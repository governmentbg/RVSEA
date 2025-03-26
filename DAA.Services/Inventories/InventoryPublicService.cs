using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Models.Configuration;
using DAA.Models.Inventories;
using DAA.Services.Nomenclatures;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace DAA.Services.Inventories
{
    public class InventoryPublicService : BaseService, IInventoryPublicService
    {

        private readonly LinkedServerSettings _settings;
        private readonly IUserInfo _userInfo;
        private readonly INomenclatureService _nomenclatureService;

        public InventoryPublicService(ArchivingContext context,
            IOptions<LinkedServerSettings> settings,
            IUserInfo userInfo,
            INomenclatureService nomenclatureService,
            ILogger<IInventoryPublicService> logger,
            IStringLocalizer<SharedResources> localizer)
            : base(context, localizer, logger)
        {
            _settings = settings.Value;
            _userInfo = userInfo;
            _nomenclatureService = nomenclatureService;
        }

        public async Task<DataSourceResponseModel<InventoryPublicDisplayModel>> GetByFundIdentifier(DataSourceRequestModel model, Guid? fundSysId, bool fundHasExternalSource = false, int? fundExternalIdentifier = null)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            int totalCount = 0;
            IEnumerable<InventoryPublicDisplayModel> items = Enumerable.Empty<InventoryPublicDisplayModel>();
            List<object> errors = new();

            try
            {
                string countQuery = "exec @ReturnValue = sp_GetFundInventoriesCountPublic @LinkedServer, @FundIdentifier, @FundHasExternalSource, @FundExternalIdentifier";

                List<SqlParameter> countQueryParams = new()
                {
                    new SqlParameter("LinkedServer", _settings.LinkedServer),
                    new SqlParameter("FundIdentifier", fundSysId.HasValue ? fundSysId.Value : DBNull.Value),
                    new SqlParameter("FundHasExternalSource", fundHasExternalSource),
                    new SqlParameter("FundExternalIdentifier", fundExternalIdentifier.HasValue ? fundExternalIdentifier.Value : DBNull.Value),
                };

                SqlParameter countQueryReturnValue = new()
                {
                    ParameterName = "ReturnValue",
                    SqlDbType = System.Data.SqlDbType.Int,
                    Direction = System.Data.ParameterDirection.Output
                };
                countQueryParams.Add(countQueryReturnValue);
                await _context.Database.ExecuteSqlRawAsync(countQuery, countQueryParams.ToArray());

                totalCount = (int)countQueryReturnValue.Value;
            }
            catch (SqlException)
            {
                // най-вероятно случай с липса на връзка с ИСДА, затова не логвай грешка; за това ще се появи warning
            }
            catch (Exception exc)
            {
                errors.Add(exc.ToString());
            }

            try
            {
                string query = "exec sp_GetFundInventoriesPublic @LinkedServer, @FundIdentifier, @FundHasExternalSource, @FundExternalIdentifier, @Paging, @PageNumber, @PageSize";
                List<SqlParameter> queryParams = new()
                {
                    new SqlParameter("LinkedServer", _settings.LinkedServer),
                    new SqlParameter("FundIdentifier", fundSysId.HasValue ? fundSysId.Value : DBNull.Value),
                    new SqlParameter("FundHasExternalSource", fundHasExternalSource),
                    new SqlParameter("FundExternalIdentifier", fundExternalIdentifier.HasValue ? fundExternalIdentifier.Value : DBNull.Value),
                    new SqlParameter("Paging", true),
                    new SqlParameter("PageNumber", model.Page),
                    new SqlParameter("PageSize", model.ItemsPerPage),
                };
                var queryResult =
                    await _context.RemoteInventories
                            .FromSqlRaw(query, queryParams.ToArray())
                            .AsNoTracking()
                            .ToListAsync();

                items =
                    queryResult.Select(i => new InventoryPublicDisplayModel()
                    {
                        SystemIdentifier = i.SystemIdentifier,
                        HasExternalSource = i.HasExternalSource ?? false,
                        ExternalIdentifier = i.ExternalIdentifier,
                        ArchiveName = i.ArchiveName,
                        FundNumber = i.FundNumber,
                        Number = i.Number,
                        DescriptionLevelText = i.DescriptionLevelText,
                        AcquisitionMethodText = i.AcquisitionMethodText,
                        CreationMethodText = i.CreationMethodText,
                        OriginalityText = i.OriginalityText,
                        LanguageText = i.LanguageText,
                        ApproxmateChronologicalScope = i.ApproxmateChronologicalScope,
                        HasNoChronologicalScope = i.HasNoChronologicalScope,
                        StartDateDay = i.StartDateDay,
                        StartDateMonth = i.StartDateMonth,
                        StartDateYear = i.StartDateYear,
                        EndDateDay = i.EndDateDay,
                        EndDateMonth = i.EndDateMonth,
                        EndDateYear = i.EndDateYear,
                        FundCreatorBiographicalHistory = i.FundCreatorBiographicalHistory,
                        FundCreatorTitleHistory = i.FundCreatorTitleHistory,
                        History = i.History,
                        DocumentsAccessDescription = i.DocumentsAccessDescription,
                        DocumentsDescription = i.DocumentsDescription,
                        DocumentsProvider = i.DocumentsProvider,
                        LinearMeters = i.LinearMeters,
                        OtherMetrics = i.OtherMetrics,
                        Notes = i.Notes,
                        ArchivalEntityCount = i.ArchivalEntityCount,
                        BoxCount = i.BoxCount,
                        RollCount = i.RollCount,
                        AudioDocumentArchivalEntityCount = i.AudioDocumentArchivalEntityCount,
                        PhotoDocumentArchivalEntityCount = i.PhotoDocumentArchivalEntityCount,
                        VideoDocumentArchivalEntityCount = i.VideoDocumentArchivalEntityCount,
                        DigitalDocumentArchivalEntityCount = i.VideoDocumentArchivalEntityCount,
                        MicrofilmedArchivalEntityCount = i.MicrofilmedArchivalEntityCount,
                        DigitizedArchivalEntityCount = i.DigitizedArchivalEntityCount,
                        NegativeFrameCount = i.NegativeFrameCount,
                        PositiveFrameCount = i.PositiveFrameCount,
                    });
            }
            catch (SqlException)
            {
                // най-вероятно случай с липса на връзка с ИСДА, затова не логвай грешка; за това ще се появи warning
            }
            catch (Exception exc)
            {
                errors.Add(exc.ToString());
            }

            DataSourceResponseModel<InventoryPublicDisplayModel> result = new()
            {
                TotalCount = totalCount,
                Errors = errors.Count > 0 ? errors : null,
                Items = items
            };

            return result;
        }
        public async Task<InventoryPublicDisplayModel?> GetInventoryBySystemIdentifierAsync(Guid sysId)
        {
            var inventory =
                await _context.Inventories
                .Where(inv => inv.SystemIdentifier == sysId && !inv.Deleted && inv.StatusCode != "12")
                .Select(inv => new InventoryPublicDisplayModel()
                {
                    SystemIdentifier = inv.SystemIdentifier,
                    ArchiveName = inv.Archive.Name,
                    FundNumber = inv.FundSystemIdentifierNavigation.Number,
                    Number = inv.Number,
                    DescriptionLevelText = inv.DescriptionLevelCodeNavigation!.Text,
                    ApproxmateChronologicalScope = inv.ApproxmateChronologicalScope,
                    HasNoChronologicalScope = inv.HasNoChronologicalScope,
                    StartDateDay = inv.StartDateDay,
                    StartDateMonth = inv.StartDateMonth,
                    StartDateYear = inv.StartDateYear,
                    EndDateDay = inv.EndDateDay,
                    EndDateMonth = inv.EndDateMonth,
                    EndDateYear = inv.EndDateYear,
                    FundCreatorBiographicalHistory = inv.FundCreatorBiographicalHistory,
                    FundCreatorTitleHistory = inv.FundCreatorTitleHistory,
                    History = inv.History,
                    DocumentsAccessDescription = inv.DocumentsAccessDescription,
                    DocumentsDescription = inv.DocumentsDescription,
                    DocumentsProvider = inv.DocumentsProvider,
                    LinearMeters = inv.LinearMeters,
                    OtherMetrics = inv.OtherMetrics,
                    Notes = inv.Notes,
                    Bytes = inv.Bytes,
                    ArchivalEntityCount = inv.ArchivalEntityCount,
                    // DocumentCount = inv.DocumentCount,
                    DigitizedArchivalEntityCount = inv.DigitizedArchivalEntityCount,
                    AudioDocumentArchivalEntityCount = inv.AudioDocumentArchivalEntityCount,
                    DigitalDocumentArchivalEntityCount = inv.DigitalDocumentArchivalEntityCount,
                    MicrofilmedArchivalEntityCount = inv.MicrofilmedArchivalEntityCount,
                    PhotoDocumentArchivalEntityCount = inv.PhotoDocumentArchivalEntityCount,
                    VideoDocumentArchivalEntityCount = inv.VideoDocumentArchivalEntityCount,
                    NegativeFrameCount = inv.NegativeFrameCount,
                    PositiveFrameCount = inv.PositiveFrameCount,
                    BoxCount = inv.BoxCount,
                    RollCount = inv.RollCount,
                    FundSystemIdentifier = inv.FundSystemIdentifier,
                    HasExternalSource = inv.HasExternalSource,
                    ExternalIdentifier = inv.ExternalIdentifier,
                    AcquisitionMethodText = _nomenclatureService.GetEntityNomenclatureText(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.AcquisitionMethod),
                    FileTypeText = _nomenclatureService.GetEntityNomenclatureText(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.FileType),
                    CreationMethodText = _nomenclatureService.GetEntityNomenclatureText(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.CreationMethod),
                    OriginalityText = _nomenclatureService.GetEntityNomenclatureText(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.Originality),
                    LanguageText = _nomenclatureService.GetEntityNomenclatureText(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.Language),
                })
                .SingleOrDefaultAsync();

            if (inventory != null)
            {
                var sizeInfo = await _context.VInventorySizeInfos
                    .Where(x => x.InventorySystemIdentifier == sysId && x.IsDraft == 0)
                    .SingleOrDefaultAsync();
                if (sizeInfo != null)
                {
                    inventory.ArchivalEntityCount = sizeInfo.EnrolledArchivalEntityCount;
                    inventory.DigitalDocumentArchivalEntityCount = sizeInfo.EnrolledArchivalEntityCount;
                    inventory.DocumentCount = sizeInfo.EnrolledDocumentCount;
                    inventory.Bytes = sizeInfo.EnrolledBytes;
                    string fileTypes = sizeInfo.FileTypes != null
                        ? String.Join(
                            System.Globalization.CultureInfo.CurrentCulture.TextInfo.ListSeparator + " ",
                            sizeInfo.FileTypes.Split("; ").Distinct()).ToUpper()
                        : String.Empty;
                    inventory.FileTypeText = fileTypes;
                }
            }

            if (inventory != null && inventory.HasExternalSource && inventory.ExternalIdentifier.HasValue)
            {
                try
                {
                    inventory = await GetFromExternalSourceAsync(
                    inventory.ExternalIdentifier.Value,
                    inventory.SystemIdentifier,
                    inventory.FundSystemIdentifier);
                }
                catch (Exception)
                {
                    _logger.LogWarning("Error retrieving inventory data from ISDA");

                    inventory!.ResultMessage = Constants.ISDADataCannotBeDisplayedMessageKey; // тук, ако няма inventory, вече трябва да се хвърли грешка
                }
            }

            return inventory;
        }
        public async Task<InventoryPublicDisplayModel?> GetFromExternalSourceAsync(
          int externalIdentifier,
          Guid? systemIdentifier = null,
          Guid? fundSystemIdentifier = null)
        {
            string query = "exec sp_GetInventory @LinkedServer, @Identifier";
            List<SqlParameter> queryParams = new List<SqlParameter>()
            {
                new SqlParameter("LinkedServer", _settings.LinkedServer),
                new SqlParameter("Identifier", externalIdentifier),
            };
            var result =
                (await _context.RemoteInventories
                        .FromSqlRaw(query, queryParams.ToArray())
                        .AsNoTracking()
                        .ToListAsync())
                    .SingleOrDefault();

            if (result == null)
            {
                return null;
            }

            var archiveId = await _context.Archives
                .Where(a => a.Code == result.ArchiveCode!.Value)
                .Select(a => a.Id)
                .SingleOrDefaultAsync();

            if (!fundSystemIdentifier.HasValue)
            {
                fundSystemIdentifier = await _context.Funds
                .Where(f => f.ExternalIdentifier == result.FundExternalIdentifier!.Value)
                .Select(f => f.SystemIdentifier)
                .SingleOrDefaultAsync();
            }

            //TODO: Add DescriptionLevelCode!!!

            return new InventoryPublicDisplayModel()
            {
                SystemIdentifier = systemIdentifier,
                FundSystemIdentifier = fundSystemIdentifier,
                HasExternalSource = result.HasExternalSource ?? false,
                ExternalIdentifier = result.ExternalIdentifier,
                ArchiveName = result.ArchiveName,
                FundNumber = result.FundNumber,
                Number = result.Number,
                DescriptionLevelText = result.DescriptionLevelText,
                AcquisitionMethodText = result.AcquisitionMethodText,
                CreationMethodText = result.CreationMethodText,
                OriginalityText = result.OriginalityText,
                LanguageText = result.LanguageText,
                ApproxmateChronologicalScope = result.ApproxmateChronologicalScope,
                HasNoChronologicalScope = result.HasNoChronologicalScope,
                StartDateDay = result.StartDateDay,
                StartDateMonth = result.StartDateMonth,
                StartDateYear = result.StartDateYear,
                EndDateDay = result.EndDateDay,
                EndDateMonth = result.EndDateMonth,
                EndDateYear = result.EndDateYear,
                FundCreatorBiographicalHistory = result.FundCreatorBiographicalHistory,
                FundCreatorTitleHistory = result.FundCreatorTitleHistory,
                History = result.History,
                DocumentsAccessDescription = result.DocumentsAccessDescription,
                DocumentsDescription = result.DocumentsDescription,
                DocumentsProvider = result.DocumentsProvider,
                LinearMeters = result.LinearMeters,
                OtherMetrics = result.OtherMetrics,
                Notes = result.Notes,
                ArchivalEntityCount = result.ArchivalEntityCount,
                BoxCount = result.BoxCount,
                FundExternalIdentifier = result.FundExternalIdentifier,
                FundHasExternalSource = result.FundHasExternalSource,
                RollCount = result.RollCount,
                AudioDocumentArchivalEntityCount = result.AudioDocumentArchivalEntityCount,
                PhotoDocumentArchivalEntityCount = result.PhotoDocumentArchivalEntityCount,
                VideoDocumentArchivalEntityCount = result.VideoDocumentArchivalEntityCount,
                DigitalDocumentArchivalEntityCount = result.VideoDocumentArchivalEntityCount,
                MicrofilmedArchivalEntityCount = result.MicrofilmedArchivalEntityCount,
                DigitizedArchivalEntityCount = result.DigitizedArchivalEntityCount,
                NegativeFrameCount = result.NegativeFrameCount,
                PositiveFrameCount = result.PositiveFrameCount,
            };
        }

        public async Task<OperationResult?> CreateInventoryReviewAsync(Guid? inventorySystemIdentifier, int? inventoryExternalIdentifier)
        {
            if (!_userInfo.CurrentUserId.HasValue || _userInfo.CurrentUserId.Value == Guid.Empty)
            {
                return OperationResult.Success;
            }

            Guid systemIdentifier = Guid.NewGuid();

            UserReview publicUserReview = new UserReview()
            {
                SystemIdentifier = systemIdentifier,
                UserId = _userInfo.CurrentUserId.Value,
                Date = DateTime.UtcNow
            };

            if ((inventorySystemIdentifier.HasValue && inventorySystemIdentifier.Value != Guid.Empty) || inventoryExternalIdentifier.HasValue)
            {
                if (inventorySystemIdentifier.HasValue && inventorySystemIdentifier.Value != Guid.Empty)
                {
                    publicUserReview.InventorySystemIdentifier = inventorySystemIdentifier.Value;
                }
                if (inventoryExternalIdentifier.HasValue)
                {
                    publicUserReview.InventoryExternalIdentifier = inventoryExternalIdentifier;
                }
            }
            else
            {
                return OperationResult.Succeed("No review for missing inventory system identifier");
            }

            await _context.UserReviews.AddAsync(publicUserReview);
            await _context.SaveAsync("Public user review created");

            return OperationResult.Success;
        }


        public async Task<InventoryPublicImportModel?> GetInventoryDraftBySysIdAsync(Guid sysId)
        {
            var inventory =
                await _context.InventoryDrafts
                .Where(inv => inv.SystemIdentifier == sysId && !inv.Deleted && inv.IsCurrent)
                .Select(inv => new InventoryPublicImportModel()
                {
                    SystemIdentifier = inv.SystemIdentifier,
                    AcquisitionMethodId = inv.AcquisitionMethodId,
                    StartDateDay = inv.StartDateDay,
                    StartDateMonth = inv.StartDateMonth,
                    StartDateYear = inv.StartDateYear ?? 1900,
                    EndDateDay = inv.EndDateDay,
                    EndDateMonth = inv.EndDateMonth,
                    EndDateYear = inv.EndDateYear ?? 1900,
                    FundCreatorBiographicalHistory = inv.FundCreatorBiographicalHistory,
                    FundCreatorTitleHistory = inv.FundCreatorTitleHistory,
                    History = inv.History,
                    DocumentsAccessDescription = inv.DocumentsAccessDescription,
                    DocumentsDescription = inv.DocumentsDescription,
                    DocumentsProvider = inv.DocumentsProvider,
                    ClassificationScheme = inv.ClassificationScheme,
                    AbbreviationList = inv.AbbreviationList,
                    OtherMetrics = inv.OtherMetrics,
                    Notes = inv.Notes,
                    OtherLanguage= inv.OtherLanguage,
                })
                .SingleOrDefaultAsync();


            return inventory;
        }

        public async Task<OperationResult> UpdateDraftAsync(InventoryPublicImportModel model, Guid? userId)
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
                var inventorySysId = await UpdateDraftInternalAsync(model, userId);

                transaction.Commit();
                return OperationResult.Succeed(inventorySysId);
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

        private async Task<Guid> UpdateDraftInternalAsync(InventoryPublicImportModel model, Guid? userId)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            if (!model.SystemIdentifier.HasValue)
            {
                throw new SystemIdentifierNullException(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            var inventoryDraft = await _context.InventoryDrafts
                .Include(x => x.Application)
                .Where(x => x.SystemIdentifier == model.SystemIdentifier && x.IsCurrent && !x.ReadOnly)
                .FirstOrDefaultAsync();

            if (inventoryDraft == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), (model.SystemIdentifier ?? Guid.Empty).ToString("D"));
            }

            if (inventoryDraft.Application == null || inventoryDraft.Application.StatusId != (int)ApplicationStatus.ModificationRequest || inventoryDraft.Application.CreatedBy != userId)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ApplicationDataNotForEdit").ToString());
            }

            inventoryDraft.AcquisitionMethodId = model.AcquisitionMethodId;
            inventoryDraft.ApproxmateChronologicalScope = model.ApproxmateChronologicalScope;
            inventoryDraft.StartDateDay = model.StartDateDay;
            inventoryDraft.StartDateMonth = model.StartDateMonth;
            inventoryDraft.StartDateYear = model.StartDateYear;
            inventoryDraft.EndDateDay = model.EndDateDay;
            inventoryDraft.EndDateMonth = model.EndDateMonth;
            inventoryDraft.EndDateYear = model.EndDateYear;
            inventoryDraft.FundCreatorBiographicalHistory = model.FundCreatorBiographicalHistory;
            inventoryDraft.FundCreatorTitleHistory = model.FundCreatorTitleHistory;
            inventoryDraft.History = model.History;
            inventoryDraft.DocumentsAccessDescription = model.DocumentsAccessDescription;
            inventoryDraft.DocumentsDescription = model.DocumentsDescription;
            inventoryDraft.DocumentsProvider = model.DocumentsProvider;
            inventoryDraft.OtherMetrics = model.OtherMetrics;
            inventoryDraft.Notes = model.Notes;
            inventoryDraft.ClassificationScheme = model.ClassificationScheme;
            inventoryDraft.AbbreviationList = model.AbbreviationList;
            inventoryDraft.OtherLanguage = model.OtherLanguage;

            _context.Update(inventoryDraft);

            await _context.SaveAsync("Inventory draft for application modified");

            return inventoryDraft.SystemIdentifier;
        }

    }
}
