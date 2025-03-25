using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Models.ArchiveEntities;
using DAA.Models.Commission;
using DAA.Models.DeductionProcess;
using DAA.Models.Documents;
using DAA.Models.Funds;
using DAA.Models.Inventories;
using DAA.Models.Processes;
using DAA.Models.Tasks;
using DAA.Services.ArchivalEntities;
using DAA.Services.CommissionReports;
using DAA.Services.CommissionSessions;
using DAA.Services.Documents;
using DAA.Services.Files;
using DAA.Services.Funds;
using DAA.Services.Inventories;
using DAA.Services.Process;
using DAA.Services.Tasks;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System.Linq.Dynamic.Core;
using Task = System.Threading.Tasks.Task;

namespace DAA.Services.DeductionProcess
{
    public class DeductionProcessService : BaseService, IDeductionProcessService
    {
        private readonly IProcessService _processService;
        private readonly IUserInfo _userInfo;
        private readonly ITaskService _taskService;
        ICommissionReportService _epkService;
        IFundService _fundService;
        IInventoryService _inventoryService;
        IArchivalEntityService _archivalEntityService;
        IDocumentService _documentService;
        ISessionAgendaService _sessionAgendaService;


        public DeductionProcessService(
            ArchivingContext context,
            IProcessService processService,
            IUserInfo userInfo,
            IFileService fileService,
            ITaskService taskService,
            ICommissionReportService ePKReportService,
            IFundService fundService,
            IInventoryService inventoryService,
            ISessionAgendaService sessionAgendaService,
            IArchivalEntityService archivalEntityService,
            IDocumentService documentService,
            IStringLocalizer<SharedResources> localizer,
            ILogger<DeductionProcessService> logger
            ) : base(context, localizer, logger)
        {
            _taskService = taskService;
            _processService = processService;
            _userInfo = userInfo;
            _epkService = ePKReportService;
            _fundService = fundService;
            _sessionAgendaService = sessionAgendaService;
            _inventoryService = inventoryService;
            _archivalEntityService = archivalEntityService;
            _documentService = documentService;
        }

        public async Task<OperationResult> Start(DeductionCreateModel model)
        {
            if (model == null)
            {
                return OperationResult.Failed(false, "Процеса не може да бъде стартиран");
            }
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {

                var result = await CheckForExistingRecord(model);

                if (result.NotExistInOurSystem)
                {
                    return OperationResult.Failed(false, "Този процес трябва да бъде стартиран в ИСДА");
                }

                else if (result.IsOnlyInOurSystem)
                {
                    var success = await CreateDraftFromEntity(model);

                    if (success.Data == null)
                    {
                        return OperationResult.Failed(false, success.Errors.First());
                    }

                    var startResult = await StartProcess(model);

                    if (startResult.Succeeded)
                    {
                        await transaction.CommitAsync();
                        return OperationResult.Success;
                    }
                    else
                    {
                        await transaction.RollbackAsync();
                        return OperationResult.Failed(false, startResult.Errors.First());
                    }
                }
                else if (result.IsInBothOfSystems)
                {
                    var success = await CreateDraftFromEntity(model);

                    if (success.Data == null)
                    {
                        return OperationResult.Failed(false, success.Errors.First());
                    }

                    var startResult = await StartProcess(model);

                    if (!startResult.Succeeded)
                    {
                        await transaction.RollbackAsync();
                        return OperationResult.Failed(false, startResult.Errors.First());
                    }
                    await transaction.CommitAsync();

                    return OperationResult.Success;
                }

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                await transaction.RollbackAsync();

                return OperationResult.Failed(exc.ToString());
            }
        }
        public async Task<OperationResult> Get(Guid entitySystemIdentifier, string entityType)
        {
            using var tran = await _context.Database.BeginTransactionAsync();

            var result = new DeductionViewModel();
            try
            {
                if (entityType == "fund")
                {
                    result = _context.Processes
                        .Include(x => x.ProcessType)
                        .Include(x => x.ProcessTimelines.Where(t => !t.Completed))
                        .Include(x => x.CreatedByNavigation)
                        .Where(x => x.FundSystemIdentifier == entitySystemIdentifier && !x.Completed)
                        .Select(x => new DeductionViewModel
                        {
                            Id = x.Id,
                            ArchiveId = x.ArchiveId,
                            FundSystemIdentifier = entitySystemIdentifier.ToString(),
                            ProcedureStepId = x.ProcessTimelines.Where(x => !x.Completed).Select(x => x.StepTypeId).FirstOrDefault(),
                            ProcedureType = x.ProcessType.Id,
                            CreatedBy = x.CreatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == x.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName ?? "",
                            AssignToUserId = x.ProcessTimelines.Where(x => !x.Completed).Select(x => x.AssignedToUserId).FirstOrDefault().ToString()
                        }).FirstOrDefault();
                }
                else if (entityType == "inventory")
                {
                    result = _context.Processes
                         .Include(x => x.ProcessType)
                       .Include(x => x.ProcessTimelines.Where(t => !t.Completed))
                       .Include(x => x.CreatedByNavigation)
                       .Where(x => x.InventorySystemIdentifier == entitySystemIdentifier && !x.Completed)
                        .Select(x => new DeductionViewModel
                        {
                            Id = x.Id,
                            ArchiveId = x.ArchiveId,
                            InventorySystemIdentifier = entitySystemIdentifier.ToString(),
                            ProcedureStepId = x.ProcessTimelines.Where(x => !x.Completed).Select(x => x.StepTypeId).FirstOrDefault(),
                            ProcedureType = x.ProcessType.Id,
                            CreatedBy = x.CreatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == x.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName ?? "",
                            AssignToUserId = x.ProcessTimelines.Where(x => !x.Completed).Select(x => x.AssignedToUserId).FirstOrDefault().ToString()
                        }).FirstOrDefault();
                }
                else if (entityType == "archival_entity")
                {
                    result = _context.Processes
                          .Include(x => x.ProcessType)
                          .Include(x => x.ProcessType)
                       .Include(x => x.ProcessTimelines.Where(t => !t.Completed))
                       .Where(x => x.ArchivalEntitySystemIdentifier == entitySystemIdentifier && !x.Completed)
                        .Select(x => new DeductionViewModel
                        {
                            Id = x.Id,
                            ArchiveId = x.ArchiveId,
                            ArchivalEntitySystemIdentifier = entitySystemIdentifier.ToString(),
                            ProcedureStepId = x.ProcessTimelines.Where(x => !x.Completed).Select(x => x.StepTypeId).FirstOrDefault(),
                            ProcedureType = x.ProcessType.Id,
                            CreatedBy = x.CreatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == x.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName ?? "",
                            AssignToUserId = x.ProcessTimelines.Where(x => !x.Completed).Select(x => x.AssignedToUserId).FirstOrDefault().ToString()
                        }).FirstOrDefault();
                }
                else if (entityType == "document")
                {
                    result = _context.Processes
                        .Include(x => x.ProcessType)
                       .Include(x => x.ProcessTimelines.Where(t => !t.Completed))
                       .Where(x => x.DocumentSystemIdentifier == entitySystemIdentifier && !x.Completed)
                        .Select(x => new DeductionViewModel
                        {
                            Id = x.Id,
                            ArchiveId = x.ArchiveId,
                            CreatedBy = x.CreatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == x.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName ?? "",
                            DocumentSystemIdentifier = entitySystemIdentifier.ToString(),
                            ProcedureStepId = x.ProcessTimelines.Where(x => !x.Completed).Select(x => x.StepTypeId).FirstOrDefault(),
                            ProcedureType = x.ProcessType.Id,
                            AssignToUserId = x.ProcessTimelines.Where(x => !x.Completed).Select(x => x.AssignedToUserId).FirstOrDefault().ToString()
                        }).FirstOrDefault();
                }

                if (result != null)
                {
                    result.SessionId = _context.SessionAgenda.Where(s => s.ProcessId == result.Id).Select(s => s.SessionId).FirstOrDefault();

                    var ssessionId = _context.SessionAgenda.Where(s => s.ProcessId == result.Id).Select(s => s.Id).FirstOrDefault();
                    result.SecretarOpinion = _context.SessionAgendaStandpoints.Where(c => c.SessionAgendaItemId == ssessionId && !c.Deleted && c.IsDraft).Select(c => c.Content).FirstOrDefault();
                    result.SessionAgendaId = ssessionId;

                    result!.ProcedureStepName = _context.ProcessSteps
                        .Where(x => x.Id == result.ProcedureStepId)
                        .Select(x => x.Text)
                        .FirstOrDefault();

                    result.AssignToUserId = _context.ProcessTimelines
                        .Where(t => t.ProcessId == result.Id && !t.Completed)
                        .Select(t => t.AssignedToUserId)
                        .FirstOrDefault()
                        .ToString();

                    result.AssignToRoleId = _context.ProcessTimelines
                     .Where(t => t.ProcessId == result.Id && !t.Completed)
                     .Select(t => t.AssignedToRoleId)
                     .FirstOrDefault()
                     .ToString();

                    var currentEpkReport = _context.Epkreports
                          .Where(r => r.ProcessId == result.Id)
                          .Select(r => new CommissionReportModel
                          {
                              Id = r.Id,
                              CreatedBy = r.CreatedBy,
                              CreatedByDisplayName = r.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == r.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                              //CreatedByJobTitle = r.AuthorPosition,
                              Title = r.Title,
                              Content = r.Content,
                              //LinkTitle = r.LinkTitle,
                              //EntityLink = r.EntityLink,
                              ProcessId = r.Process!.Id,
                              CreatedOn = r.CreatedOn.UtcToLocalTime(),
                          }).FirstOrDefault();

                    if (currentEpkReport != null)
                    {
                        result.EpkReportModel = currentEpkReport;
                    }
                    else
                    {
                        result.EpkReportModel = new CommissionReportModel()
                        {
                            CreatedOn = DateTime.UtcNow,
                            CreatedByDisplayName = result.CreatedBy,
                            Title = "Отчисляване",
                            //LinkTitle = "Приложени документи",
                        };
                    }

                    int sessionAgId = await _context.SessionAgenda.Where(s => s.ReportId == result.EpkReportModel.Id).Select(s => s.Id).FirstOrDefaultAsync();

                    result.DecisionModelId = await _context.SessionDecisions.Where(d => d.SessionAgendaId == sessionAgId).Select(d => d.Id).FirstOrDefaultAsync();

                }

                await tran.CommitAsync();

                return OperationResult.Succeed(result!);
            }
            catch (Exception exc)
            {
                await tran.RollbackAsync();
                return OperationResult.Failed(exc.Message);
            }
        }
        public async Task<OperationResult> SaveChanges(DeductionViewModel model)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var processStepAsign = await _context.ProcessTimelines
                        .Where(step => step.ProcessId == model.Id && !step.Completed)
                        .Select(step => step.AssignedToUserId)
                        .SingleOrDefaultAsync();

                if (processStepAsign != null && processStepAsign != _userInfo.CurrentUserId)
                {
                    return OperationResult.Failed("Access Denied");
                }

                var currDate = DateTime.UtcNow;

                if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_SettingADateForConsiderationOfAnEPKReport)
                {
                    var session = await _context.Sessions.Where(s => s.Id == model.SessionId).FirstOrDefaultAsync();

                    if (session == null)
                    {
                        return OperationResult.Failed("Error invalid session id");
                    }

                    var existStandpoints = _context.SessionAgenda.Where(s => s.ProcessId == model.Id).Select(a => a.SessionAgendaStandpoints).FirstOrDefault();

                    var existStandpoint = existStandpoints?.Where(s => s.CreatedBy == _userInfo.CurrentUserId!.Value && !s.Deleted).FirstOrDefault() ?? null;

                    if (existStandpoint == null)
                    {
                        SessionAgendaItemModel map = new()
                        {
                            SessionId = model.SessionId.Value,
                            ProcessId = model.Id.Value,
                            ReportId = model.EpkReportModel!.Id.Value,
                        };

                        var res = await _sessionAgendaService.CreateSessionAgendaItemInternalAsync(map);

                        if (res > 0)
                        {
                            SessionAgendaStandpoint standpoint = new()
                            {
                                CreatedBy = _userInfo.CurrentUserId,
                                CreatedOn = currDate,
                                Content = model.SecretarOpinion ?? "",
                                SessionAgendaItemId = res,
                                ReportId = model.EpkReportModel.Id.Value,
                                IsDraft = true,
                            };

                            _context.SessionAgendaStandpoints.Add(standpoint);
                            await _context.SaveAsync("");
                        }

                    }
                    else
                    {
                        existStandpoint.Content = model.SecretarOpinion;
                        existStandpoint.UpdatedOn = currDate;
                        existStandpoint.UpdatedOn = currDate;
                        existStandpoint.UpdatedBy = _userInfo.CurrentUserId;


                        _context.Update(existStandpoint);
                        await _context.SaveAsync("");

                        var sessioAgenda = _context.SessionAgenda.Where(s => s.ProcessId == model.Id).FirstOrDefault();

                        sessioAgenda!.SessionId = model.SessionId;

                        _context.SessionAgenda.Update(sessioAgenda);
                        await _context.SaveAsync(""); ;
                    }
                }
                if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_IntroductionOfAnOpinionByEPKMembers)
                {
                    var user = _userInfo.CurrentUserId;

                    var userOpinion = _context.SessionAgendaStandpoints.Where(c => c.CreatedBy == user && c.SessionAgendaItemId == model.SessionAgendaId).FirstOrDefault();

                    if (userOpinion == null)
                    {
                        return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                    }
                    userOpinion.IsDraft = false;


                    _context.Update(userOpinion);
                    await _context.SaveAsync("");
                }

                await transaction.CommitAsync();

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                await transaction.RollbackAsync();

                return OperationResult.Failed(exc.ToString());
            }
        }
        public async Task<OperationResult> StepBack(DeductionViewModel model)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var processStepAsign = await _context.ProcessTimelines
                        .Where(step => step.ProcessId == model.Id && !step.Completed)
                        .Select(step => step.AssignedToUserId)
                        .SingleOrDefaultAsync();

                if (processStepAsign != null && processStepAsign != _userInfo.CurrentUserId)
                {
                    return OperationResult.Failed("Access Denied");
                }

                var processStepId =
                 await _context.ProcessTimelines
                 .Where(step => step.ProcessId == model.Id && !step.Completed)
                 .Select(step => step.Id)
                 .SingleOrDefaultAsync();

                var agendaId = _context.SessionAgenda
                 .Where(a => a.ProcessId == model.Id!.Value)
                 .Select(a => a.Id)
                 .FirstOrDefault();

                var reportCreator = _context.Epkreports.Where(r => r.ProcessId == model.Id!.Value).Select(r => r.CreatedBy).FirstOrDefault();

                string entitySys = String.Empty;


                var tasks = _context.Tasks
                    .Where(x => x.ProcessId == model.Id && x.StepId == processStepId - 1 && x.StatusCode == Shared.TaskStatus.Pending)
                    .AsQueryable();
                if (tasks != null && tasks.Count() > 0)
                {
                    OperationResult taskResult = OperationResult.Success;
                    foreach (var task in tasks)
                    {
                        taskResult = await _taskService.ChangeTaskStatus(task.Id, Shared.TaskStatus.Completed);
                        if (!taskResult.Succeeded)
                        {
                            return taskResult;
                        }
                    }
                }

                if (model.DocumentSystemIdentifier != null)
                {
                    entitySys = model.DocumentSystemIdentifier;
                }
                else if (model.ArchivalEntitySystemIdentifier != null)
                {
                    entitySys = model.ArchivalEntitySystemIdentifier;
                }
                else if (model.InventorySystemIdentifier != null)
                {
                    entitySys = model.InventorySystemIdentifier;
                }
                else if (model.FundSystemIdentifier != null)
                {
                    entitySys = model.FundSystemIdentifier;
                }

                if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_DecisionAfterAMeetingOfTheEPК
                    || model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_ConfirmedProtocol)
                {
                    TaskCreateModel taskModel = new()
                    {
                        StepType = Shared.ProcessStepType.DeductData_DecisionAfterAMeetingOfTheEPК,
                        ProcessId = model.Id!.Value,
                        TimelineId = processStepId,
                        EntitySystemIdentifier = new Guid(entitySys),
                        AssignedToUserId = reportCreator.ToString(),
                        EntityType = model.EntityType,
                    };

                    await _taskService.CreateAsync(taskModel);

                    await _context.SaveAsync("");

                    ProcessStepModel processStep = new()
                    {
                        ProcessId = model.Id!.Value,
                        StepTypeId = (int)Shared.ProcessStepType.DeductData_ImplementationOfRecommendationsFromEPК,
                        EndDate = model.EndDate,
                        Comment = _context.SessionDecisions.Where(d => d.SessionAgendaId == agendaId).Select(d => d.DecisionText).FirstOrDefault(),
                    };

                    if (model.AssignToRoleId != null && model.AssignToRoleId != "")
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    if (model.AssignToUserId != null && model.AssignToUserId != "")
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);
                }
                else if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_CheckingTheCorrectionsMade)
                {
                    TaskCreateModel taskModel = new()
                    {
                        StepType = Shared.ProcessStepType.DeductData_DecisionAfterAMeetingOfTheEPК,
                        ProcessId = model.Id!.Value,
                        TimelineId = processStepId,
                        EntitySystemIdentifier = new Guid(entitySys),
                        AssignedToUserId = reportCreator.ToString(),
                        EntityType = model.EntityType,
                    };

                    await _taskService.CreateAsync(taskModel);

                    await _context.SaveAsync("");

                    ProcessStepModel processStep = new()
                    {
                        ProcessId = model.Id!.Value,
                        StepTypeId = (int)Shared.ProcessStepType.DeductData_ImplementationOfRecommendationsFromEPК,
                        EndDate = model.EndDate,
                    };
                    var comment = _context.Comments
                        .Where(d => d.CreatedBy == _userInfo.CurrentUserId
                        && d.ProcessId == model.Id!.Value
                        && !d.Deleted
                        && d.IsDraft == true
                        && d.ProcessStepId == (int)Shared.ProcessStepType.DeductData_CheckingTheCorrectionsMade)
                        .FirstOrDefault();

                    if (model.AssignToRoleId != null && model.AssignToRoleId != "")
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    if (model.AssignToUserId != null && model.AssignToUserId != "")
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    if (comment != null)
                    {
                        comment.IsDraft = false;

                        _context.Update(comment);
                        await _context.SaveAsync("");

                        processStep.Comment = comment.Text;
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);
                }
                else if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_ApprovalByDirector)
                {
                    TaskCreateModel taskModel = new()
                    {
                        StepType = Shared.ProcessStepType.DeductData_CheckingTheCorrectionsMade,
                        ProcessId = model.Id!.Value,
                        TimelineId = processStepId,
                        EntitySystemIdentifier = new Guid(entitySys),
                        AssignedToUserId = model.AssignToUserId,
                        AssignedToRoleId = model.AssignToRoleId,
                        EntityType = model.EntityType,
                    };

                    await _taskService.CreateAsync(taskModel);

                    await _context.SaveAsync("");

                    ProcessStepModel processStep = new()
                    {
                        ProcessId = model.Id!.Value,
                        StepTypeId = (int)Shared.ProcessStepType.DeductData_AgreeToRequestCorrections,
                        EndDate = model.EndDate,
                    };

                    if (model.AssignToRoleId != null && model.AssignToRoleId != "")
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    if (model.AssignToUserId != null && model.AssignToUserId != "")
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    var comment = _context.Comments
                        .Where(c => c.CreatedBy == _userInfo.CurrentUserId
                        && c.IsDraft == true
                        && !c.Deleted && c.ProcessId == model.Id!.Value && c.ProcessStepId == (int)Shared.ProcessStepType.DeductData_ApprovalByDirector)
                        .FirstOrDefault();

                    if (comment != null)
                    {
                        comment.IsDraft = false;

                        _context.Update(comment);
                        await _context.SaveAsync("");

                        processStep.Comment = comment.Text;
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);

                }
                else if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_AgreeToRequestCorrections)
                {
                    TaskCreateModel taskModel = new()
                    {
                        StepType = Shared.ProcessStepType.DeductData_CheckingTheCorrectionsMade,
                        ProcessId = model.Id!.Value,
                        TimelineId = processStepId,
                        EntitySystemIdentifier = new Guid(entitySys),
                        AssignedToUserId = reportCreator.ToString(),
                        EntityType = model.EntityType,
                    };

                    await _taskService.CreateAsync(taskModel);

                    await _context.SaveAsync("");

                    ProcessStepModel processStep = new()
                    {
                        ProcessId = model.Id!.Value,
                        StepTypeId = (int)Shared.ProcessStepType.DeductData_ImplementationOfRecommendationsFromEPК,
                        EndDate = model.EndDate,
                    };

                    if (model.AssignToRoleId != null && model.AssignToRoleId != "")
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    if (model.AssignToUserId != null && model.AssignToUserId != "")
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    var comment = _context.Comments
                         .Where(c => c.CreatedBy == _userInfo.CurrentUserId
                         && !c.Deleted
                         && c.IsDraft == true
                         && c.ProcessId == model.Id!.Value
                         && c.ProcessStepId == (int)Shared.ProcessStepType.DeductData_AgreeToRequestCorrections).FirstOrDefault();

                    if (comment != null)
                    {
                        comment.IsDraft = false;

                        _context.Update(comment);
                        await _context.SaveAsync("");

                        processStep.Comment = comment.Text;
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);

                }
                else if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_SettingADateForConsiderationOfAnEPKReport)
                {
                    TaskCreateModel taskModel = new()
                    {
                        StepType = Shared.ProcessStepType.DeductData_DecisionAfterAMeetingOfTheEPК,
                        ProcessId = model.Id!.Value,
                        TimelineId = processStepId,
                        EntitySystemIdentifier = new Guid(entitySys),
                        AssignedToUserId = reportCreator.ToString(),
                        EntityType = model.EntityType,
                    };

                    await _taskService.CreateAsync(taskModel);

                    await _context.SaveAsync("");

                    var comment = _context.Comments
                      .Where(d => d.CreatedBy == _userInfo.CurrentUserId
                      && d.ProcessId == model.Id!.Value
                      && !d.Deleted
                      && d.IsDraft == true
                      && d.ProcessStepId == (int)Shared.ProcessStepType.DeductData_SettingADateForConsiderationOfAnEPKReport)
                      .FirstOrDefault();



                    ProcessStepModel processStep = new()
                    {
                        ProcessId = model.Id!.Value,
                        StepTypeId = (int)Shared.ProcessStepType.DeductData_EditReport,
                        EndDate = model.EndDate,
                        Comment = _context.SessionDecisions.Where(d => d.SessionAgendaId == agendaId).Select(d => d.DecisionText).FirstOrDefault(),
                    };

                    if (model.AssignToRoleId != null && model.AssignToRoleId != "")
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    if (model.AssignToUserId != null && model.AssignToUserId != "")
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    if (comment != null)
                    {
                        comment.IsDraft = false;

                        _context.Update(comment);
                        await _context.SaveAsync("");

                        processStep.Comment = comment.Text;
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);
                }
                await transaction.CommitAsync();

                return OperationResult.Succeed(model);
            }
            catch (Exception exc)
            {
                await transaction.RollbackAsync();
                return OperationResult.Failed(exc.ToString());
            }
        }
        public async Task<OperationResult> UpdateStep(DeductionViewModel model)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var processStepAsign =
                 await _context.ProcessTimelines
                 .Where(step => step.ProcessId == model.Id && !step.Completed)
                 .Select(step => step.AssignedToUserId)
                 .SingleOrDefaultAsync();

                if (processStepAsign != null && processStepAsign != _userInfo.CurrentUserId)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_NoPermission").ToString());
                }

                var processStepId =
                   await _context.ProcessTimelines
                   .Where(step => step.ProcessId == model.Id && !step.Completed)
                   .Select(step => step.Id)
                   .SingleOrDefaultAsync();

                var currDate = DateTime.UtcNow;

                string entitySys = String.Empty;

                if (model.DocumentSystemIdentifier != null)
                {
                    entitySys = model.DocumentSystemIdentifier;
                }
                else if (model.ArchivalEntitySystemIdentifier != null)
                {
                    entitySys = model.ArchivalEntitySystemIdentifier;
                }
                else if (model.InventorySystemIdentifier != null)
                {
                    entitySys = model.InventorySystemIdentifier;
                }
                else if (model.FundSystemIdentifier != null)
                {
                    entitySys = model.FundSystemIdentifier;
                }

                var tasks = _context.Tasks
                    .Where(x => x.ProcessId == model.Id && x.StatusCode != Shared.TaskStatus.Completed)
                    .AsQueryable();

                if (tasks != null && tasks.Count() > 0)
                {
                    OperationResult taskResult = OperationResult.Success;
                    foreach (var task in tasks)
                    {
                        taskResult = await _taskService.ChangeTaskStatus(task.Id, Shared.TaskStatus.Completed);
                        if (!taskResult.Succeeded)
                        {
                            return taskResult;
                        }
                    }
                }

                if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_InitiationOfProcessAndPreparationEPKReport)
                {
                    var currentEpkReport = _context.Epkreports.Where(r => r.ProcessId == model.Id).FirstOrDefault();

                    if (currentEpkReport == null)
                    {
                        var result = await _epkService.CreateAsync(model.EpkReportModel!);

                        if (!result.Succeeded)
                        {
                            return OperationResult.Failed($"Error creating EPK report process{model.Id}");
                        }
                    }

                    TaskCreateModel taskModel = new()
                    {
                        StepType = Shared.ProcessStepType.DeductData_InitiationOfProcessAndPreparationEPKReport,
                        ProcessId = model.Id!.Value,
                        TimelineId = processStepId,
                        EntitySystemIdentifier = new Guid(entitySys),
                        AssignedToUserId = model.AssignToUserId,
                        AssignedToRoleId = model.AssignToRoleId,
                        EntityType = model.EntityType,
                    };

                    await _taskService.CreateAsync(taskModel);
                    await _context.SaveChangesAsync();

                    ProcessStepModel processStep = new()
                    {
                        ProcessId = model.Id!.Value,
                        StepTypeId = (int)Shared.ProcessStepType.DeductData_SettingADateForConsiderationOfAnEPKReport,
                        EndDate = model.EndDate,
                    };

                    if (model.AssignToRoleId != null && model.AssignToRoleId != "")
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    if (model.AssignToUserId != null && model.AssignToUserId != "")
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);
                }

                else if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_EditReport)
                {
                    var currentEpkReport = _context.Epkreports.Where(r => r.ProcessId == model.Id).FirstOrDefault();

                    if (currentEpkReport == null)
                    {
                        var result = await _epkService.CreateAsync(model.EpkReportModel!);

                        if (!result.Succeeded)
                        {
                            return OperationResult.Failed($"Error creating EPK report process{model.Id}");
                        }
                    }

                    TaskCreateModel taskModel = new()
                    {
                        StepType = Shared.ProcessStepType.DeductData_InitiationOfProcessAndPreparationEPKReport,
                        ProcessId = model.Id!.Value,
                        TimelineId = processStepId,
                        EntitySystemIdentifier = new Guid(entitySys),
                        AssignedToUserId = model.AssignToUserId,
                        AssignedToRoleId = model.AssignToRoleId,
                        EntityType = model.EntityType,
                    };

                    await _taskService.CreateAsync(taskModel);
                    await _context.SaveChangesAsync();

                    ProcessStepModel processStep = new()
                    {
                        ProcessId = model.Id!.Value,
                        StepTypeId = (int)Shared.ProcessStepType.DeductData_SettingADateForConsiderationOfAnEPKReport,
                        EndDate = model.EndDate,
                    };

                    if (model.AssignToRoleId != null && model.AssignToRoleId != "")
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    if (model.AssignToUserId != null && model.AssignToUserId != "")
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);
                }

                else if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_SettingADateForConsiderationOfAnEPKReport)
                {

                    TaskCreateModel taskModel = new()
                    {
                        StepType = Shared.ProcessStepType.DeductData_SettingADateForConsiderationOfAnEPKReport,
                        ProcessId = model.Id!.Value,
                        TimelineId = processStepId,
                        EntitySystemIdentifier = new Guid(entitySys),
                        AssignedToUserId = model.AssignToUserId,
                        AssignedToRoleId = model.AssignToRoleId,
                        EntityType = model.EntityType,
                    };

                    await _taskService.CreateAsync(taskModel);
                    await _context.SaveAsync("");

                    ProcessStepModel processStep = new()
                    {
                        ProcessId = model.Id!.Value,
                        StepTypeId = (int)Shared.ProcessStepType.DeductData_IntroductionOfAnOpinionByEPKMembers,
                        EndDate = model.EndDate,
                    };

                    if (model.AssignToRoleId != null && model.AssignToRoleId != "")
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    if (model.AssignToUserId != null && model.AssignToUserId != "")
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);
                }

                else if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_IntroductionOfAnOpinionByEPKMembers)
                {

                    var reportCreator = _context.Processes.Where(p => p.Id == model.Id).Select(p => p.CreatedBy).FirstOrDefault();

                    TaskCreateModel taskModel = new()
                    {
                        StepType = Shared.ProcessStepType.DeductData_EnterComments,
                        ProcessId = model.Id!.Value,
                        TimelineId = processStepId,
                        EntitySystemIdentifier = new Guid(entitySys),
                        AssignedToUserId = reportCreator.ToString(),
                        EntityType = model.EntityType,
                    };

                    await _taskService.CreateAsync(taskModel);

                    await _context.SaveAsync("");

                    ProcessStepModel processStep = new()
                    {
                        ProcessId = model.Id!.Value,
                        StepTypeId = (int)Shared.ProcessStepType.DeductData_EnterComments,
                        EndDate = model.EndDate,
                        AssignedToUserId = reportCreator,
                    };
                    var report = _context.Epkreports.Where(r => r.Id == model.EpkReportModel.Id).FirstOrDefault();

                    report!.IsDraft = false;

                    _context.Update(report);

                    await _context.SaveAsync("");
                    await _processService.SetActiveProcessStepAsync(processStep);
                }

                else if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_EnterComments)
                {

                    TaskCreateModel taskModel = new()
                    {
                        StepType = Shared.ProcessStepType.DeductData_EnterComments,
                        ProcessId = model.Id!.Value,
                        TimelineId = processStepId,
                        EntitySystemIdentifier = new Guid(entitySys),
                        AssignedToUserId = model.AssignToUserId,
                        EntityType = model.EntityType ?? "",
                    };

                    await _taskService.CreateAsync(taskModel);

                    await _context.SaveAsync("");

                    ProcessStepModel processStep = new()
                    {
                        ProcessId = model.Id!.Value,
                        StepTypeId = (int)Shared.ProcessStepType.DeductData_ForSession,
                        EndDate = model.EndDate,
                    };

                    if (model.AssignToRoleId != null && model.AssignToRoleId != "")
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    if (model.AssignToUserId != null && model.AssignToUserId != "")
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);
                }

                else if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_ForSession)
                {
                    ProcessStepModel processStep = new()
                    {
                        ProcessId = model.Id!.Value,
                        StepTypeId = (int)Shared.ProcessStepType.DeductData_DecisionAfterAMeetingOfTheEPК,
                        EndDate = model.EndDate,
                    };

                    if (model.AssignToRoleId != null && model.AssignToRoleId != "")
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    if (model.AssignToUserId != null && model.AssignToUserId != "")
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);
                }

                else if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_ConfirmedProtocol)
                {
                    var archiveRoleId = await _context.Archives
                                    .Where(s => s.Id == model.ArchiveId && !s.Deleted)
                                    .Select(s => s.AspNetRoles.Where(role => role.Name == ApplicationRoleType.GroupG).Select(role => role.Id).SingleOrDefault())
                                    .SingleOrDefaultAsync();

                    TaskCreateModel taskModel = new()
                    {
                        StepType = Shared.ProcessStepType.DeductData_DecisionAfterAMeetingOfTheEPК,
                        ProcessId = model.Id!.Value,
                        TimelineId = processStepId,
                        EntitySystemIdentifier = new Guid(entitySys),
                        AssignedToRoleId = archiveRoleId.ToString(),
                        EntityType = model.EntityType,
                    };

                    await _taskService.CreateAsync(taskModel);

                    await _context.SaveAsync("");

                    ProcessStepModel processStep = new()
                    {
                        ProcessId = model.Id!.Value,
                        StepTypeId = (int)Shared.ProcessStepType.DeductData_ApprovalByDirector,
                        EndDate = model.EndDate,
                    };

                    if (model.AssignToRoleId != null && model.AssignToRoleId != "")
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    if (model.AssignToUserId != null && model.AssignToUserId != "")
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);
                }

                else if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_ImplementationOfRecommendationsFromEPК)
                {
                    TaskCreateModel taskModel = new()
                    {
                        StepType = Shared.ProcessStepType.DeductData_ImplementationOfRecommendationsFromEPК,
                        ProcessId = model.Id!.Value,
                        TimelineId = processStepId,
                        EntitySystemIdentifier = new Guid(entitySys),
                        AssignedToUserId = model.AssignToUserId,
                        AssignedToRoleId = model.AssignToRoleId,
                        EntityType = model.EntityType,
                    };

                    await _taskService.CreateAsync(taskModel);

                    await _context.SaveAsync("");


                    ProcessStepModel processStep = new()
                    {
                        ProcessId = model.Id!.Value,
                        StepTypeId = (int)Shared.ProcessStepType.DeductData_CheckingTheCorrectionsMade,
                        EndDate = model.EndDate,
                    };

                    if (model.AssignToRoleId != null && model.AssignToRoleId != "")
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    if (model.AssignToUserId != null && model.AssignToUserId != "")
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);
                }

                else if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_CheckingTheCorrectionsMade)
                {
                    TaskCreateModel taskModel = new()
                    {
                        StepType = Shared.ProcessStepType.DeductData_CheckingTheCorrectionsMade,
                        ProcessId = model.Id!.Value,
                        TimelineId = processStepId,
                        EntitySystemIdentifier = new Guid(entitySys),
                        AssignedToUserId = model.AssignToUserId,
                        AssignedToRoleId = model.AssignToRoleId,
                        EntityType = model.EntityType,
                    };

                    await _taskService.CreateAsync(taskModel);

                    await _context.SaveAsync("");

                    ProcessStepModel processStep = new()
                    {
                        ProcessId = model.Id!.Value,
                        StepTypeId = (int)Shared.ProcessStepType.DeductData_ApprovalByDirector,
                        EndDate = model.EndDate,
                    };

                    if (model.AssignToRoleId != null && model.AssignToRoleId != "")
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    if (model.AssignToUserId != null && model.AssignToUserId != "")
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);
                }

                else if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_ApprovalByDirector)
                {
                    await RemoveExistingDraft(model, false);

                    var result = await DeductionAllNestedData(model);

                    if (!result.Succeeded)
                    {
                        return OperationResult.Failed();
                    }
                    else
                    {
                        ProcessStepModel processStep = new()
                        {
                            ProcessId = model.Id!.Value,
                            StepTypeId = (int)Shared.ProcessStepType.DeductData_ProcessFinalization,
                        };

                        await _processService.SetActiveProcessStepAsync(processStep);

                        await _processService.CompleteProcessAsync(model.Id!.Value);
                    }
                }

                else if (model.ProcedureStepId == (int)Shared.ProcessStepType.DeductData_AgreeToRequestCorrections)
                {

                    TaskCreateModel taskModel = new()
                    {
                        StepType = Shared.ProcessStepType.DeductData_CheckingTheCorrectionsMade,
                        ProcessId = model.Id!.Value,
                        TimelineId = processStepId,
                        EntitySystemIdentifier = new Guid(entitySys),
                        AssignedToUserId = model.AssignToUserId,
                        AssignedToRoleId = model.AssignToRoleId,
                        EntityType = model.EntityType,
                    };

                    await _taskService.CreateAsync(taskModel);

                    await _context.SaveAsync("");

                    ProcessStepModel processStep = new()
                    {
                        ProcessId = model.Id!.Value,
                        StepTypeId = (int)Shared.ProcessStepType.DeductData_ApprovalByDirector,
                        EndDate = model.EndDate,
                    };

                    if (model.AssignToRoleId != null && model.AssignToRoleId != "")
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    if (model.AssignToUserId != null && model.AssignToUserId != "")
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);
                }

                await transaction.CommitAsync();

                return OperationResult.Succeed(model);
            }
            catch (Exception exc)
            {
                await transaction.RollbackAsync();

                return OperationResult.Failed(exc.ToString());
            }
        }
        private Task<CheckWhereIsRecordModel> CheckForExistingRecord(DeductionCreateModel model)
        {
            CheckWhereIsRecordModel returnInfo = new();

            if (model.FundExternalIdentifier.HasValue || model.FundSystemIdentifier != null)
            {
                var r1 = _context.Funds.Where(f => f.ExternalIdentifier == model.FundExternalIdentifier).FirstOrDefault();

                var r2 = _context.Funds.Where(f => f.SystemIdentifier.ToString() == model.FundSystemIdentifier && f.ExternalIdentifier == null).FirstOrDefault();

                if (r1 == null)
                {
                    returnInfo.NotExistInOurSystem = true;
                    returnInfo.IsInBothOfSystems = false;
                    returnInfo.IsOnlyInOurSystem = false;
                }
                else if (r2 != null)
                {
                    returnInfo.IsOnlyInOurSystem = true;
                    returnInfo.IsInBothOfSystems = false;
                    returnInfo.NotExistInOurSystem = false;
                }
                else
                {
                    returnInfo.IsOnlyInOurSystem = false;
                    returnInfo.IsInBothOfSystems = true;
                    returnInfo.NotExistInOurSystem = false;
                }

            }
            else if (model.InventoryExternalIdentifier.HasValue || model.InventorySystemIdentifier != null)
            {
                var r1 = _context.Inventories.Where(f => f.ExternalIdentifier == model.InventoryExternalIdentifier).FirstOrDefault();

                var r2 = _context.Inventories.Where(f => f.SystemIdentifier.ToString() == model.InventorySystemIdentifier && f.ExternalIdentifier == null).FirstOrDefault();

                if (r1 == null)
                {
                    returnInfo.NotExistInOurSystem = true;
                    returnInfo.IsInBothOfSystems = false;
                    returnInfo.IsOnlyInOurSystem = false;
                }
                else if (r2 != null)
                {
                    returnInfo.IsOnlyInOurSystem = true;
                    returnInfo.IsInBothOfSystems = false;
                    returnInfo.NotExistInOurSystem = false;
                }
                else
                {
                    returnInfo.IsOnlyInOurSystem = false;
                    returnInfo.IsInBothOfSystems = true;
                    returnInfo.NotExistInOurSystem = false;
                }
            }
            else if (model.ArchivalEntityExternalIdentifier.HasValue || model.ArchivalEntitySystemIdentifier != null)
            {
                var r1 = _context.ArchivalEntities.Where(f => f.ExternalIdentifier == model.ArchivalEntityExternalIdentifier).FirstOrDefault();

                var r2 = _context.ArchivalEntities.Where(f => f.SystemIdentifier.ToString() == model.ArchivalEntitySystemIdentifier && f.ExternalIdentifier == null).FirstOrDefault();

                if (r1 == null)
                {
                    returnInfo.NotExistInOurSystem = true;
                    returnInfo.IsInBothOfSystems = false;
                    returnInfo.IsOnlyInOurSystem = false;
                }
                else if (r2 != null)
                {
                    returnInfo.IsOnlyInOurSystem = true;
                    returnInfo.IsInBothOfSystems = false;
                    returnInfo.NotExistInOurSystem = false;
                }
                else
                {
                    returnInfo.IsOnlyInOurSystem = false;
                    returnInfo.IsInBothOfSystems = true;
                    returnInfo.NotExistInOurSystem = false;
                }

            }
            else if (model.DocumentEntityExternalIdentifier.HasValue || model.DocumentSystemIdentifier != null)
            {
                var r1 = _context.Documents.Where(f => f.ExternalIdentifier == model.DocumentEntityExternalIdentifier).FirstOrDefault();

                var r2 = _context.Documents.Where(f => f.SystemIdentifier.ToString() == model.DocumentSystemIdentifier && f.ExternalIdentifier == null).FirstOrDefault();

                if (r1 == null)
                {
                    returnInfo.NotExistInOurSystem = true;
                    returnInfo.IsInBothOfSystems = false;
                    returnInfo.IsOnlyInOurSystem = false;
                }
                else if (r2 != null)
                {
                    returnInfo.IsOnlyInOurSystem = true;
                    returnInfo.IsInBothOfSystems = false;
                    returnInfo.NotExistInOurSystem = false;
                }
                else
                {
                    returnInfo.IsOnlyInOurSystem = false;
                    returnInfo.IsInBothOfSystems = true;
                    returnInfo.NotExistInOurSystem = false;
                }
            }

            return Task.FromResult(returnInfo);
        }
        private async Task<OperationResult> StartProcess(DeductionCreateModel model)
        {
            int ProcessType = (int)Shared.ProcessType.DeductData;

            if (model.FundSystemIdentifier != null || model.FundExternalIdentifier != null)
            {
                if (model.FundExternalIdentifier != null)
                {
                    model.FundSystemIdentifier = _context.Funds.Where(f => f.ExternalIdentifier == model.FundExternalIdentifier).Select(f => f.SystemIdentifier).FirstOrDefault().ToString();
                }
                if (model.FundSystemIdentifier != null)
                {
                    var result = await _processService.StartProcessAsync(new Models.Processes.ProcessModel
                    {
                        FundSystemIdentifier = new Guid(model.FundSystemIdentifier),
                        Completed = false,
                        ArchiveId = model.ArchiveId.Value,
                        ProcessTypeId = ProcessType,
                    });

                    if (result.Data == null)
                    {
                        return OperationResult.Failed(false, result.Errors.First());
                    }
                    else
                    {
                        await _processService.SetActiveProcessStepAsync((int)result.Data, (int)Shared.ProcessStepType.DeductData_InitiationOfProcessAndPreparationEPKReport);
                    }
                }
            }
            else if (model.InventorySystemIdentifier != null || model.InventoryExternalIdentifier != null)
            {
                if (model.InventoryExternalIdentifier != null)
                {
                    model.InventorySystemIdentifier = _context.Inventories.Where(i => i.ExternalIdentifier == model.InventoryExternalIdentifier).Select(i => i.SystemIdentifier).FirstOrDefault().ToString();
                }
                if (model.InventorySystemIdentifier != null)
                {
                    var result = await _processService.StartProcessAsync(new Models.Processes.ProcessModel
                    {
                        InventorySystemIdentifier = new Guid(model.InventorySystemIdentifier),
                        Completed = false,
                        ArchiveId = model.ArchiveId.Value,
                        ProcessTypeId = ProcessType,
                    });

                    if (result.Data == null)
                    {
                        return OperationResult.Failed(false, result.Errors.First());
                    }
                    else
                    {
                        await _processService.SetActiveProcessStepAsync((int)result.Data, (int)Shared.ProcessStepType.DeductData_InitiationOfProcessAndPreparationEPKReport);
                    }
                }
            }
            else if (model.ArchivalEntitySystemIdentifier != null || model.ArchivalEntityExternalIdentifier != null)
            {
                if (model.ArchivalEntityExternalIdentifier != null)
                {
                    model.ArchivalEntitySystemIdentifier =
                        _context.ArchivalEntities
                        .Where(a => a.ExternalIdentifier == model.ArchivalEntityExternalIdentifier)
                        .Select(a => a.SystemIdentifier)
                        .FirstOrDefault()
                        .ToString();
                }
                if (model.ArchivalEntitySystemIdentifier != null)
                {
                    var result = await _processService.StartProcessAsync(new Models.Processes.ProcessModel
                    {
                        ArchivalEntitySystemIdentifier = new Guid(model.ArchivalEntitySystemIdentifier),
                        Completed = false,
                        ArchiveId = model.ArchiveId.Value,
                        ProcessTypeId = ProcessType,
                    });

                    if (result.Data == null)
                    {
                        return OperationResult.Failed(false, result.Errors.First());
                    }
                    else
                    {
                        await _processService.SetActiveProcessStepAsync((int)result.Data, (int)Shared.ProcessStepType.DeductData_InitiationOfProcessAndPreparationEPKReport);
                    }
                }
            }
            else if (model.DocumentSystemIdentifier != null || model.DocumentEntityExternalIdentifier != null)
            {
                if (model.DocumentEntityExternalIdentifier != null)
                {
                    model.DocumentSystemIdentifier = _context.Documents
                          .Where(d => d.ExternalIdentifier == model.DocumentEntityExternalIdentifier)
                          .Select(d => d.SystemIdentifier)
                          .FirstOrDefault()
                          .ToString();
                }
                if (model.DocumentSystemIdentifier != null)
                {
                    var result = await _processService.StartProcessAsync(new Models.Processes.ProcessModel
                    {
                        DocumentSystemIdentifier = new Guid(model.DocumentSystemIdentifier),
                        Completed = false,
                        ArchiveId = model.ArchiveId.Value,
                        ProcessTypeId = ProcessType,
                    });

                    if (result.Data == null)
                    {
                        return OperationResult.Failed(false, result.Errors.First());
                    }
                    else
                    {
                        await _processService.SetActiveProcessStepAsync((int)result.Data, (int)Shared.ProcessStepType.DeductData_InitiationOfProcessAndPreparationEPKReport);
                    }
                }
            }

            return OperationResult.Success;
        }
        public async Task<OperationResult> ТerminateProcess(DeductionViewModel model, bool undoChanges)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var processStepAsign = await _context.ProcessTimelines
                      .Where(step => step.ProcessId == model.Id && !step.Completed)
                      .Select(step => step.AssignedToUserId)
                      .SingleOrDefaultAsync();


                var processStepId =
                 await _context.ProcessTimelines
                 .Where(step => step.ProcessId == model.Id && !step.Completed)
                 .Select(step => step.Id)
                 .SingleOrDefaultAsync();

                var tasks = _context.Tasks
                    .Where(x => x.ProcessId == model.Id && x.StepId == processStepId - 1 && x.StatusCode == Shared.TaskStatus.Pending)
                    .AsQueryable();
                if (tasks != null && tasks.Count() > 0)
                {
                    OperationResult taskResult = OperationResult.Success;
                    foreach (var task in tasks)
                    {
                        taskResult = await _taskService.ChangeTaskStatus(task.Id, Shared.TaskStatus.Completed);
                        if (!taskResult.Succeeded)
                        {
                            return taskResult;
                        }
                    }
                }

                if (processStepAsign != null && processStepAsign != _userInfo.CurrentUserId)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_NoPermission").ToString());
                }

                await RemoveExistingDraft(model, undoChanges);

                ProcessStepModel processStep = new()
                {
                    ProcessId = model.Id!.Value,
                    StepTypeId = (int)Shared.ProcessStepType.DeductData_ProcessFinalization,
                };

                await _processService.SetActiveProcessStepAsync(processStep);

                await _processService.CompleteProcessAsync(model.Id.Value);

                await transaction.CommitAsync();

                return OperationResult.Succeed(model);
            }
            catch (Exception exc)
            {
                await transaction.RollbackAsync();

                return OperationResult.Failed(false, exc.ToString());
            }
        }
        private async Task<OperationResult> DeductionAllNestedData(DeductionViewModel model)
        {
            try
            {
                if (model.FundSystemIdentifier != null)
                {
                    var fund = _context.Funds
                      .Where(d => d.SystemIdentifier.ToString() == model.FundSystemIdentifier)
                      .FirstOrDefault();

                    if (fund != null)
                    {
                        fund!.StatusCode = Shared.Status.Deducted;

                        _context.Funds.Update(fund);

                        await _context.SaveAsync($"Fund status changed fund id{fund.Id}");

                        await DeductionAllInventories(fund.SystemIdentifier);
                    }
                }
                else if (model.InventorySystemIdentifier != null)
                {
                    var inventory = _context.Inventories
                      .Where(d => d.SystemIdentifier.ToString() == model.InventorySystemIdentifier)
                      .FirstOrDefault();

                    if (inventory != null)
                    {
                        inventory!.StatusCode = Shared.Status.Deducted;
                        inventory.AvailabilityStatusCode = (int)Shared.AvailabilityStatus.DisposalDeduction;

                        _context.Inventories.Update(inventory);

                        await _context.SaveAsync($"Inventory status changed Inventory id{inventory.Id}");

                        await DeductionAllArchEntities(inventory.SystemIdentifier);
                    }

                }
                else if (model.ArchivalEntitySystemIdentifier != null)
                {
                    var archEntity = _context.ArchivalEntities
                     .Where(a => a.SystemIdentifier.ToString() == model.ArchivalEntitySystemIdentifier)
                     .FirstOrDefault();

                    if (archEntity != null)
                    {
                        archEntity!.StatusCode = Shared.Status.Deducted;
                        archEntity.AvailabilityStatusCode = (int)Shared.AvailabilityStatus.DisposalDeduction;

                        _context.ArchivalEntities.Update(archEntity);

                        await _context.SaveAsync($"ArchivalEntity status changed ArchivalEntity id{archEntity.Id}");

                        await DeductionAllDocuments(archEntity.SystemIdentifier);
                    }
                }
                else if (model.DocumentSystemIdentifier != null)
                {
                    var documment = await _context.Documents
                        .Where(d => d.SystemIdentifier.ToString() == model.DocumentSystemIdentifier)
                        .FirstOrDefaultAsync();

                    documment!.StatusCode = Shared.Status.Deducted;
                    documment!.AvailabilityStatusCode = (int)Shared.AvailabilityStatus.DisposalDeduction;

                    _context.Documents.Update(documment);

                    await _context.SaveAsync($"Documment status changed Documment id{documment.Id}");

                    await DeductionAllDigitalObjts(documment.SystemIdentifier);
                }

                return OperationResult.Succeed(model);
            }
            catch (Exception ex)
            {
                return OperationResult.Failed(ex.ToString());
            }
        }
        private async Task<OperationResult> DeductionAllInventories(Guid fundSys)
        {
            var allInventories = _context.Inventories
                .Where(i => i.FundSystemIdentifier == fundSys);

            foreach (var inv in allInventories)
            {
                inv.StatusCode = Shared.Status.Deducted;
                inv.AvailabilityStatusCode = (int)Shared.AvailabilityStatus.DisposalDeduction;

                _context.Inventories.Update(inv);
                await _context.SaveAsync($"Inventory status changed Inventory id{inv.Id}");

                await DeductionAllArchEntities(inv.SystemIdentifier);
            }

            return OperationResult.Succeed(allInventories);
        }
        private async Task<OperationResult> DeductionAllArchEntities(Guid inventorySys)
        {
            var allArchEntities = _context.ArchivalEntities
                .Where(a => a.InventorySystemIdentifier == inventorySys);

            foreach (var archEn in allArchEntities)
            {
                archEn.StatusCode = Shared.Status.Deducted;
                archEn.AvailabilityStatusCode = (int)Shared.AvailabilityStatus.DisposalDeduction;

                _context.ArchivalEntities.Update(archEn);
                await _context.SaveAsync($"ArchivalEntity status changed ArchivalEntity id{archEn.Id}");

                await DeductionAllDocuments(archEn.SystemIdentifier);
            }

            return OperationResult.Succeed(allArchEntities);
        }
        private async Task<OperationResult> DeductionAllDocuments(Guid archEntSys)
        {
            var allDocuments = _context.Documents
                .Where(i => i.ArchivalEntitySystemIdentifier == archEntSys);

            foreach (var docs in allDocuments)
            {
                docs.StatusCode = Shared.Status.Deducted;
                docs.AvailabilityStatusCode = (int)Shared.AvailabilityStatus.DisposalDeduction;

                _context.Documents.Update(docs);
                await _context.SaveAsync($"Document status changed Document id{docs.Id}");

                await DeductionAllDigitalObjts(docs.SystemIdentifier);
            }

            return OperationResult.Succeed(allDocuments);
        }
        private async Task<OperationResult> DeductionAllDigitalObjts(Guid docSys)
        {
            var allDigitalObjects = _context.DigitalObjects
                .Where(i => i.DocumentSystemIdentifier == docSys);

            foreach (var digitObj in allDigitalObjects)
            {
                digitObj.StatusCode = Shared.Status.Deducted;
                digitObj.AvailabilityStatusCode = (int)Shared.AvailabilityStatus.DisposalDeduction;

                _context.DigitalObjects.Update(digitObj);
                await _context.SaveAsync($"DigitalObject status changed DigitalObject id{digitObj.Id}");
            }

            return OperationResult.Succeed(allDigitalObjects);
        }
        private async Task<OperationResult> CreateDraftFromEntity(DeductionCreateModel model)
        {
            if (model.FundSystemIdentifier != null)
            {
                var fund = await _fundService.GetFundBySystemIdentifierAsync(new Guid(model.FundSystemIdentifier));

                if (fund == null)
                {
                    _logger.LogError($"Fund with sysId {model.FundSystemIdentifier} does not exists");
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                FundDraftModel draft = new()
                {
                    AcquisitionMethodId = fund.AcquisitionMethodId,
                    //AcquisitionMethodCodes = fund.AcquisitionMethodCodes,
                    ApproxmateChronologicalScope = fund.ApproxmateChronologicalScope,
                    ArchivalEntityCount = fund.ArchivalEntityCount,
                    ArchiveId = fund.ArchiveId,
                    Bytes = fund.Bytes,
                    DeductedBytes = fund.DeductedBytes,
                    DeductedInventoryCount = fund.DeductedInventoryCount,
                    DescriptionLevelCode = fund.DescriptionLevelCode,
                    DocumentCount = fund.DocumentCount,
                    DocumentsAccessDescription = fund.DocumentsAccessDescription,
                    DocumentsDescription = fund.DocumentsDescription,
                    DocumentsProvider = fund.DocumentsProvider,
                    EndDateDay = fund.EndDateDay,
                    EndDateMonth = fund.EndDateMonth,
                    EndDateYear = fund.EndDateYear,
                    EnrolledBytes = fund.EnrolledBytes,
                    EnrolledInventoryCount = fund.EnrolledInventoryCount,
                    ExternalIdentifier = fund.ExternalIdentifier,
                    FileTypeCodes = fund.FileTypeCodes,
                    FundCreatorActivityHistory = fund.FundCreatorActivityHistory,
                    FundCreatorBiographicalHistory = fund.FundCreatorBiographicalHistory,
                    FundCreatorTitleHistory = fund.FundCreatorTitleHistory,
                    HasExternalSource = fund.HasExternalSource,
                    HasNoChronologicalScope = fund.HasNoChronologicalScope,
                    History = fund.History,
                    IndustryTypeCodes = fund.IndustryTypeCodes,
                    InvaluableDocumentsInventoryCount = fund.InvaluableDocumentsInventoryCount,
                    InventoryCount = fund.InventoryCount,
                    IsCurrent = true,
                    LanguageCodes = fund.LanguageCodes,
                    LinearMeters = fund.LinearMeters,
                    Notes = fund.Notes,
                    Number = fund.Number,
                    NumberArray = fund.NumberArray,
                    OtherMetrics = fund.OtherMetrics,
                    RelatedFunds = fund.RelatedFunds,
                    StartDateDay = fund.StartDateDay,
                    ValuableDocumentsInventoryCount = fund.ValuableDocumentsInventoryCount,
                    Title = fund.Title,
                    StartDateMonth = fund.StartDateMonth,
                    StartDateYear = fund.StartDateYear,
                    TypeCode = fund.TypeCode,
                    SystemIdentifier = fund.SystemIdentifier,
                    ReadOnly = false,
                    StatusCode = fund.StatusCode,

                };
                if (draft.HasExternalSource == true)
                {

                }

                var result = await _fundService.CreateDraftInternalAsync(draft);

                return OperationResult.Succeed(result);
            }
            else if (model.InventorySystemIdentifier != null)
            {
                var inventory = await _inventoryService.GetInventoryBySystemIdentifierAsync(new Guid(model.InventorySystemIdentifier));

                if (inventory == null)
                {
                    _logger.LogError($"Inventory with sysId {model.InventorySystemIdentifier} does not exists");
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                InventoryDraftCreateModel draft = new()
                {
                    AbbreviationList = inventory.AbbreviationList,
                    AcquisitionMethodId = inventory.AcquisitionMethodId,
                    ApplicationId = inventory.ApplicationId,
                    ApproxmateChronologicalScope = inventory.ApproxmateChronologicalScope,
                    ArchivalEntityCount = inventory.ArchivalEntityCount,
                    ArchiveId = inventory.ArchiveId,
                    AudioDocumentArchivalEntityCount = inventory.AudioDocumentArchivalEntityCount,
                    BoxCount = inventory.BoxCount,
                    Bytes = inventory.Bytes,
                    ClassificationScheme = inventory.ClassificationScheme,
                    CreationMethodCodes = inventory.CreationMethodCodes,
                    DescriptionLevelCode = inventory.DescriptionLevelCode,
                    DigitalDocumentArchivalEntityCount = inventory.DigitalDocumentArchivalEntityCount,
                    DigitizedArchivalEntityCount = inventory.DigitizedArchivalEntityCount,
                    DocumentCount = inventory.DocumentCount,
                    DocumentsAccessDescription = inventory.DocumentsAccessDescription,
                    DocumentsDescription = inventory.DocumentsDescription,
                    DocumentsProvider = inventory.DocumentsProvider,
                    IsCurrent = true,
                    ReadOnly = false,
                    EndDateDay = inventory.EndDateDay,
                    EndDateMonth = inventory.EndDateMonth,
                    EndDateYear = inventory.EndDateYear,
                    ExternalIdentifier = inventory.ExternalIdentifier,
                    FileTypeCodes = inventory.FileTypeCodes,
                    FundCreatorBiographicalHistory = inventory.FundCreatorBiographicalHistory,
                    FundCreatorTitleHistory = inventory.FundCreatorTitleHistory,
                    FundDraftId = inventory.FundDraftId,
                    FundExternalIdentifier = inventory.FundExternalIdentifier,
                    FundHasExternalSource = inventory.FundHasExternalSource,
                    FundSystemIdentifier = inventory.FundSystemIdentifier,
                    HasExternalSource = inventory.HasExternalSource,
                    HasNoChronologicalScope = inventory.HasNoChronologicalScope,
                    History = inventory.History,
                    LanguageCodes = inventory.LanguageCodes,
                    LinearMeters = inventory.LinearMeters,
                    MicrofilmedArchivalEntityCount = inventory.MicrofilmedArchivalEntityCount,
                    NegativeFrameCount = inventory.NegativeFrameCount,
                    Notes = inventory.Notes,
                    Number = inventory.Number,
                    NumberArray = inventory.NumberArray,
                    OriginalityCodes = inventory.OriginalityCodes,
                    OtherMetrics = inventory.OtherMetrics,
                    PhotoDocumentArchivalEntityCount = inventory.PhotoDocumentArchivalEntityCount,
                    PositiveFrameCount = inventory.PositiveFrameCount,
                    RollCount = inventory.RollCount,
                    StartDateDay = inventory.StartDateDay,
                    StartDateMonth = inventory.StartDateMonth,
                    StartDateYear = inventory.StartDateYear,
                    StatusCode = inventory.StatusCode,
                    SystemIdentifier = inventory.SystemIdentifier,
                    VideoDocumentArchivalEntityCount = inventory.VideoDocumentArchivalEntityCount,
                    AvailabilityStatusCode = (int)Shared.AvailabilityStatus.DisposalDeduction,
                };

                if (draft.HasExternalSource == true)
                {
                    var res = _context.InventoryArrays.Where(ar => ar.ExternalSourceCode == draft.NumberArray).Select(ar => ar.Code).FirstOrDefault();
                    if (res != null)
                    {
                        draft.NumberArray = res;
                    }
                }
                var result = await _inventoryService.CreateDraftInternalAsync(draft);

                return OperationResult.Succeed(result);
            }
            else if (model.ArchivalEntitySystemIdentifier != null)
            {
                var archivalEntity = await _archivalEntityService.GetArchivalEntityBySystemIdentifierAsync(new Guid(model.ArchivalEntitySystemIdentifier));

                if (archivalEntity == null)
                {
                    _logger.LogError($"Archival entity with sysId {model.ArchivalEntitySystemIdentifier} does not exists");
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                ArchivalEntityDraftModel draft = new()
                {
                    ArchiveId = archivalEntity.ArchiveId,
                    Bytes = archivalEntity.Bytes,
                    CreationMethodCodes = archivalEntity.CreationMethodCodes,
                    DescriptionLevelCode = archivalEntity.DescriptionLevelCode,
                    DocumentsAccessDescription = archivalEntity.DocumentsAccessDescription,
                    IsCurrent = true,
                    ReadOnly = false,
                    EndDateDay = archivalEntity.EndDateDay,
                    EndDateMonth = archivalEntity.EndDateMonth,
                    EndDateYear = archivalEntity.EndDateYear,
                    ExternalIdentifier = archivalEntity.ExternalIdentifier,
                    FundDraftId = archivalEntity.FundDraftId,
                    FundExternalIdentifier = archivalEntity.FundExternalIdentifier,
                    FundHasExternalSource = archivalEntity.FundHasExternalSource,
                    FundSystemIdentifier = archivalEntity.FundSystemIdentifier,
                    HasExternalSource = archivalEntity.HasExternalSource,
                    HasNoChronologicalScope = archivalEntity.HasNoChronologicalScope,
                    LanguageCodes = archivalEntity.LanguageCodes,
                    NegativeFrameCount = archivalEntity.NegativeFrameCount,
                    Notes = archivalEntity.Notes,
                    Number = archivalEntity.Number,
                    OriginalityCodes = archivalEntity.OriginalityCodes,
                    OtherMetrics = archivalEntity.OtherMetrics,
                    PositiveFrameCount = archivalEntity.PositiveFrameCount,
                    StartDateDay = archivalEntity.StartDateDay,
                    StartDateMonth = archivalEntity.StartDateMonth,
                    StartDateYear = archivalEntity.StartDateYear,
                    StatusCode = archivalEntity.StatusCode,
                    SystemIdentifier = archivalEntity.SystemIdentifier,
                    ApproximateChronologicalScope = archivalEntity.ApproximateChronologicalScope,
                    Author = archivalEntity.Author,
                    Condition = archivalEntity.Condition,
                    DeductedBytes = archivalEntity.DeductedBytes,
                    DeductedDocumentCount = archivalEntity.DeductedDocumentCount,
                    DeductedLinearMeters = archivalEntity.DeductedLinearMeters,
                    Description = archivalEntity.Description,
                    DigitalDeviceCount = archivalEntity.DigitalDeviceCount,
                    DigitizedCopyCount = archivalEntity.DigitizedCopyCount,
                    EnrolledBytes = archivalEntity.EnrolledBytes,
                    EnrolledDocumentCount = archivalEntity.EnrolledDocumentCount,
                    EnrolledLinearMeters = archivalEntity.EnrolledLinearMeters,
                    Features = archivalEntity.Features,
                    FrameCount = archivalEntity.FrameCount,
                    InventoryDraftId = archivalEntity.InventoryDraftId,
                    InventoryExternalIdentifier = archivalEntity.InventoryExternalIdentifier,
                    InventoryHasExternalSource = archivalEntity.InventoryHasExternalSource,
                    InventorySystemIdentifier = archivalEntity.InventorySystemIdentifier,
                    Location = archivalEntity.Location,
                    MicrofilmCount = archivalEntity.MicrofilmCount,
                    MicrofilmedCopyCount = archivalEntity.MicrofilmedCopyCount,
                    OtherCopyCount = archivalEntity.OtherCopyCount,
                    PaperCopyCount = archivalEntity.PaperCopyCount,
                    Scaling = archivalEntity.Scaling,
                    SheetCount = archivalEntity.SheetCount,
                    SizeCm = archivalEntity.SizeCm,
                    TapeCount = archivalEntity.TapeCount,
                    Title = archivalEntity.Title,
                    VideoTapeCount = archivalEntity.VideoTapeCount,
                    AvailabilityStatusCode = (int)Shared.AvailabilityStatus.DisposalDeduction,
                };

                var result = await _archivalEntityService.CreateDraftInternalAsync(draft);

                return OperationResult.Succeed(result);
            }
            else if (model.DocumentSystemIdentifier != null)
            {
                var document = await _documentService.GetDocumentBySystemIdentifierAsync(new Guid(model.DocumentSystemIdentifier));

                if (document == null)
                {
                    _logger.LogError($"Document with sysId {model.DocumentSystemIdentifier} does not exists");
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                DocumentDraftModel draft = new()
                {
                    IsCurrent = true,
                    ReadOnly = false,
                    EndDateDay = document.EndDateDay,
                    EndDateMonth = document.EndDateMonth,
                    EndDateYear = document.EndDateYear,
                    ExternalIdentifier = document.ExternalIdentifier,
                    FundDraftId = document.FundDraftId,
                    FundExternalIdentifier = document.FundExternalIdentifier,
                    FundHasExternalSource = document.FundHasExternalSource,
                    FundSystemIdentifier = document.FundSystemIdentifier,
                    HasExternalSource = document.HasExternalSource,
                    HasNoChronologicalScope = document.HasNoChronologicalScope,
                    LanguageCodes = document.LanguageCodes,
                    NegativeFrameCount = document.NegativeFrameCount,
                    Notes = document.Notes,
                    Number = document.Number,
                    OriginalityCodes = document.OriginalityCodes,
                    OtherMetrics = document.OtherMetrics,
                    PositiveFrameCount = document.PositiveFrameCount,
                    StartDateDay = document.StartDateDay,
                    StartDateMonth = document.StartDateMonth,
                    StartDateYear = document.StartDateYear,
                    StatusCode = document.StatusCode,
                    SystemIdentifier = document.SystemIdentifier,
                    Author = document.Author,
                    Description = document.Description,
                    DigitizedCopyCount = document.DigitizedCopyCount,
                    Features = document.Features,
                    InventoryDraftId = document.InventoryDraftId,
                    InventoryExternalIdentifier = document.InventoryExternalIdentifier,
                    InventoryHasExternalSource = document.InventoryHasExternalSource,
                    InventorySystemIdentifier = document.InventorySystemIdentifier,
                    Location = document.Location,
                    MicrofilmedCopyCount = document.MicrofilmedCopyCount,
                    OtherCopyCount = document.OtherCopyCount,
                    PaperCopyCount = document.PaperCopyCount,
                    Scaling = document.Scaling,
                    SheetCount = document.SheetCount,
                    SizeCm = document.SizeCm,
                    Title = document.Title,
                    ApproximateChronologicalScope = document.ApproximateChronologicalScope,
                    ArchivalEntityDraftId = document.ArchivalEntityDraftId,
                    ArchivalEntityExternalIdentifier = document.ArchivalEntityExternalIdentifier,
                    ArchivalEntityHasExternalSource = document.ArchivalEntityHasExternalSource,
                    ArchivalEntitySystemIdentifier = document.ArchivalEntitySystemIdentifier,
                    ArchiveId = document.ArchiveId,
                    Bytes = document.Bytes,
                    CreationMethodCodes = document.CreationMethodCodes,
                    DescriptionLevelCode = document.DescriptionLevelCode,
                    DigitalDevice = document.DigitalDevice,
                    DocumentsAccessDescription = document.DocumentsAccessDescription,
                    Duration = document.Duration,
                    EndSheetNumber = document.EndSheetNumber,
                    FileFormatCode = document.FileFormatCode,
                    FileTypeCodes = document.FileTypeCodes,
                    StartSheetNumber = document.StartSheetNumber,
                    Transcription = document.Transcription,
                    AvailabilityStatusCode = (int)Shared.AvailabilityStatus.DisposalDeduction,
                };

                var result = await _documentService.CreateDraftInternalAsync(draft);

                return OperationResult.Succeed(result);
            }


            return OperationResult.Failed();
        }
        private async Task<OperationResult> RemoveExistingDraft(DeductionViewModel model, bool undoChanges)
        {

            if (undoChanges && model.EpkReportModel?.Id != null)
            {
                var report = await _context.Epkreports
                                .Where(r => r.Id == model.EpkReportModel.Id && !r.Deleted)
                                .Select(r => r)
                                .SingleOrDefaultAsync();

                if (report != null)
                {
                    await _epkService.DeleteReportInternalAsync(report.Id);
                }
            }

            if (model.DocumentSystemIdentifier != null)
            {
                var ress = _context.DocumentDrafts.Where(d => d.SystemIdentifier.ToString() == model.DocumentSystemIdentifier && d.IsCurrent).FirstOrDefault();

                if (ress == null)
                {
                    return OperationResult.Failed("No existing item document-draft");
                }
                if (undoChanges)
                {

                    ress.Deleted = true;
                    ress.DeletedOn = DateTime.Now;
                }

                ress.IsCurrent = false;
                ress.ReadOnly = true;

                _context.Update(ress);

                await _context.SaveAsync("");

                return OperationResult.Success;
            }
            else if (model.ArchivalEntitySystemIdentifier != null)
            {
                var archival = _context.ArchivalEntityDrafts
                    .Where(d => d.SystemIdentifier.ToString() == model.ArchivalEntitySystemIdentifier && d.IsCurrent)
                    .FirstOrDefault();

                if (archival == null)
                {
                    return OperationResult.Failed("No existing item archivalEntity-draft");
                }

                if (undoChanges)
                {
                    archival.Deleted = true;
                    archival.DeletedOn = DateTime.Now;
                }

                archival.IsCurrent = false;
                archival.ReadOnly = true;

                _context.Update(archival);

                await _context.SaveAsync("");

                return OperationResult.Success;
            }
            else if (model.InventorySystemIdentifier != null)
            {
                var ress = _context.InventoryDrafts.Where(d => d.SystemIdentifier.ToString() == model.InventorySystemIdentifier && d.IsCurrent).FirstOrDefault();

                if (ress == null)
                {
                    return OperationResult.Failed("");
                }
                if (undoChanges)
                {
                    ress.Deleted = true;
                    ress.DeletedOn = DateTime.Now;
                }

                ress.IsCurrent = false;
                ress.ReadOnly = true;


                _context.Update(ress);

                await _context.SaveAsync("");

                return OperationResult.Success;
            }
            else if (model.FundSystemIdentifier != null)
            {
                var ress = _context.FundDrafts.Where(d => d.SystemIdentifier.ToString() == model.FundSystemIdentifier && d.IsCurrent).FirstOrDefault();

                if (ress == null)
                {
                    return OperationResult.Failed("");
                }

                if (undoChanges)
                {
                    ress.Deleted = true;
                    ress.DeletedOn = DateTime.Now;
                }

                ress.IsCurrent = false;
                ress.ReadOnly = true;


                _context.Update(ress);

                await _context.SaveAsync("");

                return OperationResult.Success;
            }

            return OperationResult.Failed("");
        }
    }
}
