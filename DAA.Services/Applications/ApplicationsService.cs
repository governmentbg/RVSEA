using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Applications;
using DAA.Models.DocsCollectionProcedure;
using DAA.Models.File;
using DAA.Models.Tasks;
using DAA.Services.Notifications;
using DAA.Services.Tasks;
using DAA.Shared;
using DAA.Extensions.Exceptions;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using DAA.Extensions.DateTime;
using DAA.Services.Packages;

namespace DAA.Services.Applications
{
    public class ApplicationsService : BaseService, IApplicationsService
    {
        private readonly IUserInfo _userInfo;
        private readonly INotificationEventService _notificationEventService;
        private readonly ITaskService _taskService;
        private readonly IPackagesService _packageService;

        public ApplicationsService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IUserInfo userInfo,
            INotificationEventService notificationEventService,
            ITaskService taskService,
            IPackagesService packageService)
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _notificationEventService = notificationEventService;
            _taskService = taskService;
            _packageService = packageService;
        }

        public DataSourceResponseModel<ApplicationGridModel> List(DataSourceRequestModel model)
        {
            var processes = from a in _context.EdocsCollectingApplications
                            where !a.Deleted
                               && a.CreatedBy == _userInfo.CurrentUserId
                            orderby a.CreatedOn descending
                            select new ApplicationGridModel()
                            {
                                Applicant = a.Applicant.AspNetUserProfileUsers.Where(up => up.UserId == a.ApplicantId && !up.Deleted).FirstOrDefault().DisplayName,
                                ApplicationDate = a.CreatedOn.Value,
                                Archive = a.Archive.Name,
                                Id = a.Id,
                                Number = a.Number,
                                Status = a.Status.Text,
                                Type = a.TypeNavigation.Text,
                                TypeId = a.Type,
                                StatusId = a.StatusId
                            };

            QueryResponseModel<ApplicationGridModel> queryResponse = processes.SortAndFilter(model);

            DataSourceResponseModel<ApplicationGridModel> result = new DataSourceResponseModel<ApplicationGridModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => new ApplicationGridModel() 
                {
                    Applicant = x.Applicant,
                    ApplicationDate = x.ApplicationDate.UtcToLocalTime(),
                    Archive = x.Archive,
                    Id = x.Id,
                    Number = x.Number,
                    Status = x.Status,
                    Type = x.Type,
                    TypeId = x.TypeId,
                    StatusId = x.StatusId
                })
            };
            return result;
        }

        public DataSourceResponseModel<ApplicationGridModel> ListNew(DataSourceRequestModel model)
        {
            var processes = from a in _context.EdocsCollectingApplications
                            where !a.Deleted
                            orderby a.CreatedOn descending
                            select new ApplicationGridModel()
                            {
                                Applicant = a.Applicant.AspNetUserProfileUsers.Where(up => up.UserId == a.ApplicantId && !up.Deleted).FirstOrDefault().DisplayName,
                                ApplicationDate = a.CreatedOn.Value,
                                Archive = a.Archive.Name,
                                Id = a.Id,
                                Status = a.Status.Text,
                                Type = a.TypeNavigation.Text,
                                TypeId = a.Type,
                                DocumentOriginType = $"Заявление за предаване на {a.DocumentsOriginTypeNavigation.Text.ToLower()}",
                                DocumentOriginTypeId = a.DocumentsOriginType,
                                StatusId = a.StatusId,
                                Number = a.Number,
                                Organization = a.Organization
                            };

            QueryResponseModel<ApplicationGridModel> queryResponse = processes.SortAndFilter(model);

            DataSourceResponseModel<ApplicationGridModel> result = new DataSourceResponseModel<ApplicationGridModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => new ApplicationGridModel() 
                {
                    Applicant = x.Applicant,
                    ApplicationDate = x.ApplicationDate.UtcToLocalTime(),
                    Archive = x.Archive,
                    Id = x.Id,
                    Status = x.Status,
                    Type = x.Type,
                    TypeId = x.TypeId,
                    DocumentOriginType = $"Заявление за предаване на {x.DocumentOriginType}",
                    DocumentOriginTypeId = x.DocumentOriginTypeId,
                    StatusId = x.StatusId,
                    Number = x.Number,
                    Organization = x.Organization
                })
            };
            return result;
        }

        public async System.Threading.Tasks.Task CreateApplication(ApplicationCreateModel model)
        {
            using var transaction = _context.Database.BeginTransaction();

            try
            {
                //TODO Да ги питаме за номерация
                int lastNumber = await _context.EdocsCollectingApplications.OrderBy(x => x.Id).Select(x => x.Number).LastOrDefaultAsync();
                int nextNumber = lastNumber + 1;

                EdocsCollectingApplication application = new EdocsCollectingApplication()
                {
                    ApplicantId = model.ApplicantId,
                    ApplicantAddress = model.Address,
                    ApplicantEmail = model.ApplicantEmail,
                    ApplicantFullName = model.ApplicantFullName,
                    Organization = model.Organization,
                    OrganizationRepresentative = model.OrganizationRepresentative,
                    ArchiveId = model.ArchiveId,
                    Number = nextNumber,
                    Type = model.Type,
                    StatusId = (int)ApplicationStatus.New,
                    OrganizationEik = model.OrganizationEIK,
                    ApplicantPhone = model.ApplicantPhone,
                    DocumentsOriginType = model.DocumentsOriginType,
                    DocumentsOwner = model.DocumentsOwner,
                    DocumentsPeriod = model.DocumentsPeriod,
                    DocumentsSize = model.DocumentsSize
                };

                _context.EdocsCollectingApplications.Add(application);
                //await _context.SaveChangesAsync();
                await _context.SaveAsync(null);



                // add event for notification
                var roleName = _localizer.GetString("Role_G").ToString();
                var role = await _context.AspNetRoles
                        .Where(r => r.ArchiveId == application.ArchiveId && r.Name == roleName)
                        .OrderBy(r => r.Name)
                        .FirstOrDefaultAsync();
                Guid? assignedToRoleId = role != null ? role.Id : null;
                //await _notificationEventService.AddNotificationEvent(application.Id, Shared.NotificationType.NewApplication, assignedToRoleId, null);

                if (assignedToRoleId != null)
                {
                    TaskCreateModel taskModel = new()
                    {
                        NotificationType = Shared.NotificationType.NewApplication,
                        EntityType = BusinessObjectType.EDocsApplication,
                        EntityId = application.Id,
                        AssignedToRoleId = assignedToRoleId.Value.ToString("D"),
                    };

                    var taskResult = await _taskService.CreateAsync(taskModel);
                    if (!taskResult.Succeeded)
                    {
                        throw new Exception(String.Join("; ", taskResult.Errors));
                    }
                }

                transaction.Commit();
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                throw;
            }
        }

        async Task<EdocsCollectingApplication?> IApplicationServiceBase.GetByProcessInternalAsync(int processId)
        {
            var process = await _context.Processes.Where(p => p.Id == processId && !p.Deleted).SingleOrDefaultAsync();
            if (process == null)
            {
                throw new ItemNotFoundException(nameof(process), processId.ToString());
            }

            var applicationId = await _context.VInventories
                                .Where(inv =>
                                    (process.InventorySystemIdentifier.HasValue && inv.SystemIdentifier == process.InventorySystemIdentifier)
                                    || (process.FundSystemIdentifier.HasValue && inv.FundSystemIdentifier == process.FundSystemIdentifier))
                                .Select(inv => inv.ApplicationId)
                                .SingleOrDefaultAsync();
            if (applicationId.HasValue)
            {
                return await _context.EdocsCollectingApplications
                        .Where(app => app.Id == applicationId && !app.Deleted)
                        .Select(app => app)
                        .SingleOrDefaultAsync();
            }

            return null;
        }

        public async Task<ApplicationDisplayModel?> GetByProcessAsync(int processId)
        {
            var process = await _context.Processes.Where(p => p.Id == processId && !p.Deleted).SingleOrDefaultAsync();
            if (process == null)
            {
                throw new ItemNotFoundException(nameof(process), processId.ToString());
            }

            var applicationId = await _context.VInventories
                                .Where(inv =>
                                    (process.InventorySystemIdentifier.HasValue && inv.SystemIdentifier == process.InventorySystemIdentifier)
                                    || (process.FundSystemIdentifier.HasValue && inv.FundSystemIdentifier == process.FundSystemIdentifier))
                                .Select(inv => inv.ApplicationId)
                                .SingleOrDefaultAsync();
            if (applicationId.HasValue)
            {
                return await _context.EdocsCollectingApplications
                        .Where(app => app.Id == applicationId && !app.Deleted)
                        .Select(app => new ApplicationDisplayModel()
                        {
                            ApplicantFullName = app.ApplicantFullName!,
                            ApplicantEmail = app.ApplicantEmail!,
                            ApplicantPhone = app.ApplicantPhone!,
                            ApplicationDate = app.CreatedOn.UtcToLocalTime() ?? default,
                            Address = app.ApplicantAddress!,
                            Archive = app.Archive.Name!,
                            ArchiveId = app.ArchiveId,
                            Id = app.Id,
                            Number = app.Number,
                            Status = app.Status.Text,
                            StatusId = app.StatusId,
                            RejectReason = app.RejectReason,
                            Type = app.TypeNavigation.Text,
                            TypeId = app.Type,
                            DocumentsOriginType = app.DocumentsOriginTypeNavigation!.Text,
                            DocumentsOwner = app.DocumentsOwner!,
                            DocumentsPeriod = app.DocumentsPeriod!,
                            DocumentsSize = app.DocumentsSize ?? 0,
                            Organization = app.Organization!,
                            OrganizationEIK = app.OrganizationEik!,
                            OrganizationRepresentative = app.OrganizationRepresentative!,
                        })
                        .SingleOrDefaultAsync();
            }

            return null;
        }

        public ApplicationDisplayModel? Display(int id)
        {
            var inventory = _context.Inventories
                                    .Where(i => i.ApplicationId == id)
                                    .Include(i => i.FundSystemIdentifierNavigation)
                                    .FirstOrDefault();

            ApplicationDisplayModel? model = (from a in _context.EdocsCollectingApplications
                                              where a.Id == id
                                              && !a.Deleted
                                              select new ApplicationDisplayModel()
                                              {
                                                  ApplicantFullName = a.ApplicantFullName,
                                                  ApplicantEmail = a.ApplicantEmail,
                                                  ApplicantPhone = a.ApplicantPhone,
                                                  ApplicationDate = DateTime.SpecifyKind(a.CreatedOn.Value, DateTimeKind.Utc),
                                                  Address = a.ApplicantAddress,
                                                  Archive = a.Archive.Name,
                                                  ArchiveId = a.ArchiveId,
                                                  Id = a.Id,
                                                  Number = a.Number,
                                                  Status = a.Status.Text,
                                                  StatusId = a.StatusId,
                                                  RejectReason = a.RejectReason,
                                                  Type = a.TypeNavigation.Text,
                                                  TypeId = a.Type,
                                                  DocumentsOriginType = a.DocumentsOriginTypeNavigation.Text,
                                                  DocumentsOwner = a.DocumentsOwner,
                                                  DocumentsPeriod = a.DocumentsPeriod,
                                                  DocumentsSize = a.DocumentsSize ?? 0,
                                                  Organization = a.Organization,
                                                  OrganizationEIK = a.OrganizationEik,
                                                  OrganizationRepresentative = a.OrganizationRepresentative,
                                                  RedirectedFromArchiveName = a.InverseRedirectApplication.Any() ? a.InverseRedirectApplication.First().Archive.Name : null,
                                                  RedirectedToArchiveName = a.RedirectApplication != null ? a.RedirectApplication.Archive.Name : null,
                                                  PackageARejectReason = a.PackageA.RejectReason,
                                                  PackageBRejectReason = a.PackageB.RejectReason,

                                                  InventorySysId = inventory == null ? null : inventory.SystemIdentifier.ToString(),
                                                  FundSysId = inventory == null ? null : inventory.FundSystemIdentifier.ToString(),
                                                  FundNumber = inventory == null ? null : inventory.FundSystemIdentifierNavigation.Number
                                              }).FirstOrDefault();


            return model;
        }

        public FileModel GetApplicationFile(int applicationId)
        {
            FileModel model = (from a in _context.EdocsCollectingApplications
                               where a.Id == applicationId
                               && !a.Deleted
                               select new FileModel()
                               {
                                   Content = a.File.Content,
                                   ContentType = a.File.ContentType,
                                   Name = a.File.FileName,
                                   Type = a.File.FileType
                               }).FirstOrDefault();

            return model;
        }

        public async Task<OperationResult> Approve(ApproveModel model)
        {
            using var transaction = _context.Database.BeginTransaction();

            try
            {
                var application = await _context.EdocsCollectingApplications
                                            .FirstOrDefaultAsync(x => x.Id == model.Id
                                                                   && !x.Deleted
                                                                   && x.StatusId == (int)ApplicationStatus.New);

                if (application == null)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                application.StatusId = (int)ApplicationStatus.Approved;
                application.AssignToUserId = model.UserId;

                await _context.SaveAsync(null);


                // add events for notifications
                await _notificationEventService.AddNotificationEvent(application.Id, Shared.NotificationType.ApprovedApplication, null, application.CreatedBy);

                if (model.UserId != null)
                {
                    TaskCreateModel taskModel = new()
                    {
                        NotificationType = Shared.NotificationType.AssignedApplication,
                        EntityType = BusinessObjectType.EDocsApplication,
                        EntityId = application.Id,
                        AssignedToUserId = model.UserId.Value.ToString("D"),
                    };

                    var taskResult = await _taskService.CreateAsync(taskModel);
                    if (!taskResult.Succeeded)
                    {
                        throw new CustomException(String.Join("; ", taskResult.Errors));
                    }
                }

                // complete previous task
                var completePrevTaskResult = await _taskService.CompletePreviousTask(ProcessStepType.NoStep, null, Shared.NotificationType.NewApplication, application.Id);
                if (!completePrevTaskResult.Succeeded)
                {
                    throw new CustomException(String.Join("; ", completePrevTaskResult.Errors));
                }

                completePrevTaskResult = await _taskService.CompletePreviousTask(ProcessStepType.Redirected, null, null, application.Id);
                if (!completePrevTaskResult.Succeeded)
                {
                    throw new CustomException(String.Join("; ", completePrevTaskResult.Errors));
                }

                transaction.Commit();

                return OperationResult.Success;
            }
            catch (CustomException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(false, exc.ToString());
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        public async System.Threading.Tasks.Task Reject(RejectModel model)
        {
            using var transaction = _context.Database.BeginTransaction();

            try
            {
                var application = await GetById(model.Id, ApplicationStatus.New);

                if (application == null)
                {
                    throw new NullReferenceException();
                }

                application.StatusId = (int)ApplicationStatus.Rejected;
                application.RejectReason = model.Reason;
                await _context.SaveAsync(null);

                // add event for notification
                await _notificationEventService.AddNotificationEvent(application.Id, Shared.NotificationType.RejectedApplication, null, application.CreatedBy);

                // complete previous task
                var completePrevTaskResult = await _taskService.CompletePreviousTask(ProcessStepType.NoStep, null, Shared.NotificationType.NewApplication, application.Id);
                if (!completePrevTaskResult.Succeeded)
                {
                    throw new Exception(String.Join("; ", completePrevTaskResult.Errors));
                }

                transaction.Commit();
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                throw;
            }
        }

        private async Task<EdocsCollectingApplication?> GetById(int id, ApplicationStatus status)
        {
            return await _context.EdocsCollectingApplications
                                                .FirstOrDefaultAsync(x => x.Id == id
                                                                       && !x.Deleted
                                                                       && x.StatusId == (int)status);
        }

        public async Task<int> GetStatusAsync(int applicationId)
        {
           return await _context.EdocsCollectingApplications
                            .Where(app => app.Id == applicationId && !app.Deleted)
                            .Select(app => app.StatusId)
                            .SingleOrDefaultAsync();
        }

        public async System.Threading.Tasks.Task UpdateStatus(int applicationId, ApplicationStatus status, bool applySave = true)
        {
            //FIX Защо няма проверка дали е изтрито заявлението???
            var application = await _context.EdocsCollectingApplications.FindAsync(applicationId);

            if (application != null)
            {
                application.StatusId = (int)status;

                if (applySave)
                {
                    await _context.SaveAsync(null);
                }
            }
        }

        public DocsCollectingGridModel? ApplicationRelatedProcess(int applicationId)
        {
            int[] relatedProcesses = new int[]
            {
                (int)Shared.ProcessType.AddFundAndInventory,
                (int)Shared.ProcessType.AddInventory,
                (int)Shared.ProcessType.AddRawFundAndRawInventory,
                (int)Shared.ProcessType.AddRawInventoryToRawFund,
                (int)Shared.ProcessType.AddRawInventory,
                (int)Shared.ProcessType.AddSystemInventory,
            };
            var process = from i in _context.InventoryDrafts
                          let p = _context.Processes.Where(x => x.Completed == false
                                                                && relatedProcesses.Contains(x.ProcessTypeId)
                                                                && (x.InventorySystemIdentifier == i.SystemIdentifier
                                                                    || x.FundSystemIdentifier == i.FundSystemIdentifier))
                                                    .FirstOrDefault()
                          where i.ApplicationId == applicationId
                          && i.IsCurrent
                          && !i.Deleted
                          select new DocsCollectingGridModel()
                          {
                              ArchiveId = i.ArchiveId,
                              ArchiveName = i.Archive.Name,
                              Completed = p.Completed,
                              CreatedBy = p.CreatedBy.Value,
                              CreatedOn = DateTime.SpecifyKind(p.CreatedOn.Value, DateTimeKind.Utc),
                              CreatedByDisplayName = p.CreatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == p.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                              FundNumber = i.FundDraft.Title,
                              FundSystemId = i.FundSystemIdentifier,
                              InventoryNumber = i.Number,
                              InventorySystemId = i.SystemIdentifier,
                              ProcessTypeTitle = p.ProcessType.Name
                          };

            return process.FirstOrDefault();
        }

        public async Task<int?> GetActiveProcessIdByApplicationAsync(int applicationId)
        {
            int[] relatedProcesses = new int[]
            {
                (int)Shared.ProcessType.AddFundAndInventory,
                (int)Shared.ProcessType.AddInventory,
                (int)Shared.ProcessType.AddRawFundAndRawInventory,
                (int)Shared.ProcessType.AddRawInventoryToRawFund,
                (int)Shared.ProcessType.AddRawInventory,
                (int)Shared.ProcessType.AddSystemInventory,
            };
            var process = from i in _context.InventoryDrafts
                          let p = _context.Processes.Where(x => x.Completed == false
                                                                && relatedProcesses.Contains(x.ProcessTypeId)
                                                                && (x.InventorySystemIdentifier == i.SystemIdentifier
                                                                    || x.FundSystemIdentifier == i.FundSystemIdentifier))
                                                    .FirstOrDefault()
                          where i.ApplicationId == applicationId
                          && i.IsCurrent
                          && !i.Deleted
                          select p.Id;

            return await process.FirstOrDefaultAsync();
        }

        public Guid GetApplicationInventoryIdentifier(int applicationId)
        {
            Guid id = _context.InventoryDrafts.Where(x => x.ApplicationId == applicationId && !x.Deleted).Select(x => x.SystemIdentifier).SingleOrDefault();

            if (id == Guid.Empty)
            {
                throw new ItemNotFoundException($"Application {applicationId} inventory not found");
            }

            return id;
        }

        public async Task<bool> HasAnyPackagesAsync(int applicationId)
        {
            return await _context.EdocsCollectingApplications.Where(app => app.Id == applicationId && (app.PackageAid.HasValue || app.PackageBid.HasValue)).AnyAsync();
            //return _context.Packages.Where(p => p.ApplicationId == applicationId && !p.Deleted).AnyAsync();
        }

        public async Task<OperationResult> Delete(int id)
        {
            var ent = _context.EdocsCollectingApplications
                       .Where(a => a.Id == id && !a.Deleted)
                       .FirstOrDefault();

            if (ent == null)
            {
                return OperationResult.Failed();
            }
            if (ent.CreatedBy != _userInfo.CurrentUserId)
            {
                return OperationResult.Failed();
            }

            ent.Deleted = true;
            ent.DeletedOn = DateTime.UtcNow;
            ent.DeletedBy = _userInfo.CurrentUserId;

            _context.Update(ent);
            await _context.SaveChangesAsync();

            return OperationResult.Success;
        }

        public async Task<EdocsCollectingApplication?> GetApplicationFromInventoryDraft(Guid? fundSystemIdentifier, Guid? inventorySystemIdentifier)
        {
            var application = await (from i in _context.InventoryDrafts
                                     where ((fundSystemIdentifier.HasValue && i.FundSystemIdentifier == fundSystemIdentifier.Value)
                                     || (inventorySystemIdentifier.HasValue && i.SystemIdentifier == inventorySystemIdentifier.Value))
                                     && i.IsCurrent
                                     && !i.Deleted
                                     select i.Application).FirstOrDefaultAsync();

            return application;
        }

        public async Task<OperationResult> RedirectAsync(EdocsCollectingApplication application, int newArchiveId)
        {
            try
            {
                if (application == null)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                int? packageACopyId = null;
                if (application.PackageAid.HasValue)
                {
                    packageACopyId = await _packageService.CopyPackageAsync(application.PackageAid.Value);
                }

                // create new application
                int lastNumber = await _context.EdocsCollectingApplications.OrderBy(x => x.Id).Select(x => x.Number).LastOrDefaultAsync();
                int nextNumber = lastNumber + 1;

                EdocsCollectingApplication newApplication = new EdocsCollectingApplication()
                {
                    ApplicantId = application.ApplicantId,
                    ApplicantAddress = application.ApplicantAddress,
                    ApplicantEmail = application.ApplicantEmail,
                    ApplicantFullName = application.ApplicantFullName,
                    Organization = application.Organization,
                    OrganizationRepresentative = application.OrganizationRepresentative,
                    ArchiveId = newArchiveId,
                    Number = nextNumber,
                    Type = application.Type,
                    StatusId = (int)ApplicationStatus.New,
                    OrganizationEik = application.OrganizationEik,
                    ApplicantPhone = application.ApplicantPhone,
                    DocumentsOriginType = application.DocumentsOriginType,
                    DocumentsOwner = application.DocumentsOwner,
                    DocumentsPeriod = application.DocumentsPeriod,
                    DocumentsSize = application.DocumentsSize,
                    IsFromRedirect = true,
                    CreatedBy = application.CreatedBy,
                    CreatedOn = DateTime.UtcNow,
                    PackageAid = packageACopyId,
                    PackageBid = application.PackageBid,
                    IsSystem = application.IsSystem,
                };

                _context.EdocsCollectingApplications.Add(newApplication);
                await _context.SaveAsync(null, true);


                application.StatusId = (int)ApplicationStatus.Redirected;
                application.RedirectApplicationId = newApplication.Id;
                application.PackageBid = null;

                _context.Update(application);
                await _context.SaveAsync(null);


                // add events for notifications
                await _notificationEventService.AddNotificationEvent(application.Id, Shared.NotificationType.RedirectedApplication, null, application.CreatedBy);

                return OperationResult.Succeed(newApplication.Id);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(false, exc.Message.ToString());
            }
        }

        public async Task<OperationResult> CreateSystemApplicationAsync(InventoryDraft invDraft, string? docOriginType)
        {
            try
            {
                if (invDraft == null)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }


                // create new application
                int lastNumber = await _context.EdocsCollectingApplications.OrderBy(x => x.Id).Select(x => x.Number).LastOrDefaultAsync();
                int nextNumber = lastNumber + 1;

                EdocsCollectingApplication systemApplication = new EdocsCollectingApplication()
                {
                    ApplicantId = invDraft.CreatedBy ?? Guid.Empty,
                    ApplicantEmail = invDraft.CreatedByNavigation != null ? invDraft.CreatedByNavigation.Email : null,
                    ApplicantFullName = invDraft.CreatedByNavigation != null ? invDraft.CreatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == invDraft.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName : null,
                    Organization = invDraft.Archive.Name,
                    ArchiveId = invDraft.ArchiveId,
                    Number = nextNumber,
                    Type = ApplicationType.Raw,
                    StatusId = (int)ApplicationStatus.New,
                    DocumentsOriginType = docOriginType,
                    DocumentsOwner = invDraft.DocumentsProvider,
                    DocumentsPeriod = invDraft.ApproxmateChronologicalScope,
                    CreatedBy = invDraft.CreatedBy ?? Guid.Empty,
                    CreatedOn = DateTime.UtcNow,
                    PackageAid = invDraft.PackageAid,
                    PackageBid = invDraft.PackageBid,
                    IsSystem = true,
                };

                _context.EdocsCollectingApplications.Add(systemApplication);
                await _context.SaveAsync(null, true);


                return OperationResult.Succeed(systemApplication);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(false, exc.Message.ToString());
            }
        }

        public async Task<Guid?> GetInventoryDraftSysId(int applicationId)
        {
            Guid? inventorySysId = await _context.EdocsCollectingApplications
                .Where(x => x.Id == applicationId)
                .Select(x => x.InventoryDrafts.Where(d => d.IsCurrent).FirstOrDefault() != null 
                    ? x.InventoryDrafts.Where(d => d.IsCurrent).First().SystemIdentifier 
                    : Guid.Empty)
                .FirstOrDefaultAsync();

            return inventorySysId;
        }


    }
}
