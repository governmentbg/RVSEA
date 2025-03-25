using DAA.Data;
using DAA.Extensions.Exceptions;
using DAA.Identity;
using DAA.Models.Funds;
using DAA.Models.Processes;
using DAA.Models.Tasks;
using DAA.Services.CommissionReports;
using DAA.Services.CommissionSessions;
using DAA.Services.Funds;
using DAA.Services.Process;
using DAA.Services.Tasks;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using System.Text;
using ProcessType = DAA.Shared.ProcessType;

namespace DAA.Services.EditFundDataProcess
{
    public class EditFundDataProcessService : BaseService, IEditFundDataProcessService
    {
        private readonly IUserInfo _userInfo;
        private readonly ApplicationRoleManager _roleManager;
        private readonly IFundService _fundService;
        private readonly IProcessService _processService;
        private readonly ITaskService _taskService;
        private readonly ISessionAgendaService _sessionAgendaService;
        private readonly ICommissionReportService _commissionReportService;

        public EditFundDataProcessService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IUserInfo userInfo,
            ApplicationRoleManager roleManager,
            IFundService fundService,
            IProcessService processService,
            ITaskService taskService,
            ISessionAgendaService sessionAgendaService,
            ICommissionReportService commissionReportService)
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _roleManager = roleManager;
            _fundService = fundService;
            _processService = processService;
            _taskService = taskService;
            _sessionAgendaService = sessionAgendaService;
            _commissionReportService = commissionReportService;
        }

        private bool IsCurrentUserProcessAuthor(ProcessDisplayModel process)
        {
            return (_userInfo.CurrentUserIsAdmin.HasValue && _userInfo.CurrentUserIsAdmin.Value)
                    || process.CreatedBy == _userInfo.CurrentUserId;
        }

        private bool IsCurrentUserInProcessStep(ProcessDisplayModel process)
        {
            //return (_userInfo.CurrentUserIsAdmin.HasValue && _userInfo.CurrentUserIsAdmin.Value)
            //        || process.IsCurrentUserInActiveProcessStep.HasValue && process.IsCurrentUserInActiveProcessStep.Value;
            return true;
        }

        private async Task<OperationResult> SetDataStatusAsync(ProcessModel process, string status)
        {
            try
            {
                var fund = await _fundService.GetFundBySystemIdentifierAsync(process.FundSystemIdentifier!.Value);
                if (fund == null)
                {
                    return OperationResult.Failed($"Fund {process.FundSystemIdentifier} does not exists.");
                }

                int? fundDraftId = fund.IsDraft ? fund.Id : null;

                if (fundDraftId.HasValue)
                {
                    var fundDraft = await _fundService.GetCurrentDraftAsync(process.FundSystemIdentifier!.Value);
                    if (fundDraft == null)
                    {
                        return OperationResult.Failed($"Fund {process.FundSystemIdentifier} has no current draft.");
                    }

                    //var modifiedFundDraft = new FundDraftModel()
                    //{
                    //    Id = fundDraft.Id,
                    //    IsCurrent = fundDraft.IsDraft,
                    //    ReadOnly = true,
                    //    SystemIdentifier = fundDraft.SystemIdentifier,
                    //    ArchiveId = fundDraft.ArchiveId,
                    //    NumberArray = fundDraft.NumberArray,
                    //    Number = fundDraft.Number,
                    //    Title = fundDraft.Title,
                    //    DescriptionLevelCode = fundDraft.DescriptionLevelCode,
                    //    TypeCode = fundDraft.TypeCode,
                    //    StatusCode = status,
                    //    AcquisitionMethodId = fundDraft.AcquisitionMethodId,
                    //    //AcquisitionMethodCodes = fundDraft.AcquisitionMethodCodes,
                    //    FileTypeCodes = fundDraft.FileTypeCodes,
                    //    IndustryTypeCodes = fundDraft.IndustryTypeCodes,
                    //    LanguageCodes = fundDraft.LanguageCodes,
                    //    HasNoChronologicalScope = fundDraft.HasNoChronologicalScope,
                    //    StartDateYear = fundDraft.StartDateYear,
                    //    StartDateMonth = fundDraft.StartDateMonth,
                    //    StartDateDay = fundDraft.StartDateDay,
                    //    EndDateYear = fundDraft.EndDateYear,
                    //    EndDateMonth = fundDraft.EndDateMonth,
                    //    EndDateDay = fundDraft.EndDateDay,
                    //    ApproxmateChronologicalScope = fundDraft.ApproxmateChronologicalScope,
                    //    Bytes = fundDraft.Bytes,
                    //    LinearMeters = fundDraft.LinearMeters,
                    //    OtherMetrics = fundDraft.OtherMetrics,
                    //    InventoryCount = fundDraft.InventoryCount,
                    //    ArchivalEntityCount = fundDraft.ArchivalEntityCount,
                    //    DocumentCount = fundDraft.DocumentCount,
                    //    FundCreatorTitleHistory = fundDraft.FundCreatorTitleHistory,
                    //    FundCreatorActivityHistory = fundDraft.FundCreatorActivityHistory,
                    //    FundCreatorBiographicalHistory = fundDraft.FundCreatorBiographicalHistory,
                    //    DocumentsProvider = fundDraft.DocumentsProvider,
                    //    DocumentsDescription = fundDraft.DocumentsDescription,
                    //    ValuableDocumentsInventoryCount = fundDraft.ValuableDocumentsInventoryCount,
                    //    InvaluableDocumentsInventoryCount = fundDraft.InvaluableDocumentsInventoryCount,
                    //    DocumentsAccessDescription = fundDraft.DocumentsAccessDescription,
                    //    History = fundDraft.History,
                    //    RelatedFunds = fundDraft.RelatedFunds,
                    //    Notes = fundDraft.Notes,
                    //    EnrolledBytes = fundDraft.EnrolledBytes,
                    //    EnrolledInventoryCount = fundDraft.EnrolledInventoryCount,
                    //    DeductedBytes = fundDraft.DeductedBytes,
                    //    DeductedInventoryCount = fundDraft.DeductedInventoryCount,
                    //    HasExternalSource = fundDraft.HasExternalSource,
                    //    ExternalIdentifier = fundDraft.ExternalIdentifier,
                    //};
                    var modifiedFundDraft = new FundDraftModel();
                    modifiedFundDraft.Assign(fundDraft);
                    modifiedFundDraft.IsCurrent = fundDraft.IsDraft;
                    modifiedFundDraft.ReadOnly = true;

                    var modifiedFundDraftId = await _fundService.UpdateDraftInternalAsync(modifiedFundDraft);
                }

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        private async Task<OperationResult> SetReadOnlyDataAsync(ProcessModel process, bool isReadOnly)
        {
            try
            {
                var fund = await _fundService.GetFundBySystemIdentifierAsync(process.FundSystemIdentifier!.Value);
                if (fund == null)
                {
                    return OperationResult.Failed($"Fund {process.FundSystemIdentifier} does not exists.");
                }

                int? fundDraftId = fund.IsDraft ? fund.Id : null;

                if (fundDraftId.HasValue)
                {
                    var fundDraft = await _fundService.GetCurrentDraftAsync(process.FundSystemIdentifier!.Value);
                    if (fundDraft == null)
                    {
                        return OperationResult.Failed($"Fund {process.FundSystemIdentifier} has no current draft.");
                    }

                    //var modifiedFundDraft = new FundDraftModel()
                    //{
                    //    Id = fundDraft.Id,
                    //    IsCurrent = fundDraft.IsDraft,
                    //    ReadOnly = isReadOnly,
                    //    SystemIdentifier = fundDraft.SystemIdentifier,
                    //    ArchiveId = fundDraft.ArchiveId,
                    //    NumberArray = fundDraft.NumberArray,
                    //    Number = fundDraft.Number,
                    //    Title = fundDraft.Title,
                    //    DescriptionLevelCode = fundDraft.DescriptionLevelCode,
                    //    TypeCode = fundDraft.TypeCode,
                    //    StatusCode = fundDraft.StatusCode,
                    //    AcquisitionMethodId= fundDraft.AcquisitionMethodId,
                    //    //AcquisitionMethodCodes = fundDraft.AcquisitionMethodCodes,
                    //    FileTypeCodes = fundDraft.FileTypeCodes,
                    //    IndustryTypeCodes = fundDraft.IndustryTypeCodes,
                    //    LanguageCodes = fundDraft.LanguageCodes,
                    //    HasNoChronologicalScope = fundDraft.HasNoChronologicalScope,
                    //    StartDateYear = fundDraft.StartDateYear,
                    //    StartDateMonth = fundDraft.StartDateMonth,
                    //    StartDateDay = fundDraft.StartDateDay,
                    //    EndDateYear = fundDraft.EndDateYear,
                    //    EndDateMonth = fundDraft.EndDateMonth,
                    //    EndDateDay = fundDraft.EndDateDay,
                    //    ApproxmateChronologicalScope = fundDraft.ApproxmateChronologicalScope,
                    //    Bytes = fundDraft.Bytes,
                    //    LinearMeters = fundDraft.LinearMeters,
                    //    OtherMetrics = fundDraft.OtherMetrics,
                    //    InventoryCount = fundDraft.InventoryCount,
                    //    ArchivalEntityCount = fundDraft.ArchivalEntityCount,
                    //    DocumentCount = fundDraft.DocumentCount,
                    //    FundCreatorTitleHistory = fundDraft.FundCreatorTitleHistory,
                    //    FundCreatorActivityHistory = fundDraft.FundCreatorActivityHistory,
                    //    FundCreatorBiographicalHistory = fundDraft.FundCreatorBiographicalHistory,
                    //    DocumentsProvider = fundDraft.DocumentsProvider,
                    //    DocumentsDescription = fundDraft.DocumentsDescription,
                    //    ValuableDocumentsInventoryCount = fundDraft.ValuableDocumentsInventoryCount,
                    //    InvaluableDocumentsInventoryCount = fundDraft.InvaluableDocumentsInventoryCount,
                    //    DocumentsAccessDescription = fundDraft.DocumentsAccessDescription,
                    //    History = fundDraft.History,
                    //    RelatedFunds = fundDraft.RelatedFunds,
                    //    Notes = fundDraft.Notes,
                    //    EnrolledBytes = fundDraft.EnrolledBytes,
                    //    EnrolledInventoryCount = fundDraft.EnrolledInventoryCount,
                    //    DeductedBytes = fundDraft.DeductedBytes,
                    //    DeductedInventoryCount = fundDraft.DeductedInventoryCount,
                    //    HasExternalSource = fundDraft.HasExternalSource,
                    //    ExternalIdentifier = fundDraft.ExternalIdentifier,
                    //};
                    var modifiedFundDraft = new FundDraftModel();
                    modifiedFundDraft.Assign(fundDraft);
                    modifiedFundDraft.IsCurrent = fundDraft.IsDraft;
                    modifiedFundDraft.ReadOnly = isReadOnly;

                    var modifiedFundDraftId = await _fundService.UpdateDraftInternalAsync(modifiedFundDraft);
                }

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> StartProcessAsync(ProcessModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            if ((ProcessType)model.ProcessTypeId!.Value != ProcessType.EditFundData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(),""));
            }

            //Процесът не е за фонд
            if (!model.FundSystemIdentifier.HasValue)
            {
                return OperationResult.Failed($"Missing fund system identifier to start process type {model.ProcessTypeId}.");
            }

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var processResult = await _processService.StartProcessAsync(model);
                if (!processResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return processResult;
                }

                int.TryParse(processResult.Data!.ToString(), out int processId);

                var processStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.EditFundData_ProcessInitiation);
                if (!processStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return processStepResult;
                }

                processStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.EditFundData_EditData);
                if (!processStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return processStepResult;
                }

                await transaction.CommitAsync();
                return OperationResult.Succeed(processResult.Data!);
            }
            catch (Exception exc)
            {
                await transaction.RollbackAsync();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> CompleteProcessAsync(int processId)
        {

            var process = await _processService.GetProcessAsync(processId);
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.EditFundData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (!process.FundSystemIdentifier.HasValue)
            {
                return OperationResult.Failed($"Missing fund system identifier for process {processId}");
            }

            var activeStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)Shared.ProcessStepType.EditFundData_ProcessFinalization);
            if (!activeStepResult.Succeeded)
            {
                return activeStepResult;
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                bool hasDraft = await _fundService.HasCurrentDraftAsync(process.FundSystemIdentifier.Value);
                if (hasDraft)
                {
                    await _fundService.CreateOrUpdateFundFromDraftInternalAsync(process.FundSystemIdentifier.Value, false, true);
                }

                var processCompleteResult = await _processService.CompleteProcessAsync(processId);
                if (!processCompleteResult.Succeeded)
                {
                    transaction.Rollback();
                    return processCompleteResult;
                }

                transaction.Commit();
                return OperationResult.Success;
            }
            catch (ItemDraftNotCurrentException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
            catch (ItemNotFoundException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> UndoProcessChangesAsync(int processId)
        {
            var process = await _processService.GetProcessAsync(processId);

            var validateProcessResult = _processService.ValidateProcess(process, ProcessType.EditFundData);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }
            
            //Процесът не е за фонд
            if (!process!.FundSystemIdentifier.HasValue)
            {
                return OperationResult.Failed($"Missing fund system identifier for process {processId}");
            }

            //Не е активна коректната предходна стъпка
            if (process!.ActiveProcessStepTypeId != (int)ProcessStepType.EditFundData_EditData 
                && process!.ActiveProcessStepTypeId != (int)ProcessStepType.EditFundData_CreateReport)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ProcessStepNotActive", ProcessStepType.EditFundData_UndoChanges).ToString());
            }

            //Не е участник в процеса, който да изпълни стъпката
            //if ((!_userInfo.CurrentUserIsAdmin.HasValue || !_userInfo.CurrentUserIsAdmin!.Value) && _userInfo.CurrentUserId != process.CreatedBy)
            if (!IsCurrentUserProcessAuthor(process))
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_UserCannotExecuteAction").ToString());
            }

            var activeStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.EditFundData_UndoChanges);
            if (!activeStepResult.Succeeded)
            {
                return activeStepResult;
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var fund = await _fundService.GetFundBySystemIdentifierAsync(process.FundSystemIdentifier!.Value);
                if (fund == null)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                Guid fundSysId = process.FundSystemIdentifier.Value;
                int? fundDraftId = fund.IsDraft ? fund.Id : null;

                if (fundDraftId.HasValue)
                {
                    await _fundService.DeleteDraftInternalAsync(fundDraftId.Value);
                }

                var report = await _context.Epkreports
                                .Where(r => r.ProcessId == processId && !r.Deleted)
                                .Select(r => r)
                                .SingleOrDefaultAsync();
                if (report != null)
                {
                    await _commissionReportService.DeleteReportInternalAsync(report.Id);
                }
                
                activeStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)Shared.ProcessStepType.EditFundData_ProcessFinalization);
                if (!activeStepResult.Succeeded)
                {
                    return activeStepResult;
                }

                var processCompleteResult = await _processService.CompleteProcessAsync(processId);
                if (!processCompleteResult.Succeeded)
                {
                    transaction.Rollback();
                    return processCompleteResult;
                }

                transaction.Commit();
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> StartApplyingChangesAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            var validateProcessResult = _processService.ValidateProcess(process, ProcessType.EditFundData);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }

            //Не е активна коректната предходна стъпка
            if (process!.ActiveProcessStepTypeId != (int)ProcessStepType.EditFundData_ChangesRequired
                && process!.ActiveProcessStepTypeId != (int)ProcessStepType.EditFundData_ReportChangesRequired)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ProcessStepNotActive", ProcessStepType.EditFundData_UndoChanges).ToString());
            }

            //Грешна стъпка
            var validateProcessStepResult = _processService.ValidateProcessStep(process, model, ProcessStepType.EditFundData_EditData, ProcessStepType.EditFundData_DataModifications);
            //if (model.StepTypeId != (int)ProcessStepType.EditFundData_EditData
            //    && model.StepTypeId != (int)ProcessStepType.EditFundData_DataModifications)
            if (!validateProcessStepResult.Succeeded)
            {
                //return OperationResult.Failed(false, _localizer.GetString("Error_InvalidProcessStepType", model.StepTypeId, process!.ProcessTypeTitle!).ToString());
                return validateProcessStepResult;
            }

            //if (_userInfo.CurrentUserId != process!.CreatedBy)
            if (!IsCurrentUserProcessAuthor(process))
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_UserCannotExecuteAction").ToString());
            }

            var transaction = _context.Database.BeginTransaction();
            try
            {
                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)process.ActiveProcessStepTypeId, process.Id, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
                }

                var processStepResult = await _processService.SetActiveProcessStepAsync(model);
                if (!processStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return processStepResult;
                }

                int.TryParse(processStepResult.Data!.ToString(), out int activeStepId);

                transaction.Commit();
                return OperationResult.Succeed(activeStepId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> CreateReportAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            
            var validateProcessResult = _processService.ValidateProcess(process, ProcessType.EditFundData);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }

            //Процесът не е за фонд
            if (!process!.FundSystemIdentifier.HasValue)
            {
                return OperationResult.Failed($"Missing fund system identifier for process {model.ProcessId}");
            }

            //Грешна стъпка подадена
            var validateProcessStepResult = _processService.ValidateProcessStep(process, model, ProcessStepType.EditFundData_CreateReport);
            if (!validateProcessStepResult.Succeeded)
            {
                return validateProcessStepResult;
            }

            //Не е активна коректната предходна стъпка
            if (process!.ActiveProcessStepTypeId != (int)Shared.ProcessStepType.EditFundData_EditData)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ProcessStepNotActive", Shared.ProcessStepType.EditFundData_CreateReport).ToString());
            }

            //Не е участник в процеса, който да изпълни стъпката
            //if ((!_userInfo.CurrentUserIsAdmin.HasValue || !_userInfo.CurrentUserIsAdmin!.Value) && _userInfo.CurrentUserId != process.CreatedBy)
            if(!IsCurrentUserProcessAuthor(process))
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_UserCannotExecuteAction").ToString());
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var activeStepResult = await _processService.SetActiveProcessStepAsync(model);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                transaction.Commit();

                return OperationResult.Succeed(activeStepResult.Data!);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> SendReportAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);

            var validateProcessResult = _processService.ValidateProcess(process, ProcessType.EditFundData);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }

            //Процесът не е за фонд
            if (!process!.FundSystemIdentifier.HasValue)
            {
                return OperationResult.Failed($"Missing fund system identifier for process {model.ProcessId}");
            }
            
            //Грешна стъпка
            var validateProcessStepResult = _processService.ValidateProcessStep(process, model, ProcessStepType.EditFundData_SendReport);
            if (!validateProcessStepResult.Succeeded)
            {
                return validateProcessStepResult;
            }

            //Не е активна коректната предходна стъпка
            if (process!.ActiveProcessStepTypeId != (int)Shared.ProcessStepType.EditFundData_DataModifications
                && process!.ActiveProcessStepTypeId != (int)Shared.ProcessStepType.EditFundData_CreateReport)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ProcessStepNotActive", Shared.ProcessStepType.EditFundData_SendReport).ToString());
            }

            //Не е участник в процеса, който да изпълни стъпката
            //if ((!_userInfo.CurrentUserIsAdmin.HasValue || !_userInfo.CurrentUserIsAdmin!.Value) && _userInfo.CurrentUserId != process.CreatedBy)
            if(!IsCurrentUserProcessAuthor(process))
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_UserCannotExecuteAction").ToString());
            }
                        
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var report = await _commissionReportService.GetByProcessIdAsync(model.ProcessId);
                if (report == null)
                {
                    transaction.Rollback();
                    return OperationResult.Failed(false, _localizer.GetString("Error_ReportDoesNotExists", process!.ProcessTypeTitle!).ToString());
                }

                report.IsDraft = false;
                var updateReportResult = await _commissionReportService.UpdateAsync(report);
                if (!updateReportResult.Succeeded)
                {
                    transaction.Rollback();
                    return updateReportResult;
                }    

                await SetReadOnlyDataAsync(process!, true);

                //Приключва автоматично задачата от предходната стъпка
                var completeTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)process.ActiveProcessStepTypeId.Value, process.Id, string.Empty, null);
                if (!completeTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completeTaskResult;
                }

                var activeStepResult = await _processService.SetActiveProcessStepAsync(model);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);

                var task = new TaskCreateModel()
                {
                    ProcessId = process!.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = process.FundId,
                    EntitySystemIdentifier = process.FundSystemIdentifier,
                    EntityType = BusinessObjectType.Fund,
                    AssignedToUserId = model.AssignedToUserId?.ToString("D"),
                    StepType = (Shared.ProcessStepType)model.StepTypeId,
                    EndDate = model.EndDate,
                    
                };
                var taskResult = await _taskService.CreateAsync(task);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }

                transaction.Commit();

                return OperationResult.Succeed(activeStepId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        //public async Task<OperationResult> AddReportToSessionAgendaAsync(ProcessStepModel model)
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

        //    if (process.ProcessTypeId!.Value != (int)ProcessType.EditFundData)
        //    {
        //        return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
        //    }
        //    if (process.Completed)
        //    {
        //        return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
        //    }
        //    if (model.StepTypeId != (int)ProcessStepType.EditFundData_AddReportToSessionAgenda)
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

        //        transaction.Commit();

        //        return OperationResult.Succeed(activeStepResult.Data!);
        //    }
        //    catch (Exception exc)
        //    {
        //        transaction.Rollback();
        //        return OperationResult.Failed(exc.ToString());
        //    }
        //}

        public async Task<OperationResult> SendToAddStandpointAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            var validateProcessResult = _processService.ValidateProcess(process, ProcessType.EditFundData);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }

            //Процесът не е за фонд
            if (!process!.FundSystemIdentifier.HasValue)
            {
                return OperationResult.Failed($"Missing fund system identifier for process {model.ProcessId}");
            }

            //Грешна стъпка
            var validateProcessStepResult = _processService.ValidateProcessStep(process, model, ProcessStepType.EditFundData_SendToAddSessionAgendaStandpoint);
            if (!validateProcessStepResult.Succeeded)
            {
                return validateProcessStepResult;
            }

            //Не е активна коректната предходна стъпка
            if (process!.ActiveProcessStepTypeId != (int)ProcessStepType.EditFundData_SendReport)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ProcessStepNotActive", ProcessStepType.EditFundData_SendToAddSessionAgendaStandpoint).ToString());
            }

            //Не е участник в процеса, който да изпълни стъпката
            //if ((!_userInfo.CurrentUserIsAdmin.HasValue || !_userInfo.CurrentUserIsAdmin!.Value) 
            //    && process.IsCurrentUserInActiveProcessStep.HasValue && !process.IsCurrentUserInActiveProcessStep.Value)
            //if (process.IsCurrentUserInActiveProcessStep.HasValue && !process.IsCurrentUserInActiveProcessStep.Value)
            if (!IsCurrentUserInProcessStep(process))
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_UserCannotExecuteAction").ToString());
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var report = await _commissionReportService.GetByProcessIdAsync(model.ProcessId);
                if (report == null)
                {
                    transaction.Rollback();
                    return OperationResult.Failed(false, _localizer.GetString("Error_ReportDoesNotExists", process!.ProcessTypeTitle!).ToString());
                }

                //var sessionAgendaItem = await _sessionAgendaService.GetSessionAgendaItemByProcessAsync(model.ProcessId);
                //if (sessionAgendaItem == null)
                //{
                //    transaction.Rollback();
                //    return OperationResult.Failed(false, _localizer.GetString("Error_SessionAgendaItemDoesNotExists").ToString());
                //}
                //var sessionAgendaStandpoint = 
                //    await _sessionAgendaService.GetSessionAgendaItemStandpointByItemAsync(sessionAgendaItem.Id!.Value, _userInfo.CurrentUserId!.Value);
                //if (sessionAgendaStandpoint != null)
                //{
                //    sessionAgendaStandpoint.IsDraft = false;

                //    var standpointResult = await _sessionAgendaService.UpdateSessionAgendaItemStandpointAsync(sessionAgendaStandpoint);
                //    if (!standpointResult.Succeeded)
                //    {
                //        transaction.Rollback();
                //        return standpointResult;
                //    }
                //}

                //Приключва автоматично задачата от предходната стъпка
                var completeTaskResult = await _taskService.CompletePreviousTask(ProcessStepType.EditFundData_SendReport, process.Id, string.Empty, null);
                if (!completeTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completeTaskResult;
                }

                var activeStepResult = await _processService.SetActiveProcessStepAsync(model);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);

                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = process.FundId,
                    EntitySystemIdentifier = process.FundSystemIdentifier,
                    EntityType = BusinessObjectType.Fund,
                    AssignedToRoleId = model.AssignedToRoleId?.ToString("D"),
                    StepType = (ProcessStepType)model.StepTypeId,
                    EndDate = model.EndDate,

                };
                var taskResult = await _taskService.CreateAsync(task);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }

                if (!model.AssignedToUserId.HasValue)
                {
                    model.AssignedToUserId = _userInfo.CurrentUserId;
                }

                activeStepResult = await _processService.SetActiveProcessStepAsync(new ProcessStepModel()
                {
                    AssignedToRoleId = model.AssignedToRoleId,
                    AssignedToUserId = model.AssignedToUserId,
                    Comment = model.Comment,
                    EndDate = model.EndDate,
                    ProcessId = model.ProcessId,
                    StepTypeId = (int)ProcessStepType.EditFundData_AddSessionAgendaStandpoint
                });
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                transaction.Commit();

                return OperationResult.Succeed(activeStepId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> SendSessionAgendaStandpointAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (process.ProcessTypeId!.Value != (int)ProcessType.EditFundData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.EditFundData_AddSessionAgendaStandpoint)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                //var sessionAgendaItem = await _sessionAgendaService.GetSessionAgendaItemByProcessAsync(model.ProcessId);
                //if (sessionAgendaItem == null)
                //{
                //    transaction.Rollback();
                //    return OperationResult.Failed(false, _localizer.GetString("Error_SessionAgendaItemDoesNotExists").ToString());
                //}
                var sessionAgendaStandpoint =
                    await _sessionAgendaService.GetSessionAgendaItemStandpointByProcessAsync(process.Id!.Value, _userInfo.CurrentUserId!.Value);
                if (sessionAgendaStandpoint != null)
                {
                    sessionAgendaStandpoint.IsDraft = false;

                    var standpointResult = await _sessionAgendaService.UpdateSessionAgendaItemStandpointAsync(sessionAgendaStandpoint);
                    if (!standpointResult.Succeeded)
                    {
                        transaction.Rollback();
                        return standpointResult;
                    }
                }

                transaction.Commit();
                return OperationResult.Succeed(process.ActiveProcessStepId!.Value);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> SendToAddCommentAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);

            var validateProcessResult = _processService.ValidateProcess(process, ProcessType.EditFundData);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }

            //Не е активна коректната предходна стъпка
            if (process!.ActiveProcessStepTypeId != (int)ProcessStepType.EditFundData_AddSessionAgendaStandpoint)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ProcessStepNotActive", ProcessStepType.EditFundData_SendToAddSessionAgendaStandpointComment).ToString());
            }

            //Грешна стъпка
            var validateProcessStepResult = _processService.ValidateProcessStep(process, model, ProcessStepType.EditFundData_SendToAddSessionAgendaStandpointComment);
            if (!validateProcessStepResult.Succeeded)
            {
                return validateProcessStepResult;
            }

            //Не е участник в процеса, който да изпълни стъпката
            //if ((!_userInfo.CurrentUserIsAdmin.HasValue || !_userInfo.CurrentUserIsAdmin!.Value) 
            //    && process.IsCurrentUserInActiveProcessStep.HasValue && !process.IsCurrentUserInActiveProcessStep.Value)
            //if (process.IsCurrentUserInActiveProcessStep.HasValue && !process.IsCurrentUserInActiveProcessStep.Value)

            if (!IsCurrentUserInProcessStep(process))
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_UserCannotExecuteAction").ToString());
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                //Приключва автоматично задачата от предходната стъпка
                var completeTaskResult = await _taskService.CompletePreviousTask(ProcessStepType.EditFundData_AddSessionAgendaStandpoint, process.Id, string.Empty, null);
                if (!completeTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completeTaskResult;
                }

                completeTaskResult = await _taskService.CompletePreviousTask(ProcessStepType.EditFundData_SendToAddSessionAgendaStandpoint, process.Id, string.Empty, null);
                if (!completeTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completeTaskResult;
                }

                var activeStepResult = await _processService.SetActiveProcessStepAsync(model);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);

                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = process.FundId,
                    EntitySystemIdentifier = process.FundSystemIdentifier,
                    EntityType = BusinessObjectType.Fund,
                    AssignedToUserId = process.CreatedBy!.Value.ToString("D"),
                    StepType = (Shared.ProcessStepType)model.StepTypeId,
                };
                var taskResult = await _taskService.CreateAsync(task);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }

                transaction.Commit();

                return OperationResult.Succeed(activeStepId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> AddCommentToSessionAgendaStandpointAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            //if (process == null)
            //{
            //    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            //}

            //if (process.ProcessTypeId!.Value != (int)ProcessType.EditFundData)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            //}
            //if (process.Completed)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            //}
            //if (model.StepTypeId != (int)ProcessStepType.EditFundData_AddSessionAgendaStandpointComment)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            //}

            var validateProcessResult = _processService.ValidateProcess(process, ProcessType.EditFundData);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }

            //Не е активна коректната предходна стъпка
            if (process!.ActiveProcessStepTypeId != (int)ProcessStepType.EditFundData_SendToAddSessionAgendaStandpointComment)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ProcessStepNotActive", ProcessStepType.EditFundData_AddSessionAgendaStandpointComment).ToString());
            }

            //Грешна стъпка
            var validateProcessStepResult = _processService.ValidateProcessStep(process, model, ProcessStepType.EditFundData_AddSessionAgendaStandpointComment);
            if (!validateProcessStepResult.Succeeded)
            {
                return validateProcessStepResult;
            }

            //Не е участник в процеса, който да изпълни стъпката
            if (!IsCurrentUserProcessAuthor(process))
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_UserCannotExecuteAction").ToString());
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)process.ActiveProcessStepTypeId, process.Id, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
                }

                var activeStepResult = await _processService.SetActiveProcessStepAsync(model);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                transaction.Commit();

                return OperationResult.Succeed(activeStepResult.Data!);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> SendCommentAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            //if (process == null)
            //{
            //    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            //}

            //if (process.ProcessTypeId!.Value != (int)ProcessType.EditFundData)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            //}
            //if (process.Completed)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            //}
            //if (model.StepTypeId != (int)ProcessStepType.EditFundData_SendSessionAgendaStandpointComment)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            //}

            var validateProcessResult = _processService.ValidateProcess(process, ProcessType.EditFundData);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }

            //Не е активна коректната предходна стъпка
            if (process!.ActiveProcessStepTypeId != (int)ProcessStepType.EditFundData_AddSessionAgendaStandpointComment)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ProcessStepNotActive", ProcessStepType.EditFundData_SendSessionAgendaStandpointComment).ToString());
            }

            //Грешна стъпка
            var validateProcessStepResult = _processService.ValidateProcessStep(process, model, ProcessStepType.EditFundData_SendSessionAgendaStandpointComment);
            if (!validateProcessStepResult.Succeeded)
            {
                return validateProcessStepResult;
            }

            //Не е участник в процеса, който да изпълни стъпката
            if (!IsCurrentUserProcessAuthor(process))
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_UserCannotExecuteAction").ToString());
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                //Приключва автоматично задачата от предходната стъпка
                var completeTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)process.ActiveProcessStepTypeId.Value, process.Id, string.Empty, null);
                if (!completeTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completeTaskResult;
                }

                var sessionAgendaStep = await _processService.GetProcessStepAsync(process.Id!.Value, ProcessStepType.EditFundData_SendReport);
                var standpointStep = await _processService.GetProcessStepAsync(process.Id!.Value, ProcessStepType.EditFundData_SendToAddSessionAgendaStandpoint);

                if(!model.AssignedToUserId.HasValue)
                {
                    model.AssignedToUserId = sessionAgendaStep?.AssignedToUserId;
                }
                if (!model.AssignedToRoleId.HasValue)
                {
                    model.AssignedToRoleId = standpointStep?.AssignedToRoleId;
                }

                var activeStepResult = await _processService.SetActiveProcessStepAsync(model);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);
                                
                //Задача към секретар/председател на комисия
                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = process.FundId,
                    EntitySystemIdentifier = process.FundSystemIdentifier,
                    EntityType = BusinessObjectType.Fund,
                    AssignedToUserId = sessionAgendaStep?.AssignedToUserId!.Value.ToString("D"),
                    StepType = (ProcessStepType)model.StepTypeId,
                    EndDate = model.EndDate,

                };
                var taskResult = await _taskService.CreateAsync(task);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }
                //Задача към членовете на комисия
                task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = process.FundId,
                    EntitySystemIdentifier = process.FundSystemIdentifier,
                    EntityType = BusinessObjectType.Fund,
                    AssignedToRoleId = standpointStep?.AssignedToRoleId!.Value.ToString("D"),
                    StepType = (Shared.ProcessStepType)model.StepTypeId,
                    EndDate = model.EndDate,

                };
                taskResult = await _taskService.CreateAsync(task);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }

                transaction.Commit();

                return OperationResult.Succeed(activeStepId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> SetSessionAgendaItemAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            //if (process == null)
            //{
            //    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            //}

            //if (process.ProcessTypeId!.Value != (int)ProcessType.EditFundData)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            //}
            //if (process.Completed)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            //}
            //if (model.StepTypeId != (int)ProcessStepType.EditFundData_CommissionSession)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            //}
            var validateProcessResult = _processService.ValidateProcess(process, ProcessType.EditFundData);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }

            //Не е активна коректната предходна стъпка
            if (process!.ActiveProcessStepTypeId != (int)ProcessStepType.EditFundData_SendSessionAgendaStandpointComment)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ProcessStepNotActive", ProcessStepType.EditFundData_CommissionSession).ToString());
            }

            //Грешна стъпка
            var validateProcessStepResult = _processService.ValidateProcessStep(process, model, ProcessStepType.EditFundData_CommissionSession);
            if (!validateProcessStepResult.Succeeded)
            {
                return validateProcessStepResult;
            }

            //Не е участник в процеса, който да изпълни стъпката
            if (!IsCurrentUserInProcessStep(process))
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_UserCannotExecuteAction").ToString());
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                //Приключва автоматично задачата от предходната стъпка
                var completeTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)process.ActiveProcessStepTypeId.Value, process.Id, string.Empty, null);
                if (!completeTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completeTaskResult;
                }

                var activeStepResult = await _processService.SetActiveProcessStepAsync(model);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);

                //Задача към експерта, че е добавен за заседание
                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = process.FundId,
                    EntitySystemIdentifier = process.FundSystemIdentifier,
                    EntityType = BusinessObjectType.Fund,
                    AssignedToUserId = process.CreatedBy?.ToString("D"),
                    StepType = (Shared.ProcessStepType)model.StepTypeId,
                };
                var taskResult = await _taskService.CreateAsync(task);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }

                transaction.Commit();

                return OperationResult.Succeed(activeStepId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> SendReportApprovalResultAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            //if (process == null)
            //{
            //    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            //}

            //if (process.ProcessTypeId!.Value != (int)ProcessType.EditFundData)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            //}
            //if (process.Completed)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            //}
            //if (model.StepTypeId != (int)ProcessStepType.EditFundData_ChangesRequired
            //    && model.StepTypeId != (int)ProcessStepType.EditFundData_ReportApproval
            //    && model.StepTypeId != (int)ProcessStepType.EditFundData_ReportChangesRequired
            //    && model.StepTypeId != (int)ProcessStepType.EditFundData_ReportRejection)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            //}

            var validateProcessResult = _processService.ValidateProcess(process, ProcessType.EditFundData);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }

            //Не е активна коректната предходна стъпка
            if (process!.ActiveProcessStepTypeId != (int)ProcessStepType.EditFundData_SendReport
                && process!.ActiveProcessStepTypeId != (int)ProcessStepType.EditFundData_SessionMinutesOfMeeting
                && process!.ActiveProcessStepTypeId != (int)ProcessStepType.EditFundData_ModificationsRevision)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ProcessStepNotActive", model.StepTypeId).ToString());
            }

            //Грешна стъпка
            if (model.StepTypeId != (int)ProcessStepType.EditFundData_ChangesRequired
                && model.StepTypeId != (int)ProcessStepType.EditFundData_ReportApproval
                && model.StepTypeId != (int)ProcessStepType.EditFundData_ReportChangesRequired
                && model.StepTypeId != (int)ProcessStepType.EditFundData_ReportRejection)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            }

            //if (process.IsCurrentUserInActiveProcessStep.HasValue && !process.IsCurrentUserInActiveProcessStep.Value)
            if (!IsCurrentUserInProcessStep(process))
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_UserCannotExecuteAction").ToString());
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                //Приключва автоматично задачата от предходната стъпка
                var completeTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)process.ActiveProcessStepTypeId.Value, process.Id, string.Empty, null);
                if (!completeTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completeTaskResult;
                }

                var activeStepResult = await _processService.SetActiveProcessStepAsync(model);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);

                //Задача към експерта
                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = process.FundId,
                    EntitySystemIdentifier = process.FundSystemIdentifier,
                    EntityType = BusinessObjectType.Fund,
                    AssignedToUserId = process.CreatedBy?.ToString("D"),
                    StepType = (Shared.ProcessStepType)model.StepTypeId,
                };
                var taskResult = await _taskService.CreateAsync(task);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }

                transaction.Commit();
                return OperationResult.Succeed(activeStepId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> ApplyReportModificationsAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (process.ProcessTypeId!.Value != (int)ProcessType.EditFundData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.EditFundData_ReportModifications)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)process.ActiveProcessStepTypeId, process.Id, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
                }

                var activeStepResult = await _processService.SetActiveProcessStepAsync(model);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);

                var report = await _context.Epkreports
                            .Where(r => r.ProcessId == process.Id && !r.Deleted)
                            .Select(r => r)
                            .SingleOrDefaultAsync();

                if (report == null)
                {
                    transaction.Rollback();
                    return OperationResult.Failed($"Report for process {process.Id} does not exists.");
                }

                report.IsDraft = true;
                _context.Update(report);
                await _context.SaveAsync("EPK Report updated");

                await SetReadOnlyDataAsync(process, false);

                transaction.Commit();
                return OperationResult.Succeed(activeStepId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> SendForModificationsRevisionAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (process.ProcessTypeId!.Value != (int)ProcessType.EditFundData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.EditFundData_SendForModificationsRevision)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await SetReadOnlyDataAsync(process, true);

                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)process.ActiveProcessStepTypeId, process.Id, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
                }

                var activeStepResult = await _processService.SetActiveProcessStepAsync(model);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);

                //Задача към секретар/председател на комисия
                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = process.FundId,
                    EntitySystemIdentifier = process.FundSystemIdentifier,
                    EntityType = BusinessObjectType.Fund,
                    AssignedToUserId = model.AssignedToUserId!.Value.ToString("D"),
                    StepType = (Shared.ProcessStepType)model.StepTypeId,
                    EndDate = model.EndDate,

                };
                var taskResult = await _taskService.CreateAsync(task);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }
                

                transaction.Commit();
                return OperationResult.Succeed(activeStepId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> ModificationsRevisionAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (process.ProcessTypeId!.Value != (int)ProcessType.EditFundData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.EditFundData_ModificationsRevision)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)process.ActiveProcessStepTypeId, process.Id, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
                }

                var activeStepResult = await _processService.SetActiveProcessStepAsync(model);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);

                transaction.Commit();
                return OperationResult.Succeed(activeStepId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> SendForModificationAffirmationAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (process.ProcessTypeId!.Value != (int)ProcessType.EditFundData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.EditFundData_SendForAffirmation)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)process.ActiveProcessStepTypeId, process.Id, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
                }

                var activeStepResult = await _processService.SetActiveProcessStepAsync(model);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);

                //Задача към ръководителя на архива.
                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = process.FundId,
                    EntitySystemIdentifier = process.FundSystemIdentifier,
                    EntityType = BusinessObjectType.Fund,
                    AssignedToUserId = model.AssignedToUserId!.Value.ToString("D"),
                    StepType = (Shared.ProcessStepType)model.StepTypeId,
                    EndDate = model.EndDate,

                };
                var taskResult = await _taskService.CreateAsync(task);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }


                transaction.Commit();
                return OperationResult.Succeed(activeStepId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> SendModificationsAffirmationResultAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (process.ProcessTypeId!.Value != (int)ProcessType.EditFundData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.EditFundData_Affirmation
                && model.StepTypeId != (int)ProcessStepType.EditFundData_ReportChangesRequired)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)process.ActiveProcessStepTypeId, process.Id, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
                }

                var activeStepResult = await _processService.SetActiveProcessStepAsync(model);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);

                if (model.StepTypeId == (int)ProcessStepType.EditFundData_ReportChangesRequired)
                { 
                    //Задача към експерта за искани промени.
                    var task = new TaskCreateModel()
                    {
                        ProcessId = process.Id!.Value,
                        TimelineId = activeStepId,
                        EntityId = process.FundId,
                        EntitySystemIdentifier = process.FundSystemIdentifier,
                        EntityType = BusinessObjectType.Fund,
                        AssignedToUserId = process.CreatedBy?.ToString("D"),
                        StepType = (Shared.ProcessStepType)model.StepTypeId,
                    };
                    var taskResult = await _taskService.CreateAsync(task);
                    if (!taskResult.Succeeded)
                    {
                        transaction.Rollback();
                        return taskResult;
                    }
                }

                if (model.StepTypeId == (int)ProcessStepType.EditFundData_Affirmation)
                {
                    var roleA = await _roleManager.FindByNameAsync(ApplicationRoleType.GroupA, process.ArchiveId);
                    if (roleA == null)
                    {
                        transaction.Rollback();
                        return OperationResult.Failed($"Applicaiton Role {ApplicationRoleType.GroupA} does not exists in archive {process.ArchiveId}");
                    }

                    //Задача към регистратор за информация.
                    var task = new TaskCreateModel()
                    {
                        ProcessId = process.Id!.Value,
                        TimelineId = activeStepId,
                        EntityId = process.FundId,
                        EntitySystemIdentifier = process.FundSystemIdentifier,
                        EntityType = BusinessObjectType.Fund,
                        AssignedToRoleId = roleA.Id.ToString("D"),
                        StepType = (ProcessStepType)model.StepTypeId,
                    };
                    var taskResult = await _taskService.CreateAsync(task);
                    if (!taskResult.Succeeded)
                    {
                        transaction.Rollback();
                        return taskResult;
                    }

                    //Приключване на процеса
                    activeStepResult = await _processService.SetActiveProcessStepAsync(process.Id.Value, (int)ProcessStepType.EditFundData_ProcessFinalization);
                    if (!activeStepResult.Succeeded)
                    {
                        return activeStepResult;
                    }

                    await SetDataStatusAsync(process, Shared.Status.NameChanged);

                    bool hasDraft = await _fundService.HasCurrentDraftAsync(process.FundSystemIdentifier!.Value);
                    if (hasDraft)
                    {
                        await _fundService.CreateOrUpdateFundFromDraftInternalAsync(process.FundSystemIdentifier.Value, false, true);
                    }

                    var processCompleteResult = await _processService.CompleteProcessAsync(process.Id.Value);
                    if (!processCompleteResult.Succeeded)
                    {
                        transaction.Rollback();
                        return processCompleteResult;
                    }
                }

                transaction.Commit();
                return OperationResult.Succeed(activeStepId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }
    }
}
