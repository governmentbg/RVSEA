using DAA.Data;
using DAA.Extensions.Exceptions;
using DAA.Identity;
using DAA.Models.Processes;
using DAA.Models.Tasks;
using DAA.Services.ArchivalEntities;
using DAA.Services.CommissionReports;
using DAA.Services.CommissionSessions;
using DAA.Services.Documents;
using DAA.Services.FundReconstructions;
using DAA.Services.Funds;
using DAA.Services.Inventories;
using DAA.Services.Process;
using DAA.Services.Tasks;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using System.Text;
using ProcessType = DAA.Shared.ProcessType;

namespace DAA.Services.ReconstructFundDataProcess
{
    public class ReconstructFundDataProcessService : BaseService, IReconstructFundDataProcessService
    {
        private readonly IUserInfo _userInfo;
        private readonly ApplicationRoleManager _roleManager;
        private readonly IFundService _fundService;
        private readonly IInventoryService _inventoryService;
        private readonly IArchivalEntityService _archivalEntityService;
        private readonly IDocumentService _documentService;
        private readonly IProcessService _processService;
        private readonly ITaskService _taskService;
        private readonly ISessionAgendaService _sessionAgendaService;
        private readonly IFundReconstructionService _fundReconstructionService;
        private readonly ICommissionReportService _commissionReportService;

        public ReconstructFundDataProcessService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IUserInfo userInfo,
            ApplicationRoleManager roleManager,
            IFundService fundService,
            IInventoryService inventoryService,
            IArchivalEntityService archiveEntityService,
            IDocumentService documentService,
            IFundReconstructionService fundReconstructionService,
            IProcessService processService,
            ITaskService taskService,
            ISessionAgendaService sessionAgendaService,
            ICommissionReportService commissionReportService)
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _roleManager = roleManager;
            _fundService = fundService;
            _inventoryService = inventoryService;
            _archivalEntityService = archiveEntityService;
            _documentService = documentService;
            _fundReconstructionService= fundReconstructionService;
            _processService = processService;
            _taskService = taskService;
            _sessionAgendaService = sessionAgendaService;
            _commissionReportService= commissionReportService;
        }

        private OperationResult ValidateProcessData(ProcessDisplayModel? process, ProcessStepModel processStep, ProcessStepType stepType)
        {
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (process.ProcessTypeId!.Value != (int)ProcessType.ReconstructFundData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }

            if (processStep.StepTypeId != (int)stepType)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            }

            return OperationResult.Success;
        }

        private async Task<OperationResult> ModifyDataAccessAsync(ProcessDisplayModel process, bool suspendAccess)
        {
            try
            {
                var fund = await _context.Funds
                            .Where(f => f.SystemIdentifier == process.FundSystemIdentifier!.Value && !f.Deleted)
                            .SingleOrDefaultAsync();

                if (fund == null)
                {
                    return OperationResult.Failed($"Fund {process.FundSystemIdentifier} does not exists");
                }

                fund.IsSuspended = suspendAccess;
                _context.Update(fund);

                await _context.Inventories
                    .Where(inv => inv.FundSystemIdentifier == process.FundSystemIdentifier!.Value && !inv.Deleted)
                    .Select(inv => inv)
                    .ForEachAsync(inv => { inv.IsSuspended = suspendAccess; });

                await _context.ArchivalEntities
                    .Where(ae => ae.FundSystemIdentifier == process.FundSystemIdentifier!.Value && !ae.Deleted)
                    .Select(ae => ae)
                    .ForEachAsync(ae => { ae.IsSuspended = suspendAccess; });

                await _context.Documents
                    .Where(doc => doc.FundSystemIdentifier == process.FundSystemIdentifier!.Value && !doc.Deleted)
                    .Select(doc => doc)
                    .ForEachAsync(doc => { doc.IsSuspended = suspendAccess; });

                await _context.DigitalObjects
                    .Where(dig => dig.FundSystemIdentifier == process.FundSystemIdentifier!.Value && !dig.Deleted)
                    .Select(dig => dig)
                    .ForEachAsync(dig => { dig.IsSuspended = suspendAccess; });

                await _context.SaveAsync("Fund public access suspended");

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
                var fundDraft = await _context.FundDrafts
                                    .Where(f =>
                                        f.SystemIdentifier == process.FundSystemIdentifier!.Value
                                        && f.IsCurrent
                                        && !f.Deleted)
                                    .Select(f => f)
                                    .SingleOrDefaultAsync();

                int? fundDraftId = fundDraft != null ? fundDraft.Id : null;

                var documentDrafts = _context.DocumentDrafts
                                        .Where(d =>
                                            d.FundSystemIdentifier == process.FundSystemIdentifier!.Value
                                            && d.FundDraftId == fundDraftId
                                            && d.IsCurrent
                                            && !d.Deleted)
                                        .Select(d => d);
                await documentDrafts.ForEachAsync(d => { d.ReadOnly = isReadOnly; });

                await _context.SaveAsync("Document draft updated");

                var archivalEntityDrafts = _context.ArchivalEntityDrafts
                                                .Where(ae =>
                                                    ae.FundSystemIdentifier == process.FundSystemIdentifier!.Value
                                                    && ae.FundDraftId == fundDraftId
                                                    && ae.IsCurrent
                                                    && !ae.Deleted)
                                                .Select(ae => ae);
                await archivalEntityDrafts.ForEachAsync(ae => { ae.ReadOnly = isReadOnly; });

                await _context.SaveAsync("Archival entity draft updated");

                var inventoryDrafts = _context.InventoryDrafts
                                            .Where(inv =>
                                                inv.FundSystemIdentifier == process.FundSystemIdentifier!.Value
                                                && inv.FundDraftId == fundDraftId
                                                && inv.IsCurrent
                                                && !inv.Deleted)
                                            .Select(inv => inv);
                await inventoryDrafts.ForEachAsync(inv => { inv.ReadOnly = isReadOnly; });

                await _context.SaveAsync("Inventory draft updated");

                if (fundDraft != null)
                {
                    fundDraft.ReadOnly = isReadOnly;
                    _context.Update(fundDraft);

                    await _context.SaveAsync("Fund draft updated");
                }

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        private async Task<OperationResult> SetReadOnlyReportAsync(ProcessModel process, bool isReadOnly)
        {
            try
            {
                var report = await _context.Epkreports
                                .Where(r => r.ProcessId == process.Id && !r.Deleted)
                                .SingleOrDefaultAsync();
                if (report == null)
                {
                    return OperationResult.Failed(
                            false, 
                            _localizer.GetString("Error_ReportDoesNotExists", ((ProcessDisplayModel)process).ProcessTypeTitle!).ToString());
                }

                report.IsDraft= !isReadOnly;

                _context.Update(report);
                await _context.SaveAsync("EPK report updated");

                return OperationResult.Success;
            }
            catch (Exception exc) 
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        private async Task<OperationResult> UndoProcessChangesInternalAsync(ProcessModel process)
        {
            try
            { 
                await _context.FundReconstructions
                .Where(rec => rec.ProcessId == process.Id && !rec.Deleted)
                .ForEachAsync(rec => { rec.Deleted = true; rec.DeletedOn = DateTime.UtcNow; rec.DeletedBy = _userInfo.CurrentUserId; });

                await _context.SaveAsync("Fund reconstruction deleted");

                var fund = await _fundService.GetFundBySystemIdentifierAsync(process.FundSystemIdentifier!.Value);
                if (fund == null)
                {
                    return OperationResult.Failed($"Fund {process.FundSystemIdentifier} does not exists");
                }

                Guid fundSysId = process.FundSystemIdentifier.Value;
                int? fundDraftId = fund.IsDraft ? fund.Id : null;

                var documentDraftIds = await _context.DocumentDrafts
                .Where(d =>
                        d.FundSystemIdentifier == process.FundSystemIdentifier.Value
                        && d.FundDraftId == fundDraftId
                        && d.IsCurrent
                        && !d.Deleted)
                    .Select(d => d.Id)
                    .ToListAsync();
                foreach (int draftId in documentDraftIds)
                {
                    await _documentService.DeleteDraftInternalAsync(draftId);
                }

                var archivalEntityDraftIds = await _context.ArchivalEntityDrafts
                .Where(ae =>
                        ae.FundSystemIdentifier == process.FundSystemIdentifier.Value
                        && ae.FundDraftId == fundDraftId
                        && ae.IsCurrent
                        && !ae.Deleted)
                    .Select(ae => ae.Id)
                    .ToListAsync();
                foreach (int draftId in archivalEntityDraftIds)
                {
                    await _archivalEntityService.DeleteDraftInternalAsync(draftId);
                }

                var inventoryDraftIds = await _context.InventoryDrafts
                .Where(inv =>
                        inv.FundSystemIdentifier == process.FundSystemIdentifier.Value
                        && inv.FundDraftId == fundDraftId
                        && inv.IsCurrent
                        && !inv.Deleted)
                    .Select(inv => inv.Id)
                    .ToListAsync();
                foreach (int draftId in inventoryDraftIds)
                {
                    await _inventoryService.DeleteDraftInternalAsync(draftId);
                }

                if (fundDraftId.HasValue)
                {
                    await _fundService.DeleteDraftInternalAsync(fundDraftId.Value);
                }

                var report = await _context.Epkreports
                                .Where(r => r.ProcessId == process.Id && !r.Deleted)
                                .Select(r => r)
                                .SingleOrDefaultAsync();
                if (report != null)
                {
                    await _commissionReportService.DeleteReportInternalAsync(report.Id);
                }


                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        private async Task<OperationResult> RetractProcessChangesInternalAsync(ProcessModel process)
        {
            try
            {
                //await _context.FundReconstructions
                //.Where(rec => rec.ProcessId == process.Id && !rec.Deleted)
                //.ForEachAsync(rec => { rec.Deleted = true; rec.DeletedOn = DateTime.UtcNow; rec.DeletedBy = _userInfo.CurrentUserId; });

                //await _context.SaveAsync("Fund reconstruction deleted");

                var fundDraft = await _context.FundDrafts
                                    .Where(f =>
                                        f.SystemIdentifier == process.FundSystemIdentifier!.Value
                                        && f.IsCurrent
                                        && !f.Deleted)
                                    .Select(f => f)
                                    .SingleOrDefaultAsync();

                int? fundDraftId = fundDraft != null ? fundDraft.Id : null;

                var documentDrafts = _context.DocumentDrafts
                                        .Where(d =>
                                            d.FundSystemIdentifier == process.FundSystemIdentifier!.Value
                                            && d.FundDraftId == fundDraftId
                                            && d.IsCurrent
                                            && !d.Deleted)
                                        .Select(d => d);
                await documentDrafts.ForEachAsync(d => { d.IsCurrent = false; d.ReadOnly = true; });

                await _context.SaveAsync("Document draft updated");

                var archivalEntityDrafts = _context.ArchivalEntityDrafts
                                                .Where(ae =>
                                                    ae.FundSystemIdentifier == process.FundSystemIdentifier!.Value
                                                    && ae.FundDraftId == fundDraftId
                                                    && ae.IsCurrent
                                                    && !ae.Deleted)
                                                .Select(ae => ae);
                await archivalEntityDrafts.ForEachAsync(ae => { ae.IsCurrent = false; ae.ReadOnly = true; });

                await _context.SaveAsync("Archival entity draft updated");

                var inventoryDrafts = _context.InventoryDrafts
                                            .Where(inv =>
                                                inv.FundSystemIdentifier == process.FundSystemIdentifier!.Value
                                                && inv.FundDraftId == fundDraftId
                                                && inv.IsCurrent
                                                && !inv.Deleted)
                                            .Select(inv => inv);
                await inventoryDrafts.ForEachAsync(inv => { inv.IsCurrent = false; inv.ReadOnly = true; });

                await _context.SaveAsync("Inventory draft updated");

                if (fundDraft != null)
                {
                    fundDraft.IsCurrent = false;
                    fundDraft.ReadOnly = true;

                    _context.Update(fundDraft);

                    await _context.SaveAsync("Fund draft updated");
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
            if (model.ProcessTypeId!.Value != (int)ProcessType.ReconstructFundData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), ""));
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

                var processStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.ReconstructFundData_ProcessInitiation);
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
            if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.ReconstructFundData)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_InvalidProcessType", process.ProcessTypeTitle!).ToString());
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ProcessAlreadyCompleted", process.ProcessTypeTitle!).ToString());
            }

            if(await _inventoryService.AnyUnnumberedDraftsByFundIdentifier(process.FundSystemIdentifier!.Value))
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

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var activeStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.ReconstructFundData_ProcessFinalization);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                var deductReconstructions = 
                    _fundReconstructionService.GetReconstructionsByAvailabilityStatus(processId, (int)Shared.AvailabilityStatus.DisposalDeduction);
                if (deductReconstructions != null && deductReconstructions.Any())
                {
                    await _fundReconstructionService.ApplyDeductFundReconstructionsInternalAsync(deductReconstructions);
                }

                bool hasDraft = await _fundService.HasCurrentDraftAsync(process.FundSystemIdentifier!.Value);
                if (hasDraft)
                {
                    var fundSysId = await _fundService.CreateOrUpdateFundFromDraftInternalAsync(process.FundSystemIdentifier.Value);
                }

                //Set status to registered on the newly created inventories in the process
                await _context.InventoryDrafts
                    .Where(inv => inv.FundSystemIdentifier == process.FundSystemIdentifier.Value
                            && inv.StatusCode == Shared.Status.New
                            && inv.IsCurrent
                            && !inv.Deleted)
                    .ForEachAsync(inv =>
                    {
                        inv.StatusCode = Shared.Status.Registered;
                    });
                await _context.SaveAsync("Update inventories");

                var inventoryDraftSysIds = await _context.InventoryDrafts
                    .Where(inv => inv.FundSystemIdentifier == process.FundSystemIdentifier.Value && inv.IsCurrent && !inv.Deleted)
                    .Select(inv => inv.SystemIdentifier)
                    .ToListAsync();
                foreach (Guid sysId in inventoryDraftSysIds)
                {
                    var inventorySysId = await _inventoryService.CreateOrUpdateInventoryFromDraftInternalAsync(sysId);
                }

                var archivalEntityDraftSysIds = await _context.ArchivalEntityDrafts
                    .Where(ae => ae.FundSystemIdentifier == process.FundSystemIdentifier.Value && ae.IsCurrent && !ae.Deleted)
                    .Select(ae => ae.SystemIdentifier)
                    .ToListAsync();
                foreach (Guid sysId in archivalEntityDraftSysIds)
                {
                    var archivalEntitySysId = await _archivalEntityService.CreateOrUpdateArchivalEntityFromDraftInternalAsync(sysId);
                }

                var documentDraftSysIds = await _context.DocumentDrafts
                    .Where(d => d.FundSystemIdentifier == process.FundSystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                    .Select(d => d.SystemIdentifier)
                    .ToListAsync();
                foreach (Guid sysId in documentDraftSysIds)
                {
                    var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId);
                }

                var accessResult = await ModifyDataAccessAsync(process, false);
                if (!accessResult.Succeeded)
                {
                    transaction.Rollback();
                    return accessResult;
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
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.ReconstructFundData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var activeStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)Shared.ProcessStepType.ReconstructFundData_UndoChanges);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                var undoChangesResult =  await UndoProcessChangesInternalAsync(process);
                if (!undoChangesResult.Succeeded)
                {
                    transaction.Rollback();
                    return undoChangesResult;
                }

                var accessResult = await ModifyDataAccessAsync(process, false);
                if (!accessResult.Succeeded)
                {
                    transaction.Rollback();
                    return accessResult;
                }

                activeStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.ReconstructFundData_ProcessFinalization);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
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

        public async Task<OperationResult> RequestPublicAccessSuspensionAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_RequestPublicAccessSuspension);
            if (!validationResult.Succeeded)
            {
                return validationResult;
            }

            var transaction = _context.Database.BeginTransaction();
            try
            {
                var processStepResult = await _processService.SetActiveProcessStepAsync(model);
                if (!processStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return processStepResult;
                }

                int.TryParse(processStepResult.Data!.ToString(), out int activeStepId);

                var task = new TaskCreateModel()
                {
                    ProcessId = process!.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = process.FundId,
                    EntitySystemIdentifier = process.FundSystemIdentifier,
                    EntityType = BusinessObjectType.Fund,
                    AssignedToUserId = model.AssignedToUserId?.ToString("D"),
                    StepType = (ProcessStepType)model.StepTypeId,
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

        public async Task<OperationResult> SuspendPublicAccessAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_SuspendPublicAccess);
            if (!validationResult.Succeeded)
            {
                return validationResult;
            }

            var transaction = _context.Database.BeginTransaction();
            try
            {
                var suspendAccessResult = await ModifyDataAccessAsync(process!, true);

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

                var task = new TaskCreateModel()
                {
                    ProcessId = process!.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = process.FundId,
                    EntitySystemIdentifier = process.FundSystemIdentifier,
                    EntityType = BusinessObjectType.Fund,
                    AssignedToUserId = process.CreatedBy!.Value.ToString("D"),
                    StepType = (ProcessStepType)model.StepTypeId,
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

        public async Task<OperationResult> StartApplyingChangesAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            //var process = await _processService.GetProcessAsync(model.ProcessId);
            //var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_EditData);
            //if (!validationResult.Succeeded)
            //{
            //    return validationResult;
            //}

            var process = await _processService.GetProcessAsync(model.ProcessId);
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (process.ProcessTypeId!.Value != (int)ProcessType.ReconstructFundData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ReconstructFundData_EditData
                && model.StepTypeId != (int)ProcessStepType.ReconstructFundData_DataModifications)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
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
            var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_CreateReport);
            if (!validationResult.Succeeded)
            {
                return validationResult;
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

                var readOnlyResult = await SetReadOnlyDataAsync(process!, true);
                if (!readOnlyResult.Succeeded)
                {
                    transaction.Rollback();
                    return readOnlyResult;
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
            //var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_SendReport);
            //if (!validationResult.Succeeded)
            //{
            //    return validationResult;
            //}
            var validateProcessResult = _processService.ValidateProcess(process, ProcessType.ReconstructFundData);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }

            var validateProcessStepResult = _processService.ValidateProcessStep(process, model, ProcessStepType.ReconstructFundData_SendReport);
            if (!validateProcessStepResult.Succeeded)
            {
                return validateProcessStepResult;
            }

            if (_userInfo.CurrentUserId != process!.CreatedBy)
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
                    return OperationResult.Failed(false,_localizer.GetString("Error_ReportDoesNotExists", process!.ProcessTypeTitle!).ToString());
                }

                //Става в предходната стъпка
                //var setDataReadOnlyResult = await SetReadOnlyDataAsync(process!, true);
                //if (!setDataReadOnlyResult.Succeeded)
                //{
                //    transaction.Rollback();
                //    return setDataReadOnlyResult;
                //}

                var setReportReadOnlyResult = await SetReadOnlyReportAsync(process!, true);
                if (!setReportReadOnlyResult.Succeeded)
                {
                    transaction.Rollback();
                    return setReportReadOnlyResult;
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
        //    var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_AddReportToSessionAgenda);
        //    if (!validationResult.Succeeded)
        //    {
        //        return validationResult;
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
            //var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_SendToAddSessionAgendaStandpoint);
            //if (!validationResult.Succeeded)
            //{
            //    return validationResult;
            //}
            var validateProcessResult = _processService.ValidateProcess(process, ProcessType.ReconstructFundData);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }

            if (process!.ActiveProcessStepTypeId != (int)ProcessStepType.ReconstructFundData_SendReport)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ProcessStepNotActive", process.ActiveProcessStepName!).ToString());
            }

            var validateProcessStepResult = _processService.ValidateProcessStep(process, model, ProcessStepType.ReconstructFundData_SendToAddSessionAgendaStandpoint);
            if (!validateProcessStepResult.Succeeded)
            {
                return validateProcessStepResult;
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

                var task = new TaskCreateModel()
                {
                    ProcessId = process!.Id!.Value,
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
                    StepTypeId = (int)ProcessStepType.ReconstructFundData_AddSessionAgendaStandpoint
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
            var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_AddSessionAgendaStandpoint);
            if (!validationResult.Succeeded)
            {
                return validationResult;
            }
            
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var sessionAgendaItem = await _sessionAgendaService.GetSessionAgendaItemByProcessAsync(model.ProcessId);
                if (sessionAgendaItem == null)
                {
                    transaction.Rollback();
                    return OperationResult.Failed(false, _localizer.GetString("Error_SessionAgendaItemDoesNotExists").ToString());
                }
                var sessionAgendaStandpoint =
                    await _sessionAgendaService.GetSessionAgendaItemStandpointByItemAsync(sessionAgendaItem.Id!.Value, _userInfo.CurrentUserId!.Value);
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
                return OperationResult.Succeed(process!.ActiveProcessStepId!.Value);
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
            //var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_SendToAddSessionAgendaStandpointComment);
            //if (!validationResult.Succeeded)
            //{
            //    return validationResult;
            //}
            var validateProcessResult = _processService.ValidateProcess(process, ProcessType.ReconstructFundData);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }

            if (process!.ActiveProcessStepTypeId != (int)ProcessStepType.ReconstructFundData_AddSessionAgendaStandpoint)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ProcessStepNotActive", process.ActiveProcessStepName!).ToString());
            }

            var validateProcessStepResult = 
                _processService.ValidateProcessStep(process, model, ProcessStepType.ReconstructFundData_SendToAddSessionAgendaStandpointComment);
            if (!validateProcessStepResult.Succeeded)
            {
                return validateProcessStepResult;
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask(ProcessStepType.ReconstructFundData_SendToAddSessionAgendaStandpoint, process.Id, null, null);
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

                var task = new TaskCreateModel()
                {
                    ProcessId = process!.Id!.Value,
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
            var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_AddSessionAgendaStandpointComment);
            if (!validationResult.Succeeded)
            {
                return validationResult;
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

        public async Task<OperationResult> SendCommentAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_SendSessionAgendaStandpointComment);
            if (!validationResult.Succeeded)
            {
                return validationResult;
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask(ProcessStepType.ReconstructFundData_SendToAddSessionAgendaStandpointComment, process.Id, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
                }

                var sessionAgendaStep = await _processService.GetProcessStepAsync(process!.Id!.Value, ProcessStepType.ReconstructFundData_SendReport);
                var standpointStep = await _processService.GetProcessStepAsync(process.Id!.Value, ProcessStepType.ReconstructFundData_SendToAddSessionAgendaStandpoint);

                if (!model.AssignedToRoleId.HasValue && !model.AssignedToUserId.HasValue)
                {
                    model.AssignedToUserId = sessionAgendaStep?.AssignedToUserId;
                    model.AssignedToRoleId = sessionAgendaStep?.AssignedToRoleId;
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
                    StepType = (ProcessStepType)model.StepTypeId,
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
            var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_CommissionSession);
            if (!validationResult.Succeeded)
            {
                return validationResult;
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

                //Задача към експерта, че е добавен за заседание
                var task = new TaskCreateModel()
                {
                    ProcessId = process!.Id!.Value,
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
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (process.ProcessTypeId!.Value != (int)ProcessType.ReconstructFundData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ReconstructFundData_ChangesRequired
                && model.StepTypeId != (int)ProcessStepType.ReconstructFundData_ReportApproval
                && model.StepTypeId != (int)ProcessStepType.ReconstructFundData_ReportChangesRequired
                && model.StepTypeId != (int)ProcessStepType.ReconstructFundData_ReportRejection)
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

                //Задача към експерта за решението на комисията.
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

                //На следващата стъпка се случва
                //if (model.StepTypeId == (int)ProcessStepType.ReconstructFundData_ReportChangesRequired)
                //{
                //    var setDataReadOnlyResult = await SetReadOnlyDataAsync(process!, false);
                //    if (!setDataReadOnlyResult.Succeeded)
                //    {
                //        transaction.Rollback();
                //        return setDataReadOnlyResult;
                //    }

                //    var setReportReadOnlyResult = await SetReadOnlyReportAsync(process!, false);
                //    if (!setReportReadOnlyResult.Succeeded)
                //    {
                //        transaction.Rollback();
                //        return setReportReadOnlyResult;
                //    }
                //}

                //Complete process on rejection
                if (model.StepTypeId == (int)ProcessStepType.ReconstructFundData_ReportRejection)
                {
                    var retractDataResult = await RetractProcessChangesInternalAsync(process);
                    if (!retractDataResult.Succeeded)
                    {
                        transaction.Rollback();
                        return retractDataResult;
                    }

                    var accessResult = await ModifyDataAccessAsync(process, false);
                    if (!accessResult.Succeeded)
                    {
                        transaction.Rollback();
                        return accessResult;
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

        public async Task<OperationResult> ApplyReportModificationsAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_ReportModifications);
            if (!validationResult.Succeeded)
            {
                return validationResult;
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

                var setDataReadOnlyResult = await SetReadOnlyDataAsync(process!, false);
                if (!setDataReadOnlyResult.Succeeded)
                {
                    transaction.Rollback();
                    return setDataReadOnlyResult;
                }

                var setReportReadOnlyResult = await SetReadOnlyReportAsync(process!, false);
                if (!setReportReadOnlyResult.Succeeded)
                {
                    transaction.Rollback();
                    return setReportReadOnlyResult;
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

        public async Task<OperationResult> SendForModificationsRevisionAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_SendForModificationsRevision);
            if (!validationResult.Succeeded)
            {
                return validationResult;
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                //TODO Add fund reconstructions to read-only data???
                var readOnlyResult = await SetReadOnlyDataAsync(process!, true);
                if (!readOnlyResult.Succeeded)
                {
                    transaction.Rollback();
                    return readOnlyResult;
                }

                var readOnlyReportResult = await SetReadOnlyReportAsync(process!, true);
                if (!readOnlyResult.Succeeded)
                {
                    transaction.Rollback();
                    return readOnlyResult;
                }

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
            var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_ModificationsRevision);
            if (!validationResult.Succeeded)
            {
                return validationResult;
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
            var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_SendForAffirmation);
            if (!validationResult.Succeeded)
            {
                return validationResult;
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
                    ProcessId = process!.Id!.Value,
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.ReconstructFundData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ReconstructFundData_Affirmation
                && model.StepTypeId != (int)ProcessStepType.ReconstructFundData_ReportChangesRequired)
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

                if (model.StepTypeId == (int)ProcessStepType.ReconstructFundData_ReportChangesRequired)
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

                //if (model.StepTypeId == (int)ProcessStepType.ReconstructFundData_Affirmation)
                //{
                //    var roleA = await _roleManager.FindByNameAsync(ApplicationRoleType.GroupA, process.ArchiveId);
                //    if (roleA == null)
                //    {
                //        transaction.Rollback();
                //        return OperationResult.Failed($"Applicaiton Role {ApplicationRoleType.GroupA} does not exists in archive {process.ArchiveId}");
                //    }

                //    //Задача към регистратор.
                //    var task = new TaskCreateModel()
                //    {
                //        ProcessId = process.Id!.Value,
                //        TimelineId = activeStepId,
                //        EntityId = process.FundId,
                //        EntitySystemIdentifier = process.FundSystemIdentifier,
                //        EntityType = BusinessObjectType.Fund,
                //        AssignedToRoleId = roleA.Id.ToString("D"),
                //        StepType = (ProcessStepType)model.StepTypeId,
                //    };
                //    var taskResult = await _taskService.CreateAsync(task);
                //    if (!taskResult.Succeeded)
                //    {
                //        transaction.Rollback();
                //        return taskResult;
                //    }

                //    //Не приключва тук. Трябва да се прати за регистрация
                //    ////Приключване на процеса
                //    //activeStepResult = await _processService.SetActiveProcessStepAsync(process.Id.Value, (int)ProcessStepType.EditFundData_ProcessFinalization);
                //    //if (!activeStepResult.Succeeded)
                //    //{
                //    //    return activeStepResult;
                //    //}

                //    //bool hasDraft = await _fundService.HasCurrentDraftAsync(process.FundSystemIdentifier!.Value);
                //    //if (hasDraft)
                //    //{
                //    //    await _fundService.CreateOrUpdateFundFromDraftInternalAsync(process.FundSystemIdentifier.Value);
                //    //}

                //    //var processCompleteResult = await _processService.CompleteProcessAsync(process.Id.Value);
                //    //if (!processCompleteResult.Succeeded)
                //    //{
                //    //    transaction.Rollback();
                //    //    return processCompleteResult;
                //    //}
                //}

                transaction.Commit();
                return OperationResult.Succeed(activeStepId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> SendForModificationRegistrationAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_SendForRegistration);
            if (!validationResult.Succeeded)
            {
                return validationResult;
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

                //Задача към регистратор.
                var task = new TaskCreateModel()
                {
                    ProcessId = process!.Id!.Value,
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

        public async Task<OperationResult> StartModificationRegistrationAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var process = await _processService.GetProcessAsync(model.ProcessId);
            var validationResult = ValidateProcessData(process, model, ProcessStepType.ReconstructFundData_Registration);
            if (!validationResult.Succeeded)
            {
                return validationResult;
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

                ////Задача към експерта.
                //var task = new TaskCreateModel()
                //{
                //    ProcessId = process!.Id!.Value,
                //    TimelineId = activeStepId,
                //    EntityId = process.FundId,
                //    EntitySystemIdentifier = process.FundSystemIdentifier,
                //    EntityType = BusinessObjectType.Fund,
                //    AssignedToUserId = process.CreatedBy!.Value.ToString("D"),
                //    StepType = (Shared.ProcessStepType)model.StepTypeId,
                //    EndDate = model.EndDate,

                //};
                //var taskResult = await _taskService.CreateAsync(task);
                //if (!taskResult.Succeeded)
                //{
                //    transaction.Rollback();
                //    return taskResult;
                //}

                transaction.Commit();
                return OperationResult.Succeed(activeStepId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<int?> GetEntityArchiveIdAsync(ProcessModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            int? archiveId = await _fundService.GetArchiveIdAsync(model.FundSystemIdentifier!.Value);
            return archiveId;
        }

        public async Task<int?> GetEntityArchiveIdAsync(int processId)
        {
            var process = await _processService.GetProcessAsync(processId);
            if (process == null)
            {
                throw new ItemNotFoundException($"Process {processId} does not exists", processId.ToString());
            }

            int? archiveId =  await _fundService.GetArchiveIdAsync(process.FundSystemIdentifier!.Value);
            return archiveId;
        }
    }
}
