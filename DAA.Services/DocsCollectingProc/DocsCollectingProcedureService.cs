using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Extensions.Models;
using DAA.Models.Applications;
using DAA.Models.ArchiveEntities;
using DAA.Models.Comments;
using DAA.Models.Commission;
using DAA.Models.Configuration;
using DAA.Models.DigitalObjects;
using DAA.Models.DocsCollectionProcedure;
using DAA.Models.Documents;
using DAA.Models.Processes;
using DAA.Models.Tasks;
using DAA.Services.Applications;
using DAA.Services.ArchivalEntities;
using DAA.Services.Comments;
using DAA.Services.DigitalObjects;
using DAA.Services.Documents;
using DAA.Services.Funds;
using DAA.Services.Interfaces;
using DAA.Services.Inventories;
using DAA.Services.Notifications;
using DAA.Services.Packages;
using DAA.Services.Process;
using DAA.Services.Tasks;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Text;
using ProcessType = DAA.Shared.ProcessType;
using Task = System.Threading.Tasks.Task;

namespace DAA.Services.DocsCollectingProc
{
    public class DocsCollectingProcedureService : BaseService, IDocsCollectingProcedureService
    {
        private readonly LinkedServerSettings _settings;
        private readonly IUserInfo _userInfo;
        private readonly IProcessService _processService;
        private readonly ITaskService _taskService;
        private readonly IFundService _fundService;
        private readonly IInventoryService _inventoryService;
        private readonly IArchivalEntityService _archivalEntityService;
        private readonly IDocumentService _documentService;
        private readonly IDigitalObjectService _digitalObjectService;
        private readonly IPackagesService _packageService;
        private readonly IApplicationsService _applicationService;
        private readonly INotificationEventService _notificationEventService;
        private readonly IUtilityService _utilityService;
        private readonly ICommentsService _commentsService;

        public DocsCollectingProcedureService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            ILogger<IArchivalEntityService> logger,
            IOptions<LinkedServerSettings> settings,
            IUserInfo userInfo,
            IProcessService processService,
            ITaskService taskService,
            IFundService fundService,
            IInventoryService inventoryService,
            IArchivalEntityService archivalEntityService,
            IDocumentService documentService,
            IDigitalObjectService digitalObjectService,
            IPackagesService packageService,
            IApplicationsService applicationService,
            INotificationEventService notificationEventService,
            IUtilityService utilityService,
            ICommentsService commentsService)
            : base(context, localizer, logger)
        {
            _settings = settings.Value;
            _userInfo = userInfo;
            _processService = processService;
            _taskService = taskService;
            _fundService = fundService;
            _inventoryService = inventoryService;
            _archivalEntityService = archivalEntityService;
            _documentService = documentService;
            _digitalObjectService = digitalObjectService;
            _packageService = packageService;
            _applicationService = applicationService;
            _notificationEventService = notificationEventService;
            _utilityService = utilityService;
            _commentsService = commentsService;
        }

        public DataSourceResponseModel<DocsCollectingGridModel> List(DataSourceRequestModel model)
        {
            int[] ids = new int[] {
                (int)ProcessType.AddInventory,
                (int)ProcessType.AddRawInventory,
                (int)ProcessType.AddRawInventoryToRawFund,
                (int)ProcessType.AddFundAndInventory,
                (int)ProcessType.AddRawFundAndRawInventory,
            };
            var processes = from p in _context.Processes
                            let i = _context.VInventories.Where(x => x.SystemIdentifier == p.InventorySystemIdentifier).FirstOrDefault()
                            let f = _context.VFunds.Where(x => x.SystemIdentifier == p.FundSystemIdentifier).FirstOrDefault()
                            where !p.Deleted
                            && ids.Contains(p.ProcessTypeId)
                            orderby p.CreatedOn descending
                            select new DocsCollectingGridModel()
                            {
                                ProcessTypeTitle = p.ProcessType.Name,
                                ArchiveId = p.ArchiveId,
                                ArchiveName = p.Archive!.Name,
                                CreatedBy = p.CreatedBy,
                                CreatedByDisplayName = p.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                CreatedByUserName = p.CreatedByNavigation.UserName,
                                CreatedOn = p.CreatedOn,
                                FundSystemId = f.SystemIdentifier,
                                FundNumber = f.Title,
                                UpdatedBy = p.UpdatedBy,
                                UpdatedByDisplayName = p.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                UpdatedByUserName = p.UpdatedByNavigation!.UserName,
                                UpdatedOn = p.UpdatedOn,
                                Completed = p.Completed,
                                InventorySystemId = i.SystemIdentifier,
                                InventoryNumber = i.Number!,
                            };


            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                processes = processes.FilterBySearchText(model.SearchString);
            }

            QueryResponseModel<DocsCollectingGridModel> queryResponse = processes.SortAndFilter(model);

            DataSourceResponseModel<DocsCollectingGridModel> result = new DataSourceResponseModel<DocsCollectingGridModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query
            };
            return result;
        }


        public async Task<OperationResult> CommitComitteeReport(CommissionReportSubmitModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                //get process data 

                //var process = await _context.Processes.FindAsync(model.ProcessId);
                //var process = await _processService.GetProcessAsync(model.ProcessId!.Value);

                //if (process == null)
                //{
                //    //throw new NullReferenceException("Process not found");
                //    await transaction.RollbackAsync();
                //    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                //}

                var process = await _processService.GetProcessAsync(model.ProcessId!.Value);

                var validateProcessResult =
                    _processService.ValidateProcess(
                        process,
                        ProcessType.AddFundAndInventory,
                        ProcessType.AddInventory,
                        ProcessType.AddRawFundAndRawInventory,
                        ProcessType.AddRawInventory,
                        ProcessType.AddRawInventoryToRawFund,
                        ProcessType.AddSystemInventory);
                if (!validateProcessResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessResult;
                }

                var processStep = await _processService.GetProcessStepAsync(process!.ActiveProcessStepId!.Value);

                var validateProcessStepResult = _processService.ValidateProcessStep(process, processStep, ProcessStepType.CommissionReport, ProcessStepType.CommissionReportEdit);
                if (!validateProcessStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessStepResult;
                }

                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)processStep.StepTypeId, model.ProcessId, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return completePrevTaskResult;
                }

                //Update report
                var report = await _context.Epkreports.FindAsync(model.Id);
                if (report == null)
                {
                    //throw new NullReferenceException("Report not found");
                    await transaction.RollbackAsync();
                    return OperationResult.Failed(false, _localizer.GetString("Error_ReportDoesNotExists", process.ProcessTypeTitle!).ToString());
                }

                report.IsDraft = false;
                report.Title = model.Title!;
                report.Content = model.Content!;


                //if (process.ProcessTypeId == (int)Shared.ProcessType.AddFundAndInventory
                //|| process.ProcessTypeId == (int)Shared.ProcessType.AddInventory)
                //{
                //    if (await _context.DocumentDrafts
                //           .Where(doc => 
                //                (doc.InventorySystemIdentifier == process.InventorySystemIdentifier 
                //                    || !process.InventorySystemIdentifier.HasValue && doc.FundSystemIdentifier == process.FundSystemIdentifier)
                //               && doc.IsCurrent
                //               && !doc.Deleted
                //               && !doc.DigitalObjectDrafts.Where(dobj => dobj.IsCurrent && !dobj.Deleted).Any())
                //           .AnyAsync())
                //    {
                //        await transaction.RollbackAsync();
                //        return OperationResult.Failed(false, _localizer.GetString("Error_MissingDocumentFiles").ToString());
                //    }
                //}

                var inventorySysId = process.InventorySystemIdentifier;
                if (!process.InventorySystemIdentifier.HasValue)
                {
                    inventorySysId = await _context.InventoryDrafts
                                        .Where(inv => inv.FundSystemIdentifier == process.FundSystemIdentifier && inv.IsCurrent && !inv.Deleted)
                                        .Select(inv => inv.SystemIdentifier)
                                        .FirstOrDefaultAsync();
                }

                if (!inventorySysId.HasValue)
                {
                    _logger.LogError($"Missing inventory sysId for process {model.ProcessId}");

                    await transaction.RollbackAsync();
                    return OperationResult.Failed($"Missing inventory sysId for process {model.ProcessId}");
                }

                var packageAId = await _packageService.GetPackageIdByInventory("A", inventorySysId!.Value);
                if (packageAId.HasValue && !await _packageService.PackageHasRequiredDocumentsAsync(packageAId.Value, (ProcessType)process.ProcessTypeId!.Value))
                {
                    await transaction.RollbackAsync();
                    return OperationResult.Failed(false, _localizer.GetString("Error_MissingRequiredPackageADocs").ToString());
                }

                //var packageB = await _packageService.GetPackageIdByInventory("B", inventorySysId!.Value);
                //if (packageB.HasValue && !await _packageService.PackageHasRequiredDocumentsAsync(packageB.Value, (ProcessType)process.ProcessTypeId!.Value))
                //{
                //    await transaction.RollbackAsync();
                //    return OperationResult.Failed(false, _localizer.GetString("Error_MissingPackageB").ToString());
                //}

                string? failedMessage = string.Empty;
                switch ((Shared.ProcessType)process.ProcessTypeId!.Value)
                {
                    case ProcessType.AddFundAndInventory:
                    case ProcessType.AddInventory:
                        if (await _context.DocumentDrafts
                           .Where(doc =>
                                (doc.InventorySystemIdentifier == process.InventorySystemIdentifier
                                    || !process.InventorySystemIdentifier.HasValue && doc.FundSystemIdentifier == process.FundSystemIdentifier)
                               && doc.IsCurrent
                               && !doc.Deleted
                               && !doc.DigitalObjectDrafts.Where(dobj => dobj.IsCurrent && !dobj.Deleted).Any())
                           .AnyAsync())
                        {
                            failedMessage = _localizer.GetString("Error_MissingDocumentFiles").ToString();
                        }
                        if (process.ProcessTypeId!.Value == (int)ProcessType.AddInventory)
                        {
                            var packageB = await _packageService.GetPackageIdByInventory("B", inventorySysId.Value);
                            if (!packageB.HasValue || !await _packageService.PackageHasAnyDocumentsAsync(packageB.Value))
                            {
                                failedMessage = _localizer.GetString("Error_MissingPackageB").ToString();
                            }
                        }
                        break;
                    case ProcessType.AddRawFundAndRawInventory:
                    case ProcessType.AddRawInventoryToRawFund:
                    case ProcessType.AddRawInventory:
                    case ProcessType.AddSystemInventory:
                        var packageBId = await _packageService.GetPackageIdByInventory("B", inventorySysId.Value);
                        if (!packageBId.HasValue || !await _packageService.PackageHasAnyDocumentsAsync(packageBId.Value))
                        {
                            failedMessage = _localizer.GetString("Error_MissingPackageB").ToString();
                        }
                        break;
                }

                if (!string.IsNullOrWhiteSpace(failedMessage))
                {
                    await transaction.RollbackAsync();
                    return OperationResult.Failed(false, failedMessage);
                }

                ProcessStepType nextStep = ProcessStepType.CommissionReviewDate;
                string entityType = BusinessObjectType.Unknown;
                Guid? entityId = null;

                //Update step
                //switch ((ProcessType)process.ProcessTypeId!.Value)
                //{
                //    case ProcessType.AddFundAndInventory:
                //    case ProcessType.AddRawFundAndRawInventory:
                //        entityType = BusinessObjectType.Fund;
                //        entityId = process.FundSystemIdentifier;
                //        break;
                //    case ProcessType.AddRawInventoryToRawFund:
                //    case ProcessType.AddInventory:
                //    case ProcessType.AddSystemInventory:
                //        entityType = BusinessObjectType.Inventory;
                //        entityId = process.InventorySystemIdentifier;
                //        break;
                //    default:
                //        await transaction.RollbackAsync();
                //        return OperationResult.Failed(false, _localizer.GetString("Error_InvalidProcessType", process.ProcessTypeTitle!).ToString());
                //}
                entityType = _processService.GetEntityType(process);
                entityId = _processService.GetEntitySystemIdentifier(process);

                var nextStepResult = await _processService.SetActiveProcessStepAsync(process.Id!.Value, (int)nextStep);
                if (!nextStepResult.Succeeded)
                {
                    //throw new Exception(nextStepResult.ToString());
                    await transaction.RollbackAsync();
                    return nextStepResult;
                }

                int nextStepId = (int)nextStepResult.Data!;

                //Send tasks
                TaskCreateModel taskModel = new()
                {
                    StepType = nextStep,
                    ProcessId = model.ProcessId,
                    //TimelineId = (int)nextStep,
                    TimelineId = nextStepId,
                    EntitySystemIdentifier = entityId,
                    AssignedToUserId = model.AssignToUserId,
                    AssignedToRoleId = model.AssignToRoleId,
                    EntityType = entityType,
                };

                var taskResult = await _taskService.CreateAsync(taskModel);
                if (!taskResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return taskResult;
                }

                await _context.SaveAsync($"Commit committee report with ID {model.Id}");
                await transaction.CommitAsync();

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                await transaction.RollbackAsync();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> RejectReport(RejectModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var process = await _processService.GetProcessAsync(model.Id);

                var validateProcessResult =
                    _processService.ValidateProcess(
                        process,
                        ProcessType.AddFundAndInventory,
                        ProcessType.AddInventory,
                        ProcessType.AddRawFundAndRawInventory,
                        ProcessType.AddRawInventory,
                        ProcessType.AddRawInventoryToRawFund,
                        ProcessType.AddSystemInventory);
                if (!validateProcessResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessResult;
                }

                var processStep = await _processService.GetProcessStepAsync(process!.ActiveProcessStepId!.Value);

                var validateProcessStepResult = _processService.ValidateProcessStep(process, processStep, ProcessStepType.CommissionReviewDate);
                if (!validateProcessStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessStepResult;
                }

                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)processStep.StepTypeId, model.Id, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return completePrevTaskResult;
                }

                //Update report
                var report = await _context.Epkreports.Where(x => x.ProcessId == model.Id).FirstOrDefaultAsync();
                if (report == null)
                {
                    //throw new NullReferenceException("Report not found");
                    await transaction.RollbackAsync();
                    return OperationResult.Failed(false, _localizer.GetString("Error_ReportDoesNotExists", process.ProcessTypeTitle!).ToString());
                }

                report.IsDraft = true;

                //get process data 
                //var process = await _context.Processes.FindAsync(model.Id);

                //if (process == null)
                //{
                //    throw new NullReferenceException("Process not found");
                //}

                //Add comment
                Comment c = new Comment()
                {
                    IsDraft = false,
                    ProcessId = model.Id,
                    Text = model.Reason,
                    ProcessStepId = (int)ProcessStepType.CommissionReportEdit

                };
                _context.Comments.Add(c);

                ProcessStepType nextStep = ProcessStepType.CommissionReportEdit;
                var nextStepResult = await _processService.SetActiveProcessStepAsync(process.Id!.Value, (int)nextStep);
                if (!nextStepResult.Succeeded)
                {
                    //throw new Exception(nextStepResult.ToString());
                    await transaction.RollbackAsync();
                    return nextStepResult;
                }

                int nextStepId = (int)nextStepResult.Data!;

                string entityType;
                Guid entityId;

                //Update step
                //switch (process.ProcessTypeId)
                //{
                //    case (int)ProcessType.AddFundAndInventory:
                //    case (int)ProcessType.AddRawFundAndRawInventory:
                //        entityType = BusinessObjectType.Fund;
                //        entityId = process.FundSystemIdentifier!.Value;
                //        break;
                //    case (int)ProcessType.AddRawInventoryToRawFund:
                //    case (int)ProcessType.AddInventory:
                //    case (int)ProcessType.AddSystemInventory:
                //        entityType = BusinessObjectType.Inventory;
                //        entityId = process.InventorySystemIdentifier!.Value;
                //        break;
                //    default:
                //        throw new Exception("Process type not valid");
                //}
                entityType = _processService.GetEntityType(process);
                entityId = _processService.GetEntitySystemIdentifier(process);

                //Send tasks
                TaskCreateModel taskModel = new()
                {
                    StepType = nextStep,
                    ProcessId = model.Id,
                    //TimelineId = (int)nextStep,
                    TimelineId = nextStepId,
                    EntitySystemIdentifier = entityId,
                    AssignedToUserId = process.CreatedBy.ToString(),
                    EntityType = entityType,
                };

                var taskResult = await _taskService.CreateAsync(taskModel);
                if (!taskResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return taskResult;
                }

                await _context.SaveAsync($"Commit committee report with ID {model.Id}");
                await transaction.CommitAsync();

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                await transaction.RollbackAsync();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task ReturnCommissionChanges(ProcessStepModel model)
        {
            ProcessStepType nextStep = ProcessStepType.CommissionCorrections;
            ProcessStepModel step = new ProcessStepModel()
            {
                AssignedToRoleId = model.AssignedToRoleId,
                AssignedToUserId = model.AssignedToUserId,
                ProcessId = model.ProcessId,
                StepTypeId = (int)nextStep
            };

            await _processService.SetActiveProcessStepAsync(step);

            //Add comment
            Comment c = new Comment()
            {
                IsDraft = false,
                ProcessId = model.ProcessId,
                Text = model.Comment,
                ProcessStepId = (int)nextStep

            };

            _context.Comments.Add(c);

            await _context.SaveAsync("");
        }

        public async Task<OperationResult> SendForStandpoints(CommissionReportSubmitModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                //get process data 
                var process = await _processService.GetProcessAsync(model.ProcessId!.Value);

                var validateProcessResult =
                    _processService.ValidateProcess(
                        process,
                        ProcessType.AddFundAndInventory,
                        ProcessType.AddInventory,
                        ProcessType.AddRawFundAndRawInventory,
                        ProcessType.AddRawInventory,
                        ProcessType.AddRawInventoryToRawFund,
                        ProcessType.AddSystemInventory);
                if (!validateProcessResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessResult;
                }

                var processStep = await _processService.GetProcessStepAsync(process!.ActiveProcessStepId!.Value);

                var validateProcessStepResult = _processService.ValidateProcessStep(process, processStep, ProcessStepType.CommissionReviewDate);
                if (!validateProcessStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessStepResult;
                }

                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)processStep.StepTypeId, model.ProcessId, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return completePrevTaskResult;
                }

                //var process = await _context.Processes.FindAsync(model.ProcessId);

                //if (process == null)
                //{
                //    throw new NullReferenceException("Process not found");
                //}

                ProcessStepType nextStep = ProcessStepType.CommissionOpinions;
                string entityType;
                Guid entityId;

                //Update step
                //switch (process.ProcessTypeId)
                //{
                //    case (int)ProcessType.AddFundAndInventory:
                //    case (int)ProcessType.AddRawFundAndRawInventory:
                //        entityType = BusinessObjectType.Fund;
                //        entityId = process.FundSystemIdentifier.Value;
                //        break;
                //    case (int)ProcessType.AddInventory:
                //    case (int)ProcessType.AddRawInventoryToRawFund:
                //        entityType = BusinessObjectType.Inventory;
                //        entityId = process.InventorySystemIdentifier.Value;
                //        break;
                //    default:
                //        throw new Exception("Process type not valid");
                //}
                entityType = _processService.GetEntityType(process);
                entityId = _processService.GetEntitySystemIdentifier(process);

                var nextStepResult = await _processService.SetActiveProcessStepAsync(process.Id!.Value, (int)nextStep);
                if (!nextStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return nextStepResult;
                }

                int nextStepId = (int)nextStepResult.Data!;

                //TODO
                //Send tasks
                TaskCreateModel taskModel = new()
                {
                    StepType = nextStep,
                    ProcessId = model.ProcessId!.Value,
                    //TimelineId = (int)nextStep,
                    TimelineId = nextStepId,
                    EntitySystemIdentifier = entityId,
                    AssignedToUserId = model.AssignToUserId,
                    AssignedToRoleId = model.AssignToRoleId,
                    EntityType = entityType,
                };

                var taskResult = await _taskService.CreateAsync(taskModel);
                if (!taskResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return taskResult;
                }

                await _context.SaveAsync($"Commit committee report with ID {model.Id}");
                await transaction.CommitAsync();

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                await transaction.RollbackAsync();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> ApplyCommissionDecision(ProcessDecisionModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                //var process = await _context.Processes.FindAsync(model.ProcessId);

                //if (process == null)
                //{
                //    throw new NullReferenceException($"Process with ID = {model.ProcessId} not found");
                //}

                //get process data 
                var process = await _processService.GetProcessAsync(model.ProcessId);

                var validateProcessResult =
                    _processService.ValidateProcess(
                        process,
                        ProcessType.AddFundAndInventory,
                        ProcessType.AddInventory,
                        ProcessType.AddRawFundAndRawInventory,
                        ProcessType.AddRawInventory,
                        ProcessType.AddRawInventoryToRawFund,
                        ProcessType.AddSystemInventory);
                if (!validateProcessResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessResult;
                }

                //get active step
                var processStep = await _processService.GetProcessStepAsync(process!.ActiveProcessStepId!.Value);

                var validateProcessStepResult = _processService.ValidateProcessStep(process, processStep, ProcessStepType.ConfirmedProtocol);
                if (!validateProcessStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessStepResult;
                }

                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)processStep.StepTypeId, model.ProcessId, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return completePrevTaskResult;
                }

                EdocsCollectingApplication? application = null;
                ProcessStepType nextStep;

                // Find the application if any
                application = await _applicationService.GetApplicationFromInventoryDraft(process.FundSystemIdentifier, process.InventorySystemIdentifier);

                string entityType = _processService.GetEntityType(process);
                Guid entitySysId = _processService.GetEntitySystemIdentifier(process);
                if (model.Accepted)
                {
                    // move to next step
                    if (model.HasConditions)
                    {
                        // return for changes
                        nextStep = ProcessStepType.CommissionCorrections;
                        //TODO Send message to B
                    }
                    else
                    {
                        //next step is acquisition contract
                        nextStep = ProcessStepType.AcquisitionContract;
                        if (application != null)
                            application.StatusId = (int)ApplicationStatus.AcquisitionContract;
                        //TODO Send notification to B
                    }

                    ProcessStepModel step = new ProcessStepModel()
                    {
                        AssignedToRoleId = model.AssignToRoleId,
                        AssignedToUserId = model.AssignToUserId,
                        ProcessId = process.Id!.Value,
                        StepTypeId = (int)nextStep
                    };

                    var nextStepResult = await _processService.SetActiveProcessStepAsync(step);
                    if (!nextStepResult.Succeeded)
                    {
                        await transaction.RollbackAsync();
                        return nextStepResult;
                    }

                    int nextStepId = (int)nextStepResult.Data!;

                    //Send tasks to B
                    TaskCreateModel taskModel = new()
                    {
                        StepType = nextStep,
                        ProcessId = process.Id,
                        TimelineId = nextStepId,
                        EntitySystemIdentifier = entitySysId,
                        AssignedToUserId = process.CreatedBy.ToString(),
                        EntityType = entityType,
                    };

                    var taskResult = await _taskService.CreateAsync(taskModel);
                    if (!taskResult.Succeeded)
                    {
                        await transaction.RollbackAsync();
                        return taskResult;
                    }
                }
                else
                {
                    //end process
                    process.Completed = true;

                    //FIX Why are not the fund/inventory changes undone?

                    if (application != null)
                    {
                        application.StatusId = (int)ApplicationStatus.RejectedByCommission;
                        //TODO Send notification to the applicant
                    }
                }

                await _context.SaveAsync("");
                transaction.Commit();

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> SendCommissionDecisionApprovalResultAsync(ProcessDecisionModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var process = await _processService.GetProcessAsync(model.ProcessId);

                var validateProcessResult =
                    _processService.ValidateProcess(
                        process,
                        ProcessType.AddFundAndInventory,
                        ProcessType.AddInventory,
                        ProcessType.AddRawFundAndRawInventory,
                        ProcessType.AddRawInventory,
                        ProcessType.AddRawInventoryToRawFund,
                        ProcessType.AddSystemInventory);
                if (!validateProcessResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessResult;
                }

                //get active step
                var processStep = await _processService.GetProcessStepAsync(process!.ActiveProcessStepId!.Value);

                var validateProcessStepResult =
                    _processService.ValidateProcessStep(process, processStep, ProcessStepType.ConfirmedProtocol, ProcessStepType.CommissionCorrectionsCheck);
                if (!validateProcessStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessStepResult;
                }

                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)processStep.StepTypeId, model.ProcessId, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return completePrevTaskResult;
                }

                EdocsCollectingApplication? application = await _applicationService.GetByProcessInternalAsync(model.ProcessId);
                if(application != null)
                {
                    completePrevTaskResult = await _taskService.CompletePreviousTask(ProcessStepType.NoStep, model.ProcessId, Shared.NotificationType.ModificationApplied, application.Id);
                    if (!completePrevTaskResult.Succeeded)
                    {
                        await transaction.RollbackAsync();
                        return completePrevTaskResult;
                    }
                }


                ProcessStepModel nextStep = new ProcessStepModel();
                nextStep.ProcessId = model.ProcessId;
                nextStep.AssignedToUserId = model.AssignToUserId;
                nextStep.AssignedToRoleId = model.AssignToRoleId;


                if (model.Accepted)
                {
                    // move to next step
                    if (model.HasConditions)
                    {
                        // return for changes
                        nextStep.AssignedToUserId = process.CreatedBy;
                        nextStep.AssignedToRoleId = null;
                        nextStep.StepTypeId = (int)ProcessStepType.CommissionCorrections;
                    }
                    else
                    {
                        nextStep.StepTypeId = model.AssignForRedirect ? (int)ProcessStepType.SendForRedirect : (int)ProcessStepType.AcquisitionContract;
                    }

                    var nextStepResult = await _processService.SetActiveProcessStepAsync(nextStep);
                    if (!nextStepResult.Succeeded)
                    {
                        await transaction.RollbackAsync();
                        return nextStepResult;
                    }

                    int nextStepId = (int)nextStepResult.Data!;

                    if (nextStep.AssignedToUserId.HasValue || nextStep.AssignedToRoleId.HasValue)
                    {
                        //Send tasks to assignees
                        TaskCreateModel taskModel = new()
                        {
                            StepType = (ProcessStepType)nextStep.StepTypeId,
                            ProcessId = process.Id,
                            TimelineId = nextStepId,
                            EntitySystemIdentifier = _processService.GetEntitySystemIdentifier(process),
                            AssignedToUserId = nextStep.AssignedToUserId.HasValue ? nextStep.AssignedToUserId.Value.ToString("D") : null,
                            AssignedToRoleId = nextStep.AssignedToRoleId.HasValue ? nextStep.AssignedToRoleId.Value.ToString("D") : null,
                            EntityType = _processService.GetEntityType(process),
                        };

                        var taskResult = await _taskService.CreateAsync(taskModel);
                        if (!taskResult.Succeeded)
                        {
                            await transaction.RollbackAsync();
                            return taskResult;
                        }
                    }
                }
                else
                {
                    //TODO: Send task to expert B
                    //end process
                    //process.Completed = true;
                    var completeProcessResult = await _processService.CompleteProcessAsync(process!.Id!.Value);
                    if (!completeProcessResult.Succeeded)
                    {
                        transaction.Rollback();
                        return completeProcessResult;
                    }

                    //FIX What is the fund/inventory status?

                    if (application != null)
                    {
                        application.StatusId = (int)ApplicationStatus.RejectedByCommission;
                        //TODO Send notification to the applicant
                    }
                }

                await _context.SaveAsync("");
                transaction.Commit();

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> SendModificationsAffirmationResultAsync(ProcessDecisionModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var process = await _processService.GetProcessAsync(model.ProcessId);

                var validateProcessResult =
                    _processService.ValidateProcess(
                        process,
                        ProcessType.AddFundAndInventory,
                        ProcessType.AddInventory,
                        ProcessType.AddRawFundAndRawInventory,
                        ProcessType.AddRawInventory,
                        ProcessType.AddRawInventoryToRawFund,
                        ProcessType.AddSystemInventory);
                if (!validateProcessResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessResult;
                }

                //get active step
                var processStep = await _processService.GetProcessStepAsync(process!.ActiveProcessStepId!.Value);

                var validateProcessStepResult =
                    _processService.ValidateProcessStep(process, processStep, ProcessStepType.ConfirmedProtocol, ProcessStepType.Affirmation);
                if (!validateProcessStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessStepResult;
                }

                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)processStep.StepTypeId, model.ProcessId, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return completePrevTaskResult;
                }

                ProcessStepModel nextStep = new ProcessStepModel();
                nextStep.ProcessId = model.ProcessId;
                nextStep.AssignedToUserId = model.AssignToUserId;
                nextStep.AssignedToRoleId = model.AssignToRoleId;

                EdocsCollectingApplication? application = null;

                if (model.Accepted)
                {
                    // move to next step
                    if (model.HasConditions)
                    {
                        // return for changes
                        nextStep.AssignedToUserId = process.CreatedBy;
                        nextStep.AssignedToRoleId = null;
                        nextStep.StepTypeId = (int)ProcessStepType.CommissionCorrections;
                    }
                    else
                    {
                        nextStep.AssignedToUserId = process.CreatedBy;
                        nextStep.AssignedToRoleId = null;
                        nextStep.StepTypeId = (int)ProcessStepType.SendForRegistration;
                    }

                    var nextStepResult = await _processService.SetActiveProcessStepAsync(nextStep);
                    if (!nextStepResult.Succeeded)
                    {
                        await transaction.RollbackAsync();
                        return nextStepResult;
                    }

                    int nextStepId = (int)nextStepResult.Data!;

                    if (nextStep.AssignedToUserId.HasValue || nextStep.AssignedToRoleId.HasValue)
                    {
                        //Send tasks to assignees
                        TaskCreateModel taskModel = new()
                        {
                            StepType = (ProcessStepType)nextStep.StepTypeId,
                            ProcessId = process.Id,
                            TimelineId = nextStepId,
                            EntitySystemIdentifier = _processService.GetEntitySystemIdentifier(process),
                            AssignedToUserId = nextStep.AssignedToUserId.HasValue ? nextStep.AssignedToUserId.Value.ToString("D") : null,
                            AssignedToRoleId = nextStep.AssignedToRoleId.HasValue ? nextStep.AssignedToRoleId.Value.ToString("D") : null,
                            EntityType = _processService.GetEntityType(process),
                        };

                        var taskResult = await _taskService.CreateAsync(taskModel);
                        if (!taskResult.Succeeded)
                        {
                            await transaction.RollbackAsync();
                            return taskResult;
                        }
                    }
                }
                else
                {
                    //TODO: Send task to expert B
                    //end process
                    //process.Completed = true;
                    var completeProcessResult = await _processService.CompleteProcessAsync(process!.Id!.Value);
                    if (!completeProcessResult.Succeeded)
                    {
                        transaction.Rollback();
                        return completeProcessResult;
                    }

                    //FIX What is the fund/inventory status?

                    if (application != null)
                    {
                        application.StatusId = (int)ApplicationStatus.RejectedByCommission;
                        //TODO Send notification to the applicant
                    }
                }

                await _context.SaveAsync("");
                transaction.Commit();

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> RedirectToArchiveAsync(ProcessDecisionModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var process = await _processService.GetProcessAsync(model.ProcessId);

                var validateProcessResult =
                    _processService.ValidateProcess(
                        process,
                        ProcessType.AddRawFundAndRawInventory,
                        ProcessType.AddRawInventory,
                        ProcessType.AddRawInventoryToRawFund,
                        ProcessType.AddSystemInventory);
                if (!validateProcessResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessResult;
                }

                //get active step
                var processStep = await _processService.GetProcessStepAsync(process!.ActiveProcessStepId!.Value);

                var validateProcessStepResult = _processService.ValidateProcessStep(process, processStep, ProcessStepType.SendForRedirect);
                if (!validateProcessStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessStepResult;
                }

                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)processStep.StepTypeId, model.ProcessId, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return completePrevTaskResult;
                }

                // check for selected archive
                if (!model.RedirectToArchiveId.HasValue)
                {
                    OperationResult missingArchiveResult = OperationResult.Failed(false, _localizer.GetString("Error_MissingRedirectArchiveId").ToString());
                    await transaction.RollbackAsync();
                    return missingArchiveResult;
                }

                // get the application if any
                EdocsCollectingApplication? application = await _applicationService.GetApplicationFromInventoryDraft(process.FundSystemIdentifier, process.InventorySystemIdentifier);


                // create a system application for internal process
                if (application == null)
                {
                    InventoryDraft invDraft = await _utilityService.GetProcessInventoryDraftAsync(process.FundSystemIdentifier, process.InventorySystemIdentifier);
                    Shared.FundType? fundTypeCode = await _utilityService.GetFundTypeAsync(invDraft.FundSystemIdentifier);
                    string docOriginType = fundTypeCode == Shared.FundType.Personal ? ApplicationDocumentsOriginType.PersonalRaw : ApplicationDocumentsOriginType.InstitutionalRaw;

                    var systemApplicationResult = await _applicationService.CreateSystemApplicationAsync(invDraft!, docOriginType);
                    if (!systemApplicationResult.Succeeded)
                    {
                        await transaction.RollbackAsync();
                        return systemApplicationResult;
                    }

                    application = (EdocsCollectingApplication)systemApplicationResult.Data!;

                    invDraft!.ApplicationId = application.Id;
                    _context.InventoryDrafts.Update(invDraft);
                    await _context.SaveAsync("Set system application for inventory");
                }

                // redirect application
                int newApplicationId = 0;
                var redirectApplicationResult = await _applicationService.RedirectAsync(application, model.RedirectToArchiveId.Value);
                if (!redirectApplicationResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return redirectApplicationResult;
                }
                newApplicationId = (int)redirectApplicationResult.Data!;


                // deduct draft data
                OperationResult deductionResult = await _utilityService.DeductRedirectedData(process.FundSystemIdentifier, process.InventorySystemIdentifier);
                if (!deductionResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return deductionResult;
                }

                // create entities from drafts
                OperationResult createEntitiesResult = await CreateEntitiesFromDrafts(process.FundSystemIdentifier, process.InventorySystemIdentifier);
                if (!createEntitiesResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return createEntitiesResult;
                }

                // TODO: пакет А става белова!


                // change suspend access
                var accessResult = await _utilityService.ModifyDataAccessAsync(process.FundSystemIdentifier, process.InventorySystemIdentifier, false);
                if (!accessResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return accessResult;
                }


                // move to next step - Redirected
                ProcessStepModel nextStep = new ProcessStepModel();
                nextStep.ProcessId = model.ProcessId;
                nextStep.StepTypeId = (int)ProcessStepType.Redirected;

                var nextStepResult = await _processService.SetActiveProcessStepAsync(nextStep);
                if (!nextStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return nextStepResult;
                }

                int nextStepId = (int)nextStepResult.Data!;

                // add task for Group G in the new archive
                var roleName = _localizer.GetString("Role_G").ToString();
                var role = await _context.AspNetRoles
                        .Where(r => r.ArchiveId == model.RedirectToArchiveId && r.Name == roleName)
                        .OrderBy(r => r.Name)
                        .FirstOrDefaultAsync();
                Guid? assignedToRoleId = role != null ? role.Id : null;

                if (assignedToRoleId != null)
                {
                    TaskCreateModel taskModel = new()
                    {
                        EntityType = BusinessObjectType.EDocsApplication,
                        EntityId = newApplicationId,
                        StepType = (ProcessStepType)nextStep.StepTypeId,
                        ProcessId = process.Id,
                        TimelineId = nextStepId,
                        AssignedToRoleId = assignedToRoleId.Value.ToString("D"),
                    };

                    var taskResult = await _taskService.CreateAsync(taskModel);
                    if (!taskResult.Succeeded)
                    {
                        await transaction.RollbackAsync();
                        return taskResult;
                    }
                }


                // complete process
                nextStep.StepTypeId = (int)ProcessStepType.EndProcess;

                var nextStepCompleteResult = await _processService.SetActiveProcessStepAsync(nextStep);
                if (!nextStepCompleteResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return nextStepCompleteResult;
                }

                var processCompleteResult = await _processService.CompleteProcessAsync(process.Id.Value);
                if (!processCompleteResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return processCompleteResult;
                }


                await _context.SaveAsync("");
                transaction.Commit();

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        private async Task<OperationResult> CreateEntitiesFromDrafts(Guid? fundSystemIdentifier, Guid? inventorySystemIdentifier)
        {
            try
            {
                List<InventoryDraft> inventoryDrafts = new List<InventoryDraft>();
                if (fundSystemIdentifier.HasValue && fundSystemIdentifier != Guid.Empty)
                {
                    bool hasDraft = await _fundService.HasCurrentDraftAsync(fundSystemIdentifier.Value);
                    if (hasDraft)
                    {
                        var fundSysId = await _fundService.CreateOrUpdateFundFromDraftInternalAsync(fundSystemIdentifier.Value);
                    }

                    inventoryDrafts = await _context.InventoryDrafts
                    .Where(inv => inv.FundSystemIdentifier == fundSystemIdentifier.Value && inv.IsCurrent && !inv.Deleted)
                    .ToListAsync();
                }
                else if (inventorySystemIdentifier.HasValue && inventorySystemIdentifier != Guid.Empty)
                {
                    inventoryDrafts = await _context.InventoryDrafts
                    .Where(inv => inv.SystemIdentifier == inventorySystemIdentifier.Value && inv.IsCurrent && !inv.Deleted)
                    .ToListAsync();
                }

                var inventoryDraftSysIds = inventoryDrafts.Select(x => x.SystemIdentifier).ToList();
                foreach (Guid sysId in inventoryDraftSysIds)
                {
                    var inventorySysId = await _inventoryService.CreateOrUpdateInventoryFromDraftInternalAsync(sysId);
                }

                var archivalEntityDraftSysIds = await _context.ArchivalEntityDrafts
                    .Where(ae => inventoryDraftSysIds.Contains(ae.InventorySystemIdentifier) && ae.IsCurrent && !ae.Deleted)
                    .Select(ae => ae.SystemIdentifier)
                    .ToListAsync();
                foreach (Guid sysId in archivalEntityDraftSysIds)
                {
                    var archivalEntitySysId = await _archivalEntityService.CreateOrUpdateArchivalEntityFromDraftInternalAsync(sysId);
                }

                var documentDraftSysIds = await _context.DocumentDrafts
                    .Where(d => inventoryDraftSysIds.Contains(d.InventorySystemIdentifier) && d.IsCurrent && !d.Deleted)
                    .Select(d => d.SystemIdentifier)
                    .ToListAsync();
                foreach (Guid sysId in documentDraftSysIds)
                {
                    var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId);
                }

                var digitalObjectDraftSysIds = await _context.DigitalObjectDrafts
                    .Where(d => inventoryDraftSysIds.Contains(d.InventorySystemIdentifier) && d.IsCurrent && !d.Deleted)
                    .Select(d => d.SystemIdentifier)
                    .ToListAsync();
                foreach (Guid sysId in digitalObjectDraftSysIds)
                {
                    var digitalObjectSysId = await _digitalObjectService.CreateOrUpdateDigitalObjectFromDraftInternalAsync(sysId, true);
                }

                await _context.SaveAsync("Create entites from drafts");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }


        //public async Task<OperationResult> SendModificationsAffirmationResultAsync(ProcessStepModel model)
        //{
        //    if (model == null)
        //    {
        //        throw new ArgumentNullException(nameof(model));
        //    }

        //    var process = await _processService.GetProcessAsync(model.ProcessId);
        //    if (process == null)
        //    {
        //        return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
        //    }

        //    if (process.ProcessTypeId!.Value != (int)ProcessType.RefineData)
        //    {
        //        return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
        //    }
        //    if (process.Completed)
        //    {
        //        return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
        //    }
        //    if (model.StepTypeId != (int)ProcessStepType.RefineData_Affirmation
        //        && model.StepTypeId != (int)ProcessStepType.RefineData_ReportChangesRequired)
        //    {
        //        return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
        //    }

        //    using var transaction = _context.Database.BeginTransaction();
        //    try
        //    {
        //        var activeStepResult = await _processService.SetActiveProcessStepAsync(model);
        //        if (!activeStepResult.Succeeded)
        //        {
        //            transaction.Rollback();
        //            return activeStepResult;
        //        }

        //        int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);

        //        if (model.StepTypeId == (int)ProcessStepType.RefineData_ReportChangesRequired)
        //        {
        //            //Задача към експерта за искани промени.
        //            var task = new TaskCreateModel()
        //            {
        //                ProcessId = process.Id!.Value,
        //                TimelineId = activeStepId,
        //                //EntityId = GetEntityId(process),
        //                EntitySystemIdentifier = _processService.GetEntitySystemIdentifier(process),
        //                EntityType = _processService.GetEntityType(process),
        //                AssignedToUserId = process.CreatedBy?.ToString("D"),
        //                StepType = (Shared.ProcessStepType)model.StepTypeId,
        //            };
        //            var taskResult = await _taskService.CreateAsync(task);
        //            if (!taskResult.Succeeded)
        //            {
        //                transaction.Rollback();
        //                return taskResult;
        //            }
        //        }

        //        if (model.StepTypeId == (int)ProcessStepType.RefineData_Affirmation)
        //        {
        //            var roleA = await _roleManager.FindByNameAsync(ApplicationRoleType.GroupA, process.ArchiveId);
        //            if (roleA == null)
        //            {
        //                transaction.Rollback();
        //                return OperationResult.Failed($"Applicaiton Role {ApplicationRoleType.GroupA} does not exists in archive {process.ArchiveId}");
        //            }

        //            //Задача към регистратор за информация.
        //            var task = new TaskCreateModel()
        //            {
        //                ProcessId = process.Id!.Value,
        //                TimelineId = activeStepId,
        //                //EntityId = GetEntityId(process),
        //                EntitySystemIdentifier = _processService.GetEntitySystemIdentifier(process),
        //                EntityType = _processService.GetEntityType(process),
        //                AssignedToRoleId = roleA.Id.ToString("D"),
        //                StepType = (ProcessStepType)model.StepTypeId,
        //            };
        //            var taskResult = await _taskService.CreateAsync(task);
        //            if (!taskResult.Succeeded)
        //            {
        //                transaction.Rollback();
        //                return taskResult;
        //            }

        //            //Приключване на процеса
        //            activeStepResult = await _processService.SetActiveProcessStepAsync(process.Id.Value, (int)ProcessStepType.RefineData_ProcessFinalization);
        //            if (!activeStepResult.Succeeded)
        //            {
        //                transaction.Rollback();
        //                return activeStepResult;
        //            }

        //            await SetDataStatusAsync(process, Shared.Status.Refined);

        //            if (process.FundSystemIdentifier.HasValue)
        //            {
        //                bool hasDraft = await _fundService.HasCurrentDraftAsync(process.FundSystemIdentifier.Value);
        //                if (hasDraft)
        //                {
        //                    var fundSysId = await _fundService.CreateOrUpdateFundFromDraftInternalAsync(process.FundSystemIdentifier.Value);
        //                }

        //                var inventoryDraftSysIds = await _context.InventoryDrafts
        //                    .Where(inv => inv.FundSystemIdentifier == process.FundSystemIdentifier.Value && inv.IsCurrent && !inv.Deleted)
        //                    .Select(inv => inv.SystemIdentifier)
        //                    .ToListAsync();
        //                foreach (Guid sysId in inventoryDraftSysIds)
        //                {
        //                    var inventorySysId = await _inventoryService.CreateOrUpdateInventoryFromDraftInternalAsync(sysId);
        //                }

        //                var archivalEntityDraftSysIds = await _context.ArchivalEntityDrafts
        //                    .Where(ae => ae.FundSystemIdentifier == process.FundSystemIdentifier.Value && ae.IsCurrent && !ae.Deleted)
        //                    .Select(ae => ae.SystemIdentifier)
        //                    .ToListAsync();
        //                foreach (Guid sysId in archivalEntityDraftSysIds)
        //                {
        //                    var archivalEntitySysId = await _archivalEntityService.CreateOrUpdateArchivalEntityFromDraftInternalAsync(sysId);
        //                }

        //                var documentDraftSysIds = await _context.DocumentDrafts
        //                    .Where(d => d.FundSystemIdentifier == process.FundSystemIdentifier.Value && d.IsCurrent && !d.Deleted)
        //                    .Select(d => d.SystemIdentifier)
        //                    .ToListAsync();
        //                foreach (Guid sysId in documentDraftSysIds)
        //                {
        //                    var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId);
        //                }
        //            }

        //            if (process.InventorySystemIdentifier.HasValue)
        //            {
        //                bool hasDraft = await _inventoryService.HasCurrentDraftAsync(process.InventorySystemIdentifier.Value);
        //                if (hasDraft)
        //                {
        //                    var inventorySysId = await _inventoryService.CreateOrUpdateInventoryFromDraftInternalAsync(process.InventorySystemIdentifier.Value);
        //                }

        //                var archivalEntityDraftSysIds = await _context.ArchivalEntityDrafts
        //                    .Where(ae => ae.InventorySystemIdentifier == process.InventorySystemIdentifier.Value && ae.IsCurrent && !ae.Deleted)
        //                    .Select(ae => ae.SystemIdentifier)
        //                    .ToListAsync();
        //                foreach (Guid sysId in archivalEntityDraftSysIds)
        //                {
        //                    var archivalEntitySysId = await _archivalEntityService.CreateOrUpdateArchivalEntityFromDraftInternalAsync(sysId);
        //                }

        //                var documentDraftSysIds = await _context.DocumentDrafts
        //                    .Where(d => d.InventorySystemIdentifier == process.InventorySystemIdentifier.Value && d.IsCurrent && !d.Deleted)
        //                    .Select(d => d.SystemIdentifier)
        //                    .ToListAsync();
        //                foreach (Guid sysId in documentDraftSysIds)
        //                {
        //                    var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId);
        //                }
        //            }

        //            if (process.ArchivalEntitySystemIdentifier.HasValue)
        //            {
        //                bool hasDraft = await _archivalEntityService.HasCurrentDraftAsync(process.ArchivalEntitySystemIdentifier.Value);
        //                if (hasDraft)
        //                {
        //                    var archivalEntitySysId = await _archivalEntityService.CreateOrUpdateArchivalEntityFromDraftInternalAsync(process.ArchivalEntitySystemIdentifier.Value);
        //                }

        //                var documentDraftSysIds = await _context.DocumentDrafts
        //                    .Where(d => d.ArchivalEntitySystemIdentifier == process.ArchivalEntitySystemIdentifier.Value && d.IsCurrent && !d.Deleted)
        //                    .Select(d => d.SystemIdentifier)
        //                    .ToListAsync();
        //                foreach (Guid sysId in documentDraftSysIds)
        //                {
        //                    var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId);
        //                }
        //            }

        //            if (process.DocumentSystemIdentifier.HasValue)
        //            {
        //                bool hasDraft = await _documentService.HasCurrentDraftAsync(process.DocumentSystemIdentifier.Value);
        //                if (hasDraft)
        //                {
        //                    var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(process.DocumentSystemIdentifier.Value);
        //                }
        //            }

        //            var processCompleteResult = await _processService.CompleteProcessAsync(process.Id.Value);
        //            if (!processCompleteResult.Succeeded)
        //            {
        //                transaction.Rollback();
        //                return processCompleteResult;
        //            }
        //        }

        //        transaction.Commit();
        //        return OperationResult.Succeed(activeStepId);
        //    }
        //    catch (ItemDraftNotCurrentException exc)
        //    {
        //        transaction.Rollback();
        //        return OperationResult.Failed(exc.ToString());
        //    }
        //    catch (ItemNotFoundException exc)
        //    {
        //        transaction.Rollback();
        //        return OperationResult.Failed(exc.ToString());
        //    }
        //    catch (Exception exc)
        //    {
        //        transaction.Rollback();
        //        return OperationResult.Failed(exc.ToString());
        //    }
        //}

        public async Task<OperationResult> CompleteProcess(int processId)
        {
            using var transaction = _context.Database.BeginTransaction();

            try
            {
                //get process data 
                var process = await _processService.GetProcessAsync(processId);

                var validateProcessResult =
                    _processService.ValidateProcess(
                        process,
                        ProcessType.AddFundAndInventory,
                        ProcessType.AddInventory,
                        ProcessType.AddRawFundAndRawInventory,
                        ProcessType.AddRawInventory,
                        ProcessType.AddRawInventoryToRawFund,
                        ProcessType.AddSystemInventory);
                if (!validateProcessResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessResult;
                }

                //get active step
                var processStep = await _processService.GetProcessStepAsync(process!.ActiveProcessStepId!.Value);

                var validateProcessStepResult = _processService.ValidateProcessStep(process, processStep, ProcessStepType.Registration);
                if (!validateProcessStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessStepResult;
                }

                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)processStep.StepTypeId, processId, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return completePrevTaskResult;
                }

                //get application data
                var application = await (from i in _context.InventoryDrafts
                                         where ((process.FundSystemIdentifier.HasValue && i.FundSystemIdentifier == process.FundSystemIdentifier.Value)
                                                || (process.InventorySystemIdentifier.HasValue && i.SystemIdentifier == process.InventorySystemIdentifier.Value))
                                         && i.IsCurrent
                                         && !i.Deleted
                                         select i.Application).FirstOrDefaultAsync();
                if (application != null)
                {
                    application.StatusId = (int)ApplicationStatus.RegistrationComplete;
                    await _context.SaveAsync("Application updated");

                    //TODO Send notification to applicant
                }

                var nextStepResult = await _processService.MoveToNextStep(new ProcessStepModel { ProcessId = processId });
                if (!nextStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return nextStepResult;
                }

                //Process system inventory for Memory or ChP
                var processSystemInventoryResult = await ProcessSystemInventoryData(process!);
                if (!processSystemInventoryResult.Succeeded)
                {
                    transaction.Rollback();
                    return processSystemInventoryResult;
                }

                var result = await CompleteProcessCoreAsync(processId);
                if (!result.Succeeded)
                {
                    transaction.Rollback();
                    return result;
                }

                //int? applicationId;
                //if (process.FundSystemIdentifier.HasValue)
                //{
                //    //applicationId = _context.FundDrafts.Where(x => x.SystemIdentifier == process.FundSystemIdentifier)
                //    //                                    .Select(x => x.InventoryDrafts.FirstOrDefault().ApplicationId)
                //    //                                    .FirstOrDefault();
                //    applicationId = _context.InventoryDrafts
                //                        .Where(x => x.FundSystemIdentifier == process.FundSystemIdentifier.Value && !x.Deleted)
                //                        .Select(x => x.ApplicationId)
                //                        .FirstOrDefault();
                //}
                //else
                //{
                //    applicationId = _context.InventoryDrafts
                //                            .Where(x => x.SystemIdentifier == process.InventorySystemIdentifier && !x.Deleted)
                //                            .Select(x => x.ApplicationId)
                //                            .SingleOrDefault();
                //}

                //if (applicationId.HasValue)
                //{
                //    var application = await _context.EdocsCollectingApplications.FindAsync(applicationId);
                //    if (application != null)
                //    {
                //        application.StatusId = (int)ApplicationStatus.RegistrationComplete;
                //        await _context.SaveAsync("");
                //    }
                //}

                transaction.Commit();

                return OperationResult.Success;
            }
            catch (Exception x)
            {
                transaction.Rollback();
                _logger.LogError(x, "Error Completing process", new { processId });
                return OperationResult.Failed(x.ToString());
            }
        }

        private async Task<OperationResult> ProcessSystemInventoryData(ProcessModel process)
        {
            if (process == null)
            {
                throw new ArgumentNullException(nameof(process));
            }

            try
            {
                var inventoryDraft = await _context.InventoryDrafts
                                        .Where(inv => (
                                                (process.InventorySystemIdentifier.HasValue && inv.SystemIdentifier == process.InventorySystemIdentifier)
                                                    || (process.FundSystemIdentifier.HasValue && inv.FundSystemIdentifier == process.FundSystemIdentifier))
                                                && inv.DescriptionLevelCode == Shared.InventoryDescriptionLevel.SystemInventory.ToString("D")
                                                && inv.IsCurrent
                                                && !inv.Deleted)
                                        .FirstOrDefaultAsync();
                if (inventoryDraft != null)
                {
                    //Create system AE
                    var archivalEntitySysId = await _archivalEntityService.CreateDraftInternalAsync(
                        new ArchivalEntityDraftModel()
                        {
                            ArchiveId = inventoryDraft.ArchiveId,
                            FundDraftId = inventoryDraft.FundDraftId,
                            FundSystemIdentifier = inventoryDraft.FundSystemIdentifier,
                            InventoryDraftId = inventoryDraft.Id,
                            InventorySystemIdentifier = inventoryDraft.SystemIdentifier,
                            StatusCode = Shared.Status.New,
                            AvailabilityStatusCode = (int)Shared.AvailabilityStatus.Enrollment,
                            ApproximateChronologicalScope = inventoryDraft.ApproxmateChronologicalScope,
                            DescriptionLevelCode = Shared.ArchivalEntityDescriptionLevel.SystemArchivalEntity.ToString("D"),
                            HasNoChronologicalScope = inventoryDraft.HasNoChronologicalScope,
                            StartDateDay = inventoryDraft.StartDateDay,
                            StartDateMonth = inventoryDraft.StartDateMonth,
                            StartDateYear = inventoryDraft.StartDateYear,
                            EndDateDay = inventoryDraft.EndDateDay,
                            EndDateMonth = inventoryDraft.EndDateMonth,
                            EndDateYear = inventoryDraft.EndDateYear,
                            IsCurrent = true,
                            IsImported = false,
                            Number = "1",
                            NumberNumeric = 1,
                        });

                    var archivalEntityDraft = await _archivalEntityService.GetCurrentDraftAsync(archivalEntitySysId);

                    var packageDocuments = _packageService.GetPackageDocumentsByIdInternal(inventoryDraft.PackageBid!.Value);

                    foreach (var packageDocument in packageDocuments)
                    {
                        var documentSysId = await _documentService.CreateDraftInternalAsync(new DocumentDraftModel()
                        {
                            ArchiveId = archivalEntityDraft!.ArchiveId,
                            FundSystemIdentifier = archivalEntityDraft.FundSystemIdentifier,
                            FundDraftId = archivalEntityDraft.FundDraftId,
                            InventoryDraftId = archivalEntityDraft.InventoryDraftId,
                            InventorySystemIdentifier = archivalEntityDraft.InventorySystemIdentifier,
                            ArchivalEntityDraftId = archivalEntityDraft.Id,
                            ArchivalEntitySystemIdentifier = archivalEntityDraft.SystemIdentifier,
                            ApproximateChronologicalScope = archivalEntityDraft!.ApproximateChronologicalScope,
                            AvailabilityStatusCode = (int)Shared.AvailabilityStatus.Enrollment,
                            StartDateDay = archivalEntityDraft.StartDateDay,
                            StartDateMonth = archivalEntityDraft.StartDateMonth,
                            StartDateYear = archivalEntityDraft.StartDateYear,
                            EndDateDay = archivalEntityDraft.EndDateDay,
                            EndDateMonth = archivalEntityDraft.EndDateMonth,
                            EndDateYear = archivalEntityDraft.EndDateYear,
                            IsCurrent = true,
                            IsImported = false,
                            HasNoChronologicalScope = archivalEntityDraft.HasNoChronologicalScope,
                            DescriptionLevelCode = Shared.DocumentDescriptionLevel.SystemDocument.ToString("D"),
                            StatusCode = Shared.Status.New,
                            Title = packageDocument.FileName,
                        });

                        var digitalObjectSysId = await _digitalObjectService.CreateDraftInternalAsync(new DigitalObjectDraftModel()
                        {
                            ArchiveId = archivalEntityDraft!.ArchiveId,
                            FundSystemIdentifier = archivalEntityDraft.FundSystemIdentifier,
                            FundDraftId = archivalEntityDraft.FundDraftId,
                            InventoryDraftId = archivalEntityDraft.InventoryDraftId,
                            InventorySystemIdentifier = archivalEntityDraft.InventorySystemIdentifier,
                            ArchivalEntityDraftId = archivalEntityDraft.Id,
                            ArchivalEntitySystemIdentifier = archivalEntityDraft.SystemIdentifier,
                            DocumentSystemIdentifier = documentSysId,
                            IsCurrent = true,
                            IsImported = false,
                            PackageDocumentId = packageDocument.Id,
                            ContentType = packageDocument.ContentType,
                            FileSize = packageDocument.FileSizeInBytes!.Value,
                            FileType = packageDocument.FileType,
                            HashCode = packageDocument.HashCode,
                            Name = packageDocument.FileId,
                            SourceName = packageDocument.FileName,
                            StatusCode = Shared.Status.New,
                            TypeCode = (int)Shared.DigitalObjectType.MasterFile,
                            UncPath = packageDocument.FilePath,
                        }, true);
                    }
                }
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error processing system inventory data for process {process.Id}");
                return OperationResult.Failed(exc.ToString());
            }
        }

        private async Task<OperationResult> CompleteProcessCoreAsync(int processId)
        {
            var process = await _processService.GetProcessAsync(processId);

            var processResult = _processService.ValidateProcess(
                                    process,
                                    ProcessType.AddInventory,
                                    ProcessType.AddRawInventory,
                                    ProcessType.AddRawInventoryToRawFund,
                                    ProcessType.AddFundAndInventory,
                                    ProcessType.AddRawFundAndRawInventory,
                                    ProcessType.AddSystemInventory);
            if (!processResult.Succeeded)
            {
                return processResult;
            }

            var activeStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)Shared.ProcessStepType.RefineData_ProcessFinalization);
            if (!activeStepResult.Succeeded)
            {
                return activeStepResult;
            }

            if (process!.FundSystemIdentifier.HasValue)
            {
                if (await _inventoryService.AnyUnnumberedDraftsByFundIdentifier(process.FundSystemIdentifier!.Value))
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_UnnumberedInventories").ToString());
                }
                if (await _archivalEntityService.AnyUnnumberedDraftsByFundIdentifier(process.FundSystemIdentifier.Value))
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_UnnumberedArchivalEntities").ToString());
                }
                if (await _documentService.AnyUnnumberedDraftsByFundIdentifier(process.FundSystemIdentifier.Value))
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_UnnumberedDocuments").ToString());
                }

                var fundDraft = await _context.FundDrafts
                        .Where(x => x.SystemIdentifier == process.FundSystemIdentifier.Value && x.IsCurrent && !x.Deleted)
                        .FirstOrDefaultAsync();

                if (fundDraft != null)
                {
                    if (string.IsNullOrWhiteSpace(fundDraft.Number))
                    {
                        return OperationResult.Failed(false, _localizer.GetString("Error_UnnumberedFund").ToString());
                    }

                    fundDraft.StatusCode = Shared.Status.Registered;
                    _context.Update(fundDraft);
                    await _context.SaveAsync("Register fund");

                    var fundSysId = await _fundService.CreateOrUpdateFundFromDraftInternalAsync(process.FundSystemIdentifier.Value, true, true);
                }

                await _context.InventoryDrafts
                    .Where(inv => inv.FundSystemIdentifier == process.FundSystemIdentifier.Value && inv.IsCurrent && !inv.Deleted)
                    .ForEachAsync(inventoryDraft =>
                    {
                        inventoryDraft.StatusCode = Shared.Status.Registered;
                    });
                await _context.SaveAsync("Register inventory");

                var inventoryDraftSysIds = await _context.InventoryDrafts
                    .Where(inv => inv.FundSystemIdentifier == process.FundSystemIdentifier.Value && inv.IsCurrent && !inv.Deleted)
                    .Select(inv => inv.SystemIdentifier)
                    .ToListAsync();
                foreach (Guid sysId in inventoryDraftSysIds)
                {
                    var inventorySysId = await _inventoryService.CreateOrUpdateInventoryFromDraftInternalAsync(sysId);
                }

                await _context.ArchivalEntityDrafts
                    .Where(ae => ae.FundSystemIdentifier == process.FundSystemIdentifier.Value && ae.IsCurrent && !ae.Deleted)
                    .ForEachAsync(archivalEntityDraft =>
                    {
                        archivalEntityDraft.StatusCode = Shared.Status.Registered;
                    });
                await _context.SaveAsync("Register archival entity");

                var archivalEntityDraftSysIds = await _context.ArchivalEntityDrafts
                    .Where(ae => ae.FundSystemIdentifier == process.FundSystemIdentifier.Value && ae.IsCurrent && !ae.Deleted)
                    .Select(ae => ae.SystemIdentifier)
                    .ToListAsync();
                foreach (Guid sysId in archivalEntityDraftSysIds)
                {
                    var archivalEntitySysId = await _archivalEntityService.CreateOrUpdateArchivalEntityFromDraftInternalAsync(sysId);
                }

                await _context.DocumentDrafts
                    .Where(d => d.FundSystemIdentifier == process.FundSystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                    .ForEachAsync(documentDraft =>
                    {
                        documentDraft.StatusCode = Shared.Status.Registered;
                    });
                await _context.SaveAsync("Register document");

                var documentDraftSysIds = await _context.DocumentDrafts
                    .Where(d => d.FundSystemIdentifier == process.FundSystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                    .Select(d => d.SystemIdentifier)
                    .ToListAsync();
                foreach (Guid sysId in documentDraftSysIds)
                {
                    var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId);
                }

                await _context.DigitalObjectDrafts
                    .Where(d => d.FundSystemIdentifier == process.FundSystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                    .ForEachAsync(digitalObjectDraft =>
                    {
                        digitalObjectDraft.StatusCode = Shared.Status.Registered;
                    });
                await _context.SaveAsync("Register digital object");

                var digitalObjectDraftSysIds = await _context.DigitalObjectDrafts
                    .Where(d => d.FundSystemIdentifier == process.FundSystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                    .Select(d => d.SystemIdentifier)
                    .ToListAsync();
                foreach (Guid sysId in digitalObjectDraftSysIds)
                {
                    var digitalObjectSysId = await _digitalObjectService.CreateOrUpdateDigitalObjectFromDraftInternalAsync(sysId, true);
                }
            }

            if (process.InventorySystemIdentifier.HasValue)
            {
                if (await _archivalEntityService.AnyUnnumberedDraftsByInventoryIdentifier(process.InventorySystemIdentifier.Value))
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_UnnumberedArchivalEntities").ToString());
                }
                if (await _documentService.AnyUnnumberedDraftsByInventoryIdentifier(process.InventorySystemIdentifier.Value))
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_UnnumberedDocuments").ToString());
                }

                //var inventoryDraft = await _inventoryService.GetCurrentDraftAsync(process.InventorySystemIdentifier.Value);
                var inventoryDraft = await _context.InventoryDrafts
                        .Where(inv => inv.SystemIdentifier == process.InventorySystemIdentifier.Value && inv.IsCurrent && !inv.Deleted)
                        .FirstOrDefaultAsync();
                if (inventoryDraft != null)
                {
                    if (string.IsNullOrWhiteSpace(inventoryDraft.Number))
                    {
                        return OperationResult.Failed(false, _localizer.GetString("Error_UnnumberedInventory").ToString());
                    }

                    inventoryDraft.StatusCode = Shared.Status.Registered;
                    _context.Update(inventoryDraft);
                    await _context.SaveAsync("Inventory registered");

                    var inventorySysId = await _inventoryService.CreateOrUpdateInventoryFromDraftInternalAsync(process.InventorySystemIdentifier.Value);
                }

                await _context.ArchivalEntityDrafts
                    .Where(ae => ae.InventorySystemIdentifier == process.InventorySystemIdentifier.Value && ae.IsCurrent && !ae.Deleted)
                    .ForEachAsync(archivelEntityDraft =>
                    {
                        archivelEntityDraft.StatusCode = Shared.Status.Registered;
                    });
                await _context.SaveAsync("Archival entity registered");

                var archivalEntityDraftSysIds = await _context.ArchivalEntityDrafts
                    .Where(ae => ae.InventorySystemIdentifier == process.InventorySystemIdentifier.Value && ae.IsCurrent && !ae.Deleted)
                    .Select(ae => ae.SystemIdentifier)
                    .ToListAsync();
                foreach (Guid sysId in archivalEntityDraftSysIds)
                {
                    var archivalEntitySysId = await _archivalEntityService.CreateOrUpdateArchivalEntityFromDraftInternalAsync(sysId);
                }

                await _context.DocumentDrafts
                    .Where(d => d.InventorySystemIdentifier == process.InventorySystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                    .ForEachAsync(documentDraft =>
                    {
                        documentDraft.StatusCode = Shared.Status.Registered;
                    });
                await _context.SaveAsync("Document registered");

                var documentDraftSysIds = await _context.DocumentDrafts
                    .Where(d => d.InventorySystemIdentifier == process.InventorySystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                    .Select(d => d.SystemIdentifier)
                    .ToListAsync();
                foreach (Guid sysId in documentDraftSysIds)
                {
                    var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId);
                }

                await _context.DigitalObjectDrafts
                    .Where(d => d.InventorySystemIdentifier == process.InventorySystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                    .ForEachAsync(digitalObjectDraft =>
                    {
                        digitalObjectDraft.StatusCode = Shared.Status.Registered;
                    });
                await _context.SaveAsync("Digital object registered");

                var digitalObjectDraftSysIds = await _context.DigitalObjectDrafts
                    .Where(d => d.InventorySystemIdentifier == process.InventorySystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                    .Select(d => d.SystemIdentifier)
                    .ToListAsync();
                foreach (Guid sysId in digitalObjectDraftSysIds)
                {
                    var digitalObjectSysId = await _digitalObjectService.CreateOrUpdateDigitalObjectFromDraftInternalAsync(sysId, true);
                }
            }

            return await _processService.CompleteProcessAsync(processId);
        }

        public async Task<OperationResult> SendFundCreatorModificationRequestAsync(int processId, string comment)
        {
            if (!await IsExternalCollectingProcedure(processId))
            {
                _logger.LogError($"Process with id {processId} is not external collecting procedure");
                return OperationResult.Failed(false, _localizer.GetString("Error_CannotSendSignatureRequest", _localizer.GetString("Error_InternalProcess")).ToString());
            }

            var process = await _processService.GetProcessAsync(processId);

            var validateProcessResult =
                _processService.ValidateProcess(
                    process,
                    ProcessType.AddFundAndInventory,
                    ProcessType.AddInventory,
                    ProcessType.AddRawFundAndRawInventory,
                    ProcessType.AddRawInventory,
                    ProcessType.AddRawInventoryToRawFund,
                    ProcessType.AddSystemInventory);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }

            var processStep = await _processService.GetProcessStepAsync(process!.ActiveProcessStepId!.Value);

            var validateProcessStepResult = _processService.ValidateProcessStep(process, processStep, ProcessStepType.CommissionCorrections);
            if (!validateProcessStepResult.Succeeded)
            {
                return validateProcessStepResult;
            }

            var transaction = _context.Database.BeginTransaction();
            try
            {
                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)processStep.StepTypeId, processId, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
                }

                var application = await _applicationService.GetByProcessInternalAsync(processId);
                if (application == null)
                {
                    transaction.Rollback();
                    _logger.LogError($"Application missing for process with id {processId}");
                    return OperationResult.Failed(false, _localizer.GetString("Error_CannotSendModificationRequest", _localizer.GetString("Error_InternalProcess")).ToString());
                }

                //Add the modification reason as comment for history.
                var addCommentResult = await _commentsService.CreateAsync(new CommentModel()
                {
                    IsDraft = false,
                    ProcessId = process.Id,
                    ProcessStepId = process.ActiveProcessStepTypeId,
                    Text = comment,
                });
                if (!addCommentResult.Succeeded)
                {
                    transaction.Rollback();
                    _logger.LogError(addCommentResult.ToString());
                    return addCommentResult;
                }

                //Add the modification reason to the application.
                application.ModificationReason = comment;
                application.StatusId = (int)ApplicationStatus.ModificationRequest;

                _context.EdocsCollectingApplications.Update(application);
                await _context.SaveAsync("Application updated");

                // add event for notification
                await _notificationEventService.AddNotificationEvent(application.Id, Shared.NotificationType.RequestModification, null, application.CreatedBy);

                transaction.Commit();
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                _logger.LogError(exc, "Error sending signature request");
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> SendFundCreatorSignatureRequest(int processId, int packageId, IEnumerable<int> packageDocumentIds)
        {
            if (!await IsExternalCollectingProcedure(processId))
            {
                _logger.LogError($"Process with id {processId} is not external collecting procedure");
                return OperationResult.Failed(false, _localizer.GetString("Error_CannotSendSignatureRequest", _localizer.GetString("Error_InternalProcess")).ToString());
            }

            if (packageDocumentIds.Count() <= 0)
            {
                _logger.LogError($"No package documents to send for signature");
                return OperationResult.Failed(false, _localizer.GetString("Error_CannotSendSignatureRequest", _localizer.GetString("NoSelectedDocuments")).ToString());
            }

            var process = await _processService.GetProcessAsync(processId);

            var validateProcessResult =
                _processService.ValidateProcess(
                    process,
                    ProcessType.AddFundAndInventory,
                    ProcessType.AddInventory,
                    ProcessType.AddRawFundAndRawInventory,
                    ProcessType.AddRawInventory,
                    ProcessType.AddRawInventoryToRawFund,
                    ProcessType.AddSystemInventory);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }

            var processStep = await _processService.GetProcessStepAsync(process!.ActiveProcessStepId!.Value);

            var validateProcessStepResult = _processService.ValidateProcessStep(process, processStep, ProcessStepType.AcquisitionContract);
            if (!validateProcessStepResult.Succeeded)
            {
                return validateProcessStepResult;
            }

            var packageAId = await _packageService.GetPackageIdAByProcess(processId);
            if (!packageAId.HasValue || (packageAId.Value != packageId))
            {
                _logger.LogError($"Package with id {packageId} is not related to process with Id {processId}");
                return OperationResult.Failed($"Package with id {packageId} is not related to process with Id {processId}");
            }

            //TODO: Fix the validation
            //var packageDocuments = _packageService.GetPackageDocumentsById(packageId);

            //if (packageDocumentIds.All(pdoc => packageDocuments.Select(doc => doc.Id).Contains(pdoc)))
            //{
            //    _logger.LogError($"Not all documents are from package {packageId}");
            //    return OperationResult.Failed($"Not all documents are from package {packageId}");
            //}

            var transaction = _context.Database.BeginTransaction();
            try
            {
                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)processStep.StepTypeId, processId, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
                }

                var application = await _applicationService.GetByProcessInternalAsync(processId);
                if (application == null)
                {
                    transaction.Rollback();
                    _logger.LogError($"Application missing for process with id {processId}");
                    return OperationResult.Failed(false, _localizer.GetString("Error_CannotSendSignatureRequest", _localizer.GetString("Error_InternalProcess")).ToString());
                }

                var signatureRequests = packageDocumentIds.Select(pdid =>
                    new SignatureRequest()
                    {
                        ArchiveId = application!.ArchiveId,
                        ProcessId = processId,
                        ProcessStepId = process!.ActiveProcessStepId!.Value,
                        ApplicationId = application.Id,
                        PackageId = packageId,
                        PackageDocumentId = pdid,
                        SigningUserId = application.CreatedBy!.Value,
                    });

                _context.SignatureRequests.AddRange(signatureRequests);

                await _context.SaveAsync("Signature request created");

                application.StatusId = (int)ApplicationStatus.SignatureRequest;

                _context.EdocsCollectingApplications.Update(application);

                await _context.SaveAsync("Application updated");

                // add event for notification
                await _notificationEventService.AddNotificationEvent(application.Id, Shared.NotificationType.RequestSignature, null, application.CreatedBy);

                var nextStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)Shared.ProcessStepType.RequestSignature);
                if (!nextStepResult.Succeeded)
                {
                    transaction.Rollback();
                    _logger.LogError(nextStepResult.ToString());
                    return nextStepResult;
                }

                transaction.Commit();
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                _logger.LogError(exc, "Error sending signature request");
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> SendForRegistration(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                //get process data 
                var process = await _processService.GetProcessAsync(model.ProcessId);

                var validateProcessResult =
                    _processService.ValidateProcess(
                        process,
                        ProcessType.AddFundAndInventory,
                        ProcessType.AddInventory,
                        ProcessType.AddRawFundAndRawInventory,
                        ProcessType.AddRawInventory,
                        ProcessType.AddRawInventoryToRawFund,
                        ProcessType.AddSystemInventory);
                if (!validateProcessResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessResult;
                }

                //get active step
                var processStep = await _processService.GetProcessStepAsync(process!.ActiveProcessStepId!.Value);

                var validateProcessStepResult = _processService.ValidateProcessStep(process, processStep, ProcessStepType.SendForRegistration);
                if (!validateProcessStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessStepResult;
                }

                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)processStep.StepTypeId, model.ProcessId, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return completePrevTaskResult;
                }

                model.StepTypeId = (int)ProcessStepType.Registration;
                var nextStepResult = await _processService.SetActiveProcessStepAsync(model);
                if (!nextStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    _logger.LogError(nextStepResult.ToString());
                    return nextStepResult;
                }

                int nextStepId = (int)nextStepResult.Data!;

                string entityType = _processService.GetEntityType(process);
                Guid entityId = _processService.GetEntitySystemIdentifier(process);

                //Send tasks to Registrator
                TaskCreateModel taskModel = new()
                {
                    StepType = (ProcessStepType)model.StepTypeId,
                    ProcessId = process.Id,
                    TimelineId = nextStepId,
                    EntityType = entityType,
                    EntitySystemIdentifier = entityId,
                    AssignedToUserId = model.AssignedToUserId.HasValue ? model.AssignedToUserId.Value.ToString("D") : null,
                    AssignedToRoleId = model.AssignedToRoleId.HasValue ? model.AssignedToRoleId.Value.ToString("D") : null,
                };

                var taskResult = await _taskService.CreateAsync(taskModel);
                if (!taskResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    _logger.LogError(taskResult.ToString());
                    return taskResult;
                }

                await transaction.CommitAsync();

                return OperationResult.Success;
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                _logger.LogError(ex, "Error sending for registration");
                return OperationResult.Failed(ex.ToString());
            }
        }

        public async Task<bool> IsExternalCollectingProcedure(int processId)
        {
            var process = await _context.Processes.FindAsync(processId);
            int? applicationId;
            if (process.FundSystemIdentifier.HasValue)
            {
                applicationId = _context.FundDrafts.Where(x => x.SystemIdentifier == process.FundSystemIdentifier)
                                                   .Select(x => x.InventoryDrafts.FirstOrDefault().ApplicationId)
                                                   .FirstOrDefault();
            }
            else
            {
                applicationId = _context.InventoryDrafts
                                        .Where(x => x.SystemIdentifier == process.InventorySystemIdentifier && x.IsCurrent)
                                        .Select(x => x.ApplicationId)
                                        .SingleOrDefault();
            }

            return applicationId.HasValue;
        }

        public async Task<int?> GetApplicationStatusAsync(int processId)
        {
            var process = await _context.Processes.FindAsync(processId);

            if (process == null)
            {
                throw new ItemNotFoundException("Process does not exists", processId.ToString());
            }

            var applicationStatus =
                await _context.InventoryDrafts.Where(inv =>
                    inv.IsCurrent
                    && !inv.Deleted
                    && (process.InventorySystemIdentifier.HasValue
                            && inv.SystemIdentifier == process.InventorySystemIdentifier.Value)
                        || (process.FundSystemIdentifier.HasValue
                            && inv.FundSystemIdentifier == process.FundSystemIdentifier.Value))
                    .Select(inv => inv.Application != null ? inv.Application.StatusId : 0)
                    .FirstOrDefaultAsync();

            return applicationStatus;
        }

        public async Task<OperationResult> MoveToNextStepAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                //get process data 
                var process = await _processService.GetProcessAsync(model.ProcessId);

                var validateProcessResult =
                    _processService.ValidateProcess(
                        process,
                        ProcessType.AddFundAndInventory,
                        ProcessType.AddInventory,
                        ProcessType.AddRawFundAndRawInventory,
                        ProcessType.AddRawInventory,
                        ProcessType.AddRawInventoryToRawFund,
                        ProcessType.AddSystemInventory);
                if (!validateProcessResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return validateProcessResult;
                }

                //get active step
                var processStep = await _processService.GetProcessStepAsync(process!.ActiveProcessStepId!.Value);

                if (processStep == null)
                {
                    _logger.LogError($"Invalid active process step id or no active process step for process with id {process.Id}, activeProcessStepId: {process.ActiveProcessStepId}");
                    return OperationResult.Failed(false, _localizer.GetString("Error_NoActiveProcessStep").ToString());
                }

                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)processStep.StepTypeId, model.ProcessId, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return completePrevTaskResult;
                }

                //TODO Step Validation???

                var nextStepResult = await _processService.MoveToNextStep(processStep);
                if (!nextStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return nextStepResult;
                }

                if (nextStepResult.Data != null && (model.AssignedToUserId.HasValue || model.AssignedToRoleId.HasValue))
                {
                    string entityType = _processService.GetEntityType(process);
                    Guid entitySysId = _processService.GetEntitySystemIdentifier(process);

                    //Send tasks
                    TaskCreateModel taskModel = new()
                    {
                        StepType = (ProcessStepType)model.StepTypeId,
                        ProcessId = process.Id,
                        TimelineId = (int)nextStepResult.Data,
                        EntityType = entityType,
                        EntitySystemIdentifier = entitySysId,
                        AssignedToRoleId = model.AssignedToRoleId.HasValue ? model.AssignedToRoleId.Value.ToString("D") : null,
                        AssignedToUserId = model.AssignedToUserId.HasValue ? model.AssignedToUserId.Value.ToString("D") : null,
                    };

                    var taskResult = await _taskService.CreateAsync(taskModel);
                    if (!taskResult.Succeeded)
                    {
                        await transaction.RollbackAsync();
                        return taskResult;
                    }
                }

                await transaction.CommitAsync();

                return OperationResult.Success;
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return OperationResult.Failed(ex.ToString());
            }
        }
    }
}
