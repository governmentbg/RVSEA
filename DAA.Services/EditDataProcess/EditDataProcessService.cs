using DAA.Data;
using DAA.Extensions.Exceptions;
using DAA.Models.Processes;
using DAA.Services.ArchivalEntities;
using DAA.Services.DigitalObjects;
using DAA.Services.Documents;
using DAA.Services.Funds;
using DAA.Services.Inventories;
using DAA.Services.Process;
using DAA.Shared;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using System.Text;
using ProcessType = DAA.Shared.ProcessType;

namespace DAA.Services.EditDataProcess
{
    public class EditDataProcessService : BaseService, IEditDataProcessService
    {
        private readonly IFundService _fundService;
        private readonly IInventoryService _inventoryService;
        private readonly IArchivalEntityService _archivalEntityService;
        private readonly IDocumentService _documentService;
        private readonly IDigitalObjectService _digitalObjectService;
        private readonly IProcessService _processService;

        public EditDataProcessService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IFundService fundService,
            IInventoryService inventoryService,
            IArchivalEntityService archiveEntityService,
            IDocumentService documentService,
            IDigitalObjectService digitalObjectService,
            IProcessService processService)
            : base(context, localizer)
        {
            _fundService = fundService;
            _inventoryService = inventoryService;
            _archivalEntityService = archiveEntityService;
            _documentService = documentService;
            _digitalObjectService = digitalObjectService;
            _processService = processService;
        }

        public async Task<OperationResult> StartProcessAsync(ProcessModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            if (model.ProcessTypeId!.Value != (int)ProcessType.EditData)
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

                var processStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.EditData_ProcessInitiation);
                if (!processStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return processStepResult;
                }

                processStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.EditData_EditData);
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

            if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.EditData)
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
                var activeStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)Shared.ProcessStepType.EditData_ProcessFinalization);
                if (!activeStepResult.Succeeded)
                {
                    return activeStepResult;
                }

                if (process.FundSystemIdentifier.HasValue)
                {
                    bool hasDraft = await _fundService.HasCurrentDraftAsync(process.FundSystemIdentifier.Value);
                    if (hasDraft)
                    { 
                        var fundSysId = await _fundService.CreateOrUpdateFundFromDraftInternalAsync(process.FundSystemIdentifier.Value);
                    }

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
                        var documentDraftSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId);
                    }

                    var digitalObjectDraftSysIds = await _context.DigitalObjectDrafts
                        .Where(dig => dig.FundSystemIdentifier == process.FundSystemIdentifier.Value && dig.IsCurrent && !dig.Deleted)
                        .Select(dig => dig.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in digitalObjectDraftSysIds)
                    {
                        var digitalObjectDraftSysId = await _digitalObjectService.CreateOrUpdateDigitalObjectFromDraftInternalAsync(sysId, false);
                    }
                }

                if (process.InventorySystemIdentifier.HasValue)
                {
                    bool hasDraft = await _inventoryService.HasCurrentDraftAsync(process.InventorySystemIdentifier.Value);
                    if (hasDraft)
                    { 
                        var inventorySysId = await _inventoryService.CreateOrUpdateInventoryFromDraftInternalAsync(process.InventorySystemIdentifier.Value);
                    }

                    var archivalEntityDraftSysIds = await _context.ArchivalEntityDrafts
                        .Where(ae => ae.InventorySystemIdentifier == process.InventorySystemIdentifier.Value && ae.IsCurrent && !ae.Deleted)
                        .Select(ae => ae.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in archivalEntityDraftSysIds)
                    {
                        var archivalEntitySysId = await _archivalEntityService.CreateOrUpdateArchivalEntityFromDraftInternalAsync(sysId);
                    }

                    var documentDraftSysIds = await _context.DocumentDrafts
                        .Where(d => d.InventorySystemIdentifier == process.InventorySystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                        .Select(d => d.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in documentDraftSysIds)
                    {
                        var documentDraftSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId);
                    }

                    var digitalObjectDraftSysIds = await _context.DigitalObjectDrafts
                        .Where(dig => dig.InventorySystemIdentifier == process.InventorySystemIdentifier.Value && dig.IsCurrent && !dig.Deleted)
                        .Select(dig => dig.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in digitalObjectDraftSysIds)
                    {
                        var digitalObjectDraftSysId = await _digitalObjectService.CreateOrUpdateDigitalObjectFromDraftInternalAsync(sysId, false);
                    }
                }
                
                if (process.ArchivalEntitySystemIdentifier.HasValue)
                {
                    bool hasDraft = await _archivalEntityService.HasCurrentDraftAsync(process.ArchivalEntitySystemIdentifier.Value);
                    if (hasDraft)
                    {
                        var archivalEntitySysId = await _archivalEntityService.CreateOrUpdateArchivalEntityFromDraftInternalAsync(process.ArchivalEntitySystemIdentifier.Value);
                    }

                    var documentDraftSysIds = await _context.DocumentDrafts
                        .Where(d => d.ArchivalEntitySystemIdentifier == process.ArchivalEntitySystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                        .Select(d => d.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in documentDraftSysIds)
                    {
                        var documentDraftSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId);
                    }

                    var digitalObjectDraftSysIds = await _context.DigitalObjectDrafts
                        .Where(dig => dig.ArchivalEntitySystemIdentifier == process.ArchivalEntitySystemIdentifier.Value && dig.IsCurrent && !dig.Deleted)
                        .Select(dig => dig.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in digitalObjectDraftSysIds)
                    {
                        var digitalObjectDraftSysId = await _digitalObjectService.CreateOrUpdateDigitalObjectFromDraftInternalAsync(sysId, false);
                    }
                }

                if (process.DocumentSystemIdentifier.HasValue)
                {
                    bool hasDraft = await _documentService.HasCurrentDraftAsync(process.DocumentSystemIdentifier.Value);
                    if (hasDraft)
                    { 
                        var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(process.DocumentSystemIdentifier.Value);
                    }

                    var digitalObjectDraftSysIds = await _context.DigitalObjectDrafts
                        .Where(dig => dig.DocumentSystemIdentifier == process.DocumentSystemIdentifier.Value && dig.IsCurrent && !dig.Deleted)
                        .Select(dig => dig.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in digitalObjectDraftSysIds)
                    {
                        var digitalObjectDraftSysId = await _digitalObjectService.CreateOrUpdateDigitalObjectFromDraftInternalAsync(sysId, false);
                    }
                }

                var processCompleteResult = await _processService.CompleteProcessAsync(processId);
                if(!processCompleteResult.Succeeded)
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

            if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.EditData)
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
                var activeStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)Shared.ProcessStepType.EditFundData_UndoChanges);
                if (!activeStepResult.Succeeded)
                {
                    transaction.Rollback();
                    return activeStepResult;
                }

                if (process.FundSystemIdentifier.HasValue)
                {
                    var fund = await _fundService.GetFundBySystemIdentifierAsync(process.FundSystemIdentifier.Value);
                    if (fund == null)
                    {
                        return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                    }

                    Guid fundSysId = process.FundSystemIdentifier.Value;
                    int? fundDraftId = fund.IsDraft ? fund.Id : null;

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
                }

                if (process.InventorySystemIdentifier.HasValue)
                {
                    var inventory = await _inventoryService.GetInventoryBySystemIdentifierAsync(process.InventorySystemIdentifier.Value);
                    if (inventory == null)
                    {
                        return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                    }

                    Guid inventorySysId = process.InventorySystemIdentifier.Value;
                    int? inventoryDraftId = inventory.IsDraft ? inventory.Id : null;

                    var digitalObjectDraftIds = await _context.DigitalObjectDrafts
                        .Where(dig =>
                            dig.InventorySystemIdentifier == inventorySysId
                            && dig.InventoryDraftId == inventoryDraftId
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
                            d.InventorySystemIdentifier == inventorySysId
                            && d.InventoryDraftId == inventoryDraftId
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
                            ae.InventorySystemIdentifier == inventorySysId
                            && ae.InventoryDraftId == inventoryDraftId
                            && ae.IsCurrent
                            && !ae.Deleted)
                        .Select(ae => ae.Id)
                        .ToListAsync();
                    foreach (int draftId in archivalEntityDraftIds)
                    {
                        await _archivalEntityService.DeleteDraftInternalAsync(draftId);
                    }

                    if (inventoryDraftId.HasValue)
                    {
                        await _inventoryService.DeleteDraftInternalAsync(inventoryDraftId.Value);
                    }
                }

                if (process.ArchivalEntitySystemIdentifier.HasValue)
                {
                    var archivalEntity = await _archivalEntityService.GetArchivalEntityBySystemIdentifierAsync(process.ArchivalEntitySystemIdentifier.Value);
                    if (archivalEntity == null)
                    {
                        return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                    }

                    Guid archivalEntitySysId = process.ArchivalEntitySystemIdentifier.Value;
                    int? archivalEntityDraftId = archivalEntity.IsDraft ? archivalEntity.Id : null;

                    var digitalObjectDraftIds = await _context.DigitalObjectDrafts
                        .Where(dig =>
                            dig.ArchivalEntitySystemIdentifier == archivalEntitySysId
                            && dig.ArchivalEntityDraftId == archivalEntityDraftId
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
                            d.ArchivalEntitySystemIdentifier == archivalEntitySysId
                            && d.ArchivalEntityDraftId == archivalEntityDraftId
                            && d.IsCurrent
                            && !d.Deleted)
                        .Select(d => d.Id)
                        .ToListAsync();
                    foreach (int draftId in documentDraftIds)
                    {
                        await _documentService.DeleteDraftInternalAsync(draftId);
                    }

                    if (archivalEntityDraftId.HasValue)
                    {
                        await _archivalEntityService.DeleteDraftInternalAsync(archivalEntityDraftId.Value);
                    }

                }

                if (process.DocumentSystemIdentifier.HasValue)
                {
                    var document = await _documentService.GetDocumentBySystemIdentifierAsync(process.DocumentSystemIdentifier.Value);
                    if (document == null)
                    {
                        return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                    }

                    Guid documentSysId = process.DocumentSystemIdentifier.Value;
                    int? documentDraftId = document.IsDraft ? document.Id : null;

                    var digitalObjectDraftIds = await _context.DigitalObjectDrafts
                        .Where(dig =>
                            dig.DocumentSystemIdentifier == documentSysId
                            && dig.DocumentDraftId == documentDraftId
                            && dig.IsCurrent
                            && !dig.Deleted)
                        .Select(dig => dig.Id)
                        .ToListAsync();
                    foreach (int draftId in digitalObjectDraftIds)
                    {
                        await _digitalObjectService.DeleteDraftInternalAsync(draftId);
                    }

                    if (documentDraftId.HasValue)
                    {
                        await _documentService.DeleteDraftInternalAsync(documentDraftId.Value);
                    }
                }

                activeStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)Shared.ProcessStepType.EditFundData_ProcessFinalization);
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

        public string GetEntityType(ProcessModel model)
        {
            return _processService.GetEntityType(model);
        }

        public Guid GetEntityId(ProcessModel model)
        {
            return _processService.GetEntitySystemIdentifier(model);
        }

        public async Task<int?> GetEntityArchiveIdAsync(ProcessModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            string entityType = _processService.GetEntityType(model);
            Guid entitySysId = _processService.GetEntitySystemIdentifier(model);
            int? archiveId = null;

            switch (entityType) 
            {
                case BusinessObjectType.Fund:
                    archiveId = await _fundService.GetArchiveIdAsync(entitySysId);
                    break;
                case BusinessObjectType.Inventory:
                    archiveId = await _inventoryService.GetArchiveIdAsync(entitySysId);
                    break;
                case BusinessObjectType.ArchivalEntity:
                    archiveId = await _archivalEntityService.GetArchiveIdAsync(entitySysId);
                    break;
                case BusinessObjectType.Document:
                    archiveId = await _documentService.GetArchiveIdAsync(entitySysId);
                    break;
            }

            return archiveId;
        }

        public async Task<int?> GetEntityArchiveIdAsync(int processId)
        {
            var process = await _processService.GetProcessAsync(processId);
            if (process == null)
            {
                throw new ItemNotFoundException($"Process {processId} does not exists", processId.ToString());
            }

            string entityType = _processService.GetEntityType(process);
            Guid entitySysId = _processService.GetEntitySystemIdentifier(process);
            int? archiveId = null;

            switch (entityType)
            {
                case BusinessObjectType.Fund:
                    archiveId = await _fundService.GetArchiveIdAsync(entitySysId);
                    break;
                case BusinessObjectType.Inventory:
                    archiveId = await _inventoryService.GetArchiveIdAsync(entitySysId);
                    break;
                case BusinessObjectType.ArchivalEntity:
                    archiveId = await _archivalEntityService.GetArchiveIdAsync(entitySysId);
                    break;
                case BusinessObjectType.Document:
                    archiveId = await _documentService.GetArchiveIdAsync(entitySysId);
                    break;
            }

            return archiveId;
        }
    }
}
