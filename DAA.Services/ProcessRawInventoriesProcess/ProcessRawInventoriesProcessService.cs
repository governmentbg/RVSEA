using DAA.Data;
using DAA.Extensions.Exceptions;
using DAA.Models.Processes;
using DAA.Services.ArchivalEntities;
using DAA.Services.DigitalObjects;
using DAA.Services.Documents;
using DAA.Services.Funds;
using DAA.Services.Inventories;
using DAA.Services.Process;
using DAA.Shared.Localization;
using DAA.Shared;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using System.Text;
using ProcessType = DAA.Shared.ProcessType;
using FundDescriptionLevel = DAA.Shared.FundDescriptionLevel;
using DAA.Models.Inventories;
using Microsoft.AspNetCore.Http;
using DAA.Services.CommissionReports;
using DAA.Models.Commission;
using DAA.Models.Tasks;
using DAA.Services.Tasks;
using DAA.Services.CommissionSessions;
using DAA.Shared.Identity;
using DAA.Models.Funds;
using DAA.Models.ArchiveEntities;
using DAA.Models.Documents;
using System.Linq.Dynamic.Core;
using DAA.Models.DigitalObjects;
using DAA.Services.Packages;
using DAA.Services.Interfaces;
using DAA.Services.Nomenclatures;

namespace DAA.Services.ProcessRawInventoriesProcess
{
    public class ProcessRawInventoriesProcessService : BaseService, IProcessRawInventoriesProcessService
    {
        private readonly IUserInfo _userInfo;
        private readonly IFundService _fundService;
        private readonly IInventoryService _inventoryService;
        private readonly IArchivalEntityService _archivalEntityService;
        private readonly IDocumentService _documentService;
        private readonly IDigitalObjectService _digitalObjectService;
        private readonly IProcessService _processService;
        private readonly ICommissionReportService _commissionReportService;
        private readonly ITaskService _taskService;
        private readonly ISessionAgendaService _sessionAgendaService;
        private readonly IPackagesService _packagesService;
        private readonly IUtilityService _utilityService;
        private readonly INomenclatureService _nomenclatureService;

        public ProcessRawInventoriesProcessService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IUserInfo userInfo,
            IFundService fundService,
            IInventoryService inventoryService,
            IArchivalEntityService archiveEntityService,
            IDocumentService documentService,
            IDigitalObjectService digitalObjectService,
            IProcessService processService,
            ICommissionReportService commissionReportService,
            ITaskService taskService,
            ISessionAgendaService sessionAgendaService,
            IPackagesService packagesService,
            IUtilityService utilityService,
            INomenclatureService nomenclatureService)
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _fundService = fundService;
            _inventoryService = inventoryService;
            _archivalEntityService = archiveEntityService;
            _documentService = documentService;
            _digitalObjectService = digitalObjectService;
            _processService = processService;
            _commissionReportService = commissionReportService;
            _taskService = taskService;
            _sessionAgendaService = sessionAgendaService;
            _packagesService = packagesService;
            _utilityService = utilityService;
            _nomenclatureService = nomenclatureService;
        }

        public async Task<OperationResult> StartProcessAsync(ProcessModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            if (model.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                model.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
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

                ProcessStepType step =
                    model.ProcessTypeId!.Value == (int)ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStepType.ProcessRawFundWithRawInventory_ProcessInit
                    : ProcessStepType.ProcessFundWithRawInventory_ProcessInit;

                var processStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)step);
                if (!processStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return processStepResult;
                }

                step =
                    model.ProcessTypeId!.Value == (int)ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStepType.ProcessRawFundWithRawInventory_ChooseRawInventories
                    : ProcessStepType.ProcessFundWithRawInventory_ChooseRawInventories;

                processStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)step);
                if (!processStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return processStepResult;
                }

                var fundDraftModel = await _fundService.GetFundAsDraftModelBySystemIdentifierInternalAsync(model.FundSystemIdentifier ?? Guid.Empty);
                if (fundDraftModel == null)
                {
                    await transaction.RollbackAsync();
                    return OperationResult.Failed(false, _localizer.GetString("Error_FundNotFound").ToString());
                }

                var rawInventories = await _fundService.GetFundUnprocessedRawInventoriesAsync(model.FundSystemIdentifier ?? Guid.Empty);
                if (rawInventories == null || rawInventories.Count == 0)
                {
                    await transaction.RollbackAsync();
                    return OperationResult.Failed(false, _localizer.GetString("Error_FundHasNoUnprocessedRawInventories").ToString());
                }

                fundDraftModel.DescriptionLevelCode = ((int)FundDescriptionLevel.Fund).ToString();
                await _fundService.CreateDraftInternalAsync(fundDraftModel, false);


                await transaction.CommitAsync();
                return OperationResult.Succeed(processResult.Data!);
            }
            catch (Exception exc)
            {
                await transaction.RollbackAsync();
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

            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }

            if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.ProcessRawFundWithRawInventory &&
                (ProcessType)process.ProcessTypeId!.Value != ProcessType.ProcessFundWithRawInventory)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                ProcessStepType step = (ProcessType)process.ProcessTypeId!.Value == ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStepType.ProcessRawFundWithRawInventory_UndoChanges
                    : ProcessStepType.ProcessFundWithRawInventory_UndoChanges;

                var activeStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)step);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                var undoChangesResult = await UndoProcessChangesInternalAsync(process);
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


                activeStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.ProcessRawFundWithRawInventory_ProcessFinalization);
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

        public async Task<List<Guid>> GetSelectedRawInventoriesForFundAsync(Guid sysId)
        {
            var selectedRawInventories = await _context.InventoryRawToNormals
                .Where(x => x.FundSystemIdentifier == sysId && !x.IsRejected)
                .Select(x => x.RawInventorySystemIdentifier)
                .ToListAsync();
            return selectedRawInventories;
        }

        public async Task<OperationResult> SaveSelectedRawInventoriesAsync(Guid fundSystemIdentifier, int processId, string[] selectedRawInventories)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var fund = await _context.VFunds
                    .Where(x => x.SystemIdentifier == fundSystemIdentifier)
                    .FirstOrDefaultAsync();

                if (fund == null)
                {
                    throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), fundSystemIdentifier.ToString()!);
                }

                var process = await _processService.GetProcessAsync(processId);
                if (process == null)
                {
                    throw new CustomException(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                if (process.Completed)
                {
                    throw new CustomException(string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
                }

                if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                    process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
                {
                    throw new CustomException(string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
                }

                if (process.ActiveProcessStepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_ChooseRawInventories &&
                    process.ActiveProcessStepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_ChooseRawInventories)
                {
                    throw new CustomException(string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
                }

                var selectedInventoriesInDB = await _context.InventoryRawToNormals
                    .Where(x => x.FundSystemIdentifier == fundSystemIdentifier && !x.IsRejected)
                    .ToListAsync();

                var selectedRawSysIdInDB = selectedInventoriesInDB
                    .Select(x => x.RawInventorySystemIdentifier.ToString())
                    .ToList();

                var selectedToAdd = selectedRawInventories
                    .Where(x => !selectedRawSysIdInDB.Contains(x))
                    .Select(x => new InventoryRawToNormal
                    {
                        ArchiveId = fund.ArchiveId,
                        FundSystemIdentifier = fundSystemIdentifier,
                        RawInventorySystemIdentifier = new Guid(x),
                        ProcessId = processId,
                        IsRejected = false
                    })
                    .ToList();

                var selectedToDelete = selectedInventoriesInDB
                    .Where(x =>
                        !selectedRawInventories.Contains(x.RawInventorySystemIdentifier.ToString().ToLower())
                        && x.NormalInventorySystemIdentifier == null)
                    .ToList();

                _context.InventoryRawToNormals.AddRange(selectedToAdd);
                _context.InventoryRawToNormals.RemoveRange(selectedToDelete);

                await _context.SaveAsync("Selected raw inventories updated");

                transaction.Commit();

                return OperationResult.Succeed(fundSystemIdentifier);
            }
            catch (ItemNotFoundException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(false, exc.ToString());
            }
            catch (CustomException ex)
            {
                transaction.Rollback();
                return OperationResult.Failed(false, ex.Message.ToString());
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> CreateNormalInventory(int processId)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var process = await _processService.GetProcessAsync(processId);
                if (process == null)
                {
                    throw new CustomException(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                var fund = await _context.FundDrafts
                    .Where(x => x.SystemIdentifier == process.FundSystemIdentifier && !x.Deleted && x.IsCurrent)
                    .FirstOrDefaultAsync();

                if (fund == null)
                {
                    throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), process.FundSystemIdentifier.ToString()!);
                }

                if (process.Completed)
                {
                    throw new CustomException(string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
                }

                if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                    process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
                {
                    throw new CustomException(string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
                }

                if (process.ActiveProcessStepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_ChooseRawInventories &&
                    process.ActiveProcessStepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_ChooseRawInventories)
                {
                    throw new CustomException(string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
                }

                var selectedRawInventories = await _context.InventoryRawToNormals
                        .Where(x => x.ProcessId == processId && !x.IsRejected)
                        .ToListAsync();

                if (selectedRawInventories.Count == 0)
                {
                    throw new ItemNotFoundException(_localizer.GetString("Error_RawInventoriesNotSelected").ToString(), process.FundSystemIdentifier.ToString()!);
                }

                List<Guid> selectedRawInventoriesIds = selectedRawInventories.Select(x => x.RawInventorySystemIdentifier).ToList();
                var rawPackageIds = await _context.Inventories
                    .Where(x => selectedRawInventoriesIds.Contains(x.SystemIdentifier) && x.PackageBid != null)
                    .Select(x => x.PackageBid!.Value)
                    .ToListAsync();

                OperationResult packageResult = await _packagesService.UnitePackagesIntoNewPackageAsync(rawPackageIds, FileStreamLocation.Buffer, "B");
                Package? packageB = packageResult.Data != null ? packageResult.Data as Package : null;

                Guid normalInventoryGuid = await CreateEmptyInventory(fund, packageB);
                foreach (var rawInventory in selectedRawInventories)
                {
                    rawInventory.NormalInventorySystemIdentifier = normalInventoryGuid;
                }

                List<Guid> rawInventoriesIds = selectedRawInventories.Select(x => x.RawInventorySystemIdentifier).ToList();
                //Guid aeGuid = await CreateArchivalEntityWithPackageBFiles(fund, normalInventoryGuid, rawInventoriesIds);

                _context.InventoryRawToNormals.UpdateRange(selectedRawInventories);
                await _context.SaveAsync("Selected raw inventories updated");

                fund.InventoryCount = (fund.InventoryCount ?? 0) + 1;
                _context.FundDrafts.Update(fund);
                await _context.SaveAsync("Update fund inventories count");

                await _inventoryService.SetRelatedProcessStepInternalAsync(fund.SystemIdentifier);
                await _context.SaveAsync("Go to process raw inventories");

                transaction.Commit();

                return OperationResult.Succeed(process.FundSystemIdentifier!);
            }
            catch (ItemNotFoundException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(false, exc.Message.ToString());
            }
            catch (CustomException ex)
            {
                transaction.Rollback();
                return OperationResult.Failed(false, ex.Message.ToString());
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
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.ProcessRawFundWithRawInventory &&
                (ProcessType)process.ProcessTypeId!.Value != ProcessType.ProcessFundWithRawInventory)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_CreateReport &&
                model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_CreateReport)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var normalInventorySysId = await _context.InventoryRawToNormals
                    .Where(x => x.ProcessId == process.Id && !x.IsRejected)
                    .Select(x => x.NormalInventorySystemIdentifier)
                    .FirstOrDefaultAsync();

                if (normalInventorySysId == null)
                {
                    throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                var inventory = await _context.VInventories
                    .Where(x => x.SystemIdentifier == normalInventorySysId && !x.Deleted && x.IsDraft.HasValue && x.IsDraft.Value == true)
                    .FirstOrDefaultAsync();

                if (inventory == null)
                {
                    throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                if (inventory.PackageBid.HasValue)
                {
                    var availablePackageFiles = (await _packagesService.GetAvailablePackageDocumentsForArchivalEntity(inventory.SystemIdentifier, inventory.PackageBid.Value))
                        .Where(x => !x.IsInvaluable)
                        .ToList();
                    if (availablePackageFiles != null && availablePackageFiles.Count > 0)
                    {
                        throw new ItemNotFoundException(_localizer.GetString("Error_AvailablePackageFilesForAE").ToString());
                    }
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
            catch (ItemNotFoundException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(false, exc.Message.ToString());
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }


        public async Task<OperationResult> SendReportAsync(CommissionReportSubmitModel model)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var report = await _context.Epkreports.FindAsync(model.Id);
                if (report == null)
                {
                    transaction.Rollback();
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                report.IsDraft = false;
                report.Title = model.Title!;
                report.Content = model.Content!;
                _context.Update(report);

                var process = await _processService.GetProcessAsync(model.ProcessId!.Value);
                if (process == null)
                {
                    transaction.Rollback();
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                if (process.Completed)
                {
                    transaction.Rollback();
                    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
                }

                if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                    process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
                {
                    transaction.Rollback();
                    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
                }

                if (process.ActiveProcessStepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_CreateReport &&
                    process.ActiveProcessStepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_DataModifications &&
                    process.ActiveProcessStepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_CreateReport &&
                    process.ActiveProcessStepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_DataModifications)
                {
                    transaction.Rollback();
                    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
                }

                await SetReadOnlyDataAsync(process.FundSystemIdentifier, true);

                var nextStep = process.ProcessTypeId == (int)ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStepType.ProcessRawFundWithRawInventory_SendReport
                    : ProcessStepType.ProcessFundWithRawInventory_SendReport;

                var activeStepResult = await _processService.SetActiveProcessStepAsync(
                    new ProcessStepModel()
                    {
                        AssignedToRoleId = !String.IsNullOrWhiteSpace(model.AssignToRoleId) ? new Guid(model.AssignToRoleId) : null,
                        AssignedToUserId = !String.IsNullOrWhiteSpace(model.AssignToUserId) ? new Guid(model.AssignToUserId) : null,
                        ProcessId = process.Id!.Value,
                        StepTypeId = (int)nextStep
                    });

                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                TaskCreateModel taskModel = new()
                {
                    StepType = nextStep,
                    ProcessId = process.Id,
                    TimelineId = (int)activeStepResult.Data!,
                    EntitySystemIdentifier = process.FundSystemIdentifier!.Value,
                    AssignedToUserId = model.AssignToUserId,
                    AssignedToRoleId = model.AssignToRoleId,
                    EntityType = BusinessObjectType.Fund,
                };

                var taskResult = await _taskService.CreateAsync(taskModel);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }

                await _context.SaveAsync($"Send report with ID {model.Id}");

                // complete previous task
                var completePrevTaskResult = await CompletePreviousTask(process.Id!.Value, (int)nextStep);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
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

        public async Task<OperationResult> AddReportToSessionAgendaAsync(ProcessStepModel model)
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_AddReportToSessionAgenda &&
                model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_AddReportToSessionAgenda)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
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

                // complete previous task
                var completePrevTaskResult = await CompletePreviousTask(process.Id!.Value, model.StepTypeId);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
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

        public async Task<OperationResult> SendToAddStandpointAsync(ProcessStepModel model)
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_SendToAddSessionAgendaStandpoint &&
                model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_SendToAddSessionAgendaStandpoint)
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

                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = GetEntityId(process),
                    EntitySystemIdentifier = GetEntitySystemIdentifier(process),
                    EntityType = GetEntityType(process),
                    AssignedToUserId = model.AssignedToUserId != null ? model.AssignedToUserId!.Value.ToString("D") : "",
                    AssignedToRoleId = model.AssignedToRoleId != null ? model.AssignedToRoleId!.Value.ToString("D") : "",
                    StepType = (ProcessStepType)model.StepTypeId,
                    EndDate = model.EndDate,

                };
                var taskResult = await _taskService.CreateAsync(task);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }

                ProcessStepType step = process.ProcessTypeId!.Value == (int)ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStepType.ProcessRawFundWithRawInventory_AddSessionAgendaStandpoint
                    : ProcessStepType.ProcessFundWithRawInventory_AddSessionAgendaStandpoint;

                activeStepResult = await _processService.SetActiveProcessStepAsync(new ProcessStepModel()
                {
                    AssignedToRoleId = model.AssignedToRoleId,
                    AssignedToUserId = model.AssignedToUserId,
                    Comment = model.Comment,
                    EndDate = model.EndDate,
                    ProcessId = model.ProcessId,
                    StepTypeId = (int)step
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_AddSessionAgendaStandpoint &&
                model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_AddSessionAgendaStandpoint)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
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
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_SendToAddSessionAgendaStandpointComment &&
                model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_SendToAddSessionAgendaStandpointComment)
            {
                return OperationResult.Failed(
                    false,
                    string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
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

                int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);

                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = GetEntityId(process),
                    EntitySystemIdentifier = GetEntitySystemIdentifier(process),
                    EntityType = GetEntityType(process),
                    AssignedToUserId = process.CreatedBy != null ? process.CreatedBy!.Value.ToString("D") : "",
                    StepType = (ProcessStepType)model.StepTypeId,
                };
                var taskResult = await _taskService.CreateAsync(task);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }

                // complete previous task
                var completePrevTaskResult = await CompletePreviousTask(process.Id.Value, model.StepTypeId);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
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
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_AddSessionAgendaStandpointComment &&
                model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_AddSessionAgendaStandpointComment)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
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
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_SendSessionAgendaStandpointComment &&
                model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_SendSessionAgendaStandpointComment)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
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

                int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);

                ProcessStepType agendaStepType = process.ProcessTypeId!.Value == (int)ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStepType.ProcessRawFundWithRawInventory_SendReport
                    : ProcessStepType.ProcessFundWithRawInventory_SendReport;

                ProcessStepType standpointStepType = process.ProcessTypeId!.Value == (int)ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStepType.ProcessRawFundWithRawInventory_SendToAddSessionAgendaStandpoint
                    : ProcessStepType.ProcessFundWithRawInventory_SendToAddSessionAgendaStandpoint;

                var sessionAgendaStep = await _processService.GetProcessStepAsync(process.Id!.Value, agendaStepType);
                var standpointStep = await _processService.GetProcessStepAsync(process.Id!.Value, standpointStepType);

                //Задача към секретар/председател на комисия
                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = GetEntityId(process),
                    EntitySystemIdentifier = GetEntitySystemIdentifier(process),
                    EntityType = GetEntityType(process),
                    AssignedToUserId = sessionAgendaStep?.AssignedToUserId != null ? sessionAgendaStep?.AssignedToUserId!.Value.ToString("D") : "",
                    AssignedToRoleId = sessionAgendaStep?.AssignedToRoleId != null ? sessionAgendaStep?.AssignedToRoleId!.Value.ToString("D") : "",
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
                    EntityId = GetEntityId(process),
                    EntitySystemIdentifier = GetEntitySystemIdentifier(process),
                    EntityType = GetEntityType(process),
                    AssignedToUserId = standpointStep?.AssignedToUserId != null ? standpointStep?.AssignedToUserId!.Value.ToString("D") : "",
                    AssignedToRoleId = standpointStep?.AssignedToRoleId != null ? standpointStep?.AssignedToRoleId!.Value.ToString("D") : "",
                    StepType = (ProcessStepType)model.StepTypeId,
                    EndDate = model.EndDate,

                };
                taskResult = await _taskService.CreateAsync(task);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }

                // complete previous task
                var completePrevTaskResult = await CompletePreviousTask(process.Id.Value, model.StepTypeId);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
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
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_CommissionSession &&
                model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_CommissionSession)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
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

                int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);

                // Известие към експерта, че е добавен за заседание
                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = GetEntityId(process),
                    EntitySystemIdentifier = GetEntitySystemIdentifier(process),
                    EntityType = GetEntityType(process),
                    AssignedToUserId = process.CreatedBy?.ToString("D"),
                    StepType = (ProcessStepType)model.StepTypeId,
                    StatusCode = Shared.TaskStatus.Completed,
                };

                var taskResult = await _taskService.CreateAsync(task);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }

                // complete previous task
                var completePrevTaskResult = await CompletePreviousTask(process.Id.Value, model.StepTypeId);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_ReportApproval
                && model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_ChangesRequired
                && model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_ReportChangesRequired
                && model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_ReportRejection
                && model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_ChangesRequired
                && model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_ReportApproval
                && model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_ReportChangesRequired
                && model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_ReportRejection)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                // complete previous task
                var completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)process.ActiveProcessStepTypeId, process.Id, null, null);
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


                // Известие към експерта за решението на комисията.
                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = GetEntityId(process),
                    EntitySystemIdentifier = GetEntitySystemIdentifier(process),
                    EntityType = GetEntityType(process),
                    AssignedToUserId = process.CreatedBy?.ToString("D"),
                    StepType = (ProcessStepType)model.StepTypeId,
                };

                if (model.StepTypeId == (int)ProcessStepType.ProcessRawFundWithRawInventory_ReportApproval ||
                    model.StepTypeId == (int)ProcessStepType.ProcessFundWithRawInventory_ReportApproval ||
                    model.StepTypeId == (int)ProcessStepType.ProcessRawFundWithRawInventory_ReportRejection ||
                    model.StepTypeId == (int)ProcessStepType.ProcessFundWithRawInventory_ReportRejection)
                {
                    task.StatusCode = Shared.TaskStatus.Completed;
                }

                var taskResult = await _taskService.CreateAsync(task);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }


                //Complete process on rejection
                if (model.StepTypeId == (int)ProcessStepType.ProcessRawFundWithRawInventory_ReportRejection ||
                    model.StepTypeId == (int)ProcessStepType.ProcessFundWithRawInventory_ReportRejection)
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

                    ProcessStepType finalStep = process.ProcessTypeId!.Value == (int)ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStepType.ProcessRawFundWithRawInventory_ProcessFinalization
                    : ProcessStepType.ProcessFundWithRawInventory_ProcessFinalization;

                    activeStepResult = await _processService.SetActiveProcessStepAsync(process.Id.Value, (int)finalStep);
                    if (!activeStepResult.Succeeded)
                    {
                        transaction.Rollback();
                        return activeStepResult;
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

        private async Task<OperationResult> RetractProcessChangesInternalAsync(ProcessModel process)
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



                var inventoryDrafts = _context.InventoryDrafts
                                            .Where(inv =>
                                                inv.FundSystemIdentifier == process.FundSystemIdentifier!.Value
                                                //&& inv.FundDraftId == fundDraftId
                                                && inv.IsCurrent
                                                && !inv.Deleted)
                                            .Select(inv => inv);
                await inventoryDrafts.ForEachAsync(inv => { inv.IsCurrent = false; inv.ReadOnly = true; });

                await _context.SaveAsync("Inventory draft updated");


                var archivalEntityDrafts = _context.ArchivalEntityDrafts
                                                .Where(ae =>
                                                    ae.FundSystemIdentifier == process.FundSystemIdentifier!.Value
                                                    //&& ae.FundDraftId == fundDraftId
                                                    && ae.IsCurrent
                                                    && !ae.Deleted)
                                                .Select(ae => ae);
                await archivalEntityDrafts.ForEachAsync(ae => { ae.IsCurrent = false; ae.ReadOnly = true; });

                await _context.SaveAsync("Archival entity draft updated");

                var documentDrafts = _context.DocumentDrafts
                                        .Where(d =>
                                            d.FundSystemIdentifier == process.FundSystemIdentifier!.Value
                                            //&& d.FundDraftId == fundDraftId
                                            && d.IsCurrent
                                            && !d.Deleted)
                                        .Select(d => d);
                await documentDrafts.ForEachAsync(d => { d.IsCurrent = false; d.ReadOnly = true; });

                await _context.SaveAsync("Document draft updated");

                var digitalObjectsDrafts = _context.DigitalObjectDrafts
                                        .Where(d =>
                                            d.FundSystemIdentifier == process.FundSystemIdentifier!.Value
                                            //&& d.FundDraftId == fundDraftId
                                            && d.IsCurrent
                                            && !d.Deleted)
                                        .Select(d => d);
                await digitalObjectsDrafts.ForEachAsync(d => { d.IsCurrent = false; d.ReadOnly = true; });

                await _context.SaveAsync("Digital objects draft updated");


                var rawToNormalInventories = _context.InventoryRawToNormals
                    .Where(x => x.ProcessId == process.Id)
                    .Select(x => x);
                await rawToNormalInventories.ForEachAsync(x => x.IsRejected = true);
                await _context.SaveAsync("Reject raw to normal inventories");


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



        public async Task<OperationResult> StartApplyingChangesAsync(ProcessStepModel model)
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }

            if (model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_DataModifications
                && model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_DataModifications)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
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

                await SetReadOnlyDataAsync(process.FundSystemIdentifier, false);

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

            if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_ReportModifications &&
                model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_ReportModifications)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
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

                await SetReadOnlyDataAsync(process.FundSystemIdentifier, false);

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

            if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_SendForModificationsRevision &&
                model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_SendForModificationsRevision)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await SetReadOnlyDataAsync(process.FundSystemIdentifier, true);

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
                    EntityId = GetEntityId(process),
                    EntitySystemIdentifier = GetEntitySystemIdentifier(process),
                    EntityType = GetEntityType(process),
                    AssignedToUserId = model.AssignedToUserId != null ? model.AssignedToUserId!.Value.ToString("D") : "",
                    AssignedToRoleId = model.AssignedToRoleId != null ? model.AssignedToRoleId!.Value.ToString("D") : "",
                    StepType = (ProcessStepType)model.StepTypeId,
                    EndDate = model.EndDate,

                };
                var taskResult = await _taskService.CreateAsync(task);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }

                // complete previous task
                var completePrevTaskResult = await CompletePreviousTask(process.Id.Value, model.StepTypeId);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_ModificationsRevision &&
                model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_ModificationsRevision)
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_SendForAffirmation &&
                model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_SendForAffirmation)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
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

                int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);

                //Задача към ръководителя на архива.
                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = GetEntityId(process),
                    EntitySystemIdentifier = GetEntitySystemIdentifier(process),
                    EntityType = GetEntityType(process),
                    AssignedToRoleId = model.AssignedToRoleId != null ? model.AssignedToRoleId!.Value.ToString("D") : "",
                    AssignedToUserId = model.AssignedToUserId != null ? model.AssignedToUserId!.Value.ToString("D") : "",
                    StepType = (ProcessStepType)model.StepTypeId,
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_Affirmation
                && model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_Affirmation)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
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

                int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);

                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = GetEntityId(process),
                    EntitySystemIdentifier = GetEntitySystemIdentifier(process),
                    EntityType = GetEntityType(process),
                    AssignedToUserId = process.CreatedBy?.ToString("D"),
                    StepType = (ProcessStepType)model.StepTypeId,
                    StatusCode = Shared.TaskStatus.Completed,
                };

                var taskResult = await _taskService.CreateAsync(task);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }

                // complete previous task
                var completePrevTaskResult = await CompletePreviousTask(process.Id.Value, model.StepTypeId);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
                }

                transaction.Commit();
                return OperationResult.Succeed(activeStepId);
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

        public async Task<OperationResult> SendToRegistrarAsync(ProcessStepModel model)
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.ProcessRawFundWithRawInventory_SendToRegistrar &&
                model.StepTypeId != (int)ProcessStepType.ProcessFundWithRawInventory_SendToRegistrar)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
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

                int.TryParse(activeStepResult.Data!.ToString(), out int activeStepId);

                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    EntityId = GetEntityId(process),
                    EntitySystemIdentifier = GetEntitySystemIdentifier(process),
                    EntityType = GetEntityType(process),
                    AssignedToRoleId = model.AssignedToRoleId != null ? model.AssignedToRoleId!.Value.ToString("D") : "",
                    AssignedToUserId = model.AssignedToUserId != null ? model.AssignedToUserId!.Value.ToString("D") : "",
                    StepType = (ProcessStepType)model.StepTypeId,
                    EndDate = model.EndDate,
                };

                var taskResult = await _taskService.CreateAsync(task);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    return taskResult;
                }

                await SetReadOnlyDataAsync(process.FundSystemIdentifier, false);

                ProcessStepType nextStep = process.ProcessTypeId!.Value == (int)ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStepType.ProcessRawFundWithRawInventory_RegisterInventories
                    : ProcessStepType.ProcessFundWithRawInventory_RegisterInventories;

                activeStepResult = await _processService.SetActiveProcessStepAsync(new ProcessStepModel
                {
                    ProcessId = process.Id.Value,
                    StepTypeId = (int)nextStep
                });

                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                int.TryParse(activeStepResult.Data!.ToString(), out activeStepId);

                transaction.Commit();
                return OperationResult.Succeed(activeStepId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.ProcessRawFundWithRawInventory &&
                process.ProcessTypeId!.Value != (int)ProcessType.ProcessFundWithRawInventory)
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
                ProcessStepType finalStep = process.ProcessTypeId!.Value == (int)ProcessType.ProcessRawFundWithRawInventory
                    ? ProcessStepType.ProcessRawFundWithRawInventory_ProcessFinalization
                    : ProcessStepType.ProcessFundWithRawInventory_ProcessFinalization;

                var activeStepResult = await _processService.SetActiveProcessStepAsync(process.Id!.Value, (int)finalStep);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                if (process.FundSystemIdentifier.HasValue)
                {
                    bool hasDraft = await _fundService.HasCurrentDraftAsync(process.FundSystemIdentifier.Value);
                    if (hasDraft)
                    {
                        var fundSysId = await _fundService.CreateOrUpdateFundFromDraftInternalAsync(process.FundSystemIdentifier.Value);
                    }

                    var inventoryDrafts = await _context.InventoryDrafts
                        .Where(inv => inv.FundSystemIdentifier == process.FundSystemIdentifier.Value && inv.IsCurrent && !inv.Deleted)
                        .ToListAsync();

                    if (await _inventoryService.AnyUnnumberedDraftsByFundIdentifier(process.FundSystemIdentifier.Value)) //(inventoryDrafts.Where(x => String.IsNullOrWhiteSpace(x.Number)).Any())
                    {
                        transaction.Rollback();
                        return OperationResult.Failed(false, _localizer.GetString("Error_MissingInventoryNumber").ToString());
                    }
                    if (await _archivalEntityService.AnyUnnumberedDraftsByFundIdentifier(process.FundSystemIdentifier.Value))
                    {
                        transaction.Rollback();
                        return OperationResult.Failed(false, _localizer.GetString("Error_UnnumberedArchivalEntities").ToString());
                    }
                    if (await _documentService.AnyUnnumberedDraftsByFundIdentifier(process.FundSystemIdentifier.Value))
                    {
                        transaction.Rollback();
                        return OperationResult.Failed(false, _localizer.GetString("Error_UnnumberedDocuments").ToString());
                    }

                    inventoryDrafts.ForEach(x => x.StatusCode = Shared.Status.Registered);
                    _context.UpdateRange(inventoryDrafts);
                    await _context.SaveAsync("Register inventories");

                    var inventoryDraftSysIds = inventoryDrafts.Select(x => x.SystemIdentifier).ToList();
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

                    var digitalObjectDraftSysIds = await _context.DigitalObjectDrafts
                        .Where(d => d.FundSystemIdentifier == process.FundSystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                        .Select(d => d.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in digitalObjectDraftSysIds)
                    {
                        var digitalObjectSysId = await _digitalObjectService.CreateOrUpdateDigitalObjectFromDraftInternalAsync(sysId, true);
                    }
                }

                var rawInventoriesIds = await _context.InventoryRawToNormals
                    .Where(x => x.ProcessId == process.Id.Value && !x.IsRejected)
                    .Select(x => x.RawInventorySystemIdentifier)
                    .ToListAsync();

                var rawInventories = await _context.Inventories
                    .Where(x => rawInventoriesIds.Contains(x.SystemIdentifier))
                    .ToListAsync();

                rawInventories.ForEach(x => x.StatusCode = Shared.Status.Processed);

                await _context.SaveAsync("Process raw inventories");

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

                // complete previous task
                var completePrevTaskResult = await CompletePreviousTask(process.Id.Value, (int)finalStep);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
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


        private async Task<OperationResult> SetReadOnlyDataAsync(Guid? fundSystemIdentifier, bool isReadOnly)
        {
            try
            {
                if (fundSystemIdentifier.HasValue)
                {
                    var fund = await _fundService.GetFundBySystemIdentifierAsync(fundSystemIdentifier.Value);
                    if (fund == null)
                    {
                        return OperationResult.Failed($"Fund {fundSystemIdentifier} does not exists");
                    }

                    int? fundDraftId = fund.IsDraft ? fund.Id : null;

                    if (fundDraftId.HasValue)
                    {
                        var fundDraft = await _fundService.GetCurrentDraftAsync(fundSystemIdentifier!.Value);
                        if (fundDraft == null)
                        {
                            return OperationResult.Failed($"Fund {fundSystemIdentifier} does not have current draft.");
                        }

                        //var modifiedFundDraft = new FundDraftModel()
                        //{
                        //    Id = fundDraft.Id,
                        //    ArchiveId = fundDraft.ArchiveId,
                        //    SystemIdentifier = fundDraft.SystemIdentifier,
                        //    IsCurrent = fundDraft.IsDraft,
                        //    ReadOnly = isReadOnly,
                        //    ExternalIdentifier = fundDraft.ExternalIdentifier,
                        //    HasExternalSource = fundDraft.HasExternalSource,
                        //    NumberArray = fundDraft.NumberArray,
                        //    Number = fundDraft.Number,
                        //    Title = fundDraft.Title,
                        //    DescriptionLevelCode = fundDraft.DescriptionLevelCode,
                        //    TypeCode = fundDraft.TypeCode,
                        //    StatusCode = fundDraft.StatusCode,
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
                        //    NumberNumeric = fundDraft.NumberNumeric,
                        //    AcquisitionMethodId = fundDraft.AcquisitionMethodId,
                        //    FileTypeCodes = fundDraft.FileTypeCodes,
                        //    IndustryTypeCodes = fundDraft.IndustryTypeCodes,
                        //    LanguageCodes = fundDraft.LanguageCodes,
                        //    ApplicationId = fundDraft.ApplicationId,
                        //};
                        var modifiedFundDraft = new FundDraftModel();
                        modifiedFundDraft.Assign(fundDraft);
                        modifiedFundDraft.IsCurrent = fundDraft.IsDraft;
                        modifiedFundDraft.ReadOnly = isReadOnly;

                        await _fundService.UpdateDraftInternalAsync(modifiedFundDraft);

                    }

                    var inventoryDraftSysIds = await _context.InventoryDrafts
                        .Where(inv => inv.FundSystemIdentifier == fundSystemIdentifier.Value && inv.IsCurrent && !inv.Deleted)
                        .Select(inv => inv.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in inventoryDraftSysIds)
                    {
                        var inventoryDraft = await _inventoryService.GetCurrentDraftAsync(sysId);
                        if (inventoryDraft == null)
                        {
                            return OperationResult.Failed($"Inventory {sysId} does not have current draft");
                        }

                        //var modifiedInventoryDraft = new InventoryDraftModel()
                        //{
                        //    Id = inventoryDraft.Id,
                        //    SystemIdentifier = inventoryDraft.SystemIdentifier,
                        //    ArchiveId = inventoryDraft.ArchiveId,
                        //    FundDraftId = inventoryDraft.FundDraftId,
                        //    FundSystemIdentifier = inventoryDraft.FundSystemIdentifier!.Value,
                        //    IsCurrent = inventoryDraft.IsDraft,
                        //    ReadOnly = isReadOnly,
                        //    ExternalIdentifier = inventoryDraft.ExternalIdentifier,
                        //    HasExternalSource = inventoryDraft.HasExternalSource,
                        //    NumberArray = inventoryDraft.NumberArray,
                        //    Number = inventoryDraft.Number,
                        //    DescriptionLevelCode = inventoryDraft.DescriptionLevelCode,
                        //    StatusCode = inventoryDraft.StatusCode,
                        //    HasNoChronologicalScope = inventoryDraft.HasNoChronologicalScope,
                        //    StartDateYear = inventoryDraft.StartDateYear,
                        //    StartDateMonth = inventoryDraft.StartDateMonth,
                        //    StartDateDay = inventoryDraft.StartDateDay,
                        //    EndDateYear = inventoryDraft.EndDateYear,
                        //    EndDateMonth = inventoryDraft.EndDateMonth,
                        //    EndDateDay = inventoryDraft.EndDateDay,
                        //    ApproxmateChronologicalScope = inventoryDraft.ApproxmateChronologicalScope,
                        //    Bytes = inventoryDraft.Bytes,
                        //    LinearMeters = inventoryDraft.LinearMeters,
                        //    OtherMetrics = inventoryDraft.OtherMetrics,
                        //    ArchivalEntityCount = inventoryDraft.ArchivalEntityCount,
                        //    DocumentCount = inventoryDraft.DocumentCount,
                        //    BoxCount = inventoryDraft.BoxCount,
                        //    RollCount = inventoryDraft.RollCount,
                        //    AudioDocumentArchivalEntityCount = inventoryDraft.AudioDocumentArchivalEntityCount,
                        //    PhotoDocumentArchivalEntityCount = inventoryDraft.PhotoDocumentArchivalEntityCount,
                        //    VideoDocumentArchivalEntityCount = inventoryDraft.VideoDocumentArchivalEntityCount,
                        //    DigitalDocumentArchivalEntityCount = inventoryDraft.DigitalDocumentArchivalEntityCount,
                        //    FundCreatorTitleHistory = inventoryDraft.FundCreatorTitleHistory,
                        //    FundCreatorBiographicalHistory = inventoryDraft.FundCreatorBiographicalHistory,
                        //    History = inventoryDraft.History,
                        //    DocumentsProvider = inventoryDraft.DocumentsProvider,
                        //    DocumentsDescription = inventoryDraft.DocumentsDescription,
                        //    DocumentsAccessDescription = inventoryDraft.DocumentsAccessDescription,
                        //    ClassificationScheme = inventoryDraft.ClassificationScheme,
                        //    AbbreviationList = inventoryDraft.AbbreviationList,
                        //    MicrofilmedArchivalEntityCount = inventoryDraft.MicrofilmedArchivalEntityCount,
                        //    DigitizedArchivalEntityCount = inventoryDraft.DigitizedArchivalEntityCount,
                        //    NegativeFrameCount = inventoryDraft.NegativeFrameCount,
                        //    PositiveFrameCount = inventoryDraft.PositiveFrameCount,
                        //    Notes = inventoryDraft.Notes,
                        //    ApplicationId = inventoryDraft.ApplicationId,
                        //    PackageAId = inventoryDraft.PackageAId,
                        //    PackageBId = inventoryDraft.PackageBId,
                        //    AvailabilityStatusCode = inventoryDraft.AvailabilityStatusCode,
                        //    NumberNumeric = inventoryDraft.NumberNumeric,
                        //    AcquisitionMethodId = inventoryDraft.AcquisitionMethodId,
                        //    CreationMethodCodes = inventoryDraft.CreationMethodCodes,
                        //    FileTypeCodes = inventoryDraft.FileTypeCodes,
                        //    LanguageCodes = inventoryDraft.LanguageCodes,
                        //    OriginalityCodes = inventoryDraft.OriginalityCodes,
                        //};
                        var modifiedInventoryDraft = new InventoryDraftModel();
                        modifiedInventoryDraft.Assign(inventoryDraft);
                        modifiedInventoryDraft.IsCurrent = inventoryDraft.IsDraft;
                        modifiedInventoryDraft.ReadOnly = isReadOnly;

                        await _inventoryService.UpdateDraftInternalAsync(modifiedInventoryDraft);
                    }

                    var archivalEntityDraftSysIds = await _context.ArchivalEntityDrafts
                        .Where(ae => ae.FundSystemIdentifier == fundSystemIdentifier.Value && ae.IsCurrent && !ae.Deleted)
                        .Select(ae => ae.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in archivalEntityDraftSysIds)
                    {
                        var archivalEntityDraft = await _archivalEntityService.GetCurrentDraftAsync(sysId);
                        if (archivalEntityDraft == null)
                        {
                            return OperationResult.Failed($"Archival entity {sysId} does not have current draft");
                        }

                        //var modifiedArchivalEntityDraft = new ArchivalEntityDraftModel()
                        //{
                        //    Id = archivalEntityDraft.Id,
                        //    SystemIdentifier = archivalEntityDraft.SystemIdentifier,
                        //    ArchiveId = archivalEntityDraft.ArchiveId,
                        //    FundDraftId = archivalEntityDraft.FundDraftId,
                        //    FundSystemIdentifier = archivalEntityDraft.FundSystemIdentifier!.Value,
                        //    InventoryDraftId = archivalEntityDraft.InventoryDraftId,
                        //    InventorySystemIdentifier = archivalEntityDraft.InventorySystemIdentifier,
                        //    IsCurrent = archivalEntityDraft.IsDraft,
                        //    ReadOnly = isReadOnly,
                        //    ExternalIdentifier = archivalEntityDraft.ExternalIdentifier,
                        //    HasExternalSource = archivalEntityDraft.HasExternalSource,
                        //    Number = archivalEntityDraft.Number,
                        //    Title = archivalEntityDraft.Title,
                        //    DescriptionLevelCode = archivalEntityDraft.DescriptionLevelCode,
                        //    StatusCode = archivalEntityDraft.StatusCode,
                        //    HasNoChronologicalScope = archivalEntityDraft.HasNoChronologicalScope,
                        //    StartDateYear = archivalEntityDraft.StartDateYear,
                        //    StartDateMonth = archivalEntityDraft.StartDateMonth,
                        //    StartDateDay = archivalEntityDraft.StartDateDay,
                        //    EndDateYear = archivalEntityDraft.EndDateYear,
                        //    EndDateMonth = archivalEntityDraft.EndDateMonth,
                        //    EndDateDay = archivalEntityDraft.EndDateDay,
                        //    ApproximateChronologicalScope = archivalEntityDraft.ApproximateChronologicalScope,
                        //    Author = archivalEntityDraft.Author,
                        //    Location = archivalEntityDraft.Location,
                        //    Bytes = archivalEntityDraft.Bytes,
                        //    SheetCount = archivalEntityDraft.SheetCount,
                        //    TapeCount = archivalEntityDraft.TapeCount,
                        //    MicrofilmCount = archivalEntityDraft.MicrofilmCount,
                        //    FrameCount = archivalEntityDraft.FrameCount,
                        //    VideoTapeCount = archivalEntityDraft.VideoTapeCount,
                        //    DigitalDeviceCount = archivalEntityDraft.DigitalDeviceCount,
                        //    OtherMetrics = archivalEntityDraft.OtherMetrics,
                        //    SizeCm = archivalEntityDraft.SizeCm,
                        //    Scaling = archivalEntityDraft.Scaling,
                        //    Description = archivalEntityDraft.Description,
                        //    DocumentsAccessDescription = archivalEntityDraft.DocumentsAccessDescription,
                        //    Features = archivalEntityDraft.Features,
                        //    Condition = archivalEntityDraft.Condition,
                        //    MicrofilmedCopyCount = archivalEntityDraft.MicrofilmedCopyCount,
                        //    DigitizedCopyCount = archivalEntityDraft.DigitizedCopyCount,
                        //    PaperCopyCount = archivalEntityDraft.PaperCopyCount,
                        //    NegativeFrameCount = archivalEntityDraft.NegativeFrameCount,
                        //    PositiveFrameCount = archivalEntityDraft.PositiveFrameCount,
                        //    OtherCopyCount = archivalEntityDraft.OtherCopyCount,
                        //    Notes = archivalEntityDraft.Notes,
                        //    EnrolledBytes = archivalEntityDraft.EnrolledBytes,
                        //    EnrolledDocumentCount = archivalEntityDraft.EnrolledDocumentCount,
                        //    EnrolledLinearMeters = archivalEntityDraft.EnrolledLinearMeters,
                        //    DeductedBytes = archivalEntityDraft.DeductedBytes,
                        //    DeductedDocumentCount = archivalEntityDraft.DeductedDocumentCount,
                        //    DeductedLinearMeters = archivalEntityDraft.DeductedLinearMeters,
                        //    AvailabilityStatusCode = archivalEntityDraft.AvailabilityStatusCode,
                        //    NumberNumeric = archivalEntityDraft.NumberNumeric,
                        //    IsImported = archivalEntityDraft.IsImported,
                        //    NumberArray = archivalEntityDraft.NumberArray,
                        //    DescriptionAuthor = archivalEntityDraft.DescriptionAuthor,
                        //    Cypher = archivalEntityDraft.Cypher,
                        //    TextDocsCount = archivalEntityDraft.TextDocsCount,
                        //    GraphicalDocsCount = archivalEntityDraft.GraphicalDocsCount,
                        //    Phase = archivalEntityDraft.Phase,
                        //    Part = archivalEntityDraft.Part,
                        //    Stage = archivalEntityDraft.Stage,
                        //    OtherLanguage = archivalEntityDraft.OtherLanguage,
                        //    ClassificationSchemeIndex = archivalEntityDraft.ClassificationSchemeIndex,
                        //    CreationMethodCodes = archivalEntityDraft.CreationMethodCodes,
                        //    LanguageCodes = archivalEntityDraft.LanguageCodes,
                        //    OriginalityCodes = archivalEntityDraft.OriginalityCodes,
                        //};
                        var modifiedArchivalEntityDraft = new ArchivalEntityDraftModel();
                        modifiedArchivalEntityDraft.Assign(archivalEntityDraft);
                        modifiedArchivalEntityDraft.IsCurrent = archivalEntityDraft.IsDraft;
                        modifiedArchivalEntityDraft.ReadOnly = isReadOnly;

                        await _archivalEntityService.UpdateDraftInternalAsync(modifiedArchivalEntityDraft);
                    }

                    var documentDraftSysIds = await _context.DocumentDrafts
                        .Where(d => d.FundSystemIdentifier == fundSystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                        .Select(d => d.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in documentDraftSysIds)
                    {
                        var documentDraft = await _documentService.GetCurrentDraftAsync(sysId);
                        if (documentDraft == null)
                        {
                            return OperationResult.Failed($"Document {sysId} does not have current draft.");
                        }

                        //var modifiedDocumentDraft = new DocumentDraftModel()
                        //{
                        //    Id = documentDraft.Id,
                        //    SystemIdentifier = documentDraft.SystemIdentifier,
                        //    ArchiveId = documentDraft.ArchiveId,
                        //    FundDraftId = documentDraft.FundDraftId,
                        //    FundSystemIdentifier = documentDraft.FundSystemIdentifier!.Value,
                        //    InventoryDraftId = documentDraft.InventoryDraftId,
                        //    InventorySystemIdentifier = documentDraft.InventorySystemIdentifier,
                        //    ArchivalEntityDraftId = documentDraft.ArchivalEntityDraftId,
                        //    ArchivalEntitySystemIdentifier = documentDraft.ArchivalEntitySystemIdentifier,
                        //    IsCurrent = documentDraft.IsDraft,
                        //    ReadOnly = isReadOnly,
                        //    ExternalIdentifier = documentDraft.ExternalIdentifier,
                        //    HasExternalSource = documentDraft.HasExternalSource,
                        //    Number = documentDraft.Number,
                        //    Title = documentDraft.Title,
                        //    FileFormatCode = documentDraft.FileFormatCode,
                        //    DescriptionLevelCode = documentDraft.DescriptionLevelCode,
                        //    StatusCode = documentDraft.StatusCode,
                        //    HasNoChronologicalScope = documentDraft.HasNoChronologicalScope,
                        //    StartDateYear = documentDraft.StartDateYear,
                        //    StartDateMonth = documentDraft.StartDateMonth,
                        //    StartDateDay = documentDraft.StartDateDay,
                        //    EndDateYear = documentDraft.EndDateYear,
                        //    EndDateMonth = documentDraft.EndDateMonth,
                        //    EndDateDay = documentDraft.EndDateDay,
                        //    ApproximateChronologicalScope = documentDraft.ApproximateChronologicalScope,
                        //    Author = documentDraft.Author,
                        //    Location = documentDraft.Location,
                        //    Bytes = documentDraft.Bytes,
                        //    SheetCount = documentDraft.SheetCount,
                        //    StartSheetNumber = documentDraft.StartSheetNumber,
                        //    EndSheetNumber = documentDraft.EndSheetNumber,
                        //    DigitalDevice = documentDraft.DigitalDevice,
                        //    OtherMetrics = documentDraft.OtherMetrics,
                        //    SizeCm = documentDraft.SizeCm,
                        //    Scaling = documentDraft.Scaling,
                        //    Duration = documentDraft.Duration,
                        //    Description = documentDraft.Description,
                        //    DocumentsAccessDescription = documentDraft.DocumentsAccessDescription,
                        //    Features = documentDraft.Features,
                        //    MicrofilmedCopyCount = documentDraft.MicrofilmedCopyCount,
                        //    DigitizedCopyCount = documentDraft.DigitizedCopyCount,
                        //    PaperCopyCount = documentDraft.PaperCopyCount,
                        //    NegativeFrameCount = documentDraft.NegativeFrameCount,
                        //    PositiveFrameCount = documentDraft.PositiveFrameCount,
                        //    OtherCopyCount = documentDraft.OtherCopyCount,
                        //    Transcription = documentDraft.Transcription,
                        //    Notes = documentDraft.Notes,
                        //    AvailabilityStatusCode = documentDraft.AvailabilityStatusCode,
                        //    IsImported = documentDraft.IsImported,
                        //    DescriptionAuthor = documentDraft.DescriptionAuthor,
                        //    Cypher = documentDraft.Cypher,
                        //    TextDocsCount = documentDraft.TextDocsCount,
                        //    GraphicalDocsCount = documentDraft.GraphicalDocsCount,
                        //    Phase = documentDraft.Phase,
                        //    Part = documentDraft.Part,
                        //    Stage = documentDraft.Stage,
                        //    OtherLanguage = documentDraft.OtherLanguage,
                        //    CreationMethodCodes = documentDraft.CreationMethodCodes,
                        //    LanguageCodes = documentDraft.LanguageCodes,
                        //    OriginalityCodes = documentDraft.OriginalityCodes,
                        //    FileTypeCodes = documentDraft.FileTypeCodes,
                        //};
                        var modifiedDocumentDraft = new DocumentDraftModel();
                        modifiedDocumentDraft.Assign(documentDraft);
                        modifiedDocumentDraft.IsCurrent = documentDraft.IsDraft;
                        modifiedDocumentDraft.ReadOnly = isReadOnly;

                        await _documentService.UpdateDraftInternalAsync(modifiedDocumentDraft);
                    }
                }

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        private int? GetEntityId(ProcessModel process)
        {
            return process.FundId ?? process.InventoryId ?? process.ArchivalEntityId ?? process.DocumentId;
        }

        private Guid? GetEntitySystemIdentifier(ProcessModel process)
        {
            return process.FundSystemIdentifier
                    ?? process.InventorySystemIdentifier
                    ?? process.ArchivalEntitySystemIdentifier
                    ?? process.DocumentSystemIdentifier;
        }

        private string GetEntityType(ProcessModel process)
        {
            if (process.FundSystemIdentifier.HasValue)
            {
                return BusinessObjectType.Fund;
            }
            if (process.InventorySystemIdentifier.HasValue)
            {
                return BusinessObjectType.Inventory;
            }
            if (process.ArchivalEntitySystemIdentifier.HasValue)
            {
                return BusinessObjectType.ArchivalEntity;
            }
            if (process.DocumentSystemIdentifier.HasValue)
            {
                return BusinessObjectType.Document;
            }
            return BusinessObjectType.Unknown;
        }

        private async Task<OperationResult> UndoProcessChangesInternalAsync(ProcessModel process)
        {
            try
            {
                if (process.FundSystemIdentifier.HasValue)
                {
                    var fund = await _fundService.GetFundBySystemIdentifierAsync(process.FundSystemIdentifier.Value);
                    if (fund == null)
                    {
                        return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                    }

                    Guid fundSysId = process.FundSystemIdentifier.Value;
                    int? fundDraftId = fund.IsDraft ? fund.Id : null;

                    var rawInventoriesToNormals = await _context.InventoryRawToNormals
                        .Where(x => x.ProcessId == process.Id)
                        .ToListAsync();
                    _context.InventoryRawToNormals.RemoveRange(rawInventoriesToNormals);
                    await _context.SaveAsync("Delete raw to normal inventories for process");

                    var digitalObjectDraftIds = await _context.DigitalObjectDrafts
                        .Where(dig =>
                            dig.FundSystemIdentifier == process.FundSystemIdentifier.Value
                            && dig.FundDraftId == fundDraftId
                            && dig.IsCurrent
                            && !dig.Deleted)
                        .Select(dig => dig.Id)
                        .ToListAsync();
                    foreach (int draftId in digitalObjectDraftIds)
                    {
                        await _digitalObjectService.DeleteDraftInternalAsync(draftId);
                    }

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

                    var inventoryDrafts = await _context.InventoryDrafts
                        .Where(inv =>
                            inv.FundSystemIdentifier == process.FundSystemIdentifier.Value
                            && inv.FundDraftId == fundDraftId
                            && inv.IsCurrent
                            && !inv.Deleted)
                        .ToListAsync();
                    foreach (var draftInv in inventoryDrafts)
                    {
                        if (draftInv.PackageBid != null)
                        {
                            await _packagesService.DeletePackageAsync(draftInv.PackageBid.Value);
                        }
                        await _inventoryService.DeleteDraftInternalAsync(draftInv.Id);
                    }

                    if (fundDraftId.HasValue)
                    {
                        await _fundService.DeleteDraftInternalAsync(fundDraftId.Value);
                    }
                }

                var epkReports = await _context.Epkreports
                        .Where(x => x.ProcessId == process.Id!.Value && !x.Deleted)
                        .Select(x => x.Id)
                        .ToListAsync();
                foreach (int reportId in epkReports)
                {
                    await _commissionReportService.DeleteReportInternalAsync(reportId);
                }


                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        private async Task<OperationResult> CompletePreviousTask(int processId, int newStepType)
        {
            try
            {
                ProcessStepType prevStep = ProcessStepType.NoStep;

                switch (newStepType)
                {
                    case (int)ProcessStepType.ProcessRawFundWithRawInventory_SendReport:
                        prevStep = ProcessStepType.ProcessRawFundWithRawInventory_ChangesRequired;
                        break;
                    case (int)ProcessStepType.ProcessFundWithRawInventory_SendReport:
                        prevStep = ProcessStepType.ProcessFundWithRawInventory_ChangesRequired;
                        break;


                    case (int)ProcessStepType.ProcessRawFundWithRawInventory_ChangesRequired:
                    case (int)ProcessStepType.ProcessRawFundWithRawInventory_AddReportToSessionAgenda:
                        prevStep = ProcessStepType.ProcessRawFundWithRawInventory_SendReport;
                        break;
                    case (int)ProcessStepType.ProcessFundWithRawInventory_ChangesRequired:
                    case (int)ProcessStepType.ProcessFundWithRawInventory_AddReportToSessionAgenda:
                        prevStep = ProcessStepType.ProcessFundWithRawInventory_SendReport;
                        break;


                    case (int)ProcessStepType.ProcessRawFundWithRawInventory_SendToAddSessionAgendaStandpointComment:
                        prevStep = ProcessStepType.ProcessRawFundWithRawInventory_SendToAddSessionAgendaStandpoint;
                        break;
                    case (int)ProcessStepType.ProcessFundWithRawInventory_SendToAddSessionAgendaStandpointComment:
                        prevStep = ProcessStepType.ProcessFundWithRawInventory_SendToAddSessionAgendaStandpoint;
                        break;


                    case (int)ProcessStepType.ProcessRawFundWithRawInventory_SendSessionAgendaStandpointComment:
                        prevStep = ProcessStepType.ProcessRawFundWithRawInventory_SendToAddSessionAgendaStandpointComment;
                        break;
                    case (int)ProcessStepType.ProcessFundWithRawInventory_SendSessionAgendaStandpointComment:
                        prevStep = ProcessStepType.ProcessFundWithRawInventory_SendToAddSessionAgendaStandpointComment;
                        break;


                    case (int)ProcessStepType.ProcessRawFundWithRawInventory_CommissionSession:
                        prevStep = ProcessStepType.ProcessRawFundWithRawInventory_SendSessionAgendaStandpointComment;
                        break;
                    case (int)ProcessStepType.ProcessFundWithRawInventory_CommissionSession:
                        prevStep = ProcessStepType.ProcessFundWithRawInventory_SendSessionAgendaStandpointComment;
                        break;


                    case (int)ProcessStepType.ProcessRawFundWithRawInventory_SendForModificationsRevision:
                        prevStep = ProcessStepType.ProcessRawFundWithRawInventory_ReportChangesRequired;
                        break;
                    case (int)ProcessStepType.ProcessFundWithRawInventory_SendForModificationsRevision:
                        prevStep = ProcessStepType.ProcessFundWithRawInventory_ReportChangesRequired;
                        break;


                    case (int)ProcessStepType.ProcessRawFundWithRawInventory_ReportApproval:
                    case (int)ProcessStepType.ProcessRawFundWithRawInventory_ReportChangesRequired:
                    case (int)ProcessStepType.ProcessRawFundWithRawInventory_ReportRejection:
                        prevStep = ProcessStepType.ProcessRawFundWithRawInventory_SendForModificationsRevision;
                        break;
                    case (int)ProcessStepType.ProcessFundWithRawInventory_ReportApproval:
                    case (int)ProcessStepType.ProcessFundWithRawInventory_ReportChangesRequired:
                    case (int)ProcessStepType.ProcessFundWithRawInventory_ReportRejection:
                        prevStep = ProcessStepType.ProcessFundWithRawInventory_SendForModificationsRevision;
                        break;


                    case (int)ProcessStepType.ProcessRawFundWithRawInventory_Affirmation:
                        prevStep = ProcessStepType.ProcessRawFundWithRawInventory_SendForAffirmation;
                        break;
                    case (int)ProcessStepType.ProcessFundWithRawInventory_Affirmation:
                        prevStep = ProcessStepType.ProcessFundWithRawInventory_SendForAffirmation;
                        break;


                    case (int)ProcessStepType.ProcessRawFundWithRawInventory_ProcessFinalization:
                        prevStep = ProcessStepType.ProcessRawFundWithRawInventory_SendToRegistrar;
                        break;
                    case (int)ProcessStepType.ProcessFundWithRawInventory_ProcessFinalization:
                        prevStep = ProcessStepType.ProcessFundWithRawInventory_SendToRegistrar;
                        break;
                }

                OperationResult completeTaskResult = await _taskService.CompletePreviousTask(prevStep, processId, null, null);
                return completeTaskResult;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        private async Task<Guid> CreateEmptyInventory(FundDraft fund, Package? packageB)
        {
            InventoryDraftModel model = new InventoryDraftModel
            {
                ArchiveId = fund.ArchiveId,
                FundSystemIdentifier = fund.SystemIdentifier,
                FundExternalIdentifier = fund.ExternalIdentifier,
                FundHasExternalSource = fund.HasExternalSource.HasValue ? fund.HasExternalSource.Value : false,
                IsCurrent = true,
                ReadOnly = false,
                SystemIdentifier = Guid.NewGuid(),
                DescriptionLevelCode = ((int)Shared.InventoryDescriptionLevel.Inventory).ToString(),
                StatusCode = Shared.Status.New,
                PackageBId = packageB?.Id,
                FundDraftId = fund.Id,
            };


            Guid normalInventoryGuid = await _inventoryService.CreateDraftInternalAsync(model, false);
            if (packageB != null)
            {
                packageB.InventoryIdentifier = normalInventoryGuid;
                _context.Packages.Update(packageB);
            }

            return normalInventoryGuid;
        }


        public async Task<OperationResult> CreateEmptyArchivalEntityDraftFromPackageFilesAsync(Guid inventorySysId, List<int> packageDocuments)
        {
            using var transaction = _context.Database.BeginTransaction();

            try
            {
                var inventory = await _context.VInventories
                    .Where(x => x.SystemIdentifier == inventorySysId && !x.Deleted && x.IsDraft.HasValue && x.IsDraft.Value == true)
                    .FirstOrDefaultAsync();

                if (inventory == null)
                {
                    transaction.Rollback();
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                var inventoryDraft = await _context.InventoryDrafts
                    .Where(x => x.Id == inventory.Id)
                    .FirstOrDefaultAsync();

                if (inventoryDraft == null)
                {
                    transaction.Rollback();
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                var fundDraft = await _context.FundDrafts
                    .Where(x => x.SystemIdentifier == inventoryDraft.FundSystemIdentifier && !x.Deleted && x.IsCurrent)
                    .FirstOrDefaultAsync();

                if (fundDraft == null)
                {
                    transaction.Rollback();
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }


                var docs = await _context.PackageDocuments
                    .Where(x => packageDocuments.Contains(x.Id))
                    .ToListAsync();

                long? totalSizeInBytes = docs.Sum(x => x.FileSizeInBytes);
                List<string> formats = docs.Select(x => x.FileType!).Distinct().ToList();

                OperationResult usedFilesResult = _utilityService.GetUsedFileFormats(formats);
                if (!usedFilesResult.Succeeded)
                {
                    transaction.Rollback();
                    return usedFilesResult;
                }

                List<Nomenclature> usedFiles = (List<Nomenclature>)usedFilesResult.Data!;


                fundDraft.ArchivalEntityCount = (fundDraft.ArchivalEntityCount ?? 0) + 1;
                fundDraft.DocumentCount = (fundDraft.DocumentCount ?? 0) + docs.Count;
                _context.FundDrafts.Update(fundDraft);
                await _context.SaveAsync($"Fund calculations");

                inventoryDraft.Bytes = (inventoryDraft.Bytes ?? 0) + totalSizeInBytes;
                inventoryDraft.ArchivalEntityCount = (inventoryDraft.ArchivalEntityCount ?? 0) + 1;
                inventoryDraft.DocumentCount = (inventoryDraft.DocumentCount ?? 0) + docs.Count;
                inventoryDraft.DigitalDocumentArchivalEntityCount = (inventoryDraft.DigitalDocumentArchivalEntityCount ?? 0) + 1;
                _context.InventoryDrafts.Update(inventoryDraft);
                await _context.SaveAsync($"Inventory calculations");


                IEnumerable<NomenclatureValue>? invNomenclatureValues = _nomenclatureService.GetEntityNomenclatureValues(
                    inventoryDraft.Id, BusinessObjectType.Inventory, true, Shared.NomenclatureCode.FileType);

                IEnumerable<string> selectedValues = usedFiles.Select(x => x.Code).AsEnumerable();
                var inventoryFileTypesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    selectedValues, invNomenclatureValues, Shared.NomenclatureCode.FileType,
                    inventoryDraft.Id, BusinessObjectType.Inventory, true);

                //var inventoryFileTypesToAdd = _utilityService.GetFileTypesToAdd(inventoryDraft.Id, BusinessObjectType.Inventory, usedFiles, true);

                if (inventoryFileTypesToAdd != null && inventoryFileTypesToAdd.Count() > 0)
                {
                    _context.NomenclatureValues.AddRange(inventoryFileTypesToAdd!);
                    await _context.SaveAsync($"Inventory file types added");
                }



                ArchivalEntityDraftModel archivalEntityModel = new ArchivalEntityDraftModel
                {
                    ArchiveId = inventoryDraft.ArchiveId,
                    FundSystemIdentifier = inventoryDraft.FundSystemIdentifier,
                    FundExternalIdentifier = inventory.FundExternalIdentifier,
                    FundHasExternalSource = inventory.FundHasExternalSource.HasValue ? inventory.FundHasExternalSource.Value : false,
                    InventorySystemIdentifier = inventoryDraft.SystemIdentifier,
                    SystemIdentifier = Guid.NewGuid(),
                    DescriptionLevelCode = ((int)Shared.ArchivalEntityDescriptionLevel.ArchivalEntity).ToString(),
                    StatusCode = Shared.Status.New,
                    Bytes = totalSizeInBytes,
                };
                Guid archivalEntityGuid = await _archivalEntityService.CreateDraftInternalAsync(archivalEntityModel);

                foreach (var doc in docs)
                {
                    string pureFileName = doc.FileName!.Replace($".{doc.FileType}", "");
                    var fileFormat = usedFiles.Where(nv => nv.Text.ToLower() == doc.FileType!.ToLower()).FirstOrDefault();

                    DocumentDraftModel docModel = new DocumentDraftModel
                    {
                        ArchiveId = inventoryDraft.ArchiveId,
                        FundSystemIdentifier = inventoryDraft.FundSystemIdentifier,
                        FundExternalIdentifier = inventory.FundExternalIdentifier,
                        FundHasExternalSource = inventory.FundHasExternalSource.HasValue ? inventory.FundHasExternalSource.Value : false,
                        InventorySystemIdentifier = inventoryDraft.SystemIdentifier,
                        ArchivalEntitySystemIdentifier = archivalEntityGuid,
                        SystemIdentifier = Guid.NewGuid(),
                        DescriptionLevelCode = ((int)Shared.DocumentDescriptionLevel.Document).ToString(),
                        StatusCode = Shared.Status.New,
                        Title = pureFileName,
                        Bytes = doc.FileSizeInBytes,
                        FileTypeCodes = fileFormat != null ? new string[] { fileFormat.Code } : null,
                    };
                    Guid docGuid = await _documentService.CreateDraftInternalAsync(docModel);

                    DigitalObjectDraftModel digitalObject = new DigitalObjectDraftModel
                    {
                        ArchiveId = inventoryDraft.ArchiveId,
                        FundSystemIdentifier = inventoryDraft.FundSystemIdentifier,
                        InventorySystemIdentifier = inventoryDraft.SystemIdentifier,
                        ArchivalEntitySystemIdentifier = archivalEntityGuid,
                        DocumentSystemIdentifier = docGuid,
                        TypeCode = (int)DigitalObjectType.MasterFile,
                        StatusCode = Shared.Status.New,
                        ContentType = doc.ContentType,
                        SourceName = doc.FileName,
                        PackageDocumentId = doc.Id,
                        FileSize = doc.FileSizeInBytes ?? 0,
                    };

                    await _digitalObjectService.CreateDraftFromPackageDocumentInternalAsync(doc, digitalObject, true);
                }

                transaction.Commit();

                return OperationResult.Succeed(archivalEntityGuid);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }


        public async Task<OperationResult> DeleteDocumentDraftAsync(int draftId)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await _documentService.DeleteDraftInternalAsync(draftId);

                var documentDraft = await _context.DocumentDrafts.FindAsync(draftId);
                if (documentDraft == null)
                {
                    throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), draftId.ToString());
                }

                var digitalObjectDraftIds = await _context.DigitalObjectDrafts
                .Where(dig =>
                            dig.DocumentSystemIdentifier == documentDraft.SystemIdentifier
                            && dig.IsCurrent
                            && !dig.Deleted)
                        .Select(dig => dig.Id)
                        .ToListAsync();
                foreach (int digDraftId in digitalObjectDraftIds)
                {
                    await _digitalObjectService.DeleteDraftInternalAsync(digDraftId, false, true);
                }

                transaction.Commit();
                return OperationResult.Success;
            }
            catch (ItemNotFoundException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
            catch (ItemDraftNotCurrentException exc)
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


        public async Task<OperationResult> DeleteArchivalEntityDraftAsync(int draftId)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await _archivalEntityService.DeleteDraftInternalAsync(draftId);

                var aeDraft = await _context.ArchivalEntityDrafts.FindAsync(draftId);
                if (aeDraft == null)
                {
                    throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), draftId.ToString());
                }


                var documentDraftIds = await _context.DocumentDrafts
                .Where(doc =>
                            doc.ArchivalEntitySystemIdentifier == aeDraft.SystemIdentifier
                            && doc.IsCurrent
                            && !doc.Deleted)
                        .Select(dig => dig.Id)
                        .ToListAsync();
                foreach (int docDraftId in documentDraftIds)
                {
                    await _documentService.DeleteDraftInternalAsync(docDraftId);
                }

                var digitalObjectDraftIds = await _context.DigitalObjectDrafts
                .Where(dig =>
                            dig.ArchivalEntitySystemIdentifier == aeDraft.SystemIdentifier
                            && dig.IsCurrent
                            && !dig.Deleted)
                        .Select(dig => dig.Id)
                        .ToListAsync();
                foreach (int digDraftId in digitalObjectDraftIds)
                {
                    await _digitalObjectService.DeleteDraftInternalAsync(digDraftId, false, true);
                }

                transaction.Commit();
                return OperationResult.Success;
            }
            catch (ItemNotFoundException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
            catch (ItemDraftNotCurrentException exc)
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

        public async Task<OperationResult> MarkInvaluableFilesAsync(Guid inventorySysId)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var inventory = await _context.VInventories
                    .Where(x => x.SystemIdentifier == inventorySysId && !x.Deleted && x.IsDraft.HasValue && x.IsDraft.Value == true)
                    .FirstOrDefaultAsync();

                if (inventory == null)
                {
                    throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                if (inventory.PackageBid.HasValue)
                {
                    var availablePackageFiles = await _packagesService.GetAvailableRawPackageDocuments(inventory.SystemIdentifier, inventory.PackageBid.Value).ToListAsync();
                    if (availablePackageFiles != null && availablePackageFiles.Count > 0)
                    {
                        var invaluableFiles = availablePackageFiles.Where(x => x.IsInvaluable).ToList(); 
                        if(invaluableFiles.Count > 0)
                        {
                            availablePackageFiles.ForEach(x => x.IsInvaluable = false);                            
                        }
                        else
                        {
                            availablePackageFiles.ForEach(x => x.IsInvaluable = true);
                        }

                        _context.PackageDocuments.UpdateRange(availablePackageFiles);
                        await _context.SaveAsync("Mark invaluable package documents");
                    }
                }

                transaction.Commit();
                return OperationResult.Success;
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

        public async Task<bool> FundHasRawInventoriesInSEAAsync(Guid fundId)
        {
            return await _context.Inventories
                    .Where(inv => 
                        inv.FundSystemIdentifier == fundId 
                        && inv.DescriptionLevelCode == Shared.InventoryDescriptionLevel.RawInventory.ToString("D") 
                        && !inv.Deleted 
                        && !inv.HasExternalSource)
                    .AnyAsync();
        }


    }
}
