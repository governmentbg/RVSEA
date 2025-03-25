using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Extensions.Models;
using DAA.Models;
using DAA.Models.Configuration;
using DAA.Models.Documents;
using DAA.Services.ArchivalEntities;
using DAA.Services.Funds;
using DAA.Services.Inventories;
using DAA.Services.Nomenclatures;
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

namespace DAA.Services.Documents
{
    public class DocumentService : BaseService, IDocumentService
    {
        private readonly LinkedServerSettings _settings;
        private readonly IUserInfo _userInfo;
        private readonly IArchiveService _archiveService;
        private readonly IFundService _fundService;
        private readonly IInventoryService _inventoryService;
        private readonly IArchivalEntityService _archivalEntityService;
        private readonly INomenclatureService _nomenclatureService;

        public DocumentService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            ILogger<IDocumentService> logger,
            IOptions<LinkedServerSettings> settings,
            IUserInfo userInfo,
            IArchiveService archiveService,
            IFundService fundService,
            IInventoryService inventoryService,
            IArchivalEntityService archiveEntityService,
            INomenclatureService nomenclatureService)
            : base(context, localizer, logger)
        {
            _settings = settings.Value;
            _userInfo = userInfo;
            _archiveService = archiveService;
            _fundService = fundService;
            _inventoryService = inventoryService;
            _archivalEntityService = archiveEntityService;
            _nomenclatureService = nomenclatureService;
        }

        public DataSourceResponseModel<DocumentDisplayModel> GetAll(DataSourceRequestModel model, bool includeDeleted = false)
        {

            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.VDocuments
                .Select(d => new DocumentDisplayModel()
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
                    ArchivalEntityDraftId = d.ArchivalEntityDraftId,
                    ArchivalEntitySystemIdentifier = d.ArchivalEntitySystemIdentifier,
                    ArchivalEntityHasExternalSource = d.ArchivalEntityHasExternalSource ?? false,
                    ArchivalEntityExternalIdentifier = d.ArchivalEntityExternalIdentifier,
                    ArchivalEntityNumber = d.ArchivalEntityNumber,
                    ArchivalEntityAvailabilityStatusCode = d.ArchivalEntityAvailabilityStatusCode,
                    Number = d.Number,
                    Title = d.Title,
                    StatusCode = d.StatusCode!,
                    StatusText = d.StatusText,
                    DescriptionLevelCode = d.DescriptionLevelCode!,
                    DescriptionLevelText = d.DescriptionLevelText,
                    AvailabilityStatusCode = d.AvailabilityStatusCode,
                    AvailabilityStatusText = d.AvailabilityStatusText,
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

            QueryResponseModel<DocumentDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<DocumentDisplayModel> result = new DataSourceResponseModel<DocumentDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(d => new DocumentDisplayModel()
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
                    ArchivalEntityDraftId = d.ArchivalEntityDraftId,
                    ArchivalEntitySystemIdentifier = d.ArchivalEntitySystemIdentifier,
                    ArchivalEntityHasExternalSource = d.ArchivalEntityHasExternalSource,
                    ArchivalEntityExternalIdentifier = d.ArchivalEntityExternalIdentifier,
                    ArchivalEntityNumber = d.ArchivalEntityNumber,
                    ArchivalEntityAvailabilityStatusCode = d.ArchivalEntityAvailabilityStatusCode,
                    Number = d.Number,
                    Title = d.Title,
                    StatusCode = d.StatusCode!,
                    StatusText = d.StatusText,
                    DescriptionLevelCode = d.DescriptionLevelCode!,
                    DescriptionLevelText = d.DescriptionLevelText,
                    AvailabilityStatusCode = d.AvailabilityStatusCode,
                    AvailabilityStatusText = d.AvailabilityStatusText,
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

            //if (model == null)
            //{
            //    throw new ArgumentNullException(nameof(model));
            //}

            //var query =
            //    _context.Documents
            //    .Select(x => new DocumentOfListDisplayModel()
            //    {
            //        Title = x.Title,
            //        Number = x.Number,
            //        Id = x.Id,
            //        ExternalIdentifier = x.ExternalIdentifier,
            //        ApproximateChronologicalScope = x.ApproxmateChronologicalScope,
            //        DescriptionLevel = x.DescriptionLevelCodeNavigation != null ? x.DescriptionLevelCodeNavigation.Text : null,
            //        //Status = x.StatusCodeNavigation != null ? x.StatusCodeNavigation.Text : null,
            //        Deleted = x.Deleted,
            //    });

            //if (!includeDeleted)
            //{
            //    query = query.Where(x => !x.Deleted);
            //}

            //if (!string.IsNullOrEmpty(model.SearchString))
            //{
            //    query = query.FilterBySearchText(model!.SearchString);
            //}



            //QueryResponseModel<DocumentOfListDisplayModel> queryResponse = query.SortAndFilter(model);
            //DataSourceResponseModel<DocumentOfListDisplayModel> result = new()
            //{
            //    TotalCount = queryResponse.TotalCount,
            //    Errors = queryResponse.Errors,
            //    Items = queryResponse.Query.Select(x => x)
            //};

            //return result;

        }

        public async Task<DataSourceResponseModel<DocumentDisplayModel>> GetByArchivalEntityIdentifierAsync(
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
            IEnumerable<DocumentDisplayModel> items = Enumerable.Empty<DocumentDisplayModel>();
            List<object> errors = new List<object>();

            try
            {
                string countQuery = "exec @ReturnValue = sp_GetDocumentsByArchiveEntityCount @LinkedServer, @ArchiveEntityIdentifier, @ArchiveEntityHasExternalSource, @ArchiveEntityExternalIdentifier, @SearchText, @IncludeDeleted";
                List<SqlParameter> countQueryParams = new List<SqlParameter>()
                {
                    new SqlParameter("LinkedServer", _settings.LinkedServer),
                    new SqlParameter("ArchiveEntityIdentifier", archivalEntitySysId.HasValue ? archivalEntitySysId.Value : DBNull.Value),
                    new SqlParameter("ArchiveEntityHasExternalSource", archivalEntityHasExternalSource),
                    new SqlParameter("ArchiveEntityExternalIdentifier", archivalEntityExternalIdentifier.HasValue ? archivalEntityExternalIdentifier.Value : DBNull.Value),
                    new SqlParameter("SearchText", String.IsNullOrEmpty(model.SearchString) ? DBNull.Value : model.SearchString),
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
                string query = "exec sp_GetDocumentsByArchiveEntity " +
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
                    queryResult.Select(d => new DocumentDisplayModel()
                    {
                        Id = d.Id,
                        SystemIdentifier = d.SystemIdentifier,
                        HasExternalSource = d.HasExternalSource,
                        ExternalIdentifier = d.ExternalIdentifier,
                        ArchiveCode = d.ArchiveCode,
                        ArchiveName = d.ArchiveName,
                        FundHasExternalSource = d.FundHasExternalSource ?? false,
                        FundExternalIdentifier = d.FundExternalIdentifier,
                        FundNumber = d.FundNumber,
                        InventoryHasExternalSource = d.InventoryHasExternalSource ?? false,
                        InventoryExternalIdentifier = d.InventoryExternalIdentifier,
                        InventoryNumber = d.InventoryNumber,
                        ArchivalEntityHasExternalSource = d.ArchivalEntityHasExternalSource ?? false,
                        ArchivalEntityExternalIdentifier = d.ArchivalEntityExternalIdentifier,
                        ArchivalEntityNumber = d.ArchivalEntityNumber,
                        Number = d.Number,
                        Title = d.Title,
                        StatusCode = d.StatusCode!,
                        StatusText = d.StatusText,
                        DescriptionLevelCode = d.DescriptionLevelCode!,
                        DescriptionLevelText = d.DescriptionLevelText,
                        AvailabilityStatusCode = d.AvailabilityStatusCode,
                        AvailabilityStatusText = d.AvailabilityStatusText,
                        ApproximateChronologicalScope = d.ApproximateChronologicalScope,
                        CreatedOn = d.CreatedOn,
                        CreatedByDisplayName = d.CreatedByDisplayName,
                        UpdatedOn = d.UpdatedOn,
                        UpdatedByDisplayName = d.UpdatedByDisplayName,
                        HasDigitizedDigitalObjects = d.HasDigitizedDigitalObjects
                        //ClassificationSchemeIndex = d.ClassificationSchemeIndex
                    });

                items = items.Select(x =>
                {
                    x.SystemIdentifier = x.HasExternalSource == true ? _context.Documents
                                        .Where(i => i.ExternalIdentifier == x.ExternalIdentifier && !i.Deleted)
                                        .Select(i => i.SystemIdentifier)
                                        .FirstOrDefault()
                                        : x.SystemIdentifier;

                    x.IsInProcess =
                           _context.Processes
                          .Where(p => p.DocumentSystemIdentifier.HasValue && p.DocumentSystemIdentifier == x.SystemIdentifier && !p.Completed && !p.Deleted)
                          .Any();

                    return x;
                }).ToList();
            }

            catch (Exception exc)
            {
                if (archivalEntitySysId.HasValue)
                {
                    var localQuery =
                        _context.VDocuments
                        .Where(d => d.ArchivalEntitySystemIdentifier == archivalEntitySysId.Value)
                        .Select(d => new DocumentDisplayModel()
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
                            ArchivalEntityDraftId = d.ArchivalEntityDraftId,
                            ArchivalEntitySystemIdentifier = d.ArchivalEntitySystemIdentifier,
                            ArchivalEntityHasExternalSource = d.ArchivalEntityHasExternalSource ?? false,
                            ArchivalEntityExternalIdentifier = d.ArchivalEntityExternalIdentifier,
                            ArchivalEntityNumber = d.ArchivalEntityNumber,
                            ArchivalEntityAvailabilityStatusCode = d.ArchivalEntityAvailabilityStatusCode,
                            Number = d.Number,
                            Title = d.Title,
                            StatusCode = d.StatusCode!,
                            StatusText = d.StatusText,
                            DescriptionLevelCode = d.DescriptionLevelCode!,
                            DescriptionLevelText = d.DescriptionLevelText,
                            AvailabilityStatusCode = d.AvailabilityStatusCode,
                            AvailabilityStatusText = d.AvailabilityStatusText,
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
                            ApproximateChronologicalScope = d.ApproxmateChronologicalScope,
                        });

                    if (!includeDeleted)
                    {
                        localQuery = localQuery.Where(i => !i.Deleted);
                    }

                    if (!String.IsNullOrWhiteSpace(model.SearchString))
                    {
                        localQuery = localQuery.FilterBySearchText(model.SearchString);
                    }

                    foreach (var item in localQuery)
                    {
                        item.IsInProcess = await _context.Processes
                          .Where(p => p.DocumentSystemIdentifier.HasValue && p.DocumentSystemIdentifier == item.SystemIdentifier && p.Completed == false)
                          .AnyAsync();
                    }

                    totalCount = await localQuery.CountAsync();
                    items = await localQuery.Select(d => new DocumentDisplayModel()
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
                        FundHasExternalSource = d.FundHasExternalSource ,
                        FundExternalIdentifier = d.FundExternalIdentifier,
                        FundNumber = d.FundNumber,
                        InventoryDraftId = d.InventoryDraftId,
                        InventorySystemIdentifier = d.InventorySystemIdentifier,
                        InventoryHasExternalSource = d.InventoryHasExternalSource,
                        InventoryExternalIdentifier = d.InventoryExternalIdentifier,
                        InventoryNumber = d.InventoryNumber,
                        InventoryAvailabilityStatusCode = d.InventoryAvailabilityStatusCode,
                        ArchivalEntityDraftId = d.ArchivalEntityDraftId,
                        ArchivalEntitySystemIdentifier = d.ArchivalEntitySystemIdentifier,
                        ArchivalEntityHasExternalSource = d.ArchivalEntityHasExternalSource,
                        ArchivalEntityExternalIdentifier = d.ArchivalEntityExternalIdentifier,
                        ArchivalEntityNumber = d.ArchivalEntityNumber,
                        ArchivalEntityAvailabilityStatusCode = d.ArchivalEntityAvailabilityStatusCode,
                        Number = d.Number,
                        Title = d.Title,
                        StatusCode = d.StatusCode!,
                        StatusText = d.StatusText,
                        DescriptionLevelCode = d.DescriptionLevelCode!,
                        DescriptionLevelText = d.DescriptionLevelText,
                        AvailabilityStatusCode = d.AvailabilityStatusCode,
                        AvailabilityStatusText = d.AvailabilityStatusText,
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
                        ApproximateChronologicalScope = d.ApproximateChronologicalScope,
                    }).ToListAsync();
                }
            }

            DataSourceResponseModel<DocumentDisplayModel> result = new DataSourceResponseModel<DocumentDisplayModel>()
            {
                TotalCount = totalCount,
                Errors = errors.Count > 0 ? errors : null,
                Items = items
            };

            return result;
        }

        public DataSourceResponseModel<DocumentDisplayModel> GetByAvailabilityStatus(
            DataSourceRequestModel model,
            int availabilityStatus,
            Guid fundSystemIdentifier,
            string? searchArchivalEntityNumber = null,
            int? searchArchivalEntityStartSheet = null,
            int? searchArchivalEntityEndSheet = null,
            bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.VDocuments
                .Where(d =>
                    d.FundSystemIdentifier == fundSystemIdentifier
                    && d.AvailabilityStatusCode == availabilityStatus
                    && d.ArchivalEntityAvailabilityStatusCode != (int)Shared.AvailabilityStatus.RelocationDeduction
                    && d.ArchivalEntityAvailabilityStatusCode != (int)Shared.AvailabilityStatus.DisposalDeduction)
                .Select(d => new DocumentDisplayModel()
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
                    ArchivalEntityDraftId = d.ArchivalEntityDraftId,
                    ArchivalEntitySystemIdentifier = d.ArchivalEntitySystemIdentifier,
                    ArchivalEntityHasExternalSource = d.ArchivalEntityHasExternalSource ?? false,
                    ArchivalEntityExternalIdentifier = d.ArchivalEntityExternalIdentifier,
                    ArchivalEntityNumber = d.ArchivalEntityNumber,
                    ArchivalEntityAvailabilityStatusCode = d.ArchivalEntityAvailabilityStatusCode,
                    Number = d.Number,
                    Title = d.Title,
                    StatusCode = d.StatusCode!,
                    StatusText = d.StatusText,
                    DescriptionLevelCode = d.DescriptionLevelCode!,
                    DescriptionLevelText = d.DescriptionLevelText,
                    AvailabilityStatusCode = d.AvailabilityStatusCode,
                    AvailabilityStatusText = d.AvailabilityStatusText,
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

            QueryResponseModel<DocumentDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<DocumentDisplayModel> result = new DataSourceResponseModel<DocumentDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(d => new DocumentDisplayModel()
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
                    ArchivalEntityDraftId = d.ArchivalEntityDraftId,
                    ArchivalEntitySystemIdentifier = d.ArchivalEntitySystemIdentifier,
                    ArchivalEntityHasExternalSource = d.ArchivalEntityHasExternalSource,
                    ArchivalEntityExternalIdentifier = d.ArchivalEntityExternalIdentifier,
                    ArchivalEntityNumber = d.ArchivalEntityNumber,
                    ArchivalEntityAvailabilityStatusCode = d.ArchivalEntityAvailabilityStatusCode,
                    Number = d.Number,
                    Title = d.Title,
                    StatusCode = d.StatusCode!,
                    StatusText = d.StatusText,
                    DescriptionLevelCode = d.DescriptionLevelCode!,
                    DescriptionLevelText = d.DescriptionLevelText,
                    AvailabilityStatusCode = d.AvailabilityStatusCode,
                    AvailabilityStatusText = d.AvailabilityStatusText,
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

        public async Task<DocumentDisplayModel?> GetDocumentBySystemIdentifierAsync(Guid sysId)
        {
            var documentDraft = await GetCurrentDraftAsync(sysId);
            if (documentDraft != null)
            {
                var sizeInfo = await _context.VDocumentSizeInfos
                    .Where(x => x.DocumentSystemIdentifier == sysId && x.IsDraft == 1)
                    .SingleOrDefaultAsync();

                if (sizeInfo != null)
                {
                    documentDraft.Bytes = sizeInfo.EnrolledBytes;
                    string fileTypes = sizeInfo.FileTypes != null
                        ? String.Join(
                            System.Globalization.CultureInfo.CurrentCulture.TextInfo.ListSeparator + " ",
                            sizeInfo.FileTypes.Split("; ").Distinct()).ToUpper()
                        : String.Empty;
                    documentDraft.FileTypeText = fileTypes;
                    documentDraft.Duration = sizeInfo.EnrolledDuration > 0 ? sizeInfo.EnrolledDuration : documentDraft.Duration;
                }

                return documentDraft;
            }

            var document =
                await _context.Documents
                .Where(d => d.SystemIdentifier == sysId && !d.Deleted)
                .Select(d => new DocumentDisplayModel()
                {
                    Id = d.Id,
                    SystemIdentifier = d.SystemIdentifier,
                    IsDraft = false,
                    HasExternalSource = d.HasExternalSource,
                    ExternalIdentifier = d.ExternalIdentifier,
                    ExternalSourceUpdatedOn = d.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    ArchiveId = d.ArchiveId,
                    ArchiveCode = d.Archive.Code,
                    ArchiveName = d.Archive.Name,
                    FundSystemIdentifier = d.FundSystemIdentifier,
                    FundHasExternalSource = d.FundSystemIdentifierNavigation.HasExternalSource,
                    FundExternalIdentifier = d.FundSystemIdentifierNavigation.ExternalIdentifier,
                    FundNumber = d.FundSystemIdentifierNavigation.Number,
                    InventorySystemIdentifier = d.InventorySystemIdentifier,
                    InventoryHasExternalSource = d.InventorySystemIdentifierNavigation.HasExternalSource,
                    InventoryExternalIdentifier = d.InventorySystemIdentifierNavigation.ExternalIdentifier,
                    InventoryNumber = d.InventorySystemIdentifierNavigation.Number,
                    ArchivalEntitySystemIdentifier = d.ArchivalEntitySystemIdentifier,
                    ArchivalEntityHasExternalSource = d.ArchivalEntitySystemIdentifierNavigation.HasExternalSource,
                    ArchivalEntityExternalIdentifier = d.ArchivalEntitySystemIdentifierNavigation.ExternalIdentifier,
                    ArchivalEntityNumber = d.ArchivalEntitySystemIdentifierNavigation.Number,
                    Number = d.Number,
                    Title = d.Title,
                    StatusCode = d.StatusCode,
                    StatusText = d.StatusCodeNavigation.Text,
                    DescriptionLevelCode = d.DescriptionLevelCode,
                    DescriptionLevelText = d.DescriptionLevelCodeNavigation.Text,
                    AvailabilityStatusCode = d.AvailabilityStatusCode,
                    AvailabilityStatusText = d.AvailabilityStatusCodeNavigation!.Text,
                    ApproximateChronologicalScope = d.ApproxmateChronologicalScope,
                    HasNoChronologicalScope = d.HasNoChronologicalScope,
                    StartDateDay = d.StartDateDay,
                    StartDateMonth = d.StartDateMonth,
                    StartDateYear = d.StartDateYear,
                    EndDateDay = d.EndDateDay,
                    EndDateMonth = d.EndDateMonth,
                    EndDateYear = d.EndDateYear,
                    DocumentsAccessDescription = d.DocumentsAccessDescription,
                    OtherMetrics = d.OtherMetrics,
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
                    SizeCm = d.SizeCm,
                    DigitalDevice = d.DigitalDevice,
                    Duration = d.Duration,
                    StartSheetNumber = d.StartSheetNumber,
                    EndSheetNumber = d.EndSheetNumber,
                    Transcription = d.Transcription,
                    CreatedBy = d.CreatedBy,
                    CreatedByDisplayName = d.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == d.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = d.CreatedByNavigation.UserName,
                    CreatedOn = d.CreatedOn.UtcToLocalTime(),
                    Deleted = d.Deleted,
                    DeletedBy = d.DeletedBy,
                    DeletedByDisplayName = d.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == d.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = d.DeletedByNavigation.UserName,
                    DeletedOn = d.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = d.UpdatedBy,
                    UpdatedByDisplayName = d.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == d.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = d.UpdatedByNavigation.UserName,
                    UpdatedOn = d.UpdatedOn.UtcToLocalTime(),

                    DescriptionAuthor = d.DescriptionAuthor,
                    Cypher = d.Cypher,
                    TextDocsCount = d.TextDocsCount,
                    GraphicalDocsCount = d.GraphicalDocsCount,
                    Phase = d.Phase,
                    Part = d.Part,
                    Stage = d.Stage,
                    OtherLanguage = d.OtherLanguage,

                    FileTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.FileType),
                    FileTypeText = _nomenclatureService.GetEntityNomenclatureText(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.FileType),
                    CreationMethodCodes = _nomenclatureService.GetEntityNomenclatureCodes(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.CreationMethod),
                    CreationMethodText = _nomenclatureService.GetEntityNomenclatureText(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.CreationMethod),
                    OriginalityCodes = _nomenclatureService.GetEntityNomenclatureCodes(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.Originality),
                    OriginalityText = _nomenclatureService.GetEntityNomenclatureText(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.Originality),
                    LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.Language),
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
                    document.Bytes = sizeInfo.EnrolledBytes;
                    string fileTypes = sizeInfo.FileTypes != null
                        ? String.Join(
                            System.Globalization.CultureInfo.CurrentCulture.TextInfo.ListSeparator + " ",
                            sizeInfo.FileTypes.Split("; ").Distinct()).ToUpper()
                        : String.Empty;
                    document.FileTypeText = fileTypes;
                    document.Duration = sizeInfo.EnrolledDuration > 0 ? sizeInfo.EnrolledDuration : document.Duration;
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

        public async Task<DocumentDisplayModel?> GetCurrentDraftAsync(Guid sysId)
        {
            var documentDraft =
                await _context.DocumentDrafts
                .GroupJoin(
                    _context.ArchivalEntities,
                    draft => draft.ArchivalEntitySystemIdentifier,
                    archivalEntity => archivalEntity.SystemIdentifier,
                    (draft, archivalEntity) => new { Draft = draft, ArchivalEntity = archivalEntity })
                .SelectMany(doc => doc.ArchivalEntity.DefaultIfEmpty(),
                    (draft, archivalEntity) => new { Draft = draft, ArchivalEntity = archivalEntity })
                .GroupJoin(
                    _context.Inventories,
                    draft => draft.Draft.Draft.InventorySystemIdentifier,
                    inventory => inventory.SystemIdentifier,
                    (draft, inventory) => new { Draft = draft, Inventory = inventory })
                .SelectMany(doc => doc.Inventory.DefaultIfEmpty(),
                    (draft, inventory) => new { Draft = draft, Inventory = inventory })
                .GroupJoin(
                    _context.Funds,
                    ae => ae.Draft.Draft.Draft.Draft.FundSystemIdentifier,
                    fund => fund.SystemIdentifier,
                    (draft, fund) => new { Draft = draft, Fund = fund })
                .SelectMany(doc => doc.Fund.DefaultIfEmpty(),
                    (draft, fund) => new { Draft = draft, Fund = fund })
                .Where(draft => draft.Draft.Draft.Draft.Draft.Draft.Draft.SystemIdentifier == sysId && draft.Draft.Draft.Draft.Draft.Draft.Draft.IsCurrent && !draft.Draft.Draft.Draft.Draft.Draft.Draft.Deleted)
                .Select(doc => new DocumentDisplayModel()
                {
                    Id = doc.Draft.Draft.Draft.Draft.Draft.Draft.Id,
                    SystemIdentifier = doc.Draft.Draft.Draft.Draft.Draft.Draft.SystemIdentifier,
                    IsDraft = true,
                    HasExternalSource = doc.Draft.Draft.Draft.Draft.Draft.Draft.HasExternalSource ?? false,
                    ExternalIdentifier = doc.Draft.Draft.Draft.Draft.Draft.Draft.ExternalIdentifier,
                    ExternalSourceUpdatedOn = doc.Draft.Draft.Draft.Draft.Draft.Draft.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    ArchiveId = doc.Draft.Draft.Draft.Draft.Draft.Draft.ArchiveId,
                    ArchiveCode = doc.Draft.Draft.Draft.Draft.Draft.Draft.Archive.Code,
                    ArchiveName = doc.Draft.Draft.Draft.Draft.Draft.Draft.Archive.Name,
                    FundDraftId = doc.Draft.Draft.Draft.Draft.Draft.Draft.FundDraftId,
                    FundSystemIdentifier = doc.Draft.Draft.Draft.Draft.Draft.Draft.FundSystemIdentifier,
                    FundHasExternalSource = doc.Draft.Draft.Draft.Draft.Draft.Draft.FundDraft!.HasExternalSource ?? doc.Fund!.HasExternalSource,
                    FundExternalIdentifier = doc.Fund!.ExternalIdentifier,
                    FundNumber = doc.Fund.Number,
                    InventoryDraftId = doc.Draft.Draft.Draft.Draft.Draft.Draft.InventoryDraftId,
                    InventorySystemIdentifier = doc.Draft.Draft.Draft.Draft.Draft.Draft.InventorySystemIdentifier,
                    InventoryHasExternalSource = doc.Draft.Draft.Draft.Draft.Draft.Draft.InventoryDraft!.HasExternalSource ?? doc.Draft.Draft.Inventory!.HasExternalSource,
                    InventoryExternalIdentifier = doc.Draft.Draft.Inventory!.ExternalIdentifier,
                    InventoryNumberArray = doc.Draft.Draft.Inventory.NumberArray ?? doc.Draft.Draft.Draft.Draft.Draft.Draft.InventoryDraft!.NumberArray,
                    InventoryNumberNumeric = doc.Draft.Draft.Inventory.NumberNumeric ?? doc.Draft.Draft.Draft.Draft.Draft.Draft.InventoryDraft!.NumberNumeric,
                    InventoryNumber = doc.Draft.Draft.Inventory.Number,
                    ArchivalEntityDraftId = doc.Draft.Draft.Draft.Draft.Draft.Draft.ArchivalEntityDraftId,
                    ArchivalEntitySystemIdentifier = doc.Draft.Draft.Draft.Draft.Draft.Draft.ArchivalEntitySystemIdentifier,
                    ArchivalEntityHasExternalSource = doc.Draft.Draft.Draft.Draft.Draft.Draft.ArchivalEntityDraft!.HasExternalSource ?? doc.Draft.Draft.Draft.Draft.ArchivalEntity!.HasExternalSource,
                    ArchivalEntityExternalIdentifier = doc.Draft.Draft.Draft.Draft.ArchivalEntity!.ExternalIdentifier,
                    ArchivalEntityNumber = doc.Draft.Draft.Draft.Draft.ArchivalEntity!.Number,
                    Number = doc.Draft.Draft.Draft.Draft.Draft.Draft.Number,
                    Title = doc.Draft.Draft.Draft.Draft.Draft.Draft.Title,
                    StatusCode = doc.Draft.Draft.Draft.Draft.Draft.Draft.StatusCode!,
                    StatusText = doc.Draft.Draft.Draft.Draft.Draft.Draft.StatusCodeNavigation!.Text,
                    DescriptionLevelCode = doc.Draft.Draft.Draft.Draft.Draft.Draft.DescriptionLevelCode!,
                    DescriptionLevelText = doc.Draft.Draft.Draft.Draft.Draft.Draft.DescriptionLevelCodeNavigation!.Text,
                    AvailabilityStatusCode = doc.Draft.Draft.Draft.Draft.Draft.Draft.AvailabilityStatusCode,
                    AvailabilityStatusText = doc.Draft.Draft.Draft.Draft.Draft.Draft.AvailabilityStatusCodeNavigation!.Text,
                    StartSheetNumber = doc.Draft.Draft.Draft.Draft.Draft.Draft.StartSheetNumber,
                    EndSheetNumber = doc.Draft.Draft.Draft.Draft.Draft.Draft.EndSheetNumber,
                    ApproximateChronologicalScope = doc.Draft.Draft.Draft.Draft.Draft.Draft.ApproxmateChronologicalScope,
                    HasNoChronologicalScope = doc.Draft.Draft.Draft.Draft.Draft.Draft.HasNoChronologicalScope,
                    StartDateDay = doc.Draft.Draft.Draft.Draft.Draft.Draft.StartDateDay,
                    StartDateMonth = doc.Draft.Draft.Draft.Draft.Draft.Draft.StartDateMonth,
                    StartDateYear = doc.Draft.Draft.Draft.Draft.Draft.Draft.StartDateYear,
                    EndDateDay = doc.Draft.Draft.Draft.Draft.Draft.Draft.EndDateDay,
                    EndDateMonth = doc.Draft.Draft.Draft.Draft.Draft.Draft.EndDateMonth,
                    EndDateYear = doc.Draft.Draft.Draft.Draft.Draft.Draft.EndDateYear,
                    DocumentsAccessDescription = doc.Draft.Draft.Draft.Draft.Draft.Draft.DocumentsAccessDescription,
                    OtherMetrics = doc.Draft.Draft.Draft.Draft.Draft.Draft.OtherMetrics,
                    Notes = doc.Draft.Draft.Draft.Draft.Draft.Draft.Notes,
                    Bytes = doc.Draft.Draft.Draft.Draft.Draft.Draft.Bytes,
                    NegativeFrameCount = doc.Draft.Draft.Draft.Draft.Draft.Draft.NegativeFrameCount,
                    PositiveFrameCount = doc.Draft.Draft.Draft.Draft.Draft.Draft.PositiveFrameCount,
                    Author = doc.Draft.Draft.Draft.Draft.Draft.Draft.Author,
                    Description = doc.Draft.Draft.Draft.Draft.Draft.Draft.Description,
                    DigitizedCopyCount = doc.Draft.Draft.Draft.Draft.Draft.Draft.DigitizedCopyCount,
                    Features = doc.Draft.Draft.Draft.Draft.Draft.Draft.Features,
                    Transcription = doc.Draft.Draft.Draft.Draft.Draft.Draft.Transcription,
                    Location = doc.Draft.Draft.Draft.Draft.Draft.Draft.Location,
                    MicrofilmedCopyCount = doc.Draft.Draft.Draft.Draft.Draft.Draft.MicrofilmedCopyCount,
                    OtherCopyCount = doc.Draft.Draft.Draft.Draft.Draft.Draft.OtherCopyCount,
                    PaperCopyCount = doc.Draft.Draft.Draft.Draft.Draft.Draft.PaperCopyCount,
                    Scaling = doc.Draft.Draft.Draft.Draft.Draft.Draft.Scaling,
                    SheetCount = doc.Draft.Draft.Draft.Draft.Draft.Draft.SheetCount,
                    SizeCm = doc.Draft.Draft.Draft.Draft.Draft.Draft.SizeCm,
                    DigitalDevice = doc.Draft.Draft.Draft.Draft.Draft.Draft.DigitalDevice,
                    Duration = doc.Draft.Draft.Draft.Draft.Draft.Draft.Duration,

                    CreatedBy = doc.Draft.Draft.Draft.Draft.Draft.Draft.CreatedBy,
                    CreatedByDisplayName = doc.Draft.Draft.Draft.Draft.Draft.Draft.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == doc.Draft.Draft.Draft.Draft.Draft.Draft.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = doc.Draft.Draft.Draft.Draft.Draft.Draft.CreatedByNavigation!.UserName,
                    CreatedOn = doc.Draft.Draft.Draft.Draft.Draft.Draft.CreatedOn.UtcToLocalTime(),
                    Deleted = doc.Draft.Draft.Draft.Draft.Draft.Draft.Deleted,
                    DeletedBy = doc.Draft.Draft.Draft.Draft.Draft.Draft.DeletedBy,
                    DeletedByDisplayName = doc.Draft.Draft.Draft.Draft.Draft.Draft.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == doc.Draft.Draft.Draft.Draft.Draft.Draft.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = doc.Draft.Draft.Draft.Draft.Draft.Draft.DeletedByNavigation!.UserName,
                    DeletedOn = doc.Draft.Draft.Draft.Draft.Draft.Draft.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = doc.Draft.Draft.Draft.Draft.Draft.Draft.UpdatedBy,
                    UpdatedByDisplayName = doc.Draft.Draft.Draft.Draft.Draft.Draft.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == doc.Draft.Draft.Draft.Draft.Draft.Draft.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = doc.Draft.Draft.Draft.Draft.Draft.Draft.UpdatedByNavigation!.UserName,
                    UpdatedOn = doc.Draft.Draft.Draft.Draft.Draft.Draft.UpdatedOn.UtcToLocalTime(),

                    IsImported = doc.Draft.Draft.Draft.Draft.Draft.Draft.IsImported,
                    DescriptionAuthor = doc.Draft.Draft.Draft.Draft.Draft.Draft.DescriptionAuthor,
                    Cypher = doc.Draft.Draft.Draft.Draft.Draft.Draft.Cypher,
                    TextDocsCount = doc.Draft.Draft.Draft.Draft.Draft.Draft.TextDocsCount,
                    GraphicalDocsCount = doc.Draft.Draft.Draft.Draft.Draft.Draft.GraphicalDocsCount,
                    Phase = doc.Draft.Draft.Draft.Draft.Draft.Draft.Phase,
                    Part = doc.Draft.Draft.Draft.Draft.Draft.Draft.Part,
                    Stage = doc.Draft.Draft.Draft.Draft.Draft.Draft.Stage,
                    OtherLanguage = doc.Draft.Draft.Draft.Draft.Draft.Draft.OtherLanguage,

                    CreationMethodCodes = _nomenclatureService.GetEntityNomenclatureCodes(doc.Draft.Draft.Draft.Draft.Draft.Draft.Id, BusinessObjectType.Document, true, Shared.NomenclatureCode.CreationMethod),
                    CreationMethodText = _nomenclatureService.GetEntityNomenclatureText(doc.Draft.Draft.Draft.Draft.Draft.Draft.Id, BusinessObjectType.Document, true, Shared.NomenclatureCode.CreationMethod),
                    OriginalityCodes = _nomenclatureService.GetEntityNomenclatureCodes(doc.Draft.Draft.Draft.Draft.Draft.Draft.Id, BusinessObjectType.Document, true, Shared.NomenclatureCode.Originality),
                    OriginalityText = _nomenclatureService.GetEntityNomenclatureText(doc.Draft.Draft.Draft.Draft.Draft.Draft.Id, BusinessObjectType.Document, true, Shared.NomenclatureCode.Originality),
                    LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(doc.Draft.Draft.Draft.Draft.Draft.Draft.Id, BusinessObjectType.Document, true, Shared.NomenclatureCode.Language),
                    LanguageText = _nomenclatureService.GetEntityNomenclatureText(doc.Draft.Draft.Draft.Draft.Draft.Draft.Id, BusinessObjectType.Document, true, Shared.NomenclatureCode.Language),
                    FileTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(doc.Draft.Draft.Draft.Draft.Draft.Draft.Id, BusinessObjectType.Document, true, Shared.NomenclatureCode.FileType),
                    FileTypeText = _nomenclatureService.GetEntityNomenclatureText(doc.Draft.Draft.Draft.Draft.Draft.Draft.Id, BusinessObjectType.Document, true, Shared.NomenclatureCode.FileType),
                })
                .SingleOrDefaultAsync();

            return documentDraft;
        }

        public async Task<bool> HasCurrentDraftAsync(Guid sysId)
        {
            return await _context.DocumentDrafts
                    .Where(doc => doc.SystemIdentifier == sysId && doc.IsCurrent && !doc.Deleted)
                    .AnyAsync();
        }

        public async Task<bool> IsCurrentDraftAsync(DocumentDraftModel model)
        {
            return
                await _context.DocumentDrafts
                .Where(d => d.Id == model.Id && d.IsCurrent && !d.Deleted)
                .AnyAsync();
        }

        public async Task<bool> IsReadOnlyDraftAsync(DocumentDraftModel model)
        {
            return
                await _context.DocumentDrafts
                .Where(d => d.Id == model.Id && (d.ReadOnly || !d.IsCurrent || d.Deleted))
                .AnyAsync();
        }

        async Task<Guid> IDocumentServiceBase.CreateDraftInternalAsync(DocumentDraftModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            //If there is new archival entity draft on edit
            if (!model.ArchivalEntityDraftId.HasValue)
            {
                var archivalEntityDraft = await _archivalEntityService.GetCurrentDraftAsync(model.ArchivalEntitySystemIdentifier!.Value);
                if (archivalEntityDraft != null)
                {
                    model.FundDraftId = archivalEntityDraft.FundDraftId;
                    model.InventoryDraftId = archivalEntityDraft.InventoryDraftId;
                    model.ArchivalEntityDraftId = archivalEntityDraft.Id;
                }
            }

            if (!model.SystemIdentifier.HasValue)
            {
                model.SystemIdentifier = Guid.NewGuid();
            }
            else
            {
                var currentDraft =
                    await _context.DocumentDrafts
                    .Where(d => d.SystemIdentifier == model.SystemIdentifier && d.IsCurrent)
                    .SingleOrDefaultAsync();
                if (currentDraft != null)
                {
                    currentDraft.IsCurrent = false;
                    currentDraft.ReadOnly = true;
                    _context.Update(currentDraft);
                }
            }

            var documentDraft = new DocumentDraft()
            {
                IsCurrent = true,
                ReadOnly = false,
                SystemIdentifier = model.SystemIdentifier!.Value,
                WorkflowId = model.WorkflowId,
                WorkflowStepId = model.WorkflowStepId,
                WorkflowStepTypeCode = model.WorkflowStepTypeCode,
                WorkflowTypeCode = model.WorkflowTypeCode,
                ArchiveId = model.ArchiveId!.Value,
                FundDraftId = model.FundDraftId,
                FundSystemIdentifier = model.FundSystemIdentifier!.Value,
                InventoryDraftId = model.InventoryDraftId,
                InventorySystemIdentifier = model.InventorySystemIdentifier!.Value,
                ArchivalEntityDraftId = model.ArchivalEntityDraftId,
                ArchivalEntitySystemIdentifier = model.ArchivalEntitySystemIdentifier!.Value,
                DescriptionLevelCode = model.DescriptionLevelCode,
                StatusCode = model.StatusCode,
                AvailabilityStatusCode = model.AvailabilityStatusCode,
                Number = model.Number,
                Title = model.Title,
                Author = model.Author,
                DigitalDevice = model.DigitalDevice,
                Duration = model.Duration,
                StartSheetNumber = model.StartSheetNumber,
                EndSheetNumber = model.EndSheetNumber,
                HasNoChronologicalScope = model.HasNoChronologicalScope,
                Transcription = model.Transcription,
                Location = model.Location,
                Bytes = model.Bytes,
                SheetCount = model.SheetCount,
                OtherMetrics = model.OtherMetrics,
                SizeCm = model.SizeCm,
                Scaling = model.Scaling,
                Description = model.Description,
                DocumentsAccessDescription = model.DocumentsAccessDescription,
                Features = model.Features,
                MicrofilmedCopyCount = model.MicrofilmedCopyCount,
                DigitizedCopyCount = model.DigitizedCopyCount,
                PaperCopyCount = model.PaperCopyCount,
                NegativeFrameCount = model.NegativeFrameCount,
                PositiveFrameCount = model.PositiveFrameCount,
                OtherCopyCount = model.OtherCopyCount,
                Notes = model.Notes,
                ApproxmateChronologicalScope = model.ApproximateChronologicalScope,
                StartDateYear = model.StartDateYear,
                StartDateMonth = model.StartDateMonth,
                StartDateDay = model.StartDateDay,
                EndDateYear = model.EndDateYear,
                EndDateMonth = model.EndDateMonth,
                EndDateDay = model.EndDateDay,
                HasExternalSource = model.HasExternalSource,
                ExternalIdentifier = model.ExternalIdentifier,
                IsImported = model.IsImported,
                DescriptionAuthor = model.DescriptionAuthor,

                Cypher = model.Cypher,
                TextDocsCount = model.TextDocsCount,
                GraphicalDocsCount = model.GraphicalDocsCount,
                Phase = model.Phase,
                Part = model.Part,
                Stage = model.Stage,
                OtherLanguage = model.OtherLanguage,
            };

            if (!model.AvailabilityStatusCode.HasValue)
            {
                documentDraft.AvailabilityStatusCode = (int)Shared.AvailabilityStatus.Enrollment;
            }

            if (model.HasExternalSource.HasValue && model.HasExternalSource.Value)
                documentDraft.ExternalSourceUpdatedOn = DateTime.UtcNow;

            _context.DocumentDrafts.Add(documentDraft);
            await _context.SaveAsync("Document draft created");

            if (model.OriginalityCodes?.Count() > 0)
            {
                var originalityValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.OriginalityCodes, null, Shared.NomenclatureCode.Originality,
                    documentDraft.Id, BusinessObjectType.Document, true);

                if (originalityValues != null)
                {
                    _context.NomenclatureValues.AddRange(originalityValues!);
                }
            }
            if (model.CreationMethodCodes?.Count() > 0)
            {
                var creationMethodValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.CreationMethodCodes, null, Shared.NomenclatureCode.CreationMethod,
                    documentDraft.Id, BusinessObjectType.Document, true);

                if (creationMethodValues != null)
                {
                    _context.NomenclatureValues.AddRange(creationMethodValues!);
                }
            }
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, null, Shared.NomenclatureCode.Language,
                    documentDraft.Id, BusinessObjectType.Document, true);

                if (languageValues != null)
                {
                    _context.NomenclatureValues.AddRange(languageValues!);
                }
            }
            if (model.FileTypeCodes?.Count() > 0)
            {
                var fileTypeValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.FileTypeCodes, null, Shared.NomenclatureCode.FileType,
                    documentDraft.Id, BusinessObjectType.Document, true);

                if (fileTypeValues != null)
                {
                    _context.NomenclatureValues.AddRange(fileTypeValues!);
                }
            }
            await _context.SaveAsync("Document draft created");

            return documentDraft.SystemIdentifier;
        }

        public async Task<OperationResult> CreateDraftAsync(DocumentDraftModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var documentSysId = await ((IDocumentServiceBase)this).CreateDraftInternalAsync(model);

                transaction.Commit();
                return OperationResult.Succeed(documentSysId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        async Task<Guid> IDocumentServiceBase.CreateDocumentInternalAsync(DocumentModel model, Guid? createdBy, DateTime? createdOn)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }
            if ((!model.HasExternalSource.HasValue || !model.HasExternalSource.Value) && !model.SystemIdentifier.HasValue)
            {
                throw new SystemIdentifierNullException(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            if (!model.SystemIdentifier.HasValue)
            {
                model.SystemIdentifier = Guid.NewGuid();
            }

            var document = new Document()
            {
                SystemIdentifier = model.SystemIdentifier!.Value,
                ArchiveId = model.ArchiveId!.Value,
                FundSystemIdentifier = model.FundSystemIdentifier!.Value,
                InventorySystemIdentifier = model.InventorySystemIdentifier!.Value,
                ArchivalEntitySystemIdentifier = model.ArchivalEntitySystemIdentifier!.Value,
                DescriptionLevelCode = model.DescriptionLevelCode,
                StatusCode = model.StatusCode,
                AvailabilityStatusCode = model.AvailabilityStatusCode,
                Number = model.Number,
                Title = model.Title,
                Author = model.Author,
                DigitalDevice = model.DigitalDevice,
                Duration = model.Duration,
                StartSheetNumber = model.StartSheetNumber,
                EndSheetNumber = model.EndSheetNumber,
                HasNoChronologicalScope = model.HasNoChronologicalScope,
                Transcription = model.Transcription,
                Location = model.Location,
                Bytes = model.Bytes,
                SheetCount = model.SheetCount,
                OtherMetrics = model.OtherMetrics,
                SizeCm = model.SizeCm,
                Scaling = model.Scaling,
                Description = model.Description,
                DocumentsAccessDescription = model.DocumentsAccessDescription,
                Features = model.Features,
                MicrofilmedCopyCount = model.MicrofilmedCopyCount,
                DigitizedCopyCount = model.DigitizedCopyCount,
                PaperCopyCount = model.PaperCopyCount,
                NegativeFrameCount = model.NegativeFrameCount,
                PositiveFrameCount = model.PositiveFrameCount,
                OtherCopyCount = model.OtherCopyCount,
                Notes = model.Notes,
                ApproxmateChronologicalScope = model.ApproximateChronologicalScope,
                StartDateYear = model.StartDateYear,
                StartDateMonth = model.StartDateMonth,
                StartDateDay = model.StartDateDay,
                EndDateYear = model.EndDateYear,
                EndDateMonth = model.EndDateMonth,
                EndDateDay = model.EndDateDay,
                HasExternalSource = model.HasExternalSource.HasValue ? model.HasExternalSource.Value : false,
                ExternalIdentifier = model.ExternalIdentifier,
                IsImported = model.IsImported,
                DescriptionAuthor = model.DescriptionAuthor,

                Cypher = model.Cypher,
                TextDocsCount = model.TextDocsCount,
                GraphicalDocsCount = model.GraphicalDocsCount,
                Phase = model.Phase,
                Part = model.Part,
                Stage = model.Stage,
                OtherLanguage = model.OtherLanguage,
            };

            if (!model.AvailabilityStatusCode.HasValue)
            {
                document.AvailabilityStatusCode = (int)Shared.AvailabilityStatus.Enrollment;
            }

            if (model.HasExternalSource.HasValue && model.HasExternalSource.Value)
                document.ExternalSourceUpdatedOn = DateTime.UtcNow;

            bool overwriteCreated = createdBy.HasValue && createdOn.HasValue;
            if (overwriteCreated)
            {
                document.CreatedBy = createdBy;
                document.CreatedOn = createdOn;
            }

            _context.Documents.Add(document);
            await _context.SaveAsync("Document created", overwriteCreated);

            if (model.OriginalityCodes?.Count() > 0)
            {
                var originalityValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.OriginalityCodes, null, Shared.NomenclatureCode.Originality,
                    document.Id, BusinessObjectType.Document, false,
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
                    document.Id, BusinessObjectType.Document, false,
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
                    document.Id, BusinessObjectType.Document, false,
                    overwriteCreated, createdBy, createdOn);

                if (languageValues != null)
                {
                    _context.NomenclatureValues.AddRange(languageValues!);
                }
            }
            if (model.FileTypeCodes?.Count() > 0)
            {
                var fileTypeValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.FileTypeCodes, null, Shared.NomenclatureCode.FileType,
                    document.Id, BusinessObjectType.Document, false,
                    overwriteCreated, createdBy, createdOn);

                if (fileTypeValues != null)
                {
                    _context.NomenclatureValues.AddRange(fileTypeValues!);
                }
            }

            await _context.SaveAsync("Document created", overwriteCreated);

            return document.SystemIdentifier;
        }

        public async Task<OperationResult> CreateDocumentAsync(DocumentModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            if ((!model.HasExternalSource.HasValue || !model.HasExternalSource.Value) && !model.SystemIdentifier.HasValue)
            {
                return OperationResult.Failed(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var documentSysId = await ((IDocumentServiceBase)this).CreateDocumentInternalAsync(model);

                transaction.Commit();
                return OperationResult.Succeed(documentSysId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        async Task<Guid> IDocumentServiceBase.CreateOrUpdateDocumentFromDraftInternalAsync(Guid sysId, bool overwriteCreatedFromDraft, bool overwriteModifiedFromDraft)
        {
            var documentDraft = await GetCurrentDraftAsync(sysId);
            if (documentDraft == null)
            {
                throw new ItemDraftNotCurrentException(_localizer.GetString("Error_DraftNotCurrent").ToString(), sysId.ToString());
            }

            Guid? createdBy = null;
            Guid? updatedBy = null;
            DateTime? createdOn = null;
            DateTime? updatedOn = null;

            if (overwriteCreatedFromDraft)
            {
                createdBy = documentDraft.CreatedBy;
                createdOn = documentDraft.CreatedOn;
            }
            if (overwriteModifiedFromDraft)
            {
                updatedBy = documentDraft.UpdatedBy ?? documentDraft.CreatedBy;
                updatedOn = documentDraft.UpdatedOn ?? documentDraft.CreatedOn;
            }

            var document =
                await _context.Documents
                .Where(doc => doc.SystemIdentifier == sysId && !doc.Deleted)
                .Select(doc => new DocumentModel()
                {
                    Id = doc.Id,
                    SystemIdentifier = doc.SystemIdentifier,
                    ArchiveId = doc.ArchiveId,
                    FundSystemIdentifier = doc.FundSystemIdentifier,
                    InventorySystemIdentifier = doc.InventorySystemIdentifier,
                    ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                    DescriptionLevelCode = doc.DescriptionLevelCode,
                    StatusCode = doc.StatusCode,
                    AvailabilityStatusCode = doc.AvailabilityStatusCode,
                    Number = doc.Number,
                    Title = doc.Title,
                    DigitalDevice = doc.DigitalDevice,
                    Duration = doc.Duration,
                    StartSheetNumber = doc.StartSheetNumber,
                    EndSheetNumber = doc.EndSheetNumber,
                    HasNoChronologicalScope = doc.HasNoChronologicalScope,
                    Transcription = doc.Transcription,
                    Location = doc.Location,
                    Bytes = doc.Bytes,
                    SheetCount = doc.SheetCount,
                    OtherMetrics = doc.OtherMetrics,
                    SizeCm = doc.SizeCm,
                    Scaling = doc.Scaling,
                    Description = doc.Description,
                    DocumentsAccessDescription = doc.DocumentsAccessDescription,
                    Features = doc.Features,
                    MicrofilmedCopyCount = doc.MicrofilmedCopyCount,
                    DigitizedCopyCount = doc.DigitizedCopyCount,
                    PaperCopyCount = doc.PaperCopyCount,
                    NegativeFrameCount = doc.NegativeFrameCount,
                    PositiveFrameCount = doc.PositiveFrameCount,
                    OtherCopyCount = doc.OtherCopyCount,
                    Notes = doc.Notes,
                    ApproximateChronologicalScope = doc.ApproxmateChronologicalScope,
                    StartDateYear = doc.StartDateYear,
                    StartDateMonth = doc.StartDateMonth,
                    StartDateDay = doc.StartDateDay,
                    EndDateYear = doc.EndDateYear,
                    EndDateMonth = doc.EndDateMonth,
                    EndDateDay = doc.EndDateDay,
                    HasExternalSource = doc.HasExternalSource,
                    ExternalIdentifier = doc.ExternalIdentifier,
                    Author = doc.Author,
                    FileFormatCode = doc.FileFormatCode,

                    Cypher = doc.Cypher,
                    TextDocsCount = doc.TextDocsCount,
                    GraphicalDocsCount = doc.GraphicalDocsCount,
                    Phase = doc.Phase,
                    Part = doc.Part,
                    Stage = doc.Stage,
                    OtherLanguage = doc.OtherLanguage,

                    FileTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(doc.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.FileType),
                    CreationMethodCodes = _nomenclatureService.GetEntityNomenclatureCodes(doc.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.CreationMethod),
                    OriginalityCodes = _nomenclatureService.GetEntityNomenclatureCodes(doc.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.Originality),
                    LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(doc.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.Language),
                })
                .SingleOrDefaultAsync();

            if (document != null)
            {
                document.SystemIdentifier = documentDraft.SystemIdentifier;
                document.ArchiveId = documentDraft.ArchiveId;
                document.FundSystemIdentifier = documentDraft.FundSystemIdentifier;
                document.InventorySystemIdentifier = documentDraft.InventorySystemIdentifier;
                document.ArchivalEntitySystemIdentifier = documentDraft.ArchivalEntitySystemIdentifier;
                document.DescriptionLevelCode = documentDraft.DescriptionLevelCode;
                document.StatusCode = documentDraft.StatusCode;
                document.AvailabilityStatusCode = documentDraft.AvailabilityStatusCode;
                document.Number = documentDraft.Number;
                document.Title = documentDraft.Title;
                document.DigitalDevice = documentDraft.DigitalDevice;
                document.Duration = documentDraft.Duration;
                document.StartSheetNumber = documentDraft.StartSheetNumber;
                document.EndSheetNumber = documentDraft.EndSheetNumber;
                document.HasNoChronologicalScope = documentDraft.HasNoChronologicalScope;
                document.Transcription = documentDraft.Transcription;
                document.Location = documentDraft.Location;
                document.Bytes = documentDraft.Bytes;
                document.SheetCount = documentDraft.SheetCount;
                document.OtherMetrics = documentDraft.OtherMetrics;
                document.SizeCm = documentDraft.SizeCm;
                document.Scaling = documentDraft.Scaling;
                document.Description = documentDraft.Description;
                document.DocumentsAccessDescription = documentDraft.DocumentsAccessDescription;
                document.Features = documentDraft.Features;
                document.MicrofilmedCopyCount = documentDraft.MicrofilmedCopyCount;
                document.DigitizedCopyCount = documentDraft.DigitizedCopyCount;
                document.PaperCopyCount = documentDraft.PaperCopyCount;
                document.NegativeFrameCount = documentDraft.NegativeFrameCount;
                document.PositiveFrameCount = documentDraft.PositiveFrameCount;
                document.OtherCopyCount = documentDraft.OtherCopyCount;
                document.Notes = documentDraft.Notes;
                document.ApproximateChronologicalScope = documentDraft.ApproximateChronologicalScope;
                document.StartDateYear = documentDraft.StartDateYear;
                document.StartDateMonth = documentDraft.StartDateMonth;
                document.StartDateDay = documentDraft.StartDateDay;
                document.EndDateYear = documentDraft.EndDateYear;
                document.EndDateMonth = documentDraft.EndDateMonth;
                document.EndDateDay = documentDraft.EndDateDay;
                document.HasExternalSource = documentDraft.HasExternalSource;
                document.ExternalIdentifier = documentDraft.ExternalIdentifier;
                document.Author = documentDraft.Author;
                document.FileFormatCode = documentDraft.FileFormatCode;
                document.CreationMethodCodes = documentDraft.CreationMethodCodes;
                document.LanguageCodes = documentDraft.LanguageCodes;
                document.OriginalityCodes = documentDraft.OriginalityCodes;
                document.FileTypeCodes = documentDraft.FileTypeCodes;

                document.Cypher = documentDraft.Cypher;
                document.TextDocsCount = documentDraft.TextDocsCount;
                document.GraphicalDocsCount = documentDraft.GraphicalDocsCount;
                document.Phase = documentDraft.Phase;
                document.Part = documentDraft.Part;
                document.Stage = documentDraft.Stage;
                document.OtherLanguage = documentDraft.OtherLanguage;

                document.Duration = _context.VDigitalObjects
                    .Where(d => d.DocumentSystemIdentifier == document.SystemIdentifier && !d.Deleted)
                    .Sum(d => d.Duration) ?? documentDraft.Duration;
                //await ((IDocumentServiceBase)this).UpdateDocumentInternalAsync(document);
                await ((IDocumentServiceBase)this).UpdateDocumentInternalAsync(document, updatedBy, updatedOn);
            }
            else
            {
                document = new DocumentModel()
                {
                    SystemIdentifier = documentDraft.SystemIdentifier,
                    ArchiveId = documentDraft.ArchiveId,
                    FundSystemIdentifier = documentDraft.FundSystemIdentifier,
                    InventorySystemIdentifier = documentDraft.InventorySystemIdentifier,
                    ArchivalEntitySystemIdentifier = documentDraft.ArchivalEntitySystemIdentifier,
                    DescriptionLevelCode = documentDraft.DescriptionLevelCode,
                    StatusCode = documentDraft.StatusCode,
                    AvailabilityStatusCode = documentDraft.AvailabilityStatusCode,
                    Number = documentDraft.Number,
                    Title = documentDraft.Title,
                    DigitalDevice = documentDraft.DigitalDevice,
                    Duration = documentDraft.Duration,
                    StartSheetNumber = documentDraft.StartSheetNumber,
                    EndSheetNumber = documentDraft.EndSheetNumber,
                    HasNoChronologicalScope = documentDraft.HasNoChronologicalScope,
                    Transcription = documentDraft.Transcription,
                    Location = documentDraft.Location,
                    Bytes = documentDraft.Bytes,
                    SheetCount = documentDraft.SheetCount,
                    OtherMetrics = documentDraft.OtherMetrics,
                    SizeCm = documentDraft.SizeCm,
                    Scaling = documentDraft.Scaling,
                    Description = documentDraft.Description,
                    DocumentsAccessDescription = documentDraft.DocumentsAccessDescription,
                    Features = documentDraft.Features,
                    MicrofilmedCopyCount = documentDraft.MicrofilmedCopyCount,
                    DigitizedCopyCount = documentDraft.DigitizedCopyCount,
                    PaperCopyCount = documentDraft.PaperCopyCount,
                    NegativeFrameCount = documentDraft.NegativeFrameCount,
                    PositiveFrameCount = documentDraft.PositiveFrameCount,
                    OtherCopyCount = documentDraft.OtherCopyCount,
                    Notes = documentDraft.Notes,
                    ApproximateChronologicalScope = documentDraft.ApproximateChronologicalScope,
                    StartDateYear = documentDraft.StartDateYear,
                    StartDateMonth = documentDraft.StartDateMonth,
                    StartDateDay = documentDraft.StartDateDay,
                    EndDateYear = documentDraft.EndDateYear,
                    EndDateMonth = documentDraft.EndDateMonth,
                    EndDateDay = documentDraft.EndDateDay,
                    HasExternalSource = documentDraft.HasExternalSource,
                    ExternalIdentifier = documentDraft.ExternalIdentifier,
                    Author = documentDraft.Author,
                    FileFormatCode = documentDraft.FileFormatCode,
                    CreationMethodCodes = documentDraft.CreationMethodCodes,
                    LanguageCodes = documentDraft.LanguageCodes,
                    OriginalityCodes = documentDraft.OriginalityCodes,
                    FileTypeCodes = documentDraft.FileTypeCodes,


                    Cypher = documentDraft.Cypher,
                    TextDocsCount = documentDraft.TextDocsCount,
                    GraphicalDocsCount = documentDraft.GraphicalDocsCount,
                    Phase = documentDraft.Phase,
                    Part = documentDraft.Part,
                    Stage = documentDraft.Stage,
                    OtherLanguage = documentDraft.OtherLanguage,
                };

                var duration = _context.VDigitalObjects
                     .Where(d => d.DocumentSystemIdentifier == document.SystemIdentifier && !d.Deleted)
                     .Sum(d => d.Duration);

                if (duration.HasValue && duration.Value > 0)
                {
                    document.Duration = duration;
                }
                else
                {
                    document.Duration = documentDraft.Duration;
                }
                //await ((IDocumentServiceBase)this).CreateDocumentInternalAsync(document);
                await ((IDocumentServiceBase)this).CreateDocumentInternalAsync(document, createdBy, createdOn);
            }

            var modifiedDocumentDraft = new DocumentDraftModel()
            {
                Id = documentDraft.Id,
                IsCurrent = false,
                ReadOnly = true,
                SystemIdentifier = documentDraft.SystemIdentifier,
                ArchiveId = documentDraft.ArchiveId,
                FundDraftId = documentDraft.FundDraftId,
                FundSystemIdentifier = documentDraft.FundSystemIdentifier!.Value,
                InventoryDraftId = documentDraft.InventoryDraftId,
                InventorySystemIdentifier = documentDraft.InventorySystemIdentifier,
                ArchivalEntityDraftId = documentDraft.ArchivalEntityDraftId,
                ArchivalEntitySystemIdentifier = documentDraft.ArchivalEntitySystemIdentifier,
                StatusCode = documentDraft.StatusCode,
                DescriptionLevelCode = documentDraft.DescriptionLevelCode,
                AvailabilityStatusCode = documentDraft.AvailabilityStatusCode,
                Number = documentDraft.Number,
                Title = documentDraft.Title,
                ApproximateChronologicalScope = documentDraft.ApproximateChronologicalScope,
                HasNoChronologicalScope = documentDraft.HasNoChronologicalScope,
                StartDateDay = documentDraft.StartDateDay,
                StartDateMonth = documentDraft.StartDateMonth,
                StartDateYear = documentDraft.StartDateYear,
                EndDateDay = documentDraft.EndDateDay,
                EndDateMonth = documentDraft.EndDateMonth,
                EndDateYear = documentDraft.EndDateYear,
                Author = documentDraft.Author,
                Description = documentDraft.Description,
                DigitizedCopyCount = documentDraft.DigitizedCopyCount,
                Features = documentDraft.Features,
                Location = documentDraft.Location,
                MicrofilmedCopyCount = documentDraft.MicrofilmedCopyCount,
                OtherCopyCount = documentDraft.OtherCopyCount,
                PaperCopyCount = documentDraft.PaperCopyCount,
                Scaling = documentDraft.Scaling,
                SheetCount = documentDraft.SheetCount,
                SizeCm = documentDraft.SizeCm,
                DocumentsAccessDescription = documentDraft.DocumentsAccessDescription,
                OtherMetrics = documentDraft.OtherMetrics,
                Notes = documentDraft.Notes,
                Bytes = documentDraft.Bytes,
                NegativeFrameCount = documentDraft.NegativeFrameCount,
                PositiveFrameCount = documentDraft.PositiveFrameCount,
                HasExternalSource = documentDraft.HasExternalSource,
                ExternalIdentifier = documentDraft.ExternalIdentifier,
                CreationMethodCodes = documentDraft.CreationMethodCodes,
                LanguageCodes = documentDraft.LanguageCodes,
                OriginalityCodes = documentDraft.OriginalityCodes,
                DigitalDevice = documentDraft.DigitalDevice,

                EndSheetNumber = documentDraft.EndSheetNumber,
                FileFormatCode = documentDraft.FileFormatCode,
                FileTypeCodes = documentDraft.FileTypeCodes,
                StartSheetNumber = documentDraft.StartSheetNumber,
                Transcription = documentDraft.Transcription,

                Cypher = documentDraft.Cypher,
                TextDocsCount = documentDraft.TextDocsCount,
                GraphicalDocsCount = documentDraft.GraphicalDocsCount,
                Phase = documentDraft.Phase,
                Part = documentDraft.Part,
                Stage = documentDraft.Stage,
                OtherLanguage = documentDraft.OtherLanguage,
            };

            modifiedDocumentDraft.Duration = _context.VDigitalObjects
                .Where(d => d.DocumentSystemIdentifier == document.SystemIdentifier && !d.Deleted)
                .Sum(d => d.Duration) ?? documentDraft.Duration;

            await ((IDocumentServiceBase)this).UpdateDraftInternalAsync(modifiedDocumentDraft);

            return sysId;
        }

        public async Task<OperationResult> CreateOrUpdateDocumentFromDraftAsync(Guid sysId)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await ((IDocumentServiceBase)this).CreateOrUpdateDocumentFromDraftInternalAsync(sysId);

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

        async Task<Guid> IDocumentServiceBase.UpdateDraftInternalAsync(DocumentDraftModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            if (!model.SystemIdentifier.HasValue)
            {
                throw new SystemIdentifierNullException(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            var currentdocumentDraft = await GetCurrentDraftAsync(model.SystemIdentifier.Value);
            if (currentdocumentDraft == null)
            {
                return await ((IDocumentServiceBase)this).CreateDraftInternalAsync(model);
            }

            bool isReadOnly = await IsReadOnlyDraftAsync(new DocumentDraftModel() { Id = currentdocumentDraft.Id });
            if (isReadOnly)
            {
                return await ((IDocumentServiceBase)this).CreateDraftInternalAsync(model);
            }

            //var documentDraft = await _context.DocumentDrafts.FindAsync(model.Id);
            var documentDraft = await _context.DocumentDrafts.FindAsync(currentdocumentDraft.Id);
            if (documentDraft == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            documentDraft.IsCurrent = model.IsCurrent;
            documentDraft.ReadOnly = model.ReadOnly;
            documentDraft.SystemIdentifier = model.SystemIdentifier!.Value;
            documentDraft.ArchiveId = model.ArchiveId!.Value;
            documentDraft.FundDraftId = model.FundDraftId;
            documentDraft.FundSystemIdentifier = model.FundSystemIdentifier!.Value;
            documentDraft.InventoryDraftId = model.InventoryDraftId;
            documentDraft.InventorySystemIdentifier = model.InventorySystemIdentifier!.Value;
            documentDraft.ArchivalEntityDraftId = model.ArchivalEntityDraftId;
            documentDraft.ArchivalEntitySystemIdentifier = model.ArchivalEntitySystemIdentifier!.Value;
            documentDraft.Number = model.Number;
            documentDraft.DescriptionLevelCode = model.DescriptionLevelCode;
            documentDraft.Title = model.Title;
            documentDraft.ApproxmateChronologicalScope = model.ApproximateChronologicalScope;
            documentDraft.Author = model.Author;
            documentDraft.Location = model.Location;
            documentDraft.Bytes = model.Bytes;
            documentDraft.SheetCount = model.SheetCount;
            documentDraft.OtherMetrics = model.OtherMetrics;
            documentDraft.SizeCm = model.SizeCm;
            documentDraft.Scaling = model.Scaling;
            documentDraft.Description = model.Description;
            documentDraft.DocumentsAccessDescription = model.DocumentsAccessDescription;
            documentDraft.Features = model.Features;
            documentDraft.MicrofilmedCopyCount = model.MicrofilmedCopyCount;
            documentDraft.DigitizedCopyCount = model.DigitizedCopyCount;
            documentDraft.PaperCopyCount = model.PaperCopyCount;
            documentDraft.NegativeFrameCount = model.NegativeFrameCount;
            documentDraft.PositiveFrameCount = model.PositiveFrameCount;
            documentDraft.OtherCopyCount = model.OtherCopyCount;
            documentDraft.DigitalDevice = model.DigitalDevice;

            documentDraft.StartSheetNumber = model.StartSheetNumber;
            documentDraft.EndSheetNumber = model.EndSheetNumber;
            documentDraft.HasNoChronologicalScope = model.HasNoChronologicalScope;
            documentDraft.Transcription = model.Transcription;
            documentDraft.Notes = model.Notes;
            documentDraft.StartDateYear = model.StartDateYear;
            documentDraft.StartDateMonth = model.StartDateMonth;
            documentDraft.StartDateDay = model.StartDateDay;
            documentDraft.EndDateYear = model.EndDateYear;
            documentDraft.EndDateMonth = model.EndDateMonth;
            documentDraft.EndDateDay = model.EndDateDay;
            documentDraft.StatusCode = model.StatusCode;
            documentDraft.AvailabilityStatusCode = model.AvailabilityStatusCode;
            documentDraft.HasExternalSource = model.HasExternalSource;
            documentDraft.ExternalIdentifier = model.ExternalIdentifier;

            documentDraft.IsImported = documentDraft.IsImported;
            documentDraft.DescriptionAuthor = documentDraft.DescriptionAuthor;
            documentDraft.Cypher = documentDraft.Cypher;
            documentDraft.TextDocsCount = documentDraft.TextDocsCount;
            documentDraft.GraphicalDocsCount = documentDraft.GraphicalDocsCount;
            documentDraft.Phase = documentDraft.Phase;
            documentDraft.Part = documentDraft.Part;
            documentDraft.Stage = documentDraft.Stage;
            documentDraft.OtherLanguage = documentDraft.OtherLanguage;

            if (model.HasExternalSource.HasValue && model.HasExternalSource.Value)
            {
                documentDraft.ExternalSourceUpdatedOn = DateTime.UtcNow;
            }

            var duration = _context.VDigitalObjects
                                 .Where(d => d.DocumentSystemIdentifier == documentDraft.SystemIdentifier
                                         && !d.Deleted)
                                 .Sum(d => d.Duration);

            if (duration.HasValue && duration.Value > 0)
            {
                documentDraft.Duration = duration;
            }
            else
            {
                documentDraft.Duration = model.Duration;
            }
            _context.Update(documentDraft);

            var documentNomenclatureValues = _nomenclatureService.GetEntityNomenclatureValues(
                documentDraft.Id, BusinessObjectType.Document, true, null);

            //Update originality values
            if (model.OriginalityCodes?.Count() > 0)
            {
                var originalityValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.OriginalityCodes, documentNomenclatureValues, Shared.NomenclatureCode.Originality,
                    documentDraft.Id, BusinessObjectType.Document, true);

                if (originalityValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(originalityValuesToAdd);
                }
            }

            var originalityValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.OriginalityCodes, documentNomenclatureValues, Shared.NomenclatureCode.Originality);

            if(originalityValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(originalityValuesToDelete);
            }

            //Update creation method values
            if (model.CreationMethodCodes?.Count() > 0)
            {
                var creationMethodValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.CreationMethodCodes, documentNomenclatureValues, Shared.NomenclatureCode.CreationMethod,
                    documentDraft.Id, BusinessObjectType.Document, true);

                if (creationMethodValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(creationMethodValuesToAdd);
                }
            }

            var creationMethodValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.CreationMethodCodes, documentNomenclatureValues, Shared.NomenclatureCode.CreationMethod);
            
            if(creationMethodValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(creationMethodValuesToDelete);
            }

            //Update language values
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, documentNomenclatureValues, Shared.NomenclatureCode.Language,
                    documentDraft.Id, BusinessObjectType.Document, true);

                if (languageValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(languageValuesToAdd);
                }
            }

            var languageValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.LanguageCodes, documentNomenclatureValues, Shared.NomenclatureCode.Language);

            if(languageValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(languageValuesToDelete);
            }

            //Update file type values
            if (model.FileTypeCodes?.Count() > 0)
            {
                var fileTypeValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.FileTypeCodes, documentNomenclatureValues, Shared.NomenclatureCode.FileType,
                    documentDraft.Id, BusinessObjectType.Document, true);

                if (fileTypeValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(fileTypeValuesToAdd);
                }
            }

            var fileTypeValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.FileTypeCodes, documentNomenclatureValues, Shared.NomenclatureCode.FileType);

            if(fileTypeValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(fileTypeValuesToDelete);
            }

            await _context.SaveAsync("Document draft updated");

            return documentDraft.SystemIdentifier;
        }

        public async Task<OperationResult> UpdateDraftAsync(DocumentDraftModel model)
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
                var documentSysId = await ((IDocumentServiceBase)this).UpdateDraftInternalAsync(model);

                transaction.Commit();
                return OperationResult.Succeed(documentSysId);
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

        async Task<Guid> IDocumentServiceBase.UpdateDocumentInternalAsync(DocumentModel model, Guid? updatedBy, DateTime? updatedOn)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            if (!model.SystemIdentifier.HasValue)
            {
                throw new SystemIdentifierNullException(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            var document = await _context.Documents.FindAsync(model.Id);
            if (document == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), model.Id!.Value.ToString());
            }

            document.ArchiveId = model.ArchiveId!.Value;
            document.FundSystemIdentifier = model.FundSystemIdentifier!.Value;
            document.InventorySystemIdentifier = model.InventorySystemIdentifier!.Value;
            document.ArchivalEntitySystemIdentifier = model.ArchivalEntitySystemIdentifier!.Value;
            document.Number = model.Number;
            document.Title = model.Title;
            document.DescriptionLevelCode = model.DescriptionLevelCode;
            document.StatusCode = model.StatusCode;
            document.AvailabilityStatusCode = model.AvailabilityStatusCode;
            document.HasNoChronologicalScope = model.HasNoChronologicalScope;
            document.StartDateYear = model.StartDateYear;
            document.StartDateMonth = model.StartDateMonth;
            document.StartDateDay = model.StartDateDay;
            document.EndDateYear = model.EndDateYear;
            document.EndDateMonth = model.EndDateMonth;
            document.EndDateDay = model.EndDateDay;
            document.ApproxmateChronologicalScope = model.ApproximateChronologicalScope;
            document.Author = model.Author;
            document.Location = model.Location;
            document.Bytes = model.Bytes;
            document.SheetCount = model.SheetCount;
            document.OtherMetrics = model.OtherMetrics;
            document.SizeCm = model.SizeCm;
            document.Scaling = model.Scaling;
            document.Description = model.Description;
            document.DocumentsAccessDescription = model.DocumentsAccessDescription;
            document.Features = model.Features;
            document.MicrofilmedCopyCount = model.MicrofilmedCopyCount;
            document.DigitizedCopyCount = model.DigitizedCopyCount;
            document.PaperCopyCount = model.PaperCopyCount;
            document.NegativeFrameCount = model.NegativeFrameCount;
            document.PositiveFrameCount = model.PositiveFrameCount;
            document.OtherCopyCount = model.OtherCopyCount;
            document.DigitalDevice = model.DigitalDevice;

            document.StartSheetNumber = model.StartSheetNumber;
            document.EndSheetNumber = model.EndSheetNumber;
            document.Transcription = model.Transcription;
            document.Notes = model.Notes;
            document.HasExternalSource = model.HasExternalSource.HasValue ? model.HasExternalSource.Value : false;
            document.ExternalIdentifier = model.ExternalIdentifier;

            document.IsImported = model.IsImported;
            document.DescriptionAuthor = model.DescriptionAuthor;
            document.Cypher = model.Cypher;
            document.TextDocsCount = model.TextDocsCount;
            document.GraphicalDocsCount = model.GraphicalDocsCount;
            document.Phase = model.Phase;
            document.Part = model.Part;
            document.Stage = model.Stage;
            document.OtherLanguage = model.OtherLanguage;

            if (model.HasExternalSource.HasValue && model.HasExternalSource.Value)
            {
                document.ExternalSourceUpdatedOn = DateTime.UtcNow;
            }

            bool overwriteModified = updatedBy.HasValue && updatedOn.HasValue;
            if (overwriteModified)
            {
                document.UpdatedBy = updatedBy;
                document.UpdatedOn = updatedOn;
            }

            var digObjDuration = _context.VDigitalObjects
                .Where(d => d.DocumentSystemIdentifier == document.SystemIdentifier
                        && !d.Deleted)
                .Sum(d => d.Duration);

            if (digObjDuration.HasValue && digObjDuration.Value > 0)
            {
                document.Duration = digObjDuration;
            }
            else
            {
                document.Duration = model.Duration;
            }
            _context.Update(document);

            var documentNomenclatureValues = _nomenclatureService.GetEntityNomenclatureValues(
                document.Id, BusinessObjectType.Document, false, null);

            //Update originality values
            if (model.OriginalityCodes?.Count() > 0)
            {
                var originalityValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.OriginalityCodes, documentNomenclatureValues, Shared.NomenclatureCode.Originality,
                    document.Id, BusinessObjectType.Document, false,
                    overwriteModified, updatedBy, updatedOn);

                if (originalityValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(originalityValuesToAdd);
                }
            }

            var originalityValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(model.OriginalityCodes, documentNomenclatureValues, Shared.NomenclatureCode.Originality);
            if(originalityValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(originalityValuesToDelete);
            }

            //Update creation method values
            if (model.CreationMethodCodes?.Count() > 0)
            {
                var creationMethodValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.CreationMethodCodes, documentNomenclatureValues, Shared.NomenclatureCode.CreationMethod,
                    document.Id, BusinessObjectType.Document, false,
                    overwriteModified, updatedBy, updatedOn);

                if (creationMethodValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(creationMethodValuesToAdd);
                }
            }

            var creationMethodValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.CreationMethodCodes, documentNomenclatureValues, Shared.NomenclatureCode.CreationMethod);

            if(creationMethodValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(creationMethodValuesToDelete);
            }

            //Update language values
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, documentNomenclatureValues, Shared.NomenclatureCode.Language,
                    document.Id, BusinessObjectType.Document, false,
                    overwriteModified, updatedBy, updatedOn);

                if (languageValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(languageValuesToAdd);
                }
            }

            var languageValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.LanguageCodes, documentNomenclatureValues, Shared.NomenclatureCode.Language);

            if(languageValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(languageValuesToDelete);
            }

            //Update file types
            if (model.FileTypeCodes?.Count() > 0)
            {
                var fileTypesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.FileTypeCodes, documentNomenclatureValues, Shared.NomenclatureCode.FileType,
                    document.Id, BusinessObjectType.Document, false,
                    overwriteModified, updatedBy, updatedOn);

                if (fileTypesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(fileTypesToAdd);
                }
            }

            var fileTypesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.FileTypeCodes, documentNomenclatureValues, Shared.NomenclatureCode.FileType);

            if(fileTypesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(fileTypesToDelete);
            }

            await _context.SaveAsync("Document updated", overwriteModified, overwriteModified);

            return document.SystemIdentifier;
        }

        public async Task<OperationResult> UpdateDocumentAsync(DocumentModel model)
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
                var documentSysId = await ((IDocumentServiceBase)this).UpdateDocumentInternalAsync(model);

                transaction.Commit();
                return OperationResult.Succeed(documentSysId);
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

        async System.Threading.Tasks.Task IDocumentServiceBase.DeleteDraftInternalAsync(int id)
        {
            var documentDraft = await _context.DocumentDrafts.FindAsync(id);
            if (documentDraft == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), id.ToString());
            }
            if (!documentDraft.IsCurrent)
            {
                throw new ItemDraftNotCurrentException(_localizer.GetString("Error_DraftNotCurrent").ToString(), id.ToString());
            }

            documentDraft.IsCurrent = false;
            documentDraft.ReadOnly = true;
            documentDraft.Deleted = true;
            documentDraft.DeletedOn = DateTime.UtcNow;
            documentDraft.DeletedBy = _userInfo.CurrentUserId;

            _context.Update(documentDraft);

            var entityNomValues = _nomenclatureService.GetEntityNomenclatureValues(documentDraft.Id, BusinessObjectType.Document, true, null);
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

            await _context.SaveAsync("Document draft deleted");
        }

        public async Task<OperationResult> DeleteDraftAsync(int id)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await ((IDocumentServiceBase)this).DeleteDraftInternalAsync(id);

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

        async System.Threading.Tasks.Task IDocumentServiceBase.DeleteDocumentInternalAsync(Guid sysId)
        {
            var documentDrafts =
                    _context.DocumentDrafts
                    .Where(d => d.SystemIdentifier == sysId && !d.Deleted)
                    .Select(d => d);

            await documentDrafts.ForEachAsync(d =>
            {
                d.IsCurrent = false;
                d.ReadOnly = true;
                d.Deleted = true;
                d.DeletedBy = _userInfo.CurrentUserId;
                d.DeletedOn = DateTime.UtcNow;
            });

            var draftNomValues = _nomenclatureService.GetEntityNomenclatureValues(documentDrafts.Select(d => d.Id).ToList(), BusinessObjectType.Document, true, null);
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

            var document =
                await _context.Documents
                .Where(d => d.SystemIdentifier == sysId && !d.Deleted)
                .SingleOrDefaultAsync();

            if (document != null)
            {
                document.Deleted = true;
                document.DeletedOn = DateTime.UtcNow;
                document.DeletedBy = _userInfo.CurrentUserId;

                _context.Update(document);

                var entityNomValues = _nomenclatureService.GetEntityNomenclatureValues(document.Id, BusinessObjectType.Document, false, null);
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

            await _context.SaveAsync("Document deleted");
        }

        public async Task<OperationResult> DeleteDocumentAsync(Guid sysId)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await ((IDocumentServiceBase)this).DeleteDocumentInternalAsync(sysId);

                transaction.Commit();
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<DocumentDisplayModel?> GetFromExternalSourceAsync(
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

            var archiveId = await _archiveService.GetArchiveIdByCodeAsync(result.ArchiveCode!.Value);
            if (!archivalEntitySystemIdentifier.HasValue)
            {
                archivalEntitySystemIdentifier = await _archivalEntityService.GetSystemIdentifierByExternalIdentifierAsync(result.ArchivalEntityExternalIdentifier!.Value);
            }
            if (!inventorySystemIdentifier.HasValue)
            {
                inventorySystemIdentifier = await _inventoryService.GetSystemIdentifierByExternalIdentifierAsync(result.InventoryExternalIdentifier!.Value);
            }
            if (!fundSystemIdentifier.HasValue)
            {
                fundSystemIdentifier = await _fundService.GetSystemIdentifierByExternalIdentifierAsync(result.FundExternalIdentifier!.Value);
            }

            DocumentDisplayModel model = new DocumentDisplayModel()
            {
                //Id = result.Id,
                SystemIdentifier = systemIdentifier,
                IsDraft = false,
                HasExternalSource = result.HasExternalSource,
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
                ArchivalEntitySystemIdentifier = archivalEntitySystemIdentifier,
                ArchivalEntityHasExternalSource = result.ArchivalEntityHasExternalSource ?? false,
                ArchivalEntityExternalIdentifier = result.ArchivalEntityExternalIdentifier,
                ArchivalEntityNumber = result.ArchivalEntityNumber,
                Number = result.Number,
                Title = result.Title,
                StatusCode = result.StatusCode!,
                StatusText = result.StatusText,
                DescriptionLevelCode =
                    !string.IsNullOrEmpty(result.DescriptionLevelCode)
                    ? DescriptionLevelMapping.DocumentDescriptionLevel.GetValueOrDefault(result.DescriptionLevelCode)!
                    : string.Empty,
                DescriptionLevelText = result.DescriptionLevelText,
                AvailabilityStatusCode = result.AvailabilityStatusCode,
                AvailabilityStatusText = result.AvailabilityStatusText,
                ApproximateChronologicalScope = result.ApproximateChronologicalScope,
                Location = result.Location,
                HasNoChronologicalScope = result.HasNoChronologicalScope ?? false,
                StartDateDay = result.StartDateDay,
                StartDateMonth = result.StartDateMonth,
                StartDateYear = result.StartDateYear,
                EndDateDay = result.EndDateDay,
                EndDateMonth = result.EndDateMonth,
                EndDateYear = result.EndDateYear,
                SizeCm = result.SizeCm,
                //Author = result.Author,
                //Scaling = result.Scaling,
                Description = result.Description,
                //DocumentsAccessDescription = result.DocumentsAccessDescription,
                Features = result.Features,
                MicrofilmedCopyCount = result.MicrofilmedCopyCount,
                DigitizedCopyCount = result.DigitizedCopyCount,
                PaperCopyCount = result.PaperCopyCount,
                NegativeFrameCount = result.NegativeFrameCount,
                PositiveFrameCount = result.PositiveFrameCount,
                OtherCopyCount = result.OtherCopyCount,
                //Transcription = result.Transcription,
                Notes = result.Notes,
                //Bytes = result.Bytes,
                //SheetCount = result.SheetCount,
                StartSheetNumber = result.StartSheetNumber,
                EndSheetNumber = result.EndSheetNumber,
                //DigitalDevice = result.DigitalDevice,
                //Duration = result.Duration,
                CreationMethodText = result.CreationMethodText,
                OriginalityText = result.OriginalityText,
                LanguageText = result.LanguageText,
                CreatedOn = result.CreatedOn,
                CreatedByDisplayName = result.CreatedByDisplayName,
                UpdatedOn = result.UpdatedOn,
                UpdatedByDisplayName = result.UpdatedByDisplayName,
                SheetCount = result.SheetCount,
                HasDigitizedDigitalObjects = result.HasDigitizedDigitalObjects,
            };

            if (systemIdentifier != null)
            {
                var sizeInfo = await _context.VDocumentSizeInfos
                   .Where(x => x.DocumentSystemIdentifier == systemIdentifier && x.IsDraft == 0)
                   .SingleOrDefaultAsync();
                if (sizeInfo != null)
                {
                    model.Bytes = sizeInfo.EnrolledBytes;
                    string fileTypes = sizeInfo.FileTypes != null
                        ? String.Join(
                            System.Globalization.CultureInfo.CurrentCulture.TextInfo.ListSeparator + " ",
                            sizeInfo.FileTypes.Split("; ").Distinct()).ToUpper()
                        : String.Empty;
                    model.FileTypeText = fileTypes;
                    model.Duration = sizeInfo.EnrolledDuration;
                }
            }

            return model;
        }

        public async Task<DocumentDisplayModel?> GetById(int id)
        {
            var document =
                await _context.VDocuments
                .Where(d => d.Id == id && !d.Deleted)
                .Select(d => new DocumentDisplayModel()
                {
                    Id = d.Id,
                    SystemIdentifier = d.SystemIdentifier,
                    IsDraft = false,
                    HasExternalSource = d.HasExternalSource ?? false,
                    ExternalIdentifier = d.ExternalIdentifier,
                    ExternalSourceUpdatedOn = d.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    ArchiveId = d.ArchiveId,
                    ArchiveCode = d.ArchiveCode,
                    ArchiveName = d.ArchiveName,
                    FundSystemIdentifier = d.FundSystemIdentifier,
                    FundHasExternalSource = d.FundHasExternalSource ?? false,
                    FundExternalIdentifier = d.FundExternalIdentifier,
                    FundNumber = d.FundNumber,
                    InventorySystemIdentifier = d.InventorySystemIdentifier,
                    InventoryHasExternalSource = d.InventoryHasExternalSource ?? false,
                    InventoryExternalIdentifier = d.InventoryExternalIdentifier,
                    InventoryNumber = d.InventoryNumber,
                    ArchivalEntitySystemIdentifier = d.ArchivalEntitySystemIdentifier,
                    ArchivalEntityHasExternalSource = d.ArchivalEntityHasExternalSource ?? false,
                    ArchivalEntityExternalIdentifier = d.ArchivalEntityExternalIdentifier,
                    ArchivalEntityNumber = d.ArchivalEntityNumber,
                    Number = d.Number,
                    Title = d.Title,
                    StatusCode = d.StatusCode!,
                    StatusText = d.StatusText,
                    DescriptionLevelCode = d.DescriptionLevelCode!,
                    DescriptionLevelText = d.DescriptionLevelText,
                    AvailabilityStatusCode = d.AvailabilityStatusCode,
                    AvailabilityStatusText = d.AvailabilityStatusText,
                    ApproximateChronologicalScope = d.ApproxmateChronologicalScope,
                    HasNoChronologicalScope = d.HasNoChronologicalScope,
                    StartDateDay = d.StartDateDay,
                    StartDateMonth = d.StartDateMonth,
                    StartDateYear = d.StartDateYear,
                    EndDateDay = d.EndDateDay,
                    EndDateMonth = d.EndDateMonth,
                    EndDateYear = d.EndDateYear,
                    DocumentsAccessDescription = d.DocumentsAccessDescription,
                    OtherMetrics = d.OtherMetrics,
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
                    SizeCm = d.SizeCm,
                    DigitalDevice = d.DigitalDevice,
                    Duration = d.Duration,
                    StartSheetNumber = d.StartSheetNumber,
                    EndSheetNumber = d.EndSheetNumber,
                    Transcription = d.Transcription,
                    CreatedBy = d.CreatedBy,
                    CreatedByDisplayName = d.CreatedByDisplayName,
                    CreatedByUserName = d.CreatedByUserName,
                    CreatedOn = d.CreatedOn.UtcToLocalTime(),
                    Deleted = d.Deleted,
                    DeletedBy = d.DeletedBy,
                    DeletedByDisplayName = d.DeletedByDisplayName,
                    DeletedByUserName = d.DeletedByUserName,
                    DeletedOn = d.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = d.UpdatedBy,
                    UpdatedByDisplayName = d.UpdatedByDisplayName,
                    UpdatedByUserName = d.UpdatedByUserName,
                    UpdatedOn = d.UpdatedOn.UtcToLocalTime(),

                    FileTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.FileType),
                    FileTypeText = _nomenclatureService.GetEntityNomenclatureText(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.FileType),
                    CreationMethodCodes = _nomenclatureService.GetEntityNomenclatureCodes(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.CreationMethod),
                    CreationMethodText = _nomenclatureService.GetEntityNomenclatureText(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.CreationMethod),
                    OriginalityCodes = _nomenclatureService.GetEntityNomenclatureCodes(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.Originality),
                    OriginalityText = _nomenclatureService.GetEntityNomenclatureText(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.Originality),
                    LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.Language),
                    LanguageText = _nomenclatureService.GetEntityNomenclatureText(d.Id, BusinessObjectType.Document, false, Shared.NomenclatureCode.Language),
                })
                .SingleOrDefaultAsync();

            return document;
        }

        public async Task<Guid?> GetSystemIdentifierByExternalIdentifierAsync(int externalIdentifier)
        {
            return
                await _context.Documents
                .Where(doc => doc.ExternalIdentifier == externalIdentifier)
                .Select(doc => doc.SystemIdentifier)
                .SingleOrDefaultAsync();
        }

        public async Task<int?> GetArchiveIdAsync(Guid sysId)
        {
            var entity =
                await _context.VDocuments
                .Where(x => x.SystemIdentifier == sysId && !x.Deleted)
                .SingleOrDefaultAsync();

            return entity?.ArchiveId;
        }

        public async Task<int?> GetArchiveIdByProcessIdAsync(int processId)
        {
            var process = await _context.Processes.FindAsync(processId);
            if (process != null)
            {
                var entity = await _context.VDocuments
                    .Where(x => x.SystemIdentifier == process.InventorySystemIdentifier && !x.Deleted)
                    .SingleOrDefaultAsync();

                return entity?.ArchiveId;
            }

            return null;
        }

        public async Task<int?> GetDescriptionLevelAsync(Guid sysId)
        {
            var document = await GetDocumentBySystemIdentifierAsync(sysId);
            if (document == null)
            {
                return null;
            }
            //var descriptionLevelCode = await _context.VDocuments
            //                            .Where(doc => doc.SystemIdentifier == sysId && (!doc.HasExternalSource.HasValue || !doc.HasExternalSource.Value) && !doc.Deleted)
            //                            .Select(doc => doc.DescriptionLevelCode)
            //                            .SingleOrDefaultAsync();

            //if(string.IsNullOrWhiteSpace(descriptionLevelCode))
            //{
            //    return null;
            //}

            //if (!int.TryParse(descriptionLevelCode, out var documentDescriptionLevel))
            //{
            //    _logger.LogError($"Error parsing description level code for document with sysId {sysId}");
            //    throw new InvalidDataException(nameof(descriptionLevelCode));
            //}
            if (!int.TryParse(document.DescriptionLevelCode, out var documentDescriptionLevel))
            {
                _logger.LogError($"Error parsing description level code for document with sysId {sysId}");
                throw new InvalidDataException(nameof(document.DescriptionLevelCode));
            }
            return documentDescriptionLevel;
        }

        public async Task<DataSourceResponseModel<PublicUserReviewDisplayModel>> GetDocumentPublicUsersReviewsAsync(Guid? systemIdentifier)
        {
            int totalCount = 0;
            IEnumerable<PublicUserReviewDisplayModel> items = Enumerable.Empty<PublicUserReviewDisplayModel>();
            List<object> errors = new List<object>();

            if (systemIdentifier.HasValue)
            {
                var publicUserReviews =
                    _context.UserReviews
                    .Where(r => r.DocumentSystemIdentifier == systemIdentifier.Value && r.User.UserType == ApplicationUserType.External)
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

        public async Task<OperationResult?> CreateDocumentReviewAsync(Guid? documentSystemIdentifier, int? documentExternalIdentifier)
        {
            Guid systemIdentifier = Guid.NewGuid();

            UserReview employeeReview = new UserReview
            {
                SystemIdentifier = systemIdentifier,
                UserId = _userInfo.CurrentUserId.Value,
                Date = DateTime.UtcNow
            };

            if ((documentSystemIdentifier.HasValue && documentSystemIdentifier.Value != Guid.Empty) || documentExternalIdentifier.HasValue)
            {
                if (documentSystemIdentifier.HasValue && documentSystemIdentifier.Value != Guid.Empty)
                {
                    employeeReview.DocumentSystemIdentifier = documentSystemIdentifier.Value;
                }
                if (documentExternalIdentifier.HasValue)
                {
                    employeeReview.DocumentExternalIdentifier = documentExternalIdentifier;
                }
            }
            else
            {
                return OperationResult.Succeed("No review for missing document system identifier");
            }

            await _context.UserReviews.AddAsync(employeeReview);
            await _context.SaveAsync("Employee review created");

            return OperationResult.Success;
        }

        public async Task<bool> AnyUnnumberedByArchivalEntityIdentifier(Guid aeSysId)
        {
            return await _context.Documents
                    .Where(d =>
                            d.ArchivalEntitySystemIdentifier == aeSysId
                            && string.IsNullOrWhiteSpace(d.Number)
                            && !d.Deleted
                            && !d.HasExternalSource)
                    .AnyAsync();
        }

        public async Task<bool> AnyUnnumberedDraftsByArchivalEntityIdentifier(Guid aeSysId)
        {
            return await _context.DocumentDrafts
                    .Where(d =>
                            d.ArchivalEntitySystemIdentifier == aeSysId
                            && string.IsNullOrWhiteSpace(d.Number)
                            && !d.Deleted
                            && (!d.HasExternalSource.HasValue || !d.HasExternalSource.Value))
                    .AnyAsync();
        }

        public async Task<bool> AnyUnnumberedByInventoryIdentifier(Guid inventorySysId)
        {
            return await _context.Documents
                    .Where(d =>
                            d.InventorySystemIdentifier == inventorySysId
                            && string.IsNullOrWhiteSpace(d.Number)
                            && !d.Deleted
                            && !d.HasExternalSource)
                    .AnyAsync();
        }

        public async Task<bool> AnyUnnumberedDraftsByInventoryIdentifier(Guid inventorySysId)
        {
            return await _context.DocumentDrafts
                    .Where(d =>
                            d.InventorySystemIdentifier == inventorySysId
                            && string.IsNullOrWhiteSpace(d.Number)
                            && !d.Deleted
                            && (!d.HasExternalSource.HasValue || !d.HasExternalSource.Value))
                    .AnyAsync();
        }

        public async Task<bool> AnyUnnumberedByFundIdentifier(Guid fundSysId)
        {
            return await _context.Documents
                    .Where(d =>
                            d.FundSystemIdentifier == fundSysId
                            && string.IsNullOrWhiteSpace(d.Number)
                            && !d.Deleted
                            && !d.HasExternalSource)
                    .AnyAsync();
        }

        public async Task<bool> AnyUnnumberedDraftsByFundIdentifier(Guid fundSysId)
        {
            return await _context.DocumentDrafts
                    .Where(d =>
                            d.FundSystemIdentifier == fundSysId
                            && string.IsNullOrWhiteSpace(d.Number)
                            && d.IsCurrent
                            && !d.Deleted
                            && (!d.HasExternalSource.HasValue || !d.HasExternalSource.Value))
                    .AnyAsync();
        }
    }
}
