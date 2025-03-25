using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Models;
using DAA.Models.Configuration;
using DAA.Models.Tasks;
using DAA.Services.Notifications;
using DAA.Services.Users;
using DAA.Shared;
using DAA.Extensions.Exceptions;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;
using System.Text;

namespace DAA.Services.Tasks
{
    public class TaskService : BaseService, ITaskService
    {
        private readonly IUserInfo _userInfo;
        private readonly IUserService _userService;
        private readonly ApplicationSettings _appSettings;
        private readonly INotificationEventService _notificationEventService;

        public TaskService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IUserInfo userInfo,
            IUserService userService,
            INotificationEventService notificationEventService,
            IOptions<ApplicationSettings> appSettings)
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _userService = userService;
            _notificationEventService = notificationEventService;
            _appSettings = appSettings.Value;
        }

        public async Task<OperationResult> CreateAsync(TaskCreateModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            // should be called inside transaction, do not add one here!

            try
            {
                List<TaskModel> taskModels = await CreateNewTaskModels(model);
                List<Data.Task> tasks = new List<Data.Task>();
                foreach (var taskModel in taskModels)
                {
                    var task = taskModel.ToEntity();
                    task.StatusCode = String.IsNullOrWhiteSpace(task.StatusCode) ? Shared.TaskStatus.Pending : task.StatusCode;
                    tasks.Add(task);
                }

                await _context.Tasks.AddRangeAsync(tasks);
                await _context.SaveAsync("Tasks created");

                foreach (var newTask in tasks)
                {
                    await _notificationEventService.AddNotificationEvent(newTask.Id, Shared.NotificationType.NewTask, null, null);
                }

                return OperationResult.Succeed(tasks);
            }
            catch (CustomException exc)
            {
                return OperationResult.Failed(false, exc.Message.ToString());
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.Message.ToString());
            }
        }

        private async Task<List<TaskModel>> CreateNewTaskModels(TaskCreateModel createModel)
        {
            //var context = new ValidationContext(createModel);
            //List<ValidationResult> validationResults = new List<ValidationResult>();
            //bool isValid = Validator.TryValidateObject(createModel, context, validationResults, true);
            //if (!isValid)
            //{
            //    var errorMessage = String.Join("; ", validationResults.Select(r => r.ErrorMessage).ToList());
            //    throw new ArgumentException(errorMessage);
            //}

            if (createModel.StepType == ProcessStepType.NoStep &&
                createModel.NotificationType == Shared.NotificationType.None)
            {
                throw new ArgumentException(_localizer.GetString("MissingTaskStepAndNotificationType").ToString());
            }

            TaskTemplate? taskTemplate = null;
            if (createModel.StepType != ProcessStepType.NoStep)
            {
                taskTemplate = await _context.ProcessSteps
                    .Where(x => x.Id == (int)createModel.StepType)
                    .Select(x => x.TaskTemplatesNavigation.FirstOrDefault())
                    .FirstOrDefaultAsync();
            }
            else
            {
                taskTemplate = await _context.TaskTemplates
                    .Where(x => x.NotificationType == createModel.NotificationType)
                    .FirstOrDefaultAsync();
            }

            if (taskTemplate == null)
            {
                throw new CustomException(String.Format(_localizer.GetString("Error_MissingTaskTemplate").ToString(), (int)createModel.StepType));
            }

            List<Guid> assignedToUsers = await GetAssignedToUsers(createModel.AssignedToUserId, createModel.AssignedToRoleId);
            if (assignedToUsers == null || assignedToUsers.Count == 0)
            {
                throw new CustomException(String.Format(_localizer.GetString("Error_MissingTaskAssignedUsers").ToString(), createModel.EntityId, (int)createModel.StepType));
            }

            //TODO Това трябва да се махне
            if (string.IsNullOrEmpty(createModel.EntityType))
            {
                string entityType = BusinessObjectType.Unknown;
                switch (createModel.StepType)
                {
                    case Shared.ProcessStepType.Film_SendForApproval:
                    case Shared.ProcessStepType.Film_SendCardForApproval:
                    case Shared.ProcessStepType.Film_SendAllForApproval:
                        entityType = BusinessObjectType.Film;
                        break;
                    case Shared.ProcessStepType.EditData_ProcessInitiation:
                    case Shared.ProcessStepType.EditData_UndoChanges:
                    case Shared.ProcessStepType.EditData_EditData:
                    case Shared.ProcessStepType.EditData_ProcessFinalization:
                    case Shared.ProcessStepType.RefineData_ProcessInitiation:
                    case Shared.ProcessStepType.RefineData_UndoChanges:
                    case Shared.ProcessStepType.RefineData_EditData:
                    case Shared.ProcessStepType.RefineData_CreateReport:
                    case Shared.ProcessStepType.RefineData_SendReport:
                    case Shared.ProcessStepType.RefineData_AddReportToSessionAgenda:
                    case Shared.ProcessStepType.RefineData_ProcessFinalization:
                    case Shared.ProcessStepType.EditFundData_ProcessInitiation:
                    case Shared.ProcessStepType.EditFundData_UndoChanges:
                    case Shared.ProcessStepType.EditFundData_EditData:
                    case Shared.ProcessStepType.EditFundData_CreateReport:
                    case Shared.ProcessStepType.EditFundData_SendReport:
                    case Shared.ProcessStepType.EditFundData_AddReportToSessionAgenda:
                        entityType = BusinessObjectType.Fund;
                        break;
                    default:
                        break;
                }
                createModel.EntityType = entityType;
            }

            Tuple<string, string, string> result =
                await ReplaceKeywords(
                    taskTemplate.Title,
                    taskTemplate.Description,
                    taskTemplate.RelatedContentUrl,
                    createModel.EntityId,
                    createModel.EntitySystemIdentifier,
                    createModel.EntityType,
                    createModel.ProcessId,
                    createModel.TimelineId);
            string title = result.Item1;
            string description = result.Item2;
            string url = result.Item3;

            List<TaskModel> list = new List<TaskModel>();
            foreach (var user in assignedToUsers)
            {
                TaskModel model = new TaskModel
                {
                    ProcessId = createModel.ProcessId,
                    StepId = createModel.TimelineId,
                    NotificationType = createModel.NotificationType,
                    Title = title,
                    Description = description,
                    EndDate = createModel.EndDate,
                    RelatedEntityId = createModel.EntityId,
                    RelatedEntitySystemIdentifier = createModel.EntitySystemIdentifier,
                    RelatedEntityType = createModel.EntityType,
                    RelatedContentUrl = url,
                    AssignedToUserId = user,
                    AssignedToRoleId = !string.IsNullOrWhiteSpace(createModel.AssignedToRoleId) ? new Guid(createModel.AssignedToRoleId) : null,
                    StatusCode = createModel.StatusCode,
                };
                list.Add(model);
            }

            return list;
        }

        private async Task<List<Guid>> GetAssignedToUsers(string? userId, string? roleId)
        {
            List<Guid> assignedToUsers = new List<Guid>();

            if (!String.IsNullOrWhiteSpace(userId))
            {
                assignedToUsers.Add(new Guid(userId));
            }
            else if (!String.IsNullOrWhiteSpace(roleId))
            {
                assignedToUsers = await _userService.GetUsersInRole(new Guid(roleId));
            }

            return assignedToUsers;
        }

        private async Task<Tuple<string, string, string>> ReplaceKeywords(
            string title,
            string description,
            string url,
            int? entityId,
            Guid? entitySysId,
            string entityType,
            int? processId,
            int? timelineId)
        {
            string replacedTitle = title;
            string replacedDescription = description;
            string replacedUrl = url;
            string baseUrl = _appSettings.Uri!;
            string baseUrlInternal = _appSettings.UriInternal!;
            string displayUrl = string.Empty;
            string displayUrlInternal = string.Empty;

            ProcessTimeline? processStep = null;
            string processStepComment = null!;
            if (timelineId != null)
            {
                processStep = await _context.ProcessTimelines.Where(x => x.Id == timelineId.Value).FirstOrDefaultAsync();
                processStepComment = processStep != null ? processStep.Comment! : string.Empty;
            }

            switch (entityType)
            {
                case EntityType.eDocsCollecting:
                    // TODO
                    break;

                case EntityType.film:
                    var film =
                        await _context.VFilms
                        .Where(x => x.SystemIdentifier == entitySysId && x.IsDraft.HasValue && x.IsDraft.Value == true)
                        .FirstOrDefaultAsync();

                    if (film == null)
                    {
                        film =
                        await _context.VFilms
                        .Where(x => x.SystemIdentifier == entitySysId && (!x.IsDraft.HasValue || x.IsDraft.Value == false))
                        .FirstOrDefaultAsync();
                    }

                    if (film == null)
                    {
                        throw new Exception(_localizer.GetString("Error_ItemNeededForTaskDoesNotExists").ToString());
                    }

                    replacedTitle = replacedTitle.Replace("#filmInventoryNumber#", film.InventoryNumber.ToString());
                    replacedDescription = replacedDescription.Replace("#filmInventoryNumber#", film.InventoryNumber.ToString());
                    replacedUrl = replacedUrl.Replace("#filmInventoryNumber#", film.InventoryNumber.ToString());

                    replacedTitle = replacedTitle.Replace("#filmNumber#", film.CountryCode);
                    replacedDescription = replacedDescription.Replace("#filmNumber#", film.CountryCode);
                    replacedUrl = replacedUrl.Replace("#filmNumber#", film.CountryCode);

                    string filmUrl = $"<p><a href='{baseUrl}/films/display/{entitySysId}' target='_blank'>{_localizer.GetString("InventoryNumber")} {film.InventoryNumber}</a></p>";
                    replacedTitle = replacedTitle.Replace("#filmDisplayUrl#", filmUrl);
                    replacedDescription = replacedDescription.Replace("#filmDisplayUrl#", filmUrl);
                    replacedUrl = replacedUrl.Replace("#filmDisplayUrl#", filmUrl);
                    break;


                case EntityType.fund:
                    var fund = await _context.VFunds.Where(f => f.SystemIdentifier == entitySysId).FirstOrDefaultAsync();
                    replacedTitle = replacedTitle
                                    .Replace(TemplateKeyphrase.Number, fund?.Number)
                                    .Replace(TemplateKeyphrase.Title, fund?.Title)
                                    .Replace(TemplateKeyphrase.ApproximateChronologicalScope, fund?.ApproxmateChronologicalScope);
                    replacedDescription = replacedDescription
                                        .Replace(TemplateKeyphrase.Number, fund?.Number)
                                        .Replace(TemplateKeyphrase.Title, fund?.Title)
                                        .Replace(TemplateKeyphrase.ApproximateChronologicalScope, fund?.ApproxmateChronologicalScope);

                    displayUrl = $"<p><a href='{baseUrl}/funds/display/{fund!.SystemIdentifier}' target='_blank'> {fund.DescriptionLevelText} {fund.Number} {fund.Title} {fund.ApproxmateChronologicalScope}</a></p>";
                    break;


                case EntityType.inventory:
                    var inventory = await _context.VInventories.Where(a => a.SystemIdentifier == entitySysId).FirstOrDefaultAsync();

                    displayUrl = $"<p><a href='{baseUrl}/inventories/display/{inventory!.SystemIdentifier}' target='_blank'>{inventory.DescriptionLevelText} {inventory.Number} {inventory.ApproxmateChronologicalScope}</a></p>";
                    break;


                case EntityType.archivalEntity:
                    var archivalEntity = await _context.VArchivalEntities.Where(a => a.SystemIdentifier == entitySysId).FirstOrDefaultAsync();
                    displayUrl = $"<p><a href='{baseUrl}/archiveEntities/display/{archivalEntity!.SystemIdentifier}' target='_blank'> {archivalEntity.DescriptionLevelText} {archivalEntity.Number} {archivalEntity.Title}</a></p>";
                    break;


                case EntityType.document:
                    var document =
                       await _context.VDocuments
                       .Where(x => x.SystemIdentifier == entitySysId)
                       .FirstOrDefaultAsync();

                    displayUrl = $"<p><a href='{baseUrl}/documents/display/{document!.SystemIdentifier}' target='_blank'>{document.DescriptionLevelText} {document.Title}</a></p>";
                    break;


                case EntityType.session:
                    displayUrl = $"<p><a href='{baseUrl}/commission/sessions/current/{entityId}' target='_blank'>{_localizer.GetString("Изпратен протокол за утвърждаване")}  </a></p>";
                    break;


                case EntityType.eDocsApplication:
                    var application = await _context.EdocsCollectingApplications
                        .Include(x => x.TypeNavigation)
                        .Include(x => x.DocumentsOriginTypeNavigation)
                        .Include(x => x.InverseRedirectApplication).ThenInclude(a => a.Archive)
                        .Where(x => x.Id == entityId)
                        .FirstOrDefaultAsync();

                    displayUrl = $"<p><a href='{baseUrl}/edocscollection/applications/display/{application?.Id}' target='_blank'>{application?.TypeNavigation.Text}</a></p>";
                    displayUrlInternal = $"<p><a href='{baseUrlInternal}/edocscollection/applications/display/{application?.Id}' target='_blank'>{application?.TypeNavigation.Text}</a></p>";
                    replacedDescription = replacedDescription
                        .Replace(TemplateKeyphrase.ApplicationType, application != null && application.TypeNavigation != null ? application.TypeNavigation.Text : String.Empty)
                        .Replace(TemplateKeyphrase.DocumentsOrigin, application != null && application.DocumentsOriginTypeNavigation != null ? application.DocumentsOriginTypeNavigation.Text : String.Empty)
                        .Replace(TemplateKeyphrase.DocumentsOwner, application != null ? application.DocumentsOwner : String.Empty)
                        .Replace(TemplateKeyphrase.ApplicantFullName, application != null ? application.ApplicantFullName : String.Empty)
                        .Replace(TemplateKeyphrase.ApplicantEmail, application != null ? application.ApplicantEmail : String.Empty)
                        .Replace(TemplateKeyphrase.ApplicationNumber, application != null ? application.Number.ToString() : String.Empty)
                        .Replace(TemplateKeyphrase.ApplicationDate, application != null && application.CreatedOn.HasValue ? application.CreatedOn.Value.UtcToLocalTime().ToString("dd.MM.yyyy г.") : String.Empty)
                        .Replace(TemplateKeyphrase.ApplicationRejectReason, application != null ? application.RejectReason : String.Empty)
                        .Replace(TemplateKeyphrase.RedirectArchiveName, application != null && application.InverseRedirectApplication.Any() ? application.InverseRedirectApplication.First().Archive.Name : String.Empty)
                        .Replace(TemplateKeyphrase.InternalDisplayUrl, displayUrlInternal);
                    break;

                default:
                    break;
            }

            if (replacedTitle.Contains(TemplateKeyphrase.ReportNumber, StringComparison.OrdinalIgnoreCase)
                || replacedDescription.Contains(TemplateKeyphrase.ReportNumber, StringComparison.OrdinalIgnoreCase))
            {
                var reportNumber =
                    await _context.Epkreports
                    .Where(r => r.ProcessId == processId && !r.Deleted)
                    .Select(r => r.Number)
                    .FirstOrDefaultAsync();
                replacedTitle = replacedTitle.Replace(TemplateKeyphrase.ReportNumber, reportNumber.ToString());
                replacedDescription = replacedDescription.Replace(TemplateKeyphrase.ReportNumber, reportNumber.ToString());
            }
            if (replacedTitle.Contains(TemplateKeyphrase.SessionDate, StringComparison.OrdinalIgnoreCase)
                || replacedDescription.Contains(TemplateKeyphrase.SessionDate, StringComparison.OrdinalIgnoreCase))
            {
                var sessionDate =
                    await _context.SessionAgenda
                    .Where(item => item.ProcessId == processId && !item.Deleted)
                    .Select(item => item.Session!.SessionDate.UtcToLocalTime())
                    .FirstOrDefaultAsync();
                replacedTitle = replacedTitle.Replace(TemplateKeyphrase.SessionDate, sessionDate.ToString());
                replacedDescription = replacedDescription.Replace(TemplateKeyphrase.SessionDate, sessionDate.ToString());
            }

            replacedTitle = replacedTitle.Replace(TemplateKeyphrase.DisplayUrl, displayUrl);
            replacedTitle = replacedTitle.Replace(TemplateKeyphrase.InternalDisplayUrl, displayUrlInternal);
            replacedDescription = replacedDescription.Replace(TemplateKeyphrase.DisplayUrl, displayUrl);
            replacedDescription = replacedDescription.Replace(TemplateKeyphrase.InternalDisplayUrl, displayUrlInternal);
            replacedDescription = replacedDescription.Replace(TemplateKeyphrase.ProcessStepComment, processStepComment);
            replacedUrl = replacedUrl.Replace(TemplateKeyphrase.DisplayUrl, displayUrl);
            replacedUrl = replacedUrl.Replace(TemplateKeyphrase.InternalDisplayUrl, displayUrlInternal);

            return new Tuple<string, string, string>(replacedTitle, replacedDescription, replacedUrl);
        }

        public async Task<OperationResult> ChangeTaskStatus(int taskId, string newStatus)
        {
            // should be called inside transaction, do not add one here!
            try
            {
                var task = await _context.Tasks.FindAsync(taskId);
                if (task == null)
                {
                    return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                OperationResult validateResult = ValidateTaskStatusChange(task, newStatus);
                if (!validateResult.Succeeded)
                {
                    //return OperationResult.Failed(String.Join("; ", validateResult.Errors));
                    return validateResult;
                }

                task.StatusCode = newStatus;

                _context.Update(task);
                await _context.SaveAsync($"Task status changed to {newStatus}");

                //if (newStatus == Shared.TaskStatus.Complete)
                //{
                //    await _notificationService.AddNotificationEvent(task.Id, Shared.NotificationType.CompletedTask);
                //}
                //else if (newStatus == Shared.TaskStatus.Cancelled)
                //{
                //    await _notificationService.AddNotificationEvent(task.Id, Shared.NotificationType.CancelledTask);
                //}

                return OperationResult.Succeed(task);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.Message.ToString());
            }
        }

        private OperationResult ValidateTaskStatusChange(Data.Task task, string newStatus)
        {
            if (task.StatusCode == Shared.TaskStatus.Completed)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_TaskAlreadyCompleted").ToString());
            }

            if (newStatus == Shared.TaskStatus.Canceled)
            {
                if (task.CreatedBy != _userInfo.CurrentUserId
                    || (task.StatusCode != Shared.TaskStatus.Pending && task.StatusCode != Shared.TaskStatus.NotStarted))
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_CannotCancelTask").ToString());
                }
            }
            //else if (newStatus == Shared.TaskStatus.Completed && task.StatusCode != Shared.TaskStatus.Pending)
            //{
            //    return OperationResult.Failed(_localizer.GetString("Error_CannotCompleteTask").ToString());
            //}
            else
            {
                if (task.StatusCode == Shared.TaskStatus.Canceled)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_TaskAlreadyCanceled").ToString());
                }
            }

            return OperationResult.Success;
        }

        public DataSourceResponseModel<TaskShortModel> GetMyTasks(DataSourceRequestModel model, bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.VTasks
                .Where(x => x.AssignedToUserId == _userInfo.CurrentUserId && x.StatusCode == Shared.TaskStatus.Pending)
                .OrderByDescending(f => f.Id)
                .AsQueryable();

            return doGetAll(query, model);
        }

        public DataSourceResponseModel<TaskShortModel> GetAssignedByMe(DataSourceRequestModel model, bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.VTasks
                .Where(x => x.CreatedBy == _userInfo.CurrentUserId && x.ProcessCompleted != true && x.StatusCode != Shared.TaskStatus.Completed)
                .OrderByDescending(f => f.Id)
                .AsQueryable();

            return doGetAll(query, model);
        }

        private DataSourceResponseModel<TaskShortModel> doGetAll(IQueryable<VTask> query, DataSourceRequestModel model, bool includeDeleted = false)
        {
            if (!includeDeleted)
            {
                query = query.Where(f => !f.Deleted);
            }

            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }

            QueryResponseModel<Data.VTask> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<TaskShortModel> result = new DataSourceResponseModel<TaskShortModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => new TaskShortModel()
                {
                    Id = x.Id,
                    Title = x.Title,
                    EndDate = x.EndDate.UtcToLocalTime(),
                    StatusCode = x.StatusCode,
                    StatusName = x.StatusName,
                    RelatedContentUrl = x.RelatedContentUrl,
                    CreatedOn = x.CreatedOn.UtcToLocalTime(),
                    CreatedByDisplayName = x.CreatedByDisplayName,
                    UpdatedOn = x.UpdatedOn.UtcToLocalTime(),
                    UpdatedByDisplayName = x.UpdatedByDisplayName,
                    AssignedToDisplayName = x.AssignedToDisplayName,
                    AssignedToRoleName = x.AssignedToRoleName,
                    ProcessTypeName = x.ProcessTypeName,
                    StepTypeName = x.StepTypeName,
                    NotificationTypeName = x.NotificationTypeName,
                })
            };
            return result;
        }


        public async Task<TaskDisplayModel?> GetById(int id)
        {
            var model =
                await _context.Tasks
                .Where(f => f.Id == id && !f.Deleted)
                .Select(x => new TaskDisplayModel()
                {
                    Id = x.Id,
                    ProcessId = x.ProcessId,
                    ProcessTypeName = x.Process != null && x.Process.ProcessType != null ? x.Process.ProcessType.Name : null,
                    StepId = x.StepId,
                    StepTypeName = x.Step != null && x.Step.StepType != null ? x.Step.StepType.Text : null,
                    NotificationType = x.NotificationType,
                    NotificationTypeName = x.NotificationTypeNavigation != null ? x.NotificationTypeNavigation.Text : null,
                    Title = x.Title,
                    Description = x.Description,
                    EndDate = x.EndDate.UtcToLocalTime(),
                    StatusName = x.StatusCodeNavigation.Text,
                    RelatedContentUrl = x.RelatedContentUrl,
                    CreatedOn = x.CreatedOn.UtcToLocalTime(),
                    CreatedByDisplayName = x.CreatedByNavigation != null ? x.CreatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == x.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName : null,
                    UpdatedOn = x.UpdatedOn.UtcToLocalTime(),
                    UpdatedByDisplayName = x.UpdatedByNavigation != null ? x.UpdatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == x.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName : null,
                    AssignedToDisplayName = x.AssignedToUser.AspNetUserProfileUsers.Where(up => up.UserId == x.AssignedToUserId && !up.Deleted).FirstOrDefault().DisplayName,
                    AssignedToRoleName = x.AssignedToRole != null ? x.AssignedToRole.Name : null,
                })
                .SingleOrDefaultAsync();

            return model;
        }


        public async Task<OperationResult> CompletePreviousTask(ProcessStepType prevStep, int? processId, string notificationType, int? entityId)
        {
            try
            {
                List<Data.Task> tasks = new List<Data.Task>();
                if (prevStep != ProcessStepType.NoStep)
                {
                    tasks = await _context.Tasks
                        .Where(x =>
                            ((entityId.HasValue && x.RelatedEntityId == entityId) || x.ProcessId == processId) &&
                            x.Step!.StepTypeId == (int)prevStep &&
                            x.StatusCode == Shared.TaskStatus.Pending)
                        .ToListAsync();                    
                }
                else if (!String.IsNullOrWhiteSpace(notificationType) && notificationType != Shared.NotificationType.None)
                {
                    tasks = await _context.Tasks
                        .Where(x =>
                            x.RelatedEntityId == entityId &&
                            x.NotificationType == notificationType.ToString() &&
                            x.StatusCode == Shared.TaskStatus.Pending)
                        .ToListAsync();
                }


                OperationResult completeTaskResult = OperationResult.Success;

                if (tasks != null && tasks.Count() > 0)
                {
                    foreach (var prevTask in tasks)
                    {
                        completeTaskResult = await ChangeTaskStatus(prevTask.Id, Shared.TaskStatus.Completed);
                        if (!completeTaskResult.Succeeded)
                        {
                            return completeTaskResult;
                        }
                    }
                }

                return completeTaskResult;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<int> GetMyNewTasksCount()
        {
            return await _context.VTasks
                     .Where(x => x.AssignedToUserId == _userInfo.CurrentUserId
                            && x.StatusCode == Shared.TaskStatus.Pending)
                     // || x.StatusCode == Shared.TaskStatus.NotStarted)
                     .CountAsync();
        }
    }
}
