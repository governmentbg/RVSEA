using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Extensions.Models;
using DAA.Models.Configuration;
using DAA.Models.Documents;
using DAA.Services.Nomenclatures;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
namespace DAA.Services.Documents
{
    public class DocumentPublicService : BaseService, IDocumentPublicService
    {
        private readonly LinkedServerSettings _settings;
        private readonly IUserInfo _userInfo;
        private readonly INomenclatureService _nomenclatureService;

        public DocumentPublicService(ArchivingContext context,
            IOptions<LinkedServerSettings> settings,
            IUserInfo userInfo,
            INomenclatureService nomenclatureService,
            ILogger<IDocumentPublicService> logger,
            IStringLocalizer<SharedResources> localizer)
            : base(context, localizer, logger)
        {
            _settings = settings.Value;
            _userInfo = userInfo;
            _nomenclatureService = nomenclatureService;
        }


        public async Task<DocumentPublicDisplayModel?> GetDocumentBySystemIdentifierAsync(Guid sysId)
        {
            var document =
                await _context.Documents
                .Where(d => d.SystemIdentifier == sysId && !d.Deleted && d.StatusCode != "12")
                .Select(d => new DocumentPublicDisplayModel()
                {
                    ExternalIdentifier = d.ExternalIdentifier,
                    HasExternalSource = d.HasExternalSource,
                    SystemIdentifier = d.SystemIdentifier,
                    ArchiveName = d.Archive.Name,
                    FundNumber = d.FundSystemIdentifierNavigation.Number,
                    InventoryNumber = d.InventorySystemIdentifierNavigation.Number,
                    ArchivalEntityNumber = d.ArchivalEntitySystemIdentifierNavigation.Number,
                    Number = d.Number,
                    Title = d.Title,
                    DescriptionLevelText = d.DescriptionLevelCodeNavigation.Text,
                    ApproximateChronologicalScope = d.ApproxmateChronologicalScope,
                    HasNoChronologicalScope = d.HasNoChronologicalScope,
                    StartDateDay = d.StartDateDay,
                    StartDateMonth = d.StartDateMonth,
                    StartDateYear = d.StartDateYear,
                    EndDateDay = d.EndDateDay,
                    EndDateMonth = d.EndDateMonth,
                    EndDateYear = d.EndDateYear,
                    DocumentsAccessDescription = d.DocumentsAccessDescription,
                    Notes = d.Notes,
                    Bytes = d.Bytes,
                    NegativeFrameCount = d.NegativeFrameCount,
                    PositiveFrameCount = d.PositiveFrameCount,
                    Author = d.Author,
                    Description = d.Description,
                    DigitizedCopyCount = d.DigitizedCopyCount,
                    Features = d.Features,
                    Location = d.Location,
                    MicrofilmedCopyCount = d.MicrofilmedCopyCount,
                    OtherCopyCount = d.OtherCopyCount,
                    PaperCopyCount = d.PaperCopyCount,
                    Scaling = d.Scaling,
                    SheetCount = d.SheetCount,
                    ArchivalEntitySystemIdentifier = d.ArchivalEntitySystemIdentifier,
                    ArchivalEntityExternalIdentifier = d.ArchivalEntitySystemIdentifierNavigation.ExternalIdentifier,
                    ArchivalEntityHasExternalSource = d.ArchivalEntitySystemIdentifierNavigation.HasExternalSource,
                    InventoryExternalIdentifier = d.InventorySystemIdentifierNavigation.ExternalIdentifier,
                    InventorySystemIdentifier = d.InventorySystemIdentifier,
                    InventoryHasExternalSource = d.InventorySystemIdentifierNavigation.HasExternalSource,
                    FundSystemIdentifier = d.FundSystemIdentifier,
                    FundHasExternalSource = d.FundSystemIdentifierNavigation.HasExternalSource,
                    FundExternalIdentifier = d.FundSystemIdentifierNavigation.ExternalIdentifier,
                    SizeCm = d.SizeCm,
                    DigitalDevice = d.DigitalDevice,
                    Duration = d.Duration,
                    StartSheetNumber = d.StartSheetNumber,
                    EndSheetNumber = d.EndSheetNumber,
                    FileTypeText = _nomenclatureService.GetEntityNomenclatureText(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.FileType),
                    CreationMethodText = _nomenclatureService.GetEntityNomenclatureText(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.CreationMethod),
                    OriginalityText = _nomenclatureService.GetEntityNomenclatureText(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.Originality),
                    LanguageText = _nomenclatureService.GetEntityNomenclatureText(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.Language),
                })
                .SingleOrDefaultAsync();

            if (document != null)
            {
                var sizeInfo = await _context.VDocumentSizeInfos
                    .Where(x => x.DocumentSystemIdentifier == sysId && x.IsDraft == 0)
                    .SingleOrDefaultAsync();
                if (sizeInfo != null)
                {
                    document.Duration = sizeInfo.EnrolledDuration;
                    document.Bytes = sizeInfo.EnrolledBytes;
                    string fileTypes = sizeInfo.FileTypes != null
                        ? String.Join(
                            System.Globalization.CultureInfo.CurrentCulture.TextInfo.ListSeparator + " ",
                            sizeInfo.FileTypes.Split("; ").Distinct()).ToUpper()
                        : String.Empty;
                    document.FileTypeText = fileTypes;
                }
            }

            if (document != null && document.HasExternalSource.HasValue && document.HasExternalSource.Value && document.ExternalIdentifier.HasValue)
            {
                try
                {
                    document = await GetFromExternalSourceAsync(
                    document.ExternalIdentifier.Value,
                    document.SystemIdentifier,
                    document.ArchivalEntitySystemIdentifier,
                    document.InventorySystemIdentifier,
                    document.FundSystemIdentifier);
                }
                catch (Exception)
                {
                    _logger.LogWarning("Error retrieving fund data from ISDA");

                    document!.ResultMessage = Constants.ISDADataCannotBeDisplayedMessageKey; // тук, ако няма document, вече трябва да се хвърли грешка
                }
            }

            return document;
        }


        public async Task<DataSourceResponseModel<DocumentPublicDisplayModel>> GetByArchivalEntityIdentifierAsync(
           DataSourceRequestModel model,
           Guid? archivalEntitySysId,
           bool archivalEntityHasExternalSource = false,
           int? archivalEntityExternalIdentifier = null,
           string? searchArchivalEntityNumber = null,
           int? searchArchivalEntityStartSheet = null,
           int? searchArchivalEntityEndSheet = null,
           bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            int totalCount = 0;
            IEnumerable<DocumentPublicDisplayModel> items = Enumerable.Empty<DocumentPublicDisplayModel>();
            List<object> errors = new List<object>();

            try
            {
                string countQuery = "exec @ReturnValue = sp_GetDocumentsByArchiveEntityCountPublic @LinkedServer, @ArchiveEntityIdentifier, @ArchiveEntityHasExternalSource, @ArchiveEntityExternalIdentifier, @SearchText, @IncludeDeleted";
                List<SqlParameter> countQueryParams = new()
                {
                    new SqlParameter("LinkedServer", _settings.LinkedServer),
                    new SqlParameter("ArchiveEntityIdentifier", archivalEntitySysId.HasValue ? archivalEntitySysId.Value : DBNull.Value),
                    new SqlParameter("ArchiveEntityHasExternalSource", archivalEntityHasExternalSource),
                    new SqlParameter("ArchiveEntityExternalIdentifier", archivalEntityExternalIdentifier.HasValue ? archivalEntityExternalIdentifier.Value : DBNull.Value),
                    new SqlParameter("SearchText", String.IsNullOrEmpty(model.SearchString) ? DBNull.Value : model.SearchString),
                    new SqlParameter("IncludeDeleted", includeDeleted),
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
                string query = "exec sp_GetDocumentsByArchiveEntityPublic " +
                "@LinkedServer, @ArchiveEntityIdentifier, @ArchiveEntityHasExternalSource, @ArchiveEntityExternalIdentifier, @SearchText, @IncludeDeleted, @Paging, @PageNumber, @PageSize";
                List<SqlParameter> queryParams = new()
                {
                    new SqlParameter("LinkedServer", _settings.LinkedServer),
                    new SqlParameter("ArchiveEntityIdentifier", archivalEntitySysId.HasValue ? archivalEntitySysId.Value : DBNull.Value),
                    new SqlParameter("ArchiveEntityHasExternalSource", archivalEntityHasExternalSource),
                    new SqlParameter("ArchiveEntityExternalIdentifier", archivalEntityExternalIdentifier.HasValue
                        ? archivalEntityExternalIdentifier.Value
                        : DBNull.Value),
                    new SqlParameter("SearchText", String.IsNullOrEmpty(model.SearchString) ? DBNull.Value : model.SearchString),
                    new SqlParameter("IncludeDeleted", includeDeleted),
                    new SqlParameter("Paging", true),
                    new SqlParameter("PageNumber", model.Page),
                    new SqlParameter("PageSize", model.ItemsPerPage),
                };
                var queryResult = await _context.RemoteDocuments
                        .FromSqlRaw(query, queryParams.ToArray())
                        .AsNoTracking()
                        .ToListAsync();

                items =
                    queryResult.Select(d => new DocumentPublicDisplayModel()
                    {
                        SystemIdentifier = d.SystemIdentifier,
                        HasExternalSource = d.HasExternalSource,
                        ExternalIdentifier = d.ExternalIdentifier,
                        ArchiveName = d.ArchiveName,
                        FundNumber = d.FundNumber,
                        FundHasExternalSource = d.FundHasExternalSource,
                        FundExternalIdentifier = d.FundExternalIdentifier,
                        InventoryHasExternalSource = d.InventoryHasExternalSource,
                        InventoryExternalIdentifier = d.InventoryExternalIdentifier,
                        ArchivalEntityHasExternalSource = d.ArchivalEntityHasExternalSource,
                        ArchivalEntityExternalIdentifier = d.ArchivalEntityExternalIdentifier,
                        InventoryNumber = d.InventoryNumber,
                        ArchivalEntityNumber = d.ArchivalEntityNumber,
                        Number = d.Number,
                        Title = d.Title,
                        DescriptionLevelText = d.DescriptionLevelText,
                        ApproximateChronologicalScope = d.ApproximateChronologicalScope,
                        StatusText = d.StatusText,
                        HasDigitizedDigitalObjects = d.HasDigitizedDigitalObjects,
                    });
            }
            catch (Exception exc)
            {
                if (archivalEntitySysId.HasValue)
                {
                    var localQuery =
                        _context.VPublicDocuments
                        .Where(d => d.ArchivalEntitySystemIdentifier == archivalEntitySysId.Value && !d.Deleted && d.StatusCode != "12")
                        .Select(d => new DocumentPublicDisplayModel()
                        {
                            SystemIdentifier = d.SystemIdentifier,
                            HasExternalSource = d.HasExternalSource,
                            ExternalIdentifier = d.ExternalIdentifier,
                            ArchiveName = d.ArchiveName,
                            FundSystemIdentifier = d.FundSystemIdentifier,
                            FundNumber = d.FundNumber,
                            FundHasExternalSource = d.FundHasExternalSource,
                            FundExternalIdentifier = d.FundExternalIdentifier,
                            InventoryHasExternalSource = d.InventoryHasExternalSource,
                            InventoryExternalIdentifier = d.InventoryExternalIdentifier,
                            ArchivalEntityHasExternalSource = d.ArchivalEntityHasExternalSource,
                            ArchivalEntityExternalIdentifier = d.ArchivalEntityExternalIdentifier,
                            InventorySystemIdentifier = d.InventorySystemIdentifier,
                            InventoryNumber = d.InventoryNumber,
                            ArchivalEntitySystemIdentifier = d.ArchivalEntitySystemIdentifier,
                            ArchivalEntityNumber = d.ArchivalEntityNumber,
                            Number = d.Number,
                            Title = d.Title,
                            DescriptionLevelText = d.DescriptionLevelText,
                            ApproximateChronologicalScope = d.ApproxmateChronologicalScope,
                            StatusText = d.StatusText,
                            HasDigitizedDigitalObjects = d.HasDigitizedDigitalObjects,
                        });

                    if (!includeDeleted)
                    {
                        localQuery = localQuery.Where(i => !i.Deleted);
                    }

                    if (!String.IsNullOrWhiteSpace(model.SearchString))
                    {
                        localQuery = localQuery.FilterBySearchText(model.SearchString);
                    }

                    totalCount = await localQuery.CountAsync();
                    items = await localQuery.ToListAsync();
                }
            }

            DataSourceResponseModel<DocumentPublicDisplayModel> result = new()
            {
                TotalCount = totalCount,
                Errors = errors.Count > 0 ? errors : null,
                Items = items
            };

            return result;
        }

        public async Task<DocumentPublicDisplayModel?> GetFromExternalSourceAsync(
           int externalIdentifier,
           Guid? systemIdentifier = null,
           Guid? archivalEntitySystemIdentifier = null,
           Guid? inventorySystemIdentifier = null,
           Guid? fundSystemIdentifier = null)
        {
            string query = "exec sp_GetDocument @LinkedServer, @Identifier";
            List<SqlParameter> queryParams = new()
            {
                new SqlParameter("LinkedServer", _settings.LinkedServer),
                new SqlParameter("Identifier", externalIdentifier),
            };
            var result = (await _context.RemoteDocuments
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

            if (!archivalEntitySystemIdentifier.HasValue)
            {
                archivalEntitySystemIdentifier = await _context.ArchivalEntities
                .Where(ae => ae.ExternalIdentifier == result.ArchivalEntityExternalIdentifier!.Value)
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
                .Where(f => f.ExternalIdentifier == result.FundExternalIdentifier!.Value)
                .Select(f => f.SystemIdentifier)
                .SingleOrDefaultAsync();

            }

            return new DocumentPublicDisplayModel()
            {
                SystemIdentifier = systemIdentifier,
                HasExternalSource = result.HasExternalSource,
                ExternalIdentifier = result.ExternalIdentifier,
                ArchiveName = result.ArchiveName,
                FundSystemIdentifier = fundSystemIdentifier,
                FundNumber = result.FundNumber,
                InventorySystemIdentifier = inventorySystemIdentifier,
                InventoryNumber = result.InventoryNumber,
                ArchivalEntitySystemIdentifier = archivalEntitySystemIdentifier,
                ArchivalEntityNumber = result.ArchivalEntityNumber,
                Number = result.Number,
                Title = result.Title,
                ApproximateChronologicalScope = result.ApproximateChronologicalScope,
                Location = result.Location,
                HasNoChronologicalScope = result.HasNoChronologicalScope ?? false,
                StartDateDay = result.StartDateDay,
                StartDateMonth = result.StartDateMonth,
                StartDateYear = result.StartDateYear,
                EndDateDay = result.EndDateDay,
                EndDateMonth = result.EndDateMonth,
                FundHasExternalSource = result.FundHasExternalSource,
                FundExternalIdentifier = result.FundExternalIdentifier,
                InventoryHasExternalSource = result.InventoryHasExternalSource,
                InventoryExternalIdentifier = result.InventoryExternalIdentifier,
                ArchivalEntityHasExternalSource = result.ArchivalEntityHasExternalSource,
                ArchivalEntityExternalIdentifier = result.ArchivalEntityExternalIdentifier,
                EndDateYear = result.EndDateYear,
                Description = result.Description,
                Features = result.Features,
                MicrofilmedCopyCount = result.MicrofilmedCopyCount,
                DigitizedCopyCount = result.DigitizedCopyCount,
                PaperCopyCount = result.PaperCopyCount,
                NegativeFrameCount = result.NegativeFrameCount,
                PositiveFrameCount = result.PositiveFrameCount,
                OtherCopyCount = result.OtherCopyCount,
                Notes = result.Notes,
                CreationMethodText = result.CreationMethodText,
                OriginalityText = result.OriginalityText,
                LanguageText = result.LanguageText,
                SheetCount = result.SheetCount,
            };
        }

        public async Task<OperationResult?> CreateDocumentReviewAsync(Guid? documentSystemIdentifier, int? documentExternalIdentifier)
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

            if ((documentSystemIdentifier.HasValue && documentSystemIdentifier.Value != Guid.Empty) || documentExternalIdentifier.HasValue)
            {
                if (documentSystemIdentifier.HasValue && documentSystemIdentifier.Value != Guid.Empty)
                {
                    publicUserReview.DocumentSystemIdentifier = documentSystemIdentifier.Value;
                }
                if (documentExternalIdentifier.HasValue)
                {
                    publicUserReview.DocumentExternalIdentifier = documentExternalIdentifier;
                }
            }
            else
            {
                return OperationResult.Succeed("No review for missing document system identifier");
            }

            await _context.UserReviews.AddAsync(publicUserReview);
            await _context.SaveAsync("Public user review created");

            return OperationResult.Success;
        }


        public async Task<DocumentPublicImportModel?> GetDocumentDraftBySysIdAsync(Guid sysId)
        {
            var doc =
                await _context.DocumentDrafts
                .Where(x => x.SystemIdentifier == sysId && !x.Deleted && x.IsCurrent)
                .Select(x => new DocumentPublicImportModel()
                {
                    SystemIdentifier = x.SystemIdentifier,

                    Number = CommonHelper.NullableTryParseInt32(x.Number) ?? 0,
                    Cypher = x.Cypher,
                    Title = x.Title,
                    StartDateDay = x.StartDateDay,
                    StartDateMonth = x.StartDateMonth,
                    StartDateYear = x.StartDateYear ?? 1900,
                    EndDateDay = x.EndDateDay,
                    EndDateMonth = x.EndDateMonth,
                    EndDateYear = x.EndDateYear ?? 1900,
                    Location = x.Location,
                    TextDocsCount = x.TextDocsCount,
                    GraphicalDocsCount = x.GraphicalDocsCount,
                    OtherMetrics = x.OtherMetrics,
                    Author = x.Author,
                    Scaling = x.Scaling,
                    Description = x.Description,
                    OtherLanguage = x.OtherLanguage,
                    DocumentsAccessDescription = x.DocumentsAccessDescription,
                    Features = x.Features,
                    Notes = x.Notes,
                    Phase = x.Phase,
                    Part = x.Part,
                    Stage = x.Stage,
                    DescriptionAuthor = x.DescriptionAuthor,

                    InventoryNumberArray = x.InventoryDraft!.NumberArray,
                    ArchiveId = x.ArchiveId,
                    InventorySystemIdentifier = x.InventoryDraft!.SystemIdentifier,
                    ArchivalEntitySystemIdentifier = x.ArchivalEntityDraft!.SystemIdentifier,
                    DescriptionLevelCode = x.DescriptionLevelCode,

                    LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(x.Id, BusinessObjectType.Document, true, Shared.NomenclatureCode.Language),
                    Language = _nomenclatureService.GetEntityNomenclatureText(x.Id, BusinessObjectType.Document, true, Shared.NomenclatureCode.Language),

                })
                .SingleOrDefaultAsync();

            return doc;
        }

        public async Task<OperationResult> UpdateDraftAsync(DocumentPublicImportModel model, Guid? userId)
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
                var docSysId = await UpdateDraftInternalAsync(model, userId);

                transaction.Commit();
                return OperationResult.Succeed(docSysId);
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

        private async Task<Guid> UpdateDraftInternalAsync(DocumentPublicImportModel model, Guid? userId)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            if (!model.SystemIdentifier.HasValue)
            {
                throw new SystemIdentifierNullException(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            var docDraft = await _context.DocumentDrafts
                .Include(x => x.InventoryDraft).ThenInclude(inv => inv.Application)
                .Where(x => x.SystemIdentifier == model.SystemIdentifier && x.IsCurrent && !x.ReadOnly)
                .FirstOrDefaultAsync();

            if (docDraft == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), (model.SystemIdentifier ?? Guid.Empty).ToString("D"));
            }

            if (docDraft.InventoryDraft?.Application == null || docDraft.InventoryDraft?.Application.StatusId != (int)ApplicationStatus.ModificationRequest || docDraft.InventoryDraft?.Application.CreatedBy != userId)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ApplicationDataNotForEdit").ToString());
            }

            VDocument? existingNumber = await _context.VDocuments
                .Where(x =>
                    ((String.IsNullOrWhiteSpace(x.Number) && model.Number <= 0) || String.Equals(x.Number, model.Number)) &&
                    x.ArchivalEntitySystemIdentifier == docDraft.ArchivalEntitySystemIdentifier &&
                    (x.IsDraft == false || x.Id != docDraft.Id))
                .FirstOrDefaultAsync();

            if (existingNumber != null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_DuplicatedDocNumber").ToString());
            }

            docDraft.Number = model.Number.ToString();
            docDraft.Cypher = model.Cypher;
            docDraft.Title = model.Title;
            docDraft.ApproxmateChronologicalScope = model.ApproximateChronologicalScope;
            docDraft.StartDateDay = model.StartDateDay;
            docDraft.StartDateMonth = model.StartDateMonth;
            docDraft.StartDateYear = model.StartDateYear;
            docDraft.EndDateDay = model.EndDateDay;
            docDraft.EndDateMonth = model.EndDateMonth;
            docDraft.EndDateYear = model.EndDateYear;
            docDraft.Location = model.Location;
            docDraft.TextDocsCount = model.TextDocsCount;
            docDraft.GraphicalDocsCount = model.GraphicalDocsCount;
            docDraft.OtherMetrics = model.OtherMetrics;
            docDraft.Author = model.Author;
            docDraft.Scaling = model.Scaling;
            docDraft.Description = model.Description;
            docDraft.OtherLanguage = model.OtherLanguage;
            docDraft.DocumentsAccessDescription = model.DocumentsAccessDescription;
            docDraft.Features = model.Features;
            docDraft.Notes = model.Notes;
            docDraft.Phase = model.Phase;
            docDraft.Part = model.Part;
            docDraft.Stage = model.Stage;
            docDraft.DescriptionAuthor = model.DescriptionAuthor;

            _context.Update(docDraft);

            //Update language values
            IEnumerable<NomenclatureValue>? docNomenclatureValues = _nomenclatureService.GetEntityNomenclatureValues(docDraft.Id, BusinessObjectType.Document, true, Shared.NomenclatureCode.Language);

            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(model.LanguageCodes, docNomenclatureValues, Shared.NomenclatureCode.Language, docDraft.Id, BusinessObjectType.Document, true);
                if (languageValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(languageValuesToAdd);
                }
            }

            var languageValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(model.LanguageCodes, docNomenclatureValues, Shared.NomenclatureCode.Language);
            if (languageValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(languageValuesToDelete);
            }

            await _context.SaveAsync("Document draft for application modified");

            return docDraft.SystemIdentifier;
        }



    }
}
