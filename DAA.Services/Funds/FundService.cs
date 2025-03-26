using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Extensions.Models;
using DAA.Models;
using DAA.Models.Configuration;
using DAA.Models.Funds;
using DAA.Models.Processes;
using DAA.Services.Nomenclatures;
using DAA.Services.Process;
using DAA.Shared;
using DAA.Shared.Data;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.AspNetCore.Http;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.ComponentModel;
using System.Text;

namespace DAA.Services.Funds
{
    public class FundService : BaseService, IFundService
    {
        private readonly LinkedServerSettings _settings;
        private readonly IUserInfo _userInfo;
        private readonly INomenclatureService _nomenclatureService;
        private readonly IArchiveService _archiveService;
        private readonly IProcessService _processService;

        public FundService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IOptions<LinkedServerSettings> settings,
            IUserInfo userInfo,
            INomenclatureService nomenclatureService,
            IArchiveService archiveService,
            IProcessService processService,
            ILogger<IFundService> logger)
            : base(context, localizer, logger)
        {
            _settings = settings.Value;
            _userInfo = userInfo;
            _nomenclatureService = nomenclatureService;
            _archiveService = archiveService;
            _processService = processService;
        }

        public DataSourceResponseModel<FundDisplayModel> GetAll(DataSourceRequestModel model, bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.VFunds
                .OrderBy(f => f.NumberNumeric).ThenBy(f => f.NumberArray).ThenBy(f => f.CreatedOn)
                .Select(f => new FundDisplayModel()
                {
                    Id = f.Id,
                    SystemIdentifier = f.SystemIdentifier,
                    IsDraft = f.IsDraft!.Value,
                    ArchiveId = f.ArchiveId,
                    ArchiveCode = f.ArchiveCode,
                    ArchiveName = f.ArchiveName,
                    NumberArray = f.NumberArray,
                    NumberNumeric = f.NumberNumeric,
                    Number = f.Number,
                    Title = f.Title,
                    TypeCode = f.TypeCode!,
                    TypeText = f.TypeText,
                    StatusCode = f.StatusCode!,
                    StatusText = f.StatusText,
                    DescriptionLevelCode = f.DescriptionLevelCode!,
                    DescriptionLevelText = f.DescriptionLevelText,
                    AcquisitionMethodId = f.AcquisitionMethodId,
                    AcquisitionMethodText = f.AcquisitionMethodText,
                    HasExternalSource = f.HasExternalSource!.Value,
                    ExternalIdentifier = f.ExternalIdentifier,
                    ExternalSourceUpdatedOn = f.ExternalSourceUpdatedOn,
                    CreatedBy = f.CreatedBy,
                    CreatedByDisplayName = f.CreatedByDisplayName,
                    CreatedByUserName = f.CreatedByUserName,
                    CreatedOn = f.CreatedOn,
                    Deleted = f.Deleted,
                    DeletedBy = f.DeletedBy,
                    DeletedByDisplayName = f.DeletedByDisplayName,
                    DeletedByUserName = f.DeletedByUserName,
                    DeletedOn = f.DeletedOn,
                    UpdatedBy = f.UpdatedBy,
                    UpdatedByDisplayName = f.UpdatedByDisplayName,
                    UpdatedByUserName = f.UpdatedByUserName,
                    UpdatedOn = f.UpdatedOn,
                });

            if (!includeDeleted)
            {
                query = query.Where(f => !f.Deleted);
            }

            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }

            QueryResponseModel<FundDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<FundDisplayModel> result = new DataSourceResponseModel<FundDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(f => new FundDisplayModel()
                {
                    Id = f.Id,
                    SystemIdentifier = f.SystemIdentifier,
                    IsDraft = f.IsDraft,
                    ArchiveId = f.ArchiveId,
                    ArchiveCode = f.ArchiveCode,
                    ArchiveName = f.ArchiveName,
                    NumberArray = f.NumberArray,
                    NumberNumeric = f.NumberNumeric,
                    Number = f.Number,
                    Title = f.Title,
                    TypeCode = f.TypeCode!,
                    TypeText = f.TypeText,
                    StatusCode = f.StatusCode!,
                    StatusText = f.StatusText,
                    DescriptionLevelCode = f.DescriptionLevelCode!,
                    DescriptionLevelText = f.DescriptionLevelText,
                    AcquisitionMethodId = f.AcquisitionMethodId,
                    AcquisitionMethodText = f.AcquisitionMethodText,
                    HasExternalSource = f.HasExternalSource,
                    ExternalIdentifier = f.ExternalIdentifier,
                    ExternalSourceUpdatedOn = f.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    CreatedBy = f.CreatedBy,
                    CreatedByDisplayName = f.CreatedByDisplayName,
                    CreatedByUserName = f.CreatedByUserName,
                    CreatedOn = f.CreatedOn.UtcToLocalTime(),
                    Deleted = f.Deleted,
                    DeletedBy = f.DeletedBy,
                    DeletedByDisplayName = f.DeletedByDisplayName,
                    DeletedByUserName = f.DeletedByUserName,
                    DeletedOn = f.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = f.UpdatedBy,
                    UpdatedByDisplayName = f.UpdatedByDisplayName,
                    UpdatedByUserName = f.UpdatedByUserName,
                    UpdatedOn = f.UpdatedOn.UtcToLocalTime(),
                })
            };

            return result;
        }

        public async Task<int?> GetIdByExternalIdentifierAsync(int externalIdentifier)
        {
            return await _context.Funds
                .Where(f => f.ExternalIdentifier == externalIdentifier)
                .Select(f => f.Id)
                .SingleOrDefaultAsync();
        }

        public async Task<Guid?> GetSystemIdentifierByExternalIdentifierAsync(int externalIdentifier)
        {
            return await _context.Funds
                .Where(f => f.ExternalIdentifier == externalIdentifier)
                .Select(f => f.SystemIdentifier)
                .SingleOrDefaultAsync();
        }

        public async Task<FundDisplayModel?> GetFundById(int id)
        {
            var fund =
                await _context.Funds
                .Where(f => f.Id == id && !f.Deleted)
                .Select(f => new FundDisplayModel()
                {
                    Id = f.Id,
                    SystemIdentifier = f.SystemIdentifier,
                    IsDraft = false,
                    ArchiveId = f.ArchiveId,
                    ArchiveCode = f.Archive.Code,
                    ArchiveName = f.Archive.Name,
                    NumberArray = f.NumberArray,
                    NumberNumeric = f.NumberNumeric,
                    Number = f.Number,
                    Title = f.Title,
                    TypeCode = f.TypeCode!,
                    TypeText = f.TypeCodeNavigation!.Text,
                    StatusCode = f.StatusCode!,
                    StatusText = f.StatusCodeNavigation!.Text,
                    DescriptionLevelCode = f.DescriptionLevelCode!,
                    DescriptionLevelText = f.DescriptionLevelCodeNavigation!.Text,
                    ApproxmateChronologicalScope = f.ApproxmateChronologicalScope,
                    HasNoChronologicalScope = f.HasNoChronologicalScope,
                    StartDateDay = f.StartDateDay,
                    StartDateMonth = f.StartDateMonth,
                    StartDateYear = f.StartDateYear,
                    EndDateDay = f.EndDateDay,
                    EndDateMonth = f.EndDateMonth,
                    EndDateYear = f.EndDateYear,
                    FundCreatorActivityHistory = f.FundCreatorActivityHistory,
                    FundCreatorBiographicalHistory = f.FundCreatorBiographicalHistory,
                    FundCreatorTitleHistory = f.FundCreatorTitleHistory,
                    History = f.History,
                    DocumentsAccessDescription = f.DocumentsAccessDescription,
                    DocumentsDescription = f.DocumentsDescription,
                    DocumentsProvider = f.DocumentsProvider,
                    LinearMeters = f.LinearMeters,
                    OtherMetrics = f.OtherMetrics,
                    RelatedFunds = f.RelatedFunds,
                    Notes = f.Notes,
                    InventoryCount = f.InventoryCount,
                    ArchivalEntityCount = f.ArchivalEntityCount,
                    DocumentCount = f.DocumentCount,
                    Bytes = f.Bytes,
                    InvaluableDocumentsInventoryCount = f.InvaluableDocumentsInventoryCount,
                    ValuableDocumentsInventoryCount = f.ValuableDocumentsInventoryCount,
                    DeductedBytes = f.DeductedBytes,
                    DeductedInventoryCount = f.DeductedInventoryCount,
                    EnrolledBytes = f.EnrolledBytes,
                    EnrolledInventoryCount = f.EnrolledInventoryCount,
                    HasExternalSource = f.HasExternalSource,
                    ExternalIdentifier = f.ExternalIdentifier,
                    ExternalSourceUpdatedOn = f.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    CreatedBy = f.CreatedBy,
                    CreatedByDisplayName = f.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == f.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = f.CreatedByNavigation.UserName,
                    CreatedOn = f.CreatedOn.UtcToLocalTime(),
                    Deleted = f.Deleted,
                    DeletedBy = f.DeletedBy,
                    DeletedByDisplayName = f.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == f.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = f.DeletedByNavigation.UserName,
                    DeletedOn = f.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = f.UpdatedBy,
                    UpdatedByDisplayName = f.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == f.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = f.UpdatedByNavigation.UserName,
                    UpdatedOn = f.UpdatedOn.UtcToLocalTime(),

                    AcquisitionMethodId = f.AcquisitionMethodId,
                    AcquisitionMethodText = f.AcquisitionMethod!.Text,

                    FileTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.FileType),
                    FileTypeText = _nomenclatureService.GetEntityNomenclatureText(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.FileType),
                    IndustryTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.IndustryType),
                    IndustryTypeText = _nomenclatureService.GetEntityNomenclatureText(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.IndustryType),
                    LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.Language),
                    LanguageText = _nomenclatureService.GetEntityNomenclatureText(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.Language),
                })
                .SingleOrDefaultAsync();

            if (fund != null && fund.HasExternalSource && fund.ExternalIdentifier.HasValue)
            {
                fund = await GetFromExternalSourceAsync(fund.ExternalIdentifier.Value, fund.SystemIdentifier);
            }

            return fund;
        }

        public async Task<FundDisplayModel?> GetFundBySystemIdentifierAsync(Guid sysId)
        {
            var fundDraft = await GetCurrentDraftAsync(sysId);
            if (fundDraft != null)
            {
                var sizeInfo = await _context.VFundSizeInfos
                    .Where(x => x.FundSystemIdentifier == sysId && x.IsDraft == 1)
                    .SingleOrDefaultAsync();
                if(sizeInfo != null)
                {
                    fundDraft.InventoryCount = sizeInfo.EnrolledInventoryCount;
                    fundDraft.EnrolledInventoryCount = sizeInfo.EnrolledInventoryCount;
                    fundDraft.DeductedInventoryCount = sizeInfo.DeductedInventoryCount;
                    fundDraft.ArchivalEntityCount = sizeInfo.EnrolledArchivalEntityCount;
                    fundDraft.DocumentCount = sizeInfo.EnrolledDocumentCount;
                    fundDraft.Bytes = sizeInfo.EnrolledBytes;
                    fundDraft.EnrolledBytes = sizeInfo.EnrolledBytes;
                    fundDraft.DeductedBytes = sizeInfo.DeductedBytes;
                    string fileTypes = sizeInfo.FileTypes != null 
                        ? String.Join(
                            System.Globalization.CultureInfo.CurrentCulture.TextInfo.ListSeparator + " ", 
                            sizeInfo.FileTypes.Split("; ").Distinct()).ToUpper()
                        : String.Empty;
                    fundDraft.FileTypeText = fileTypes;
                }

                return fundDraft;
            }

            var fund =
                await _context.Funds
                .Where(f => f.SystemIdentifier == sysId && !f.Deleted)
                .Select(f => new FundDisplayModel()
                {
                    Id = f.Id,
                    SystemIdentifier = f.SystemIdentifier,
                    IsDraft = false,
                    ArchiveId = f.ArchiveId,
                    ArchiveCode = f.Archive.Code,
                    ArchiveName = f.Archive.Name,
                    NumberArray = f.NumberArray,
                    NumberNumeric = f.NumberNumeric,
                    Number = f.Number,
                    Title = f.Title,
                    TypeCode = f.TypeCode!,
                    TypeText = f.TypeCodeNavigation!.Text,
                    StatusCode = f.StatusCode!,
                    StatusText = f.StatusCodeNavigation!.Text,
                    DescriptionLevelCode = f.DescriptionLevelCode!,
                    DescriptionLevelText = f.DescriptionLevelCodeNavigation!.Text,
                    ApproxmateChronologicalScope = f.ApproxmateChronologicalScope,
                    HasNoChronologicalScope = f.HasNoChronologicalScope,
                    StartDateDay = f.StartDateDay,
                    StartDateMonth = f.StartDateMonth,
                    StartDateYear = f.StartDateYear,
                    EndDateDay = f.EndDateDay,
                    EndDateMonth = f.EndDateMonth,
                    EndDateYear = f.EndDateYear,
                    FundCreatorActivityHistory = f.FundCreatorActivityHistory,
                    FundCreatorBiographicalHistory = f.FundCreatorBiographicalHistory,
                    FundCreatorTitleHistory = f.FundCreatorTitleHistory,
                    History = f.History,
                    DocumentsAccessDescription = f.DocumentsAccessDescription,
                    DocumentsDescription = f.DocumentsDescription,
                    DocumentsProvider = f.DocumentsProvider,
                    LinearMeters = f.LinearMeters,
                    OtherMetrics = f.OtherMetrics,
                    RelatedFunds = f.RelatedFunds,
                    Notes = f.Notes,
                    InventoryCount = f.InventoryCount,
                    ArchivalEntityCount = f.ArchivalEntityCount,
                    DocumentCount = f.DocumentCount,
                    Bytes = f.Bytes,
                    InvaluableDocumentsInventoryCount = f.InvaluableDocumentsInventoryCount,
                    ValuableDocumentsInventoryCount = f.ValuableDocumentsInventoryCount,
                    DeductedBytes = f.DeductedBytes,
                    DeductedInventoryCount = f.DeductedInventoryCount,
                    EnrolledBytes = f.EnrolledBytes,
                    EnrolledInventoryCount = f.EnrolledInventoryCount,
                    HasExternalSource = f.HasExternalSource,
                    ExternalIdentifier = f.ExternalIdentifier,
                    ExternalSourceUpdatedOn = f.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    CreatedBy = f.CreatedBy,
                    CreatedByDisplayName = f.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == f.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = f.CreatedByNavigation.UserName,
                    CreatedOn = f.CreatedOn.UtcToLocalTime(),
                    Deleted = f.Deleted,
                    DeletedBy = f.DeletedBy,
                    DeletedByDisplayName = f.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == f.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = f.DeletedByNavigation.UserName,
                    DeletedOn = f.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = f.UpdatedBy,
                    UpdatedByDisplayName = f.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == f.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = f.UpdatedByNavigation.UserName,
                    UpdatedOn = f.UpdatedOn.UtcToLocalTime(),

                    AcquisitionMethodId = f.AcquisitionMethodId,
                    AcquisitionMethodText = f.AcquisitionMethod!.Text,

                    FileTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.FileType),
                    FileTypeText = _nomenclatureService.GetEntityNomenclatureText(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.FileType),
                    IndustryTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.IndustryType),
                    IndustryTypeText = _nomenclatureService.GetEntityNomenclatureText(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.IndustryType),
                    LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.Language),
                    LanguageText = _nomenclatureService.GetEntityNomenclatureText(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.Language),
                })
                .SingleOrDefaultAsync();

            if(fund != null)
            {
                var sizeInfo = await _context.VFundSizeInfos
                        .Where(x => x.FundSystemIdentifier == sysId && x.IsDraft == 0)
                        .SingleOrDefaultAsync();
                if (sizeInfo != null)
                {
                    fund.InventoryCount = sizeInfo.EnrolledInventoryCount;
                    fund.EnrolledInventoryCount = sizeInfo.EnrolledInventoryCount;
                    fund.DeductedInventoryCount = sizeInfo.DeductedInventoryCount;
                    fund.ArchivalEntityCount = sizeInfo.EnrolledArchivalEntityCount;
                    fund.DocumentCount = sizeInfo.EnrolledDocumentCount;
                    fund.Bytes = sizeInfo.EnrolledBytes;
                    fund.EnrolledBytes = sizeInfo.EnrolledBytes;
                    fund.DeductedBytes = sizeInfo.DeductedBytes;
                    string fileTypes = sizeInfo.FileTypes != null
                        ? String.Join(
                                System.Globalization.CultureInfo.CurrentCulture.TextInfo.ListSeparator + " ", 
                                sizeInfo.FileTypes.Split("; ").Distinct()).ToUpper()
                        : String.Empty;
                    fund.FileTypeText = fileTypes;
                }
            }

            if (fund != null && fund.HasExternalSource && fund.ExternalIdentifier.HasValue)
            {
                try
                {       
                    fund = await GetFromExternalSourceAsync(fund.ExternalIdentifier.Value, fund.SystemIdentifier);
                }
                catch (Exception)
                {
                    _logger.LogWarning("Error retrieving fund data from ISDA");

                    fund!.ResultMessage = Constants.ISDADataCannotBeDisplayedMessageKey; // тук, ако няма fund, вече трябва да се хвърли грешка
                }
            }

            return fund;
        }

        public async Task<FundDraftModel?> GetFundAsDraftModelBySystemIdentifierInternalAsync(Guid sysId)
        {
            var fund =
                await _context.Funds
                .Where(f => f.SystemIdentifier == sysId && !f.Deleted)
                .Select(f => new FundDraftModel()
                {
                    Id = f.Id,
                    SystemIdentifier = f.SystemIdentifier,
                    IsCurrent = true,
                    ReadOnly = false,
                    ArchiveId = f.ArchiveId,
                    ExternalIdentifier = f.ExternalIdentifier,
                    HasExternalSource = f.HasExternalSource,
                    NumberArray = f.NumberArray,
                    NumberNumeric = f.NumberNumeric,
                    Number = f.Number,
                    Title = f.Title,
                    DescriptionLevelCode = f.DescriptionLevelCode!,
                    TypeCode = f.TypeCode!,
                    StatusCode = f.StatusCode!,
                    HasNoChronologicalScope = f.HasNoChronologicalScope,
                    StartDateDay = f.StartDateDay,
                    StartDateMonth = f.StartDateMonth,
                    StartDateYear = f.StartDateYear,
                    EndDateDay = f.EndDateDay,
                    EndDateMonth = f.EndDateMonth,
                    EndDateYear = f.EndDateYear,
                    ApproxmateChronologicalScope = f.ApproxmateChronologicalScope,
                    Bytes = f.Bytes,
                    LinearMeters = f.LinearMeters,
                    OtherMetrics = f.OtherMetrics,
                    InventoryCount = f.InventoryCount,
                    ArchivalEntityCount = f.ArchivalEntityCount,
                    DocumentCount = f.DocumentCount,
                    FundCreatorTitleHistory = f.FundCreatorTitleHistory,
                    FundCreatorActivityHistory = f.FundCreatorActivityHistory,
                    FundCreatorBiographicalHistory = f.FundCreatorBiographicalHistory,
                    DocumentsProvider = f.DocumentsProvider,
                    DocumentsDescription = f.DocumentsDescription,
                    ValuableDocumentsInventoryCount = f.ValuableDocumentsInventoryCount,
                    InvaluableDocumentsInventoryCount = f.InvaluableDocumentsInventoryCount,
                    DocumentsAccessDescription = f.DocumentsAccessDescription,
                    History = f.History,
                    RelatedFunds = f.RelatedFunds,
                    Notes = f.Notes,
                    EnrolledBytes = f.EnrolledBytes,
                    EnrolledInventoryCount = f.EnrolledInventoryCount,
                    DeductedBytes = f.DeductedBytes,
                    DeductedInventoryCount = f.DeductedInventoryCount,

                    AcquisitionMethodId = f.AcquisitionMethodId,

                    FileTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.FileType),
                    IndustryTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.IndustryType),
                    LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.Language),
                })
                .SingleOrDefaultAsync();


            return fund;
        }

        public async Task<FundDisplayModel?> GetCurrentDraftAsync(Guid sysId)
        {
            var fundDraft =
                await _context.FundDrafts
                    .Where(f => f.SystemIdentifier == sysId && f.IsCurrent && !f.Deleted)
                    .Select(f => new FundDisplayModel()
                    {
                        Id = f.Id,
                        SystemIdentifier = f.SystemIdentifier,
                        IsDraft = true,
                        ArchiveId = f.ArchiveId,
                        ArchiveCode = f.Archive.Code,
                        ArchiveName = f.Archive.Name,
                        NumberArray = f.NumberArray,
                        NumberNumeric = f.NumberNumeric,
                        Number = f.Number,
                        Title = f.Title,
                        TypeCode = f.TypeCode!,
                        TypeText = f.TypeCodeNavigation!.Text,
                        StatusCode = f.StatusCode!,
                        StatusText = f.StatusCodeNavigation!.Text,
                        DescriptionLevelCode = f.DescriptionLevelCode!,
                        DescriptionLevelText = f.DescriptionLevelCodeNavigation!.Text,
                        ApproxmateChronologicalScope = f.ApproxmateChronologicalScope,
                        HasNoChronologicalScope = f.HasNoChronologicalScope,
                        StartDateDay = f.StartDateDay,
                        StartDateMonth = f.StartDateMonth,
                        StartDateYear = f.StartDateYear,
                        EndDateDay = f.EndDateDay,
                        EndDateMonth = f.EndDateMonth,
                        EndDateYear = f.EndDateYear,
                        FundCreatorActivityHistory = f.FundCreatorActivityHistory,
                        FundCreatorBiographicalHistory = f.FundCreatorBiographicalHistory,
                        FundCreatorTitleHistory = f.FundCreatorTitleHistory,
                        History = f.History,
                        DocumentsAccessDescription = f.DocumentsAccessDescription,
                        DocumentsDescription = f.DocumentsDescription,
                        DocumentsProvider = f.DocumentsProvider,
                        LinearMeters = f.LinearMeters,
                        OtherMetrics = f.OtherMetrics,
                        RelatedFunds = f.RelatedFunds,
                        Notes = f.Notes,
                        InventoryCount = f.InventoryCount,
                        ArchivalEntityCount = f.ArchivalEntityCount,
                        DocumentCount = f.DocumentCount,
                        Bytes = f.Bytes,
                        InvaluableDocumentsInventoryCount = f.InvaluableDocumentsInventoryCount,
                        ValuableDocumentsInventoryCount = f.ValuableDocumentsInventoryCount,
                        DeductedBytes = f.DeductedBytes,
                        DeductedInventoryCount = f.DeductedInventoryCount,
                        EnrolledBytes = f.EnrolledBytes,
                        EnrolledInventoryCount = f.EnrolledInventoryCount,
                        ApplicationId = f.ApplicationId,
                        HasExternalSource = f.HasExternalSource!.Value,
                        ExternalIdentifier = f.ExternalIdentifier,
                        ExternalSourceUpdatedOn = f.ExternalSourceUpdatedOn.UtcToLocalTime(),
                        CreatedBy = f.CreatedBy,
                        CreatedByDisplayName = f.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == f.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                        CreatedByUserName = f.CreatedByNavigation.UserName,
                        CreatedOn = f.CreatedOn.UtcToLocalTime(),
                        Deleted = f.Deleted,
                        DeletedBy = f.DeletedBy,
                        DeletedByDisplayName = f.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == f.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                        DeletedByUserName = f.DeletedByNavigation.UserName,
                        DeletedOn = f.DeletedOn.UtcToLocalTime(),
                        UpdatedBy = f.UpdatedBy,
                        UpdatedByDisplayName = f.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == f.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                        UpdatedByUserName = f.UpdatedByNavigation.UserName,
                        UpdatedOn = f.UpdatedOn.UtcToLocalTime(),

                        AcquisitionMethodId = f.AcquisitionMethodId,
                        AcquisitionMethodText = f.AcquisitionMethod!.Text,

                        FileTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(f.Id, BusinessObjectType.Fund, true, Shared.NomenclatureCode.FileType),
                        FileTypeText = _nomenclatureService.GetEntityNomenclatureText(f.Id, BusinessObjectType.Fund, true, Shared.NomenclatureCode.FileType),
                        IndustryTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(f.Id, BusinessObjectType.Fund, true, Shared.NomenclatureCode.IndustryType),
                        IndustryTypeText = _nomenclatureService.GetEntityNomenclatureText(f.Id, BusinessObjectType.Fund, true, Shared.NomenclatureCode.IndustryType),
                        LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(f.Id, BusinessObjectType.Fund, true, Shared.NomenclatureCode.Language),
                        LanguageText = _nomenclatureService.GetEntityNomenclatureText(f.Id, BusinessObjectType.Fund, true, Shared.NomenclatureCode.Language),
                    })
                .SingleOrDefaultAsync();


            return fundDraft;
        }

        public async Task<bool> HasCurrentDraftAsync(Guid sysId)
        {
            return await _context.FundDrafts
                    .Where(f => f.SystemIdentifier == sysId && f.IsCurrent && !f.Deleted)
                    .AnyAsync();
        }

        public async Task<bool> IsCurrentDraftAsync(FundDraftModel model)
        {
            return await _context.FundDrafts.Where(f => f.Id == model.Id && f.IsCurrent && !f.Deleted).AnyAsync();
        }

        public async Task<bool> IsReadOnlyDraftAsync(FundDraftModel model)
        {
            return await _context.FundDrafts.Where(f => f.Id == model.Id && (f.ReadOnly || !f.IsCurrent || f.Deleted)).AnyAsync();
        }

        async Task<Guid> IFundServiceBase.CreateDraftInternalAsync(FundDraftModel model, bool startProcess)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            if (!model.SystemIdentifier.HasValue)
            {
                model.SystemIdentifier = Guid.NewGuid();
            }
            else
            {
                var currentDraft =
                    await _context.FundDrafts
                    .Where(f => f.SystemIdentifier == model.SystemIdentifier && f.IsCurrent)
                    .SingleOrDefaultAsync();
                if (currentDraft != null)
                {
                    currentDraft.IsCurrent = false;
                    currentDraft.ReadOnly = true;
                    _context.Update(currentDraft);
                }
            }

            var fundDraft = new FundDraft
            {
                IsCurrent = true,
                ReadOnly = false,
                SystemIdentifier = model.SystemIdentifier.Value,
                ArchiveId = model.ArchiveId!.Value,
                WorkflowId = model.WorkflowId,
                WorkflowTypeCode = model.WorkflowTypeCode,
                WorkflowStepId = model.WorkflowStepId,
                WorkflowStepTypeCode = model.WorkflowStepTypeCode,
                NumberArray = model.NumberArray,
                NumberNumeric = model.NumberNumeric,
                Number = model.Number,
                Title = model.Title,
                DescriptionLevelCode = model.DescriptionLevelCode,
                TypeCode = model.TypeCode,
                StatusCode = model.StatusCode,
                AcquisitionMethodId = model.AcquisitionMethodId,
                HasNoChronologicalScope = model.HasNoChronologicalScope,
                StartDateYear = model.StartDateYear,
                StartDateMonth = model.StartDateMonth,
                StartDateDay = model.StartDateDay,
                EndDateYear = model.EndDateYear,
                EndDateMonth = model.EndDateMonth,
                EndDateDay = model.EndDateDay,
                ApproxmateChronologicalScope = model.ApproxmateChronologicalScope,
                Bytes = model.Bytes,
                LinearMeters = model.LinearMeters,
                OtherMetrics = model.OtherMetrics,
                InventoryCount = model.InventoryCount,
                ArchivalEntityCount = model.ArchivalEntityCount,
                DocumentCount = model.DocumentCount,
                FundCreatorTitleHistory = model.FundCreatorTitleHistory,
                FundCreatorActivityHistory = model.FundCreatorActivityHistory,
                FundCreatorBiographicalHistory = model.FundCreatorBiographicalHistory,
                DocumentsProvider = model.DocumentsProvider,
                DocumentsDescription = model.DocumentsDescription,
                ValuableDocumentsInventoryCount = model.ValuableDocumentsInventoryCount,
                InvaluableDocumentsInventoryCount = model.InvaluableDocumentsInventoryCount,
                DocumentsAccessDescription = model.DocumentsAccessDescription,
                History = model.History,
                RelatedFunds = model.RelatedFunds,
                Notes = model.Notes,
                EnrolledBytes = model.EnrolledBytes,
                EnrolledInventoryCount = model.EnrolledInventoryCount,
                DeductedBytes = model.DeductedBytes,
                DeductedInventoryCount = model.DeductedInventoryCount,
                HasExternalSource = model.HasExternalSource,
                ExternalIdentifier = model.ExternalIdentifier,
            };

            if (model.HasExternalSource)
                fundDraft.ExternalSourceUpdatedOn = DateTime.UtcNow;

            _context.FundDrafts.Add(fundDraft);
            var res = await _context.SaveAsync("Fund draft created");


            //Industry types
            if (model.IndustryTypeCodes?.Count() > 0)
            {
                var industryTypeValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.IndustryTypeCodes, null, Shared.NomenclatureCode.IndustryType, 
                    fundDraft.Id, BusinessObjectType.Fund, true);

                if(industryTypeValues != null)
                {
                    _context.NomenclatureValues.AddRange(industryTypeValues!);
                }
            }

            //File types
            if (model.FileTypeCodes?.Count() > 0)
            {
                var fileTypeValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.FileTypeCodes, null, Shared.NomenclatureCode.FileType, 
                    fundDraft.Id, BusinessObjectType.Fund, true);

                if(fileTypeValues != null)
                {
                    _context.NomenclatureValues.AddRange(fileTypeValues!);
                }
            }

            //Languages
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, null, Shared.NomenclatureCode.Language, 
                    fundDraft.Id, BusinessObjectType.Fund, true);

                if(languageValues != null)
                {
                    _context.NomenclatureValues.AddRange(languageValues!);
                }
            }

            await _context.SaveAsync("Fund draft created");

            if (startProcess)
            {
                //Start process
                int processTypeId = model.DescriptionLevelCode == ((int)Shared.FundDescriptionLevel.Fund).ToString() ? (int)Shared.ProcessType.AddFundAndInventory : (int)Shared.ProcessType.AddRawFundAndRawInventory;
                ProcessModel process = new ProcessModel()
                {
                    ActiveProcessStepTypeId = (int)ProcessStepType.ProcessInitialization,
                    FundSystemIdentifier = fundDraft.SystemIdentifier,
                    ArchiveId = fundDraft.ArchiveId,
                    Completed = false,
                    ProcessTypeId = processTypeId
                };

                var dbProcess = await _processService.CreateProcessAsync(process);
                await _processService.AddStepAsync(dbProcess.Id, process.ActiveProcessStepTypeId.Value);
            }

            return fundDraft.SystemIdentifier;
        }

        public async Task<OperationResult> CreateDraftAsync(FundDraftModel model, bool startProcess = false)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var fundDraftSysId = await ((IFundService)this).CreateDraftInternalAsync(model, startProcess);

                transaction.Commit();
                return OperationResult.Succeed(fundDraftSysId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        //TODO не се реферира никъде, вероятно трябва да се изтрие.
        //public async Task<OperationResult> CreateDraftFromIdentifierAsync(Guid systemIdentifier)
        //{
        //    var fund = await GetFundBySystemIdentifierAsync(systemIdentifier);

        //    FundDraftModel draft = new()
        //    {
        //        AcquisitionMethodId = fund.AcquisitionMethodId,
        //        //AcquisitionMethodCodes = fund.AcquisitionMethodCodes,
        //        ApproxmateChronologicalScope = fund.ApproxmateChronologicalScope,
        //        ArchivalEntityCount = fund.ArchivalEntityCount,
        //        ArchiveId = fund.ArchiveId,
        //        Bytes = fund.Bytes,
        //        DeductedBytes = fund.DeductedBytes,
        //        DeductedInventoryCount = fund.DeductedInventoryCount,
        //        DescriptionLevelCode = fund.DescriptionLevelCode,
        //        DocumentCount = fund.DocumentCount,
        //        DocumentsAccessDescription = fund.DocumentsAccessDescription,
        //        DocumentsDescription = fund.DocumentsDescription,
        //        DocumentsProvider = fund.DocumentsProvider,
        //        EndDateDay = fund.EndDateDay,
        //        EndDateMonth = fund.EndDateMonth,
        //        EndDateYear = fund.EndDateYear,
        //        EnrolledBytes = fund.EnrolledBytes,
        //        EnrolledInventoryCount = fund.EnrolledInventoryCount,
        //        ExternalIdentifier = fund.ExternalIdentifier,
        //        FileTypeCodes = fund.FileTypeCodes,
        //        FundCreatorActivityHistory = fund.FundCreatorActivityHistory,
        //        FundCreatorBiographicalHistory = fund.FundCreatorBiographicalHistory,
        //        FundCreatorTitleHistory = fund.FundCreatorTitleHistory,
        //        HasExternalSource = fund.HasExternalSource,
        //        HasNoChronologicalScope = fund.HasNoChronologicalScope,
        //        History = fund.History,
        //        IndustryTypeCodes = fund.IndustryTypeCodes,
        //        InvaluableDocumentsInventoryCount = fund.InvaluableDocumentsInventoryCount,
        //        InventoryCount = fund.InventoryCount,
        //        IsCurrent = true,
        //        LanguageCodes = fund.LanguageCodes,
        //        LinearMeters = fund.LinearMeters,
        //        Notes = fund.Notes,
        //        Number = fund.Number,
        //        NumberArray = fund.NumberArray,
        //        NumberNumeric = fund.NumberNumeric,
        //        OtherMetrics = fund.OtherMetrics,
        //        RelatedFunds = fund.RelatedFunds,
        //        StartDateDay = fund.StartDateDay,
        //        ValuableDocumentsInventoryCount = fund.ValuableDocumentsInventoryCount,
        //        StatusCode = Shared.Status.Deducted,
        //        Title = fund.Title,
        //        StartDateMonth = fund.StartDateMonth,
        //        StartDateYear = fund.StartDateYear,
        //        TypeCode = fund.TypeCode,
        //        SystemIdentifier = fund.SystemIdentifier,
        //        ReadOnly = false
        //    };

        //    return await CreateDraftAsync(draft);
        //}

        async Task<Guid> IFundServiceBase.CreateFundInternalAsync(FundModel model, Guid? createdBy, DateTime? createdOn)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            if (!model.HasExternalSource && !model.SystemIdentifier.HasValue)
            {
                throw new SystemIdentifierNullException(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            if (!model.SystemIdentifier.HasValue)
            {
                model.SystemIdentifier = Guid.NewGuid();
            }

            var fund = new Fund
            {
                SystemIdentifier = model.SystemIdentifier.Value,
                ArchiveId = model.ArchiveId!.Value,
                NumberArray = model.NumberArray,
                NumberNumeric = model.NumberNumeric,
                Number = model.Number,
                Title = model.Title,
                DescriptionLevelCode = model.DescriptionLevelCode,
                TypeCode = model.TypeCode,
                StatusCode = model.StatusCode,
                AcquisitionMethodId = model.AcquisitionMethodId,
                HasNoChronologicalScope = model.HasNoChronologicalScope,
                StartDateYear = model.StartDateYear,
                StartDateMonth = model.StartDateMonth,
                StartDateDay = model.StartDateDay,
                EndDateYear = model.EndDateYear,
                EndDateMonth = model.EndDateMonth,
                EndDateDay = model.EndDateDay,
                ApproxmateChronologicalScope = model.ApproxmateChronologicalScope,
                Bytes = model.Bytes,
                LinearMeters = model.LinearMeters,
                OtherMetrics = model.OtherMetrics,
                InventoryCount = model.InventoryCount,
                ArchivalEntityCount = model.ArchivalEntityCount,
                DocumentCount = model.DocumentCount,
                FundCreatorTitleHistory = model.FundCreatorTitleHistory,
                FundCreatorActivityHistory = model.FundCreatorActivityHistory,
                FundCreatorBiographicalHistory = model.FundCreatorBiographicalHistory,
                DocumentsProvider = model.DocumentsProvider,
                DocumentsDescription = model.DocumentsDescription,
                ValuableDocumentsInventoryCount = model.ValuableDocumentsInventoryCount,
                InvaluableDocumentsInventoryCount = model.InvaluableDocumentsInventoryCount,
                DocumentsAccessDescription = model.DocumentsAccessDescription,
                History = model.History,
                RelatedFunds = model.RelatedFunds,
                Notes = model.Notes,
                EnrolledBytes = model.EnrolledBytes,
                EnrolledInventoryCount = model.EnrolledInventoryCount,
                DeductedBytes = model.DeductedBytes,
                DeductedInventoryCount = model.DeductedInventoryCount,
                HasExternalSource = model.HasExternalSource,
                ExternalIdentifier = model.ExternalIdentifier,
            };

            if (model.HasExternalSource)
                fund.ExternalSourceUpdatedOn = DateTime.UtcNow;

            bool overwriteCreated = createdBy.HasValue && createdOn.HasValue;
            if (overwriteCreated)
            {
                fund.CreatedBy = createdBy;
                fund.CreatedOn = createdOn;
            }
            
            _context.Funds.Add(fund);
            await _context.SaveAsync("Fund created", overwriteCreated);

            //Aqcuisition methods
            //if (model.AcquisitionMethodCodes?.Count() > 0)
            //{
            //    var acquisitionMethods = _nomenclatureService.GetNomenclatureValues(Shared.NomenclatureCode.AcquisitionMethod);
            //    var acquisitionValues = model.AcquisitionMethodCodes?
            //                            .Select(ac => new NomenclatureValue()
            //                            {
            //                                EntityId = fund.Id,
            //                                EntityType = BusinessObjectType.Fund,
            //                                EntityIsDraft = false,
            //                                NomenclatureCode = acquisitionMethods.Where(nv => nv.Code == ac).Select(nv => nv.ParentCode).FirstOrDefault()!,
            //                                NomenclatureId = acquisitionMethods.Where(nv => nv.Code == ac).Select(nv => nv.ParentId!.Value).FirstOrDefault(),
            //                                ValueCode = ac,
            //                                ValueId = acquisitionMethods.Where(nv => nv.Code == ac).Select(nv => nv.Id!.Value).FirstOrDefault(),
            //                            });
            //    _context.NomenclatureValues.AddRange(acquisitionValues!);
            //}

            //Industry types
            if (model.IndustryTypeCodes?.Count() > 0)
            {
                var industryTypeValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.IndustryTypeCodes, null, Shared.NomenclatureCode.IndustryType,
                    fund.Id, BusinessObjectType.Fund, false,
                    overwriteCreated, createdBy, createdOn);

                if(industryTypeValues != null)
                {
                    _context.NomenclatureValues.AddRange(industryTypeValues!);
                }
            }

            //File types
            if (model.FileTypeCodes?.Count() > 0)
            {
                var fileTypeValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.FileTypeCodes, null, Shared.NomenclatureCode.FileType,
                    fund.Id, BusinessObjectType.Fund, false,
                    overwriteCreated, createdBy, createdOn);

                if(fileTypeValues != null)
                {
                    _context.NomenclatureValues.AddRange(fileTypeValues!);
                }
            }

            //Languages
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, null, Shared.NomenclatureCode.Language,
                    fund.Id, BusinessObjectType.Fund, false,
                    overwriteCreated, createdBy, createdOn);

                if(languageValues != null)
                {
                    _context.NomenclatureValues.AddRange(languageValues!);
                }
            }
            await _context.SaveAsync("Fund created", overwriteCreated);

            return fund.SystemIdentifier;
        }

        public async Task<OperationResult> CreateFundAsync(FundModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            if (!model.HasExternalSource && !model.SystemIdentifier.HasValue)
            {
                return OperationResult.Failed(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var fundSysId = await ((IFundService)this).CreateFundInternalAsync(model);
                transaction.Commit();
                return OperationResult.Succeed(fundSysId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        async Task<Guid> IFundServiceBase.CreateOrUpdateFundFromDraftInternalAsync(Guid sysId, bool overwriteCreatedFromDraft, bool overwriteModifiedFromDraft)
        {
            var fundDraft = await GetCurrentDraftAsync(sysId);
            if (fundDraft == null)
            {
                throw new ItemDraftNotCurrentException(_localizer.GetString("Error_DraftNotCurrent").ToString(), sysId.ToString());
            }

            Guid? createdBy = null;
            Guid? updatedBy = null;
            DateTime? createdOn = null;
            DateTime? updatedOn = null;

            if (overwriteCreatedFromDraft)
            {
                createdBy = fundDraft.CreatedBy;
                createdOn = fundDraft.CreatedOn;
            }
            if (overwriteModifiedFromDraft)
            {
                updatedBy = fundDraft.UpdatedBy ?? fundDraft.CreatedBy;
                updatedOn = fundDraft.UpdatedOn ?? fundDraft.CreatedOn;
            }

            var fund =
                await _context.Funds
                .Where(f => f.SystemIdentifier == sysId && !f.Deleted)
                .Select(f => new FundModel()
                {
                    Id = f.Id,
                    SystemIdentifier = f.SystemIdentifier,
                    ArchiveId = f.ArchiveId,
                    NumberArray = f.NumberArray,
                    NumberNumeric = f.NumberNumeric,
                    Number = f.Number,
                    Title = f.Title,
                    DescriptionLevelCode = f.DescriptionLevelCode!,
                    TypeCode = f.TypeCode!,
                    StatusCode = f.StatusCode!,
                    HasNoChronologicalScope = f.HasNoChronologicalScope,
                    StartDateYear = f.StartDateYear,
                    StartDateMonth = f.StartDateMonth,
                    StartDateDay = f.StartDateDay,
                    EndDateYear = f.EndDateYear,
                    EndDateMonth = f.EndDateMonth,
                    EndDateDay = f.EndDateDay,
                    ApproxmateChronologicalScope = f.ApproxmateChronologicalScope,
                    Bytes = f.Bytes,
                    LinearMeters = f.LinearMeters,
                    OtherMetrics = f.OtherMetrics,
                    InventoryCount = f.InventoryCount,
                    ArchivalEntityCount = f.ArchivalEntityCount,
                    DocumentCount = f.DocumentCount,
                    FundCreatorTitleHistory = f.FundCreatorTitleHistory,
                    FundCreatorActivityHistory = f.FundCreatorActivityHistory,
                    FundCreatorBiographicalHistory = f.FundCreatorBiographicalHistory,
                    DocumentsProvider = f.DocumentsProvider,
                    DocumentsDescription = f.DocumentsDescription,
                    ValuableDocumentsInventoryCount = f.ValuableDocumentsInventoryCount,
                    InvaluableDocumentsInventoryCount = f.InvaluableDocumentsInventoryCount,
                    DocumentsAccessDescription = f.DocumentsAccessDescription,
                    History = f.History,
                    RelatedFunds = f.RelatedFunds,
                    Notes = f.Notes,
                    EnrolledBytes = f.EnrolledBytes,
                    EnrolledInventoryCount = f.EnrolledInventoryCount,
                    DeductedBytes = f.DeductedBytes,
                    DeductedInventoryCount = f.DeductedInventoryCount,
                    HasExternalSource = f.HasExternalSource,
                    ExternalIdentifier = f.ExternalIdentifier,

                    AcquisitionMethodId = f.AcquisitionMethodId,

                    FileTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.FileType),
                    IndustryTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.IndustryType),
                    LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.Language),
                })
                .SingleOrDefaultAsync();

            if (fund != null)
            {
                fund.SystemIdentifier = fundDraft.SystemIdentifier;
                fund.ArchiveId = fundDraft.ArchiveId;
                fund.NumberArray = fundDraft.NumberArray;
                fund.NumberNumeric = fundDraft.NumberNumeric;
                fund.Number = fundDraft.Number;
                fund.Title = fundDraft.Title;
                fund.DescriptionLevelCode = fundDraft.DescriptionLevelCode;
                fund.TypeCode = fundDraft.TypeCode;
                fund.StatusCode = fundDraft.StatusCode;
                fund.HasNoChronologicalScope = fundDraft.HasNoChronologicalScope;
                fund.StartDateYear = fundDraft.StartDateYear;
                fund.StartDateMonth = fundDraft.StartDateMonth;
                fund.StartDateDay = fundDraft.StartDateDay;
                fund.EndDateYear = fundDraft.EndDateYear;
                fund.EndDateMonth = fundDraft.EndDateMonth;
                fund.EndDateDay = fundDraft.EndDateDay;
                fund.ApproxmateChronologicalScope = fundDraft.ApproxmateChronologicalScope;
                fund.Bytes = fundDraft.Bytes;
                fund.LinearMeters = fundDraft.LinearMeters;
                fund.OtherMetrics = fundDraft.OtherMetrics;
                fund.InventoryCount = fundDraft.InventoryCount;
                fund.ArchivalEntityCount = fundDraft.ArchivalEntityCount;
                fund.DocumentCount = fundDraft.DocumentCount;
                fund.FundCreatorTitleHistory = fundDraft.FundCreatorTitleHistory;
                fund.FundCreatorActivityHistory = fundDraft.FundCreatorActivityHistory;
                fund.FundCreatorBiographicalHistory = fundDraft.FundCreatorBiographicalHistory;
                fund.DocumentsProvider = fundDraft.DocumentsProvider;
                fund.DocumentsDescription = fundDraft.DocumentsDescription;
                fund.ValuableDocumentsInventoryCount = fundDraft.ValuableDocumentsInventoryCount;
                fund.InvaluableDocumentsInventoryCount = fundDraft.InvaluableDocumentsInventoryCount;
                fund.DocumentsAccessDescription = fundDraft.DocumentsAccessDescription;
                fund.History = fundDraft.History;
                fund.RelatedFunds = fundDraft.RelatedFunds;
                fund.Notes = fundDraft.Notes;
                fund.EnrolledBytes = fundDraft.EnrolledBytes;
                fund.EnrolledInventoryCount = fundDraft.EnrolledInventoryCount;
                fund.DeductedBytes = fundDraft.DeductedBytes;
                fund.DeductedInventoryCount = fundDraft.DeductedInventoryCount;
                fund.HasExternalSource = fundDraft.HasExternalSource;
                fund.ExternalIdentifier = fundDraft.ExternalIdentifier;
                fund.AcquisitionMethodId = fundDraft.AcquisitionMethodId;
                //fund.AcquisitionMethodCodes = fundDraft.AcquisitionMethodCodes;
                fund.FileTypeCodes = fundDraft.FileTypeCodes;
                fund.IndustryTypeCodes = fundDraft.IndustryTypeCodes;
                fund.LanguageCodes = fundDraft.LanguageCodes;

                //await ((IFundServiceBase)this).UpdateFundInternalAsync(fund);
                await ((IFundServiceBase)this).UpdateFundInternalAsync(fund, updatedBy, updatedOn);
            }
            else
            {
                fund = new FundModel()
                {
                    SystemIdentifier = fundDraft.SystemIdentifier,
                    ArchiveId = fundDraft.ArchiveId,
                    NumberArray = fundDraft.NumberArray,
                    NumberNumeric = fundDraft.NumberNumeric,
                    Number = fundDraft.Number,
                    Title = fundDraft.Title,
                    DescriptionLevelCode = fundDraft.DescriptionLevelCode,
                    TypeCode = fundDraft.TypeCode,
                    StatusCode = fundDraft.StatusCode,
                    HasNoChronologicalScope = fundDraft.HasNoChronologicalScope,
                    StartDateYear = fundDraft.StartDateYear,
                    StartDateMonth = fundDraft.StartDateMonth,
                    StartDateDay = fundDraft.StartDateDay,
                    EndDateYear = fundDraft.EndDateYear,
                    EndDateMonth = fundDraft.EndDateMonth,
                    EndDateDay = fundDraft.EndDateDay,
                    ApproxmateChronologicalScope = fundDraft.ApproxmateChronologicalScope,
                    Bytes = fundDraft.Bytes,
                    LinearMeters = fundDraft.LinearMeters,
                    OtherMetrics = fundDraft.OtherMetrics,
                    InventoryCount = fundDraft.InventoryCount,
                    ArchivalEntityCount = fundDraft.ArchivalEntityCount,
                    DocumentCount = fundDraft.DocumentCount,
                    FundCreatorTitleHistory = fundDraft.FundCreatorTitleHistory,
                    FundCreatorActivityHistory = fundDraft.FundCreatorActivityHistory,
                    FundCreatorBiographicalHistory = fundDraft.FundCreatorBiographicalHistory,
                    DocumentsProvider = fundDraft.DocumentsProvider,
                    DocumentsDescription = fundDraft.DocumentsDescription,
                    ValuableDocumentsInventoryCount = fundDraft.ValuableDocumentsInventoryCount,
                    InvaluableDocumentsInventoryCount = fundDraft.InvaluableDocumentsInventoryCount,
                    DocumentsAccessDescription = fundDraft.DocumentsAccessDescription,
                    History = fundDraft.History,
                    RelatedFunds = fundDraft.RelatedFunds,
                    Notes = fundDraft.Notes,
                    EnrolledBytes = fundDraft.EnrolledBytes,
                    EnrolledInventoryCount = fundDraft.EnrolledInventoryCount,
                    DeductedBytes = fundDraft.DeductedBytes,
                    DeductedInventoryCount = fundDraft.DeductedInventoryCount,
                    HasExternalSource = fundDraft.HasExternalSource,
                    ExternalIdentifier = fundDraft.ExternalIdentifier,
                    AcquisitionMethodId = fundDraft.AcquisitionMethodId,
                    //AcquisitionMethodCodes = fundDraft.AcquisitionMethodCodes,
                    FileTypeCodes = fundDraft.FileTypeCodes,
                    IndustryTypeCodes = fundDraft.IndustryTypeCodes,
                    LanguageCodes = fundDraft.LanguageCodes,
                };

                //await ((IFundServiceBase)this).CreateFundInternalAsync(fund);
                await ((IFundServiceBase)this).CreateFundInternalAsync(fund, createdBy, createdOn);
            }

            var modifiedFundDraft = new FundDraftModel()
            {
                Id = fundDraft.Id,
                IsCurrent = false,
                ReadOnly = true,
                SystemIdentifier = fundDraft.SystemIdentifier,
                ArchiveId = fundDraft.ArchiveId,
                NumberArray = fundDraft.NumberArray,
                NumberNumeric = fundDraft.NumberNumeric,
                Number = fundDraft.Number,
                Title = fundDraft.Title,
                DescriptionLevelCode = fundDraft.DescriptionLevelCode,
                TypeCode = fundDraft.TypeCode,
                StatusCode = fundDraft.StatusCode,
                AcquisitionMethodId = fundDraft.AcquisitionMethodId,
                //AcquisitionMethodCodes = fundDraft.AcquisitionMethodCodes,
                FileTypeCodes = fundDraft.FileTypeCodes,
                IndustryTypeCodes = fundDraft.IndustryTypeCodes,
                LanguageCodes = fundDraft.LanguageCodes,
                HasNoChronologicalScope = fundDraft.HasNoChronologicalScope,
                StartDateYear = fundDraft.StartDateYear,
                StartDateMonth = fundDraft.StartDateMonth,
                StartDateDay = fundDraft.StartDateDay,
                EndDateYear = fundDraft.EndDateYear,
                EndDateMonth = fundDraft.EndDateMonth,
                EndDateDay = fundDraft.EndDateDay,
                ApproxmateChronologicalScope = fundDraft.ApproxmateChronologicalScope,
                Bytes = fundDraft.Bytes,
                LinearMeters = fundDraft.LinearMeters,
                OtherMetrics = fundDraft.OtherMetrics,
                InventoryCount = fundDraft.InventoryCount,
                ArchivalEntityCount = fundDraft.ArchivalEntityCount,
                DocumentCount = fundDraft.DocumentCount,
                FundCreatorTitleHistory = fundDraft.FundCreatorTitleHistory,
                FundCreatorActivityHistory = fundDraft.FundCreatorActivityHistory,
                FundCreatorBiographicalHistory = fundDraft.FundCreatorBiographicalHistory,
                DocumentsProvider = fundDraft.DocumentsProvider,
                DocumentsDescription = fundDraft.DocumentsDescription,
                ValuableDocumentsInventoryCount = fundDraft.ValuableDocumentsInventoryCount,
                InvaluableDocumentsInventoryCount = fundDraft.InvaluableDocumentsInventoryCount,
                DocumentsAccessDescription = fundDraft.DocumentsAccessDescription,
                History = fundDraft.History,
                RelatedFunds = fundDraft.RelatedFunds,
                Notes = fundDraft.Notes,
                EnrolledBytes = fundDraft.EnrolledBytes,
                EnrolledInventoryCount = fundDraft.EnrolledInventoryCount,
                DeductedBytes = fundDraft.DeductedBytes,
                DeductedInventoryCount = fundDraft.DeductedInventoryCount,
                HasExternalSource = fundDraft.HasExternalSource,
                ExternalIdentifier = fundDraft.ExternalIdentifier,
            };

            await ((IFundServiceBase)this).UpdateDraftInternalAsync(modifiedFundDraft);

            return sysId;
        }

        public async Task<OperationResult> CreateOrUpdateFundFromDraftAsync(Guid sysId)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await ((IFundServiceBase)this).CreateOrUpdateFundFromDraftInternalAsync(sysId);

                transaction.Commit();
                return OperationResult.Succeed(sysId);
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

        async Task<Guid> IFundServiceBase.UpdateDraftInternalAsync(FundDraftModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            if (!model.SystemIdentifier.HasValue)
            {
                throw new SystemIdentifierNullException(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            var currentFundDraft = await GetCurrentDraftAsync(model.SystemIdentifier!.Value);
            if (currentFundDraft == null)
            {
                return await ((IFundServiceBase)this).CreateDraftInternalAsync(model);
            }

            bool isReadOnly = await IsReadOnlyDraftAsync(new FundDraftModel() { Id = currentFundDraft.Id });
            if (isReadOnly)
            {
                return await ((IFundServiceBase)this).CreateDraftInternalAsync(model);
            }

            //var fundDraft = await _context.FundDrafts.FindAsync(model.Id);
            var fundDraft = await _context.FundDrafts.FindAsync(currentFundDraft.Id);
            if (fundDraft == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), model.Id?.ToString()!);
            }

            fundDraft.IsCurrent = model.IsCurrent;
            fundDraft.ReadOnly = model.ReadOnly;
            fundDraft.SystemIdentifier = model.SystemIdentifier.Value;
            fundDraft.ArchiveId = model.ArchiveId!.Value;
            fundDraft.WorkflowId = model.WorkflowId;
            fundDraft.WorkflowTypeCode = model.WorkflowTypeCode;
            fundDraft.WorkflowStepId = model.WorkflowStepId;
            fundDraft.WorkflowStepTypeCode = model.WorkflowStepTypeCode;
            fundDraft.NumberArray = model.NumberArray;
            fundDraft.NumberNumeric = model.NumberNumeric;
            fundDraft.Number = model.Number;
            fundDraft.Title = model.Title;
            fundDraft.DescriptionLevelCode = model.DescriptionLevelCode;
            fundDraft.TypeCode = model.TypeCode;
            fundDraft.StatusCode = model.StatusCode;
            fundDraft.AcquisitionMethodId = model.AcquisitionMethodId;
            fundDraft.HasNoChronologicalScope = model.HasNoChronologicalScope;
            fundDraft.StartDateYear = model.StartDateYear;
            fundDraft.StartDateMonth = model.StartDateMonth;
            fundDraft.StartDateDay = model.StartDateDay;
            fundDraft.EndDateYear = model.EndDateYear;
            fundDraft.EndDateMonth = model.EndDateMonth;
            fundDraft.EndDateDay = model.EndDateDay;
            fundDraft.ApproxmateChronologicalScope = model.ApproxmateChronologicalScope;
            fundDraft.Bytes = model.Bytes;
            fundDraft.LinearMeters = model.LinearMeters;
            fundDraft.OtherMetrics = model.OtherMetrics;
            fundDraft.InventoryCount = model.InventoryCount;
            fundDraft.ArchivalEntityCount = model.ArchivalEntityCount;
            fundDraft.DocumentCount = model.DocumentCount;
            fundDraft.FundCreatorTitleHistory = model.FundCreatorTitleHistory;
            fundDraft.FundCreatorActivityHistory = model.FundCreatorActivityHistory;
            fundDraft.FundCreatorBiographicalHistory = model.FundCreatorBiographicalHistory;
            fundDraft.DocumentsProvider = model.DocumentsProvider;
            fundDraft.DocumentsDescription = model.DocumentsDescription;
            fundDraft.ValuableDocumentsInventoryCount = model.ValuableDocumentsInventoryCount;
            fundDraft.InvaluableDocumentsInventoryCount = model.InvaluableDocumentsInventoryCount;
            fundDraft.DocumentsAccessDescription = model.DocumentsAccessDescription;
            fundDraft.History = model.History;
            fundDraft.RelatedFunds = model.RelatedFunds;
            fundDraft.Notes = model.Notes;
            fundDraft.EnrolledBytes = model.EnrolledBytes;
            fundDraft.EnrolledInventoryCount = model.EnrolledInventoryCount;
            fundDraft.DeductedBytes = model.DeductedBytes;
            fundDraft.DeductedInventoryCount = model.DeductedInventoryCount;
            fundDraft.HasExternalSource = model.HasExternalSource;
            fundDraft.ExternalIdentifier = model.ExternalIdentifier;

            _context.Update(fundDraft);

            var fundNomenclatureValues = _nomenclatureService.GetEntityNomenclatureValues(
                fundDraft.Id, BusinessObjectType.Fund, true, null);
                       

            //Update industry type values
            if (model.IndustryTypeCodes?.Count() > 0)
            {
                var industryTypeValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.IndustryTypeCodes, fundNomenclatureValues, Shared.NomenclatureCode.IndustryType,
                    fundDraft.Id, BusinessObjectType.Fund, true);

                if (industryTypeValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(industryTypeValuesToAdd);
                }
            }

            var industryTypeValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.IndustryTypeCodes, fundNomenclatureValues, Shared.NomenclatureCode.IndustryType);

            if(industryTypeValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(industryTypeValuesToDelete);
            }

            //Update file type values
            if (model.FileTypeCodes?.Count() > 0)
            {
                var fileTypeValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.FileTypeCodes, fundNomenclatureValues, Shared.NomenclatureCode.FileType,
                    fundDraft.Id, BusinessObjectType.Fund, true);

                if (fileTypeValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(fileTypeValuesToAdd);
                }
            }

            var fileTypeValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.FileTypeCodes, fundNomenclatureValues, Shared.NomenclatureCode.FileType);
            
            if(fileTypeValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(fileTypeValuesToDelete);
            }

            //Update language values
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, fundNomenclatureValues, Shared.NomenclatureCode.Language,
                    fundDraft.Id, BusinessObjectType.Fund, true);

                if (languageValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(languageValuesToAdd);
                }
            }

            var languageValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.LanguageCodes, fundNomenclatureValues, Shared.NomenclatureCode.Language);

            if(languageValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(languageValuesToDelete);
            }


            await _context.SaveAsync("Fund draft updated");

            return fundDraft.SystemIdentifier;
        }

        public async Task<OperationResult> UpdateDraftAsync(FundDraftModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            if (!model.SystemIdentifier.HasValue)
            {
                return OperationResult.Failed(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var fundDraftSysId = await ((IFundServiceBase)this).UpdateDraftInternalAsync(model);

                await transaction.CommitAsync();
                return OperationResult.Succeed(fundDraftSysId);
            }
            catch (ItemNotFoundException exc)
            {
                await transaction.RollbackAsync();
                return OperationResult.Failed(exc.ToString());
            }
            catch (Exception exc)
            {
                await transaction.RollbackAsync();
                return OperationResult.Failed(exc.ToString());
            }
        }

        async Task<Guid> IFundServiceBase.UpdateFundInternalAsync(FundModel model, Guid? updatedBy, DateTime? updatedOn)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            if (!model.SystemIdentifier.HasValue)
            {
                throw new SystemIdentifierNullException(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            var fund = await _context.Funds.FindAsync(model.Id);
            if (fund == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), model.Id?.ToString()!);
            }

            fund.ArchiveId = model.ArchiveId!.Value;
            fund.NumberArray = model.NumberArray;
            fund.NumberNumeric = model.NumberNumeric;
            fund.Number = model.Number;
            fund.Title = model.Title;
            fund.DescriptionLevelCode = model.DescriptionLevelCode;
            fund.TypeCode = model.TypeCode;
            fund.StatusCode = model.StatusCode;
            fund.AcquisitionMethodId = model.AcquisitionMethodId;
            fund.HasNoChronologicalScope = model.HasNoChronologicalScope;
            fund.StartDateYear = model.StartDateYear;
            fund.StartDateMonth = model.StartDateMonth;
            fund.StartDateDay = model.StartDateDay;
            fund.EndDateYear = model.EndDateYear;
            fund.EndDateMonth = model.EndDateMonth;
            fund.EndDateDay = model.EndDateDay;
            fund.ApproxmateChronologicalScope = model.ApproxmateChronologicalScope;
            fund.Bytes = model.Bytes;
            fund.LinearMeters = model.LinearMeters;
            fund.OtherMetrics = model.OtherMetrics;
            fund.InventoryCount = model.InventoryCount;
            fund.ArchivalEntityCount = model.ArchivalEntityCount;
            fund.DocumentCount = model.DocumentCount;
            fund.FundCreatorTitleHistory = model.FundCreatorTitleHistory;
            fund.FundCreatorActivityHistory = model.FundCreatorActivityHistory;
            fund.FundCreatorBiographicalHistory = model.FundCreatorBiographicalHistory;
            fund.DocumentsProvider = model.DocumentsProvider;
            fund.DocumentsDescription = model.DocumentsDescription;
            fund.ValuableDocumentsInventoryCount = model.ValuableDocumentsInventoryCount;
            fund.InvaluableDocumentsInventoryCount = model.InvaluableDocumentsInventoryCount;
            fund.DocumentsAccessDescription = model.DocumentsAccessDescription;
            fund.History = model.History;
            fund.RelatedFunds = model.RelatedFunds;
            fund.Notes = model.Notes;
            fund.EnrolledBytes = model.EnrolledBytes;
            fund.EnrolledInventoryCount = model.EnrolledInventoryCount;
            fund.DeductedBytes = model.DeductedBytes;
            fund.DeductedInventoryCount = model.DeductedInventoryCount;
            fund.HasExternalSource = model.HasExternalSource;
            fund.ExternalIdentifier = model.ExternalIdentifier;

            if (model.HasExternalSource)
                fund.ExternalSourceUpdatedOn = DateTime.UtcNow;

            bool overwriteModified = updatedBy.HasValue && updatedOn.HasValue;
            if (overwriteModified)
            {
                fund.UpdatedBy = updatedBy;
                fund.UpdatedOn = updatedOn;
            }

            _context.Update(fund);

            var fundNomenclatureValues = _nomenclatureService.GetEntityNomenclatureValues(
                fund.Id, BusinessObjectType.Fund, false, null);


            //Update industry type values
            if (model.IndustryTypeCodes?.Count() > 0)
            {
                var industryTypeValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.IndustryTypeCodes, fundNomenclatureValues, Shared.NomenclatureCode.IndustryType,
                    fund.Id, BusinessObjectType.Fund, false, overwriteModified, updatedBy, updatedOn);

                if (industryTypeValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(industryTypeValuesToAdd);
                }
            }

            var industryTypeValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.IndustryTypeCodes, fundNomenclatureValues, Shared.NomenclatureCode.IndustryType);

            if(industryTypeValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(industryTypeValuesToDelete);
            }

            //Update file type values
            if (model.FileTypeCodes?.Count() > 0)
            {
                var fileTypeValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.FileTypeCodes, fundNomenclatureValues, Shared.NomenclatureCode.FileType,
                    fund.Id, BusinessObjectType.Fund, false, overwriteModified, updatedBy, updatedOn);

                if (fileTypeValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(fileTypeValuesToAdd);
                }
            }

            var fileTypeValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.FileTypeCodes, fundNomenclatureValues, Shared.NomenclatureCode.FileType);
                
            if(fileTypeValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(fileTypeValuesToDelete);
            }

            //Update language values
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, fundNomenclatureValues, Shared.NomenclatureCode.Language,
                    fund.Id, BusinessObjectType.Fund, false, overwriteModified, updatedBy, updatedOn);

                if (languageValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(languageValuesToAdd);
                }
            }

            var languageValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.LanguageCodes, fundNomenclatureValues, Shared.NomenclatureCode.Language);

            if(languageValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(languageValuesToDelete);
            }

            await _context.SaveAsync("Fund updated", overwriteModified, overwriteModified);

            return fund.SystemIdentifier;
        }

        public async Task<OperationResult> UpdateFundAsync(FundModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            if (!model.SystemIdentifier.HasValue)
            {
                return OperationResult.Failed(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var fundSysId = await ((IFundServiceBase)this).UpdateFundInternalAsync(model);

                transaction.Commit();

                return OperationResult.Succeed(fundSysId);
            }
            catch (ItemNotFoundException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(false, exc.ToString());
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        async System.Threading.Tasks.Task IFundServiceBase.DeleteDraftInternalAsync(int id)
        {
            //TODO: Да се добави изтриването на всички нива под фонда?
            var fundDraft = await _context.FundDrafts.FindAsync(id);
            if (fundDraft == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), id.ToString());
            }
            if (!fundDraft.IsCurrent)
            {
                throw new ItemDraftNotCurrentException(_localizer.GetString("Error_DraftNotCurrent").ToString(), id.ToString());
            }

            fundDraft.IsCurrent = false;
            fundDraft.ReadOnly = true;
            fundDraft.Deleted = true;
            fundDraft.DeletedOn = DateTime.UtcNow;
            fundDraft.DeletedBy = _userInfo.CurrentUserId;

            _context.Update(fundDraft);

            var draftNomValues = _nomenclatureService.GetEntityNomenclatureValues(fundDraft.Id, BusinessObjectType.Fund, true, null);
            if (draftNomValues != null && draftNomValues.Count() > 0)
            {
                draftNomValues.ToList().ForEach(nv =>
                {
                    nv.Deleted = true;
                    nv.DeletedBy = _userInfo.CurrentUserId;
                    nv.DeletedOn = DateTime.UtcNow;
                });

                _context.NomenclatureValues.UpdateRange(draftNomValues);
            }
            
            await _context.SaveAsync("Fund draft deleted");
        }

        public async Task<OperationResult> DeleteDraftAsync(int id)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await ((IFundServiceBase)this).DeleteDraftInternalAsync(id);

                transaction.Commit();
                return OperationResult.Success;
            }
            catch (ItemNotFoundException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(false, exc.ToString());
            }
            catch (ItemDraftNotCurrentException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(false, exc.ToString());
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        async System.Threading.Tasks.Task IFundServiceBase.DeleteFundInternalAsync(Guid sysId)
        {
            //TODO: Да се добави изтриването на всички нива под фонда?
            var fundDrafts =
                _context.FundDrafts
                .Where(f => f.SystemIdentifier == sysId && !f.Deleted)
                .Select(f => f);

            await fundDrafts.ForEachAsync(f =>
            {
                f.IsCurrent = false;
                f.ReadOnly = true;
                f.Deleted = true;
                f.DeletedBy = _userInfo.CurrentUserId;
                f.DeletedOn = DateTime.UtcNow;
                f.StatusCode = "4";
            });

            var draftNomValues = _nomenclatureService.GetEntityNomenclatureValues(fundDrafts.Select(f => f.Id).ToList(), BusinessObjectType.Fund, true, null);
            if (draftNomValues != null && draftNomValues.Count() > 0)
            {
                draftNomValues.ToList().ForEach(nv =>
                {
                    nv.Deleted = true;
                    nv.DeletedBy = _userInfo.CurrentUserId;
                    nv.DeletedOn = DateTime.UtcNow;
                });

                _context.NomenclatureValues.UpdateRange(draftNomValues);
            }

            var fund =
                await _context.Funds
                .Where(f => f.SystemIdentifier == sysId && !f.Deleted)
                .SingleOrDefaultAsync();
            if (fund == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            fund.Deleted = true;
            fund.DeletedOn = DateTime.UtcNow;
            fund.DeletedBy = _userInfo.CurrentUserId;
            fund.StatusCode = "4";

            _context.Update(fund);

            var entityNomValues = _nomenclatureService.GetEntityNomenclatureValues(fund.Id, BusinessObjectType.Fund, false, null);
            if (entityNomValues != null && entityNomValues.Count() > 0)
            {
                entityNomValues.ToList().ForEach(nv =>
                {
                    nv.Deleted = true;
                    nv.DeletedBy = _userInfo.CurrentUserId;
                    nv.DeletedOn = DateTime.UtcNow;
                });

                _context.NomenclatureValues.UpdateRange(entityNomValues);
            }

            await _context.SaveAsync("Fund deleted");
        }

        public async Task<OperationResult> DeleteFundAsync(Guid sysId)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await ((IFundServiceBase)this).DeleteFundInternalAsync(sysId);

                transaction.Commit();
                return OperationResult.Success;
            }
            catch (ItemNotFoundException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(false, exc.ToString());
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<FundDisplayModel?> GetFromExternalSourceAsync(int externalIdentifier, Guid? systemIdentifier = null)
        {
            string query = "exec sp_GetFund @LinkedServer, @Identifier";
            List<SqlParameter> queryParams = new List<SqlParameter>()
            {
                new SqlParameter("LinkedServer", _settings.LinkedServer),
                new SqlParameter("Identifier", externalIdentifier),
            };
            var result =
                (await _context.RemoteFunds
                        .FromSqlRaw(query, queryParams.ToArray())
                        .AsNoTracking()
                        .ToListAsync())
                    .SingleOrDefault();

            if (result == null)
            {
                return null;
            }

            var archiveId = await _archiveService.GetArchiveIdByCodeAsync(result.ArchiveCode!.Value);
            if (!systemIdentifier.HasValue)
            {
                systemIdentifier = await GetSystemIdentifierByExternalIdentifierAsync(externalIdentifier);
            }

            FundDisplayModel model = new FundDisplayModel()
            {
                Id = result.Id,
                SystemIdentifier = systemIdentifier,
                IsDraft = false,
                ArchiveId = archiveId,
                ArchiveCode = result.ArchiveCode,
                ArchiveName = result.ArchiveName,
                NumberArray = result.NumberArray,
                NumberNumeric = result.NumberNumeric,
                Number = result.Number,
                Title = result.Title!,
                TypeText = result.TypeText,
                StatusCode = result.StatusCode!,
                StatusText = result.StatusText,
                DescriptionLevelCode =
                    !string.IsNullOrEmpty(result.DescriptionLevelCode)
                    ? DescriptionLevelMapping.FundDescriptionLevel.GetValueOrDefault(result.DescriptionLevelCode)!
                    : string.Empty,
                DescriptionLevelText = result.DescriptionLevelText,
                AcquisitionMethodText = result.AcquisitionMethodText,
                IndustryTypeText = result.IndustryTypeText,
                LanguageText = result.LanguageText,
                ApproxmateChronologicalScope = result.ApproxmateChronologicalScope,
                HasNoChronologicalScope = result.HasNoChronologicalScope ?? false,
                StartDateDay = result.StartDateDay,
                StartDateMonth = result.StartDateMonth,
                StartDateYear = result.StartDateYear,
                EndDateDay = result.EndDateDay,
                EndDateMonth = result.EndDateMonth,
                EndDateYear = result.EndDateYear,
                FundCreatorActivityHistory = result.FundCreatorActivityHistory,
                FundCreatorBiographicalHistory = result.FundCreatorBiographicalHistory,
                FundCreatorTitleHistory = result.FundCreatorTitleHistory,
                History = result.History,
                DocumentsAccessDescription = result.DocumentsAccessDescription,
                DocumentsDescription = result.DocumentsDescription,
                DocumentsProvider = result.DocumentsProvider,
                LinearMeters = result.LinearMeters,
                OtherMetrics = result.OtherMetrics,
                RelatedFunds = result.RelatedFunds,
                Notes = result.Notes,
                InventoryCount = result.InventoryCount,
                ArchivalEntityCount = result.ArchivalEntityCount,
                DeductedInventoryCount = result.DeductedInventoryCount,
                EnrolledInventoryCount = result.EnrolledInventoryCount,
                HasExternalSource = result.HasExternalSource,
                ExternalIdentifier = result.ExternalIdentifier,
                CreatedOn = result.CreatedOn,
                CreatedByDisplayName = result.CreatedByDisplayName,
            };


            if (systemIdentifier != null)
            {
                var sizeInfo = await _context.VFundSizeInfos
                   .Where(x => x.FundSystemIdentifier == systemIdentifier && x.IsDraft == 0)
                   .SingleOrDefaultAsync();
                if (sizeInfo != null)
                {
                    model.InventoryCount = model.InventoryCount.HasValue ? model.InventoryCount.Value + sizeInfo.EnrolledInventoryCount : sizeInfo.EnrolledInventoryCount;
                    model.EnrolledInventoryCount = model.EnrolledInventoryCount.HasValue ? model.EnrolledInventoryCount.Value + sizeInfo.EnrolledInventoryCount : sizeInfo.EnrolledInventoryCount;
                    model.DeductedInventoryCount = model.DeductedInventoryCount.HasValue ? model.DeductedInventoryCount.Value + sizeInfo.DeductedInventoryCount : sizeInfo.DeductedInventoryCount;
                    model.ArchivalEntityCount = model.ArchivalEntityCount.HasValue ? model.ArchivalEntityCount.Value + sizeInfo.EnrolledArchivalEntityCount : sizeInfo.EnrolledArchivalEntityCount;
                    model.DocumentCount = sizeInfo.EnrolledDocumentCount;
                    model.Bytes = sizeInfo.EnrolledBytes;
                    model.EnrolledBytes = sizeInfo.EnrolledBytes;
                    model.DeductedBytes = sizeInfo.DeductedBytes;
                    string fileTypes = sizeInfo.FileTypes != null
                        ? String.Join(
                            System.Globalization.CultureInfo.CurrentCulture.TextInfo.ListSeparator + " ",
                            sizeInfo.FileTypes.Split("; ").Distinct()).ToUpper()
                        : String.Empty;
                    model.FileTypeText = fileTypes;
                }
            }

            return model;
        }

        public async Task<int?> GetArchiveIdAsync(Guid sysId)
        {
            var entity =
                await _context.VFunds
                .Where(x => x.SystemIdentifier == sysId && !x.Deleted)
                .SingleOrDefaultAsync();

            return entity?.ArchiveId;
        }

        public async Task<int?> GetArchiveIdByProcessIdAsync(int processId)
        {
            //TODO МОже да се направи с една заявка
            var process = await _context.Processes.FindAsync(processId);
            if (process != null)
            {
                var entity = await _context.VFunds
                    .Where(x => x.SystemIdentifier == process.FundSystemIdentifier && !x.Deleted)
                    .SingleOrDefaultAsync();

                return entity?.ArchiveId;
            }

            return null;
        }

        public async Task<int?> GetDescriptionLevelAsync(Guid sysId)
        {
            var fund = await GetFundBySystemIdentifierAsync(sysId);
            if (fund == null)
            {
                return null;
            }

            if (!int.TryParse(fund.DescriptionLevelCode, out var fundDescriptionLevel))
            {
                _logger.LogError($"Error parsing description level code for fund with sysId {sysId}");
                throw new InvalidDataException(nameof(fund.DescriptionLevelCode));
            }
            return fundDescriptionLevel;
        }

        public async Task<List<VInventory>> GetFundUnprocessedRawInventoriesAsync(Guid sysId)
        {
            var inventories =
                await _context.VInventories
                .Where(x => x.FundSystemIdentifier == sysId && !x.Deleted
                    && x.DescriptionLevelCode == ((int)Shared.InventoryDescriptionLevel.RawInventory).ToString()
                    && (x.StatusCode == Shared.Status.New || x.StatusCode == Shared.Status.Registered))
                .ToListAsync();

            var inventoriesIds = inventories.Select(x => x.SystemIdentifier).ToList();

            var processed = await _context.InventoryRawToNormals
                .Where(x => inventoriesIds.Contains(x.RawInventorySystemIdentifier)
                    && x.NormalInventorySystemIdentifier != null
                    && !x.IsRejected)
                .Select(x => x.RawInventorySystemIdentifier)
                .ToListAsync();

            if (processed != null && processed.Count > 0)
            {
                inventories = inventories.Where(x => !processed.Contains(x.SystemIdentifier)).ToList();
            }

            return inventories;
        }

        public async Task<DataSourceResponseModel<PublicUserReviewDisplayModel>> GetFundPublicUsersReviewsAsync(Guid? systemIdentifier)
        {
            int totalCount = 0;
            IEnumerable<PublicUserReviewDisplayModel> items = Enumerable.Empty<PublicUserReviewDisplayModel>();
            List<object> errors = new List<object>();

            if (systemIdentifier.HasValue)
            {
                var publicUserReviews =
                    _context.UserReviews
                    .Where(r => r.FundSystemIdentifier == systemIdentifier.Value && r.User.UserType == ApplicationUserType.External)
                    .Select(r => new PublicUserReviewDisplayModel
                    {
                        UserDisplayName = _context.AspNetUserProfiles
                                                  .Where(u => u.UserId == r.UserId && !u.Deleted)
                                                  .Select(u => u.DisplayName)
                                                  .SingleOrDefault(),
                        UserProfileType = _context.AspNetUserProfiles
                                                  .Where(u => u.UserId == r.UserId && !u.Deleted)
                                                  .Select(u => u.ProfileType)
                                                  .SingleOrDefault(),
                        Date = r.Date.UtcToLocalTime()
                    });


                totalCount = await publicUserReviews.CountAsync();
                items = await publicUserReviews.ToListAsync();
            }
            //}

            DataSourceResponseModel<PublicUserReviewDisplayModel> result = new DataSourceResponseModel<PublicUserReviewDisplayModel>()
            {
                TotalCount = totalCount,
                Errors = errors.Count > 0 ? errors : null,
                Items = items
            };

            return result;
        }


        //async System.Threading.Tasks.Task IFundServiceBase.CalculateDocFieldsInternalAsync(Guid? inventorySysId)
        //{
        //    Guid? fundSysId = await _context.InventoryDrafts
        //        .Where(inv => inv.SystemIdentifier == inventorySysId && inv.IsCurrent && !inv.Deleted)
        //        .Select(inv => inv.FundSystemIdentifier)
        //        .SingleOrDefaultAsync();

        //    if (fundSysId == null || fundSysId == Guid.Empty)
        //    {
        //        fundSysId = await _context.Inventories
        //            .Where(inv => inv.SystemIdentifier == inventorySysId && !inv.Deleted)
        //            .Select(inv => inv.FundSystemIdentifier)
        //            .SingleOrDefaultAsync();
        //    }

        //    var fund = await _context.Funds
        //        .Where(x => x.SystemIdentifier == fundSysId && !x.Deleted)
        //        .FirstOrDefaultAsync();

        //    if (fund == null)
        //    {
        //        return;
        //        //throw new CustomException(_localizer.GetString("Error_ItemDoesNotExists").ToString());
        //    }

        //    var docs = await _context.PackageDocuments
        //        .Where(x => x.Package.InventoryPackageBs.Where(i => i.SystemIdentifier == inventorySysId).Any() && !x.Deleted)
        //        .ToListAsync();


        //    // find formats in nomenclature
        //    var fileTypes = _nomenclatureService.GetNomenclatureValues(Shared.NomenclatureCode.FileType);
        //    List<string> formats = docs.Select(x => x.FileType).Distinct().ToList();
        //    List<NomenclatureValueDisplayModel> usedFiles = new List<NomenclatureValueDisplayModel>();

        //    foreach (var format in formats)
        //    {
        //        var usedFile = fileTypes.Where(nv => nv.Text.ToLower() == format.ToLower()).FirstOrDefault();
        //        if (usedFile == null)
        //        {
        //            throw new CustomException(_localizer.GetString("Error_MissingFileType", format).ToString());
        //        }

        //        usedFiles.Add(usedFile);
        //    }

        //    long? totalBytes = docs.Sum(x => x.FileSizeInBytes);

        //    // update fund
        //    fund.Bytes = totalBytes;
        //    fund.DocumentCount = docs.Count;
        //    _context.Funds.Update(fund);

        //    var fundFileTypes = await _context.NomenclatureValues
        //        .Where(nv => nv.EntityId == fund.Id
        //                && nv.EntityType == BusinessObjectType.Fund
        //                && !nv.EntityIsDraft
        //                && nv.NomenclatureCode == Shared.NomenclatureCode.FileType)
        //        .Select(x => x.ValueCode.ToLower())
        //        .ToListAsync();

        //    var fundFileTypeValuesToAdd = usedFiles
        //        .Where(x => !fundFileTypes.Contains(x.Code.ToLower()))
        //        .ToList();

        //    var fundFileTypeValues = fundFileTypeValuesToAdd
        //        .Select(x => new NomenclatureValue()
        //        {
        //            EntityId = fund.Id,
        //            EntityType = BusinessObjectType.Fund,
        //            EntityIsDraft = false,
        //            NomenclatureCode = x.ParentCode!,
        //            NomenclatureId = x.ParentId!.Value,
        //            ValueCode = x.Code,
        //            ValueId = x.Id!.Value
        //        });

        //    if (fundFileTypeValues != null && fundFileTypeValues.Count() > 0)
        //    {
        //        _context.NomenclatureValues.AddRange(fundFileTypeValues!);
        //        await _context.SaveAsync($"Fund file types added");
        //    }
        //}

        public async Task<OperationResult?> CreateFundReviewAsync(Guid? fundSystemIdentifier, int? fundExternalIdentifier)
        {
            Guid systemIdentifier = Guid.NewGuid();

            UserReview employeeReview = new UserReview
            {
                SystemIdentifier = systemIdentifier,
                UserId = _userInfo.CurrentUserId.Value,
                Date = DateTime.UtcNow
            };

            if ((fundSystemIdentifier.HasValue && fundSystemIdentifier.Value != Guid.Empty) || fundExternalIdentifier.HasValue)
            {
                if (fundSystemIdentifier.HasValue && fundSystemIdentifier.Value != Guid.Empty)
                {
                    employeeReview.FundSystemIdentifier = fundSystemIdentifier.Value;
                }
                if (fundExternalIdentifier.HasValue)
                {
                    employeeReview.FundExternalIdentifier = fundExternalIdentifier;
                }
            }
            else
            {
                return OperationResult.Succeed("No review for missing fund system identifier");
            }

            await _context.UserReviews.AddAsync(employeeReview);
            await _context.SaveAsync("Employee review created");

            return OperationResult.Success;
        }
    }
}
