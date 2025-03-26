using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Extensions.Models;
using DAA.Models.ArchiveEntities;
using DAA.Models.Documents;
using DAA.Models.FundReconstructions;
using DAA.Models.Inventories;
using DAA.Services.ArchivalEntities;
using DAA.Services.Documents;
using DAA.Services.Funds;
using DAA.Services.Inventories;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;

namespace DAA.Services.FundReconstructions
{
    public class FundReconstructionService : BaseService, IFundReconstructionService
    {
        private readonly IUserInfo _userInfo;
        private readonly IFundService _fundService;
        private readonly IInventoryService _inventoryService;
        private readonly IArchivalEntityService _archivalEntityService;
        private readonly IDocumentService _documentService;

        public FundReconstructionService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IUserInfo userInfo,
            IFundService fundService,
            IInventoryService inventoryService,
            IArchivalEntityService archivalEntityService,
            IDocumentService documentService)
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _fundService = fundService;
            _inventoryService = inventoryService;   
            _archivalEntityService= archivalEntityService;
            _documentService = documentService;
        }

        private async System.Threading.Tasks.Task CreateOrUpdateDocumentDraftAsync(DocumentDisplayModel document, int availabilityStatus)
        {
            //var documentDraft = new DocumentDraftModel()
            //{
            //    Id = document.Id,
            //    IsCurrent = true,
            //    ReadOnly = false,
            //    ArchiveId = document.ArchiveId,
            //    FundDraftId = document.FundDraftId,
            //    //FundExternalIdentifier = document.FundExternalIdentifier,
            //    //FundHasExternalSource = document.FundHasExternalSource,
            //    FundSystemIdentifier = document.FundSystemIdentifier,
            //    InventoryDraftId = document.InventoryDraftId,
            //    //InventoryExternalIdentifier = document.InventoryExternalIdentifier,
            //    //InventoryHasExternalSource = document.InventoryHasExternalSource,
            //    InventorySystemIdentifier = document.InventorySystemIdentifier,
            //    ArchivalEntityDraftId = document.ArchivalEntityDraftId,
            //    //ArchivalEntityExternalIdentifier = document.ArchivalEntityExternalIdentifier,
            //    //ArchivalEntityHasExternalSource = document.ArchivalEntityHasExternalSource,
            //    ArchivalEntitySystemIdentifier = document.ArchivalEntitySystemIdentifier,
            //    ApproximateChronologicalScope = document.ApproximateChronologicalScope,
            //    Author = document.Author,
            //    AvailabilityStatusCode = availabilityStatus,
            //    Bytes = document.Bytes,
            //    CreationMethodCodes = document.CreationMethodCodes,
            //    Description = document.Description,
            //    DescriptionLevelCode = document.DescriptionLevelCode,
            //    DigitalDevice = document.DigitalDevice,
            //    DigitizedCopyCount = document.DigitizedCopyCount,
            //    DocumentsAccessDescription = document.DocumentsAccessDescription,
            //    Duration = document.Duration,
            //    EndDateDay = document.EndDateDay,
            //    EndDateMonth = document.EndDateMonth,
            //    EndDateYear = document.EndDateYear,
            //    EndSheetNumber = document.EndSheetNumber,
            //    ExternalIdentifier = document.ExternalIdentifier,
            //    Features = document.Features,
            //    FileFormatCode = document.FileFormatCode,
            //    FileTypeCodes = document.FileTypeCodes,
            //    HasExternalSource = document.HasExternalSource,
            //    HasNoChronologicalScope = document.HasNoChronologicalScope,
            //    LanguageCodes = document.LanguageCodes,
            //    Location = document.Location,
            //    MicrofilmedCopyCount = document.MicrofilmedCopyCount,
            //    NegativeFrameCount = document.NegativeFrameCount,
            //    Notes = document.Notes,
            //    Number = document.Number,
            //    OriginalityCodes = document.OriginalityCodes,
            //    OtherCopyCount = document.OtherCopyCount,
            //    OtherMetrics = document.OtherMetrics,
            //    PaperCopyCount = document.PaperCopyCount,
            //    PositiveFrameCount = document.PositiveFrameCount,
            //    Scaling = document.Scaling,
            //    SheetCount = document.SheetCount,
            //    SizeCm = document.SizeCm,
            //    StartDateDay = document.StartDateDay,
            //    StartDateMonth = document.StartDateMonth,
            //    StartDateYear = document.StartDateYear,
            //    StartSheetNumber = document.StartSheetNumber,
            //    StatusCode = document.StatusCode,
            //    SystemIdentifier = document.SystemIdentifier,
            //    Title = document.Title,
            //    Transcription = document.Transcription,
            //};
            var documentDraft = new DocumentDraftModel();
            documentDraft.Assign(document);
            documentDraft.IsCurrent = true;
            documentDraft.ReadOnly = false;
            documentDraft.AvailabilityStatusCode = availabilityStatus;

            if (document.IsDraft)
            {
                await _documentService.UpdateDraftInternalAsync(documentDraft);
            }
            else
            {
                await _documentService.CreateDraftInternalAsync(documentDraft);
            }
        }

        private async System.Threading.Tasks.Task CreateOrUpdateArchivalEntityDraftAsync(ArchivalEntityDisplayModel archivalEntity, int availabilityStatus)
        {
            //var archivalEntityDraft = new ArchivalEntityDraftModel()
            //{
            //    Id = archivalEntity.Id,
            //    IsCurrent = true,
            //    ReadOnly = false,
            //    ArchiveId = archivalEntity.ArchiveId,
            //    FundDraftId = archivalEntity.FundDraftId,
            //    //FundExternalIdentifier = archivalEntity.FundExternalIdentifier,
            //    //FundHasExternalSource = archivalEntity.FundHasExternalSource,
            //    FundSystemIdentifier = archivalEntity.FundSystemIdentifier,
            //    InventoryDraftId = archivalEntity.InventoryDraftId,
            //    //InventoryExternalIdentifier = archivalEntity.InventoryExternalIdentifier,
            //    //InventoryHasExternalSource = archivalEntity.InventoryHasExternalSource,
            //    InventorySystemIdentifier = archivalEntity.InventorySystemIdentifier,
            //    AvailabilityStatusCode = availabilityStatus,
            //    ApproximateChronologicalScope = archivalEntity.ApproximateChronologicalScope,
            //    Author = archivalEntity.Author,
            //    Bytes = archivalEntity.Bytes,
            //    Condition = archivalEntity.Condition,
            //    CreationMethodCodes = archivalEntity.CreationMethodCodes,
            //    DeductedBytes = archivalEntity.DeductedBytes,
            //    DeductedDocumentCount = archivalEntity.DeductedDocumentCount,
            //    DeductedLinearMeters = archivalEntity.DeductedLinearMeters,
            //    Description = archivalEntity.Description,
            //    DescriptionLevelCode = archivalEntity.DescriptionLevelCode,
            //    DigitalDeviceCount = archivalEntity.DigitalDeviceCount,
            //    DigitizedCopyCount = archivalEntity.DigitizedCopyCount,
            //    DocumentsAccessDescription = archivalEntity.DocumentsAccessDescription,
            //    EndDateDay = archivalEntity.EndDateDay,
            //    EndDateMonth = archivalEntity.EndDateMonth,
            //    EndDateYear = archivalEntity.EndDateYear,
            //    EnrolledBytes = archivalEntity.EnrolledBytes,
            //    EnrolledDocumentCount = archivalEntity.EnrolledDocumentCount,
            //    EnrolledLinearMeters = archivalEntity.EnrolledLinearMeters,
            //    ExternalIdentifier = archivalEntity.ExternalIdentifier,
            //    Features = archivalEntity.Features,
            //    FrameCount = archivalEntity.FrameCount,
            //    HasExternalSource = archivalEntity.HasExternalSource,
            //    HasNoChronologicalScope = archivalEntity.HasNoChronologicalScope,
            //    LanguageCodes = archivalEntity.LanguageCodes,
            //    Location = archivalEntity.Location,
            //    MicrofilmCount = archivalEntity.MicrofilmCount,
            //    MicrofilmedCopyCount = archivalEntity.MicrofilmedCopyCount,
            //    NegativeFrameCount = archivalEntity.NegativeFrameCount,
            //    Notes = archivalEntity.Notes,
            //    Number = archivalEntity.Number,
            //    OriginalityCodes = archivalEntity.OriginalityCodes,
            //    OtherCopyCount = archivalEntity.OtherCopyCount,
            //    OtherMetrics = archivalEntity.OtherMetrics,
            //    PaperCopyCount = archivalEntity.PaperCopyCount,
            //    PositiveFrameCount = archivalEntity.PositiveFrameCount,
            //    Scaling = archivalEntity.Scaling,
            //    SheetCount = archivalEntity.SheetCount,
            //    SizeCm = archivalEntity.SizeCm,
            //    StartDateDay = archivalEntity.StartDateDay,
            //    StartDateMonth = archivalEntity.StartDateMonth,
            //    StartDateYear = archivalEntity.StartDateYear,
            //    StatusCode = archivalEntity.StatusCode,
            //    SystemIdentifier = archivalEntity.SystemIdentifier,
            //    TapeCount = archivalEntity.TapeCount,
            //    Title = archivalEntity.Title,
            //    VideoTapeCount = archivalEntity.VideoTapeCount,
            //};
            var archivalEntityDraft = new ArchivalEntityDraftModel();
            archivalEntityDraft.Assign(archivalEntity);
            archivalEntityDraft.IsCurrent = true;
            archivalEntityDraft.ReadOnly = false;
            archivalEntityDraft.AvailabilityStatusCode = availabilityStatus;

            if (archivalEntity.IsDraft)
            {
                await _archivalEntityService.UpdateDraftInternalAsync(archivalEntityDraft);
            }
            else
            {
                await _archivalEntityService.CreateDraftInternalAsync(archivalEntityDraft);
            }
        }

        private async System.Threading.Tasks.Task CreateOrUpdateInventoryDraftAsync(InventoryDisplayModel inventory, int availabilityStatus)
        {
            //var inventoryDraft = new InventoryDraftModel()
            //{
            //    Id = inventory.Id,
            //    IsCurrent = true,
            //    ReadOnly = false,
            //    ArchiveId = inventory.ArchiveId,
            //    FundDraftId = inventory.FundDraftId,
            //    //FundExternalIdentifier = inventory.FundExternalIdentifier,
            //    //FundHasExternalSource = inventory.FundHasExternalSource,
            //    FundSystemIdentifier = inventory.FundSystemIdentifier,
            //    AvailabilityStatusCode = availabilityStatus,
            //    AbbreviationList = inventory.AbbreviationList,
            //    AcquisitionMethodId= inventory.AcquisitionMethodId,
            //    //AcquisitionMethodCodes = inventory.AcquisitionMethodCodes,
            //    SystemIdentifier = inventory.SystemIdentifier,
            //    ApplicationId = inventory.ApplicationId,
            //    ApproxmateChronologicalScope = inventory.ApproxmateChronologicalScope,
            //    ArchivalEntityCount = inventory.ArchivalEntityCount,
            //    AudioDocumentArchivalEntityCount = inventory.AudioDocumentArchivalEntityCount,
            //    BoxCount = inventory.BoxCount,
            //    Bytes = inventory.Bytes,
            //    ClassificationScheme = inventory.ClassificationScheme,
            //    CreationMethodCodes = inventory.CreationMethodCodes,
            //    DescriptionLevelCode = inventory.DescriptionLevelCode,
            //    DigitalDocumentArchivalEntityCount = inventory.DigitalDocumentArchivalEntityCount,
            //    DigitizedArchivalEntityCount = inventory.DigitizedArchivalEntityCount,
            //    DocumentCount = inventory.DocumentCount,
            //    DocumentsAccessDescription = inventory.DocumentsAccessDescription,
            //    DocumentsDescription = inventory.DocumentsDescription,
            //    DocumentsProvider = inventory.DocumentsProvider,
            //    EndDateDay = inventory.EndDateDay,
            //    EndDateMonth = inventory.EndDateMonth,
            //    EndDateYear = inventory.EndDateYear,
            //    ExternalIdentifier = inventory.ExternalIdentifier,
            //    FileTypeCodes = inventory.FileTypeCodes,
            //    FundCreatorBiographicalHistory = inventory.FundCreatorBiographicalHistory,
            //    FundCreatorTitleHistory = inventory.FundCreatorTitleHistory,
            //    HasExternalSource = inventory.HasExternalSource,
            //    HasNoChronologicalScope = inventory.HasNoChronologicalScope,
            //    History = inventory.History,
            //    LanguageCodes = inventory.LanguageCodes,
            //    LinearMeters = inventory.LinearMeters,
            //    MicrofilmedArchivalEntityCount = inventory.MicrofilmedArchivalEntityCount,
            //    NegativeFrameCount = inventory.NegativeFrameCount,
            //    Notes = inventory.Notes,
            //    Number = inventory.Number,
            //    NumberArray = inventory.NumberArray,
            //    OriginalityCodes = inventory.OriginalityCodes,
            //    OtherMetrics = inventory.OtherMetrics,
            //    PhotoDocumentArchivalEntityCount = inventory.PhotoDocumentArchivalEntityCount,
            //    PositiveFrameCount = inventory.PositiveFrameCount,
            //    RollCount = inventory.RollCount,
            //    StartDateDay = inventory.StartDateDay,
            //    StartDateMonth = inventory.StartDateMonth,
            //    StartDateYear = inventory.StartDateYear,
            //    StatusCode = inventory.StatusCode,
            //    VideoDocumentArchivalEntityCount = inventory.VideoDocumentArchivalEntityCount,
            //};
            var inventoryDraft = new InventoryDraftModel();
            inventoryDraft.Assign(inventory);
            inventoryDraft.IsCurrent = true;
            inventoryDraft.ReadOnly = false;
            inventoryDraft.AvailabilityStatusCode = availabilityStatus;

            if (inventory.IsDraft)
            {
                await _inventoryService.UpdateDraftInternalAsync(inventoryDraft);
            }
            else
            {
                await _inventoryService.CreateDraftInternalAsync(inventoryDraft, false);
            }
        }

        private async System.Threading.Tasks.Task CreateOrUpdateReconstructionSourceDraftsAsync(FundReconstructionModel reconstruction)
        {
            if (reconstruction.SourceDocumentSystemIdentifier.HasValue)
            {
                var document =
                    await _documentService.GetDocumentBySystemIdentifierAsync(reconstruction.SourceDocumentSystemIdentifier.Value);

                if (document == null)
                {
                    throw new ItemNotFoundException(
                        $"Document {reconstruction.SourceDocumentSystemIdentifier} does not exists",
                        reconstruction.SourceDocumentSystemIdentifier.ToString()!);
                }
                if (document.HasExternalSource.HasValue && document.HasExternalSource.Value)
                {
                    throw new Exception($"Document {reconstruction.SourceDocumentSystemIdentifier} is from external source");
                }

                await CreateOrUpdateDocumentDraftAsync(document, reconstruction.AvailabilityStatusCode);
            }
            else if (reconstruction.SourceArchivalEntitySystemIdentifier.HasValue)
            {
                var archivalEntity =
                    await _archivalEntityService.GetArchivalEntityBySystemIdentifierAsync(reconstruction.SourceArchivalEntitySystemIdentifier.Value);

                if (archivalEntity == null)
                {
                    throw new ItemNotFoundException(
                        $"Archival entity {reconstruction.SourceArchivalEntitySystemIdentifier} does not exists",
                        reconstruction.SourceArchivalEntitySystemIdentifier.ToString()!);
                }
                if (archivalEntity.HasExternalSource && archivalEntity.HasExternalSource)
                {
                    throw new Exception($"Archival entity {reconstruction.SourceArchivalEntitySystemIdentifier} is from external source");
                }

                await CreateOrUpdateArchivalEntityDraftAsync(archivalEntity, reconstruction.AvailabilityStatusCode);

                //TODO Add Get method in document service for full document data 
                var documentSystemIdentifiers = _context.VDocuments
                                                .Where(doc => doc.ArchivalEntitySystemIdentifier == archivalEntity.SystemIdentifier
                                                                && !doc.Deleted
                                                                && (!doc.HasExternalSource.HasValue || !doc.HasExternalSource.Value))
                                                .Select(doc => doc.SystemIdentifier);

                foreach (var docSystemIdentifier in documentSystemIdentifiers)
                {
                    var document = await _documentService.GetDocumentBySystemIdentifierAsync(docSystemIdentifier);
                    if (document == null)
                    {
                        throw new ItemNotFoundException($"Document {docSystemIdentifier} does not exists", docSystemIdentifier.ToString());
                    }

                    if (!archivalEntity.IsDraft)
                    {
                        document.ArchivalEntityDraftId = null;
                    }

                    await CreateOrUpdateDocumentDraftAsync(document, reconstruction.AvailabilityStatusCode);
                }
            }
            else if (reconstruction.SourceInventorySystemIdentifier.HasValue)
            {
                var inventory =
                    await _inventoryService.GetInventoryBySystemIdentifierAsync(reconstruction.SourceInventorySystemIdentifier.Value);

                if (inventory == null)
                {
                    throw new ItemNotFoundException(
                        $"Inventory {reconstruction.SourceInventorySystemIdentifier} does not exists",
                        reconstruction.SourceInventorySystemIdentifier.ToString()!);
                }
                if (inventory.HasExternalSource && inventory.HasExternalSource)
                {
                    throw new Exception($"Inventory {reconstruction.SourceInventorySystemIdentifier} is from external source");
                }

                await CreateOrUpdateInventoryDraftAsync(inventory, reconstruction.AvailabilityStatusCode);

                //TODO Add get method in AE service for full AE data
                var archivalEntitySystemIdentifiers = _context.VArchivalEntities
                                                        .Where(ae => ae.InventorySystemIdentifier == inventory.SystemIdentifier
                                                                    && !ae.Deleted
                                                                    && (!ae.HasExternalSource.HasValue || !ae.HasExternalSource.Value))
                                                        .Select(ae => ae.SystemIdentifier);
                foreach (var aeSystemIdentifier in archivalEntitySystemIdentifiers)
                {
                    var archivalEntity = await _archivalEntityService.GetArchivalEntityBySystemIdentifierAsync(aeSystemIdentifier);
                    if (archivalEntity == null)
                    {
                        throw new ItemNotFoundException($"Archival entity {aeSystemIdentifier} does not exists", aeSystemIdentifier.ToString());
                    }

                    if (!inventory.IsDraft)
                    {
                        archivalEntity.InventoryDraftId = null;
                    }

                    await CreateOrUpdateArchivalEntityDraftAsync(archivalEntity, reconstruction.AvailabilityStatusCode);
                }

                var documentSystemIdentifiers = _context.VDocuments
                                                .Where(doc => doc.InventorySystemIdentifier == inventory.SystemIdentifier
                                                                && !doc.Deleted
                                                                && (!doc.HasExternalSource.HasValue || !doc.HasExternalSource.Value))
                                                .Select(doc => doc.SystemIdentifier);

                foreach (var docSystemIdentifier in documentSystemIdentifiers)
                {
                    var document = await _documentService.GetDocumentBySystemIdentifierAsync(docSystemIdentifier);
                    if (document == null)
                    {
                        throw new ItemNotFoundException($"Document {docSystemIdentifier} does not exists", docSystemIdentifier.ToString());
                    }

                    if (!inventory.IsDraft)
                    {
                        document.InventoryDraftId = null;
                        document.ArchivalEntityDraftId = null;
                    }

                    await CreateOrUpdateDocumentDraftAsync(document, reconstruction.AvailabilityStatusCode);
                }
            }
        }

        private async System.Threading.Tasks.Task DeleteReconstructionSourceDraftsAsync(FundReconstruction reconstruction)
        {
            if (reconstruction.SourceDocumentSystemIdentifier.HasValue)
            {
                var document =
                    await _documentService.GetDocumentBySystemIdentifierAsync(reconstruction.SourceDocumentSystemIdentifier.Value);

                if (document == null)
                {
                    throw new ItemNotFoundException(
                        $"Document {reconstruction.SourceDocumentSystemIdentifier} does not exists",
                        reconstruction.SourceDocumentSystemIdentifier.ToString()!);
                }
                if (document.HasExternalSource.HasValue && document.HasExternalSource.Value)
                {
                    throw new Exception($"Document {reconstruction.SourceDocumentSystemIdentifier} is from external source");
                }

                if (document.IsDraft)
                {
                    await _documentService.DeleteDraftInternalAsync(document.Id!.Value);
                }
            }
            else if (reconstruction.SourceArchivalEntitySystemIdentifier.HasValue)
            {
                var archivalEntity =
                    await _archivalEntityService.GetArchivalEntityBySystemIdentifierAsync(reconstruction.SourceArchivalEntitySystemIdentifier.Value);

                if (archivalEntity == null)
                {
                    throw new ItemNotFoundException(
                        $"Archival entity {reconstruction.SourceArchivalEntitySystemIdentifier} does not exists",
                        reconstruction.SourceArchivalEntitySystemIdentifier.ToString()!);
                }
                if (archivalEntity.HasExternalSource && archivalEntity.HasExternalSource)
                {
                    throw new Exception($"Archival entity {reconstruction.SourceArchivalEntitySystemIdentifier} is from external source");
                }

                if (archivalEntity.IsDraft)
                {
                    await _archivalEntityService.DeleteDraftInternalAsync(archivalEntity.Id!.Value);
                }
                
                //TODO Add Get method in document service for full document data 
                var documentSystemIdentifiers = _context.VDocuments
                                                .Where(doc => doc.ArchivalEntitySystemIdentifier == archivalEntity.SystemIdentifier
                                                                && !doc.Deleted
                                                                && (!doc.HasExternalSource.HasValue || !doc.HasExternalSource.Value))
                                                .Select(doc => doc.SystemIdentifier);

                foreach (var docSystemIdentifier in documentSystemIdentifiers)
                {
                    var document = await _documentService.GetDocumentBySystemIdentifierAsync(docSystemIdentifier);
                    if (document == null)
                    {
                        throw new ItemNotFoundException($"Document {docSystemIdentifier} does not exists", docSystemIdentifier.ToString());
                    }

                    if (document.IsDraft)
                    {
                        await _documentService.DeleteDraftInternalAsync(document.Id!.Value);
                    }
                }
            }
            else if (reconstruction.SourceInventorySystemIdentifier.HasValue)
            {
                var inventory =
                    await _inventoryService.GetInventoryBySystemIdentifierAsync(reconstruction.SourceInventorySystemIdentifier.Value);

                if (inventory == null)
                {
                    throw new ItemNotFoundException(
                        $"Inventory {reconstruction.SourceInventorySystemIdentifier} does not exists",
                        reconstruction.SourceInventorySystemIdentifier.ToString()!);
                }
                if (inventory.HasExternalSource && inventory.HasExternalSource)
                {
                    throw new Exception($"Inventory {reconstruction.SourceInventorySystemIdentifier} is from external source");
                }

                if (inventory.IsDraft)
                {
                    await _inventoryService.DeleteDraftInternalAsync(inventory.Id!.Value);
                }
                
                //TODO Add get method in AE service for full AE data
                var archivalEntitySystemIdentifiers = _context.VArchivalEntities
                                                        .Where(ae => ae.InventorySystemIdentifier == inventory.SystemIdentifier
                                                                    && !ae.Deleted
                                                                    && (!ae.HasExternalSource.HasValue || !ae.HasExternalSource.Value))
                                                        .Select(ae => ae.SystemIdentifier);
                foreach (var aeSystemIdentifier in archivalEntitySystemIdentifiers)
                {
                    var archivalEntity = await _archivalEntityService.GetArchivalEntityBySystemIdentifierAsync(aeSystemIdentifier);
                    if (archivalEntity == null)
                    {
                        throw new ItemNotFoundException($"Archival entity {aeSystemIdentifier} does not exists", aeSystemIdentifier.ToString());
                    }

                    if (archivalEntity.IsDraft)
                    {
                        await _archivalEntityService.DeleteDraftInternalAsync(archivalEntity.Id!.Value);
                    }
                }

                var documentSystemIdentifiers = _context.VDocuments
                                                .Where(doc => doc.InventorySystemIdentifier == inventory.SystemIdentifier
                                                                && !doc.Deleted
                                                                && (!doc.HasExternalSource.HasValue || !doc.HasExternalSource.Value))
                                                .Select(doc => doc.SystemIdentifier);

                foreach (var docSystemIdentifier in documentSystemIdentifiers)
                {
                    var document = await _documentService.GetDocumentBySystemIdentifierAsync(docSystemIdentifier);
                    if (document == null)
                    {
                        throw new ItemNotFoundException($"Document {docSystemIdentifier} does not exists", docSystemIdentifier.ToString());
                    }

                    if (document.IsDraft)
                    {
                        await _documentService.DeleteDraftInternalAsync(document.Id!.Value);
                    }
                }
            }
        }

        private async System.Threading.Tasks.Task DeleteReconstructionTargetDraftsAsync(FundReconstruction reconstruction)
        {
            if (reconstruction.TargetDocumentSystemIdentifier.HasValue)
            {
                var document =
                    await _documentService.GetDocumentBySystemIdentifierAsync(reconstruction.TargetDocumentSystemIdentifier.Value);

                if (document == null)
                {
                    throw new ItemNotFoundException(
                        $"Document {reconstruction.TargetDocumentSystemIdentifier} does not exists",
                        reconstruction.TargetDocumentSystemIdentifier.ToString()!);
                }
                if (document.HasExternalSource.HasValue && document.HasExternalSource.Value)
                {
                    throw new Exception($"Document {reconstruction.TargetDocumentSystemIdentifier} is from external source");
                }

                if (document.IsDraft)
                {
                    await _documentService.DeleteDraftInternalAsync(document.Id!.Value);
                }
            }
            else if (reconstruction.TargetArchivalEntitySystemIdentifier.HasValue)
            {
                var archivalEntity =
                    await _archivalEntityService.GetArchivalEntityBySystemIdentifierAsync(reconstruction.TargetArchivalEntitySystemIdentifier.Value);

                if (archivalEntity == null)
                {
                    throw new ItemNotFoundException(
                        $"Archival entity {reconstruction.TargetArchivalEntitySystemIdentifier} does not exists",
                        reconstruction.TargetArchivalEntitySystemIdentifier.ToString()!);
                }
                if (archivalEntity.HasExternalSource && archivalEntity.HasExternalSource)
                {
                    throw new Exception($"Archival entity {reconstruction.TargetArchivalEntitySystemIdentifier} is from external source");
                }

                //Взимат се само документите, които отговарят на SourceArchivalEntitySystemIdentifier
                var sourceArchivalEntityDocumentSysIds =
                    _context.Documents
                    .Where(doc =>
                        doc.ArchivalEntitySystemIdentifier == reconstruction.SourceArchivalEntitySystemIdentifier
                        && !doc.Deleted
                        && !doc.HasExternalSource)
                    .Select(doc => doc.SystemIdentifier);


                var documentSystemIdentifiers = _context.VDocuments
                                                .Where(doc => doc.ArchivalEntitySystemIdentifier == archivalEntity.SystemIdentifier
                                                                && !doc.Deleted
                                                                && (!doc.HasExternalSource.HasValue || !doc.HasExternalSource.Value)
                                                                && sourceArchivalEntityDocumentSysIds.Contains(doc.SystemIdentifier))
                                                .Select(doc => doc.SystemIdentifier);

                foreach (var docSystemIdentifier in documentSystemIdentifiers)
                {
                    var document = await _documentService.GetDocumentBySystemIdentifierAsync(docSystemIdentifier);
                    if (document == null)
                    {
                        throw new ItemNotFoundException($"Document {docSystemIdentifier} does not exists", docSystemIdentifier.ToString());
                    }

                    if (document.IsDraft)
                    {
                        await _documentService.DeleteDraftInternalAsync(document.Id!.Value);
                    }
                }

                //Target-а се изтрива само ако е празна
                bool targetHasAnyDocuments =
                    await _context.VDocuments
                    .Where(doc => 
                        doc.ArchivalEntitySystemIdentifier == archivalEntity.SystemIdentifier
                        && !doc.Deleted)
                    .AnyAsync();
                
                if (archivalEntity.IsDraft && !targetHasAnyDocuments)
                {
                    await _archivalEntityService.DeleteDraftInternalAsync(archivalEntity.Id!.Value);
                }
            }
            else if (reconstruction.TargetInventorySystemIdentifier.HasValue)
            {
                var inventory =
                    await _inventoryService.GetInventoryBySystemIdentifierAsync(reconstruction.TargetInventorySystemIdentifier.Value);

                if (inventory == null)
                {
                    throw new ItemNotFoundException(
                        $"Inventory {reconstruction.TargetInventorySystemIdentifier} does not exists",
                        reconstruction.TargetInventorySystemIdentifier.ToString()!);
                }
                if (inventory.HasExternalSource && inventory.HasExternalSource)
                {
                    throw new Exception($"Inventory {reconstruction.TargetInventorySystemIdentifier} is from external source");
                }

                //Взимат се само документите, които отговарят на SourceInventorySystemIdentifier
                var sourceInventoryDocumentSysIds =
                    _context.Documents
                    .Where(doc =>
                        doc.InventorySystemIdentifier == reconstruction.SourceInventorySystemIdentifier
                        && !doc.Deleted
                        && !doc.HasExternalSource)
                    .Select(doc => doc.SystemIdentifier);

                var documentSystemIdentifiers = _context.VDocuments
                                                .Where(doc => doc.InventorySystemIdentifier == inventory.SystemIdentifier
                                                                && !doc.Deleted
                                                                && (!doc.HasExternalSource.HasValue || !doc.HasExternalSource.Value)
                                                                && sourceInventoryDocumentSysIds.Contains(doc.SystemIdentifier))
                                                .Select(doc => doc.SystemIdentifier);

                foreach (var docSystemIdentifier in documentSystemIdentifiers)
                {
                    var document = await _documentService.GetDocumentBySystemIdentifierAsync(docSystemIdentifier);
                    if (document == null)
                    {
                        throw new ItemNotFoundException($"Document {docSystemIdentifier} does not exists", docSystemIdentifier.ToString());
                    }

                    if (document.IsDraft)
                    {
                        await _documentService.DeleteDraftInternalAsync(document.Id!.Value);
                    }
                }

                //Взимат се само архивните единици, които отговарят на SourceInventorySystemIdentifier
                var sourceInventoryArchivalEntitiesSysIds =
                    _context.ArchivalEntities
                    .Where(ае =>
                        ае.InventorySystemIdentifier == reconstruction.SourceInventorySystemIdentifier
                        && !ае.Deleted
                        && !ае.HasExternalSource)
                    .Select(ае => ае.SystemIdentifier);

                var archivalEntitySystemIdentifiers = _context.VArchivalEntities
                                                        .Where(ae => ae.InventorySystemIdentifier == inventory.SystemIdentifier
                                                                    && !ae.Deleted
                                                                    && (!ae.HasExternalSource.HasValue || !ae.HasExternalSource.Value)
                                                                    && sourceInventoryArchivalEntitiesSysIds.Contains(ae.SystemIdentifier))
                                                        .Select(ae => ae.SystemIdentifier);

                foreach (var aeSystemIdentifier in archivalEntitySystemIdentifiers)
                {
                    var archivalEntity = await _archivalEntityService.GetArchivalEntityBySystemIdentifierAsync(aeSystemIdentifier);
                    if (archivalEntity == null)
                    {
                        throw new ItemNotFoundException($"Archival entity {aeSystemIdentifier} does not exists", aeSystemIdentifier.ToString());
                    }

                    if (archivalEntity.IsDraft)
                    {
                        await _archivalEntityService.DeleteDraftInternalAsync(archivalEntity.Id!.Value);
                    }
                }

                //Target-a се изтрива само ако е празен
                bool targetHasAnyArchivalEntities =
                await _context.VArchivalEntities
                    .Where(ae => 
                        ae.InventorySystemIdentifier == inventory.SystemIdentifier
                        && !ae.Deleted)
                    .AnyAsync();

                if (inventory.IsDraft && !targetHasAnyArchivalEntities)
                {
                    await _inventoryService.DeleteDraftInternalAsync(inventory.Id!.Value);
                }
            }
        }

        private async System.Threading.Tasks.Task DeductReconstructionSourceAsync(FundReconstructionModel reconstruction)
        {
            if (reconstruction.AvailabilityStatusCode != (int)Shared.AvailabilityStatus.DisposalDeduction)
            {
                throw new InvalidOperationException($"Fund reconstruction {reconstruction.Id} is not disposal");
            }

            if (reconstruction.SourceDocumentSystemIdentifier.HasValue)
            {
                var document = await _documentService.GetDocumentBySystemIdentifierAsync(reconstruction.SourceDocumentSystemIdentifier.Value);
                if (document == null)
                {
                    throw new ItemNotFoundException(
                        $"Document {reconstruction.SourceDocumentSystemIdentifier} does not exists",
                        reconstruction.SourceDocumentSystemIdentifier.ToString()!);
                }
                if (document.HasExternalSource.HasValue && document.HasExternalSource.Value)
                {
                    throw new Exception($"Archival entity {reconstruction.SourceDocumentSystemIdentifier} is from external source");
                }

                document.StatusCode = Shared.Status.Deducted;

                await CreateOrUpdateDocumentDraftAsync(document, reconstruction.AvailabilityStatusCode);
            }
            else if (reconstruction.SourceArchivalEntitySystemIdentifier.HasValue)
            {
                var archivalEntity =
                    await _archivalEntityService.GetArchivalEntityBySystemIdentifierAsync(reconstruction.SourceArchivalEntitySystemIdentifier.Value);

                if (archivalEntity == null)
                {
                    throw new ItemNotFoundException(
                        $"Archival entity {reconstruction.SourceArchivalEntitySystemIdentifier} does not exists",
                        reconstruction.SourceArchivalEntitySystemIdentifier.ToString()!);
                }
                if (archivalEntity.HasExternalSource)
                {
                    throw new Exception($"Archival entity {reconstruction.SourceArchivalEntitySystemIdentifier} is from external source");
                }

                archivalEntity.StatusCode = Shared.Status.Deducted;

                await CreateOrUpdateArchivalEntityDraftAsync(archivalEntity, reconstruction.AvailabilityStatusCode);

                //TODO Add Get method in document service for full document data 
                var documentSystemIdentifiers = _context.VDocuments
                                                .Where(doc => doc.ArchivalEntitySystemIdentifier == archivalEntity.SystemIdentifier
                                                                && !doc.Deleted
                                                                && (!doc.HasExternalSource.HasValue || !doc.HasExternalSource.Value))
                                                .Select(doc => doc.SystemIdentifier);

                foreach (var docSystemIdentifier in documentSystemIdentifiers)
                {
                    var document = await _documentService.GetDocumentBySystemIdentifierAsync(docSystemIdentifier);
                    if (document == null)
                    {
                        throw new ItemNotFoundException($"Document {docSystemIdentifier} does not exists", docSystemIdentifier.ToString());
                    }
                    
                    document.StatusCode = Shared.Status.Deducted;

                    await CreateOrUpdateDocumentDraftAsync(document, reconstruction.AvailabilityStatusCode);
                }
            }
            else if (reconstruction.SourceInventorySystemIdentifier.HasValue)
            {
                var inventory =
                    await _inventoryService.GetInventoryBySystemIdentifierAsync(reconstruction.SourceInventorySystemIdentifier.Value);

                if (inventory == null)
                {
                    throw new ItemNotFoundException(
                        $"Inventory {reconstruction.SourceInventorySystemIdentifier} does not exists",
                        reconstruction.SourceInventorySystemIdentifier.ToString()!);
                }
                if (inventory.HasExternalSource)
                {
                    throw new Exception($"Inventory {reconstruction.SourceInventorySystemIdentifier} is from external source");
                }

                inventory.StatusCode = Shared.Status.Deducted;

                await CreateOrUpdateInventoryDraftAsync(inventory, reconstruction.AvailabilityStatusCode);

                //TODO Add get method in AE service for full AE data
                var archivalEntitySystemIdentifiers = _context.VArchivalEntities
                                                        .Where(ae => ae.InventorySystemIdentifier == inventory.SystemIdentifier
                                                                    && !ae.Deleted
                                                                    && (!ae.HasExternalSource.HasValue || !ae.HasExternalSource.Value))
                                                        .Select(ae => ae.SystemIdentifier);
                foreach (var aeSystemIdentifier in archivalEntitySystemIdentifiers)
                {
                    var archivalEntity = await _archivalEntityService.GetArchivalEntityBySystemIdentifierAsync(aeSystemIdentifier);
                    if (archivalEntity == null)
                    {
                        throw new ItemNotFoundException($"Archival entity {aeSystemIdentifier} does not exists", aeSystemIdentifier.ToString());
                    }

                    archivalEntity.StatusCode = Shared.Status.Deducted;

                    await CreateOrUpdateArchivalEntityDraftAsync(archivalEntity, reconstruction.AvailabilityStatusCode);
                }

                var documentSystemIdentifiers = _context.VDocuments
                                                .Where(doc => doc.InventorySystemIdentifier == inventory.SystemIdentifier
                                                                && !doc.Deleted
                                                                && (!doc.HasExternalSource.HasValue || !doc.HasExternalSource.Value))
                                                .Select(doc => doc.SystemIdentifier);

                foreach (var docSystemIdentifier in documentSystemIdentifiers)
                {
                    var document = await _documentService.GetDocumentBySystemIdentifierAsync(docSystemIdentifier);
                    if (document == null)
                    {
                        throw new ItemNotFoundException($"Document {docSystemIdentifier} does not exists", docSystemIdentifier.ToString());
                    }

                    document.StatusCode = Shared.Status.Deducted;

                    await CreateOrUpdateDocumentDraftAsync(document, reconstruction.AvailabilityStatusCode);
                }
            }
        }

        private async System.Threading.Tasks.Task MoveReconstructionSourceToTargetAsync(FundReconstructionModel reconstruction)
        {
            if (reconstruction.AvailabilityStatusCode != (int)Shared.AvailabilityStatus.RelocationDeduction)
            {
                throw new InvalidOperationException($"Fund reconstruction {reconstruction.Id} is not relocation");
            }

            if (reconstruction.TargetDocumentSystemIdentifier.HasValue
                && reconstruction.TargetArchivalEntitySystemIdentifier.HasValue
                && reconstruction.TargetInventorySystemIdentifier.HasValue
                && reconstruction.TargetDocumentSystemIdentifier != reconstruction.SourceDocumentSystemIdentifier)
            {
                throw new InvalidOperationException(
                    $"Fund reconstruction {reconstruction.Id} source document {reconstruction.SourceDocumentSystemIdentifier} and target document {reconstruction.TargetDocumentSystemIdentifier} are different");
            }

            if (!reconstruction.TargetDocumentSystemIdentifier.HasValue
                && reconstruction.TargetArchivalEntitySystemIdentifier.HasValue
                && reconstruction.TargetInventorySystemIdentifier.HasValue
                && reconstruction.TargetArchivalEntitySystemIdentifier != reconstruction.SourceArchivalEntitySystemIdentifier)
            {
                throw new InvalidOperationException(
                    $"Fund reconstruction {reconstruction.Id} source AE {reconstruction.SourceArchivalEntitySystemIdentifier} and target AE {reconstruction.TargetArchivalEntitySystemIdentifier} are different");
            }

            //if (!reconstruction.TargetDocumentSystemIdentifier.HasValue
            //    && !reconstruction.TargetArchivalEntitySystemIdentifier.HasValue
            //    && reconstruction.TargetInventorySystemIdentifier.HasValue
            //    && reconstruction.TargetInventorySystemIdentifier != reconstruction.SourceInventorySystemIdentifier)
            //{
            //    throw new InvalidOperationException(
            //        $"Fund reconstruction {reconstruction.Id} source inventory {reconstruction.SourceInventorySystemIdentifier} and target inventory {reconstruction.TargetInventorySystemIdentifier} are different");
            //}

            if (reconstruction.SourceDocumentSystemIdentifier.HasValue)
            {
                var document =
                    await _documentService.GetDocumentBySystemIdentifierAsync(reconstruction.SourceDocumentSystemIdentifier.Value);

                if (document == null)
                {
                    throw new ItemNotFoundException(
                        $"Document {reconstruction.SourceDocumentSystemIdentifier} does not exists",
                        reconstruction.SourceDocumentSystemIdentifier.ToString()!);
                }
                if (document.HasExternalSource.HasValue && document.HasExternalSource.Value)
                {
                    throw new Exception($"Document {reconstruction.SourceDocumentSystemIdentifier} is from external source");
                }

                //Изрично се създава нова чернова за документа с променените връзки и статус.
                var currentDraft =
                    await _context.DocumentDrafts
                    .Where(doc =>
                        doc.SystemIdentifier == document.SystemIdentifier
                        && doc.IsCurrent
                        && !doc.ReadOnly)
                    .SingleOrDefaultAsync();
                if (currentDraft != null)
                {
                    currentDraft.ReadOnly = true;
                    _context.Update(currentDraft);

                    await _context.SaveAsync("Document draft updated");
                }

                document.InventoryDraftId = null;
                document.InventorySystemIdentifier = reconstruction.TargetInventorySystemIdentifier;
                document.ArchivalEntityDraftId = null;
                document.ArchivalEntitySystemIdentifier = reconstruction.TargetArchivalEntitySystemIdentifier;
                document.StatusCode = Shared.Status.Moved;
                
                await CreateOrUpdateDocumentDraftAsync(document, (int)Shared.AvailabilityStatus.Enrollment);
            }
            else if (reconstruction.SourceArchivalEntitySystemIdentifier.HasValue)
            {
                var archivalEntity =
                    await _archivalEntityService.GetArchivalEntityBySystemIdentifierAsync(reconstruction.SourceArchivalEntitySystemIdentifier.Value);

                if (archivalEntity == null)
                {
                    throw new ItemNotFoundException(
                        $"Archival entity {reconstruction.SourceArchivalEntitySystemIdentifier} does not exists",
                        reconstruction.SourceArchivalEntitySystemIdentifier.ToString()!);
                }
                if (archivalEntity.HasExternalSource)
                {
                    throw new Exception($"Archival entity {reconstruction.SourceArchivalEntitySystemIdentifier} is from external source");
                }
                //Изрично се създава нова чернова за AE с променените връзки и статус.
                var currentDraft =
                    await _context.ArchivalEntityDrafts
                    .Where(ae =>
                        ae.SystemIdentifier == archivalEntity.SystemIdentifier
                        && ae.IsCurrent
                        && !ae.ReadOnly)
                    .SingleOrDefaultAsync();
                if (currentDraft != null)
                {
                    currentDraft.ReadOnly = true;
                    _context.Update(currentDraft);

                    await _context.SaveAsync("Archival entity draft updated");
                }

                archivalEntity.InventoryDraftId = null;
                archivalEntity.InventorySystemIdentifier = reconstruction.TargetInventorySystemIdentifier;
                archivalEntity.StatusCode = Shared.Status.Moved;
                

                await CreateOrUpdateArchivalEntityDraftAsync(archivalEntity, (int)Shared.AvailabilityStatus.Enrollment);

                //TODO Add Get method in document service for full document data 
                var documentSystemIdentifiers = _context.VDocuments
                                                .Where(doc => doc.ArchivalEntitySystemIdentifier == archivalEntity.SystemIdentifier
                                                                && !doc.Deleted
                                                                && (!doc.HasExternalSource.HasValue || !doc.HasExternalSource.Value))
                                                .Select(doc => doc.SystemIdentifier);

                foreach (var docSystemIdentifier in documentSystemIdentifiers)
                {
                    var document = await _documentService.GetDocumentBySystemIdentifierAsync(docSystemIdentifier);
                    if (document == null)
                    {
                        throw new ItemNotFoundException($"Document {docSystemIdentifier} does not exists", docSystemIdentifier.ToString());
                    }

                    //Изрично се създава нова чернова за документа с променените връзки и статус.
                    if (document.IsDraft)
                    { 
                        var currentDocDraft =
                            await _context.DocumentDrafts
                            .Where(doc =>
                                doc.SystemIdentifier == document.SystemIdentifier
                                && doc.IsCurrent
                                && !doc.ReadOnly)
                            .SingleOrDefaultAsync();
                        if (currentDocDraft != null)
                        {
                            currentDocDraft.ReadOnly = true;
                            _context.Update(currentDocDraft);

                            await _context.SaveAsync("Document draft updated");
                        }
                    }

                    document.ArchivalEntityDraftId = null;
                    document.ArchivalEntitySystemIdentifier = reconstruction.TargetArchivalEntitySystemIdentifier;
                    document.InventoryDraftId = null;
                    document.InventorySystemIdentifier = reconstruction.TargetInventorySystemIdentifier;
                    document.StatusCode = Shared.Status.Moved;

                    await CreateOrUpdateDocumentDraftAsync(document, (int)Shared.AvailabilityStatus.Enrollment);
                }
            } else
            {
                throw new Exception(_localizer.GetString("InvalidData").ToString());
            }
        }

        private async System.Threading.Tasks.Task MergeReconstructionSourceToTargetAsync(FundReconstructionModel reconstruction)
        {
            if (reconstruction.AvailabilityStatusCode != (int)Shared.AvailabilityStatus.RelocationDeduction)
            {
                throw new InvalidOperationException($"Fund reconstruction {reconstruction.Id} is not relocation");
            }

            if (reconstruction.TargetDocumentSystemIdentifier.HasValue
                && reconstruction.TargetArchivalEntitySystemIdentifier.HasValue
                && reconstruction.TargetInventorySystemIdentifier.HasValue)
            {
                throw new InvalidOperationException($"Cannot merge documents. Fund recosntruction {reconstruction.Id}");
            }

            if (!reconstruction.TargetDocumentSystemIdentifier.HasValue
                && reconstruction.TargetArchivalEntitySystemIdentifier.HasValue
                && reconstruction.TargetInventorySystemIdentifier.HasValue
                && reconstruction.TargetArchivalEntitySystemIdentifier == reconstruction.SourceArchivalEntitySystemIdentifier)
            {
                throw new InvalidOperationException(
                    $"Cannot merge AE. Source AE and target AE MUST be different. Fund reconstruction {reconstruction.Id}");
            }

            if (!reconstruction.TargetDocumentSystemIdentifier.HasValue
                && !reconstruction.TargetArchivalEntitySystemIdentifier.HasValue
                && reconstruction.TargetInventorySystemIdentifier.HasValue
                && reconstruction.TargetInventorySystemIdentifier == reconstruction.SourceInventorySystemIdentifier)
            {
                throw new InvalidOperationException(
                    $"Cannot merge inventories. Source inventory and target inventory MUST be different. Fund reconstruction {reconstruction.Id}");
            }

            if (reconstruction.SourceArchivalEntitySystemIdentifier.HasValue)
            {
                var archivalEntity =
                    await _archivalEntityService.GetArchivalEntityBySystemIdentifierAsync(reconstruction.SourceArchivalEntitySystemIdentifier.Value);

                if (archivalEntity == null)
                {
                    throw new ItemNotFoundException(
                        $"Archival entity {reconstruction.SourceArchivalEntitySystemIdentifier} does not exists",
                        reconstruction.SourceArchivalEntitySystemIdentifier.ToString()!);
                }
                if (archivalEntity.HasExternalSource)
                {
                    throw new Exception($"Archival entity {reconstruction.SourceArchivalEntitySystemIdentifier} is from external source");
                }
                
                archivalEntity.StatusCode = Shared.Status.Deleted;
            
                await CreateOrUpdateArchivalEntityDraftAsync(archivalEntity, (int)Shared.AvailabilityStatus.Enrollment);

                //TODO Add Get method in document service for full document data 
                var documentSystemIdentifiers = _context.VDocuments
                                                .Where(doc => doc.ArchivalEntitySystemIdentifier == archivalEntity.SystemIdentifier
                                                                && !doc.Deleted
                                                                && (!doc.HasExternalSource.HasValue || !doc.HasExternalSource.Value))
                                                .Select(doc => doc.SystemIdentifier);

                foreach (var docSystemIdentifier in documentSystemIdentifiers)
                {
                    var document = await _documentService.GetDocumentBySystemIdentifierAsync(docSystemIdentifier);
                    if (document == null)
                    {
                        throw new ItemNotFoundException($"Document {docSystemIdentifier} does not exists", docSystemIdentifier.ToString());
                    }

                    //Изрично се създава нова чернова за документа с променените връзки и статус.
                    if (document.IsDraft)
                    {
                        var currentDocDraft =
                            await _context.DocumentDrafts
                            .Where(doc =>
                                doc.SystemIdentifier == document.SystemIdentifier
                                && doc.IsCurrent
                                && !doc.ReadOnly)
                            .SingleOrDefaultAsync();
                        if (currentDocDraft != null)
                        {
                            currentDocDraft.ReadOnly = true;
                            _context.Update(currentDocDraft);

                            await _context.SaveAsync("Document draft updated");
                        }
                    }

                    document.ArchivalEntityDraftId = null;
                    document.ArchivalEntitySystemIdentifier = reconstruction.TargetArchivalEntitySystemIdentifier;
                    document.InventoryDraftId = null;
                    document.InventorySystemIdentifier = reconstruction.TargetInventorySystemIdentifier;
                    document.StatusCode = Shared.Status.Moved;

                    await CreateOrUpdateDocumentDraftAsync(document, (int)Shared.AvailabilityStatus.Enrollment);
                }
            }
            else if (reconstruction.SourceInventorySystemIdentifier.HasValue)
            {
                var inventory =
                    await _inventoryService.GetInventoryBySystemIdentifierAsync(reconstruction.SourceInventorySystemIdentifier.Value);

                if (inventory == null)
                {
                    throw new ItemNotFoundException(
                        $"Inventory {reconstruction.SourceInventorySystemIdentifier} does not exists",
                        reconstruction.SourceInventorySystemIdentifier.ToString()!);
                }
                if (inventory.HasExternalSource)
                {
                    throw new Exception($"Inventory {reconstruction.SourceInventorySystemIdentifier} is from external source");
                }

                inventory.StatusCode = Shared.Status.Deleted;

                await CreateOrUpdateInventoryDraftAsync(inventory, (int)Shared.AvailabilityStatus.Enrollment);

                //TODO Add get method in AE service for full AE data
                var archivalEntitySystemIdentifiers = _context.VArchivalEntities
                                                        .Where(ae => ae.InventorySystemIdentifier == inventory.SystemIdentifier
                                                                    && !ae.Deleted
                                                                    && (!ae.HasExternalSource.HasValue || !ae.HasExternalSource.Value))
                                                        .Select(ae => ae.SystemIdentifier);
                foreach (var aeSystemIdentifier in archivalEntitySystemIdentifiers)
                {
                    var archivalEntity = await _archivalEntityService.GetArchivalEntityBySystemIdentifierAsync(aeSystemIdentifier);
                    if (archivalEntity == null)
                    {
                        throw new ItemNotFoundException($"Archival entity {aeSystemIdentifier} does not exists", aeSystemIdentifier.ToString());
                    }

                    //Изрично се създава нова чернова за АЕ с променените връзки и статус.
                    if (archivalEntity.IsDraft)
                    {
                        var currentArchivalEntityDraft =
                            await _context.ArchivalEntityDrafts
                            .Where(ae =>
                                ae.SystemIdentifier == archivalEntity.SystemIdentifier
                                && ae.IsCurrent
                                && !ae.ReadOnly)
                            .SingleOrDefaultAsync();
                        if (currentArchivalEntityDraft != null)
                        {
                            currentArchivalEntityDraft.ReadOnly = true;
                            _context.Update(currentArchivalEntityDraft);

                            await _context.SaveAsync("Archival entity draft updated");
                        }
                    }

                    archivalEntity.InventoryDraftId = null;
                    archivalEntity.InventorySystemIdentifier = reconstruction.TargetInventorySystemIdentifier;
                    archivalEntity.StatusCode = Shared.Status.Moved;

                    await CreateOrUpdateArchivalEntityDraftAsync(archivalEntity, (int)Shared.AvailabilityStatus.Enrollment);
                }

                var documentSystemIdentifiers = _context.VDocuments
                                                .Where(doc => doc.InventorySystemIdentifier == inventory.SystemIdentifier
                                                                && !doc.Deleted
                                                                && (!doc.HasExternalSource.HasValue || !doc.HasExternalSource.Value))
                                                .Select(doc => doc.SystemIdentifier);

                foreach (var docSystemIdentifier in documentSystemIdentifiers)
                {
                    var document = await _documentService.GetDocumentBySystemIdentifierAsync(docSystemIdentifier);
                    if (document == null)
                    {
                        throw new ItemNotFoundException($"Document {docSystemIdentifier} does not exists", docSystemIdentifier.ToString());
                    }

                    //Изрично се създава нова чернова за документа с променените връзки и статус.
                    if (document.IsDraft)
                    {
                        var currentDocDraft =
                            await _context.DocumentDrafts
                            .Where(doc =>
                                doc.SystemIdentifier == document.SystemIdentifier
                                && doc.IsCurrent
                                && !doc.ReadOnly)
                            .SingleOrDefaultAsync();
                        if (currentDocDraft != null)
                        {
                            currentDocDraft.ReadOnly = true;
                            _context.Update(currentDocDraft);

                            await _context.SaveAsync("Document draft updated");
                        }
                    }

                    document.ArchivalEntityDraftId = null;
                    //document.ArchivalEntitySystemIdentifier = reconstruction.TargetArchivalEntitySystemIdentifier;
                    document.InventoryDraftId = null;
                    document.InventorySystemIdentifier = reconstruction.TargetInventorySystemIdentifier;
                    document.StatusCode = Shared.Status.Moved;

                    await CreateOrUpdateDocumentDraftAsync(document, (int)Shared.AvailabilityStatus.Enrollment);
                }
            }
        }

        public IQueryable<ArchivalEntityShortDisplayModel> GetSourceArchivalEntities(Guid fundSystemIdentifier)
        {
            return _context.VArchivalEntities
                    .Where(ae =>
                        ae.FundSystemIdentifier == fundSystemIdentifier
                        && ae.AvailabilityStatusCode == (int)Shared.AvailabilityStatus.RelocationDeduction
                        && ae.InventoryAvailabilityStatusCode != (int)Shared.AvailabilityStatus.RelocationDeduction)
                    .Select(ae => new ArchivalEntityShortDisplayModel()
                    {
                        Id = ae.Id,
                        IsDraft = ae.IsDraft ?? false,
                        SystemIdentifier = ae.SystemIdentifier,
                        HasExternalSource = ae.HasExternalSource ?? false,
                        ExternalIdentifier = ae.ExternalIdentifier,
                        ArchiveId = ae.ArchiveId,
                        ArchiveCode = ae.ArchiveCode,
                        ArchiveName = ae.ArchiveName,
                        FundDraftId = ae.FundDraftId,
                        FundSystemIdentifier = ae.FundSystemIdentifier,
                        FundHasExternalSource = ae.FundHasExternalSource ?? false,
                        FundExternalIdentifier = ae.FundExternalIdentifier,
                        FundNumber = ae.FundNumber,
                        InventoryDraftId = ae.InventoryDraftId,
                        InventorySystemIdentifier = ae.InventorySystemIdentifier,
                        InventoryHasExternalSource = ae.InventoryHasExternalSource ?? false,
                        InventoryExternalIdentifier = ae.InventoryExternalIdentifier,
                        InventoryNumber = ae.InventoryNumber,
                        ApproximateChronologicalScope = ae.ApproxmateChronologicalScope,
                        AvailabilityStatusCode = ae.AvailabilityStatusCode,
                        AvailabilityStatusText= ae.AvailabilityStatusText,
                        DescriptionLevelCode = ae.DescriptionLevelCode!,
                        DescriptionLevelText= ae.DescriptionLevelText!,
                        StatusCode = ae.StatusCode!,
                        StatusText= ae.StatusText!,
                        Number = ae.Number,
                        Title = ae.Title,
                    });
        }

        public IQueryable<ArchivalEntityShortDisplayModel> GetTargetArchivalEntities(Guid fundSystemIdentifier)
        {
            return _context.VArchivalEntities
                    .Where(ae =>
                        ae.FundSystemIdentifier == fundSystemIdentifier
                        && ae.AvailabilityStatusCode != (int)Shared.AvailabilityStatus.RelocationDeduction
                        && ae.AvailabilityStatusCode != (int)Shared.AvailabilityStatus.DisposalDeduction
                        && ae.StatusCode != Shared.Status.Deducted
                        && ae.StatusCode != Shared.Status.Deleted
                        && ae.InventoryAvailabilityStatusCode != (int)Shared.AvailabilityStatus.RelocationDeduction)
                    .Select(ae => new ArchivalEntityShortDisplayModel()
                    {
                        Id = ae.Id,
                        IsDraft = ae.IsDraft ?? false,
                        SystemIdentifier = ae.SystemIdentifier,
                        HasExternalSource = ae.HasExternalSource ?? false,
                        ExternalIdentifier = ae.ExternalIdentifier,
                        ArchiveId = ae.ArchiveId,
                        ArchiveCode = ae.ArchiveCode,
                        ArchiveName = ae.ArchiveName,
                        FundDraftId = ae.FundDraftId,
                        FundSystemIdentifier = ae.FundSystemIdentifier,
                        FundHasExternalSource = ae.FundHasExternalSource ?? false,
                        FundExternalIdentifier = ae.FundExternalIdentifier,
                        FundNumber = ae.FundNumber,
                        InventoryDraftId = ae.InventoryDraftId,
                        InventorySystemIdentifier = ae.InventorySystemIdentifier,
                        InventoryHasExternalSource = ae.InventoryHasExternalSource ?? false,
                        InventoryExternalIdentifier = ae.InventoryExternalIdentifier,
                        InventoryNumber = ae.InventoryNumber,
                        ApproximateChronologicalScope = ae.ApproxmateChronologicalScope,
                        AvailabilityStatusCode = ae.AvailabilityStatusCode,
                        AvailabilityStatusText= ae.AvailabilityStatusText,
                        DescriptionLevelCode = ae.DescriptionLevelCode!,
                        DescriptionLevelText= ae.DescriptionLevelText!,
                        StatusCode = ae.StatusCode!,
                        StatusText= ae.StatusText!,
                        Number = ae.Number,
                        Title = ae.Title,
                    });
        }

        public IQueryable<Models.Inventories.InventoryShortDisplayModel> GetSourceInventories(Guid fundSystemIdentifier)
        {
            return _context.VInventories
                    .Where(inv =>
                        inv.FundSystemIdentifier == fundSystemIdentifier
                        && inv.AvailabilityStatusCode == (int)Shared.AvailabilityStatus.RelocationDeduction)
                    .Select(inv => new Models.Inventories.InventoryShortDisplayModel()
                    {
                        Id = inv.Id,
                        IsDraft = inv.IsDraft ?? false,
                        SystemIdentifier = inv.SystemIdentifier,
                        HasExternalSource = inv.HasExternalSource ?? false,
                        ExternalIdentifier = inv.ExternalIdentifier,
                        ArchiveId = inv.ArchiveId,
                        ArchiveCode = inv.ArchiveCode,
                        ArchiveName = inv.ArchiveName,
                        FundDraftId = inv.FundDraftId,
                        FundSystemIdentifier = inv.FundSystemIdentifier,
                        FundHasExternalSource = inv.FundHasExternalSource ?? false,
                        FundExternalIdentifier = inv.FundExternalIdentifier,
                        FundNumber = inv.FundNumber,
                        ApproxmateChronologicalScope = inv.ApproxmateChronologicalScope,
                        AvailabilityStatusCode = inv.AvailabilityStatusCode,
                        AvailabilityStatusText= inv.AvailabilityStatusText,
                        DescriptionLevelCode = inv.DescriptionLevelCode!,
                        DescriptionLevelText= inv.DescriptionLevelText,
                        StatusCode = inv.StatusCode!,
                        StatusText= inv.StatusText,
                        NumberArray= inv.NumberArray,
                        Number = inv.Number,
                    });
        }

        public IQueryable<Models.Inventories.InventoryShortDisplayModel> GetTargetInventories(Guid fundSystemIdentifier)
        {
            return _context.VInventories
                    .Where(inv =>
                        inv.FundSystemIdentifier == fundSystemIdentifier
                        && inv.AvailabilityStatusCode != (int)Shared.AvailabilityStatus.RelocationDeduction
                        && inv.AvailabilityStatusCode != (int)Shared.AvailabilityStatus.DisposalDeduction
                        && inv.StatusCode != Shared.Status.Deducted
                        && inv.StatusCode != Shared.Status.Deleted
                        && inv.DescriptionLevelCode != ((int)Shared.InventoryDescriptionLevel.RawInventory).ToString())
                    .Select(inv => new Models.Inventories.InventoryShortDisplayModel()
                    {
                        Id = inv.Id,
                        IsDraft = inv.IsDraft ?? false,
                        SystemIdentifier = inv.SystemIdentifier,
                        HasExternalSource = inv.HasExternalSource ?? false,
                        ExternalIdentifier = inv.ExternalIdentifier,
                        ArchiveId = inv.ArchiveId,
                        ArchiveCode = inv.ArchiveCode,
                        ArchiveName = inv.ArchiveName,
                        FundDraftId = inv.FundDraftId,
                        FundSystemIdentifier = inv.FundSystemIdentifier,
                        FundHasExternalSource = inv.FundHasExternalSource ?? false,
                        FundExternalIdentifier = inv.FundExternalIdentifier,
                        FundNumber = inv.FundNumber,
                        ApproxmateChronologicalScope = inv.ApproxmateChronologicalScope,
                        AvailabilityStatusCode = inv.AvailabilityStatusCode,
                        AvailabilityStatusText = inv.AvailabilityStatusText,
                        DescriptionLevelCode = inv.DescriptionLevelCode!,
                        DescriptionLevelText= inv.DescriptionLevelText,
                        StatusCode = inv.StatusCode!,
                        StatusText= inv.StatusText,
                        NumberArray = inv.NumberArray,
                        Number = inv.Number,
                    });
        }

        public DataSourceResponseModel<FundReconstructionDisplayModel> GetReconstructionsByProcess(DataSourceRequestModel model, int processId)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query = _context.VFundReconstructions
                        .Where(rec => rec.ProcessId == processId && !rec.Deleted)
                        .Select(rec => new FundReconstructionDisplayModel()
                        {
                            Id = rec.Id,
                            ProcessId = rec.ProcessId,
                            ArchiveId = rec.ArchiveId,
                            FundSystemIdentifier = rec.FundSystemIdentifier,
                            FundNumber = rec.FundNumber,
                            AvailabilityStatusCode = rec.AvailabilityStatusCode!.Value,
                            AvailabilityStatusText = rec.AvailabilityStatusText,
                            CreatedBy = rec.CreatedBy,
                            CreatedByDisplayName = rec.CreatedByDisplayName,
                            CreatedByUserName = rec.CreatedByUserName,
                            CreatedOn = rec.CreatedOn.UtcToLocalTime(),
                            Deleted = rec.Deleted,
                            DeletedBy = rec.DeletedBy,
                            DeletedByDisplayName = rec.DeletedByDisplayName,
                            DeletedByUserName = rec.DeletedByUserName,
                            DeletedOn = rec.DeletedOn.UtcToLocalTime(),
                            UpdatedBy = rec.UpdatedBy,
                            UpdatedByDisplayName = rec.UpdatedByDisplayName,
                            UpdatedByUserName = rec.UpdatedByUserName,
                            UpdatedOn = rec.UpdatedOn.UtcToLocalTime(),
                            SourceInventorySystemIdentifier = rec.SourceInventorySystemIdentifier,
                            SourceInventoryNumber = rec.SourceInventoryNumber,
                            SourceArchivalEntitySystemIdentifier = rec.SourceArchivalEntitySystemIdentifier,
                            SourceArchivalEntityNumber = rec.SourceArchivalEntityNumber,
                            SourceDocumentSystemIdentifier = rec.SourceDocumentSystemIdentifier,
                            SourceDocumentTitle = rec.SourceDocumentTitle,
                            TargetInventorySystemIdentifier = rec.TargetInventorySystemIdentifier,
                            TargetInventoryNumber = rec.TargetInventoryNumber,
                            TargetArchivalEntitySystemIdentifier = rec.TargetArchivalEntitySystemIdentifier,
                            TargetArchivalEntityNumber = rec.TargetArchivalEntityNumber,
                            TargetDocumentSystemIdentifier = rec.TargetDocumentSystemIdentifier,
                            TargetDocumentTitle = rec.TargetDocumentTitle,
                        });


            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }

            QueryResponseModel<FundReconstructionDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<FundReconstructionDisplayModel> result = new DataSourceResponseModel<FundReconstructionDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => x)
            };

            return result;
        }

        public IQueryable<FundReconstructionDisplayModel> GetReconstructionsByProcess(int processId)
        {
            var query = _context.VFundReconstructions
                        .Where(rec => rec.ProcessId == processId && !rec.Deleted)
                        .Select(rec => new FundReconstructionDisplayModel()
                        {
                            Id = rec.Id,
                            ProcessId = rec.ProcessId,
                            ArchiveId = rec.ArchiveId,
                            FundSystemIdentifier = rec.FundSystemIdentifier,
                            FundNumber = rec.FundNumber,
                            AvailabilityStatusCode = rec.AvailabilityStatusCode!.Value,
                            AvailabilityStatusText = rec.AvailabilityStatusText,
                            CreatedBy = rec.CreatedBy,
                            CreatedByDisplayName = rec.CreatedByDisplayName,
                            CreatedByUserName = rec.CreatedByUserName,
                            CreatedOn = rec.CreatedOn.UtcToLocalTime(),
                            Deleted = rec.Deleted,
                            DeletedBy = rec.DeletedBy,
                            DeletedByDisplayName = rec.DeletedByDisplayName,
                            DeletedByUserName = rec.DeletedByUserName,
                            DeletedOn = rec.DeletedOn.UtcToLocalTime(),
                            UpdatedBy = rec.UpdatedBy,
                            UpdatedByDisplayName = rec.UpdatedByDisplayName,
                            UpdatedByUserName = rec.UpdatedByUserName,
                            UpdatedOn = rec.UpdatedOn.UtcToLocalTime(),
                            SourceInventorySystemIdentifier = rec.SourceInventorySystemIdentifier,
                            SourceInventoryNumber = rec.SourceInventoryNumber,
                            SourceArchivalEntitySystemIdentifier = rec.SourceArchivalEntitySystemIdentifier,
                            SourceArchivalEntityNumber = rec.SourceArchivalEntityNumber,
                            SourceDocumentSystemIdentifier = rec.SourceDocumentSystemIdentifier,
                            SourceDocumentTitle = rec.SourceDocumentTitle,
                            TargetInventorySystemIdentifier = rec.TargetInventorySystemIdentifier,
                            TargetInventoryNumber = rec.TargetInventoryNumber,
                            TargetArchivalEntitySystemIdentifier = rec.TargetArchivalEntitySystemIdentifier,
                            TargetArchivalEntityNumber = rec.TargetArchivalEntityNumber,
                            TargetDocumentSystemIdentifier = rec.TargetDocumentSystemIdentifier,
                            TargetDocumentTitle = rec.TargetDocumentTitle,
                        });

            return query;
        }

        public IQueryable<FundReconstructionDisplayModel> GetReconstructionsByAvailabilityStatus(int processId, int availabilityStatus)
        {
            var query = GetReconstructionsByProcess(processId);
            query = query.Where(rec => rec.AvailabilityStatusCode == availabilityStatus);

            return query;
        }

        public IQueryable<FundReconstructionDisplayModel> GetReconstructionsBySourceParent(
            int processId, 
            int availabilityStatus, 
            Guid? inventorySysId = null, 
            Guid? archivalEntitySysId = null)
        {
            var query = GetReconstructionsByAvailabilityStatus(processId, availabilityStatus);

            if (!inventorySysId.HasValue)
            {
                query = query.Where(rec => !rec.SourceArchivalEntitySystemIdentifier.HasValue && !rec.SourceDocumentSystemIdentifier.HasValue);
            }
            else
            {
                query = query.Where(rec => rec.SourceInventorySystemIdentifier == inventorySysId);
            }

            if (!archivalEntitySysId.HasValue)
            {
                query = 
                    query.Where(rec => !rec.SourceDocumentSystemIdentifier.HasValue);
            }
            else
            {
                query = 
                    query.Where(rec => 
                        rec.SourceArchivalEntitySystemIdentifier == archivalEntitySysId 
                        && rec.SourceDocumentSystemIdentifier.HasValue);
            }

            return query;
        }

        public IQueryable<FundReconstructionDisplayModel> GetReconstructionsByTargetParent(
            int processId,
            int availabilityStatus,
            Guid? inventorySysId = null,
            Guid? archivalEntitySysId = null)
        {
            var query = GetReconstructionsByAvailabilityStatus(processId, availabilityStatus);

            if (!inventorySysId.HasValue)
            {
                query = query.Where(rec => !rec.TargetArchivalEntitySystemIdentifier.HasValue && !rec.TargetArchivalEntitySystemIdentifier.HasValue);
            }
            else
            {
                query = query.Where(rec => rec.TargetInventorySystemIdentifier == inventorySysId);
            }

            if (!archivalEntitySysId.HasValue)
            {
                query =
                    query.Where(rec => !rec.TargetDocumentSystemIdentifier.HasValue);
            }
            else
            {
                query =
                    query.Where(rec =>
                        rec.TargetArchivalEntitySystemIdentifier == archivalEntitySysId
                        && rec.TargetDocumentSystemIdentifier.HasValue);
            }

            return query;
        }

        public async Task<FundReconstructionDisplayModel?> GetReconstructionByIdAsync(int id)
        {
            var fundReconstruction = await _context.VFundReconstructions
                                    .Where(rec => rec.Id == id && !rec.Deleted)
                                    .Select(rec => new FundReconstructionDisplayModel()
                                    {
                                        ProcessId = rec.ProcessId,
                                        ArchiveId = rec.ArchiveId,
                                        FundSystemIdentifier = rec.FundSystemIdentifier,
                                        FundNumber = rec.FundNumber,
                                        AvailabilityStatusCode = rec.AvailabilityStatusCode!.Value,
                                        AvailabilityStatusText = rec.AvailabilityStatusText,
                                        CreatedBy = rec.CreatedBy,
                                        CreatedByDisplayName = rec.CreatedByDisplayName,
                                        CreatedByUserName = rec.CreatedByUserName,
                                        CreatedOn = rec.CreatedOn.UtcToLocalTime(),
                                        Deleted = rec.Deleted,
                                        DeletedBy = rec.DeletedBy,
                                        DeletedByDisplayName = rec.DeletedByDisplayName,
                                        DeletedByUserName = rec.DeletedByUserName,
                                        DeletedOn = rec.DeletedOn.UtcToLocalTime(),
                                        UpdatedBy = rec.UpdatedBy,
                                        UpdatedByDisplayName = rec.UpdatedByDisplayName,
                                        UpdatedByUserName = rec.UpdatedByUserName,
                                        UpdatedOn = rec.UpdatedOn.UtcToLocalTime(),
                                        SourceInventorySystemIdentifier = rec.SourceInventorySystemIdentifier,
                                        SourceInventoryNumber = rec.SourceInventoryNumber,
                                        SourceArchivalEntitySystemIdentifier = rec.SourceArchivalEntitySystemIdentifier,
                                        SourceArchivalEntityNumber = rec.SourceArchivalEntityNumber,
                                        SourceDocumentSystemIdentifier = rec.SourceDocumentSystemIdentifier,
                                        SourceDocumentTitle = rec.SourceDocumentTitle,
                                        TargetInventorySystemIdentifier = rec.TargetInventorySystemIdentifier,
                                        TargetInventoryNumber = rec.TargetInventoryNumber,
                                        TargetArchivalEntitySystemIdentifier = rec.TargetArchivalEntitySystemIdentifier,
                                        TargetArchivalEntityNumber = rec.TargetArchivalEntityNumber,
                                        TargetDocumentSystemIdentifier = rec.TargetDocumentSystemIdentifier,
                                        TargetDocumentTitle = rec.TargetDocumentTitle,
                                    })
                                    .SingleOrDefaultAsync();

            return fundReconstruction;
        }

        private async Task<int> CreateReconstructionInternalAsync(FundReconstructionModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            await CreateOrUpdateReconstructionSourceDraftsAsync(model);

            var fundReconstruction = new FundReconstruction()
            {
                ProcessId = model.ProcessId,
                ArchiveId = model.ArchiveId,
                AvailabilityStatusCode = model.AvailabilityStatusCode,
                FundSystemIdentifier = model.FundSystemIdentifier,
                SourceInventorySystemIdentifier = model.SourceInventorySystemIdentifier,
                SourceArchivalEntitySystemIdentifier = model.SourceArchivalEntitySystemIdentifier,
                SourceDocumentSystemIdentifier = model.SourceDocumentSystemIdentifier,
                TargetInventorySystemIdentifier = model.TargetInventorySystemIdentifier,
                TargetArchivalEntitySystemIdentifier = model.TargetArchivalEntitySystemIdentifier,
                TargetDocumentSystemIdentifier = model.TargetDocumentSystemIdentifier,
            };

            _context.FundReconstructions.Add(fundReconstruction);

            await _context.SaveAsync("Fund reconstruction mapping created");

            return fundReconstruction.Id;
        }

        public async Task<OperationResult> CreateReconstructionAsync(FundReconstructionModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var fundReconstructionId = await CreateReconstructionInternalAsync(model);

                transaction.Commit();
                return OperationResult.Succeed(fundReconstructionId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        private async System.Threading.Tasks.Task CreateReconstructionsInternalAsync(IEnumerable<FundReconstructionModel> reconstructions)
        {
            if (reconstructions == null || !reconstructions.Any())
            {
                throw new ArgumentNullException(nameof(reconstructions));
            }

            foreach (var reconstruction in reconstructions)
            {
                await CreateReconstructionInternalAsync(reconstruction);
            }
        }

        public async Task<OperationResult> CreateReconstructionsAsync(IEnumerable<FundReconstructionModel> reconstructions)
        {
            if (reconstructions == null || !reconstructions.Any())
            {
                throw new ArgumentNullException(nameof(reconstructions));
            }

            using var transaction = _context.Database.BeginTransaction();

            try
            {
                await CreateReconstructionsInternalAsync(reconstructions);
                //foreach (var reconstruction in reconstructions)
                //{
                //    await CreateReconstructionInternalAsync(reconstruction);
                //}

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

        public async Task<OperationResult> UpdateReconstructionAsync(FundReconstructionModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            
            try
            {
                //var fundReconstruction = 
                //    await _context.FundReconstructions
                //    .Where(rec => 
                //        rec.Id == model.Id 
                //        && rec.ProcessId == model.ProcessId)
                //    .SingleOrDefaultAsync();

                var fundReconstruction =
                    await _context.FundReconstructions
                    .Where(rec =>
                        rec.ProcessId == model.ProcessId
                        && rec.ArchiveId == model.ArchiveId
                        && rec.FundSystemIdentifier == model.FundSystemIdentifier
                        && rec.AvailabilityStatusCode == model.AvailabilityStatusCode
                        && rec.SourceInventorySystemIdentifier == model.SourceInventorySystemIdentifier
                        && rec.SourceArchivalEntitySystemIdentifier == model.SourceArchivalEntitySystemIdentifier
                        && rec.SourceDocumentSystemIdentifier == model.SourceDocumentSystemIdentifier
                        && !rec.Deleted)
                    .SingleOrDefaultAsync();


                if (fundReconstruction == null)
                {
                    return OperationResult.Failed($"Fund reconstruction {model.Id} does not exists for process {model.ProcessId}");
                }

                //fundReconstruction.AvailabilityStatusCode = model.AvailabilityStatusCode;
                //fundReconstruction.SourceArchivalEntitySystemIdentifier = model.SourceArchivalEntitySystemIdentifier;
                //fundReconstruction.SourceDocumentSystemIdentifier = model.SourceDocumentSystemIdentifier;
                //fundReconstruction.SourceInventorySystemIdentifier = model.SourceInventorySystemIdentifier;
                fundReconstruction.TargetArchivalEntitySystemIdentifier = model.TargetArchivalEntitySystemIdentifier;
                fundReconstruction.TargetDocumentSystemIdentifier = model.TargetDocumentSystemIdentifier;
                fundReconstruction.TargetInventorySystemIdentifier = model.TargetInventorySystemIdentifier;

                _context.Update(fundReconstruction);
                await _context.SaveAsync("Fund reconstruction mapping updated");

                return OperationResult.Succeed(fundReconstruction.Id);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> UpdateFundReconstructionsAsync(IEnumerable<FundReconstructionModel> reconstructions)
        {
            if (reconstructions == null || !reconstructions.Any()) 
            {
                throw new ArgumentNullException(nameof(reconstructions));
            }

            try
            {
                var processId = reconstructions.Select(rec => rec.ProcessId).Distinct().SingleOrDefault();

                var modifiedReconstructions = _context.FundReconstructions
                                                .Where(rec => rec.ProcessId == processId && reconstructions.Select(r => r.Id).Contains(rec.Id) && !rec.Deleted)
                                                .Select(rec => rec);

                await modifiedReconstructions.ForEachAsync(rec =>
                {
                    var data =
                        reconstructions
                        .Where(r =>
                            r.ProcessId == rec.ProcessId
                            && r.AvailabilityStatusCode == rec.AvailabilityStatusCode
                            && r.ArchiveId == rec.ArchiveId
                            && r.FundSystemIdentifier == rec.FundSystemIdentifier
                            && r.SourceInventorySystemIdentifier == rec.SourceInventorySystemIdentifier
                            && r.SourceArchivalEntitySystemIdentifier == rec.SourceArchivalEntitySystemIdentifier
                            && r.SourceDocumentSystemIdentifier == rec.SourceDocumentSystemIdentifier)
                        .Single();

                    rec.TargetInventorySystemIdentifier = data.TargetInventorySystemIdentifier;
                    rec.TargetArchivalEntitySystemIdentifier = data.TargetArchivalEntitySystemIdentifier;
                    rec.TargetDocumentSystemIdentifier = data.TargetDocumentSystemIdentifier;
                });

                await _context.SaveAsync("Fund reconstruction updated");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> CreateOrUpdateReconstructionsBySourceAsync(IEnumerable<FundReconstructionModel> reconstructions)
        {
            if (reconstructions == null || !reconstructions.Any())
            {
                throw new ArgumentNullException(nameof(reconstructions));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                //Data should include only one process
                var processId = reconstructions.Select(rec => rec.ProcessId).Distinct().SingleOrDefault();
                //Data should include only one availability status
                var availabilityStatus = reconstructions.Select(rec => rec.AvailabilityStatusCode).Distinct().SingleOrDefault();
                //Data should include only one inventory identifier if any archival entities or documents.
                var inventorySystemIdentifier =
                    reconstructions.Any(rec => rec.SourceDocumentSystemIdentifier.HasValue || rec.SourceArchivalEntitySystemIdentifier.HasValue) ?
                    reconstructions.Select(rec => rec.SourceInventorySystemIdentifier).Distinct().SingleOrDefault() :
                    null;
                //Data should include only one archival entity identifier if any documents.
                var archivalEntitySystemIdentifier =
                    reconstructions.Any(rec => rec.SourceDocumentSystemIdentifier.HasValue) ?
                    reconstructions.Select(rec => rec.SourceArchivalEntitySystemIdentifier).Distinct().SingleOrDefault() :
                    null;

                
                var sourceReconstructions =
                    GetReconstructionsBySourceParent(
                        processId,
                        availabilityStatus,
                        inventorySystemIdentifier,
                        archivalEntitySystemIdentifier);

                if (await sourceReconstructions.AnyAsync())
                {
                    var recIds = sourceReconstructions.Select(rec => rec.Id!.Value).ToArray();

                    await DeleteFundReconstructionsInternalAsync(processId, recIds);
                }

                await CreateReconstructionsInternalAsync(reconstructions);
                
                transaction.Commit();
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> UpdateMoveFundReconstructionsByTargetAsync(IEnumerable<FundReconstructionModel> reconstructions)
        {
            if (reconstructions == null || !reconstructions.Any())
            {
                throw new ArgumentNullException(nameof(reconstructions));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                //Data should include only one process
                var processId = reconstructions.Select(rec => rec.ProcessId).Distinct().SingleOrDefault();
                //Data should include only one availability status
                var availabilityStatus = reconstructions.Select(rec => rec.AvailabilityStatusCode).Distinct().SingleOrDefault();
                //Data should include only one inventory identifier if any archival entities or documents.
                var inventorySystemIdentifier =
                    reconstructions.Any(rec => rec.TargetDocumentSystemIdentifier.HasValue || rec.TargetArchivalEntitySystemIdentifier.HasValue) ?
                    reconstructions.Select(rec => rec.TargetInventorySystemIdentifier).Distinct().SingleOrDefault() :
                    null;
                //Data should include only one archival entity identifier if any documents.
                var archivalEntitySystemIdentifier =
                    reconstructions.Any(rec => rec.TargetDocumentSystemIdentifier.HasValue) ?
                    reconstructions.Select(rec => rec.TargetArchivalEntitySystemIdentifier).Distinct().SingleOrDefault() :
                    null;


                var targetReconstructions = _context.FundReconstructions
                                                .Where(rec => 
                                                    rec.ProcessId == processId 
                                                    && rec.AvailabilityStatusCode == availabilityStatus 
                                                    && !rec.Deleted)
                                                .Select(rec => rec);

                //Местят се документи от една АЕ в друга
                if (archivalEntitySystemIdentifier.HasValue)
                {
                    targetReconstructions = 
                        targetReconstructions
                        .Where(rec => 
                            reconstructions.Select(r => r.TargetDocumentSystemIdentifier).Contains(rec.SourceDocumentSystemIdentifier));

                    await targetReconstructions.ForEachAsync(rec =>
                    {
                        var data =
                            reconstructions
                            .Where(r =>
                                r.ProcessId == rec.ProcessId
                                && r.AvailabilityStatusCode == rec.AvailabilityStatusCode
                                && r.ArchiveId == rec.ArchiveId
                                && r.FundSystemIdentifier == rec.FundSystemIdentifier
                                && r.TargetDocumentSystemIdentifier == rec.SourceDocumentSystemIdentifier)
                            .Single();

                        rec.TargetInventorySystemIdentifier = data.TargetInventorySystemIdentifier;
                        rec.TargetArchivalEntitySystemIdentifier = data.TargetArchivalEntitySystemIdentifier;
                        rec.TargetDocumentSystemIdentifier = data.TargetDocumentSystemIdentifier;
                    });

                    await _context.SaveAsync("Fund reconstruction updated");

                    foreach(var targetReconstruction in targetReconstructions)
                    {
                        await MoveReconstructionSourceToTargetAsync(
                            new FundReconstructionModel() 
                            { 
                                Id = targetReconstruction.Id,
                                AvailabilityStatusCode = targetReconstruction.AvailabilityStatusCode!.Value,
                                ProcessId = targetReconstruction.ProcessId,
                                ArchiveId= targetReconstruction.ArchiveId,
                                FundSystemIdentifier= targetReconstruction.FundSystemIdentifier,
                                SourceInventorySystemIdentifier= targetReconstruction.SourceInventorySystemIdentifier,
                                SourceArchivalEntitySystemIdentifier = targetReconstruction.SourceArchivalEntitySystemIdentifier,
                                SourceDocumentSystemIdentifier = targetReconstruction.SourceDocumentSystemIdentifier,
                                TargetInventorySystemIdentifier= targetReconstruction.TargetInventorySystemIdentifier,
                                TargetArchivalEntitySystemIdentifier = targetReconstruction.TargetArchivalEntitySystemIdentifier,
                                TargetDocumentSystemIdentifier = targetReconstruction.TargetDocumentSystemIdentifier,
                            });
                    }
                } 
                //Местят се АЕ от един опис в друг
                else if (inventorySystemIdentifier.HasValue)
                {
                    targetReconstructions =
                        targetReconstructions
                        .Where(rec =>
                            !rec.TargetDocumentSystemIdentifier.HasValue
                            && reconstructions.Select(r => r.TargetArchivalEntitySystemIdentifier).Contains(rec.SourceArchivalEntitySystemIdentifier));

                    await targetReconstructions.ForEachAsync(rec =>
                    {
                        var data =
                            reconstructions
                            .Where(r =>
                                r.ProcessId == rec.ProcessId
                                && r.AvailabilityStatusCode == rec.AvailabilityStatusCode
                                && r.ArchiveId == rec.ArchiveId
                                && r.FundSystemIdentifier == rec.FundSystemIdentifier
                                && r.TargetArchivalEntitySystemIdentifier == rec.SourceArchivalEntitySystemIdentifier
                                && !r.TargetDocumentSystemIdentifier.HasValue)
                            .Single();

                        rec.TargetInventorySystemIdentifier = data.TargetInventorySystemIdentifier;
                        rec.TargetArchivalEntitySystemIdentifier = data.TargetArchivalEntitySystemIdentifier;
                        rec.TargetDocumentSystemIdentifier = null;
                    });

                    await _context.SaveAsync("Fund reconstruction updated");

                    foreach (var targetReconstruction in targetReconstructions)
                    {
                        await MoveReconstructionSourceToTargetAsync(
                            new FundReconstructionModel()
                            {
                                Id = targetReconstruction.Id,
                                AvailabilityStatusCode = targetReconstruction.AvailabilityStatusCode!.Value,
                                ProcessId = targetReconstruction.ProcessId,
                                ArchiveId = targetReconstruction.ArchiveId,
                                FundSystemIdentifier = targetReconstruction.FundSystemIdentifier,
                                SourceInventorySystemIdentifier = targetReconstruction.SourceInventorySystemIdentifier,
                                SourceArchivalEntitySystemIdentifier = targetReconstruction.SourceArchivalEntitySystemIdentifier,
                                TargetInventorySystemIdentifier = targetReconstruction.TargetInventorySystemIdentifier,
                                TargetArchivalEntitySystemIdentifier = targetReconstruction.TargetArchivalEntitySystemIdentifier,
                            });
                    }
                }
                else
                {
                    transaction.Rollback();
                    return OperationResult.Failed("Reconstructions data is not for moving target data");
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

        //TODO От свръзващата таблица трябва да дойдат Source и Target, тъй като те се избират изрично ръчно, когато се мести един опис в друг или едно АЕ в друго.
        public async Task<OperationResult> UpdateMergeFundReconstructionAsync(FundReconstructionModel reconstruction)
        {
            if (reconstruction == null)
            {
                throw new ArgumentNullException(nameof(reconstruction));
            }
                        
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var updateReconstructionResult = await UpdateReconstructionAsync(reconstruction);
                if (!updateReconstructionResult.Succeeded)
                {
                    transaction.Rollback();
                    return updateReconstructionResult;
                }

                await MergeReconstructionSourceToTargetAsync(reconstruction);
                
                transaction.Commit();
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        async Task<OperationResult> IFundReconstructionServiceBase.ApplyDeductFundReconstructionsInternalAsync(IEnumerable<FundReconstructionModel> reconstructions)
        {
            if (reconstructions == null || !reconstructions.Any())
            {
                throw new ArgumentNullException(nameof(reconstructions));
            }

            try
            {
                foreach (var reconstruction in reconstructions)
                {
                    await DeductReconstructionSourceAsync(reconstruction);
                }
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        private async System.Threading.Tasks.Task DeleteFundReconstructionInternalAsync(int processId, int id)
        {
            var reconstruction = await _context.FundReconstructions
                                    .Where(rec => rec.ProcessId == processId && rec.Id == id && !rec.Deleted)
                                    .SingleOrDefaultAsync();

            if (reconstruction == null)
            {
                throw new ItemNotFoundException($"Fund reconstruction {id} does not exists", id.ToString());
            }

            await DeleteReconstructionTargetDraftsAsync(reconstruction);
            await DeleteReconstructionSourceDraftsAsync(reconstruction);

            reconstruction.Deleted = true;
            reconstruction.DeletedBy = _userInfo.CurrentUserId;
            reconstruction.DeletedOn = DateTime.UtcNow;

            _context.Update(reconstruction);
            await _context.SaveAsync("Fund reconstruction deleted");            
        }

        public async Task<OperationResult> DeleteFundReconstructionAsync(int processId, int id)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await DeleteFundReconstructionInternalAsync(processId, id);

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

        private async System.Threading.Tasks.Task DeleteFundReconstructionsInternalAsync(int processId, int[] ids)
        {
            foreach (var id in ids)
            {
                await DeleteFundReconstructionInternalAsync(processId, id);
            }
        }

        public async Task<OperationResult> DeleteFundReconstructionsAsync(int processId, int[] ids)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await DeleteFundReconstructionsInternalAsync(processId, ids);
                //foreach (var id in ids)
                //{
                //    await DeleteFundReconstructionInternalAsync(processId, id);
                //}

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
    }
}
