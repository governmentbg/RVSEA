using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Extensions.Models;
using DAA.Models.ArchiveEntities;
using DAA.Models.Configuration;
using DAA.Services.Nomenclatures;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;


namespace DAA.Services.ArchivalEntities
{
    public class ArchivalEntityPublicService : BaseService, IArchivalEntityPublicService
    {
        private readonly LinkedServerSettings _settings;
        private readonly IUserInfo _userInfo;
        private readonly INomenclatureService _nomenclatureService;

        public ArchivalEntityPublicService(
            ArchivingContext context,
            IOptions<LinkedServerSettings> settings,
            IUserInfo userInfo,
            INomenclatureService nomenclatureService,
            ILogger<IArchivalEntityPublicService> logger,
            IStringLocalizer<SharedResources> localizer)
            : base(context, localizer, logger)
        {
            _nomenclatureService = nomenclatureService;
            _settings = settings.Value;
            _userInfo = userInfo;
        }

        public async Task<ArchivalEntityPublicDisplayModel?> GetArchivalEntityBySystemIdentifierAsync(Guid sysId)
        {
            var archivalEntity =
                await _context.ArchivalEntities
                .Where(ae => ae.SystemIdentifier == sysId && !ae.Deleted && ae.StatusCode != "12")
                .Select(ae => new ArchivalEntityPublicDisplayModel()
                {
                    SystemIdentifier = ae.SystemIdentifier,
                    HasExternalSource = ae.HasExternalSource,
                    ExternalIdentifier = ae.ExternalIdentifier,
                    ArchiveName = ae.Archive.Name,
                    FundNumber = ae.FundSystemIdentifierNavigation.Number,
                    InventoryNumber = ae.InventorySystemIdentifierNavigation.Number,
                    Number = ae.Number,
                    Title = ae.Title,
                    StatusText = ae.StatusCodeNavigation!.Text,
                    DescriptionLevelText = ae.DescriptionLevelCodeNavigation!.Text,
                    ApproxmateChronologicalScope = ae.ApproxmateChronologicalScope,
                    HasNoChronologicalScope = ae.HasNoChronologicalScope,
                    StartDateDay = ae.StartDateDay,
                    StartDateMonth = ae.StartDateMonth,
                    StartDateYear = ae.StartDateYear,
                    EndDateDay = ae.EndDateDay,
                    EndDateMonth = ae.EndDateMonth,
                    EndDateYear = ae.EndDateYear,
                    OtherMetrics = ae.OtherMetrics,
                    Bytes = ae.Bytes,
                    NegativeFrameCount = ae.NegativeFrameCount,
                    PositiveFrameCount = ae.PositiveFrameCount,
                    DeductedBytes = ae.DeductedBytes,
                    DeductedDocumentCount = ae.DeductedDocumentCount,
                    EnrolledDocumentCount = ae.EnrolledDocumentCount,
                    DeductedLinearMeters = ae.DeductedLinearMeters,
                    EnrolledLinearMeters = ae.EnrolledLinearMeters,
                    Description = ae.Description,
                    DigitalDeviceCount = ae.DigitalDeviceCount,
                    DigitizedCopyCount = ae.DigitizedCopyCount,
                    Features = ae.Features,
                    FrameCount = ae.FrameCount,
                    FundExternalIdentifier = ae.FundSystemIdentifierNavigation.ExternalIdentifier,
                    FundHasExternalSource = ae.FundSystemIdentifierNavigation.HasExternalSource,
                    FundSystemIdentifier = ae.FundSystemIdentifierNavigation.SystemIdentifier,
                    InventorySystemIdentifier = ae.InventorySystemIdentifier,
                    InventoryExternalIdentifier = ae.InventorySystemIdentifierNavigation.ExternalIdentifier,
                    InventoryHasExternalSource = ae.InventorySystemIdentifierNavigation.HasExternalSource,
                    Location = ae.Location,
                    MicrofilmCount = ae.MicrofilmCount,
                    MicrofilmedCopyCount = ae.MicrofilmedCopyCount,
                    PaperCopyCount = ae.PaperCopyCount,
                    Scaling = ae.Scaling,
                    SheetCount = ae.SheetCount,
                    SizeCm = ae.SizeCm,
                    TapeCount = ae.TapeCount,
                    VideoTapeCount = ae.VideoTapeCount,
                    CreationMethodText = _nomenclatureService.GetEntityNomenclatureText(ae.Id, BusinessObjectType.ArchivalEntity, false, Shared.NomenclatureCode.CreationMethod), 
                    OriginalityText = _nomenclatureService.GetEntityNomenclatureText(ae.Id, BusinessObjectType.ArchivalEntity, false, Shared.NomenclatureCode.Originality),
                    LanguageText = _nomenclatureService.GetEntityNomenclatureText(ae.Id, BusinessObjectType.ArchivalEntity, false, Shared.NomenclatureCode.Language),
                })
                .SingleOrDefaultAsync();

            if (archivalEntity != null)
            {
                var sizeInfo = await _context.VArchivalEntitySizeInfos
                    .Where(x => x.ArchivalEntitySystemIdentifier == sysId && x.IsDraft == 0)
                    .SingleOrDefaultAsync();
                if (sizeInfo != null)
                {
                    archivalEntity.Bytes = sizeInfo.EnrolledBytes;
                    archivalEntity.FileTypeText = sizeInfo.FileTypes;
                    archivalEntity.DocumentCount = sizeInfo.EnrolledDocumentCount;
                }
            }

            if (archivalEntity != null && archivalEntity.HasExternalSource && archivalEntity.ExternalIdentifier.HasValue)
            {
                try
                {
                    archivalEntity = await GetFromExternalSourceAsync(archivalEntity.ExternalIdentifier.Value, archivalEntity.SystemIdentifier);
                }
                catch (Exception)
                {
                    _logger.LogWarning("Error retrieving archival entity data from ISDA");

                    archivalEntity!.ResultMessage = Constants.ISDADataCannotBeDisplayedMessageKey; // тук, ако няма archivalEntity, вече трябва да се хвърли грешка
                }
            }

            return archivalEntity;
        }

        public async Task<DataSourceResponseModel<ArchivalEntityPublicDisplayModel>> GetByInventoryIdentifierAsync(
          DataSourceRequestModel model,
          Guid? inventorySysId,
          bool inventoryHasExternalSource = false,
          int? inventoryExternalIdentifier = null,
          string? searchInventoryNumberString = null,
          bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            int totalCount = 0;
            IEnumerable<ArchivalEntityPublicDisplayModel> items = Enumerable.Empty<ArchivalEntityPublicDisplayModel>();
            List<object> errors = new();

            try
            {
                string countQuery = "exec @ReturnValue = sp_GetArchiveEntitiesByInventoryCountPublic @LinkedServer, @InventoryIdentifier, @InventoryHasExternalSource, @InventoryExternalIdentifier, @SearchText, @SearchNumber, @IncludeDeleted";
                List<SqlParameter> countQueryParams = new List<SqlParameter>()
                {
                    new SqlParameter("LinkedServer", _settings.LinkedServer),
                    new SqlParameter("InventoryIdentifier", inventorySysId.HasValue ? inventorySysId.Value : DBNull.Value),
                    new SqlParameter("InventoryHasExternalSource", inventoryHasExternalSource),
                    new SqlParameter("InventoryExternalIdentifier", inventoryExternalIdentifier.HasValue ? inventoryExternalIdentifier.Value : DBNull.Value),
                    new SqlParameter("SearchText", String.IsNullOrEmpty(model.SearchString) ? DBNull.Value : model.SearchString),
                    new SqlParameter("SearchNumber", String.IsNullOrEmpty(searchInventoryNumberString) ? DBNull.Value :searchInventoryNumberString),
                    new SqlParameter("IncludeDeleted", includeDeleted),
                };
                SqlParameter countQueryReturnValue = new SqlParameter()
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
                string query = "exec sp_GetArchiveEntitiesByInventoryPublic " +
                "@LinkedServer, @InventoryIdentifier, @InventoryHasExternalSource, @InventoryExternalIdentifier, @SearchText, @SearchNumber, @IncludeDeleted, @Paging, @PageNumber, @PageSize";
                List<SqlParameter> queryParams = new()
                {
                    new SqlParameter("LinkedServer", _settings.LinkedServer),
                    new SqlParameter("InventoryIdentifier", inventorySysId.HasValue
                        ? inventorySysId.Value
                        : DBNull.Value),
                    new SqlParameter("InventoryHasExternalSource", inventoryHasExternalSource),
                    new SqlParameter("InventoryExternalIdentifier", inventoryExternalIdentifier.HasValue
                        ? inventoryExternalIdentifier.Value
                        : DBNull.Value),
                    new SqlParameter("SearchText", String.IsNullOrEmpty(model.SearchString) ? DBNull.Value : model.SearchString),
                    new SqlParameter("SearchNumber", String.IsNullOrEmpty(searchInventoryNumberString) ? DBNull.Value : searchInventoryNumberString),
                    new SqlParameter("IncludeDeleted", includeDeleted),
                    new SqlParameter("Paging", true),
                    new SqlParameter("PageNumber", model.Page),
                    new SqlParameter("PageSize", model.ItemsPerPage),
                };
                var queryResult = await _context.RemoteArchiveEntities
                        .FromSqlRaw(query, queryParams.ToArray())
                        .AsNoTracking()
                        .ToListAsync();

                items =
                    queryResult.Select(i => new ArchivalEntityPublicDisplayModel()
                    {
                        SystemIdentifier = i.SystemIdentifier,
                        HasExternalSource = i.HasExternalSource ?? false,
                        ExternalIdentifier = i.ExternalIdentifier,
                        ArchiveName = i.ArchiveName,
                        FundNumber = i.FundNumber,
                        InventoryNumber = i.InventoryNumber,
                        Number = i.Number,
                        Title = i.Title,
                        StatusText = i.StatusText,
                        DescriptionLevelText = i.DescriptionLevelText,
                        CreationMethodText = i.CreationMethodText,
                        OriginalityText = i.OriginalityText,
                        LanguageText = i.LanguageText,
                        ApproxmateChronologicalScope = i.ApproximateChronologicalScope,
                        HasNoChronologicalScope = i.HasNoChronologicalScope ?? false,
                        StartDateDay = i.StartDateDay,
                        StartDateMonth = i.StartDateMonth,
                        StartDateYear = i.StartDateYear,
                        EndDateDay = i.EndDateDay,
                        EndDateMonth = i.EndDateMonth,
                        EndDateYear = i.EndDateYear,
                        OtherMetrics = i.OtherMetrics,
                        NegativeFrameCount = i.NegativeFrameCount,
                        PositiveFrameCount = i.PositiveFrameCount,
                        DeductedDocumentCount = i.DeductedDocumentCount,
                        DeductedLinearMeters = i.DeductedLinearMeters,
                        Description = i.Description,
                        DigitalDeviceCount = i.DigitalDeviceCount,
                        DigitizedCopyCount = i.DigitizedCopyCount,
                        EnrolledDocumentCount = i.EnrolledDocumentCount,
                        EnrolledLinearMeters = i.EnrolledLinearMeters,
                        Features = i.Features,
                        FrameCount = i.FrameCount,
                        Location = i.Location,
                        MicrofilmCount = i.MicrofilmCount,
                        MicrofilmedCopyCount = i.MicrofilmedCopyCount,
                        PaperCopyCount = i.PaperCopyCount,
                        SizeCm = i.SizeCm,
                        TapeCount = i.TapeCount,
                        FundExternalIdentifier = i.FundExternalIdentifier,
                        FundHasExternalSource = i.FundHasExternalSource,
                        InventoryHasExternalSource = i.InventoryHasExternalSource,
                        InventoryExternalIdentifier = i.InventoryExternalIdentifier,
                        VideoTapeCount = i.VideoTapeCount,
                        HasDigitizedDigitalObjects = i.HasDigitizedDigitalObjects,
                        
                    });
            }
            catch (Exception exc)
            {
                if (inventorySysId.HasValue)
                {
                    var localQuery =
                        _context.VPublicArchivalEntities
                        .Where(ae => ae.InventorySystemIdentifier == inventorySysId.Value)
                        .Select(ae => new ArchivalEntityPublicDisplayModel()
                        {
                            SystemIdentifier = ae.SystemIdentifier,
                            HasExternalSource = ae.HasExternalSource,
                            ExternalIdentifier = ae.ExternalIdentifier,
                            ArchiveName = ae.ArchiveName,
                            FundNumber = ae.FundNumber,
                            InventoryNumber = ae.InventoryNumber,
                            Number = ae.Number,
                            Title = ae.Title,
                            StatusText = ae.StatusText,
                            DescriptionLevelText = ae.DescriptionLevelText,
                            FundExternalIdentifier = ae.FundExternalIdentifier,
                            FundHasExternalSource = ae.FundHasExternalSource,
                            FundSystemIdentifier = ae.FundSystemIdentifier,
                            InventoryHasExternalSource = ae.InventoryHasExternalSource,
                            InventoryExternalIdentifier = ae.InventoryExternalIdentifier,
                            InventorySystemIdentifier = ae.InventorySystemIdentifier,
                            HasDigitizedDigitalObjects = ae.HasDigitizedDigitalObjects
                        });

                    if (!String.IsNullOrWhiteSpace(model.SearchString))
                    {
                        localQuery = localQuery.FilterBySearchTextPublic(model.SearchString);
                    }
                    if (!String.IsNullOrWhiteSpace(searchInventoryNumberString))
                    {
                        localQuery = localQuery.FilterByNumberPublic(searchInventoryNumberString);
                    }

                    totalCount = await localQuery.CountAsync();
                    items = await localQuery.ToListAsync();
                }
            }

         

            DataSourceResponseModel<ArchivalEntityPublicDisplayModel> result = new()
            {
                TotalCount = totalCount,
                Errors = errors.Count > 0 ? errors : null,
                Items = items
            };

            return result;
        }

        public async Task<ArchivalEntityPublicDisplayModel?> GetFromExternalSourceAsync(
         int externalIdentifier,
         Guid? systemIdentifier = null,
         Guid? inventorySystemIdentifier = null,
         Guid? fundSystemIdentifier = null)
        {
            string query = "exec sp_GetArchiveEntity @LinkedServer, @Identifier";
            List<SqlParameter> queryParams = new()
            {
                new SqlParameter("LinkedServer", _settings.LinkedServer),
                new SqlParameter("Identifier", externalIdentifier),
            };
            var result = (await _context.RemoteArchiveEntities
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

            if (!systemIdentifier.HasValue)
            {
                systemIdentifier = await _context.ArchivalEntities
                .Where(ae => ae.ExternalIdentifier == externalIdentifier)
                .Select(ae => ae.SystemIdentifier)
                .SingleOrDefaultAsync();

            }
            if (!inventorySystemIdentifier.HasValue)
            {
                inventorySystemIdentifier = await _context.Inventories
                .Where(inv => inv.ExternalIdentifier == result.InventoryExternalIdentifier!.Value)
                .Select(inv => inv.SystemIdentifier)
                .SingleOrDefaultAsync();
            }
            if (!fundSystemIdentifier.HasValue)
            {
                fundSystemIdentifier = await _context.Funds
                .Where(ae => ae.ExternalIdentifier == result.FundExternalIdentifier!.Value)
                .Select(ae => ae.SystemIdentifier)
                .SingleOrDefaultAsync();
            }

            return new ArchivalEntityPublicDisplayModel()
            {
                SystemIdentifier = systemIdentifier,
                HasExternalSource = result.HasExternalSource ?? false,
                ExternalIdentifier = result.ExternalIdentifier,
                ArchiveName = result.ArchiveName,
                FundNumber = result.FundNumber,
                InventoryNumber = result.InventoryNumber,
                Number = result.Number,
                Title = result.Title,
                StatusText = result.StatusText,
                DescriptionLevelText = result.DescriptionLevelText,
                ApproxmateChronologicalScope = result.ApproximateChronologicalScope,
                HasNoChronologicalScope = result.HasNoChronologicalScope ?? false,
                StartDateDay = result.StartDateDay,
                StartDateMonth = result.StartDateMonth,
                StartDateYear = result.StartDateYear,
                EndDateDay = result.EndDateDay,
                EndDateMonth = result.EndDateMonth,
                EndDateYear = result.EndDateYear,
                OtherMetrics = result.OtherMetrics,
                NegativeFrameCount = result.NegativeFrameCount,
                PositiveFrameCount = result.PositiveFrameCount,
                CreationMethodText = result.CreationMethodText,
                OriginalityText = result.OriginalityText,
                LanguageText = result.LanguageText,
                FundHasExternalSource = result.FundHasExternalSource ?? false,
                FundExternalIdentifier = result.FundExternalIdentifier,
                InventoryExternalIdentifier = result.InventoryExternalIdentifier,
                InventoryHasExternalSource = result.InventoryHasExternalSource ?? false,
                FundSystemIdentifier = fundSystemIdentifier,
                InventorySystemIdentifier = inventorySystemIdentifier,
                DeductedDocumentCount = result.DeductedDocumentCount,
                DeductedLinearMeters = result.DeductedLinearMeters,
                Description = result.Description,
                DigitalDeviceCount = result.DigitalDeviceCount,
                DigitizedCopyCount = result.DigitizedCopyCount,
                EnrolledDocumentCount = result.EnrolledDocumentCount,
                EnrolledLinearMeters = result.EnrolledLinearMeters,
                Features = result.Features,
                FrameCount = result.FrameCount,
                Location = result.Location,
                MicrofilmCount = result.MicrofilmCount,
                MicrofilmedCopyCount = result.MicrofilmedCopyCount,
                //OtherCopyCount = result.OtherCopyCount,
                PaperCopyCount = result.PaperCopyCount,
                SizeCm = result.SizeCm,
                TapeCount = result.TapeCount,
                VideoTapeCount = result.VideoTapeCount,
            };
        }

        public async Task<OperationResult?> CreateArchivalEntityReviewAsync(Guid? archivalEntitySystemIdentifier, int? archivalEntityExternalIdentifier)
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

            if ((archivalEntitySystemIdentifier.HasValue && archivalEntitySystemIdentifier.Value != Guid.Empty) || archivalEntityExternalIdentifier.HasValue)
            {
                if (archivalEntitySystemIdentifier.HasValue && archivalEntitySystemIdentifier.Value != Guid.Empty)
                {
                    publicUserReview.ArchivalEntitySystemIdentifier = archivalEntitySystemIdentifier.Value;
                }
                if (archivalEntityExternalIdentifier.HasValue)
                {
                    publicUserReview.ArchivalEntityExternalIdentifier = archivalEntityExternalIdentifier;
                }
            }
            else
            {
                return OperationResult.Succeed("No review for missing archive entity system identifier");
            }

            await _context.UserReviews.AddAsync(publicUserReview);
            await _context.SaveAsync("Public user review created");

            return OperationResult.Success;
        }

        public async Task<ArchivalEntityPublicImportModel?> GetArchivalEntityDraftBySysIdAsync(Guid sysId)
        {
            var archivalEntity =
                await _context.ArchivalEntityDrafts
                .Where(ae => ae.SystemIdentifier == sysId && !ae.Deleted && ae.IsCurrent)
                .Select(ae => new ArchivalEntityPublicImportModel()
                {
                    SystemIdentifier = ae.SystemIdentifier,
                    NumberNumeric = ae.NumberNumeric ?? 0,
                    NumberArray = ae.NumberArray,
                    ClassificationSchemeIndex = ae.ClassificationSchemeIndex,
                    Cypher = ae.Cypher,
                    Title = ae.Title,
                    StartDateDay = ae.StartDateDay,
                    StartDateMonth = ae.StartDateMonth,
                    StartDateYear = ae.StartDateYear ?? 1900,
                    EndDateDay = ae.EndDateDay,
                    EndDateMonth = ae.EndDateMonth,
                    EndDateYear = ae.EndDateYear ?? 1900,
                    Location = ae.Location,
                    TextDocsCount = ae.TextDocsCount,
                    GraphicalDocsCount = ae.GraphicalDocsCount,
                    OtherMetrics = ae.OtherMetrics,
                    Author = ae.Author,
                    Scaling = ae.Scaling,
                    Description = ae.Description,
                    OtherLanguage = ae.OtherLanguage,
                    DocumentsAccessDescription = ae.DocumentsAccessDescription,
                    Features = ae.Features,
                    Notes = ae.Notes,
                    Phase = ae.Phase,
                    Part = ae.Part,
                    Stage = ae.Stage,
                    DescriptionAuthor = ae.DescriptionAuthor,

                    InventoryNumberArray = ae.InventoryDraft!.NumberArray,
                    ArchiveId = ae.ArchiveId,
                    InventorySystemIdentifier = ae.InventoryDraft!.SystemIdentifier,
                    DescriptionLevelCode = ae.DescriptionLevelCode,

                    LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(ae.Id, BusinessObjectType.ArchivalEntity, true, Shared.NomenclatureCode.Language),
                    LanguageText = _nomenclatureService.GetEntityNomenclatureText(ae.Id, BusinessObjectType.ArchivalEntity, true, Shared.NomenclatureCode.Language), 
                    
                })
                .SingleOrDefaultAsync();

            return archivalEntity;
        }

        public async Task<OperationResult> UpdateDraftAsync(ArchivalEntityPublicImportModel model, Guid? userId)
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
                var archivalEntitySysId = await UpdateDraftInternalAsync(model, userId);

                transaction.Commit();
                return OperationResult.Succeed(archivalEntitySysId);
            }
            catch (ItemNotFoundException exc)
            {
                _logger.LogError(exc.ToString());
                transaction.Rollback();
                return OperationResult.Failed(exc.Message.ToString());
            }
            catch (Exception exc)
            {
                _logger.LogError(exc.ToString());
                transaction.Rollback();
                return OperationResult.Failed(_localizer.GetString("Error_ExecutingAction").ToString());
            }
        }

        private async Task<Guid> UpdateDraftInternalAsync(ArchivalEntityPublicImportModel model, Guid? userId)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            if (!model.SystemIdentifier.HasValue)
            {
                throw new SystemIdentifierNullException(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            var aeDraft = await _context.ArchivalEntityDrafts
                .Include(x => x.InventoryDraft).ThenInclude(inv => inv.Application)
                .Where(x => x.SystemIdentifier == model.SystemIdentifier && x.IsCurrent && !x.ReadOnly)
                .FirstOrDefaultAsync();

            if (aeDraft == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), (model.SystemIdentifier ?? Guid.Empty).ToString("D"));
            }

            if (aeDraft.InventoryDraft?.Application == null || aeDraft.InventoryDraft?.Application.StatusId != (int)ApplicationStatus.ModificationRequest || aeDraft.InventoryDraft?.Application.CreatedBy != userId)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ApplicationDataNotForEdit").ToString());
            }

            VArchivalEntity? existingNumber = await _context.VArchivalEntities
                .Where(x => 
                    x.NumberNumeric == model.NumberNumeric && 
                    ((String.IsNullOrWhiteSpace(x.NumberArray) && String.IsNullOrWhiteSpace(model.NumberArray)) || String.Equals(x.NumberArray, model.NumberArray)) && 
                    x.InventorySystemIdentifier == aeDraft.InventorySystemIdentifier &&
                    (x.IsDraft == false || x.Id != aeDraft.Id))
                .FirstOrDefaultAsync();

            if(existingNumber != null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_DuplicatedAENumber").ToString());
            }

            aeDraft.NumberNumeric = model.NumberNumeric;
            aeDraft.NumberArray = model.NumberArray;
            aeDraft.ClassificationSchemeIndex = model.ClassificationSchemeIndex;
            aeDraft.Cypher = model.Cypher;
            aeDraft.Title = model.Title;
            aeDraft.ApproxmateChronologicalScope = model.ApproximateChronologicalScope;
            aeDraft.StartDateDay = model.StartDateDay;
            aeDraft.StartDateMonth = model.StartDateMonth;
            aeDraft.StartDateYear = model.StartDateYear;
            aeDraft.EndDateDay = model.EndDateDay;
            aeDraft.EndDateMonth = model.EndDateMonth;
            aeDraft.EndDateYear = model.EndDateYear;
            aeDraft.Location = model.Location;
            aeDraft.TextDocsCount = model.TextDocsCount;
            aeDraft.GraphicalDocsCount = model.GraphicalDocsCount;
            aeDraft.OtherMetrics = model.OtherMetrics;
            aeDraft.Author = model.Author;
            aeDraft.Scaling = model.Scaling;
            aeDraft.Description = model.Description;
            aeDraft.OtherLanguage = model.OtherLanguage;
            aeDraft.DocumentsAccessDescription = model.DocumentsAccessDescription;
            aeDraft.Features = model.Features;
            aeDraft.Notes = model.Notes;
            aeDraft.Phase = model.Phase;
            aeDraft.Part = model.Part;
            aeDraft.Stage = model.Stage;
            aeDraft.DescriptionAuthor = model.DescriptionAuthor;

            _context.Update(aeDraft);

            //Update language values
            IEnumerable<NomenclatureValue>? archivalEntityNomenclatureValues = _nomenclatureService.GetEntityNomenclatureValues(aeDraft.Id, BusinessObjectType.ArchivalEntity, true, Shared.NomenclatureCode.Language);

            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(model.LanguageCodes, archivalEntityNomenclatureValues, Shared.NomenclatureCode.Language, aeDraft.Id, BusinessObjectType.ArchivalEntity, true);
                if (languageValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(languageValuesToAdd);
                }
            }

            var languageValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.LanguageCodes, archivalEntityNomenclatureValues, Shared.NomenclatureCode.Language);

            if(languageValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(languageValuesToDelete);
            }

            await _context.SaveAsync("Archival entity draft for application modified");

            return aeDraft.SystemIdentifier;
        }


    }
}
