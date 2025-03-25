using DAA.Data;
using DAA.Extensions.Exceptions;
using DAA.Identity;
using DAA.Models.ArchiveEntities;
using DAA.Models.Documents;
using DAA.Models.Funds;
using DAA.Models.Inventories;
using DAA.Models.Processes;
using DAA.Models.Tasks;
using DAA.Services.ArchivalEntities;
using DAA.Services.CommissionReports;
using DAA.Services.CommissionSessions;
using DAA.Services.Documents;
using DAA.Services.Funds;
using DAA.Services.Inventories;
using DAA.Services.Process;
using DAA.Services.Tasks;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System.Text;
using ProcessType = DAA.Shared.ProcessType;

namespace DAA.Services.RefineDataProcess
{
    public class RefineDataProcessService : BaseService, IRefineDataProcessService
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
        private readonly ICommissionReportService _commissionReportService;

        public RefineDataProcessService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            ILogger<RefineDataProcessService> logger,
            IUserInfo userInfo,
            ApplicationRoleManager roleManager,
            IFundService fundService,
            IInventoryService inventoryService,
            IArchivalEntityService archiveEntityService,
            IDocumentService documentService,
            IProcessService processService,
            ITaskService taskService,
            ISessionAgendaService sessionAgendaService,
            ICommissionReportService commissionReportService)
            : base(context, localizer, logger)
        {
            _userInfo = userInfo;
            _roleManager = roleManager;
            _fundService = fundService;
            _inventoryService = inventoryService;
            _archivalEntityService = archiveEntityService;
            _documentService = documentService;
            _processService = processService;
            _taskService = taskService;
            _sessionAgendaService = sessionAgendaService;
            _commissionReportService= commissionReportService;
        }

        private async Task<int?> GetEntityDescriptionLevel(ProcessModel process)
        {
            if (process.FundSystemIdentifier.HasValue)
            {
                return await _fundService.GetDescriptionLevelAsync(process.FundSystemIdentifier.Value);
            }
            if (process.InventorySystemIdentifier.HasValue)
            {
                return await _inventoryService.GetDescriptionLevelAsync(process.InventorySystemIdentifier.Value);
            }
            if (process.ArchivalEntitySystemIdentifier.HasValue)
            {
                return await _archivalEntityService.GetDescriptionLevelAsync(process.ArchivalEntitySystemIdentifier.Value);
            }
            if (process.DocumentSystemIdentifier.HasValue)
            {
                return await _documentService.GetDescriptionLevelAsync(process.DocumentSystemIdentifier.Value);
            }
            return null;
        }
        private async Task<OperationResult> SetDataStatusAsync(ProcessModel process, string status)
        {
            try
            {
                if (process.FundSystemIdentifier.HasValue)
                {
                    var fund = await _fundService.GetFundBySystemIdentifierAsync(process.FundSystemIdentifier.Value);
                    if (fund == null)
                    {
                        return OperationResult.Failed($"Fund {process.FundSystemIdentifier} does not exists");
                    }

                    int? fundDraftId = fund.IsDraft ? fund.Id : null;

                    if (fundDraftId.HasValue)
                    {
                        var fundDraft = await _fundService.GetCurrentDraftAsync(process.FundSystemIdentifier!.Value);
                        if (fundDraft == null)
                        {
                            return OperationResult.Failed($"Fund {process.FundSystemIdentifier} does not have current draft.");
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
                        //    ApplicationId = fundDraft.ApplicationId,
                        //    NumberNumeric = fundDraft.NumberNumeric,
                        //};
                        var modifiedFundDraft = new FundDraftModel();
                        modifiedFundDraft.Assign(fundDraft);
                        modifiedFundDraft.IsCurrent = fundDraft.IsDraft;
                        modifiedFundDraft.ReadOnly = true;
                        modifiedFundDraft.StatusCode = status;

                        await _fundService.UpdateDraftInternalAsync(modifiedFundDraft);
                    }

                    var inventoryDraftSysIds = await _context.InventoryDrafts
                        .Where(inv => inv.FundSystemIdentifier == process.FundSystemIdentifier.Value && inv.IsCurrent && !inv.Deleted)
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
                        //    IsCurrent = inventoryDraft.IsDraft,
                        //    ReadOnly = true,
                        //    SystemIdentifier = inventoryDraft.SystemIdentifier,
                        //    ArchiveId = inventoryDraft.ArchiveId,
                        //    FundDraftId = inventoryDraft.FundDraftId,
                        //    FundSystemIdentifier = inventoryDraft.FundSystemIdentifier!.Value,
                        //    NumberArray = inventoryDraft.NumberArray,
                        //    Number = inventoryDraft.Number,
                        //    StatusCode = status,
                        //    DescriptionLevelCode = inventoryDraft.DescriptionLevelCode,
                        //    ApproxmateChronologicalScope = inventoryDraft.ApproxmateChronologicalScope,
                        //    HasNoChronologicalScope = inventoryDraft.HasNoChronologicalScope,
                        //    StartDateDay = inventoryDraft.StartDateDay,
                        //    StartDateMonth = inventoryDraft.StartDateMonth,
                        //    StartDateYear = inventoryDraft.StartDateYear,
                        //    EndDateDay = inventoryDraft.EndDateDay,
                        //    EndDateMonth = inventoryDraft.EndDateMonth,
                        //    EndDateYear = inventoryDraft.EndDateYear,
                        //    FundCreatorBiographicalHistory = inventoryDraft.FundCreatorBiographicalHistory,
                        //    FundCreatorTitleHistory = inventoryDraft.FundCreatorTitleHistory,
                        //    History = inventoryDraft.History,
                        //    DocumentsAccessDescription = inventoryDraft.DocumentsAccessDescription,
                        //    DocumentsDescription = inventoryDraft.DocumentsDescription,
                        //    DocumentsProvider = inventoryDraft.DocumentsProvider,
                        //    LinearMeters = inventoryDraft.LinearMeters,
                        //    OtherMetrics = inventoryDraft.OtherMetrics,
                        //    Notes = inventoryDraft.Notes,
                        //    ClassificationScheme = inventoryDraft.ClassificationScheme,
                        //    AbbreviationList = inventoryDraft.AbbreviationList,
                        //    Bytes = inventoryDraft.Bytes,
                        //    ArchivalEntityCount = inventoryDraft.ArchivalEntityCount,
                        //    DocumentCount = inventoryDraft.DocumentCount,
                        //    DigitizedArchivalEntityCount = inventoryDraft.DigitizedArchivalEntityCount,
                        //    AudioDocumentArchivalEntityCount = inventoryDraft.AudioDocumentArchivalEntityCount,
                        //    DigitalDocumentArchivalEntityCount = inventoryDraft.DigitalDocumentArchivalEntityCount,
                        //    MicrofilmedArchivalEntityCount = inventoryDraft.MicrofilmedArchivalEntityCount,
                        //    PhotoDocumentArchivalEntityCount = inventoryDraft.PhotoDocumentArchivalEntityCount,
                        //    VideoDocumentArchivalEntityCount = inventoryDraft.VideoDocumentArchivalEntityCount,
                        //    NegativeFrameCount = inventoryDraft.NegativeFrameCount,
                        //    PositiveFrameCount = inventoryDraft.PositiveFrameCount,
                        //    BoxCount = inventoryDraft.BoxCount,
                        //    RollCount = inventoryDraft.RollCount,
                        //    HasExternalSource = inventoryDraft.HasExternalSource,
                        //    ExternalIdentifier = inventoryDraft.ExternalIdentifier,
                        //    AcquisitionMethodId= inventoryDraft.AcquisitionMethodId,
                        //    //AcquisitionMethodCodes = inventoryDraft.AcquisitionMethodCodes,
                        //    CreationMethodCodes = inventoryDraft.CreationMethodCodes,
                        //    FileTypeCodes = inventoryDraft.FileTypeCodes,
                        //    LanguageCodes = inventoryDraft.LanguageCodes,
                        //    OriginalityCodes = inventoryDraft.OriginalityCodes,
                        //    ApplicationId = inventoryDraft.ApplicationId,
                        //    AvailabilityStatusCode = inventoryDraft.AvailabilityStatusCode,
                        //    FundExternalIdentifier = inventoryDraft.FundExternalIdentifier,
                        //    FundHasExternalSource = inventoryDraft.FundHasExternalSource,
                        //    NumberNumeric = inventoryDraft.NumberNumeric,
                        //    PackageAId = inventoryDraft.PackageAId,
                        //    PackageBId = inventoryDraft.PackageBId,
                        //    PackageCId = inventoryDraft.PackageCId,
                        //};
                        var modifiedInventoryDraft = new InventoryDraftModel();
                        modifiedInventoryDraft.Assign(inventoryDraft);
                        modifiedInventoryDraft.IsCurrent = inventoryDraft.IsDraft;
                        modifiedInventoryDraft.ReadOnly = true;
                        modifiedInventoryDraft.StatusCode = status;

                        await _inventoryService.UpdateDraftInternalAsync(modifiedInventoryDraft);
                    }

                    var archivalEntityDraftSysIds = await _context.ArchivalEntityDrafts
                        .Where(ae => ae.FundSystemIdentifier == process.FundSystemIdentifier.Value && ae.IsCurrent && !ae.Deleted)
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
                        //    IsCurrent = archivalEntityDraft.IsDraft,
                        //    ReadOnly = true,
                        //    SystemIdentifier = archivalEntityDraft.SystemIdentifier,
                        //    ArchiveId = archivalEntityDraft.ArchiveId,
                        //    FundDraftId = archivalEntityDraft.FundDraftId,
                        //    FundSystemIdentifier = archivalEntityDraft.FundSystemIdentifier!.Value,
                        //    InventoryDraftId = archivalEntityDraft.InventoryDraftId,
                        //    InventorySystemIdentifier = archivalEntityDraft.InventorySystemIdentifier,
                        //    StatusCode = status,
                        //    DescriptionLevelCode = archivalEntityDraft.DescriptionLevelCode,
                        //    Number = archivalEntityDraft.Number,
                        //    Title = archivalEntityDraft.Title,
                        //    ApproximateChronologicalScope = archivalEntityDraft.ApproximateChronologicalScope,
                        //    HasNoChronologicalScope = archivalEntityDraft.HasNoChronologicalScope,
                        //    StartDateDay = archivalEntityDraft.StartDateDay,
                        //    StartDateMonth = archivalEntityDraft.StartDateMonth,
                        //    StartDateYear = archivalEntityDraft.StartDateYear,
                        //    EndDateDay = archivalEntityDraft.EndDateDay,
                        //    EndDateMonth = archivalEntityDraft.EndDateMonth,
                        //    EndDateYear = archivalEntityDraft.EndDateYear,
                        //    Author = archivalEntityDraft.Author,
                        //    Condition = archivalEntityDraft.Condition,
                        //    Description = archivalEntityDraft.Description,
                        //    DigitalDeviceCount = archivalEntityDraft.DigitalDeviceCount,
                        //    DigitizedCopyCount = archivalEntityDraft.DigitizedCopyCount,
                        //    Features = archivalEntityDraft.Features,
                        //    FrameCount = archivalEntityDraft.FrameCount,
                        //    Location = archivalEntityDraft.Location,
                        //    MicrofilmCount = archivalEntityDraft.MicrofilmCount,
                        //    MicrofilmedCopyCount = archivalEntityDraft.MicrofilmedCopyCount,
                        //    OtherCopyCount = archivalEntityDraft.OtherCopyCount,
                        //    PaperCopyCount = archivalEntityDraft.PaperCopyCount,
                        //    Scaling = archivalEntityDraft.Scaling,
                        //    SheetCount = archivalEntityDraft.SheetCount,
                        //    SizeCm = archivalEntityDraft.SizeCm,
                        //    TapeCount = archivalEntityDraft.TapeCount,
                        //    VideoTapeCount = archivalEntityDraft.VideoTapeCount,
                        //    DeductedBytes = archivalEntityDraft.DeductedBytes,
                        //    DeductedDocumentCount = archivalEntityDraft.DeductedDocumentCount,
                        //    DeductedLinearMeters = archivalEntityDraft.DeductedLinearMeters,
                        //    EnrolledBytes = archivalEntityDraft.EnrolledBytes,
                        //    EnrolledDocumentCount = archivalEntityDraft.EnrolledDocumentCount,
                        //    EnrolledLinearMeters = archivalEntityDraft.EnrolledLinearMeters,
                        //    DocumentsAccessDescription = archivalEntityDraft.DocumentsAccessDescription,
                        //    OtherMetrics = archivalEntityDraft.OtherMetrics,
                        //    Notes = archivalEntityDraft.Notes,
                        //    Bytes = archivalEntityDraft.Bytes,
                        //    NegativeFrameCount = archivalEntityDraft.NegativeFrameCount,
                        //    PositiveFrameCount = archivalEntityDraft.PositiveFrameCount,
                        //    HasExternalSource = archivalEntityDraft.HasExternalSource,
                        //    ExternalIdentifier = archivalEntityDraft.ExternalIdentifier,
                        //    CreationMethodCodes = archivalEntityDraft.CreationMethodCodes,
                        //    LanguageCodes = archivalEntityDraft.LanguageCodes,
                        //    OriginalityCodes = archivalEntityDraft.OriginalityCodes,

                        //};
                        var modifiedArchivalEntityDraft = new ArchivalEntityDraftModel();
                        modifiedArchivalEntityDraft.Assign(archivalEntityDraft);
                        modifiedArchivalEntityDraft.IsCurrent = archivalEntityDraft.IsDraft;
                        modifiedArchivalEntityDraft.ReadOnly = true;
                        modifiedArchivalEntityDraft.StatusCode = status;

                        await _archivalEntityService.UpdateDraftInternalAsync(modifiedArchivalEntityDraft);
                    }

                    var documentDraftSysIds = await _context.DocumentDrafts
                        .Where(d => d.FundSystemIdentifier == process.FundSystemIdentifier.Value && d.IsCurrent && !d.Deleted)
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
                        //    IsCurrent = documentDraft.IsDraft,
                        //    ReadOnly = true,
                        //    SystemIdentifier = documentDraft.SystemIdentifier,
                        //    ArchiveId = documentDraft.ArchiveId,
                        //    FundDraftId = documentDraft.FundDraftId,
                        //    FundSystemIdentifier = documentDraft.FundSystemIdentifier!.Value,
                        //    InventoryDraftId = documentDraft.InventoryDraftId,
                        //    InventorySystemIdentifier = documentDraft.InventorySystemIdentifier,
                        //    ArchivalEntityDraftId = documentDraft.ArchivalEntityDraftId,
                        //    ArchivalEntitySystemIdentifier = documentDraft.ArchivalEntitySystemIdentifier,
                        //    StatusCode = status,
                        //    DescriptionLevelCode = documentDraft.DescriptionLevelCode,
                        //    Number = documentDraft.Number,
                        //    Title = documentDraft.Title,
                        //    ApproximateChronologicalScope = documentDraft.ApproximateChronologicalScope,
                        //    HasNoChronologicalScope = documentDraft.HasNoChronologicalScope,
                        //    StartDateDay = documentDraft.StartDateDay,
                        //    StartDateMonth = documentDraft.StartDateMonth,
                        //    StartDateYear = documentDraft.StartDateYear,
                        //    EndDateDay = documentDraft.EndDateDay,
                        //    EndDateMonth = documentDraft.EndDateMonth,
                        //    EndDateYear = documentDraft.EndDateYear,
                        //    Author = documentDraft.Author,
                        //    Description = documentDraft.Description,
                        //    DigitizedCopyCount = documentDraft.DigitizedCopyCount,
                        //    Features = documentDraft.Features,
                        //    Location = documentDraft.Location,
                        //    MicrofilmedCopyCount = documentDraft.MicrofilmedCopyCount,
                        //    OtherCopyCount = documentDraft.OtherCopyCount,
                        //    PaperCopyCount = documentDraft.PaperCopyCount,
                        //    Scaling = documentDraft.Scaling,
                        //    SheetCount = documentDraft.SheetCount,
                        //    SizeCm = documentDraft.SizeCm,
                        //    DocumentsAccessDescription = documentDraft.DocumentsAccessDescription,
                        //    OtherMetrics = documentDraft.OtherMetrics,
                        //    Notes = documentDraft.Notes,
                        //    Bytes = documentDraft.Bytes,
                        //    NegativeFrameCount = documentDraft.NegativeFrameCount,
                        //    PositiveFrameCount = documentDraft.PositiveFrameCount,
                        //    HasExternalSource = documentDraft.HasExternalSource,
                        //    ExternalIdentifier = documentDraft.ExternalIdentifier,
                        //    CreationMethodCodes = documentDraft.CreationMethodCodes,
                        //    LanguageCodes = documentDraft.LanguageCodes,
                        //    OriginalityCodes = documentDraft.OriginalityCodes,
                        //    DigitalDevice = documentDraft.DigitalDevice,
                        //    Duration = documentDraft.Duration,
                        //    EndSheetNumber = documentDraft.EndSheetNumber,
                        //    FileFormatCode = documentDraft.FileFormatCode,
                        //    FileTypeCodes = documentDraft.FileTypeCodes,
                        //    StartSheetNumber = documentDraft.StartSheetNumber,
                        //    Transcription = documentDraft.Transcription,
                        //};
                        var modifiedDocumentDraft = new DocumentDraftModel();
                        modifiedDocumentDraft.Assign(documentDraft);
                        modifiedDocumentDraft.IsCurrent = documentDraft.IsDraft;
                        modifiedDocumentDraft.ReadOnly = true;
                        modifiedDocumentDraft.StatusCode = status;

                        await _documentService.UpdateDraftInternalAsync(modifiedDocumentDraft);
                    }
                }

                if (process.InventorySystemIdentifier.HasValue)
                {
                    var inventory = await _inventoryService.GetInventoryBySystemIdentifierAsync(process.InventorySystemIdentifier.Value);
                    if (inventory == null)
                    {
                        return OperationResult.Failed($"Inventory {process.InventorySystemIdentifier} does not exists");
                    }

                    int? inventoryDraftId = inventory.IsDraft ? inventory.Id : null;

                    if (inventoryDraftId.HasValue)
                    {
                        var inventoryDraft = await _inventoryService.GetCurrentDraftAsync(process.InventorySystemIdentifier!.Value);
                        if (inventoryDraft == null)
                        {
                            return OperationResult.Failed($"Inventory {process.InventorySystemIdentifier} does not have current draft.");
                        }

                        //var modifiedInventoryDraft = new InventoryDraftModel()
                        //{
                        //    Id = inventoryDraft.Id,
                        //    IsCurrent = inventoryDraft.IsDraft,
                        //    ReadOnly = true,
                        //    SystemIdentifier = inventoryDraft.SystemIdentifier,
                        //    ArchiveId = inventoryDraft.ArchiveId,
                        //    FundDraftId = inventoryDraft.FundDraftId,
                        //    FundSystemIdentifier = inventoryDraft.FundSystemIdentifier!.Value,
                        //    NumberArray = inventoryDraft.NumberArray,
                        //    Number = inventoryDraft.Number,
                        //    StatusCode = status,
                        //    AvailabilityStatusCode = inventoryDraft.AvailabilityStatusCode,
                        //    DescriptionLevelCode = inventoryDraft.DescriptionLevelCode,
                        //    ApproxmateChronologicalScope = inventoryDraft.ApproxmateChronologicalScope,
                        //    HasNoChronologicalScope = inventoryDraft.HasNoChronologicalScope,
                        //    StartDateDay = inventoryDraft.StartDateDay,
                        //    StartDateMonth = inventoryDraft.StartDateMonth,
                        //    StartDateYear = inventoryDraft.StartDateYear,
                        //    EndDateDay = inventoryDraft.EndDateDay,
                        //    EndDateMonth = inventoryDraft.EndDateMonth,
                        //    EndDateYear = inventoryDraft.EndDateYear,
                        //    FundCreatorBiographicalHistory = inventoryDraft.FundCreatorBiographicalHistory,
                        //    FundCreatorTitleHistory = inventoryDraft.FundCreatorTitleHistory,
                        //    History = inventoryDraft.History,
                        //    DocumentsAccessDescription = inventoryDraft.DocumentsAccessDescription,
                        //    DocumentsDescription = inventoryDraft.DocumentsDescription,
                        //    DocumentsProvider = inventoryDraft.DocumentsProvider,
                        //    LinearMeters = inventoryDraft.LinearMeters,
                        //    OtherMetrics = inventoryDraft.OtherMetrics,
                        //    Notes = inventoryDraft.Notes,
                        //    ClassificationScheme = inventoryDraft.ClassificationScheme,
                        //    AbbreviationList = inventoryDraft.AbbreviationList,
                        //    Bytes = inventoryDraft.Bytes,
                        //    ArchivalEntityCount = inventoryDraft.ArchivalEntityCount,
                        //    DocumentCount = inventoryDraft.DocumentCount,
                        //    DigitizedArchivalEntityCount = inventoryDraft.DigitizedArchivalEntityCount,
                        //    AudioDocumentArchivalEntityCount = inventoryDraft.AudioDocumentArchivalEntityCount,
                        //    DigitalDocumentArchivalEntityCount = inventoryDraft.DigitalDocumentArchivalEntityCount,
                        //    MicrofilmedArchivalEntityCount = inventoryDraft.MicrofilmedArchivalEntityCount,
                        //    PhotoDocumentArchivalEntityCount = inventoryDraft.PhotoDocumentArchivalEntityCount,
                        //    VideoDocumentArchivalEntityCount = inventoryDraft.VideoDocumentArchivalEntityCount,
                        //    NegativeFrameCount = inventoryDraft.NegativeFrameCount,
                        //    PositiveFrameCount = inventoryDraft.PositiveFrameCount,
                        //    BoxCount = inventoryDraft.BoxCount,
                        //    RollCount = inventoryDraft.RollCount,
                        //    HasExternalSource = inventoryDraft.HasExternalSource,
                        //    ExternalIdentifier = inventoryDraft.ExternalIdentifier,
                        //    AcquisitionMethodId = inventoryDraft.AcquisitionMethodId,
                        //    //AcquisitionMethodCodes = inventoryDraft.AcquisitionMethodCodes,
                        //    CreationMethodCodes = inventoryDraft.CreationMethodCodes,
                        //    FileTypeCodes = inventoryDraft.FileTypeCodes,
                        //    LanguageCodes = inventoryDraft.LanguageCodes,
                        //    OriginalityCodes = inventoryDraft.OriginalityCodes,
                        //    ApplicationId = inventoryDraft.ApplicationId,
                        //};
                        var modifiedInventoryDraft = new InventoryDraftModel();
                        modifiedInventoryDraft.Assign(inventoryDraft);
                        modifiedInventoryDraft.IsCurrent = inventoryDraft.IsDraft;
                        modifiedInventoryDraft.ReadOnly = true;
                        modifiedInventoryDraft.StatusCode = status;

                        await _inventoryService.UpdateDraftInternalAsync(modifiedInventoryDraft);
                    }

                    var archivalEntityDraftSysIds = await _context.ArchivalEntityDrafts
                        .Where(ae => ae.InventorySystemIdentifier == process.InventorySystemIdentifier.Value && ae.IsCurrent && !ae.Deleted)
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
                        //    IsCurrent = archivalEntityDraft.IsDraft,
                        //    ReadOnly = true,
                        //    SystemIdentifier = archivalEntityDraft.SystemIdentifier,
                        //    ArchiveId = archivalEntityDraft.ArchiveId,
                        //    FundDraftId = archivalEntityDraft.FundDraftId,
                        //    FundSystemIdentifier = archivalEntityDraft.FundSystemIdentifier!.Value,
                        //    InventoryDraftId = archivalEntityDraft.InventoryDraftId,
                        //    InventorySystemIdentifier = archivalEntityDraft.InventorySystemIdentifier,
                        //    StatusCode = status,
                        //    AvailabilityStatusCode = archivalEntityDraft.AvailabilityStatusCode,
                        //    DescriptionLevelCode = archivalEntityDraft.DescriptionLevelCode,
                        //    Number = archivalEntityDraft.Number,
                        //    Title = archivalEntityDraft.Title,
                        //    ApproximateChronologicalScope = archivalEntityDraft.ApproximateChronologicalScope,
                        //    HasNoChronologicalScope = archivalEntityDraft.HasNoChronologicalScope,
                        //    StartDateDay = archivalEntityDraft.StartDateDay,
                        //    StartDateMonth = archivalEntityDraft.StartDateMonth,
                        //    StartDateYear = archivalEntityDraft.StartDateYear,
                        //    EndDateDay = archivalEntityDraft.EndDateDay,
                        //    EndDateMonth = archivalEntityDraft.EndDateMonth,
                        //    EndDateYear = archivalEntityDraft.EndDateYear,
                        //    Author = archivalEntityDraft.Author,
                        //    Condition = archivalEntityDraft.Condition,
                        //    Description = archivalEntityDraft.Description,
                        //    DigitalDeviceCount = archivalEntityDraft.DigitalDeviceCount,
                        //    DigitizedCopyCount = archivalEntityDraft.DigitizedCopyCount,
                        //    Features = archivalEntityDraft.Features,
                        //    FrameCount = archivalEntityDraft.FrameCount,
                        //    Location = archivalEntityDraft.Location,
                        //    MicrofilmCount = archivalEntityDraft.MicrofilmCount,
                        //    MicrofilmedCopyCount = archivalEntityDraft.MicrofilmedCopyCount,
                        //    OtherCopyCount = archivalEntityDraft.OtherCopyCount,
                        //    PaperCopyCount = archivalEntityDraft.PaperCopyCount,
                        //    Scaling = archivalEntityDraft.Scaling,
                        //    SheetCount = archivalEntityDraft.SheetCount,
                        //    SizeCm = archivalEntityDraft.SizeCm,
                        //    TapeCount = archivalEntityDraft.TapeCount,
                        //    VideoTapeCount = archivalEntityDraft.VideoTapeCount,
                        //    DeductedBytes = archivalEntityDraft.DeductedBytes,
                        //    DeductedDocumentCount = archivalEntityDraft.DeductedDocumentCount,
                        //    DeductedLinearMeters = archivalEntityDraft.DeductedLinearMeters,
                        //    EnrolledBytes = archivalEntityDraft.EnrolledBytes,
                        //    EnrolledDocumentCount = archivalEntityDraft.EnrolledDocumentCount,
                        //    EnrolledLinearMeters = archivalEntityDraft.EnrolledLinearMeters,
                        //    DocumentsAccessDescription = archivalEntityDraft.DocumentsAccessDescription,
                        //    OtherMetrics = archivalEntityDraft.OtherMetrics,
                        //    Notes = archivalEntityDraft.Notes,
                        //    Bytes = archivalEntityDraft.Bytes,
                        //    NegativeFrameCount = archivalEntityDraft.NegativeFrameCount,
                        //    PositiveFrameCount = archivalEntityDraft.PositiveFrameCount,
                        //    HasExternalSource = archivalEntityDraft.HasExternalSource,
                        //    ExternalIdentifier = archivalEntityDraft.ExternalIdentifier,
                        //    CreationMethodCodes = archivalEntityDraft.CreationMethodCodes,
                        //    LanguageCodes = archivalEntityDraft.LanguageCodes,
                        //    OriginalityCodes = archivalEntityDraft.OriginalityCodes,
                        //};
                        var modifiedArchivalEntityDraft = new ArchivalEntityDraftModel();
                        modifiedArchivalEntityDraft.Assign(archivalEntityDraft);
                        modifiedArchivalEntityDraft.IsCurrent = archivalEntityDraft.IsDraft;
                        modifiedArchivalEntityDraft.ReadOnly = true;
                        modifiedArchivalEntityDraft.StatusCode = status;

                        await _archivalEntityService.UpdateDraftInternalAsync(modifiedArchivalEntityDraft);
                    }

                    var documentDraftSysIds = await _context.DocumentDrafts
                        .Where(d => d.InventorySystemIdentifier == process.InventorySystemIdentifier.Value && d.IsCurrent && !d.Deleted)
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
                        //    IsCurrent = documentDraft.IsDraft,
                        //    ReadOnly = true,
                        //    SystemIdentifier = documentDraft.SystemIdentifier,
                        //    ArchiveId = documentDraft.ArchiveId,
                        //    FundDraftId = documentDraft.FundDraftId,
                        //    FundSystemIdentifier = documentDraft.FundSystemIdentifier!.Value,
                        //    InventoryDraftId = documentDraft.InventoryDraftId,
                        //    InventorySystemIdentifier = documentDraft.InventorySystemIdentifier,
                        //    ArchivalEntityDraftId = documentDraft.ArchivalEntityDraftId,
                        //    ArchivalEntitySystemIdentifier = documentDraft.ArchivalEntitySystemIdentifier,
                        //    StatusCode = status,
                        //    AvailabilityStatusCode = documentDraft.AvailabilityStatusCode,
                        //    DescriptionLevelCode = documentDraft.DescriptionLevelCode,
                        //    Number = documentDraft.Number,
                        //    Title = documentDraft.Title,
                        //    ApproximateChronologicalScope = documentDraft.ApproximateChronologicalScope,
                        //    HasNoChronologicalScope = documentDraft.HasNoChronologicalScope,
                        //    StartDateDay = documentDraft.StartDateDay,
                        //    StartDateMonth = documentDraft.StartDateMonth,
                        //    StartDateYear = documentDraft.StartDateYear,
                        //    EndDateDay = documentDraft.EndDateDay,
                        //    EndDateMonth = documentDraft.EndDateMonth,
                        //    EndDateYear = documentDraft.EndDateYear,
                        //    Author = documentDraft.Author,
                        //    Description = documentDraft.Description,
                        //    DigitizedCopyCount = documentDraft.DigitizedCopyCount,
                        //    Features = documentDraft.Features,
                        //    Location = documentDraft.Location,
                        //    MicrofilmedCopyCount = documentDraft.MicrofilmedCopyCount,
                        //    OtherCopyCount = documentDraft.OtherCopyCount,
                        //    PaperCopyCount = documentDraft.PaperCopyCount,
                        //    Scaling = documentDraft.Scaling,
                        //    SheetCount = documentDraft.SheetCount,
                        //    SizeCm = documentDraft.SizeCm,
                        //    DocumentsAccessDescription = documentDraft.DocumentsAccessDescription,
                        //    OtherMetrics = documentDraft.OtherMetrics,
                        //    Notes = documentDraft.Notes,
                        //    Bytes = documentDraft.Bytes,
                        //    NegativeFrameCount = documentDraft.NegativeFrameCount,
                        //    PositiveFrameCount = documentDraft.PositiveFrameCount,
                        //    HasExternalSource = documentDraft.HasExternalSource,
                        //    ExternalIdentifier = documentDraft.ExternalIdentifier,
                        //    CreationMethodCodes = documentDraft.CreationMethodCodes,
                        //    LanguageCodes = documentDraft.LanguageCodes,
                        //    OriginalityCodes = documentDraft.OriginalityCodes,
                        //    DigitalDevice = documentDraft.DigitalDevice,
                        //    Duration = documentDraft.Duration,
                        //    EndSheetNumber = documentDraft.EndSheetNumber,
                        //    FileFormatCode = documentDraft.FileFormatCode,
                        //    FileTypeCodes = documentDraft.FileTypeCodes,
                        //    StartSheetNumber = documentDraft.StartSheetNumber,
                        //    Transcription = documentDraft.Transcription,
                        //};
                        var modifiedDocumentDraft = new DocumentDraftModel();
                        modifiedDocumentDraft.Assign(documentDraft);
                        modifiedDocumentDraft.IsCurrent = documentDraft.IsDraft;
                        modifiedDocumentDraft.ReadOnly = true;
                        modifiedDocumentDraft.StatusCode = status;

                        await _documentService.UpdateDraftInternalAsync(modifiedDocumentDraft);
                    }
                }

                if (process.ArchivalEntitySystemIdentifier.HasValue)
                {
                    var archivalEntity = await _archivalEntityService.GetArchivalEntityBySystemIdentifierAsync(process.ArchivalEntitySystemIdentifier.Value);
                    if (archivalEntity == null)
                    {
                        return OperationResult.Failed($"Archival entity {process.ArchivalEntitySystemIdentifier} does not exists");
                    }

                    int? archivalEntityDraftId = archivalEntity.IsDraft ? archivalEntity.Id : null;

                    if (archivalEntityDraftId.HasValue)
                    {
                        var archivalEntityDraft = await _archivalEntityService.GetCurrentDraftAsync(process.ArchivalEntitySystemIdentifier!.Value);
                        if (archivalEntityDraft == null)
                        {
                            return OperationResult.Failed($"Archival entity {process.ArchivalEntitySystemIdentifier} does not have current draft.");
                        }

                        //var modifiedArchivalEntityDraft = new ArchivalEntityDraftModel()
                        //{
                        //    Id = archivalEntityDraft.Id,
                        //    IsCurrent = archivalEntityDraft.IsDraft,
                        //    ReadOnly = true,
                        //    SystemIdentifier = archivalEntityDraft.SystemIdentifier,
                        //    ArchiveId = archivalEntityDraft.ArchiveId,
                        //    FundDraftId = archivalEntityDraft.FundDraftId,
                        //    FundSystemIdentifier = archivalEntityDraft.FundSystemIdentifier!.Value,
                        //    InventoryDraftId = archivalEntityDraft.InventoryDraftId,
                        //    InventorySystemIdentifier = archivalEntityDraft.InventorySystemIdentifier,
                        //    StatusCode = status,
                        //    AvailabilityStatusCode = archivalEntityDraft.AvailabilityStatusCode,
                        //    DescriptionLevelCode = archivalEntityDraft.DescriptionLevelCode,
                        //    Number = archivalEntityDraft.Number,
                        //    Title = archivalEntityDraft.Title,
                        //    ApproximateChronologicalScope = archivalEntityDraft.ApproximateChronologicalScope,
                        //    HasNoChronologicalScope = archivalEntityDraft.HasNoChronologicalScope,
                        //    StartDateDay = archivalEntityDraft.StartDateDay,
                        //    StartDateMonth = archivalEntityDraft.StartDateMonth,
                        //    StartDateYear = archivalEntityDraft.StartDateYear,
                        //    EndDateDay = archivalEntityDraft.EndDateDay,
                        //    EndDateMonth = archivalEntityDraft.EndDateMonth,
                        //    EndDateYear = archivalEntityDraft.EndDateYear,
                        //    Author = archivalEntityDraft.Author,
                        //    Condition = archivalEntityDraft.Condition,
                        //    Description = archivalEntityDraft.Description,
                        //    DigitalDeviceCount = archivalEntityDraft.DigitalDeviceCount,
                        //    DigitizedCopyCount = archivalEntityDraft.DigitizedCopyCount,
                        //    Features = archivalEntityDraft.Features,
                        //    FrameCount = archivalEntityDraft.FrameCount,
                        //    Location = archivalEntityDraft.Location,
                        //    MicrofilmCount = archivalEntityDraft.MicrofilmCount,
                        //    MicrofilmedCopyCount = archivalEntityDraft.MicrofilmedCopyCount,
                        //    OtherCopyCount = archivalEntityDraft.OtherCopyCount,
                        //    PaperCopyCount = archivalEntityDraft.PaperCopyCount,
                        //    Scaling = archivalEntityDraft.Scaling,
                        //    SheetCount = archivalEntityDraft.SheetCount,
                        //    SizeCm = archivalEntityDraft.SizeCm,
                        //    TapeCount = archivalEntityDraft.TapeCount,
                        //    VideoTapeCount = archivalEntityDraft.VideoTapeCount,
                        //    DeductedBytes = archivalEntityDraft.DeductedBytes,
                        //    DeductedDocumentCount = archivalEntityDraft.DeductedDocumentCount,
                        //    DeductedLinearMeters = archivalEntityDraft.DeductedLinearMeters,
                        //    EnrolledBytes = archivalEntityDraft.EnrolledBytes,
                        //    EnrolledDocumentCount = archivalEntityDraft.EnrolledDocumentCount,
                        //    EnrolledLinearMeters = archivalEntityDraft.EnrolledLinearMeters,
                        //    DocumentsAccessDescription = archivalEntityDraft.DocumentsAccessDescription,
                        //    OtherMetrics = archivalEntityDraft.OtherMetrics,
                        //    Notes = archivalEntityDraft.Notes,
                        //    Bytes = archivalEntityDraft.Bytes,
                        //    NegativeFrameCount = archivalEntityDraft.NegativeFrameCount,
                        //    PositiveFrameCount = archivalEntityDraft.PositiveFrameCount,
                        //    HasExternalSource = archivalEntityDraft.HasExternalSource,
                        //    ExternalIdentifier = archivalEntityDraft.ExternalIdentifier,
                        //    CreationMethodCodes = archivalEntityDraft.CreationMethodCodes,
                        //    LanguageCodes = archivalEntityDraft.LanguageCodes,
                        //    OriginalityCodes = archivalEntityDraft.OriginalityCodes,
                        //};
                        var modifiedArchivalEntityDraft = new ArchivalEntityDraftModel();
                        modifiedArchivalEntityDraft.Assign(archivalEntityDraft);
                        modifiedArchivalEntityDraft.IsCurrent = archivalEntityDraft.IsDraft;
                        modifiedArchivalEntityDraft.ReadOnly = true;
                        modifiedArchivalEntityDraft.StatusCode = status;

                        await _archivalEntityService.UpdateDraftInternalAsync(modifiedArchivalEntityDraft);

                    }

                    var documentDraftSysIds = await _context.DocumentDrafts
                        .Where(d => d.ArchivalEntitySystemIdentifier == process.ArchivalEntitySystemIdentifier.Value && d.IsCurrent && !d.Deleted)
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
                        //    IsCurrent = documentDraft.IsDraft,
                        //    ReadOnly = true ,
                        //    SystemIdentifier = documentDraft.SystemIdentifier,
                        //    ArchiveId = documentDraft.ArchiveId,
                        //    FundDraftId = documentDraft.FundDraftId,
                        //    FundSystemIdentifier = documentDraft.FundSystemIdentifier!.Value,
                        //    InventoryDraftId = documentDraft.InventoryDraftId,
                        //    InventorySystemIdentifier = documentDraft.InventorySystemIdentifier,
                        //    ArchivalEntityDraftId = documentDraft.ArchivalEntityDraftId,
                        //    ArchivalEntitySystemIdentifier = documentDraft.ArchivalEntitySystemIdentifier,
                        //    StatusCode = status,
                        //    AvailabilityStatusCode = documentDraft.AvailabilityStatusCode,
                        //    DescriptionLevelCode = documentDraft.DescriptionLevelCode,
                        //    Number = documentDraft.Number,
                        //    Title = documentDraft.Title,
                        //    ApproximateChronologicalScope = documentDraft.ApproximateChronologicalScope,
                        //    HasNoChronologicalScope = documentDraft.HasNoChronologicalScope,
                        //    StartDateDay = documentDraft.StartDateDay,
                        //    StartDateMonth = documentDraft.StartDateMonth,
                        //    StartDateYear = documentDraft.StartDateYear,
                        //    EndDateDay = documentDraft.EndDateDay,
                        //    EndDateMonth = documentDraft.EndDateMonth,
                        //    EndDateYear = documentDraft.EndDateYear,
                        //    Author = documentDraft.Author,
                        //    Description = documentDraft.Description,
                        //    DigitizedCopyCount = documentDraft.DigitizedCopyCount,
                        //    Features = documentDraft.Features,
                        //    Location = documentDraft.Location,
                        //    MicrofilmedCopyCount = documentDraft.MicrofilmedCopyCount,
                        //    OtherCopyCount = documentDraft.OtherCopyCount,
                        //    PaperCopyCount = documentDraft.PaperCopyCount,
                        //    Scaling = documentDraft.Scaling,
                        //    SheetCount = documentDraft.SheetCount,
                        //    SizeCm = documentDraft.SizeCm,
                        //    DocumentsAccessDescription = documentDraft.DocumentsAccessDescription,
                        //    OtherMetrics = documentDraft.OtherMetrics,
                        //    Notes = documentDraft.Notes,
                        //    Bytes = documentDraft.Bytes,
                        //    NegativeFrameCount = documentDraft.NegativeFrameCount,
                        //    PositiveFrameCount = documentDraft.PositiveFrameCount,
                        //    HasExternalSource = documentDraft.HasExternalSource,
                        //    ExternalIdentifier = documentDraft.ExternalIdentifier,
                        //    CreationMethodCodes = documentDraft.CreationMethodCodes,
                        //    LanguageCodes = documentDraft.LanguageCodes,
                        //    OriginalityCodes = documentDraft.OriginalityCodes,
                        //    DigitalDevice = documentDraft.DigitalDevice,
                        //    Duration = documentDraft.Duration,
                        //    EndSheetNumber = documentDraft.EndSheetNumber,
                        //    FileFormatCode = documentDraft.FileFormatCode,
                        //    FileTypeCodes = documentDraft.FileTypeCodes,
                        //    StartSheetNumber = documentDraft.StartSheetNumber,
                        //    Transcription = documentDraft.Transcription,
                        //};
                        var modifiedDocumentDraft = new DocumentDraftModel();
                        modifiedDocumentDraft.Assign(documentDraft);
                        modifiedDocumentDraft.IsCurrent = documentDraft.IsDraft;
                        modifiedDocumentDraft.ReadOnly = true;
                        modifiedDocumentDraft.StatusCode = status;

                        await _documentService.UpdateDraftInternalAsync(modifiedDocumentDraft);
                    }
                }

                if (process.DocumentSystemIdentifier.HasValue)
                {
                    var document = await _documentService.GetDocumentBySystemIdentifierAsync(process.DocumentSystemIdentifier.Value);
                    if (document == null)
                    {
                        return OperationResult.Failed($"Document {process.DocumentSystemIdentifier} does not exists");
                    }

                    int? documentDraftId = document.IsDraft ? document.Id : null;

                    if (documentDraftId.HasValue)
                    {
                        var documentDraft = await _documentService.GetCurrentDraftAsync(process.DocumentSystemIdentifier.Value);
                        if (documentDraft == null)
                        {
                            return OperationResult.Failed($"Document {process.DocumentSystemIdentifier} does not have current draft.");
                        }

                        //var modifiedDocumentDraft = new DocumentDraftModel()
                        //{
                        //    Id = documentDraft.Id,
                        //    IsCurrent = documentDraft.IsDraft,
                        //    ReadOnly = true,
                        //    SystemIdentifier = documentDraft.SystemIdentifier,
                        //    ArchiveId = documentDraft.ArchiveId,
                        //    FundDraftId = documentDraft.FundDraftId,
                        //    FundSystemIdentifier = documentDraft.FundSystemIdentifier!.Value,
                        //    InventoryDraftId = documentDraft.InventoryDraftId,
                        //    InventorySystemIdentifier = documentDraft.InventorySystemIdentifier,
                        //    ArchivalEntityDraftId = documentDraft.ArchivalEntityDraftId,
                        //    ArchivalEntitySystemIdentifier = documentDraft.ArchivalEntitySystemIdentifier,
                        //    StatusCode = status,
                        //    AvailabilityStatusCode = documentDraft.AvailabilityStatusCode,
                        //    DescriptionLevelCode = documentDraft.DescriptionLevelCode,
                        //    Number = documentDraft.Number,
                        //    Title = documentDraft.Title,
                        //    ApproximateChronologicalScope = documentDraft.ApproximateChronologicalScope,
                        //    HasNoChronologicalScope = documentDraft.HasNoChronologicalScope,
                        //    StartDateDay = documentDraft.StartDateDay,
                        //    StartDateMonth = documentDraft.StartDateMonth,
                        //    StartDateYear = documentDraft.StartDateYear,
                        //    EndDateDay = documentDraft.EndDateDay,
                        //    EndDateMonth = documentDraft.EndDateMonth,
                        //    EndDateYear = documentDraft.EndDateYear,
                        //    Author = documentDraft.Author,
                        //    Description = documentDraft.Description,
                        //    DigitizedCopyCount = documentDraft.DigitizedCopyCount,
                        //    Features = documentDraft.Features,
                        //    Location = documentDraft.Location,
                        //    MicrofilmedCopyCount = documentDraft.MicrofilmedCopyCount,
                        //    OtherCopyCount = documentDraft.OtherCopyCount,
                        //    PaperCopyCount = documentDraft.PaperCopyCount,
                        //    Scaling = documentDraft.Scaling,
                        //    SheetCount = documentDraft.SheetCount,
                        //    SizeCm = documentDraft.SizeCm,
                        //    DocumentsAccessDescription = documentDraft.DocumentsAccessDescription,
                        //    OtherMetrics = documentDraft.OtherMetrics,
                        //    Notes = documentDraft.Notes,
                        //    Bytes = documentDraft.Bytes,
                        //    NegativeFrameCount = documentDraft.NegativeFrameCount,
                        //    PositiveFrameCount = documentDraft.PositiveFrameCount,
                        //    HasExternalSource = documentDraft.HasExternalSource,
                        //    ExternalIdentifier = documentDraft.ExternalIdentifier,
                        //    CreationMethodCodes = documentDraft.CreationMethodCodes,
                        //    LanguageCodes = documentDraft.LanguageCodes,
                        //    OriginalityCodes = documentDraft.OriginalityCodes,
                        //    DigitalDevice = documentDraft.DigitalDevice,
                        //    Duration = documentDraft.Duration,
                        //    EndSheetNumber = documentDraft.EndSheetNumber,
                        //    FileFormatCode = documentDraft.FileFormatCode,
                        //    FileTypeCodes = documentDraft.FileTypeCodes,
                        //    StartSheetNumber = documentDraft.StartSheetNumber,
                        //    Transcription = documentDraft.Transcription,
                        //};
                        var modifiedDocumentDraft = new DocumentDraftModel();
                        modifiedDocumentDraft.Assign(documentDraft);
                        modifiedDocumentDraft.IsCurrent = documentDraft.IsDraft;
                        modifiedDocumentDraft.ReadOnly = true;
                        modifiedDocumentDraft.StatusCode = status;

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

        private async Task<OperationResult> SetReadOnlyDataAsync(ProcessModel process, bool isReadOnly)
        {
            try
            {
                if (process.FundSystemIdentifier.HasValue)
                {
                    var fund = await _fundService.GetFundBySystemIdentifierAsync(process.FundSystemIdentifier.Value);
                    if (fund == null)
                    {
                        return OperationResult.Failed($"Fund {process.FundSystemIdentifier} does not exists");
                    }

                    int? fundDraftId = fund.IsDraft ? fund.Id : null;

                    if (fundDraftId.HasValue)
                    {
                        var fundDraft = await _fundService.GetCurrentDraftAsync(process.FundSystemIdentifier!.Value);
                        if (fundDraft == null)
                        {
                            return OperationResult.Failed($"Fund {process.FundSystemIdentifier} does not have current draft.");
                        }

                        var modifiedFundDraft = new FundDraftModel();
                        modifiedFundDraft.Assign(fundDraft);
                        modifiedFundDraft.IsCurrent = fundDraft.IsDraft;
                        modifiedFundDraft.ReadOnly = isReadOnly;

                        await _fundService.UpdateDraftInternalAsync(modifiedFundDraft);
                    }

                    var inventoryDraftSysIds = await _context.InventoryDrafts
                        .Where(inv => inv.FundSystemIdentifier == process.FundSystemIdentifier.Value && inv.IsCurrent && !inv.Deleted)
                        .Select(inv => inv.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in inventoryDraftSysIds)
                    {
                        var inventoryDraft = await _inventoryService.GetCurrentDraftAsync(sysId);
                        if (inventoryDraft == null)
                        {
                            return OperationResult.Failed($"Inventory {sysId} does not have current draft");
                        }

                        var modifiedInventoryDraft = new InventoryDraftModel();
                        modifiedInventoryDraft.Assign(inventoryDraft);
                        modifiedInventoryDraft.IsCurrent = inventoryDraft.IsDraft;
                        modifiedInventoryDraft.ReadOnly = isReadOnly;

                        await _inventoryService.UpdateDraftInternalAsync(modifiedInventoryDraft);
                    }

                    var archivalEntityDraftSysIds = await _context.ArchivalEntityDrafts
                        .Where(ae => ae.FundSystemIdentifier == process.FundSystemIdentifier.Value && ae.IsCurrent && !ae.Deleted)
                        .Select(ae => ae.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in archivalEntityDraftSysIds)
                    {
                        var archivalEntityDraft = await _archivalEntityService.GetCurrentDraftAsync(sysId);
                        if (archivalEntityDraft == null)
                        {
                            return OperationResult.Failed($"Archival entity {sysId} does not have current draft");
                        }

                        var modifiedArchivalEntityDraft = new ArchivalEntityDraftModel();
                        modifiedArchivalEntityDraft.Assign(archivalEntityDraft);
                        modifiedArchivalEntityDraft.IsCurrent = archivalEntityDraft.IsDraft;
                        modifiedArchivalEntityDraft.ReadOnly = isReadOnly;

                        await _archivalEntityService.UpdateDraftInternalAsync(modifiedArchivalEntityDraft);
                    }

                    var documentDraftSysIds = await _context.DocumentDrafts
                        .Where(d => d.FundSystemIdentifier == process.FundSystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                        .Select(d => d.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in documentDraftSysIds)
                    {
                        var documentDraft = await _documentService.GetCurrentDraftAsync(sysId);
                        if (documentDraft == null)
                        {
                            return OperationResult.Failed($"Document {sysId} does not have current draft.");
                        }

                        var modifiedDocumentDraft = new DocumentDraftModel();
                        modifiedDocumentDraft.Assign(documentDraft);
                        modifiedDocumentDraft.IsCurrent = documentDraft.IsDraft;
                        modifiedDocumentDraft.ReadOnly = isReadOnly;

                        await _documentService.UpdateDraftInternalAsync(modifiedDocumentDraft);
                    }
                }

                if (process.InventorySystemIdentifier.HasValue)
                {
                    var inventory = await _inventoryService.GetInventoryBySystemIdentifierAsync(process.InventorySystemIdentifier.Value);
                    if (inventory == null)
                    {
                        return OperationResult.Failed($"Inventory {process.InventorySystemIdentifier} does not exists");
                    }

                    int? inventoryDraftId = inventory.IsDraft ? inventory.Id : null;

                    if (inventoryDraftId.HasValue)
                    {
                        var inventoryDraft = await _inventoryService.GetCurrentDraftAsync(process.InventorySystemIdentifier!.Value);
                        if (inventoryDraft == null)
                        {
                            return OperationResult.Failed($"Inventory {process.InventorySystemIdentifier} does not have current draft.");
                        }

                        var modifiedInventoryDraft = new InventoryDraftModel();
                        modifiedInventoryDraft.Assign(inventoryDraft);
                        modifiedInventoryDraft.IsCurrent = inventoryDraft.IsDraft;
                        modifiedInventoryDraft.ReadOnly = isReadOnly;

                        await _inventoryService.UpdateDraftInternalAsync(modifiedInventoryDraft);
                    }

                    var archivalEntityDraftSysIds = await _context.ArchivalEntityDrafts
                        .Where(ae => ae.InventorySystemIdentifier == process.InventorySystemIdentifier.Value && ae.IsCurrent && !ae.Deleted)
                        .Select(ae => ae.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in archivalEntityDraftSysIds)
                    {
                        var archivalEntityDraft = await _archivalEntityService.GetCurrentDraftAsync(sysId);
                        if (archivalEntityDraft == null)
                        {
                            return OperationResult.Failed($"Archival entity {sysId} does not have current draft");
                        }

                        var modifiedArchivalEntityDraft = new ArchivalEntityDraftModel();
                        modifiedArchivalEntityDraft.Assign(archivalEntityDraft);
                        modifiedArchivalEntityDraft.IsCurrent = archivalEntityDraft.IsDraft;
                        modifiedArchivalEntityDraft.ReadOnly = isReadOnly;

                        await _archivalEntityService.UpdateDraftInternalAsync(modifiedArchivalEntityDraft);
                    }

                    var documentDraftSysIds = await _context.DocumentDrafts
                        .Where(d => d.InventorySystemIdentifier == process.InventorySystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                        .Select(d => d.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in documentDraftSysIds)
                    {
                        var documentDraft = await _documentService.GetCurrentDraftAsync(sysId);
                        if (documentDraft == null)
                        {
                            return OperationResult.Failed($"Document {sysId} does not have current draft.");
                        }

                        var modifiedDocumentDraft = new DocumentDraftModel();
                        modifiedDocumentDraft.Assign(documentDraft);
                        modifiedDocumentDraft.IsCurrent = documentDraft.IsDraft;
                        modifiedDocumentDraft.ReadOnly = isReadOnly;

                        await _documentService.UpdateDraftInternalAsync(modifiedDocumentDraft);
                    }
                }

                if (process.ArchivalEntitySystemIdentifier.HasValue)
                {
                    var archivalEntity = await _archivalEntityService.GetArchivalEntityBySystemIdentifierAsync(process.ArchivalEntitySystemIdentifier.Value);
                    if (archivalEntity == null)
                    {
                        return OperationResult.Failed($"Archival entity {process.ArchivalEntitySystemIdentifier} does not exists");
                    }

                    int? archivalEntityDraftId = archivalEntity.IsDraft ? archivalEntity.Id : null;

                    if (archivalEntityDraftId.HasValue)
                    {
                        var archivalEntityDraft = await _archivalEntityService.GetCurrentDraftAsync(process.ArchivalEntitySystemIdentifier!.Value);
                        if (archivalEntityDraft == null)
                        {
                            return OperationResult.Failed($"Archival entity {process.ArchivalEntitySystemIdentifier} does not have current draft.");
                        }

                        var modifiedArchivalEntityDraft = new ArchivalEntityDraftModel();
                        modifiedArchivalEntityDraft.Assign(archivalEntityDraft);
                        modifiedArchivalEntityDraft.IsCurrent = archivalEntityDraft.IsDraft;
                        modifiedArchivalEntityDraft.ReadOnly = isReadOnly;

                        await _archivalEntityService.UpdateDraftInternalAsync(modifiedArchivalEntityDraft);
                    }

                    var documentDraftSysIds = await _context.DocumentDrafts
                        .Where(d => d.ArchivalEntitySystemIdentifier == process.ArchivalEntitySystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                        .Select(d => d.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in documentDraftSysIds)
                    {
                        var documentDraft = await _documentService.GetCurrentDraftAsync(sysId);
                        if (documentDraft == null)
                        {
                            return OperationResult.Failed($"Document {sysId} does not have current draft.");
                        }

                        var modifiedDocumentDraft = new DocumentDraftModel();
                        modifiedDocumentDraft.Assign(documentDraft);
                        modifiedDocumentDraft.IsCurrent = documentDraft.IsDraft;
                        modifiedDocumentDraft.ReadOnly = isReadOnly;

                        await _documentService.UpdateDraftInternalAsync(modifiedDocumentDraft);
                    }
                }

                if (process.DocumentSystemIdentifier.HasValue)
                {
                    var document = await _documentService.GetDocumentBySystemIdentifierAsync(process.DocumentSystemIdentifier.Value);
                    if (document == null)
                    {
                        return OperationResult.Failed($"Document {process.DocumentSystemIdentifier} does not exists");
                    }

                    int? documentDraftId = document.IsDraft ? document.Id : null;

                    if (documentDraftId.HasValue)
                    {
                        var documentDraft = await _documentService.GetCurrentDraftAsync(process.DocumentSystemIdentifier.Value);
                        if (documentDraft == null)
                        {
                            return OperationResult.Failed($"Document {process.DocumentSystemIdentifier} does not have current draft.");
                        }

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

        public async Task<OperationResult> StartProcessAsync(ProcessModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            if (model.ProcessTypeId!.Value != (int)ProcessType.RefineData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), ""));
            }

            var entitySystemIdentifier = _processService.GetEntitySystemIdentifier(model);
            var entityType = _processService.GetEntityType(model);
            var entityDescriptionLevel = await GetEntityDescriptionLevel(model);
            if (!entityDescriptionLevel.HasValue)
            {
                _logger.LogError($"{nameof(StartProcessAsync)}: Cannot start process RefineData. No entity description level for {entityType} with sysId {entitySystemIdentifier}.");
                return OperationResult.Failed(false, _localizer.GetString("Error_CannotStartProcess").ToString());
            }
            if (entityType == BusinessObjectType.Unknown)
            {
                _logger.LogError($"{nameof(StartProcessAsync)}: Cannot start process RefineData. Entity type unknown (sysId: {entitySystemIdentifier}).");
                return OperationResult.Failed(false, _localizer.GetString("Error_CannotStartProcess").ToString());
            }
            if(entityType == BusinessObjectType.Fund && entityDescriptionLevel.Value == (int)Shared.FundDescriptionLevel.RawFund)
            {
                _logger.LogWarning($"{nameof(StartProcessAsync)}: Cannot start process RefineData for raw fund with sysId {entitySystemIdentifier}).");
                return OperationResult.Failed(false, _localizer.GetString("Error_CannotStartProcess", _localizer.GetString("Fund_RawFund").ToString()).ToString());
            }
            if(entityType == BusinessObjectType.Inventory && entityDescriptionLevel.Value == (int)Shared.InventoryDescriptionLevel.RawInventory)
            {
                _logger.LogWarning($"{nameof(StartProcessAsync)}: Cannot start process RefineData for raw inventory with sysId {entitySystemIdentifier}).");
                return OperationResult.Failed(false, _localizer.GetString("Error_CannotStartProcess", _localizer.GetString("Inventory_RawInventory").ToString()).ToString());
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

                var processStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.RefineData_ProcessInitiation);
                if (!processStepResult.Succeeded)
                {
                    await transaction.RollbackAsync();
                    return processStepResult;
                }

                processStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.RefineData_EditData);
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
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var process = await _processService.GetProcessAsync(processId);

                var validateProcessResult = _processService.ValidateProcess(process, ProcessType.RefineData);
                if (!validateProcessResult.Succeeded)
                {
                    return validateProcessResult;
                }

                if (process!.ActiveProcessStepTypeId != (int)ProcessStepType.RefineData_Affirmation)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_InvalidProcessStepType", process.ActiveProcessStepName!, process.ProcessTypeTitle!).ToString());
                }

                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)process.ActiveProcessStepTypeId, process.Id, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
                }

                var activeStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)Shared.ProcessStepType.RefineData_ProcessFinalization);
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

                    var inventoryDraftSysIds = await _context.InventoryDrafts
                        .Where(inv => inv.FundSystemIdentifier == process.FundSystemIdentifier.Value && inv.IsCurrent && !inv.Deleted)
                        .Select(inv => inv.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in inventoryDraftSysIds)
                    {
                        var inventorySysId = await _inventoryService.CreateOrUpdateInventoryFromDraftInternalAsync(sysId,false);
                    }

                    var archivalEntityDraftSysIds = await _context.ArchivalEntityDrafts
                        .Where(ae => ae.FundSystemIdentifier == process.FundSystemIdentifier.Value && ae.IsCurrent && !ae.Deleted)
                        .Select(ae => ae.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in archivalEntityDraftSysIds)
                    {
                        var archivalEntitySysId = await _archivalEntityService.CreateOrUpdateArchivalEntityFromDraftInternalAsync(sysId, false);
                    }

                    var documentDraftSysIds = await _context.DocumentDrafts
                        .Where(d => d.FundSystemIdentifier == process.FundSystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                        .Select(d => d.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in documentDraftSysIds)
                    {
                        var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId, false);
                    }
                }

                if (process.InventorySystemIdentifier.HasValue)
                {
                    bool hasDraft = await _inventoryService.HasCurrentDraftAsync(process.InventorySystemIdentifier.Value);
                    if (hasDraft)
                    {
                        var inventorySysId = await _inventoryService.CreateOrUpdateInventoryFromDraftInternalAsync(process.InventorySystemIdentifier.Value, false);
                    }

                    var archivalEntityDraftSysIds = await _context.ArchivalEntityDrafts
                        .Where(ae => ae.InventorySystemIdentifier == process.InventorySystemIdentifier.Value && ae.IsCurrent && !ae.Deleted)
                        .Select(ae => ae.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in archivalEntityDraftSysIds)
                    {
                        var archivalEntitySysId = await _archivalEntityService.CreateOrUpdateArchivalEntityFromDraftInternalAsync(sysId, false);
                    }

                    var documentDraftSysIds = await _context.DocumentDrafts
                        .Where(d => d.InventorySystemIdentifier == process.InventorySystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                        .Select(d => d.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in documentDraftSysIds)
                    {
                        var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId,false);
                    }
                }

                if (process.ArchivalEntitySystemIdentifier.HasValue)
                {
                    bool hasDraft = await _archivalEntityService.HasCurrentDraftAsync(process.ArchivalEntitySystemIdentifier.Value);
                    if (hasDraft)
                    {
                        var archivalEntitySysId = await _archivalEntityService.CreateOrUpdateArchivalEntityFromDraftInternalAsync(process.ArchivalEntitySystemIdentifier.Value, false);
                    }

                    var documentDraftSysIds = await _context.DocumentDrafts
                        .Where(d => d.ArchivalEntitySystemIdentifier == process.ArchivalEntitySystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                        .Select(d => d.SystemIdentifier)
                        .ToListAsync();
                    foreach (Guid sysId in documentDraftSysIds)
                    {
                        var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId, false);
                    }
                }

                if (process.DocumentSystemIdentifier.HasValue)
                {
                    bool hasDraft = await _documentService.HasCurrentDraftAsync(process.DocumentSystemIdentifier.Value);
                    if (hasDraft)
                    {
                        var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(process.DocumentSystemIdentifier.Value, false);
                    }
                }

                var processCompleteResult = await _processService.CompleteProcessAsync(processId);

                //var processCompleteResult = await CompleteProcessCoreAsync(processId);
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

        //TODO да се изнесе в базов сервиз за процесите
        public async Task<OperationResult> CompleteProcessCoreAsync(int processId, bool overwriteCreatedFromDraft = true, bool overwriteModifiedFromDraft = true)
        {
            var process = await _processService.GetProcessAsync(processId);
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }
            //if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.RefineData)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            //}
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }

            var activeStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)Shared.ProcessStepType.RefineData_ProcessFinalization);
            if (!activeStepResult.Succeeded)
            {
                return activeStepResult;
            }

            if (process.FundSystemIdentifier.HasValue)
            {
                //Ако има описи или архивни единици без номер процесът не може да приключи
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

                //bool hasDraft = await _fundService.HasCurrentDraftAsync(process.FundSystemIdentifier.Value);
                //if (hasDraft)
                var fundDraft = await _fundService.GetCurrentDraftAsync(process.FundSystemIdentifier.Value);
                if (fundDraft != null)
                {
                    //Aко фондът няма номер процесът не може да приключи
                    if (string.IsNullOrWhiteSpace(fundDraft.Number))
                    {
                        return OperationResult.Failed(false, _localizer.GetString("Error_UnnumberedFund").ToString());
                    }

                    var fundSysId = await _fundService.CreateOrUpdateFundFromDraftInternalAsync(process.FundSystemIdentifier.Value, overwriteCreatedFromDraft, overwriteModifiedFromDraft);
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
                    var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId);
                }
            }

            if (process.InventorySystemIdentifier.HasValue)
            {
                //Ако има архивни единици без номер процесът не може да приключи
                if (await _archivalEntityService.AnyUnnumberedDraftsByFundIdentifier(process.InventorySystemIdentifier.Value))
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_UnnumberedArchivalEntities").ToString());
                }
                if (await _documentService.AnyUnnumberedDraftsByFundIdentifier(process.InventorySystemIdentifier.Value))
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_UnnumberedDocuments").ToString());
                }

                //bool hasDraft = await _inventoryService.HasCurrentDraftAsync(process.InventorySystemIdentifier.Value);
                //if (hasDraft)
                var inventoryDraft = await _inventoryService.GetCurrentDraftAsync(process.InventorySystemIdentifier.Value);
                if (inventoryDraft != null)
                {
                    //Aко описът няма номер процесът не може да приключи
                    if (string.IsNullOrWhiteSpace(inventoryDraft.Number))
                    {
                        return OperationResult.Failed(false, _localizer.GetString("Error_UnnumberedInventory").ToString());
                    }

                    var inventorySysId = await _inventoryService.CreateOrUpdateInventoryFromDraftInternalAsync(process.InventorySystemIdentifier.Value);
                    //await _fundService.CalculateDocFieldsInternalAsync(inventorySysId);
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
                    var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId);
                }
            }

            if (process.ArchivalEntitySystemIdentifier.HasValue)
            {
                //bool hasDraft = await _archivalEntityService.HasCurrentDraftAsync(process.ArchivalEntitySystemIdentifier.Value);
                //if (hasDraft)
                var archivalEntityDraft = await _archivalEntityService.GetCurrentDraftAsync(process.ArchivalEntitySystemIdentifier.Value);
                if (archivalEntityDraft != null)
                {
                    //Aко АЕ няма номер процесът не може да приключи
                    if (string.IsNullOrWhiteSpace(archivalEntityDraft.Number))
                    {
                        return OperationResult.Failed(false, _localizer.GetString("Error_UnnumberedArchivalEntity").ToString());
                    }

                    var archivalEntitySysId = await _archivalEntityService.CreateOrUpdateArchivalEntityFromDraftInternalAsync(process.ArchivalEntitySystemIdentifier.Value);
                }

                var documentDraftSysIds = await _context.DocumentDrafts
                    .Where(d => d.ArchivalEntitySystemIdentifier == process.ArchivalEntitySystemIdentifier.Value && d.IsCurrent && !d.Deleted)
                    .Select(d => d.SystemIdentifier)
                    .ToListAsync();
                foreach (Guid sysId in documentDraftSysIds)
                {
                    var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId);
                }
            }

            if (process.DocumentSystemIdentifier.HasValue)
            {
                bool hasDraft = await _documentService.HasCurrentDraftAsync(process.DocumentSystemIdentifier.Value);
                if (hasDraft)
                {
                    var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(process.DocumentSystemIdentifier.Value);
                }
            }

            return await _processService.CompleteProcessAsync(processId);
        }

        public async Task<OperationResult> UndoProcessChangesAsync(int processId)
        {
            var process = await _processService.GetProcessAsync(processId);
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.RefineData)
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
                OperationResult completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)process.ActiveProcessStepTypeId, process.Id, null, null);
                if (!completePrevTaskResult.Succeeded)
                {
                    transaction.Rollback();
                    return completePrevTaskResult;
                }

                var activeStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)Shared.ProcessStepType.RefineData_UndoChanges);
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

                    if (documentDraftId.HasValue)
                    {
                        await _documentService.DeleteDraftInternalAsync(documentDraftId.Value);
                    }
                }

                var report = await _context.Epkreports
                                .Where(r => r.ProcessId == processId && !r.Deleted)
                                .Select(r => r)
                                .SingleOrDefaultAsync();
                if (report != null)
                {
                    await _commissionReportService.DeleteReportInternalAsync(report.Id);
                }

                activeStepResult = await _processService.SetActiveProcessStepAsync(processId, (int)Shared.ProcessStepType.RefineData_ProcessFinalization);
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.RefineData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.RefineData_EditData
                && model.StepTypeId != (int)ProcessStepType.RefineData_DataModifications)
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
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (process.ProcessTypeId!.Value != (int)ProcessType.RefineData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.RefineData_CreateReport)
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
            //if (process == null)
            //{
            //    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            //}
            //if (process.ProcessTypeId!.Value != (int)ProcessType.RefineData)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            //}
            //if (process.Completed)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            //}
            //if (model.StepTypeId != (int)ProcessStepType.RefineData_SendReport)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            //}
            var validateProcessResult = _processService.ValidateProcess(process, ProcessType.RefineData);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }

            var validateProcessStepResult = _processService.ValidateProcessStep(process, model, ProcessStepType.RefineData_SendReport);
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
                    return OperationResult.Failed(false, _localizer.GetString("Error_ReportDoesNotExists", process.ProcessTypeTitle!).ToString());
                }

                report.IsDraft = false;
                var updateReportResult = await _commissionReportService.UpdateAsync(report);
                if (!updateReportResult.Succeeded)
                {
                    transaction.Rollback();
                    return updateReportResult;
                }

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

                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    //EntityId = GetEntityId(process),
                    EntitySystemIdentifier = _processService.GetEntitySystemIdentifier(process),
                    EntityType = _processService.GetEntityType(process),
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

        //    if (process.ProcessTypeId!.Value != (int)ProcessType.RefineData)
        //    {
        //        return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
        //    }
        //    if (process.Completed)
        //    {
        //        return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
        //    }
        //    if (model.StepTypeId != (int)ProcessStepType.RefineData_AddReportToSessionAgenda)
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
            //if (process == null)
            //{
            //    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            //}

            //if (process.ProcessTypeId!.Value != (int)ProcessType.RefineData)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            //}
            //if (process.Completed)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            //}
            //if (model.StepTypeId != (int)ProcessStepType.RefineData_SendToAddSessionAgendaStandpoint)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            //}
            var validateProcessResult = _processService.ValidateProcess(process, ProcessType.RefineData);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }

            if (process!.ActiveProcessStepTypeId != (int)ProcessStepType.RefineData_SendReport)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ProcessStepNotActive", process.ActiveProcessStepName!).ToString());
            }

            var validateProcessStepResult = _processService.ValidateProcessStep(process, model, ProcessStepType.RefineData_SendToAddSessionAgendaStandpoint);
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
                    //EntityId = GetEntityId(process),
                    EntitySystemIdentifier = _processService.GetEntitySystemIdentifier(process),
                    EntityType = _processService.GetEntityType(process),
                    AssignedToRoleId = model.AssignedToRoleId!.Value.ToString("D"),
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
                    StepTypeId = (int)ProcessStepType.RefineData_AddSessionAgendaStandpoint
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.RefineData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.RefineData_AddSessionAgendaStandpoint)
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
            //if (process == null)
            //{
            //    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            //}

            //if (process.ProcessTypeId!.Value != (int)ProcessType.RefineData)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            //}
            //if (process.Completed)
            //{
            //    return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            //}
            //if (model.StepTypeId != (int)ProcessStepType.RefineData_SendToAddSessionAgendaStandpointComment)
            //{
            //    return OperationResult.Failed(
            //        false,
            //        string.Format(_localizer.GetString("Error_InvalidProcessStepType").ToString(), "", process.ProcessTypeTitle));
            //}
            var validateProcessResult = _processService.ValidateProcess(process, ProcessType.RefineData);
            if (!validateProcessResult.Succeeded)
            {
                return validateProcessResult;
            }

            if (process!.ActiveProcessStepTypeId != (int)ProcessStepType.RefineData_AddSessionAgendaStandpoint)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ProcessStepNotActive", process.ActiveProcessStepName!).ToString());
            }

            var validateProcessStepResult = _processService.ValidateProcessStep(process, model, ProcessStepType.RefineData_SendToAddSessionAgendaStandpointComment);
            if (!validateProcessStepResult.Succeeded)
            {
                return validateProcessStepResult;
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

                completePrevTaskResult = await _taskService.CompletePreviousTask(ProcessStepType.RefineData_SendToAddSessionAgendaStandpoint, process.Id, null, null);
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
                    //EntityId = GetEntityId(process),
                    EntitySystemIdentifier = _processService.GetEntitySystemIdentifier(process),
                    EntityType = _processService.GetEntityType(process),
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
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (process.ProcessTypeId!.Value != (int)ProcessType.RefineData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.RefineData_AddSessionAgendaStandpointComment)
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.RefineData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.RefineData_SendSessionAgendaStandpointComment)
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

                var sessionAgendaStep = await _processService.GetProcessStepAsync(process.Id!.Value, ProcessStepType.RefineData_SendReport);
                var standpointStep = await _processService.GetProcessStepAsync(process.Id!.Value, ProcessStepType.RefineData_SendToAddSessionAgendaStandpoint);

                //Задача към секретар/председател на комисия
                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    //EntityId = GetEntityId(process),
                    EntitySystemIdentifier = _processService.GetEntitySystemIdentifier(process),
                    EntityType = _processService.GetEntityType(process),
                    AssignedToUserId = sessionAgendaStep?.AssignedToUserId!.Value.ToString("D"),
                    StepType = (Shared.ProcessStepType)model.StepTypeId,
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
                    //EntityId = GetEntityId(process),
                    EntitySystemIdentifier = _processService.GetEntitySystemIdentifier(process),
                    EntityType = _processService.GetEntityType(process),
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
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (process.ProcessTypeId!.Value != (int)ProcessType.RefineData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.RefineData_CommissionSession)
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

                //Задача към експерта, че е добавен за заседание
                var task = new TaskCreateModel()
                {
                    ProcessId = process.Id!.Value,
                    TimelineId = activeStepId,
                    //EntityId = GetEntityId(process),
                    EntitySystemIdentifier = _processService.GetEntitySystemIdentifier(process),
                    EntityType = _processService.GetEntityType(process),
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.RefineData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.RefineData_ChangesRequired
                && model.StepTypeId != (int)ProcessStepType.RefineData_ReportApproval
                && model.StepTypeId != (int)ProcessStepType.RefineData_ReportChangesRequired
                && model.StepTypeId != (int)ProcessStepType.RefineData_ReportRejection)
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
                    //EntityId = GetEntityId(process),
                    EntitySystemIdentifier = _processService.GetEntitySystemIdentifier(process),
                    EntityType = _processService.GetEntityType(process),
                    AssignedToUserId = process.CreatedBy?.ToString("D"),
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.RefineData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.RefineData_ReportModifications)
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.RefineData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.RefineData_SendForModificationsRevision)
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
                    //EntityId = GetEntityId(process),
                    EntitySystemIdentifier = _processService.GetEntitySystemIdentifier(process),
                    EntityType = _processService.GetEntityType(process),
                    AssignedToUserId = model.AssignedToUserId!.Value.ToString("D"),
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.RefineData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.RefineData_ModificationsRevision)
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.RefineData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.RefineData_SendForAffirmation)
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
                    //EntityId = GetEntityId(process),
                    EntitySystemIdentifier = _processService.GetEntitySystemIdentifier(process),
                    EntityType = _processService.GetEntityType(process),
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

            if (process.ProcessTypeId!.Value != (int)ProcessType.RefineData)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
            }
            if (model.StepTypeId != (int)ProcessStepType.RefineData_Affirmation
                && model.StepTypeId != (int)ProcessStepType.RefineData_ReportChangesRequired)
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

                if (model.StepTypeId == (int)ProcessStepType.RefineData_ReportChangesRequired)
                {
                    //Задача към експерта за искани промени.
                    var task = new TaskCreateModel()
                    {
                        ProcessId = process.Id!.Value,
                        TimelineId = activeStepId,
                        //EntityId = GetEntityId(process),
                        EntitySystemIdentifier = _processService.GetEntitySystemIdentifier(process),
                        EntityType = _processService.GetEntityType(process),
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

                if (model.StepTypeId == (int)ProcessStepType.RefineData_Affirmation)
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
                        //EntityId = GetEntityId(process),
                        EntitySystemIdentifier = _processService.GetEntitySystemIdentifier(process),
                        EntityType = _processService.GetEntityType(process),
                        AssignedToRoleId = roleA.Id.ToString("D"),
                        StepType = (ProcessStepType)model.StepTypeId,
                    };
                    var taskResult = await _taskService.CreateAsync(task);
                    if (!taskResult.Succeeded)
                    {
                        transaction.Rollback();
                        return taskResult;
                    }

                    completePrevTaskResult = await _taskService.CompletePreviousTask((ProcessStepType)model.StepTypeId, process.Id, null, null);
                    if (!completePrevTaskResult.Succeeded)
                    {
                        transaction.Rollback();
                        return completePrevTaskResult;
                    }

                    //Приключване на процеса
                    activeStepResult = await _processService.SetActiveProcessStepAsync(process.Id.Value, (int)ProcessStepType.RefineData_ProcessFinalization);
                    if (!activeStepResult.Succeeded)
                    {
                        transaction.Rollback();
                        return activeStepResult;
                    }

                    await SetDataStatusAsync(process, Shared.Status.Refined);

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
                            var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId);
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
                            var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId);
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
                            var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(sysId);
                        }
                    }

                    if (process.DocumentSystemIdentifier.HasValue)
                    {
                        bool hasDraft = await _documentService.HasCurrentDraftAsync(process.DocumentSystemIdentifier.Value);
                        if (hasDraft)
                        {
                            var documentSysId = await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(process.DocumentSystemIdentifier.Value);
                        }
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
            }

            return archiveId;
        }
    }
}
