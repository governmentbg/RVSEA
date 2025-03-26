using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Extensions.Models;
using DAA.Extensions.Recapitulation;
using DAA.Models;
using DAA.Models.ArchiveEntities;
using DAA.Models.Configuration;
using DAA.Services.Funds;
using DAA.Services.Inventories;
using DAA.Services.Nomenclatures;
using DAA.Services.Roles;
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
using System.Text;

namespace DAA.Services.ArchivalEntities
{
    public class ArchivalEntityService : BaseService, IArchivalEntityService
    {
        private readonly LinkedServerSettings _settings;
        private readonly IUserInfo _userInfo;
        private readonly IArchiveService _archiveService;
        private readonly IFundService _fundService;
        private readonly IInventoryService _inventoryService;
        private readonly INomenclatureService _nomenclatureService;

        public ArchivalEntityService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            ILogger<IArchivalEntityService> logger,
            IOptions<LinkedServerSettings> settings,
            IUserInfo userInfo,
            IArchiveService archiveService,
            IFundService fundService,
            IInventoryService inventoryService,
            IRoleService roleService,
            INomenclatureService nomenclatureService)
            : base(context, localizer, logger)
        {
            _settings = settings.Value;
            _userInfo = userInfo;
            _archiveService = archiveService;
            _fundService = fundService;
            _inventoryService = inventoryService;
            _nomenclatureService = nomenclatureService;
        }

        public DataSourceResponseModel<ArchivalEntityDisplayModel> GetAll(DataSourceRequestModel model, bool includeDeleted = false)
        {

            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.VArchivalEntities
                .OrderBy(ae => ae.NumberNumeric).ThenBy(ae => ae.CreatedOn)
                .Select(ae => new ArchivalEntityDisplayModel()
                {
                    Id = ae.Id,
                    SystemIdentifier = ae.SystemIdentifier,
                    IsDraft = ae.IsDraft ?? false,
                    HasExternalSource = ae.HasExternalSource!.Value,
                    ExternalIdentifier = ae.ExternalIdentifier,
                    ExternalSourceUpdatedOn = ae.ExternalSourceUpdatedOn,
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
                    Number = ae.Number,
                    NumberNumeric = ae.NumberNumeric,
                    Title = ae.Title,
                    StatusCode = ae.StatusCode!,
                    StatusText = ae.StatusText,
                    DescriptionLevelCode = ae.DescriptionLevelCode!,
                    DescriptionLevelText = ae.DescriptionLevelText,
                    AvailabilityStatusCode = ae.AvailabilityStatusCode,
                    AvailabilityStatusText = ae.AvailabilityStatusText,
                    CreatedBy = ae.CreatedBy,
                    CreatedByDisplayName = ae.CreatedByDisplayName,
                    CreatedByUserName = ae.CreatedByUserName,
                    CreatedOn = ae.CreatedOn,
                    UpdatedBy = ae.UpdatedBy,
                    UpdatedByDisplayName = ae.UpdatedByDisplayName,
                    UpdatedByUserName = ae.UpdatedByUserName,
                    UpdatedOn = ae.UpdatedOn,
                    Deleted = ae.Deleted,
                    DeletedBy = ae.DeletedBy,
                    DeletedByDisplayName = ae.DeletedByDisplayName,
                    DeletedByUserName = ae.DeletedByUserName,
                    DeletedOn = ae.DeletedOn,
                });

            if (!includeDeleted)
            {
                query = query.Where(i => !i.Deleted);
            }

            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }

            QueryResponseModel<ArchivalEntityDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<ArchivalEntityDisplayModel> result = new DataSourceResponseModel<ArchivalEntityDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(ae => new ArchivalEntityDisplayModel()
                {
                    Id = ae.Id,
                    SystemIdentifier = ae.SystemIdentifier,
                    IsDraft = ae.IsDraft,
                    HasExternalSource = ae.HasExternalSource,
                    ExternalIdentifier = ae.ExternalIdentifier,
                    ExternalSourceUpdatedOn = ae.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    ArchiveId = ae.ArchiveId,
                    ArchiveCode = ae.ArchiveCode,
                    ArchiveName = ae.ArchiveName,
                    FundDraftId = ae.FundDraftId,
                    FundSystemIdentifier = ae.FundSystemIdentifier,
                    FundHasExternalSource = ae.FundHasExternalSource,
                    FundExternalIdentifier = ae.FundExternalIdentifier,
                    FundNumber = ae.FundNumber,
                    InventoryDraftId = ae.InventoryDraftId,
                    InventorySystemIdentifier = ae.InventorySystemIdentifier,
                    InventoryHasExternalSource = ae.InventoryHasExternalSource,
                    InventoryExternalIdentifier = ae.InventoryExternalIdentifier,
                    InventoryNumber = ae.InventoryNumber,
                    Number = ae.Number,
                    NumberNumeric = ae.NumberNumeric,
                    Title = ae.Title,
                    StatusCode = ae.StatusCode!,
                    StatusText = ae.StatusText,
                    DescriptionLevelCode = ae.DescriptionLevelCode!,
                    DescriptionLevelText = ae.DescriptionLevelText,
                    AvailabilityStatusCode = ae.AvailabilityStatusCode,
                    AvailabilityStatusText = ae.AvailabilityStatusText,
                    CreatedBy = ae.CreatedBy,
                    CreatedByDisplayName = ae.CreatedByDisplayName,
                    CreatedByUserName = ae.CreatedByUserName,
                    CreatedOn = ae.CreatedOn.UtcToLocalTime(),
                    UpdatedBy = ae.UpdatedBy,
                    UpdatedByDisplayName = ae.UpdatedByDisplayName,
                    UpdatedByUserName = ae.UpdatedByUserName,
                    UpdatedOn = ae.UpdatedOn.UtcToLocalTime(),
                    Deleted = ae.Deleted,
                    DeletedBy = ae.DeletedBy,
                    DeletedByDisplayName = ae.DeletedByDisplayName,
                    DeletedByUserName = ae.DeletedByUserName,
                    DeletedOn = ae.DeletedOn.UtcToLocalTime(),
                })
            };

            return result;
        }

        public async Task<DataSourceResponseModel<ArchivalEntityDisplayModel>> GetByInventoryIdentifierAsync(
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
            IEnumerable<ArchivalEntityDisplayModel> items = Enumerable.Empty<ArchivalEntityDisplayModel>();
            List<object> errors = new List<object>();

            try
            {
                string countQuery = "exec @ReturnValue = sp_GetArchiveEntitiesByInventoryCount @LinkedServer, @InventoryIdentifier, @InventoryHasExternalSource, @InventoryExternalIdentifier, @SearchText, @SearchNumber, @IncludeDeleted";
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
                string query = "exec sp_GetArchiveEntitiesByInventory " +
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
                    queryResult.Select(ae => new ArchivalEntityDisplayModel()
                    {
                        Id = ae.Id,
                        SystemIdentifier = ae.SystemIdentifier,
                        HasExternalSource = ae.HasExternalSource ?? false,
                        ExternalIdentifier = ae.ExternalIdentifier,
                        ArchiveCode = ae.ArchiveCode,
                        ArchiveName = ae.ArchiveName,
                        FundHasExternalSource = ae.FundHasExternalSource ?? false,
                        FundExternalIdentifier = ae.FundExternalIdentifier,
                        FundNumber = ae.FundNumber,
                        InventoryHasExternalSource = ae.InventoryHasExternalSource ?? false,
                        InventoryExternalIdentifier = ae.InventoryExternalIdentifier,
                        InventoryNumber = ae.InventoryNumber,
                        Number = ae.Number,
                        Title = ae.Title,
                        StatusCode = ae.StatusCode!,
                        StatusText = ae.StatusText,
                        DescriptionLevelCode = ae.DescriptionLevelCode!,
                        DescriptionLevelText = ae.DescriptionLevelText,
                        AvailabilityStatusCode = ae.AvailabilityStatusCode,
                        AvailabilityStatusText = ae.AvailabilityStatusText,
                        CreationMethodText = ae.CreationMethodText,
                        OriginalityText = ae.OriginalityText,
                        LanguageText = ae.LanguageText,
                        ApproximateChronologicalScope = ae.ApproximateChronologicalScope,
                        HasNoChronologicalScope = ae.HasNoChronologicalScope ?? false,
                        StartDateDay = ae.StartDateDay,
                        StartDateMonth = ae.StartDateMonth,
                        StartDateYear = ae.StartDateYear,
                        EndDateDay = ae.EndDateDay,
                        EndDateMonth = ae.EndDateMonth,
                        EndDateYear = ae.EndDateYear,
                        DocumentsAccessDescription = ae.DocumentsAccessDescription,
                        OtherMetrics = ae.OtherMetrics,
                        Notes = ae.Notes,
                        NegativeFrameCount = ae.NegativeFrameCount,
                        PositiveFrameCount = ae.PositiveFrameCount,
                        DeductedDocumentCount = ae.DeductedDocumentCount,
                        DeductedLinearMeters = ae.DeductedLinearMeters,
                        Description = ae.Description,
                        DigitalDeviceCount = ae.DigitalDeviceCount,
                        DigitizedCopyCount = ae.DigitizedCopyCount,
                        EnrolledDocumentCount = ae.EnrolledDocumentCount,
                        EnrolledLinearMeters = ae.EnrolledLinearMeters,
                        Features = ae.Features,
                        FrameCount = ae.FrameCount,
                        Location = ae.Location,
                        MicrofilmCount = ae.MicrofilmCount,
                        MicrofilmedCopyCount = ae.MicrofilmedCopyCount,
                        OtherCopyCount = ae.OtherCopyCount,
                        PaperCopyCount = ae.PaperCopyCount,
                        SizeCm = ae.SizeCm,
                        TapeCount = ae.TapeCount,
                        VideoTapeCount = ae.VideoTapeCount,
                        CreatedOn = ae.CreatedOn,
                        CreatedByDisplayName = ae.CreatedByDisplayName,
                        UpdatedOn = ae.UpdatedOn,
                        UpdatedByDisplayName = ae.UpdatedByDisplayName,
                        ClassificationSchemeIndex = ae.ClassificationSchemeIndex,
                        Cypher = ae.Cypher,
                        DescriptionAuthor = ae.DescriptionAuthor,
                        TextDocsCount = ae.TextDocsCount,
                        GraphicalDocsCount = ae.GraphicalDocsCount,
                        Phase = ae.Phase,
                        Part = ae.Part,
                        Stage = ae.Stage,
                        Author = ae.Author,
                        HasDigitizedDigitalObjects = ae.HasDigitizedDigitalObjects
                    });


                items = items.Select(x =>
                        {
                            x.SystemIdentifier = x.HasExternalSource == true ? _context.ArchivalEntities
                            .Where(i => i.ExternalIdentifier == x.ExternalIdentifier && !i.Deleted)
                            .Select(i => i.SystemIdentifier)
                            .FirstOrDefault()
                            : x.SystemIdentifier;

                            x.IsInProcess =
                                    _context.Processes
                                  .Where(p => p.ArchivalEntitySystemIdentifier.HasValue && p.ArchivalEntitySystemIdentifier == x.SystemIdentifier && !p.Completed && !p.Deleted)
                                  .Any();

                            return x;
                        });
            }
            catch (Exception exc)
            {
                _logger.LogWarning(exc.ToString(), "Error getting archival entities from external source");

                if (inventorySysId.HasValue)
                {
                    var localQuery =
                        _context.VArchivalEntities
                        .Where(ae => ae.InventorySystemIdentifier == inventorySysId.Value)
                        .OrderBy(ae => ae.NumberNumeric).ThenBy(ae => ae.CreatedOn)
                        .Select(i => new ArchivalEntityDisplayModel()
                        {
                            Id = i.Id,
                            SystemIdentifier = i.SystemIdentifier,
                            IsDraft = i.IsDraft ?? false,
                            HasExternalSource = i.HasExternalSource!.Value,
                            ExternalIdentifier = i.ExternalIdentifier,
                            ExternalSourceUpdatedOn = i.ExternalSourceUpdatedOn,
                            ArchiveId = i.ArchiveId,
                            ArchiveCode = i.ArchiveCode,
                            ArchiveName = i.ArchiveName,
                            FundDraftId = i.FundDraftId,
                            FundSystemIdentifier = i.FundSystemIdentifier,
                            FundHasExternalSource = i.FundHasExternalSource ?? false,
                            FundExternalIdentifier = i.FundExternalIdentifier,
                            FundNumber = i.FundNumber,
                            InventoryDraftId = i.InventoryDraftId,
                            InventorySystemIdentifier = i.InventorySystemIdentifier,
                            InventoryHasExternalSource = i.InventoryHasExternalSource ?? false,
                            InventoryExternalIdentifier = i.InventoryExternalIdentifier,
                            InventoryNumber = i.InventoryNumber,
                            Number = i.Number,
                            NumberNumeric = i.NumberNumeric,
                            Title = i.Title,
                            StatusCode = i.StatusCode!,
                            StatusText = i.StatusText,
                            DescriptionLevelCode = i.DescriptionLevelCode!,
                            DescriptionLevelText = i.DescriptionLevelText,
                            AvailabilityStatusCode = i.AvailabilityStatusCode,
                            AvailabilityStatusText = i.AvailabilityStatusText,
                            CreatedBy = i.CreatedBy,
                            CreatedByDisplayName = i.CreatedByDisplayName,
                            CreatedByUserName = i.CreatedByUserName,
                            CreatedOn = i.CreatedOn,
                            UpdatedBy = i.UpdatedBy,
                            UpdatedByDisplayName = i.UpdatedByDisplayName,
                            UpdatedByUserName = i.UpdatedByUserName,
                            UpdatedOn = i.UpdatedOn,
                            Deleted = i.Deleted,
                            DeletedBy = i.DeletedBy,
                            DeletedByDisplayName = i.DeletedByDisplayName,
                            DeletedByUserName = i.DeletedByUserName,
                            DeletedOn = i.DeletedOn,
                            ClassificationSchemeIndex = i.ClassificationSchemeIndex,
                            HasDigitizedDigitalObjects = i.HasDigitizedDigitalObjects
                        });

                    if (!includeDeleted)
                    {
                        localQuery = localQuery.Where(i => !i.Deleted);
                    }

                    if (!String.IsNullOrWhiteSpace(model.SearchString))
                    {
                        localQuery = localQuery.FilterBySearchText(model.SearchString);
                    }
                    if (!String.IsNullOrWhiteSpace(searchInventoryNumberString))
                    {
                        localQuery = localQuery.FilterByNumber(searchInventoryNumberString);
                    }

                    foreach (var item in localQuery)
                    {
                        item.IsInProcess = await _context.Processes
                          .Where(p => p.ArchivalEntitySystemIdentifier.HasValue && p.ArchivalEntitySystemIdentifier == item.SystemIdentifier && !p.Completed)
                          .AnyAsync();
                    }

                    totalCount = await localQuery.CountAsync();
                    items = await localQuery.Select(i => new ArchivalEntityDisplayModel()
                    {
                        Id = i.Id,
                        SystemIdentifier = i.SystemIdentifier,
                        IsDraft = i.IsDraft,
                        HasExternalSource = i.HasExternalSource,
                        ExternalIdentifier = i.ExternalIdentifier,
                        ExternalSourceUpdatedOn = i.ExternalSourceUpdatedOn.UtcToLocalTime(),
                        ArchiveId = i.ArchiveId,
                        ArchiveCode = i.ArchiveCode,
                        ArchiveName = i.ArchiveName,
                        FundDraftId = i.FundDraftId,
                        FundSystemIdentifier = i.FundSystemIdentifier,
                        FundHasExternalSource = i.FundHasExternalSource,
                        FundExternalIdentifier = i.FundExternalIdentifier,
                        FundNumber = i.FundNumber,
                        InventoryDraftId = i.InventoryDraftId,
                        InventorySystemIdentifier = i.InventorySystemIdentifier,
                        InventoryHasExternalSource = i.InventoryHasExternalSource,
                        InventoryExternalIdentifier = i.InventoryExternalIdentifier,
                        InventoryNumber = i.InventoryNumber,
                        Number = i.Number,
                        NumberNumeric = i.NumberNumeric,
                        Title = i.Title,
                        StatusCode = i.StatusCode!,
                        StatusText = i.StatusText,
                        DescriptionLevelCode = i.DescriptionLevelCode!,
                        DescriptionLevelText = i.DescriptionLevelText,
                        AvailabilityStatusCode = i.AvailabilityStatusCode,
                        AvailabilityStatusText = i.AvailabilityStatusText,
                        CreatedBy = i.CreatedBy,
                        CreatedByDisplayName = i.CreatedByDisplayName,
                        CreatedByUserName = i.CreatedByUserName,
                        CreatedOn = i.CreatedOn.UtcToLocalTime(),
                        UpdatedBy = i.UpdatedBy,
                        UpdatedByDisplayName = i.UpdatedByDisplayName,
                        UpdatedByUserName = i.UpdatedByUserName,
                        UpdatedOn = i.UpdatedOn.UtcToLocalTime(),
                        Deleted = i.Deleted,
                        DeletedBy = i.DeletedBy,
                        DeletedByDisplayName = i.DeletedByDisplayName,
                        DeletedByUserName = i.DeletedByUserName,
                        DeletedOn = i.DeletedOn.UtcToLocalTime(),
                        ClassificationSchemeIndex = i.ClassificationSchemeIndex,
                        HasDigitizedDigitalObjects = i.HasDigitizedDigitalObjects
                    }).ToListAsync();
                }
            }


            DataSourceResponseModel<ArchivalEntityDisplayModel> result = new DataSourceResponseModel<ArchivalEntityDisplayModel>()
            {
                TotalCount = totalCount,
                TotalCountInWords = NumberInWordsExtension.BGCurrencyToBGText(totalCount),
                Errors = errors.Count > 0 ? errors : null,
                Items = items
            };

            return result;
        }

        public DataSourceResponseModel<ArchivalEntityDisplayModel> GetByAvailabilityStatus(
            DataSourceRequestModel model,
            int availabilityStatus,
            Guid fundSystemIdentifier,
            string? searchInventoryNumberString,
            bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.VArchivalEntities
                .Where(d =>
                    d.FundSystemIdentifier == fundSystemIdentifier
                    && d.AvailabilityStatusCode == availabilityStatus
                    && d.InventoryAvailabilityStatusCode != (int)Shared.AvailabilityStatus.RelocationDeduction
                    && d.InventoryAvailabilityStatusCode != (int)Shared.AvailabilityStatus.DisposalDeduction)
                .OrderBy(d => d.NumberNumeric).ThenBy(d => d.CreatedOn)
                .Select(d => new ArchivalEntityDisplayModel()
                {
                    Id = d.Id,
                    SystemIdentifier = d.SystemIdentifier,
                    IsDraft = d.IsDraft ?? false,
                    HasExternalSource = d.HasExternalSource ?? false,
                    ExternalIdentifier = d.ExternalIdentifier,
                    ExternalSourceUpdatedOn = d.ExternalSourceUpdatedOn,
                    ArchiveId = d.ArchiveId,
                    ArchiveCode = d.ArchiveCode,
                    ArchiveName = d.ArchiveName,
                    FundDraftId = d.FundDraftId,
                    FundSystemIdentifier = d.FundSystemIdentifier,
                    FundHasExternalSource = d.FundHasExternalSource ?? false,
                    FundExternalIdentifier = d.FundExternalIdentifier,
                    FundNumber = d.FundNumber,
                    InventoryDraftId = d.InventoryDraftId,
                    InventorySystemIdentifier = d.InventorySystemIdentifier,
                    InventoryHasExternalSource = d.InventoryHasExternalSource ?? false,
                    InventoryExternalIdentifier = d.InventoryExternalIdentifier,
                    InventoryNumber = d.InventoryNumber,
                    InventoryAvailabilityStatusCode = d.InventoryAvailabilityStatusCode,
                    Number = d.Number,
                    NumberNumeric = d.NumberNumeric,
                    Title = d.Title,
                    StatusCode = d.StatusCode!,
                    StatusText = d.StatusText,
                    DescriptionLevelCode = d.DescriptionLevelCode!,
                    DescriptionLevelText = d.DescriptionLevelText,
                    AvailabilityStatusCode = d.AvailabilityStatusCode,
                    AvailabilityStatusText = d.AvailabilityStatusText,
                    ApproximateChronologicalScope = d.ApproxmateChronologicalScope,
                    CreatedBy = d.CreatedBy,
                    CreatedByDisplayName = d.CreatedByDisplayName,
                    CreatedByUserName = d.CreatedByUserName,
                    CreatedOn = d.CreatedOn,
                    UpdatedBy = d.UpdatedBy,
                    UpdatedByDisplayName = d.UpdatedByDisplayName,
                    UpdatedByUserName = d.UpdatedByUserName,
                    UpdatedOn = d.UpdatedOn,
                    Deleted = d.Deleted,
                    DeletedBy = d.DeletedBy,
                    DeletedByDisplayName = d.DeletedByDisplayName,
                    DeletedByUserName = d.DeletedByUserName,
                    DeletedOn = d.DeletedOn,
                });

            if (!includeDeleted)
            {
                query = query.Where(i => !i.Deleted);
            }

            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }

            QueryResponseModel<ArchivalEntityDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<ArchivalEntityDisplayModel> result = new DataSourceResponseModel<ArchivalEntityDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(d => new ArchivalEntityDisplayModel()
                {
                    Id = d.Id,
                    SystemIdentifier = d.SystemIdentifier,
                    IsDraft = d.IsDraft,
                    HasExternalSource = d.HasExternalSource,
                    ExternalIdentifier = d.ExternalIdentifier,
                    ExternalSourceUpdatedOn = d.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    ArchiveId = d.ArchiveId,
                    ArchiveCode = d.ArchiveCode,
                    ArchiveName = d.ArchiveName,
                    FundDraftId = d.FundDraftId,
                    FundSystemIdentifier = d.FundSystemIdentifier,
                    FundHasExternalSource = d.FundHasExternalSource,
                    FundExternalIdentifier = d.FundExternalIdentifier,
                    FundNumber = d.FundNumber,
                    InventoryDraftId = d.InventoryDraftId,
                    InventorySystemIdentifier = d.InventorySystemIdentifier,
                    InventoryHasExternalSource = d.InventoryHasExternalSource,
                    InventoryExternalIdentifier = d.InventoryExternalIdentifier,
                    InventoryNumber = d.InventoryNumber,
                    InventoryAvailabilityStatusCode = d.InventoryAvailabilityStatusCode,
                    Number = d.Number,
                    NumberNumeric = d.NumberNumeric,
                    Title = d.Title,
                    StatusCode = d.StatusCode!,
                    StatusText = d.StatusText,
                    DescriptionLevelCode = d.DescriptionLevelCode!,
                    DescriptionLevelText = d.DescriptionLevelText,
                    AvailabilityStatusCode = d.AvailabilityStatusCode,
                    AvailabilityStatusText = d.AvailabilityStatusText,
                    ApproximateChronologicalScope = d.ApproximateChronologicalScope,
                    CreatedBy = d.CreatedBy,
                    CreatedByDisplayName = d.CreatedByDisplayName,
                    CreatedByUserName = d.CreatedByUserName,
                    CreatedOn = d.CreatedOn.UtcToLocalTime(),
                    UpdatedBy = d.UpdatedBy,
                    UpdatedByDisplayName = d.UpdatedByDisplayName,
                    UpdatedByUserName = d.UpdatedByUserName,
                    UpdatedOn = d.UpdatedOn.UtcToLocalTime(),
                    Deleted = d.Deleted,
                    DeletedBy = d.DeletedBy,
                    DeletedByDisplayName = d.DeletedByDisplayName,
                    DeletedByUserName = d.DeletedByUserName,
                    DeletedOn = d.DeletedOn.UtcToLocalTime(),
                })
            };

            return result;
        }

        public async Task<bool> AnyUnnumberedDraftsByFundIdentifier(Guid fundSysId)
        {
            return await _context.ArchivalEntityDrafts
                    .Where(ae =>
                            ae.FundSystemIdentifier == fundSysId
                            && ae.IsCurrent
                            && string.IsNullOrWhiteSpace(ae.Number)
                            && !ae.Deleted
                            && (!ae.HasExternalSource.HasValue || !ae.HasExternalSource.Value))
                    .AnyAsync();
        }

        public async Task<bool> AnyUnnumberedDraftsByInventoryIdentifier(Guid inventorySysId)
        {
            return await _context.ArchivalEntityDrafts
                    .Where(ae =>
                            ae.InventorySystemIdentifier == inventorySysId
                            && ae.IsCurrent
                            && string.IsNullOrWhiteSpace(ae.Number)
                            && !ae.Deleted
                            && (!ae.HasExternalSource.HasValue || !ae.HasExternalSource.Value))
                    .AnyAsync();
        }

        public async Task<ArchivalEntityDisplayModel?> GetArchivalEntityBySystemIdentifierAsync(Guid sysId)
        {
            var archivalEntityDraft = await GetCurrentDraftAsync(sysId);
            if (archivalEntityDraft != null)
            {
                var sizeInfo = await _context.VArchivalEntitySizeInfos
                    .Where(x => x.ArchivalEntitySystemIdentifier == sysId && x.IsDraft == 1)
                    .SingleOrDefaultAsync();
                if (sizeInfo != null)
                {
                    archivalEntityDraft.EnrolledDocumentCount = sizeInfo.EnrolledDocumentCount;
                    archivalEntityDraft.DeductedDocumentCount = sizeInfo.DeductedDocumentCount;
                    archivalEntityDraft.Bytes = sizeInfo.EnrolledBytes;
                    archivalEntityDraft.EnrolledBytes = sizeInfo.EnrolledBytes;
                    archivalEntityDraft.DeductedBytes = sizeInfo.DeductedBytes;
                    archivalEntityDraft.FileTypeText = sizeInfo.FileTypes;
                    archivalEntityDraft.DocumentCount = sizeInfo.EnrolledDocumentCount;
                    archivalEntityDraft.EnrolledDuration = sizeInfo.EnrolledDuration;
                    archivalEntityDraft.DeductedDuration = sizeInfo.DeductedDuration;
                }

                return archivalEntityDraft;
            }

            var archivalEntity =
                await _context.ArchivalEntities
                .Where(ae => ae.SystemIdentifier == sysId && !ae.Deleted)
                .Select(ae => new ArchivalEntityDisplayModel()
                {
                    Id = ae.Id,
                    SystemIdentifier = ae.SystemIdentifier,
                    IsDraft = false,
                    HasExternalSource = ae.HasExternalSource,
                    ExternalIdentifier = ae.ExternalIdentifier,
                    ExternalSourceUpdatedOn = ae.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    ArchiveId = ae.ArchiveId,
                    ArchiveCode = ae.Archive.Code,
                    ArchiveName = ae.Archive.Name,
                    FundSystemIdentifier = ae.FundSystemIdentifier,
                    FundHasExternalSource = ae.FundSystemIdentifierNavigation.HasExternalSource,
                    FundExternalIdentifier = ae.FundSystemIdentifierNavigation.ExternalIdentifier,
                    FundNumberArray = ae.FundSystemIdentifierNavigation.NumberArray,
                    FundNumberNumeric = ae.FundSystemIdentifierNavigation.NumberNumeric,
                    FundNumber = ae.FundSystemIdentifierNavigation.Number,
                    InventorySystemIdentifier = ae.InventorySystemIdentifier,
                    InventoryHasExternalSource = ae.InventorySystemIdentifierNavigation.HasExternalSource,
                    InventoryExternalIdentifier = ae.InventorySystemIdentifierNavigation.ExternalIdentifier,
                    InventoryNumberArray = ae.InventorySystemIdentifierNavigation.NumberArray,
                    InventoryNumberNumeric = ae.InventorySystemIdentifierNavigation.NumberNumeric,
                    InventoryNumber = ae.InventorySystemIdentifierNavigation.Number,
                    Number = ae.Number,
                    NumberNumeric = ae.NumberNumeric,
                    Title = ae.Title,
                    StatusCode = ae.StatusCode!,
                    StatusText = ae.StatusCodeNavigation!.Text,
                    DescriptionLevelCode = ae.DescriptionLevelCode!,
                    DescriptionLevelText = ae.DescriptionLevelCodeNavigation!.Text,
                    AvailabilityStatusCode = ae.AvailabilityStatusCode,
                    AvailabilityStatusText = ae.AvailabilityStatusCodeNavigation!.Text,
                    ApproximateChronologicalScope = ae.ApproxmateChronologicalScope,
                    HasNoChronologicalScope = ae.HasNoChronologicalScope,
                    StartDateDay = ae.StartDateDay,
                    StartDateMonth = ae.StartDateMonth,
                    StartDateYear = ae.StartDateYear,
                    EndDateDay = ae.EndDateDay,
                    EndDateMonth = ae.EndDateMonth,
                    EndDateYear = ae.EndDateYear,
                    DocumentsAccessDescription = ae.DocumentsAccessDescription,
                    OtherMetrics = ae.OtherMetrics,
                    Notes = ae.Notes,
                    Bytes = ae.Bytes,
                    NegativeFrameCount = ae.NegativeFrameCount,
                    PositiveFrameCount = ae.PositiveFrameCount,
                    Author = ae.Author,
                    Condition = ae.Condition,
                    DeductedBytes = ae.DeductedBytes,
                    EnrolledBytes = ae.EnrolledBytes,
                    DeductedDocumentCount = ae.DeductedDocumentCount,
                    EnrolledDocumentCount = ae.EnrolledDocumentCount,
                    DeductedLinearMeters = ae.DeductedLinearMeters,
                    EnrolledLinearMeters = ae.EnrolledLinearMeters,
                    Description = ae.Description,
                    DigitalDeviceCount = ae.DigitalDeviceCount,
                    DigitizedCopyCount = ae.DigitizedCopyCount,
                    Features = ae.Features,
                    FrameCount = ae.FrameCount,
                    Location = ae.Location,
                    MicrofilmCount = ae.MicrofilmCount,
                    MicrofilmedCopyCount = ae.MicrofilmedCopyCount,
                    OtherCopyCount = ae.OtherCopyCount,
                    PaperCopyCount = ae.PaperCopyCount,
                    Scaling = ae.Scaling,
                    SheetCount = ae.SheetCount,
                    SizeCm = ae.SizeCm,
                    TapeCount = ae.TapeCount,
                    VideoTapeCount = ae.VideoTapeCount,
                    CreatedBy = ae.CreatedBy,
                    CreatedByDisplayName = ae.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == ae.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = ae.CreatedByNavigation.UserName,
                    CreatedOn = ae.CreatedOn.UtcToLocalTime(),
                    Deleted = ae.Deleted,
                    DeletedBy = ae.DeletedBy,
                    DeletedByDisplayName = ae.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == ae.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = ae.DeletedByNavigation.UserName,
                    DeletedOn = ae.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = ae.UpdatedBy,
                    UpdatedByDisplayName = ae.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == ae.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = ae.UpdatedByNavigation.UserName,
                    UpdatedOn = ae.UpdatedOn.UtcToLocalTime(),

                    IsImported = ae.IsImported,
                    NumberArray = ae.NumberArray,
                    DescriptionAuthor = ae.DescriptionAuthor,

                    Cypher = ae.Cypher,
                    TextDocsCount = ae.TextDocsCount,
                    GraphicalDocsCount = ae.GraphicalDocsCount,
                    Phase = ae.Phase,
                    Part = ae.Part,
                    Stage = ae.Stage,
                    OtherLanguage = ae.OtherLanguage,
                    ClassificationSchemeIndex = ae.ClassificationSchemeIndex,

                    CreationMethodCodes = _nomenclatureService.GetEntityNomenclatureCodes(ae.Id, BusinessObjectType.ArchivalEntity, false, Shared.NomenclatureCode.CreationMethod),
                    CreationMethodText = _nomenclatureService.GetEntityNomenclatureText(ae.Id, BusinessObjectType.ArchivalEntity, false, Shared.NomenclatureCode.CreationMethod),
                    OriginalityCodes = _nomenclatureService.GetEntityNomenclatureCodes(ae.Id, BusinessObjectType.ArchivalEntity, false, Shared.NomenclatureCode.Originality),
                    OriginalityText = _nomenclatureService.GetEntityNomenclatureText(ae.Id, BusinessObjectType.ArchivalEntity, false, Shared.NomenclatureCode.Originality),
                    LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(ae.Id, BusinessObjectType.ArchivalEntity, false, Shared.NomenclatureCode.Language),
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
                    archivalEntity.EnrolledDocumentCount = sizeInfo.EnrolledDocumentCount;
                    archivalEntity.DeductedDocumentCount = sizeInfo.DeductedDocumentCount;
                    archivalEntity.Bytes = sizeInfo.EnrolledBytes;
                    archivalEntity.EnrolledBytes = sizeInfo.EnrolledBytes;
                    archivalEntity.DeductedBytes = sizeInfo.DeductedBytes;
                    archivalEntity.FileTypeText = sizeInfo.FileTypes;
                    archivalEntity.DocumentCount = sizeInfo.EnrolledDocumentCount;
                    archivalEntity.EnrolledDuration = sizeInfo.EnrolledDuration;
                    archivalEntity.DeductedDuration = sizeInfo.DeductedDuration;
                }
            }

            if (archivalEntity != null && archivalEntity.HasExternalSource && archivalEntity.ExternalIdentifier.HasValue)
            {
                try
                {
                    archivalEntity = await GetFromExternalSourceAsync(archivalEntity.ExternalIdentifier.Value, archivalEntity.SystemIdentifier);
                }
                catch (Exception exc)
                {
                    _logger.LogWarning(exc, $"Error getting archival entity from external source (systemIdentifier: {archivalEntity?.SystemIdentifier}, externalIdentifier: {archivalEntity?.ExternalIdentifier})");

                    archivalEntity.IsExternalSourceSnapshot = true;

                    //archivalEntity!.ResultMessage = Constants.ISDADataCannotBeDisplayedMessageKey; // тук, ако няма archivalEntity, вече трябва да се хвърли грешка
                }
            }

            return archivalEntity;
        }

        public async Task<ArchivalEntityDisplayModel?> GetCurrentDraftAsync(Guid sysId)
        {
            var archivalEntityDraft =
                await _context.ArchivalEntityDrafts
                .GroupJoin(
                    _context.Inventories,
                    draft => draft.InventorySystemIdentifier,
                    inventory => inventory.SystemIdentifier,
                    (draft, inventory) => new { Draft = draft, Inventory = inventory })
                .SelectMany(ae => ae.Inventory.DefaultIfEmpty(),
                    (draft, inventory) => new { Draft = draft, Inventory = inventory })
                .GroupJoin(
                    _context.Funds,
                    ae => ae.Draft.Draft.FundSystemIdentifier,
                    fund => fund.SystemIdentifier,
                    (draft, fund) => new { Draft = draft, Fund = fund })
                .SelectMany(ae => ae.Fund.DefaultIfEmpty(),
                    (draft, fund) => new { Draft = draft, Fund = fund })
                .Where(draft => draft.Draft.Draft.Draft.Draft.SystemIdentifier == sysId && draft.Draft.Draft.Draft.Draft.IsCurrent && !draft.Draft.Draft.Draft.Draft.Deleted)
                .Select(ae => new ArchivalEntityDisplayModel()
                {
                    Id = ae.Draft.Draft.Draft.Draft.Id,
                    SystemIdentifier = ae.Draft.Draft.Draft.Draft.SystemIdentifier,
                    IsDraft = true,
                    HasExternalSource = ae.Draft.Draft.Draft.Draft.HasExternalSource ?? false,
                    ExternalIdentifier = ae.Draft.Draft.Draft.Draft.ExternalIdentifier,
                    ExternalSourceUpdatedOn = ae.Draft.Draft.Draft.Draft.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    ArchiveId = ae.Draft.Draft.Draft.Draft.ArchiveId,
                    ArchiveCode = ae.Draft.Draft.Draft.Draft.Archive.Code,
                    ArchiveName = ae.Draft.Draft.Draft.Draft.Archive.Name,
                    FundDraftId = ae.Draft.Draft.Draft.Draft.FundDraftId,
                    FundSystemIdentifier = ae.Draft.Draft.Draft.Draft.FundSystemIdentifier,
                    FundHasExternalSource = ae.Draft.Draft.Draft.Draft.FundDraft!.HasExternalSource ?? ae.Fund!.HasExternalSource,
                    FundExternalIdentifier = ae.Fund!.ExternalIdentifier,
                    FundNumberArray = ae.Fund.NumberArray,
                    FundNumberNumeric = ae.Fund.NumberNumeric,
                    FundNumber = ae.Fund.Number,
                    InventoryDraftId = ae.Draft.Draft.Draft.Draft.InventoryDraftId,
                    InventorySystemIdentifier = ae.Draft.Draft.Draft.Draft.InventorySystemIdentifier,
                    InventoryHasExternalSource = ae.Draft.Draft.Draft.Draft.InventoryDraft!.HasExternalSource ?? ae.Draft.Draft.Inventory!.HasExternalSource,
                    InventoryExternalIdentifier = ae.Draft.Draft.Inventory!.ExternalIdentifier,
                    InventoryNumberArray = ae.Draft.Draft.Inventory.NumberArray ?? ae.Draft.Draft.Draft.Draft.InventoryDraft!.NumberArray,
                    InventoryNumberNumeric = ae.Draft.Draft.Inventory.NumberNumeric ?? ae.Draft.Draft.Draft.Draft.InventoryDraft!.NumberNumeric,
                    InventoryNumber = ae.Draft.Draft.Inventory.Number,
                    Number = ae.Draft.Draft.Draft.Draft.Number,
                    NumberArray = ae.Draft.Draft.Draft.Draft.NumberArray,
                    NumberNumeric = ae.Draft.Draft.Draft.Draft.NumberNumeric,
                    Title = ae.Draft.Draft.Draft.Draft.Title,
                    StatusCode = ae.Draft.Draft.Draft.Draft.StatusCode!,
                    StatusText = ae.Draft.Draft.Draft.Draft.StatusCodeNavigation!.Text,
                    DescriptionLevelCode = ae.Draft.Draft.Draft.Draft.DescriptionLevelCode!,
                    DescriptionLevelText = ae.Draft.Draft.Draft.Draft.DescriptionLevelCodeNavigation!.Text,
                    AvailabilityStatusCode = ae.Draft.Draft.Draft.Draft.AvailabilityStatusCode,
                    AvailabilityStatusText = ae.Draft.Draft.Draft.Draft.AvailabilityStatusCodeNavigation!.Text,
                    ApproximateChronologicalScope = ae.Draft.Draft.Draft.Draft.ApproxmateChronologicalScope,
                    HasNoChronologicalScope = ae.Draft.Draft.Draft.Draft.HasNoChronologicalScope,
                    StartDateDay = ae.Draft.Draft.Draft.Draft.StartDateDay,
                    StartDateMonth = ae.Draft.Draft.Draft.Draft.StartDateMonth,
                    StartDateYear = ae.Draft.Draft.Draft.Draft.StartDateYear,
                    EndDateDay = ae.Draft.Draft.Draft.Draft.EndDateDay,
                    EndDateMonth = ae.Draft.Draft.Draft.Draft.EndDateMonth,
                    EndDateYear = ae.Draft.Draft.Draft.Draft.EndDateYear,
                    DocumentsAccessDescription = ae.Draft.Draft.Draft.Draft.DocumentsAccessDescription,
                    OtherMetrics = ae.Draft.Draft.Draft.Draft.OtherMetrics,
                    Notes = ae.Draft.Draft.Draft.Draft.Notes,
                    Bytes = ae.Draft.Draft.Draft.Draft.Bytes,
                    NegativeFrameCount = ae.Draft.Draft.Draft.Draft.NegativeFrameCount,
                    PositiveFrameCount = ae.Draft.Draft.Draft.Draft.PositiveFrameCount,
                    Author = ae.Draft.Draft.Draft.Draft.Author,
                    Condition = ae.Draft.Draft.Draft.Draft.Condition,
                    DeductedBytes = ae.Draft.Draft.Draft.Draft.DeductedBytes,
                    EnrolledBytes = ae.Draft.Draft.Draft.Draft.EnrolledBytes,
                    DeductedDocumentCount = ae.Draft.Draft.Draft.Draft.DeductedDocumentCount,
                    EnrolledDocumentCount = ae.Draft.Draft.Draft.Draft.EnrolledDocumentCount,
                    DeductedLinearMeters = ae.Draft.Draft.Draft.Draft.DeductedLinearMeters,
                    EnrolledLinearMeters = ae.Draft.Draft.Draft.Draft.EnrolledLinearMeters,
                    Description = ae.Draft.Draft.Draft.Draft.Description,
                    DigitalDeviceCount = ae.Draft.Draft.Draft.Draft.DigitalDeviceCount,
                    DigitizedCopyCount = ae.Draft.Draft.Draft.Draft.DigitizedCopyCount,
                    Features = ae.Draft.Draft.Draft.Draft.Features,
                    FrameCount = ae.Draft.Draft.Draft.Draft.FrameCount,
                    Location = ae.Draft.Draft.Draft.Draft.Location,
                    MicrofilmCount = ae.Draft.Draft.Draft.Draft.MicrofilmCount,
                    MicrofilmedCopyCount = ae.Draft.Draft.Draft.Draft.MicrofilmedCopyCount,
                    OtherCopyCount = ae.Draft.Draft.Draft.Draft.OtherCopyCount,
                    PaperCopyCount = ae.Draft.Draft.Draft.Draft.PaperCopyCount,
                    Scaling = ae.Draft.Draft.Draft.Draft.Scaling,
                    SheetCount = ae.Draft.Draft.Draft.Draft.SheetCount,
                    SizeCm = ae.Draft.Draft.Draft.Draft.SizeCm,
                    TapeCount = ae.Draft.Draft.Draft.Draft.TapeCount,
                    VideoTapeCount = ae.Draft.Draft.Draft.Draft.VideoTapeCount,
                    CreatedBy = ae.Draft.Draft.Draft.Draft.CreatedBy,
                    CreatedByDisplayName = ae.Draft.Draft.Draft.Draft.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == ae.Draft.Draft.Draft.Draft.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = ae.Draft.Draft.Draft.Draft.CreatedByNavigation!.UserName,
                    CreatedOn = ae.Draft.Draft.Draft.Draft.CreatedOn.UtcToLocalTime(),
                    Deleted = ae.Draft.Draft.Draft.Draft.Deleted,
                    DeletedBy = ae.Draft.Draft.Draft.Draft.DeletedBy,
                    DeletedByDisplayName = ae.Draft.Draft.Draft.Draft.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == ae.Draft.Draft.Draft.Draft.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = ae.Draft.Draft.Draft.Draft.DeletedByNavigation!.UserName,
                    DeletedOn = ae.Draft.Draft.Draft.Draft.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = ae.Draft.Draft.Draft.Draft.UpdatedBy,
                    UpdatedByDisplayName = ae.Draft.Draft.Draft.Draft.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == ae.Draft.Draft.Draft.Draft.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = ae.Draft.Draft.Draft.Draft.UpdatedByNavigation!.UserName,
                    UpdatedOn = ae.Draft.Draft.Draft.Draft.UpdatedOn.UtcToLocalTime(),
                    IsImported = ae.Draft.Draft.Draft.Draft.IsImported,
                    DescriptionAuthor = ae.Draft.Draft.Draft.Draft.DescriptionAuthor,
                    Cypher = ae.Draft.Draft.Draft.Draft.Cypher,
                    TextDocsCount = ae.Draft.Draft.Draft.Draft.TextDocsCount,
                    GraphicalDocsCount = ae.Draft.Draft.Draft.Draft.GraphicalDocsCount,
                    Phase = ae.Draft.Draft.Draft.Draft.Phase,
                    Part = ae.Draft.Draft.Draft.Draft.Part,
                    Stage = ae.Draft.Draft.Draft.Draft.Stage,
                    OtherLanguage = ae.Draft.Draft.Draft.Draft.OtherLanguage,
                    ClassificationSchemeIndex = ae.Draft.Draft.Draft.Draft.ClassificationSchemeIndex,

                    CreationMethodCodes = _nomenclatureService.GetEntityNomenclatureCodes(ae.Draft.Draft.Draft.Draft.Id, BusinessObjectType.ArchivalEntity, true, Shared.NomenclatureCode.CreationMethod),
                    CreationMethodText = _nomenclatureService.GetEntityNomenclatureText(ae.Draft.Draft.Draft.Draft.Id, BusinessObjectType.ArchivalEntity, true, Shared.NomenclatureCode.CreationMethod),
                    OriginalityCodes = _nomenclatureService.GetEntityNomenclatureCodes(ae.Draft.Draft.Draft.Draft.Id, BusinessObjectType.ArchivalEntity, true, Shared.NomenclatureCode.Originality),
                    OriginalityText = _nomenclatureService.GetEntityNomenclatureText(ae.Draft.Draft.Draft.Draft.Id, BusinessObjectType.ArchivalEntity, true, Shared.NomenclatureCode.Originality),
                    LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(ae.Draft.Draft.Draft.Draft.Id, BusinessObjectType.ArchivalEntity, true, Shared.NomenclatureCode.Language),
                    LanguageText = _nomenclatureService.GetEntityNomenclatureText(ae.Draft.Draft.Draft.Draft.Id, BusinessObjectType.ArchivalEntity, true, Shared.NomenclatureCode.Language),
                })
                .SingleOrDefaultAsync();

            return archivalEntityDraft;
        }

        public async Task<bool> HasCurrentDraftAsync(Guid sysId)
        {
            return await _context.ArchivalEntityDrafts
                    .Where(ae => ae.SystemIdentifier == sysId && ae.IsCurrent && !ae.Deleted)
                    .AnyAsync();
        }

        public async Task<bool> IsCurrentDraftAsync(ArchivalEntityDraftModel model)
        {
            return await _context.ArchivalEntityDrafts.Where(ae => ae.Id == model.Id && ae.IsCurrent && !ae.Deleted).AnyAsync();
        }

        public async Task<bool> IsReadOnlyDraftAsync(ArchivalEntityDraftModel model)
        {
            return await _context.ArchivalEntityDrafts.Where(ae => ae.Id == model.Id && (ae.ReadOnly || !ae.IsCurrent || ae.Deleted)).AnyAsync();
        }

        async Task<Guid> IArchivalEntityServiceBase.CreateDraftInternalAsync(ArchivalEntityDraftModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            //If there is new inventory draft on edit
            if (!model.InventoryDraftId.HasValue)
            {
                var inventoryDraft = await _inventoryService.GetCurrentDraftAsync(model.InventorySystemIdentifier!.Value);
                if (inventoryDraft != null)
                {
                    model.FundDraftId = inventoryDraft.FundDraftId;
                    model.InventoryDraftId = inventoryDraft.Id;
                }
            }

            if (!model.SystemIdentifier.HasValue)
            {
                model.SystemIdentifier = Guid.NewGuid();
            }
            else
            {
                var currentDraft =
                    await _context.ArchivalEntityDrafts
                    .Where(inv => inv.SystemIdentifier == model.SystemIdentifier && inv.IsCurrent)
                    .SingleOrDefaultAsync();
                if (currentDraft != null)
                {
                    currentDraft.IsCurrent = false;
                    currentDraft.ReadOnly = true;
                    _context.Update(currentDraft);
                }
            }

            var archivalEntityDraft = new ArchivalEntityDraft()
            {
                IsCurrent = true,
                ReadOnly = false,
                SystemIdentifier = model.SystemIdentifier!.Value,
                ArchiveId = model.ArchiveId!.Value,
                FundDraftId = model.FundDraftId,
                FundSystemIdentifier = model.FundSystemIdentifier!.Value,
                InventoryDraftId = model.InventoryDraftId,
                InventorySystemIdentifier = model.InventorySystemIdentifier!.Value,
                Number = model.Number,
                NumberArray = model.NumberArray,
                NumberNumeric = model.NumberNumeric,
                DescriptionLevelCode = model.DescriptionLevelCode,
                Title = model.Title,
                ApproxmateChronologicalScope = model.ApproximateChronologicalScope,
                Location = model.Location,
                Bytes = model.Bytes,
                SheetCount = model.SheetCount,
                TapeCount = model.TapeCount,
                MicrofilmCount = model.MicrofilmCount,
                FrameCount = model.FrameCount,
                VideoTapeCount = model.VideoTapeCount,
                DigitalDeviceCount = model.DigitalDeviceCount,
                OtherMetrics = model.OtherMetrics,
                SizeCm = model.SizeCm,
                Scaling = model.Scaling,
                Description = model.Description,
                DocumentsAccessDescription = model.DocumentsAccessDescription,
                Features = model.Features,
                Condition = model.Condition,
                MicrofilmedCopyCount = model.MicrofilmedCopyCount,
                DigitizedCopyCount = model.DigitizedCopyCount,
                PaperCopyCount = model.PaperCopyCount,
                NegativeFrameCount = model.NegativeFrameCount,
                PositiveFrameCount = model.PositiveFrameCount,
                OtherCopyCount = model.OtherCopyCount,
                Notes = model.Notes,
                EnrolledLinearMeters = model.EnrolledLinearMeters,
                EnrolledDocumentCount = model.EnrolledDocumentCount,
                DeductedDocumentCount = model.DeductedDocumentCount,
                DeductedLinearMeters = model.DeductedLinearMeters,
                DeductedBytes = model.DeductedBytes,
                StartDateYear = model.StartDateYear,
                StartDateMonth = model.StartDateMonth,
                StartDateDay = model.StartDateDay,
                EndDateYear = model.EndDateYear,
                EndDateMonth = model.EndDateMonth,
                EndDateDay = model.EndDateDay,
                StatusCode = model.StatusCode,
                AvailabilityStatusCode = model.AvailabilityStatusCode,
                HasExternalSource = model.HasExternalSource,
                ExternalIdentifier = model.ExternalIdentifier,
                IsImported = model.IsImported,
                DescriptionAuthor = model.DescriptionAuthor,
                Author = model.Author,
                Cypher = model.Cypher,
                TextDocsCount = model.TextDocsCount,
                GraphicalDocsCount = model.GraphicalDocsCount,
                Phase = model.Phase,
                Part = model.Part,
                Stage = model.Stage,
                OtherLanguage = model.OtherLanguage,
                ClassificationSchemeIndex = model.ClassificationSchemeIndex,
            };

            if (!model.AvailabilityStatusCode.HasValue)
            {
                archivalEntityDraft.AvailabilityStatusCode = (int)Shared.AvailabilityStatus.Enrollment;
            }

            if (model.HasExternalSource)
                archivalEntityDraft.ExternalSourceUpdatedOn = DateTime.UtcNow;

            _context.ArchivalEntityDrafts.Add(archivalEntityDraft);
            await _context.SaveAsync("Archival entity draft created");

            if (model.OriginalityCodes?.Count() > 0)
            {
                var originalityValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.OriginalityCodes, null, Shared.NomenclatureCode.Originality,
                    archivalEntityDraft.Id, BusinessObjectType.ArchivalEntity, true);

                if (originalityValues != null)
                {
                    _context.NomenclatureValues.AddRange(originalityValues!);
                }
            }
            if (model.CreationMethodCodes?.Count() > 0)
            {
                var creationMethodValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.CreationMethodCodes, null, Shared.NomenclatureCode.CreationMethod,
                    archivalEntityDraft.Id, BusinessObjectType.ArchivalEntity, true);

                if (creationMethodValues != null)
                {
                    _context.NomenclatureValues.AddRange(creationMethodValues!);
                }
            }
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, null, Shared.NomenclatureCode.Language,
                    archivalEntityDraft.Id, BusinessObjectType.ArchivalEntity, true);

                if (languageValues != null)
                {
                    _context.NomenclatureValues.AddRange(languageValues!);
                }
            }
            await _context.SaveAsync("Archival entity draft created");

            return archivalEntityDraft.SystemIdentifier;
        }

        public async Task<OperationResult> CreateDraftAsync(ArchivalEntityDraftModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var archivalEntitySysId = await ((IArchivalEntityServiceBase)this).CreateDraftInternalAsync(model);

                transaction.Commit();
                return OperationResult.Succeed(archivalEntitySysId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        async Task<Guid> IArchivalEntityServiceBase.CreateArchivalEntityInternalAsync(ArchivalEntityModel model, Guid? createdBy, DateTime? createdOn)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }
            if (!model.HasExternalSource && !model.SystemIdentifier.HasValue)
            {
                throw new SystemIdentifierNullException(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            if (!model.SystemIdentifier.HasValue)
            {
                model.SystemIdentifier = Guid.NewGuid();
            }

            var archivalEntity = new ArchivalEntity()
            {
                SystemIdentifier = model.SystemIdentifier!.Value,
                ArchiveId = model.ArchiveId!.Value,
                FundSystemIdentifier = model.FundSystemIdentifier!.Value,
                InventorySystemIdentifier = model.InventorySystemIdentifier!.Value,
                Number = model.Number,
                NumberNumeric = model.NumberNumeric,
                NumberArray = model.NumberArray,
                DescriptionLevelCode = model.DescriptionLevelCode,
                Title = model.Title,
                ApproxmateChronologicalScope = model.ApproximateChronologicalScope,
                Location = model.Location,
                Bytes = model.Bytes,
                SheetCount = model.SheetCount,
                TapeCount = model.TapeCount,
                MicrofilmCount = model.MicrofilmCount,
                FrameCount = model.FrameCount,
                VideoTapeCount = model.VideoTapeCount,
                DigitalDeviceCount = model.DigitalDeviceCount,
                OtherMetrics = model.OtherMetrics,
                SizeCm = model.SizeCm,
                Scaling = model.Scaling,
                Description = model.Description,
                DocumentsAccessDescription = model.DocumentsAccessDescription,
                Features = model.Features,
                Condition = model.Condition,
                MicrofilmedCopyCount = model.MicrofilmedCopyCount,
                DigitizedCopyCount = model.DigitizedCopyCount,
                PaperCopyCount = model.PaperCopyCount,
                NegativeFrameCount = model.NegativeFrameCount,
                PositiveFrameCount = model.PositiveFrameCount,
                OtherCopyCount = model.OtherCopyCount,
                Notes = model.Notes,
                EnrolledLinearMeters = model.EnrolledLinearMeters,
                EnrolledDocumentCount = model.EnrolledDocumentCount,
                DeductedDocumentCount = model.DeductedDocumentCount,
                DeductedLinearMeters = model.DeductedLinearMeters,
                DeductedBytes = model.DeductedBytes,
                StartDateYear = model.StartDateYear,
                StartDateMonth = model.StartDateMonth,
                StartDateDay = model.StartDateDay,
                EndDateYear = model.EndDateYear,
                EndDateMonth = model.EndDateMonth,
                EndDateDay = model.EndDateDay,
                StatusCode = model.StatusCode,
                AvailabilityStatusCode = model.AvailabilityStatusCode,
                HasExternalSource = model.HasExternalSource,
                ExternalIdentifier = model.ExternalIdentifier,
                IsImported = model.IsImported,
                DescriptionAuthor = model.DescriptionAuthor,
                Author = model.Author,
                Cypher = model.Cypher,
                TextDocsCount = model.TextDocsCount,
                GraphicalDocsCount = model.GraphicalDocsCount,
                Phase = model.Phase,
                Part = model.Part,
                Stage = model.Stage,
                OtherLanguage = model.OtherLanguage,
                ClassificationSchemeIndex = model.ClassificationSchemeIndex,
            };

            if (!model.AvailabilityStatusCode.HasValue)
            {
                archivalEntity.AvailabilityStatusCode = (int)Shared.AvailabilityStatus.Enrollment;
            }

            if (model.HasExternalSource)
                archivalEntity.ExternalSourceUpdatedOn = DateTime.UtcNow;

            bool overwriteCreated = createdBy.HasValue && createdOn.HasValue;
            if (overwriteCreated)
            {
                archivalEntity.CreatedBy = createdBy;
                archivalEntity.CreatedOn = createdOn;
            }

            _context.ArchivalEntities.Add(archivalEntity);
            await _context.SaveAsync("Archival entity created", overwriteCreated);

            if (model.OriginalityCodes?.Count() > 0)
            {
                var originalityValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.OriginalityCodes, null, Shared.NomenclatureCode.Originality,
                    archivalEntity.Id, BusinessObjectType.ArchivalEntity, false,
                    overwriteCreated, createdBy, createdOn);

                if (originalityValues != null)
                {
                    _context.NomenclatureValues.AddRange(originalityValues!);
                }
            }
            if (model.CreationMethodCodes?.Count() > 0)
            {
                var creationMethodValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.CreationMethodCodes, null, Shared.NomenclatureCode.CreationMethod,
                    archivalEntity.Id, BusinessObjectType.ArchivalEntity, false,
                    overwriteCreated, createdBy, createdOn);

                if (creationMethodValues != null)
                {
                    _context.NomenclatureValues.AddRange(creationMethodValues!);
                }
            }
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, null, Shared.NomenclatureCode.Language,
                    archivalEntity.Id, BusinessObjectType.ArchivalEntity, false,
                    overwriteCreated, createdBy, createdOn);

                if (languageValues != null)
                {
                    _context.NomenclatureValues.AddRange(languageValues!);
                }
            }
            await _context.SaveAsync("Archival entity created", overwriteCreated);

            return archivalEntity.SystemIdentifier;
        }

        public async Task<OperationResult> CreateArchivalEntityAsync(ArchivalEntityModel model)
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
                var archivalEntitySysId = await ((IArchivalEntityServiceBase)this).CreateArchivalEntityInternalAsync(model);

                transaction.Commit();
                return OperationResult.Succeed(archivalEntitySysId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        async Task<Guid> IArchivalEntityServiceBase.CreateOrUpdateArchivalEntityFromDraftInternalAsync(Guid sysId, bool overwriteCreatedFromDraft, bool overwriteModifiedFromDraft)
        {
            var archivalEntityDraft = await GetCurrentDraftAsync(sysId);
            if (archivalEntityDraft == null)
            {
                throw new ItemDraftNotCurrentException(_localizer.GetString("Error_DraftNotCurrent").ToString(), sysId.ToString());
            }

            Guid? createdBy = null;
            Guid? updatedBy = null;
            DateTime? createdOn = null;
            DateTime? updatedOn = null;

            if (overwriteCreatedFromDraft)
            {
                createdBy = archivalEntityDraft.CreatedBy;
                createdOn = archivalEntityDraft.CreatedOn;
            }
            if (overwriteModifiedFromDraft)
            {
                updatedBy = archivalEntityDraft.UpdatedBy ?? archivalEntityDraft.CreatedBy;
                updatedOn = archivalEntityDraft.UpdatedOn ?? archivalEntityDraft.CreatedOn;
            }

            var archivalEntity =
                await _context.ArchivalEntities
                .Where(ae => ae.SystemIdentifier == sysId && !ae.Deleted)
                .Select(ae => new ArchivalEntityModel()
                {
                    Id = ae.Id,
                    SystemIdentifier = ae.SystemIdentifier,
                    ArchiveId = ae.ArchiveId,
                    FundSystemIdentifier = ae.FundSystemIdentifier,
                    InventorySystemIdentifier = ae.InventorySystemIdentifier,
                    StatusCode = ae.StatusCode!,
                    DescriptionLevelCode = ae.DescriptionLevelCode!,
                    AvailabilityStatusCode = ae.AvailabilityStatusCode,
                    Number = ae.Number,
                    NumberNumeric = ae.NumberNumeric,
                    NumberArray = ae.NumberArray,
                    Title = ae.Title,
                    ApproximateChronologicalScope = ae.ApproxmateChronologicalScope,
                    HasNoChronologicalScope = ae.HasNoChronologicalScope,
                    StartDateDay = ae.StartDateDay,
                    StartDateMonth = ae.StartDateMonth,
                    StartDateYear = ae.StartDateYear,
                    EndDateDay = ae.EndDateDay,
                    EndDateMonth = ae.EndDateMonth,
                    EndDateYear = ae.EndDateYear,
                    Author = ae.Author,
                    Condition = ae.Condition,
                    Description = ae.Description,
                    DigitalDeviceCount = ae.DigitalDeviceCount,
                    DigitizedCopyCount = ae.DigitizedCopyCount,
                    Features = ae.Features,
                    FrameCount = ae.FrameCount,
                    Location = ae.Location,
                    MicrofilmCount = ae.MicrofilmCount,
                    MicrofilmedCopyCount = ae.MicrofilmedCopyCount,
                    OtherCopyCount = ae.OtherCopyCount,
                    PaperCopyCount = ae.PaperCopyCount,
                    Scaling = ae.Scaling,
                    SheetCount = ae.SheetCount,
                    SizeCm = ae.SizeCm,
                    TapeCount = ae.TapeCount,
                    VideoTapeCount = ae.VideoTapeCount,
                    DeductedBytes = ae.DeductedBytes,
                    DeductedDocumentCount = ae.DeductedDocumentCount,
                    DeductedLinearMeters = ae.DeductedLinearMeters,
                    EnrolledBytes = ae.EnrolledBytes,
                    EnrolledDocumentCount = ae.EnrolledDocumentCount,
                    EnrolledLinearMeters = ae.EnrolledLinearMeters,
                    DocumentsAccessDescription = ae.DocumentsAccessDescription,
                    OtherMetrics = ae.OtherMetrics,
                    Notes = ae.Notes,
                    Bytes = ae.Bytes,
                    NegativeFrameCount = ae.NegativeFrameCount,
                    PositiveFrameCount = ae.PositiveFrameCount,
                    HasExternalSource = ae.HasExternalSource,
                    ExternalIdentifier = ae.ExternalIdentifier,
                    IsImported = ae.IsImported,
                    DescriptionAuthor = ae.DescriptionAuthor,
                    Cypher = ae.Cypher,
                    TextDocsCount = ae.TextDocsCount,
                    GraphicalDocsCount = ae.GraphicalDocsCount,
                    Phase = ae.Phase,
                    Part = ae.Part,
                    Stage = ae.Stage,
                    OtherLanguage = ae.OtherLanguage,
                    ClassificationSchemeIndex = ae.ClassificationSchemeIndex,

                    CreationMethodCodes = _nomenclatureService.GetEntityNomenclatureCodes(ae.Id, BusinessObjectType.ArchivalEntity, false, Shared.NomenclatureCode.CreationMethod),
                    OriginalityCodes = _nomenclatureService.GetEntityNomenclatureCodes(ae.Id, BusinessObjectType.ArchivalEntity, false, Shared.NomenclatureCode.Originality),
                    LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(ae.Id, BusinessObjectType.ArchivalEntity, false, Shared.NomenclatureCode.Language),
                })
                .SingleOrDefaultAsync();

            if (archivalEntity != null)
            {
                archivalEntity.SystemIdentifier = archivalEntityDraft.SystemIdentifier;
                archivalEntity.ArchiveId = archivalEntityDraft.ArchiveId;
                archivalEntity.FundSystemIdentifier = archivalEntityDraft.FundSystemIdentifier;
                archivalEntity.InventorySystemIdentifier = archivalEntityDraft.InventorySystemIdentifier;
                archivalEntity.StatusCode = archivalEntityDraft.StatusCode;
                archivalEntity.DescriptionLevelCode = archivalEntityDraft.DescriptionLevelCode;
                archivalEntity.AvailabilityStatusCode = archivalEntityDraft.AvailabilityStatusCode;
                archivalEntity.Number = archivalEntityDraft.Number;
                archivalEntity.NumberNumeric = archivalEntityDraft.NumberNumeric;
                archivalEntity.NumberArray = archivalEntityDraft.NumberArray;
                archivalEntity.Title = archivalEntityDraft.Title;
                archivalEntity.ApproximateChronologicalScope = archivalEntityDraft.ApproximateChronologicalScope;
                archivalEntity.HasNoChronologicalScope = archivalEntityDraft.HasNoChronologicalScope;
                archivalEntity.StartDateDay = archivalEntityDraft.StartDateDay;
                archivalEntity.StartDateMonth = archivalEntityDraft.StartDateMonth;
                archivalEntity.StartDateYear = archivalEntityDraft.StartDateYear;
                archivalEntity.EndDateDay = archivalEntityDraft.EndDateDay;
                archivalEntity.EndDateMonth = archivalEntityDraft.EndDateMonth;
                archivalEntity.EndDateYear = archivalEntityDraft.EndDateYear;
                archivalEntity.Author = archivalEntityDraft.Author;
                archivalEntity.Condition = archivalEntityDraft.Condition;
                archivalEntity.Description = archivalEntityDraft.Description;
                archivalEntity.DigitalDeviceCount = archivalEntityDraft.DigitalDeviceCount;
                archivalEntity.DigitizedCopyCount = archivalEntityDraft.DigitizedCopyCount;
                archivalEntity.Features = archivalEntityDraft.Features;
                archivalEntity.FrameCount = archivalEntityDraft.FrameCount;
                archivalEntity.Location = archivalEntityDraft.Location;
                archivalEntity.MicrofilmCount = archivalEntityDraft.MicrofilmCount;
                archivalEntity.MicrofilmedCopyCount = archivalEntityDraft.MicrofilmedCopyCount;
                archivalEntity.OtherCopyCount = archivalEntityDraft.OtherCopyCount;
                archivalEntity.PaperCopyCount = archivalEntityDraft.PaperCopyCount;
                archivalEntity.Scaling = archivalEntityDraft.Scaling;
                archivalEntity.SheetCount = archivalEntityDraft.SheetCount;
                archivalEntity.SizeCm = archivalEntityDraft.SizeCm;
                archivalEntity.TapeCount = archivalEntityDraft.TapeCount;
                archivalEntity.VideoTapeCount = archivalEntityDraft.VideoTapeCount;
                archivalEntity.DeductedBytes = archivalEntityDraft.DeductedBytes;
                archivalEntity.DeductedDocumentCount = archivalEntityDraft.DeductedDocumentCount;
                archivalEntity.DeductedLinearMeters = archivalEntityDraft.DeductedLinearMeters;
                archivalEntity.EnrolledBytes = archivalEntityDraft.EnrolledBytes;
                archivalEntity.EnrolledDocumentCount = archivalEntityDraft.EnrolledDocumentCount;
                archivalEntity.EnrolledLinearMeters = archivalEntityDraft.EnrolledLinearMeters;
                archivalEntity.DocumentsAccessDescription = archivalEntityDraft.DocumentsAccessDescription;
                archivalEntity.OtherMetrics = archivalEntityDraft.OtherMetrics;
                archivalEntity.Notes = archivalEntityDraft.Notes;
                archivalEntity.Bytes = archivalEntityDraft.Bytes;
                archivalEntity.NegativeFrameCount = archivalEntityDraft.NegativeFrameCount;
                archivalEntity.PositiveFrameCount = archivalEntityDraft.PositiveFrameCount;
                archivalEntity.HasExternalSource = archivalEntityDraft.HasExternalSource;
                archivalEntity.ExternalIdentifier = archivalEntityDraft.ExternalIdentifier;
                archivalEntity.CreationMethodCodes = archivalEntityDraft.CreationMethodCodes;
                archivalEntity.LanguageCodes = archivalEntityDraft.LanguageCodes;
                archivalEntity.OriginalityCodes = archivalEntityDraft.OriginalityCodes;
                archivalEntity.IsImported = archivalEntityDraft.IsImported;
                archivalEntity.DescriptionAuthor = archivalEntityDraft.DescriptionAuthor;
                archivalEntity.Cypher = archivalEntityDraft.Cypher;
                archivalEntity.TextDocsCount = archivalEntityDraft.TextDocsCount;
                archivalEntity.GraphicalDocsCount = archivalEntityDraft.GraphicalDocsCount;
                archivalEntity.Phase = archivalEntityDraft.Phase;
                archivalEntity.Part = archivalEntityDraft.Part;
                archivalEntity.Stage = archivalEntityDraft.Stage;
                archivalEntity.OtherLanguage = archivalEntityDraft.OtherLanguage;
                archivalEntity.ClassificationSchemeIndex = archivalEntityDraft.ClassificationSchemeIndex;

                //await ((IArchivalEntityServiceBase)this).UpdateArchivalEntityInternalAsync(archivalEntity);
                await ((IArchivalEntityServiceBase)this).UpdateArchivalEntityInternalAsync(archivalEntity, updatedBy, updatedOn);
            }
            else
            {
                archivalEntity = new ArchivalEntityModel()
                {
                    SystemIdentifier = archivalEntityDraft.SystemIdentifier,
                    ArchiveId = archivalEntityDraft.ArchiveId,
                    FundSystemIdentifier = archivalEntityDraft.FundSystemIdentifier,
                    InventorySystemIdentifier = archivalEntityDraft.InventorySystemIdentifier,
                    StatusCode = archivalEntityDraft.StatusCode,
                    DescriptionLevelCode = archivalEntityDraft.DescriptionLevelCode,
                    AvailabilityStatusCode = archivalEntityDraft.AvailabilityStatusCode,
                    Number = archivalEntityDraft.Number,
                    NumberNumeric = archivalEntityDraft.NumberNumeric,
                    NumberArray = archivalEntityDraft.NumberArray,
                    Title = archivalEntityDraft.Title,
                    ApproximateChronologicalScope = archivalEntityDraft.ApproximateChronologicalScope,
                    HasNoChronologicalScope = archivalEntityDraft.HasNoChronologicalScope,
                    StartDateDay = archivalEntityDraft.StartDateDay,
                    StartDateMonth = archivalEntityDraft.StartDateMonth,
                    StartDateYear = archivalEntityDraft.StartDateYear,
                    EndDateDay = archivalEntityDraft.EndDateDay,
                    EndDateMonth = archivalEntityDraft.EndDateMonth,
                    EndDateYear = archivalEntityDraft.EndDateYear,
                    Author = archivalEntityDraft.Author,
                    Condition = archivalEntityDraft.Condition,
                    Description = archivalEntityDraft.Description,
                    DigitalDeviceCount = archivalEntityDraft.DigitalDeviceCount,
                    DigitizedCopyCount = archivalEntityDraft.DigitizedCopyCount,
                    Features = archivalEntityDraft.Features,
                    FrameCount = archivalEntityDraft.FrameCount,
                    Location = archivalEntityDraft.Location,
                    MicrofilmCount = archivalEntityDraft.MicrofilmCount,
                    MicrofilmedCopyCount = archivalEntityDraft.MicrofilmedCopyCount,
                    OtherCopyCount = archivalEntityDraft.OtherCopyCount,
                    PaperCopyCount = archivalEntityDraft.PaperCopyCount,
                    Scaling = archivalEntityDraft.Scaling,
                    SheetCount = archivalEntityDraft.SheetCount,
                    SizeCm = archivalEntityDraft.SizeCm,
                    TapeCount = archivalEntityDraft.TapeCount,
                    VideoTapeCount = archivalEntityDraft.VideoTapeCount,
                    DeductedBytes = archivalEntityDraft.DeductedBytes,
                    DeductedDocumentCount = archivalEntityDraft.DeductedDocumentCount,
                    DeductedLinearMeters = archivalEntityDraft.DeductedLinearMeters,
                    EnrolledBytes = archivalEntityDraft.EnrolledBytes,
                    EnrolledDocumentCount = archivalEntityDraft.EnrolledDocumentCount,
                    EnrolledLinearMeters = archivalEntityDraft.EnrolledLinearMeters,
                    DocumentsAccessDescription = archivalEntityDraft.DocumentsAccessDescription,
                    OtherMetrics = archivalEntityDraft.OtherMetrics,
                    Notes = archivalEntityDraft.Notes,
                    Bytes = archivalEntityDraft.Bytes,
                    NegativeFrameCount = archivalEntityDraft.NegativeFrameCount,
                    PositiveFrameCount = archivalEntityDraft.PositiveFrameCount,
                    HasExternalSource = archivalEntityDraft.HasExternalSource,
                    ExternalIdentifier = archivalEntityDraft.ExternalIdentifier,
                    CreationMethodCodes = archivalEntityDraft.CreationMethodCodes,
                    LanguageCodes = archivalEntityDraft.LanguageCodes,
                    OriginalityCodes = archivalEntityDraft.OriginalityCodes,
                    IsImported = archivalEntityDraft.IsImported,
                    DescriptionAuthor = archivalEntityDraft.DescriptionAuthor,
                    Cypher = archivalEntityDraft.Cypher,
                    TextDocsCount = archivalEntityDraft.TextDocsCount,
                    GraphicalDocsCount = archivalEntityDraft.GraphicalDocsCount,
                    Phase = archivalEntityDraft.Phase,
                    Part = archivalEntityDraft.Part,
                    Stage = archivalEntityDraft.Stage,
                    OtherLanguage = archivalEntityDraft.OtherLanguage,
                    ClassificationSchemeIndex = archivalEntityDraft.ClassificationSchemeIndex,
                };

                //await ((IArchivalEntityServiceBase)this).CreateArchivalEntityInternalAsync(archivalEntity);
                await ((IArchivalEntityServiceBase)this).CreateArchivalEntityInternalAsync(archivalEntity, createdBy, createdOn);
            }

            var modifiedArchivalEntityDraft = new ArchivalEntityDraftModel()
            {
                Id = archivalEntityDraft.Id,
                IsCurrent = false,
                ReadOnly = true,
                SystemIdentifier = archivalEntityDraft.SystemIdentifier,
                ArchiveId = archivalEntityDraft.ArchiveId,
                FundDraftId = archivalEntityDraft.FundDraftId,
                FundSystemIdentifier = archivalEntityDraft.FundSystemIdentifier!.Value,
                InventoryDraftId = archivalEntityDraft.InventoryDraftId,
                InventorySystemIdentifier = archivalEntityDraft.InventorySystemIdentifier,
                StatusCode = archivalEntityDraft.StatusCode,
                DescriptionLevelCode = archivalEntityDraft.DescriptionLevelCode,
                AvailabilityStatusCode = archivalEntityDraft.AvailabilityStatusCode,
                Number = archivalEntityDraft.Number,
                NumberNumeric = archivalEntityDraft.NumberNumeric,
                NumberArray = archivalEntityDraft.NumberArray,
                Title = archivalEntityDraft.Title,
                ApproximateChronologicalScope = archivalEntityDraft.ApproximateChronologicalScope,
                HasNoChronologicalScope = archivalEntityDraft.HasNoChronologicalScope,
                StartDateDay = archivalEntityDraft.StartDateDay,
                StartDateMonth = archivalEntityDraft.StartDateMonth,
                StartDateYear = archivalEntityDraft.StartDateYear,
                EndDateDay = archivalEntityDraft.EndDateDay,
                EndDateMonth = archivalEntityDraft.EndDateMonth,
                EndDateYear = archivalEntityDraft.EndDateYear,
                Author = archivalEntityDraft.Author,
                Condition = archivalEntityDraft.Condition,
                Description = archivalEntityDraft.Description,
                DigitalDeviceCount = archivalEntityDraft.DigitalDeviceCount,
                DigitizedCopyCount = archivalEntityDraft.DigitizedCopyCount,
                Features = archivalEntityDraft.Features,
                FrameCount = archivalEntityDraft.FrameCount,
                Location = archivalEntityDraft.Location,
                MicrofilmCount = archivalEntityDraft.MicrofilmCount,
                MicrofilmedCopyCount = archivalEntityDraft.MicrofilmedCopyCount,
                OtherCopyCount = archivalEntityDraft.OtherCopyCount,
                PaperCopyCount = archivalEntityDraft.PaperCopyCount,
                Scaling = archivalEntityDraft.Scaling,
                SheetCount = archivalEntityDraft.SheetCount,
                SizeCm = archivalEntityDraft.SizeCm,
                TapeCount = archivalEntityDraft.TapeCount,
                VideoTapeCount = archivalEntityDraft.VideoTapeCount,
                DeductedBytes = archivalEntityDraft.DeductedBytes,
                DeductedDocumentCount = archivalEntityDraft.DeductedDocumentCount,
                DeductedLinearMeters = archivalEntityDraft.DeductedLinearMeters,
                EnrolledBytes = archivalEntityDraft.EnrolledBytes,
                EnrolledDocumentCount = archivalEntityDraft.EnrolledDocumentCount,
                EnrolledLinearMeters = archivalEntityDraft.EnrolledLinearMeters,
                DocumentsAccessDescription = archivalEntityDraft.DocumentsAccessDescription,
                OtherMetrics = archivalEntityDraft.OtherMetrics,
                Notes = archivalEntityDraft.Notes,
                Bytes = archivalEntityDraft.Bytes,
                NegativeFrameCount = archivalEntityDraft.NegativeFrameCount,
                PositiveFrameCount = archivalEntityDraft.PositiveFrameCount,
                HasExternalSource = archivalEntityDraft.HasExternalSource,
                ExternalIdentifier = archivalEntityDraft.ExternalIdentifier,
                CreationMethodCodes = archivalEntityDraft.CreationMethodCodes,
                LanguageCodes = archivalEntityDraft.LanguageCodes,
                OriginalityCodes = archivalEntityDraft.OriginalityCodes,
                IsImported = archivalEntityDraft.IsImported,
                DescriptionAuthor = archivalEntityDraft.DescriptionAuthor,
                Cypher = archivalEntityDraft.Cypher,
                TextDocsCount = archivalEntityDraft.TextDocsCount,
                GraphicalDocsCount = archivalEntityDraft.GraphicalDocsCount,
                Phase = archivalEntityDraft.Phase,
                Part = archivalEntityDraft.Part,
                Stage = archivalEntityDraft.Stage,
                OtherLanguage = archivalEntityDraft.OtherLanguage,
                ClassificationSchemeIndex = archivalEntityDraft.ClassificationSchemeIndex,
            };

            await ((IArchivalEntityServiceBase)this).UpdateDraftInternalAsync(modifiedArchivalEntityDraft);

            return sysId;
        }

        public async Task<OperationResult> CreateOrUpdateArchivalEntityFromDraftAsync(Guid sysId)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await ((IArchivalEntityServiceBase)this).CreateOrUpdateArchivalEntityFromDraftInternalAsync(sysId);

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

        async Task<Guid> IArchivalEntityServiceBase.UpdateDraftInternalAsync(ArchivalEntityDraftModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            if (!model.SystemIdentifier.HasValue)
            {
                throw new SystemIdentifierNullException(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            var currentArchivalEntityDraft = await GetCurrentDraftAsync(model.SystemIdentifier.Value);
            if (currentArchivalEntityDraft == null)
            {
                return await ((IArchivalEntityServiceBase)this).CreateDraftInternalAsync(model);
            }

            bool isReadOnly = await IsReadOnlyDraftAsync(new ArchivalEntityDraftModel() { Id = currentArchivalEntityDraft.Id });
            if (isReadOnly)
            {
                return await ((IArchivalEntityServiceBase)this).CreateDraftInternalAsync(model);
            }

            //var archivalEntityDraft = await _context.ArchivalEntityDrafts.FindAsync(model.Id);
            var archivalEntityDraft = await _context.ArchivalEntityDrafts.FindAsync(currentArchivalEntityDraft.Id);
            if (archivalEntityDraft == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), model.Id!.Value.ToString());
            }

            archivalEntityDraft.IsCurrent = model.IsCurrent;
            archivalEntityDraft.ReadOnly = model.ReadOnly;
            archivalEntityDraft.SystemIdentifier = model.SystemIdentifier!.Value;
            archivalEntityDraft.ArchiveId = model.ArchiveId!.Value;
            archivalEntityDraft.FundDraftId = model.FundDraftId;
            archivalEntityDraft.FundSystemIdentifier = model.FundSystemIdentifier!.Value;
            archivalEntityDraft.InventoryDraftId = model.InventoryDraftId;
            archivalEntityDraft.InventorySystemIdentifier = model.InventorySystemIdentifier!.Value;
            archivalEntityDraft.Number = model.Number;
            archivalEntityDraft.NumberNumeric = model.NumberNumeric;
            archivalEntityDraft.NumberArray = model.NumberArray;
            archivalEntityDraft.DescriptionLevelCode = model.DescriptionLevelCode;
            archivalEntityDraft.Title = model.Title;
            archivalEntityDraft.ApproxmateChronologicalScope = model.ApproximateChronologicalScope;
            archivalEntityDraft.Location = model.Location;
            archivalEntityDraft.Bytes = model.Bytes;
            archivalEntityDraft.SheetCount = model.SheetCount;
            archivalEntityDraft.TapeCount = model.TapeCount;
            archivalEntityDraft.MicrofilmCount = model.MicrofilmCount;
            archivalEntityDraft.FrameCount = model.FrameCount;
            archivalEntityDraft.VideoTapeCount = model.VideoTapeCount;
            archivalEntityDraft.DigitalDeviceCount = model.DigitalDeviceCount;
            archivalEntityDraft.OtherMetrics = model.OtherMetrics;
            archivalEntityDraft.SizeCm = model.SizeCm;
            archivalEntityDraft.Scaling = model.Scaling;
            archivalEntityDraft.Description = model.Description;
            archivalEntityDraft.DocumentsAccessDescription = model.DocumentsAccessDescription;
            archivalEntityDraft.Features = model.Features;
            archivalEntityDraft.Condition = model.Condition;
            archivalEntityDraft.MicrofilmedCopyCount = model.MicrofilmedCopyCount;
            archivalEntityDraft.DigitizedCopyCount = model.DigitizedCopyCount;
            archivalEntityDraft.PaperCopyCount = model.PaperCopyCount;
            archivalEntityDraft.NegativeFrameCount = model.NegativeFrameCount;
            archivalEntityDraft.PositiveFrameCount = model.PositiveFrameCount;
            archivalEntityDraft.OtherCopyCount = model.OtherCopyCount;
            archivalEntityDraft.Notes = model.Notes;
            archivalEntityDraft.EnrolledLinearMeters = model.EnrolledLinearMeters;
            archivalEntityDraft.EnrolledDocumentCount = model.EnrolledDocumentCount;
            archivalEntityDraft.DeductedDocumentCount = model.DeductedDocumentCount;
            archivalEntityDraft.DeductedLinearMeters = model.DeductedLinearMeters;
            archivalEntityDraft.DeductedBytes = model.DeductedBytes;
            archivalEntityDraft.StartDateYear = model.StartDateYear;
            archivalEntityDraft.StartDateMonth = model.StartDateMonth;
            archivalEntityDraft.StartDateDay = model.StartDateDay;
            archivalEntityDraft.EndDateYear = model.EndDateYear;
            archivalEntityDraft.EndDateMonth = model.EndDateMonth;
            archivalEntityDraft.EndDateDay = model.EndDateDay;
            archivalEntityDraft.StatusCode = model.StatusCode;
            archivalEntityDraft.AvailabilityStatusCode = model.AvailabilityStatusCode;
            archivalEntityDraft.HasExternalSource = model.HasExternalSource;
            archivalEntityDraft.ExternalIdentifier = model.ExternalIdentifier;
            archivalEntityDraft.IsImported = model.IsImported;
            archivalEntityDraft.DescriptionAuthor = model.DescriptionAuthor;
            archivalEntityDraft.Author = model.Author;
            archivalEntityDraft.Cypher = model.Cypher;
            archivalEntityDraft.TextDocsCount = model.TextDocsCount;
            archivalEntityDraft.GraphicalDocsCount = model.GraphicalDocsCount;
            archivalEntityDraft.Phase = model.Phase;
            archivalEntityDraft.Part = model.Part;
            archivalEntityDraft.Stage = model.Stage;
            archivalEntityDraft.OtherLanguage = model.OtherLanguage;
            archivalEntityDraft.ClassificationSchemeIndex = model.ClassificationSchemeIndex;

            if (model.HasExternalSource)
            {
                archivalEntityDraft.ExternalSourceUpdatedOn = DateTime.UtcNow;
            }

            _context.Update(archivalEntityDraft);

            var archivalEntityNomenclatureValues = _nomenclatureService.GetEntityNomenclatureValues(
                archivalEntityDraft.Id, BusinessObjectType.ArchivalEntity, true, null);

            //Update originality values
            if (model.OriginalityCodes?.Count() > 0)
            {
                var originalityValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.OriginalityCodes, archivalEntityNomenclatureValues, Shared.NomenclatureCode.Originality,
                    archivalEntityDraft.Id, BusinessObjectType.ArchivalEntity, true);

                if (originalityValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(originalityValuesToAdd);
                }
            }

            var originalityValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.OriginalityCodes, archivalEntityNomenclatureValues, Shared.NomenclatureCode.Originality);

            if (originalityValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(originalityValuesToDelete);
            }

            //Update creation method values
            if (model.CreationMethodCodes?.Count() > 0)
            {
                var creationMethodValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.CreationMethodCodes, archivalEntityNomenclatureValues, Shared.NomenclatureCode.CreationMethod,
                    archivalEntityDraft.Id, BusinessObjectType.ArchivalEntity, true);

                if (creationMethodValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(creationMethodValuesToAdd);
                }
            }

            var creationMethodValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.CreationMethodCodes, archivalEntityNomenclatureValues, Shared.NomenclatureCode.CreationMethod);

            if (creationMethodValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(creationMethodValuesToDelete);
            }

            //Update language values
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, archivalEntityNomenclatureValues, Shared.NomenclatureCode.Language,
                    archivalEntityDraft.Id, BusinessObjectType.ArchivalEntity, true);

                if (languageValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(languageValuesToAdd);
                }
            }

            var languageValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.LanguageCodes, archivalEntityNomenclatureValues, Shared.NomenclatureCode.Language);

            if (languageValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(languageValuesToDelete);
            }

            await _context.SaveAsync("Archival entity draft updated");

            return archivalEntityDraft.SystemIdentifier;
        }

        public async Task<OperationResult> UpdateDraftAsync(ArchivalEntityDraftModel model)
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
                var archivalEntitySysId = await ((IArchivalEntityServiceBase)this).UpdateDraftInternalAsync(model);

                transaction.Commit();
                return OperationResult.Succeed(archivalEntitySysId);
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

        async Task<Guid> IArchivalEntityServiceBase.UpdateArchivalEntityInternalAsync(ArchivalEntityModel model, Guid? updatedBy, DateTime? updatedOn)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            if (!model.SystemIdentifier.HasValue)
            {
                throw new SystemIdentifierNullException(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            var archivalEntity = await _context.ArchivalEntities.FindAsync(model.Id);
            if (archivalEntity == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            archivalEntity.ArchiveId = model.ArchiveId!.Value;
            archivalEntity.FundSystemIdentifier = model.FundSystemIdentifier!.Value;
            archivalEntity.InventorySystemIdentifier = model.InventorySystemIdentifier!.Value;
            archivalEntity.Number = model.Number;
            archivalEntity.NumberNumeric = model.NumberNumeric;
            archivalEntity.NumberArray = model.NumberArray;
            archivalEntity.Title = model.Title;
            archivalEntity.DescriptionLevelCode = model.DescriptionLevelCode;
            archivalEntity.StatusCode = model.StatusCode;
            archivalEntity.AvailabilityStatusCode = model.AvailabilityStatusCode;
            archivalEntity.HasNoChronologicalScope = model.HasNoChronologicalScope;
            archivalEntity.StartDateYear = model.StartDateYear;
            archivalEntity.StartDateMonth = model.StartDateMonth;
            archivalEntity.StartDateDay = model.StartDateDay;
            archivalEntity.EndDateYear = model.EndDateYear;
            archivalEntity.EndDateMonth = model.EndDateMonth;
            archivalEntity.EndDateDay = model.EndDateDay;
            archivalEntity.ApproxmateChronologicalScope = model.ApproximateChronologicalScope;
            archivalEntity.Location = model.Location;
            archivalEntity.Bytes = model.Bytes;
            archivalEntity.SheetCount = model.SheetCount;
            archivalEntity.TapeCount = model.TapeCount;
            archivalEntity.MicrofilmCount = model.MicrofilmCount;
            archivalEntity.FrameCount = model.FrameCount;
            archivalEntity.VideoTapeCount = model.VideoTapeCount;
            archivalEntity.DigitalDeviceCount = model.DigitalDeviceCount;
            archivalEntity.OtherMetrics = model.OtherMetrics;
            archivalEntity.SizeCm = model.SizeCm;
            archivalEntity.Scaling = model.Scaling;
            archivalEntity.Description = model.Description;
            archivalEntity.DocumentsAccessDescription = model.DocumentsAccessDescription;
            archivalEntity.Features = model.Features;
            archivalEntity.Condition = model.Condition;
            archivalEntity.MicrofilmedCopyCount = model.MicrofilmedCopyCount;
            archivalEntity.DigitizedCopyCount = model.DigitizedCopyCount;
            archivalEntity.PaperCopyCount = model.PaperCopyCount;
            archivalEntity.NegativeFrameCount = model.NegativeFrameCount;
            archivalEntity.PositiveFrameCount = model.PositiveFrameCount;
            archivalEntity.OtherCopyCount = model.OtherCopyCount;
            archivalEntity.Notes = model.Notes;
            archivalEntity.EnrolledBytes = model.EnrolledBytes;
            archivalEntity.EnrolledDocumentCount = model.EnrolledDocumentCount;
            archivalEntity.EnrolledLinearMeters = model.EnrolledLinearMeters;
            archivalEntity.DeductedBytes = model.DeductedBytes;
            archivalEntity.DeductedDocumentCount = model.DeductedDocumentCount;
            archivalEntity.DeductedLinearMeters = model.DeductedLinearMeters;
            archivalEntity.HasExternalSource = model.HasExternalSource;
            archivalEntity.ExternalIdentifier = model.ExternalIdentifier;
            archivalEntity.DescriptionAuthor = model.DescriptionAuthor;
            archivalEntity.Cypher = model.Cypher;
            archivalEntity.TextDocsCount = model.TextDocsCount;
            archivalEntity.GraphicalDocsCount = model.GraphicalDocsCount;
            archivalEntity.Phase = model.Phase;
            archivalEntity.Part = model.Part;
            archivalEntity.Stage = model.Stage;
            archivalEntity.OtherLanguage = model.OtherLanguage;
            archivalEntity.ClassificationSchemeIndex = model.ClassificationSchemeIndex;


            if (model.HasExternalSource)
            {
                archivalEntity.ExternalSourceUpdatedOn = DateTime.UtcNow;
            }

            bool overwriteModified = updatedBy.HasValue && updatedOn.HasValue;
            if (overwriteModified)
            {
                archivalEntity.UpdatedBy = updatedBy;
                archivalEntity.UpdatedOn = updatedOn;
            }

            _context.Update(archivalEntity);

            var archivalEntityNomenclatureValues = _nomenclatureService.GetEntityNomenclatureValues(
                archivalEntity.Id, BusinessObjectType.ArchivalEntity, false, null);

            //Update originality values
            if (model.OriginalityCodes?.Count() > 0)
            {
                var originalityValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.OriginalityCodes, archivalEntityNomenclatureValues, Shared.NomenclatureCode.Originality,
                    archivalEntity.Id, BusinessObjectType.ArchivalEntity, false, overwriteModified, updatedBy, updatedOn);

                if (originalityValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(originalityValuesToAdd);
                }
            }

            var originalityValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.OriginalityCodes, archivalEntityNomenclatureValues, Shared.NomenclatureCode.Originality);

            if (originalityValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(originalityValuesToDelete);
            }


            //Update creation method values
            if (model.CreationMethodCodes?.Count() > 0)
            {
                var creationMethodValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.CreationMethodCodes, archivalEntityNomenclatureValues, Shared.NomenclatureCode.CreationMethod,
                    archivalEntity.Id, BusinessObjectType.ArchivalEntity, false, overwriteModified, updatedBy, updatedOn);

                if (creationMethodValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(creationMethodValuesToAdd);
                }
            }

            var creationMethodValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.CreationMethodCodes, archivalEntityNomenclatureValues, Shared.NomenclatureCode.CreationMethod);

            if (creationMethodValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(creationMethodValuesToDelete);
            }

            //Update language values
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, archivalEntityNomenclatureValues, Shared.NomenclatureCode.Language,
                    archivalEntity.Id, BusinessObjectType.ArchivalEntity, false, overwriteModified, updatedBy, updatedOn);

                if (languageValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(languageValuesToAdd);
                }
            }

            var languageValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.LanguageCodes, archivalEntityNomenclatureValues, Shared.NomenclatureCode.Language);

            if (languageValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(languageValuesToDelete);
            }

            await _context.SaveAsync("Archival entity updated", overwriteModified, overwriteModified);

            return archivalEntity.SystemIdentifier;
        }

        public async Task<OperationResult> UpdateArchivalEntityAsync(ArchivalEntityModel model)
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
                var archivalEntitySysId = await ((IArchivalEntityServiceBase)this).UpdateArchivalEntityInternalAsync(model);

                transaction.Commit();
                return OperationResult.Succeed(archivalEntitySysId);
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

        async System.Threading.Tasks.Task IArchivalEntityServiceBase.DeleteDraftInternalAsync(int id)
        {
            //TODO: Да се добави изтриването на всички нива под АЕ?
            var archivalEntityDraft = await _context.ArchivalEntityDrafts.FindAsync(id);
            if (archivalEntityDraft == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), id.ToString());
            }
            if (!archivalEntityDraft.IsCurrent)
            {
                throw new ItemDraftNotCurrentException(_localizer.GetString("Error_DraftNotCurrent").ToString(), id.ToString());
            }

            archivalEntityDraft.IsCurrent = false;
            archivalEntityDraft.ReadOnly = true;
            archivalEntityDraft.Deleted = true;
            archivalEntityDraft.DeletedOn = DateTime.UtcNow;
            archivalEntityDraft.DeletedBy = _userInfo.CurrentUserId;

            _context.Update(archivalEntityDraft);

            var nomValues = _nomenclatureService.GetEntityNomenclatureValues(archivalEntityDraft.Id, BusinessObjectType.ArchivalEntity, true, null);
            if (nomValues != null && nomValues.Count() > 0)
            {
                nomValues.ToList().ForEach(nv =>
                {
                    nv.Deleted = true;
                    nv.DeletedBy = _userInfo.CurrentUserId;
                    nv.DeletedOn = DateTime.UtcNow;
                });

                _context.NomenclatureValues.UpdateRange(nomValues);
            }

            await _context.SaveAsync("Archival entity draft deleted");
        }

        public async Task<OperationResult> DeleteDraftAsync(int id)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await ((IArchivalEntityServiceBase)this).DeleteDraftInternalAsync(id);

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

        async System.Threading.Tasks.Task IArchivalEntityServiceBase.DeleteArchivalEntityInternalAsync(Guid sysId)
        {
            //TODO: Да се добави изтриването на всички нива под АЕ?
            var archivalEntityDrafts =
                _context.ArchivalEntityDrafts
                .Where(ae => ae.SystemIdentifier == sysId && !ae.Deleted)
                .Select(ae => ae);

            await archivalEntityDrafts.ForEachAsync(ae =>
            {
                ae.IsCurrent = false;
                ae.ReadOnly = true;
                ae.Deleted = true;
                ae.DeletedBy = _userInfo.CurrentUserId;
                ae.DeletedOn = DateTime.UtcNow;
            });

            var draftsNomenclatureValues = _nomenclatureService.GetEntityNomenclatureValues(
                archivalEntityDrafts.Select(ae => ae.Id).ToList(), BusinessObjectType.ArchivalEntity, true, null);
            if (draftsNomenclatureValues != null && draftsNomenclatureValues.Count() > 0)
            {
                draftsNomenclatureValues.ToList().ForEach(nv =>
                {
                    nv.Deleted = true;
                    nv.DeletedBy = _userInfo.CurrentUserId;
                    nv.DeletedOn = DateTime.UtcNow;
                });

                _context.NomenclatureValues.UpdateRange(draftsNomenclatureValues);
            }

            var archivalEntity =
                await _context.ArchivalEntities
                .Where(inv => inv.SystemIdentifier == sysId && !inv.Deleted)
                .SingleOrDefaultAsync();

            if (archivalEntity != null)
            {
                archivalEntity.Deleted = true;
                archivalEntity.DeletedOn = DateTime.UtcNow;
                archivalEntity.DeletedBy = _userInfo.CurrentUserId;

                _context.Update(archivalEntity);

                var entityNomValues = _nomenclatureService.GetEntityNomenclatureValues(archivalEntity.Id, BusinessObjectType.ArchivalEntity, false, null);
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
            }

            await _context.SaveAsync("Archival entity deleted");
        }

        public async Task<OperationResult> DeleteArchivalEntityAsync(Guid sysId)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await ((IArchivalEntityServiceBase)this).DeleteArchivalEntityInternalAsync(sysId);

                transaction.Commit();
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<ArchivalEntityDisplayModel?> GetFromExternalSourceAsync(
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

            var archiveId = await _archiveService.GetArchiveIdByCodeAsync(result.ArchiveCode!.Value);
            if (!systemIdentifier.HasValue)
            {
                systemIdentifier = await GetSystemIdentifierByExternalIdentifierAsync(externalIdentifier);
            }
            if (!inventorySystemIdentifier.HasValue)
            {
                inventorySystemIdentifier = await _inventoryService.GetSystemIdentifierByExternalIdentifierAsync(result.InventoryExternalIdentifier!.Value);
            }
            if (!fundSystemIdentifier.HasValue)
            {
                fundSystemIdentifier = await _fundService.GetSystemIdentifierByExternalIdentifierAsync(result.FundExternalIdentifier!.Value);
            }


            ArchivalEntityDisplayModel model = new ArchivalEntityDisplayModel()
            {
                Id = result.Id,
                SystemIdentifier = systemIdentifier,
                IsDraft = false,
                HasExternalSource = result.HasExternalSource ?? false,
                ExternalIdentifier = result.ExternalIdentifier,
                ArchiveId = archiveId,
                ArchiveCode = result.ArchiveCode,
                ArchiveName = result.ArchiveName,
                FundSystemIdentifier = fundSystemIdentifier,
                FundHasExternalSource = result.FundHasExternalSource ?? false,
                FundExternalIdentifier = result.FundExternalIdentifier,
                FundNumber = result.FundNumber,
                InventorySystemIdentifier = inventorySystemIdentifier,
                InventoryHasExternalSource = result.InventoryHasExternalSource ?? false,
                InventoryExternalIdentifier = result.InventoryExternalIdentifier,
                InventoryNumber = result.InventoryNumber,
                Number = result.Number,
                Title = result.Title,
                StatusCode = result.StatusCode!,
                StatusText = result.StatusText,
                AvailabilityStatusCode = result.AvailabilityStatusCode,
                AvailabilityStatusText = result.AvailabilityStatusText,
                DescriptionLevelCode =
                    !string.IsNullOrEmpty(result.DescriptionLevelCode)
                    ? DescriptionLevelMapping.ArchivalEntityDescriptionLevel.GetValueOrDefault(result.DescriptionLevelCode)!
                    : string.Empty,
                DescriptionLevelText = result.DescriptionLevelText,
                ApproximateChronologicalScope = result.ApproximateChronologicalScope,
                HasNoChronologicalScope = result.HasNoChronologicalScope ?? false,
                StartDateDay = result.StartDateDay,
                StartDateMonth = result.StartDateMonth,
                StartDateYear = result.StartDateYear,
                EndDateDay = result.EndDateDay,
                EndDateMonth = result.EndDateMonth,
                EndDateYear = result.EndDateYear,
                DocumentsAccessDescription = result.DocumentsAccessDescription,
                OtherMetrics = result.OtherMetrics,
                Notes = result.Notes,
                NegativeFrameCount = result.NegativeFrameCount,
                PositiveFrameCount = result.PositiveFrameCount,
                CreationMethodText = result.CreationMethodText,
                OriginalityText = result.OriginalityText,
                LanguageText = result.LanguageText,
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
                OtherCopyCount = result.OtherCopyCount,
                PaperCopyCount = result.PaperCopyCount,
                SizeCm = result.SizeCm,
                TapeCount = result.TapeCount,
                VideoTapeCount = result.VideoTapeCount,
                SheetCount = result.SheetCount,
                CreatedOn = result.CreatedOn,
                CreatedByDisplayName = result.CreatedByDisplayName,
                UpdatedOn = result.UpdatedOn,
                UpdatedByDisplayName = result.UpdatedByDisplayName,
                HasDigitizedDigitalObjects = result.HasDigitizedDigitalObjects,
            };

            if (systemIdentifier != null)
            {
                var sizeInfo = await _context.VArchivalEntitySizeInfos
                   .Where(x => x.ArchivalEntitySystemIdentifier == systemIdentifier && x.IsDraft == 0)
                   .SingleOrDefaultAsync();
                if (sizeInfo != null)
                {
                    model.EnrolledDocumentCount = model.EnrolledDocumentCount.HasValue ? model.EnrolledDocumentCount.Value + sizeInfo.EnrolledDocumentCount : sizeInfo.EnrolledDocumentCount;
                    model.DeductedDocumentCount = model.DeductedDocumentCount.HasValue ? model.DeductedDocumentCount.Value + sizeInfo.DeductedDocumentCount : sizeInfo.DeductedDocumentCount;
                    model.Bytes = sizeInfo.EnrolledBytes;
                    model.EnrolledBytes = sizeInfo.EnrolledBytes;
                    model.DeductedBytes = sizeInfo.DeductedBytes;
                    model.FileTypeText = sizeInfo.FileTypes;
                    model.DocumentCount = sizeInfo.EnrolledDocumentCount;
                    model.EnrolledDuration = sizeInfo.EnrolledDuration;
                    model.DeductedDuration = sizeInfo.DeductedDuration;
                }
            }


            return model;
        }

        public async Task<int?> GetIdByExternalIdentifierAsync(int externalIdentifier)
        {
            return
                await _context.ArchivalEntities
                .Where(ae => ae.ExternalIdentifier == externalIdentifier)
                .Select(ae => ae.Id)
                .SingleOrDefaultAsync();
        }

        public async Task<Guid?> GetSystemIdentifierByExternalIdentifierAsync(int externalIdentifier)
        {
            return
                await _context.ArchivalEntities
                .Where(ae => ae.ExternalIdentifier == externalIdentifier)
                .Select(ae => ae.SystemIdentifier)
                .SingleOrDefaultAsync();
        }

        public async Task<int?> GetArchiveIdAsync(Guid sysId)
        {
            var entity =
                await _context.VArchivalEntities
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
                var entity = await _context.VArchivalEntities
                    .Where(x => x.SystemIdentifier == process.InventorySystemIdentifier && !x.Deleted)
                    .SingleOrDefaultAsync();

                return entity?.ArchiveId;
            }
            return null;
        }

        public async Task<int?> GetDescriptionLevelAsync(Guid sysId)
        {
            var archivalEntity = await GetArchivalEntityBySystemIdentifierAsync(sysId);
            if (archivalEntity == null)
            {
                return null;
            }
            //var descriptionLevelCode = await _context.VArchivalEntities
            //                            .Where(ae => ae.SystemIdentifier == sysId && (!ae.HasExternalSource.HasValue || !ae.HasExternalSource.Value) && !ae.Deleted)
            //                            .Select(ae => ae.DescriptionLevelCode)
            //                            .SingleOrDefaultAsync();

            //if (string.IsNullOrWhiteSpace(descriptionLevelCode))
            //{
            //    return null;
            //}

            //if (!int.TryParse(descriptionLevelCode, out var archivalEntityDescriptionLevel))
            //{
            //    _logger.LogError($"Error parsing description level code for archival entity with sysId {sysId}");
            //    throw new InvalidDataException(nameof(descriptionLevelCode));
            //}
            if (!int.TryParse(archivalEntity.DescriptionLevelCode, out var archivalEntityDescriptionLevel))
            {
                _logger.LogError($"Error parsing description level code for archival entity with sysId {sysId}");
                throw new InvalidDataException(nameof(archivalEntity.DescriptionLevelCode));
            }
            return archivalEntityDescriptionLevel;
        }

        public async Task<IEnumerable<SearchedArchiveEntityShortDisplayModel>?> GetShortBySearchText(SearchedArchiveEntityRequestModel model)
        {
            if (string.IsNullOrEmpty(model.SearchText.Trim()))
            {
                return null;
            }

            if (!model.InventoryInternalIdentifier.HasValue && model.InventoryExternalIdentifier.HasValue)
            {
                model.InventoryInternalIdentifier = await _inventoryService.GetIdByExternalIdentifier(model.InventoryExternalIdentifier.Value);
            }

            string query = "exec sp_SearchArchiveEntities @LinkedServer, @HasInventoryExternalSource, @Number, @InventoryExternalIdentifier, @InventoryInternalIdentifier";
            List<SqlParameter> queryParams = new()
            {
                new SqlParameter("LinkedServer", _settings.LinkedServer),
                new SqlParameter("HasInventoryExternalSource", model.HasInventoryExternalSource),
                new SqlParameter("InventoryExternalIdentifier", model.InventoryExternalIdentifier.HasValue
                    ? model.InventoryExternalIdentifier.Value
                    : DBNull.Value),
                new SqlParameter("InventoryInternalIdentifier", model.InventoryInternalIdentifier.HasValue
                    ? model.InventoryInternalIdentifier.Value
                    : DBNull.Value),
                new SqlParameter("Number", model.SearchText),
            };

            var result = await _context.SearchedArchiveEntitiesShort
                    .FromSqlRaw(query, queryParams.ToArray())
                    .ToListAsync();

            return result?.Select(x => new SearchedArchiveEntityShortDisplayModel()
            {
                HasExternalSource = x.HasExternalSource,
                Id = x.Id,
                ExternalIdentifier = x.ExternalIdentifier,
                CommonId = $"{x.Id}_{x.ExternalIdentifier}",
                Name = CommonHelper.GenerateCompositeName(x.Number, x.Title)
            });
        }

        public async Task<DataSourceResponseModel<PublicUserReviewDisplayModel>> GetArchivalEntityPublicUsersReviewsAsync(Guid? systemIdentifier)
        {
            int totalCount = 0;
            IEnumerable<PublicUserReviewDisplayModel> items = Enumerable.Empty<PublicUserReviewDisplayModel>();
            List<object> errors = new List<object>();

            if (systemIdentifier.HasValue)
            {
                var publicUserReviews =
                    _context.UserReviews
                    .Where(r => r.ArchivalEntitySystemIdentifier == systemIdentifier.Value && r.User.UserType == ApplicationUserType.External)
                    .Select(r => new PublicUserReviewDisplayModel
                    {
                        UserDisplayName = _context.AspNetUserProfiles
                                                  .Where(up => up.UserId == r.UserId && !up.Deleted)
                                                  .Select(up => up.DisplayName)
                                                  .SingleOrDefault(),
                        UserProfileType = _context.AspNetUserProfiles
                                                  .Where(up => up.UserId == r.UserId && !up.Deleted)
                                                  .Select(up => up.ProfileType)
                                                  .SingleOrDefault(),
                        Date = r.Date.UtcToLocalTime(),
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

        public async Task<OperationResult?> CreateArchivalEntityReviewAsync(Guid? archivalEntitySystemIdentifier, int? archivalEntityExternalIdentifier)
        {
            Guid systemIdentifier = Guid.NewGuid();

            UserReview employeeReview = new UserReview
            {
                SystemIdentifier = systemIdentifier,
                UserId = _userInfo.CurrentUserId.Value,
                Date = DateTime.UtcNow
            };

            if ((archivalEntitySystemIdentifier.HasValue && archivalEntitySystemIdentifier.Value != Guid.Empty) || archivalEntityExternalIdentifier.HasValue)
            {
                if (archivalEntitySystemIdentifier.HasValue && archivalEntitySystemIdentifier.Value != Guid.Empty)
                {
                    employeeReview.ArchivalEntitySystemIdentifier = archivalEntitySystemIdentifier.Value;
                }
                if (archivalEntityExternalIdentifier.HasValue)
                {
                    employeeReview.ArchivalEntityExternalIdentifier = archivalEntityExternalIdentifier;
                }
            }
            else
            {
                return OperationResult.Succeed("No review for missing archive entity system identifier");
            }

            await _context.UserReviews.AddAsync(employeeReview);
            await _context.SaveAsync("Employee review created");

            return OperationResult.Success;
        }

    }
}
