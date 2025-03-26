using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Extensions.Models;
using DAA.Models;
using DAA.Models.Configuration;
using DAA.Models.Inventories;
using DAA.Models.Processes;
using DAA.Models.Tasks;
using DAA.Services.Applications;
using DAA.Services.Funds;
using DAA.Services.Nomenclatures;
using DAA.Services.Notifications;
using DAA.Services.Process;
using DAA.Services.Tasks;
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
using Task = System.Threading.Tasks.Task;

namespace DAA.Services.Inventories
{
    public class InventoryService : BaseService, IInventoryService
    {
        private readonly LinkedServerSettings _settings;
        private readonly IUserInfo _userInfo;
        private readonly INomenclatureService _nomenclatureService;
        private readonly IArchiveService _archiveService;
        private readonly IFundService _fundService;
        private readonly IProcessService _processService;
        private readonly IApplicationsService _applicationService;
        private readonly INotificationEventService _notificationEventService;
        private readonly ITaskService _taskService;

        public InventoryService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IOptions<LinkedServerSettings> settings,
            IUserInfo userInfo,
            INomenclatureService nomenclatureService,
            IArchiveService archiveService,
            IFundService fundService,
            IProcessService processService,
            IApplicationsService applicationService,
            INotificationEventService notificationEventService,
            ITaskService taskService,
            ILogger<IInventoryService> logger)
            : base(context, localizer, logger)
        {
            _settings = settings.Value;
            _userInfo = userInfo;
            _nomenclatureService = nomenclatureService;
            _archiveService = archiveService;
            _fundService = fundService;
            _processService = processService;
            _applicationService = applicationService;
            _notificationEventService = notificationEventService;
            _taskService = taskService;
        }

        public DataSourceResponseModel<InventoryDisplayModel> GetAll(DataSourceRequestModel model, bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.VInventories
                .OrderBy(i => i.NumberNumeric).ThenBy(i => i.NumberArray).ThenBy(i => i.CreatedOn)
                .Select(i => new InventoryDisplayModel()
                {
                    Id = i.Id,
                    SystemIdentifier = i.SystemIdentifier,
                    IsDraft = i.IsDraft!.Value,
                    ArchiveId = i.ArchiveId,
                    ArchiveName = i.ArchiveName,
                    FundSystemIdentifier = i.FundSystemIdentifier,
                    FundHasExternalSource = i.FundHasExternalSource ?? false,
                    FundExternalIdentifier = i.FundExternalIdentifier,
                    FundNumber = i.FundNumber,
                    NumberArray = i.NumberArray,
                    NumberNumeric = i.NumberNumeric,
                    Number = i.Number,
                    StatusCode = i.StatusCode!,
                    StatusText = i.StatusText,
                    AvailabilityStatusCode = i.AvailabilityStatusCode,
                    AvailabilityStatusText = i.AvailabilityStatusText,
                    DescriptionLevelCode = i.DescriptionLevelCode!,
                    DescriptionLevelText = i.DescriptionLevelText,
                    AcquisitionMethodId = i.AcquisitionMethodId,
                    AcquisitionMethodText = i.AcquisitionMethodText,
                    HasExternalSource = i.HasExternalSource!.Value,
                    ExternalIdentifier = i.ExternalIdentifier,
                    ExternalSourceUpdatedOn = i.ExternalSourceUpdatedOn,
                    CreatedBy = i.CreatedBy,
                    CreatedByDisplayName = i.CreatedByDisplayName,
                    CreatedByUserName = i.CreatedByUserName,
                    CreatedOn = i.CreatedOn,
                    Deleted = i.Deleted,
                    DeletedBy = i.DeletedBy,
                    DeletedByDisplayName = i.DeletedByDisplayName,
                    DeletedByUserName = i.DeletedByUserName,
                    DeletedOn = i.DeletedOn,
                    UpdatedBy = i.UpdatedBy,
                    UpdatedByDisplayName = i.UpdatedByDisplayName,
                    UpdatedByUserName = i.UpdatedByUserName,
                    UpdatedOn = i.UpdatedOn,
                });
            if (!includeDeleted)
            {
                query = query.Where(i => !i.Deleted);
            }

            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }

            QueryResponseModel<InventoryDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<InventoryDisplayModel> result = new DataSourceResponseModel<InventoryDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => new InventoryDisplayModel()
                {
                    Id = x.Id,
                    SystemIdentifier = x.SystemIdentifier,
                    IsDraft = x.IsDraft,
                    ArchiveId = x.ArchiveId,
                    ArchiveName = x.ArchiveName,
                    FundSystemIdentifier = x.FundSystemIdentifier,
                    FundHasExternalSource = x.FundHasExternalSource,
                    FundExternalIdentifier = x.FundExternalIdentifier,
                    FundNumber = x.FundNumber,
                    NumberArray = x.NumberArray,
                    NumberNumeric = x.NumberNumeric,
                    Number = x.Number,
                    StatusCode = x.StatusCode!,
                    StatusText = x.StatusText,
                    AvailabilityStatusCode = x.AvailabilityStatusCode,
                    AvailabilityStatusText = x.AvailabilityStatusText,
                    DescriptionLevelCode = x.DescriptionLevelCode!,
                    DescriptionLevelText = x.DescriptionLevelText,
                    AcquisitionMethodId = x.AcquisitionMethodId,
                    AcquisitionMethodText = x.AcquisitionMethodText,
                    HasExternalSource = x.HasExternalSource,
                    ExternalIdentifier = x.ExternalIdentifier,
                    ExternalSourceUpdatedOn = x.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    CreatedBy = x.CreatedBy,
                    CreatedByDisplayName = x.CreatedByDisplayName,
                    CreatedByUserName = x.CreatedByUserName,
                    CreatedOn = x.CreatedOn.UtcToLocalTime(),
                    Deleted = x.Deleted,
                    DeletedBy = x.DeletedBy,
                    DeletedByDisplayName = x.DeletedByDisplayName,
                    DeletedByUserName = x.DeletedByUserName,
                    DeletedOn = x.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = x.UpdatedBy,
                    UpdatedByDisplayName = x.UpdatedByDisplayName,
                    UpdatedByUserName = x.UpdatedByUserName,
                    UpdatedOn = x.UpdatedOn.UtcToLocalTime(),
                })
            };

            return result;
        }

        public DataSourceResponseModel<InventoryDisplayModel> GetAll(DataSourceRequestModel model, bool includeDrafts, bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            if (includeDrafts)
            {
                return GetAll(model, includeDeleted);
            }

            var query =
                _context.Inventories
                .OrderBy(i => i.FundSystemIdentifierNavigation.NumberNumeric)
                .ThenBy(i => i.FundSystemIdentifierNavigation.NumberArray)
                .ThenBy(i => i.NumberNumeric)
                .ThenBy(i => i.NumberArray)
                .Select(i => new InventoryDisplayModel()
                {
                    Id = i.Id,
                    SystemIdentifier = i.SystemIdentifier,
                    IsDraft = false,
                    ArchiveId = i.ArchiveId,
                    ArchiveName = i.Archive.Name,
                    FundSystemIdentifier = i.FundSystemIdentifier,
                    FundHasExternalSource = i.FundSystemIdentifierNavigation.HasExternalSource,
                    FundExternalIdentifier = i.FundSystemIdentifierNavigation.ExternalIdentifier,
                    FundNumber = i.FundSystemIdentifierNavigation.Number,
                    NumberArray = i.NumberArray,
                    NumberNumeric = i.NumberNumeric,
                    Number = i.Number,
                    StatusCode = i.StatusCode!,
                    StatusText = i.StatusCodeNavigation!.Text,
                    AvailabilityStatusCode = i.AvailabilityStatusCode,
                    AvailabilityStatusText = i.AvailabilityStatusCodeNavigation!.Text,
                    DescriptionLevelCode = i.DescriptionLevelCode!,
                    DescriptionLevelText = i.DescriptionLevelCodeNavigation!.Text,
                    AcquisitionMethodId = i.AcquisitionMethodId,
                    AcquisitionMethodText = i.AcquisitionMethod!.Text,
                    HasExternalSource = i.HasExternalSource,
                    ExternalIdentifier = i.ExternalIdentifier,
                    ExternalSourceUpdatedOn = i.ExternalSourceUpdatedOn,
                    CreatedBy = i.CreatedBy,
                    CreatedByDisplayName = i.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == i.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = i.CreatedByNavigation.UserName,
                    CreatedOn = i.CreatedOn,
                    Deleted = i.Deleted,
                    DeletedBy = i.DeletedBy,
                    DeletedByDisplayName = i.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == i.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = i.DeletedByNavigation.UserName,
                    DeletedOn = i.DeletedOn,
                    UpdatedBy = i.UpdatedBy,
                    UpdatedByDisplayName = i.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == i.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = i.UpdatedByNavigation.UserName,
                    UpdatedOn = i.UpdatedOn,
                });
            if (!includeDeleted)
            {
                query = query.Where(i => !i.Deleted);
            }

            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }

            QueryResponseModel<InventoryDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<InventoryDisplayModel> result = new DataSourceResponseModel<InventoryDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => new InventoryDisplayModel()
                {
                    Id = x.Id,
                    SystemIdentifier = x.SystemIdentifier,
                    IsDraft = x.IsDraft,
                    ArchiveId = x.ArchiveId,
                    ArchiveName = x.ArchiveName,
                    FundSystemIdentifier = x.FundSystemIdentifier,
                    FundHasExternalSource = x.FundHasExternalSource,
                    FundExternalIdentifier = x.FundExternalIdentifier,
                    FundNumber = x.FundNumber,
                    NumberArray = x.NumberArray,
                    NumberNumeric = x.NumberNumeric,
                    Number = x.Number,
                    StatusCode = x.StatusCode,
                    StatusText = x.StatusText,
                    AvailabilityStatusCode = x.AvailabilityStatusCode,
                    AvailabilityStatusText = x.AvailabilityStatusText,
                    DescriptionLevelCode = x.DescriptionLevelCode!,
                    DescriptionLevelText = x.DescriptionLevelText,
                    AcquisitionMethodId = x.AcquisitionMethodId,
                    AcquisitionMethodText = x.AcquisitionMethodText,
                    HasExternalSource = x.HasExternalSource,
                    ExternalIdentifier = x.ExternalIdentifier,
                    ExternalSourceUpdatedOn = x.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    CreatedBy = x.CreatedBy,
                    CreatedByDisplayName = x.CreatedByDisplayName,
                    CreatedByUserName = x.CreatedByUserName,
                    CreatedOn = x.CreatedOn.UtcToLocalTime(),
                    Deleted = x.Deleted,
                    DeletedBy = x.DeletedBy,
                    DeletedByDisplayName = x.DeletedByDisplayName,
                    DeletedByUserName = x.DeletedByUserName,
                    DeletedOn = x.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = x.UpdatedBy,
                    UpdatedByDisplayName = x.UpdatedByDisplayName,
                    UpdatedByUserName = x.UpdatedByUserName,
                    UpdatedOn = x.UpdatedOn.UtcToLocalTime(),
                })
            };

            return result;
        }

        public DataSourceResponseModel<InventoryDisplayModel> GetByAvailabilityStatus(
            DataSourceRequestModel model,
            int availabilityStatus,
            Guid fundSystemIdentifier,
            bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.VInventories
                .Where(d =>
                    d.FundSystemIdentifier == fundSystemIdentifier
                    && d.AvailabilityStatusCode == availabilityStatus)
                .OrderBy(d => d.NumberNumeric).ThenBy(d => d.NumberArray).ThenBy(d => d.CreatedOn)
                .Select(d => new InventoryDisplayModel()
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
                    Number = d.Number,
                    StatusCode = d.StatusCode!,
                    StatusText = d.StatusText,
                    DescriptionLevelCode = d.DescriptionLevelCode!,
                    DescriptionLevelText = d.DescriptionLevelText,
                    AvailabilityStatusCode = d.AvailabilityStatusCode,
                    AvailabilityStatusText = d.AvailabilityStatusText,
                    AcquisitionMethodId = d.AcquisitionMethodId,
                    AcquisitionMethodText = d.AcquisitionMethodText,
                    ApproxmateChronologicalScope = d.ApproxmateChronologicalScope,
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

            QueryResponseModel<InventoryDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<InventoryDisplayModel> result = new DataSourceResponseModel<InventoryDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => new InventoryDisplayModel()
                {
                    Id = x.Id,
                    SystemIdentifier = x.SystemIdentifier,
                    IsDraft = x.IsDraft,
                    HasExternalSource = x.HasExternalSource,
                    ExternalIdentifier = x.ExternalIdentifier,
                    ExternalSourceUpdatedOn = x.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    ArchiveId = x.ArchiveId,
                    ArchiveCode = x.ArchiveCode,
                    ArchiveName = x.ArchiveName,
                    FundDraftId = x.FundDraftId,
                    FundSystemIdentifier = x.FundSystemIdentifier,
                    FundHasExternalSource = x.FundHasExternalSource,
                    FundExternalIdentifier = x.FundExternalIdentifier,
                    FundNumber = x.FundNumber,
                    Number = x.Number,
                    StatusCode = x.StatusCode!,
                    StatusText = x.StatusText,
                    DescriptionLevelCode = x.DescriptionLevelCode!,
                    DescriptionLevelText = x.DescriptionLevelText,
                    AvailabilityStatusCode = x.AvailabilityStatusCode,
                    AvailabilityStatusText = x.AvailabilityStatusText,
                    AcquisitionMethodId = x.AcquisitionMethodId,
                    AcquisitionMethodText = x.AcquisitionMethodText,
                    ApproxmateChronologicalScope = x.ApproxmateChronologicalScope,
                    CreatedBy = x.CreatedBy,
                    CreatedByDisplayName = x.CreatedByDisplayName,
                    CreatedByUserName = x.CreatedByUserName,
                    CreatedOn = x.CreatedOn.UtcToLocalTime(),
                    UpdatedBy = x.UpdatedBy,
                    UpdatedByDisplayName = x.UpdatedByDisplayName,
                    UpdatedByUserName = x.UpdatedByUserName,
                    UpdatedOn = x.UpdatedOn.UtcToLocalTime(),
                    Deleted = x.Deleted,
                    DeletedBy = x.DeletedBy,
                    DeletedByDisplayName = x.DeletedByDisplayName,
                    DeletedByUserName = x.DeletedByUserName,
                    DeletedOn = x.DeletedOn.UtcToLocalTime(),
                })
            };

            return result;
        }

        public async Task<DataSourceResponseModel<InventoryDisplayModel>> GetByFundIdentifier(DataSourceRequestModel model, Guid? fundSysId, bool fundHasExternalSource = false, int? fundExternalIdentifier = null, bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            int totalCount = 0;
            IEnumerable<InventoryDisplayModel> items = Enumerable.Empty<InventoryDisplayModel>();
            List<object> errors = new List<object>();

            try
            {
                string countQuery = "exec @ReturnValue = sp_GetFundInventoriesCount @LinkedServer, @FundIdentifier, @FundHasExternalSource, @FundExternalIdentifier";
                List<SqlParameter> countQueryParams = new List<SqlParameter>()
                {
                    new SqlParameter("LinkedServer", _settings.LinkedServer),
                    new SqlParameter("FundIdentifier", fundSysId.HasValue ? fundSysId.Value : DBNull.Value),
                    new SqlParameter("FundHasExternalSource", fundHasExternalSource),
                    new SqlParameter("FundExternalIdentifier", fundExternalIdentifier.HasValue ? fundExternalIdentifier.Value : DBNull.Value),
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
            catch (SqlException exc)
            {
                _logger.LogWarning(exc, $"Error getting fund inventories count from external source (fundSysId: {fundSysId}, fundHasExternalSource: {fundHasExternalSource}, fundExternalIdentifier: {fundExternalIdentifier})");
                // най-вероятно случай с липса на връзка с ИСДА, затова не логвай грешка; за това ще се появи warning
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting fund inventories count from external source (fundSysId: {fundSysId}, fundHasExternalSource: {fundHasExternalSource}, fundExternalIdentifier: {fundExternalIdentifier})");
                errors.Add(exc.ToString());
            }

            try
            {
                string query = "exec sp_GetFundInventories @LinkedServer, @FundIdentifier, @FundHasExternalSource, @FundExternalIdentifier, @Paging, @PageNumber, @PageSize";
                List<SqlParameter> queryParams = new List<SqlParameter>()
                {
                    new SqlParameter("LinkedServer", _settings.LinkedServer),
                    //new SqlParameter("FundIdentifier", fundId.HasValue ? fundId.Value : DBNull.Value),
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
                    queryResult.Select(i => new InventoryDisplayModel()
                    {
                        Id = i.Id,
                        SystemIdentifier = i.SystemIdentifier,
                        HasExternalSource = i.HasExternalSource ?? false,
                        ExternalIdentifier = i.ExternalIdentifier,
                        ArchiveCode = i.ArchiveCode,
                        ArchiveName = i.ArchiveName,
                        FundHasExternalSource = i.FundHasExternalSource ?? false,
                        FundExternalIdentifier = i.FundExternalIdentifier,
                        FundNumber = i.FundNumber,
                        NumberArray = i.NumberArray,
                        NumberNumeric = i.NumberNumeric,
                        Number = i.Number,
                        StatusCode = i.StatusCode!,
                        StatusText = i.StatusText,
                        AvailabilityStatusCode = i.AvailabilityStatusCode,
                        AvailabilityStatusText = i.AvailabilityStatusText,
                        DescriptionLevelCode = i.DescriptionLevelCode!,
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
                        ClassificationScheme = i.ClassificationScheme,
                        AbbreviationList = i.AbbreviationList,
                        MicrofilmedArchivalEntityCount = i.MicrofilmedArchivalEntityCount,
                        DigitizedArchivalEntityCount = i.DigitizedArchivalEntityCount,
                        NegativeFrameCount = i.NegativeFrameCount,
                        PositiveFrameCount = i.PositiveFrameCount,
                        CreatedOn = i.CreatedOn,
                        CreatedByDisplayName = i.CreatedByDisplayName,
                        UpdatedOn = i.UpdatedOn,
                        UpdatedByDisplayName = i.UpdatedByDisplayName,
                        DeductedAECount = i.DeductedAECount,
                        DeductedBytes = i.DeductedBytes,
                        DeductedLinearMeters = i.DeductedLinearMeters,
                        EnrolledAECount = i.EnrolledAECount,
                        EnrolledLinearMeters = i.EnrolledLinearMeters,
                        EnrolledBytes = i.EnrolledBytes,
                    });

                items = items.Select(x =>
                {

                    x.SystemIdentifier = x.HasExternalSource == true ? _context.Inventories
                   .Where(i => i.ExternalIdentifier == x.ExternalIdentifier && !i.Deleted)
                   .Select(i => i.SystemIdentifier)
                   .FirstOrDefault()
                   : x.SystemIdentifier;

                    x.IsInProcess = _context.Processes
                          .Where(p => p.InventorySystemIdentifier.HasValue && p.InventorySystemIdentifier == x.SystemIdentifier && !p.Completed && !p.Deleted)
                          .Any();

                    return x;
                }).ToList();

            }
            catch (SqlException exc)
            {
                _logger.LogWarning(exc, $"Error getting fund inventories from external source (fundSysId: {fundSysId}, fundHasExternalSource: {fundHasExternalSource}, fundExternalIdentifier: {fundExternalIdentifier})");
                //errors.Add(exc.ToString());

                if (fundSysId.HasValue)
                {
                    var localQuery =
                        _context.VInventories
                        .Where(inv => inv.FundSystemIdentifier == fundSysId.Value && !inv.Deleted);

                    if (!includeDeleted)
                    {
                        localQuery = localQuery.Where(i => !i.Deleted);
                    }

                    var localQueryDisplayModel = localQuery
                        .OrderBy(inv => inv.NumberNumeric).ThenBy(inv => inv.NumberArray).ThenBy(inv => inv.CreatedOn)
                        .Select(i => new InventoryDisplayModel()
                        {
                            Id = i.Id,
                            SystemIdentifier = i.SystemIdentifier,
                            HasExternalSource = i.HasExternalSource ?? false,
                            ExternalIdentifier = i.ExternalIdentifier,
                            ArchiveCode = i.ArchiveCode,
                            ArchiveName = i.ArchiveName,
                            FundHasExternalSource = i.FundHasExternalSource ?? false,
                            FundExternalIdentifier = i.FundExternalIdentifier,
                            FundNumber = i.FundNumber,
                            NumberArray = i.NumberArray,
                            NumberNumeric = i.NumberNumeric,
                            Number = i.Number,
                            StatusCode = i.StatusCode!,
                            StatusText = i.StatusText,
                            AvailabilityStatusCode = i.AvailabilityStatusCode,
                            AvailabilityStatusText = i.AvailabilityStatusText,
                            DescriptionLevelCode = i.DescriptionLevelCode!,
                            DescriptionLevelText = i.DescriptionLevelText,
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
                            ClassificationScheme = i.ClassificationScheme,
                            AbbreviationList = i.AbbreviationList,
                            MicrofilmedArchivalEntityCount = i.MicrofilmedArchivalEntityCount,
                            DigitizedArchivalEntityCount = i.DigitizedArchivalEntityCount,
                            NegativeFrameCount = i.NegativeFrameCount,
                            PositiveFrameCount = i.PositiveFrameCount,
                            CreatedOn = i.CreatedOn,
                            CreatedByDisplayName = i.CreatedByDisplayName,
                            UpdatedOn = i.UpdatedOn,
                            UpdatedByDisplayName = i.UpdatedByDisplayName,
                        });

                    //слага се флаг IsInProcess заради разлиакта във визуализацията на клиента.

                    foreach (var item in localQueryDisplayModel)
                    {
                        item.IsInProcess = await _context.Processes
                              .Where(p => p.InventorySystemIdentifier.HasValue && p.InventorySystemIdentifier == item.SystemIdentifier && !p.Completed)
                              .AnyAsync();
                    }

                    if (!string.IsNullOrWhiteSpace(model.SearchString))
                    {
                        localQueryDisplayModel = localQueryDisplayModel.FilterBySearchText(model.SearchString);
                    }

                    totalCount = (await localQuery.ToListAsync()).Count();
                    items = await localQueryDisplayModel.Select(i => new InventoryDisplayModel()
                    {
                        Id = i.Id,
                        SystemIdentifier = i.SystemIdentifier,
                        HasExternalSource = i.HasExternalSource,
                        ExternalIdentifier = i.ExternalIdentifier,
                        ArchiveCode = i.ArchiveCode,
                        ArchiveName = i.ArchiveName,
                        FundHasExternalSource = i.FundHasExternalSource,
                        FundExternalIdentifier = i.FundExternalIdentifier,
                        FundNumber = i.FundNumber,
                        NumberArray = i.NumberArray,
                        NumberNumeric = i.NumberNumeric,
                        Number = i.Number,
                        StatusCode = i.StatusCode!,
                        StatusText = i.StatusText,
                        AvailabilityStatusCode = i.AvailabilityStatusCode,
                        AvailabilityStatusText = i.AvailabilityStatusText,
                        DescriptionLevelCode = i.DescriptionLevelCode!,
                        DescriptionLevelText = i.DescriptionLevelText,
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
                        ClassificationScheme = i.ClassificationScheme,
                        AbbreviationList = i.AbbreviationList,
                        MicrofilmedArchivalEntityCount = i.MicrofilmedArchivalEntityCount,
                        DigitizedArchivalEntityCount = i.DigitizedArchivalEntityCount,
                        NegativeFrameCount = i.NegativeFrameCount,
                        PositiveFrameCount = i.PositiveFrameCount,
                        CreatedOn = i.CreatedOn.UtcToLocalTime(),
                        CreatedByDisplayName = i.CreatedByDisplayName,
                        UpdatedOn = i.UpdatedOn.UtcToLocalTime(),
                        UpdatedByDisplayName = i.UpdatedByDisplayName
                    }).ToListAsync();
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting fund inventories (fundSysId: {fundSysId}, fundHasExternalSource: {fundHasExternalSource}, fundExternalIdentifier: {fundExternalIdentifier})");
                errors.Add(exc.ToString());
            }

            DataSourceResponseModel<InventoryDisplayModel> result = new DataSourceResponseModel<InventoryDisplayModel>()
            {
                TotalCount = totalCount,
                Errors = errors.Count > 0 ? errors : null,
                Items = items
            };

            return result;
        }

        public async Task<bool> AnyUnnumberedDraftsByFundIdentifier(Guid fundSysId)
        {
            return await _context.InventoryDrafts
                    .Where(inv =>
                            inv.FundSystemIdentifier == fundSysId
                            && inv.IsCurrent
                            && string.IsNullOrWhiteSpace(inv.Number)
                            && !inv.Deleted
                            && (!inv.HasExternalSource.HasValue || !inv.HasExternalSource.Value))
                    .AnyAsync();
        }

        public async Task<InventoryDisplayModel?> GetInventoryByIdAsync(int id)
        {
            var inventory =
                await _context.Inventories
                .Where(inv => inv.Id == id && !inv.Deleted)
                .Select(inv => new InventoryDisplayModel()
                {
                    Id = inv.Id,
                    SystemIdentifier = inv.SystemIdentifier,
                    ArchiveId = inv.ArchiveId,
                    ArchiveName = inv.Archive.Name,
                    FundSystemIdentifier = inv.FundSystemIdentifier,
                    FundHasExternalSource = inv.FundSystemIdentifierNavigation.HasExternalSource,
                    FundExternalIdentifier = inv.FundSystemIdentifierNavigation.ExternalIdentifier,
                    FundNumber = inv.FundSystemIdentifierNavigation.Number,
                    NumberArray = inv.NumberArray,
                    NumberNumeric = inv.NumberNumeric,
                    Number = inv.Number,
                    StatusCode = inv.StatusCode!,
                    StatusText = inv.StatusCodeNavigation!.Text,
                    AvailabilityStatusCode = inv.AvailabilityStatusCode,
                    AvailabilityStatusText = inv.AvailabilityStatusCodeNavigation!.Text,
                    DescriptionLevelCode = inv.DescriptionLevelCode!,
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
                    ClassificationScheme = inv.ClassificationScheme,
                    AbbreviationList = inv.AbbreviationList,
                    Bytes = inv.Bytes,
                    ArchivalEntityCount = inv.ArchivalEntityCount,
                    DocumentCount = inv.DocumentCount,
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
                    HasExternalSource = inv.HasExternalSource,
                    ExternalIdentifier = inv.ExternalIdentifier,
                    ExternalSourceUpdatedOn = inv.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    CreatedBy = inv.CreatedBy,
                    CreatedByDisplayName = inv.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == inv.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = inv.CreatedByNavigation.UserName,
                    CreatedOn = inv.CreatedOn.UtcToLocalTime(),
                    Deleted = inv.Deleted,
                    DeletedBy = inv.DeletedBy,
                    DeletedByDisplayName = inv.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == inv.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = inv.DeletedByNavigation.UserName,
                    DeletedOn = inv.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = inv.UpdatedBy,
                    UpdatedByDisplayName = inv.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == inv.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = inv.UpdatedByNavigation.UserName,
                    UpdatedOn = inv.UpdatedOn.UtcToLocalTime(),
                    ApplicationId = inv.ApplicationId,
                    PackageAId = inv.PackageAid,
                    PackageBId = inv.PackageBid,

                    AcquisitionMethodId = inv.AcquisitionMethodId,
                    AcquisitionMethodText = inv.AcquisitionMethod!.Text,

                    FileTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.FileType),
                    FileTypeText = _nomenclatureService.GetEntityNomenclatureText(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.FileType),
                    CreationMethodCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.CreationMethod),
                    CreationMethodText = _nomenclatureService.GetEntityNomenclatureText(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.CreationMethod),
                    OriginalityCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.Originality),
                    OriginalityText = _nomenclatureService.GetEntityNomenclatureText(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.Originality),
                    LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.Language),
                    LanguageText = _nomenclatureService.GetEntityNomenclatureText(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.Language),
                })
                .SingleOrDefaultAsync();

            if (inventory != null && inventory.HasExternalSource && inventory.ExternalIdentifier.HasValue)
            {
                inventory = await GetFromExternalSourceAsync(inventory.ExternalIdentifier.Value);
            }

            return inventory;
        }

        public async Task<InventoryDisplayModel?> GetInventoryBySystemIdentifierAsync(Guid sysId)
        {
            var inventoryDraft = await GetCurrentDraftAsync(sysId);
            if (inventoryDraft != null)
            {
                var sizeInfo = await _context.VInventorySizeInfos
                    .Where(x => x.InventorySystemIdentifier == sysId && x.IsDraft == 1)
                    .SingleOrDefaultAsync();
                if (sizeInfo != null)
                {
                    inventoryDraft.ArchivalEntityCount = sizeInfo.EnrolledArchivalEntityCount;
                    inventoryDraft.DigitalDocumentArchivalEntityCount = sizeInfo.EnrolledArchivalEntityCount;
                    inventoryDraft.DocumentCount = sizeInfo.EnrolledDocumentCount;
                    inventoryDraft.Bytes = sizeInfo.EnrolledBytes;
                    string fileTypes = sizeInfo.FileTypes != null
                        ? String.Join(
                            System.Globalization.CultureInfo.CurrentCulture.TextInfo.ListSeparator + " ",
                            sizeInfo.FileTypes.Split("; ").Distinct()).ToUpper()
                        : String.Empty;
                    inventoryDraft.FileTypeText = fileTypes;
                    inventoryDraft.TextDocsCount = sizeInfo.TextDocsCount;
                    inventoryDraft.GraphicalDocsCount = sizeInfo.GraphicalDocsCount;
                }

                return inventoryDraft;
            }

            var inventory =
                await _context.Inventories
                .Where(inv => inv.SystemIdentifier == sysId && !inv.Deleted)
                .Select(inv => new InventoryDisplayModel()
                {
                    Id = inv.Id,
                    SystemIdentifier = inv.SystemIdentifier,
                    IsDraft = false,
                    ArchiveId = inv.ArchiveId,
                    ArchiveCode = inv.Archive.Code,
                    ArchiveName = inv.Archive.Name,
                    FundSystemIdentifier = inv.FundSystemIdentifier,
                    FundHasExternalSource = inv.FundSystemIdentifierNavigation.HasExternalSource,
                    FundExternalIdentifier = inv.FundSystemIdentifierNavigation.ExternalIdentifier,
                    FundNumber = inv.FundSystemIdentifierNavigation.Number,
                    NumberArray = inv.NumberArray,
                    NumberNumeric = inv.NumberNumeric,
                    Number = inv.Number,
                    StatusCode = inv.StatusCode!,
                    StatusText = inv.StatusCodeNavigation!.Text,
                    AvailabilityStatusCode = inv.AvailabilityStatusCode,
                    AvailabilityStatusText = inv.AvailabilityStatusCodeNavigation!.Text,
                    DescriptionLevelCode = inv.DescriptionLevelCode!,
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
                    ClassificationScheme = inv.ClassificationScheme,
                    AbbreviationList = inv.AbbreviationList,
                    Bytes = inv.Bytes,
                    ArchivalEntityCount = inv.ArchivalEntityCount,
                    DocumentCount = inv.DocumentCount,
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
                    HasExternalSource = inv.HasExternalSource,
                    ExternalIdentifier = inv.ExternalIdentifier,
                    ExternalSourceUpdatedOn = inv.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    CreatedBy = inv.CreatedBy,
                    CreatedByDisplayName = inv.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == inv.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = inv.CreatedByNavigation.UserName,
                    CreatedOn = inv.CreatedOn.UtcToLocalTime(),
                    Deleted = inv.Deleted,
                    DeletedBy = inv.DeletedBy,
                    DeletedByDisplayName = inv.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == inv.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = inv.DeletedByNavigation.UserName,
                    DeletedOn = inv.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = inv.UpdatedBy,
                    UpdatedByDisplayName = inv.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == inv.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = inv.UpdatedByNavigation.UserName,
                    UpdatedOn = inv.UpdatedOn.UtcToLocalTime(),
                    ApplicationId = inv.ApplicationId,
                    HasSystemApplication = inv.Application != null ? inv.Application.IsSystem : false,
                    PackageAId = inv.PackageAid,
                    PackageBId = inv.PackageBid,
                    PackageCId = inv.PackageCid,
                    IsInPersonalFund =
                        (_context.Funds.Where(x => x.SystemIdentifier == inv.FundSystemIdentifier)
                        .Select(x => x.TypeCode).FirstOrDefault()) == ((int)Shared.FundType.Personal).ToString(),

                    AcquisitionMethodId = inv.AcquisitionMethodId,
                    AcquisitionMethodText = inv.AcquisitionMethod!.Text,

                    FileTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.FileType),
                    FileTypeText = _nomenclatureService.GetEntityNomenclatureText(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.FileType),
                    CreationMethodCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.CreationMethod),
                    CreationMethodText = _nomenclatureService.GetEntityNomenclatureText(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.CreationMethod),
                    OriginalityCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.Originality),
                    OriginalityText = _nomenclatureService.GetEntityNomenclatureText(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.Originality),
                    LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.Language),
                    LanguageText = _nomenclatureService.GetEntityNomenclatureText(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.Language),
                    OtherLanguage = inv.OtherLanguage,
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
                    inventory.DeductedBytes = sizeInfo.DeductedBytes;
                    string fileTypes = sizeInfo.FileTypes != null
                        ? String.Join(
                            System.Globalization.CultureInfo.CurrentCulture.TextInfo.ListSeparator + " ",
                            sizeInfo.FileTypes.Split("; ").Distinct()).ToUpper()
                        : String.Empty;
                    inventory.FileTypeText = fileTypes;
                    inventory.TextDocsCount = sizeInfo.TextDocsCount;
                    inventory.GraphicalDocsCount = sizeInfo.GraphicalDocsCount;
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
                catch (Exception exc)
                {
                    _logger.LogWarning(exc, "Error retrieving inventory data from ISDA");

                    inventory!.ResultMessage = Constants.ISDADataCannotBeDisplayedMessageKey; // тук, ако няма inventory, вече трябва да се хвърли грешка
                }
            }

            return inventory;
        }

        public async Task<InventoryDisplayModel?> GetInventoryBySystemIdentifierAsync(Guid sysId, bool includeDrafts)
        {
            if (includeDrafts)
            {
                return await GetInventoryBySystemIdentifierAsync(sysId);
            }

            var inventory =
                await _context.Inventories
                .Where(inv => inv.SystemIdentifier == sysId && !inv.Deleted)
                .Select(inv => new InventoryDisplayModel()
                {
                    Id = inv.Id,
                    SystemIdentifier = inv.SystemIdentifier,
                    IsDraft = false,
                    ArchiveId = inv.ArchiveId,
                    ArchiveCode = inv.Archive.Code,
                    ArchiveName = inv.Archive.Name,
                    FundSystemIdentifier = inv.FundSystemIdentifier,
                    FundHasExternalSource = inv.FundSystemIdentifierNavigation.HasExternalSource,
                    FundExternalIdentifier = inv.FundSystemIdentifierNavigation.ExternalIdentifier,
                    FundNumber = inv.FundSystemIdentifierNavigation.Number,
                    NumberArray = inv.NumberArray,
                    NumberNumeric = inv.NumberNumeric,
                    Number = inv.Number,
                    StatusCode = inv.StatusCode!,
                    StatusText = inv.StatusCodeNavigation!.Text,
                    AvailabilityStatusCode = inv.AvailabilityStatusCode,
                    AvailabilityStatusText = inv.AvailabilityStatusCodeNavigation!.Text,
                    DescriptionLevelCode = inv.DescriptionLevelCode!,
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
                    ClassificationScheme = inv.ClassificationScheme,
                    AbbreviationList = inv.AbbreviationList,
                    Bytes = inv.Bytes,
                    ArchivalEntityCount = inv.ArchivalEntityCount,
                    DocumentCount = inv.DocumentCount,
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
                    HasExternalSource = inv.HasExternalSource,
                    ExternalIdentifier = inv.ExternalIdentifier,
                    ExternalSourceUpdatedOn = inv.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    CreatedBy = inv.CreatedBy,
                    CreatedByDisplayName = inv.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == inv.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = inv.CreatedByNavigation.UserName,
                    CreatedOn = inv.CreatedOn.UtcToLocalTime(),
                    Deleted = inv.Deleted,
                    DeletedBy = inv.DeletedBy,
                    DeletedByDisplayName = inv.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == inv.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = inv.DeletedByNavigation.UserName,
                    DeletedOn = inv.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = inv.UpdatedBy,
                    UpdatedByDisplayName = inv.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == inv.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = inv.UpdatedByNavigation.UserName,
                    UpdatedOn = inv.UpdatedOn.UtcToLocalTime(),
                    ApplicationId = inv.ApplicationId,
                    HasSystemApplication = inv.Application != null ? inv.Application.IsSystem : false,
                    PackageAId = inv.PackageAid,
                    PackageBId = inv.PackageBid,
                    PackageCId = inv.PackageCid,
                    AcquisitionMethodId = inv.AcquisitionMethodId,
                    AcquisitionMethodText = inv.AcquisitionMethod!.Text,

                    FileTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.FileType),
                    FileTypeText = _nomenclatureService.GetEntityNomenclatureText(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.FileType),
                    CreationMethodCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.CreationMethod),
                    CreationMethodText = _nomenclatureService.GetEntityNomenclatureText(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.CreationMethod),
                    OriginalityCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.Originality),
                    OriginalityText = _nomenclatureService.GetEntityNomenclatureText(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.Originality),
                    LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.Language),
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
                    inventory.DeductedBytes = sizeInfo.DeductedBytes;
                    string fileTypes = sizeInfo.FileTypes != null
                        ? String.Join(
                            System.Globalization.CultureInfo.CurrentCulture.TextInfo.ListSeparator + " ",
                            sizeInfo.FileTypes.Split("; ").Distinct()).ToUpper()
                        : String.Empty;
                    inventory.FileTypeText = fileTypes;
                    inventory.TextDocsCount = sizeInfo.TextDocsCount;
                    inventory.GraphicalDocsCount = sizeInfo.GraphicalDocsCount;
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

        public async Task<InventoryDisplayModel?> GetCurrentDraftAsync(Guid sysId)
        {
            var inventoryDraft =
                await _context.InventoryDrafts
                    .GroupJoin(
                        _context.Funds,
                        inv => inv.FundSystemIdentifier,
                        fund => fund.SystemIdentifier,
                        (draft, fund) => new { Draft = draft, Fund = fund })
                    .SelectMany(inv => inv.Fund.DefaultIfEmpty(),
                        (draft, fund) => new { Draft = draft, Fund = fund })
                    .Where(inv => inv.Draft.Draft.SystemIdentifier == sysId && inv.Draft.Draft.IsCurrent && !inv.Draft.Draft.Deleted)
                    .Select(inv => new InventoryDisplayModel()
                    {
                        Id = inv.Draft.Draft.Id,
                        SystemIdentifier = inv.Draft.Draft.SystemIdentifier,
                        IsDraft = true,
                        ArchiveId = inv.Draft.Draft.ArchiveId,
                        ArchiveName = inv.Draft.Draft.Archive.Name,
                        ArchiveCode = inv.Draft.Draft.Archive.Code,
                        FundDraftId = inv.Draft.Draft.FundDraftId,
                        FundSystemIdentifier = inv.Draft.Draft.FundSystemIdentifier,
                        FundHasExternalSource = inv.Draft.Draft.FundDraft!.HasExternalSource ?? inv.Fund!.HasExternalSource,
                        FundExternalIdentifier = inv.Fund!.ExternalIdentifier,
                        FundNumber = inv.Fund.Number,
                        NumberArray = inv.Draft.Draft.NumberArray,
                        NumberNumeric = inv.Draft.Draft.NumberNumeric,
                        Number = inv.Draft.Draft.Number,
                        StatusCode = inv.Draft.Draft.StatusCode!,
                        StatusText = inv.Draft.Draft.StatusCodeNavigation!.Text,
                        AvailabilityStatusCode = inv.Draft.Draft.AvailabilityStatusCode,
                        AvailabilityStatusText = inv.Draft.Draft.AvailabilityStatusCodeNavigation!.Text,
                        DescriptionLevelCode = inv.Draft.Draft.DescriptionLevelCode!,
                        DescriptionLevelText = inv.Draft.Draft.DescriptionLevelCodeNavigation!.Text,
                        ApproxmateChronologicalScope = inv.Draft.Draft.ApproxmateChronologicalScope,
                        HasNoChronologicalScope = inv.Draft.Draft.HasNoChronologicalScope,
                        StartDateDay = inv.Draft.Draft.StartDateDay,
                        StartDateMonth = inv.Draft.Draft.StartDateMonth,
                        StartDateYear = inv.Draft.Draft.StartDateYear,
                        EndDateDay = inv.Draft.Draft.EndDateDay,
                        EndDateMonth = inv.Draft.Draft.EndDateMonth,
                        EndDateYear = inv.Draft.Draft.EndDateYear,
                        FundCreatorBiographicalHistory = inv.Draft.Draft.FundCreatorBiographicalHistory,
                        FundCreatorTitleHistory = inv.Draft.Draft.FundCreatorTitleHistory,
                        History = inv.Draft.Draft.History,
                        DocumentsAccessDescription = inv.Draft.Draft.DocumentsAccessDescription,
                        DocumentsDescription = inv.Draft.Draft.DocumentsDescription,
                        DocumentsProvider = inv.Draft.Draft.DocumentsProvider,
                        LinearMeters = inv.Draft.Draft.LinearMeters,
                        OtherMetrics = inv.Draft.Draft.OtherMetrics,
                        Notes = inv.Draft.Draft.Notes,
                        ClassificationScheme = inv.Draft.Draft.ClassificationScheme,
                        AbbreviationList = inv.Draft.Draft.AbbreviationList,
                        Bytes = inv.Draft.Draft.Bytes,
                        ArchivalEntityCount = inv.Draft.Draft.ArchivalEntityCount,
                        DocumentCount = inv.Draft.Draft.DocumentCount,
                        DigitizedArchivalEntityCount = inv.Draft.Draft.DigitizedArchivalEntityCount,
                        AudioDocumentArchivalEntityCount = inv.Draft.Draft.AudioDocumentArchivalEntityCount,
                        DigitalDocumentArchivalEntityCount = inv.Draft.Draft.DigitalDocumentArchivalEntityCount,
                        MicrofilmedArchivalEntityCount = inv.Draft.Draft.MicrofilmedArchivalEntityCount,
                        PhotoDocumentArchivalEntityCount = inv.Draft.Draft.PhotoDocumentArchivalEntityCount,
                        VideoDocumentArchivalEntityCount = inv.Draft.Draft.VideoDocumentArchivalEntityCount,
                        NegativeFrameCount = inv.Draft.Draft.NegativeFrameCount,
                        PositiveFrameCount = inv.Draft.Draft.PositiveFrameCount,
                        BoxCount = inv.Draft.Draft.BoxCount,
                        RollCount = inv.Draft.Draft.RollCount,
                        HasExternalSource = inv.Draft.Draft.HasExternalSource ?? false,
                        ExternalIdentifier = inv.Draft.Draft.ExternalIdentifier,
                        ExternalSourceUpdatedOn = inv.Draft.Draft.ExternalSourceUpdatedOn.UtcToLocalTime(),
                        CreatedBy = inv.Draft.Draft.CreatedBy,
                        CreatedByDisplayName = inv.Draft.Draft.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == inv.Draft.Draft.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                        CreatedByUserName = inv.Draft.Draft.CreatedByNavigation.UserName,
                        CreatedOn = inv.Draft.Draft.CreatedOn.UtcToLocalTime(),
                        Deleted = inv.Draft.Draft.Deleted,
                        DeletedBy = inv.Draft.Draft.DeletedBy,
                        DeletedByDisplayName = inv.Draft.Draft.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == inv.Draft.Draft.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                        DeletedByUserName = inv.Draft.Draft.DeletedByNavigation.UserName,
                        DeletedOn = inv.Draft.Draft.DeletedOn.UtcToLocalTime(),
                        UpdatedBy = inv.Draft.Draft.UpdatedBy,
                        UpdatedByDisplayName = inv.Draft.Draft.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == inv.Draft.Draft.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                        UpdatedByUserName = inv.Draft.Draft.UpdatedByNavigation.UserName,
                        UpdatedOn = inv.Draft.Draft.UpdatedOn.UtcToLocalTime(),
                        ApplicationId = inv.Draft.Draft.ApplicationId,
                        HasSystemApplication = inv.Draft.Draft.Application != null ? inv.Draft.Draft.Application.IsSystem : false,
                        PackageAId = inv.Draft.Draft.PackageAid,
                        PackageBId = inv.Draft.Draft.PackageBid,
                        IsInPersonalFund = (inv.Draft.Draft.FundDraft!.TypeCode ?? inv.Fund!.TypeCode) == ((int)Shared.FundType.Personal).ToString(),

                        AcquisitionMethodId = inv.Draft.Draft.AcquisitionMethodId,
                        AcquisitionMethodText = inv.Draft.Draft.AcquisitionMethod!.Text,
                        FileTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Draft.Draft.Id, BusinessObjectType.Inventory, true, Shared.NomenclatureCode.FileType),
                        FileTypeText = _nomenclatureService.GetEntityNomenclatureText(inv.Draft.Draft.Id, BusinessObjectType.Inventory, true, Shared.NomenclatureCode.FileType),
                        CreationMethodCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Draft.Draft.Id, BusinessObjectType.Inventory, true, Shared.NomenclatureCode.CreationMethod),
                        CreationMethodText = _nomenclatureService.GetEntityNomenclatureText(inv.Draft.Draft.Id, BusinessObjectType.Inventory, true, Shared.NomenclatureCode.CreationMethod),
                        OriginalityCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Draft.Draft.Id, BusinessObjectType.Inventory, true, Shared.NomenclatureCode.Originality),
                        OriginalityText = _nomenclatureService.GetEntityNomenclatureText(inv.Draft.Draft.Id, BusinessObjectType.Inventory, true, Shared.NomenclatureCode.Originality),
                        LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Draft.Draft.Id, BusinessObjectType.Inventory, true, Shared.NomenclatureCode.Language),
                        LanguageText = _nomenclatureService.GetEntityNomenclatureText(inv.Draft.Draft.Id, BusinessObjectType.Inventory, true, Shared.NomenclatureCode.Language),
                        OtherLanguage = inv.Draft.Draft.OtherLanguage,
                    })
                .SingleOrDefaultAsync();

            return inventoryDraft;
        }

        public async Task<bool> HasCurrentDraftAsync(Guid sysId)
        {
            return await _context.InventoryDrafts
                    .Where(inv => inv.SystemIdentifier == sysId && inv.IsCurrent && !inv.Deleted)
                    .AnyAsync();
        }

        public async Task<bool> IsCurrentDraftAsync(InventoryDraftModel model)
        {
            return await _context.InventoryDrafts.Where(inv => inv.Id == model.Id && inv.IsCurrent && !inv.Deleted).AnyAsync();
        }

        public async Task<bool> IsReadOnlyDraftAsync(InventoryDraftModel model)
        {
            return await _context.InventoryDrafts.Where(inv => inv.Id == model.Id && (inv.ReadOnly || !inv.IsCurrent || inv.Deleted)).AnyAsync();
        }

        async Task<Guid> IInventoryServiceBase.CreateDraftInternalAsync(InventoryDraftModel model, bool checkRelatedProcess)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            //If there is new fund draft on edit
            if (!model.FundDraftId.HasValue)
            {
                var fundDraft = await _fundService.GetCurrentDraftAsync(model.FundSystemIdentifier!.Value);
                if (fundDraft != null)
                {
                    model.FundDraftId = fundDraft.Id;
                }
            }

            if (!model.SystemIdentifier.HasValue)
            {
                model.SystemIdentifier = Guid.NewGuid();
            }
            else
            {
                var currentDraft =
                    await _context.InventoryDrafts
                    .Where(inv => inv.SystemIdentifier == model.SystemIdentifier && inv.IsCurrent)
                    .SingleOrDefaultAsync();
                if (currentDraft != null)
                {
                    currentDraft.IsCurrent = false;
                    currentDraft.ReadOnly = true;
                    _context.Update(currentDraft);
                }
            }

            var inventoryDraft = new InventoryDraft
            {
                IsCurrent = true,
                ReadOnly = false,
                SystemIdentifier = model.SystemIdentifier!.Value,
                ArchiveId = model.ArchiveId,
                FundDraftId = model.FundDraftId,
                FundSystemIdentifier = model.FundSystemIdentifier!.Value,
                NumberArray = model.NumberArray,
                NumberNumeric = model.NumberNumeric,
                Number = model.Number,
                StatusCode = model.StatusCode,
                AvailabilityStatusCode = model.AvailabilityStatusCode,
                DescriptionLevelCode = model.DescriptionLevelCode,
                AcquisitionMethodId = model.AcquisitionMethodId,
                ApproxmateChronologicalScope = model.ApproxmateChronologicalScope,
                HasNoChronologicalScope = model.HasNoChronologicalScope,
                StartDateDay = model.StartDateDay,
                StartDateMonth = model.StartDateMonth,
                StartDateYear = model.StartDateYear,
                EndDateDay = model.EndDateDay,
                EndDateMonth = model.EndDateMonth,
                EndDateYear = model.EndDateYear,
                FundCreatorBiographicalHistory = model.FundCreatorBiographicalHistory,
                FundCreatorTitleHistory = model.FundCreatorTitleHistory,
                History = model.History,
                DocumentsAccessDescription = model.DocumentsAccessDescription,
                DocumentsDescription = model.DocumentsDescription,
                DocumentsProvider = model.DocumentsProvider,
                LinearMeters = model.LinearMeters,
                OtherMetrics = model.OtherMetrics,
                Notes = model.Notes,
                ClassificationScheme = model.ClassificationScheme,
                AbbreviationList = model.AbbreviationList,
                Bytes = model.Bytes,
                ArchivalEntityCount = model.ArchivalEntityCount,
                DocumentCount = model.DocumentCount,
                DigitizedArchivalEntityCount = model.DigitizedArchivalEntityCount,
                AudioDocumentArchivalEntityCount = model.AudioDocumentArchivalEntityCount,
                DigitalDocumentArchivalEntityCount = model.DigitalDocumentArchivalEntityCount,
                MicrofilmedArchivalEntityCount = model.MicrofilmedArchivalEntityCount,
                PhotoDocumentArchivalEntityCount = model.PhotoDocumentArchivalEntityCount,
                VideoDocumentArchivalEntityCount = model.VideoDocumentArchivalEntityCount,
                NegativeFrameCount = model.NegativeFrameCount,
                PositiveFrameCount = model.PositiveFrameCount,
                BoxCount = model.BoxCount,
                RollCount = model.RollCount,
                HasExternalSource = model.HasExternalSource,
                ExternalIdentifier = model.ExternalIdentifier,
                ApplicationId = model.ApplicationId,
                PackageAid = model.PackageAId,
                PackageBid = model.PackageBId,
                OtherLanguage = model.OtherLanguage,
            };

            if (!model.AvailabilityStatusCode.HasValue)
            {
                inventoryDraft.AvailabilityStatusCode = (int)Shared.AvailabilityStatus.Enrollment;
            }

            if (model.HasExternalSource)
                inventoryDraft.ExternalSourceUpdatedOn = DateTime.UtcNow;

            _context.InventoryDrafts.Add(inventoryDraft);
            await _context.SaveAsync("Inventory draft created");

            //Acquisition methods
            //if (model.AcquisitionMethodCodes?.Count() > 0)
            //{
            //    var acquisitionMethods = _nomenclatureService.GetNomenclatureValues(Shared.NomenclatureCode.AcquisitionMethod);
            //    var acquisitionValues = model.AcquisitionMethodCodes?
            //                            .Select(ac => new NomenclatureValue()
            //                            {
            //                                EntityId = inventoryDraft.Id,
            //                                EntityType = BusinessObjectType.Inventory,
            //                                EntityIsDraft = true,
            //                                NomenclatureCode = acquisitionMethods.Where(nv => nv.Code == ac).Select(nv => nv.ParentCode).FirstOrDefault()!,
            //                                NomenclatureId = acquisitionMethods.Where(nv => nv.Code == ac).Select(nv => nv.ParentId!.Value).FirstOrDefault(),
            //                                ValueCode = ac,
            //                                ValueId = acquisitionMethods.Where(nv => nv.Code == ac).Select(nv => nv.Id!.Value).FirstOrDefault(),
            //                            });
            //    _context.NomenclatureValues.AddRange(acquisitionValues!);
            //}

            //Originality
            if (model.OriginalityCodes?.Count() > 0)
            {
                var originalityValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.OriginalityCodes, null, Shared.NomenclatureCode.Originality,
                    inventoryDraft.Id, BusinessObjectType.Inventory, true);

                if (originalityValues != null)
                {
                    _context.NomenclatureValues.AddRange(originalityValues!);
                }
            }

            //Creation methods
            if (model.CreationMethodCodes?.Count() > 0)
            {
                var creationMethodValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.CreationMethodCodes, null, Shared.NomenclatureCode.CreationMethod,
                    inventoryDraft.Id, BusinessObjectType.Inventory, true);

                if (creationMethodValues != null)
                {
                    _context.NomenclatureValues.AddRange(creationMethodValues!);
                }
            }

            //FIle types
            if (model.FileTypeCodes?.Count() > 0)
            {
                var fileTypeValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.FileTypeCodes, null, Shared.NomenclatureCode.FileType,
                    inventoryDraft.Id, BusinessObjectType.Inventory, true);

                if (fileTypeValues != null)
                {
                    _context.NomenclatureValues.AddRange(fileTypeValues!);
                }
            }

            //Languages
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, null, Shared.NomenclatureCode.Language,
                    inventoryDraft.Id, BusinessObjectType.Inventory, true);

                if (languageValues != null)
                {
                    _context.NomenclatureValues.AddRange(languageValues!);
                }
            }
            await _context.SaveAsync("Inventory draft created");

            if (checkRelatedProcess)
            {
                //Update process step
                await ((IInventoryServiceBase)this).SetRelatedProcessStepInternalAsync(model.FundSystemIdentifier.Value);
            }

            if (model.ApplicationId.HasValue)
            {
                var application = await _context.EdocsCollectingApplications.FindAsync(model.ApplicationId.Value);
                if (application == null)
                {
                    throw new Exception(_localizer.GetString("Error_NoApplicationFound").ToString());
                }

                if (application.StatusId == (int)ApplicationStatus.Approved)
                {
                    if (application.IsFromRedirect == true)
                    {
                        await _applicationService.UpdateStatus(model.ApplicationId.Value, ApplicationStatus.AddPackages);
                        await _applicationService.UpdateStatus(model.ApplicationId.Value, ApplicationStatus.PackagesApproval);

                        //send task
                        var roleName = _localizer.GetString("Role_B").ToString();
                        var role = await _context.AspNetRoles
                                .Where(r => r.ArchiveId == application.ArchiveId && r.Name == roleName)
                                .OrderBy(r => r.Name)
                                .FirstOrDefaultAsync();
                        Guid? assignedToRoleId = role != null ? role.Id : null;

                        if (assignedToRoleId != null)
                        {
                            TaskCreateModel taskModel = new()
                            {
                                NotificationType = Shared.NotificationType.ApplicationPackagesAdded,
                                EntityType = BusinessObjectType.EDocsApplication,
                                EntityId = application.Id,
                                AssignedToRoleId = assignedToRoleId.Value.ToString("D"),
                            };

                            var taskResult = await _taskService.CreateAsync(taskModel);
                            if (!taskResult.Succeeded)
                            {
                                throw new Exception(taskResult.ToString());
                            }
                        }
                    }
                    else
                    {
                        //Update application status
                        await _applicationService.UpdateStatus(model.ApplicationId.Value, ApplicationStatus.AddPackages);

                        // add event for notification
                        await _notificationEventService.AddNotificationEvent(application.Id, Shared.NotificationType.AddApplicationPackages, null, application.CreatedBy);
                    }
                }
                

                // complete previous task
                var completePrevTaskResult = await _taskService.CompletePreviousTask(ProcessStepType.NoStep, null, Shared.NotificationType.AssignedApplication, application.Id);
                if (!completePrevTaskResult.Succeeded)
                {
                    throw new Exception(completePrevTaskResult.ToString());
                }
            }

            return inventoryDraft.SystemIdentifier;
        }

        public async Task<OperationResult> CreateDraftAsync(InventoryDraftCreateModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                model.SystemIdentifier = await ((IInventoryServiceBase)this).CreateDraftInternalAsync(model, !model.StartProcess);

                if (model.StartProcess)
                {
                    //Create fund draft
                    //await _fundService.CreateDraftFromIdentifierAsync(model.FundSystemIdentifier.Value);
                    //Start process
                    var processResult = await StartProcessAsync(model);
                    if (!processResult.Succeeded)
                    {
                        return processResult;
                    }
                }
                else
                {
                    //Тук процесът е стартиран на ниво фонд
                    var process = await _context.Processes.Where(x => x.FundSystemIdentifier == model.FundSystemIdentifier && !x.Completed).FirstOrDefaultAsync();
                    int[] colectionPrcessesIds = new[] { (int)Shared.ProcessType.AddRawFundAndRawInventory, (int)Shared.ProcessType.AddRawInventory, (int)Shared.ProcessType.AddFundAndInventory, (int)Shared.ProcessType.AddInventory };
                    bool isCollectingProcedure = colectionPrcessesIds.Contains(process.ProcessTypeId);
                    if (process != null && isCollectingProcedure && !model.ApplicationId.HasValue)
                    {
                        //При създаване на опис към фонд със стартиран процесс и без заявление се създават пакети 
                        //Процеса е вътрешен
                        Package packageА = new Package()
                        {
                            Type = "A",
                            Approved = true
                        };

                        _context.Packages.Add(packageА);

                        Package packageB = new Package()
                        {
                            Type = "B",
                            Approved = true
                        };

                        _context.Packages.Add(packageB);
                        var inv = await _context.InventoryDrafts.FirstOrDefaultAsync(x => x.SystemIdentifier == model.SystemIdentifier && x.IsCurrent);
                        inv.PackageA = packageА;
                        inv.PackageB = packageB;
                        await _context.SaveAsync("");

                        var stepResult = await _processService.SetActiveProcessStepAsync(process.Id, (int)ProcessStepType.CommissionReport);
                        if (!stepResult.Succeeded)
                        {
                            transaction.Rollback();
                            return stepResult;
                        }
                    }
                }

                transaction.Commit();
                return OperationResult.Succeed(model.SystemIdentifier);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        private async Task<OperationResult> StartProcessAsync(InventoryDraftCreateModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            //check for active process
            if (await _context.Processes
                    .Where(p => p.InventorySystemIdentifier == model.SystemIdentifier
                        || p.FundSystemIdentifier == model.FundSystemIdentifier
                        && !p.Deleted
                        && !p.Completed)
                    .AnyAsync())
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemHasActiveProcess").ToString());
            }

            try
            {
                int? processTypeId = null;
                int.TryParse(model.DescriptionLevelCode, out int descriptionLevel);

                switch ((Shared.InventoryDescriptionLevel)descriptionLevel)
                {
                    case Shared.InventoryDescriptionLevel.Inventory:
                        processTypeId = (int)Shared.ProcessType.AddInventory;
                        break;
                    case Shared.InventoryDescriptionLevel.RawInventory:
                        processTypeId = (int)Shared.ProcessType.AddRawInventoryToRawFund; //TODO Тук не трябва ли да се провери descriptionLevel на фонда?
                        break;
                    case Shared.InventoryDescriptionLevel.SystemInventory:
                        processTypeId = (int)Shared.ProcessType.AddSystemInventory;
                        break;
                }

                ProcessModel process = new ProcessModel()
                {
                    InventorySystemIdentifier = model.SystemIdentifier,
                    ArchiveId = model.ArchiveId,
                    ProcessTypeId = processTypeId,
                };

                var startProcessResult = await _processService.StartProcessAsync(process);
                if (!startProcessResult.Succeeded)
                {
                    return startProcessResult;
                }

                var processId = (int)startProcessResult.Data!;

                var processStep = new ProcessStepModel()
                {
                    ProcessId = processId,
                    StepTypeId = model.ApplicationId.HasValue ? (int)ProcessStepType.AddPackages : (int)ProcessStepType.CommissionReport,
                };
                var processStepResult = await _processService.SetActiveProcessStepAsync(processStep);
                if (!processStepResult.Succeeded)
                {
                    return processStepResult;
                }

                if (!model.ApplicationId.HasValue) //Ако няма заявление процеса е вътрешен 
                {
                    Package packageА = new Package()
                    {
                        Type = "A",
                        Approved = true
                    };

                    _context.Packages.Add(packageА);

                    Package packageB = new Package()
                    {
                        Type = "B",
                        Approved = true
                    };

                    _context.Packages.Add(packageB);

                    var inv = await _context.InventoryDrafts.FirstOrDefaultAsync(x => x.SystemIdentifier == model.SystemIdentifier && x.IsCurrent && !x.Deleted);
                    if (inv == null)
                    {
                        return OperationResult.Failed($"No current inventory draft with sysId {model.SystemIdentifier}.");
                    }
                    inv.PackageA = packageА;
                    inv.PackageB = packageB;

                    await _context.SaveAsync("Inventory draft updated");
                }

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        async Task IInventoryServiceBase.SetRelatedProcessStepInternalAsync(Guid fundIdentifier)
        {
            //var activeProcess = await _context.Processes
            //    .Include(x => x.ProcessTimelines)
            //    .FirstOrDefaultAsync(x => x.FundSystemIdentifier == fundIdentifier && !x.Completed);

            var activeProcess = await _processService.GetCurrentActiveProcess(BusinessObjectType.Fund, fundIdentifier);

            if (activeProcess != null)
            {
                OperationResult result = OperationResult.Success;
                switch ((Shared.ProcessType)activeProcess.ProcessTypeId!.Value)
                {
                    case Shared.ProcessType.AddFundAndInventory:
                    case Shared.ProcessType.AddRawFundAndRawInventory:
                    case Shared.ProcessType.AddInventory:
                    case Shared.ProcessType.AddRawInventoryToRawFund:
                        result = await _processService.SetActiveProcessStepAsync(activeProcess.Id!.Value, (int)ProcessStepType.AddPackages);
                        break;
                    case Shared.ProcessType.ProcessRawFundWithRawInventory:
                        if (activeProcess.ActiveProcessStepTypeId.HasValue
                            && activeProcess.ActiveProcessStepTypeId.Value == (int)ProcessStepType.ProcessRawFundWithRawInventory_ChooseRawInventories)
                        {
                            result = await _processService.SetActiveProcessStepAsync(activeProcess.Id!.Value, (int)ProcessStepType.ProcessRawFundWithRawInventory_CreateInventories);
                        }
                        break;
                    case Shared.ProcessType.ProcessFundWithRawInventory:
                        if (activeProcess.ActiveProcessStepTypeId.HasValue
                            && activeProcess.ActiveProcessStepTypeId.Value == (int)ProcessStepType.ProcessFundWithRawInventory_ChooseRawInventories)
                        {
                            result = await _processService.SetActiveProcessStepAsync(activeProcess.Id!.Value, (int)ProcessStepType.ProcessFundWithRawInventory_CreateInventories);
                        }
                        break;
                }

                if (!result.Succeeded)
                {
                    throw new Exception(result.ToString());
                }

                //if (activeProcess.ProcessTypeId != (int)Shared.ProcessType.EditData
                //    && activeProcess.ProcessTypeId != (int)Shared.ProcessType.EditFundData
                //    && activeProcess.ProcessTypeId != (int)Shared.ProcessType.RefineData
                //    && activeProcess.ProcessTypeId != (int)Shared.ProcessType.ReconstructFundData)
                //{
                //    var currentStep = activeProcess.ProcessTimelines.FirstOrDefault(x => !x.Completed);
                //    if (currentStep != null)
                //    {
                //        currentStep.Completed = true;
                //    }

                //    if (activeProcess.ProcessTypeId == (int)Shared.ProcessType.AddFundAndInventory
                //     || activeProcess.ProcessTypeId == (int)Shared.ProcessType.AddRawFundAndRawInventory
                //     || activeProcess.ProcessTypeId == (int)Shared.ProcessType.AddInventory
                //     || activeProcess.ProcessTypeId == (int)Shared.ProcessType.AddRawInventoryToRawFund)
                //    {
                //        await _processService.AddStepAsync(activeProcess.Id, (int)ProcessStepType.AddPackages);
                //    }
                //    else if (activeProcess.ProcessTypeId == (int)Shared.ProcessType.ProcessRawFundWithRawInventory)
                //    {
                //        if (currentStep != null && currentStep.StepTypeId == (int)ProcessStepType.ProcessRawFundWithRawInventory_ChooseRawInventories)
                //        {
                //            await _processService.AddStepAsync(activeProcess.Id, (int)ProcessStepType.ProcessRawFundWithRawInventory_CreateInventories);
                //        }
                //        else if (currentStep != null)
                //        {
                //            currentStep.Completed = false;
                //        }
                //    }
                //    else if (activeProcess.ProcessTypeId == (int)Shared.ProcessType.ProcessFundWithRawInventory)
                //    {
                //        if (currentStep != null && currentStep.StepTypeId == (int)ProcessStepType.ProcessFundWithRawInventory_ChooseRawInventories)
                //        {
                //            await _processService.AddStepAsync(activeProcess.Id, (int)ProcessStepType.ProcessFundWithRawInventory_CreateInventories);
                //        }
                //        else if (currentStep != null)
                //        {
                //            currentStep.Completed = false;
                //        }
                //    }
                //}
            }
        }

        async Task<Guid> IInventoryServiceBase.CreateInventoryInternalAsync(InventoryModel model, Guid? createdBy, DateTime? createdOn)
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

            var inventory = new Inventory
            {
                SystemIdentifier = model.SystemIdentifier.Value,
                ArchiveId = model.ArchiveId,
                FundSystemIdentifier = model.FundSystemIdentifier!.Value,
                NumberArray = model.NumberArray,
                NumberNumeric = model.NumberNumeric,
                Number = model.Number,
                StatusCode = model.StatusCode,
                AvailabilityStatusCode = model.AvailabilityStatusCode,
                DescriptionLevelCode = model.DescriptionLevelCode,
                AcquisitionMethodId = model.AcquisitionMethodId,
                ApproxmateChronologicalScope = model.ApproxmateChronologicalScope,
                HasNoChronologicalScope = model.HasNoChronologicalScope,
                StartDateDay = model.StartDateDay,
                StartDateMonth = model.StartDateMonth,
                StartDateYear = model.StartDateYear,
                EndDateDay = model.EndDateDay,
                EndDateMonth = model.EndDateMonth,
                EndDateYear = model.EndDateYear,
                FundCreatorBiographicalHistory = model.FundCreatorBiographicalHistory,
                FundCreatorTitleHistory = model.FundCreatorTitleHistory,
                History = model.History,
                DocumentsAccessDescription = model.DocumentsAccessDescription,
                DocumentsDescription = model.DocumentsDescription,
                DocumentsProvider = model.DocumentsProvider,
                LinearMeters = model.LinearMeters,
                OtherMetrics = model.OtherMetrics,
                Notes = model.Notes,
                ClassificationScheme = model.ClassificationScheme,
                AbbreviationList = model.AbbreviationList,
                Bytes = model.Bytes,
                ArchivalEntityCount = model.ArchivalEntityCount,
                DocumentCount = model.DocumentCount,
                DigitizedArchivalEntityCount = model.DigitizedArchivalEntityCount,
                AudioDocumentArchivalEntityCount = model.AudioDocumentArchivalEntityCount,
                DigitalDocumentArchivalEntityCount = model.DigitalDocumentArchivalEntityCount,
                MicrofilmedArchivalEntityCount = model.MicrofilmedArchivalEntityCount,
                PhotoDocumentArchivalEntityCount = model.PhotoDocumentArchivalEntityCount,
                VideoDocumentArchivalEntityCount = model.VideoDocumentArchivalEntityCount,
                NegativeFrameCount = model.NegativeFrameCount,
                PositiveFrameCount = model.PositiveFrameCount,
                BoxCount = model.BoxCount,
                RollCount = model.RollCount,
                HasExternalSource = model.HasExternalSource,
                ExternalIdentifier = model.ExternalIdentifier,
                ApplicationId = model.ApplicationId,
                PackageAid = model.PackageAId,
                PackageBid = model.PackageBId,
                OtherLanguage = model.OtherLanguage,
            };

            if (!model.AvailabilityStatusCode.HasValue)
            {
                inventory.AvailabilityStatusCode = (int)Shared.AvailabilityStatus.Enrollment;
            }

            if (model.HasExternalSource)
                inventory.ExternalSourceUpdatedOn = DateTime.UtcNow;

            bool overwriteCreated = createdBy.HasValue && createdOn.HasValue;
            if (overwriteCreated)
            {
                inventory.CreatedBy = createdBy;
                inventory.CreatedOn = createdOn;
            }

            _context.Inventories.Add(inventory);
            await _context.SaveAsync("Inventory created", overwriteCreated);


            if (model.OriginalityCodes?.Count() > 0)
            {
                var originalityValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.OriginalityCodes, null, Shared.NomenclatureCode.Originality,
                    inventory.Id, BusinessObjectType.Inventory, false, overwriteCreated, createdBy, createdOn);

                if (originalityValues != null)
                {
                    _context.NomenclatureValues.AddRange(originalityValues!);
                }
            }
            if (model.CreationMethodCodes?.Count() > 0)
            {
                var creationMethodValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.CreationMethodCodes, null, Shared.NomenclatureCode.CreationMethod,
                    inventory.Id, BusinessObjectType.Inventory, false, overwriteCreated, createdBy, createdOn);

                if (creationMethodValues != null)
                {
                    _context.NomenclatureValues.AddRange(creationMethodValues!);
                }
            }
            if (model.FileTypeCodes?.Count() > 0)
            {
                var fileTypeValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.FileTypeCodes, null, Shared.NomenclatureCode.FileType,
                    inventory.Id, BusinessObjectType.Inventory, false, overwriteCreated, createdBy, createdOn);

                if (fileTypeValues != null)
                {
                    _context.NomenclatureValues.AddRange(fileTypeValues!);
                }
            }
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, null, Shared.NomenclatureCode.Language,
                    inventory.Id, BusinessObjectType.Inventory, false, overwriteCreated, createdBy, createdOn);

                if (languageValues != null)
                {
                    _context.NomenclatureValues.AddRange(languageValues!);
                }
            }
            await _context.SaveAsync("Inventory created", overwriteCreated);

            return inventory.SystemIdentifier;
        }

        public async Task<OperationResult> CreateInventoryAsync(InventoryModel model)
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
                var inventorySysId = await ((IInventoryServiceBase)this).CreateInventoryInternalAsync(model);

                transaction.Commit();
                return OperationResult.Succeed(inventorySysId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        async Task<Guid> IInventoryServiceBase.CreateOrUpdateInventoryFromDraftInternalAsync(Guid sysId, bool overwriteCreatedFromDraft, bool overwriteModifiedFromDraft)
        {
            var inventoryDraft = await GetCurrentDraftAsync(sysId);
            if (inventoryDraft == null)
            {
                throw new ItemDraftNotCurrentException(_localizer.GetString("Error_DraftNotCurrent").ToString(), sysId.ToString());
            }

            Guid? createdBy = null;
            Guid? updatedBy = null;
            DateTime? createdOn = null;
            DateTime? updatedOn = null;

            if (overwriteCreatedFromDraft)
            {
                createdBy = inventoryDraft.CreatedBy;
                createdOn = inventoryDraft.CreatedOn;
            }
            if (overwriteModifiedFromDraft)
            {
                updatedBy = inventoryDraft.UpdatedBy ?? inventoryDraft.CreatedBy;
                updatedOn = inventoryDraft.UpdatedOn ?? inventoryDraft.CreatedOn;
            }

            var inventory =
                await _context.Inventories
                .Where(inv => inv.SystemIdentifier == sysId && !inv.Deleted)
                .Select(inv => new InventoryModel()
                {
                    Id = inv.Id,
                    SystemIdentifier = inv.SystemIdentifier,
                    ArchiveId = inv.ArchiveId,
                    FundSystemIdentifier = inv.FundSystemIdentifier,
                    NumberArray = inv.NumberArray,
                    NumberNumeric = inv.NumberNumeric,
                    Number = inv.Number,
                    StatusCode = inv.StatusCode!,
                    AvailabilityStatusCode = inv.AvailabilityStatusCode,
                    DescriptionLevelCode = inv.DescriptionLevelCode!,
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
                    ClassificationScheme = inv.ClassificationScheme,
                    AbbreviationList = inv.AbbreviationList,
                    Bytes = inv.Bytes,
                    ArchivalEntityCount = inv.ArchivalEntityCount,
                    DocumentCount = inv.DocumentCount,
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
                    HasExternalSource = inv.HasExternalSource,
                    ExternalIdentifier = inv.ExternalIdentifier,
                    ApplicationId = inv.ApplicationId,
                    PackageAId = inv.PackageAid,
                    PackageBId = inv.PackageBid,

                    AcquisitionMethodId = inv.AcquisitionMethodId,

                    FileTypeCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.FileType),
                    CreationMethodCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.CreationMethod),
                    OriginalityCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.Originality),
                    LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(inv.Id, BusinessObjectType.Inventory, false, Shared.NomenclatureCode.Language),
                    OtherLanguage = inv.OtherLanguage,
                })
                .SingleOrDefaultAsync();

            if (inventory != null)
            {
                inventory.SystemIdentifier = inventoryDraft.SystemIdentifier;
                inventory.ArchiveId = inventoryDraft.ArchiveId;
                inventory.FundSystemIdentifier = inventoryDraft.FundSystemIdentifier;
                inventory.NumberArray = inventoryDraft.NumberArray;
                inventory.NumberNumeric = inventoryDraft.NumberNumeric;
                inventory.Number = inventoryDraft.Number;
                inventory.StatusCode = inventoryDraft.StatusCode;
                inventory.AvailabilityStatusCode = inventoryDraft.AvailabilityStatusCode;
                inventory.DescriptionLevelCode = inventoryDraft.DescriptionLevelCode;
                inventory.ApproxmateChronologicalScope = inventoryDraft.ApproxmateChronologicalScope;
                inventory.HasNoChronologicalScope = inventoryDraft.HasNoChronologicalScope;
                inventory.StartDateDay = inventoryDraft.StartDateDay;
                inventory.StartDateMonth = inventoryDraft.StartDateMonth;
                inventory.StartDateYear = inventoryDraft.StartDateYear;
                inventory.EndDateDay = inventoryDraft.EndDateDay;
                inventory.EndDateMonth = inventoryDraft.EndDateMonth;
                inventory.EndDateYear = inventoryDraft.EndDateYear;
                inventory.FundCreatorBiographicalHistory = inventoryDraft.FundCreatorBiographicalHistory;
                inventory.FundCreatorTitleHistory = inventoryDraft.FundCreatorTitleHistory;
                inventory.History = inventoryDraft.History;
                inventory.DocumentsAccessDescription = inventoryDraft.DocumentsAccessDescription;
                inventory.DocumentsDescription = inventoryDraft.DocumentsDescription;
                inventory.DocumentsProvider = inventoryDraft.DocumentsProvider;
                inventory.LinearMeters = inventoryDraft.LinearMeters;
                inventory.OtherMetrics = inventoryDraft.OtherMetrics;
                inventory.Notes = inventoryDraft.Notes;
                inventory.ClassificationScheme = inventoryDraft.ClassificationScheme;
                inventory.AbbreviationList = inventoryDraft.AbbreviationList;
                inventory.Bytes = inventoryDraft.Bytes;
                inventory.ArchivalEntityCount = inventoryDraft.ArchivalEntityCount;
                inventory.DocumentCount = inventoryDraft.DocumentCount;
                inventory.DigitizedArchivalEntityCount = inventoryDraft.DigitizedArchivalEntityCount;
                inventory.AudioDocumentArchivalEntityCount = inventoryDraft.AudioDocumentArchivalEntityCount;
                inventory.DigitalDocumentArchivalEntityCount = inventoryDraft.DigitalDocumentArchivalEntityCount;
                inventory.MicrofilmedArchivalEntityCount = inventoryDraft.MicrofilmedArchivalEntityCount;
                inventory.PhotoDocumentArchivalEntityCount = inventoryDraft.PhotoDocumentArchivalEntityCount;
                inventory.VideoDocumentArchivalEntityCount = inventoryDraft.VideoDocumentArchivalEntityCount;
                inventory.NegativeFrameCount = inventoryDraft.NegativeFrameCount;
                inventory.PositiveFrameCount = inventoryDraft.PositiveFrameCount;
                inventory.BoxCount = inventoryDraft.BoxCount;
                inventory.RollCount = inventoryDraft.RollCount;
                inventory.HasExternalSource = inventoryDraft.HasExternalSource;
                inventory.ExternalIdentifier = inventoryDraft.ExternalIdentifier;
                inventory.AcquisitionMethodId = inventoryDraft.AcquisitionMethodId;
                //inventory.AcquisitionMethodCodes = inventoryDraft.AcquisitionMethodCodes;
                inventory.CreationMethodCodes = inventoryDraft.CreationMethodCodes;
                inventory.FileTypeCodes = inventoryDraft.FileTypeCodes;
                inventory.LanguageCodes = inventoryDraft.LanguageCodes;
                inventory.OriginalityCodes = inventoryDraft.OriginalityCodes;
                inventory.ApplicationId = inventoryDraft.ApplicationId;
                inventory.PackageAId = inventoryDraft.PackageAId;
                inventory.PackageBId = inventoryDraft.PackageBId;
                inventory.OtherLanguage = inventoryDraft.OtherLanguage;

                //await ((IInventoryServiceBase)this).UpdateInventoryInternalAsync(inventory);
                await ((IInventoryServiceBase)this).UpdateInventoryInternalAsync(inventory, updatedBy, updatedOn);
            }
            else
            {
                inventory = new InventoryModel()
                {
                    SystemIdentifier = inventoryDraft.SystemIdentifier,
                    ArchiveId = inventoryDraft.ArchiveId,
                    FundSystemIdentifier = inventoryDraft.FundSystemIdentifier,
                    NumberArray = inventoryDraft.NumberArray,
                    NumberNumeric = inventoryDraft.NumberNumeric,
                    Number = inventoryDraft.Number,
                    StatusCode = inventoryDraft.StatusCode,
                    AvailabilityStatusCode = inventoryDraft.AvailabilityStatusCode,
                    DescriptionLevelCode = inventoryDraft.DescriptionLevelCode,
                    ApproxmateChronologicalScope = inventoryDraft.ApproxmateChronologicalScope,
                    HasNoChronologicalScope = inventoryDraft.HasNoChronologicalScope,
                    StartDateDay = inventoryDraft.StartDateDay,
                    StartDateMonth = inventoryDraft.StartDateMonth,
                    StartDateYear = inventoryDraft.StartDateYear,
                    EndDateDay = inventoryDraft.EndDateDay,
                    EndDateMonth = inventoryDraft.EndDateMonth,
                    EndDateYear = inventoryDraft.EndDateYear,
                    FundCreatorBiographicalHistory = inventoryDraft.FundCreatorBiographicalHistory,
                    FundCreatorTitleHistory = inventoryDraft.FundCreatorTitleHistory,
                    History = inventoryDraft.History,
                    DocumentsAccessDescription = inventoryDraft.DocumentsAccessDescription,
                    DocumentsDescription = inventoryDraft.DocumentsDescription,
                    DocumentsProvider = inventoryDraft.DocumentsProvider,
                    LinearMeters = inventoryDraft.LinearMeters,
                    OtherMetrics = inventoryDraft.OtherMetrics,
                    Notes = inventoryDraft.Notes,
                    ClassificationScheme = inventoryDraft.ClassificationScheme,
                    AbbreviationList = inventoryDraft.AbbreviationList,
                    Bytes = inventoryDraft.Bytes,
                    ArchivalEntityCount = inventoryDraft.ArchivalEntityCount,
                    DocumentCount = inventoryDraft.DocumentCount,
                    DigitizedArchivalEntityCount = inventoryDraft.DigitizedArchivalEntityCount,
                    AudioDocumentArchivalEntityCount = inventoryDraft.AudioDocumentArchivalEntityCount,
                    DigitalDocumentArchivalEntityCount = inventoryDraft.DigitalDocumentArchivalEntityCount,
                    MicrofilmedArchivalEntityCount = inventoryDraft.MicrofilmedArchivalEntityCount,
                    PhotoDocumentArchivalEntityCount = inventoryDraft.PhotoDocumentArchivalEntityCount,
                    VideoDocumentArchivalEntityCount = inventoryDraft.VideoDocumentArchivalEntityCount,
                    NegativeFrameCount = inventoryDraft.NegativeFrameCount,
                    PositiveFrameCount = inventoryDraft.PositiveFrameCount,
                    BoxCount = inventoryDraft.BoxCount,
                    RollCount = inventoryDraft.RollCount,
                    HasExternalSource = inventoryDraft.HasExternalSource,
                    ExternalIdentifier = inventoryDraft.ExternalIdentifier,
                    AcquisitionMethodId = inventoryDraft.AcquisitionMethodId,
                    //AcquisitionMethodCodes = inventoryDraft.AcquisitionMethodCodes,
                    CreationMethodCodes = inventoryDraft.CreationMethodCodes,
                    FileTypeCodes = inventoryDraft.FileTypeCodes,
                    LanguageCodes = inventoryDraft.LanguageCodes,
                    OriginalityCodes = inventoryDraft.OriginalityCodes,
                    ApplicationId = inventoryDraft.ApplicationId,
                    PackageAId = inventoryDraft.PackageAId,
                    PackageBId = inventoryDraft.PackageBId,
                    OtherLanguage = inventoryDraft.OtherLanguage,
                };

                //await ((IInventoryServiceBase)this).CreateInventoryInternalAsync(inventory);
                await ((IInventoryServiceBase)this).CreateInventoryInternalAsync(inventory, createdBy, createdOn);
            }

            var modifiedInventoryDraft = new InventoryDraftModel()
            {
                Id = inventoryDraft.Id,
                IsCurrent = false,
                ReadOnly = true,
                SystemIdentifier = inventoryDraft.SystemIdentifier,
                ArchiveId = inventoryDraft.ArchiveId,
                FundDraftId = inventoryDraft.FundDraftId,
                FundSystemIdentifier = inventoryDraft.FundSystemIdentifier!.Value,
                NumberArray = inventoryDraft.NumberArray,
                NumberNumeric = inventoryDraft.NumberNumeric,
                Number = inventoryDraft.Number,
                StatusCode = inventoryDraft.StatusCode,
                AvailabilityStatusCode = inventoryDraft.AvailabilityStatusCode,
                DescriptionLevelCode = inventoryDraft.DescriptionLevelCode,
                ApproxmateChronologicalScope = inventoryDraft.ApproxmateChronologicalScope,
                HasNoChronologicalScope = inventoryDraft.HasNoChronologicalScope,
                StartDateDay = inventoryDraft.StartDateDay,
                StartDateMonth = inventoryDraft.StartDateMonth,
                StartDateYear = inventoryDraft.StartDateYear,
                EndDateDay = inventoryDraft.EndDateDay,
                EndDateMonth = inventoryDraft.EndDateMonth,
                EndDateYear = inventoryDraft.EndDateYear,
                FundCreatorBiographicalHistory = inventoryDraft.FundCreatorBiographicalHistory,
                FundCreatorTitleHistory = inventoryDraft.FundCreatorTitleHistory,
                History = inventoryDraft.History,
                DocumentsAccessDescription = inventoryDraft.DocumentsAccessDescription,
                DocumentsDescription = inventoryDraft.DocumentsDescription,
                DocumentsProvider = inventoryDraft.DocumentsProvider,
                LinearMeters = inventoryDraft.LinearMeters,
                OtherMetrics = inventoryDraft.OtherMetrics,
                Notes = inventoryDraft.Notes,
                ClassificationScheme = inventoryDraft.ClassificationScheme,
                AbbreviationList = inventoryDraft.AbbreviationList,
                Bytes = inventoryDraft.Bytes,
                ArchivalEntityCount = inventoryDraft.ArchivalEntityCount,
                DocumentCount = inventoryDraft.DocumentCount,
                DigitizedArchivalEntityCount = inventoryDraft.DigitizedArchivalEntityCount,
                AudioDocumentArchivalEntityCount = inventoryDraft.AudioDocumentArchivalEntityCount,
                DigitalDocumentArchivalEntityCount = inventoryDraft.DigitalDocumentArchivalEntityCount,
                MicrofilmedArchivalEntityCount = inventoryDraft.MicrofilmedArchivalEntityCount,
                PhotoDocumentArchivalEntityCount = inventoryDraft.PhotoDocumentArchivalEntityCount,
                VideoDocumentArchivalEntityCount = inventoryDraft.VideoDocumentArchivalEntityCount,
                NegativeFrameCount = inventoryDraft.NegativeFrameCount,
                PositiveFrameCount = inventoryDraft.PositiveFrameCount,
                BoxCount = inventoryDraft.BoxCount,
                RollCount = inventoryDraft.RollCount,
                HasExternalSource = inventoryDraft.HasExternalSource,
                ExternalIdentifier = inventoryDraft.ExternalIdentifier,
                AcquisitionMethodId = inventoryDraft.AcquisitionMethodId,
                //AcquisitionMethodCodes = inventoryDraft.AcquisitionMethodCodes,
                CreationMethodCodes = inventoryDraft.CreationMethodCodes,
                FileTypeCodes = inventoryDraft.FileTypeCodes,
                LanguageCodes = inventoryDraft.LanguageCodes,
                OriginalityCodes = inventoryDraft.OriginalityCodes,
                ApplicationId = inventoryDraft.ApplicationId,
                PackageAId = inventoryDraft.PackageAId,
                PackageBId = inventoryDraft.PackageBId,
                OtherLanguage = inventoryDraft.OtherLanguage,
            };

            await ((IInventoryServiceBase)this).UpdateDraftInternalAsync(modifiedInventoryDraft);

            return sysId;
        }

        public async Task<OperationResult> CreateOrUpdateInventoryFromDraftAsync(Guid sysId)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await ((IInventoryServiceBase)this).CreateOrUpdateInventoryFromDraftInternalAsync(sysId);

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

        async Task<Guid> IInventoryServiceBase.UpdateDraftInternalAsync(InventoryDraftModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            if (!model.SystemIdentifier.HasValue)
            {
                throw new SystemIdentifierNullException(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            if (model.ApplicationId.HasValue)
            {
                var applicationId = await _context.VInventories
                                        .Where(inv => inv.SystemIdentifier == model.SystemIdentifier)
                                        .Select(inv => inv.ApplicationId)
                                        .SingleOrDefaultAsync();
                if (applicationId.HasValue && model.ApplicationId != applicationId)
                {
                    //Get current application info
                    var currentApplication = await _context.EdocsCollectingApplications.Where(app => app.Id == applicationId.Value).SingleOrDefaultAsync();
                    if (currentApplication == null)
                    {
                        throw new ItemNotFoundException(_localizer.GetString("Error_NoApplicationFound").ToString(), applicationId.Value.ToString());
                    }

                    //Return current application to its previous status
                    await _applicationService.UpdateStatus(currentApplication.Id, ApplicationStatus.Approved);

                    // add event for notification for modified status
                    await _notificationEventService.AddNotificationEvent(currentApplication.Id, Shared.NotificationType.ApprovedApplication, null, currentApplication.CreatedBy);

                    //Get new application info
                    var newApplication = await _context.EdocsCollectingApplications.Where(app => app.Id == model.ApplicationId.Value && !app.Deleted).SingleOrDefaultAsync();
                    if (newApplication == null)
                    {
                        throw new ItemNotFoundException(_localizer.GetString("Error_NoApplicationFound").ToString());
                    }

                    //Update new application status
                    await _applicationService.UpdateStatus(model.ApplicationId.Value, ApplicationStatus.AddPackages);

                    // add event for notification
                    await _notificationEventService.AddNotificationEvent(newApplication.Id, Shared.NotificationType.AddApplicationPackages, null, newApplication.CreatedBy);
                }
            }

            var currentInventoryDraft = await GetCurrentDraftAsync(model.SystemIdentifier!.Value);
            if (currentInventoryDraft == null)
            {
                return await ((IInventoryServiceBase)this).CreateDraftInternalAsync(model);
            }

            bool isReadOnly = await IsReadOnlyDraftAsync(new InventoryDraftModel() { Id = currentInventoryDraft.Id });
            if (isReadOnly)
            {
                return await ((IInventoryServiceBase)this).CreateDraftInternalAsync(model);
            }

            //var inventoryDraft = await _context.InventoryDrafts.FindAsync(model.Id);
            var inventoryDraft = await _context.InventoryDrafts.FindAsync(currentInventoryDraft.Id);
            if (inventoryDraft == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), model.Id?.ToString()!);
            }

            inventoryDraft.IsCurrent = model.IsCurrent;
            inventoryDraft.ReadOnly = model.ReadOnly;
            inventoryDraft.SystemIdentifier = model.SystemIdentifier.Value;
            inventoryDraft.ArchiveId = model.ArchiveId;
            inventoryDraft.FundDraftId = model.FundDraftId;
            inventoryDraft.FundSystemIdentifier = model.FundSystemIdentifier!.Value;
            inventoryDraft.WorkflowId = model.WorkflowId;
            inventoryDraft.WorkflowTypeCode = model.WorkflowTypeCode;
            inventoryDraft.WorkflowStepId = model.WorkflowStepId;
            inventoryDraft.WorkflowStepTypeCode = model.WorkflowStepTypeCode;
            inventoryDraft.NumberArray = model.NumberArray;
            inventoryDraft.NumberNumeric = model.NumberNumeric;
            inventoryDraft.Number = model.Number;
            inventoryDraft.StatusCode = model.StatusCode;
            inventoryDraft.AvailabilityStatusCode = model.AvailabilityStatusCode;
            inventoryDraft.DescriptionLevelCode = model.DescriptionLevelCode;
            inventoryDraft.AcquisitionMethodId = model.AcquisitionMethodId;
            inventoryDraft.ApproxmateChronologicalScope = model.ApproxmateChronologicalScope;
            inventoryDraft.HasNoChronologicalScope = model.HasNoChronologicalScope;
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
            inventoryDraft.LinearMeters = model.LinearMeters;
            inventoryDraft.OtherMetrics = model.OtherMetrics;
            inventoryDraft.Notes = model.Notes;
            inventoryDraft.ClassificationScheme = model.ClassificationScheme;
            inventoryDraft.AbbreviationList = model.AbbreviationList;
            inventoryDraft.Bytes = model.Bytes;
            inventoryDraft.ArchivalEntityCount = model.ArchivalEntityCount;
            inventoryDraft.DocumentCount = model.DocumentCount;
            inventoryDraft.DigitizedArchivalEntityCount = model.DigitizedArchivalEntityCount;
            inventoryDraft.AudioDocumentArchivalEntityCount = model.AudioDocumentArchivalEntityCount;
            inventoryDraft.DigitalDocumentArchivalEntityCount = model.DigitalDocumentArchivalEntityCount;
            inventoryDraft.MicrofilmedArchivalEntityCount = model.MicrofilmedArchivalEntityCount;
            inventoryDraft.PhotoDocumentArchivalEntityCount = model.PhotoDocumentArchivalEntityCount;
            inventoryDraft.VideoDocumentArchivalEntityCount = model.VideoDocumentArchivalEntityCount;
            inventoryDraft.NegativeFrameCount = model.NegativeFrameCount;
            inventoryDraft.PositiveFrameCount = model.PositiveFrameCount;
            inventoryDraft.BoxCount = model.BoxCount;
            inventoryDraft.RollCount = model.RollCount;
            inventoryDraft.HasExternalSource = model.HasExternalSource;
            inventoryDraft.ExternalIdentifier = model.ExternalIdentifier;
            inventoryDraft.ApplicationId = model.ApplicationId;
            inventoryDraft.PackageAid = model.PackageAId;
            inventoryDraft.PackageBid = model.PackageBId;
            inventoryDraft.OtherLanguage = model.OtherLanguage;

            if (model.HasExternalSource)
            {
                inventoryDraft.ExternalSourceUpdatedOn = DateTime.UtcNow;
            }

            _context.Update(inventoryDraft);

            var inventoryNomenclatureValues = _nomenclatureService.GetEntityNomenclatureValues(
                inventoryDraft.Id, BusinessObjectType.Inventory, true, null);


            //Update originality values
            if (model.OriginalityCodes?.Count() > 0)
            {
                var originalityValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.OriginalityCodes, inventoryNomenclatureValues, Shared.NomenclatureCode.Originality,
                    inventoryDraft.Id, BusinessObjectType.Inventory, true);

                if (originalityValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(originalityValuesToAdd);
                }
            }

            var originalityValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.OriginalityCodes, inventoryNomenclatureValues, Shared.NomenclatureCode.Originality);

            if(originalityValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(originalityValuesToDelete);
            }


            //Update creation method values
            if (model.CreationMethodCodes?.Count() > 0)
            {
                var creationMethodValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.CreationMethodCodes, inventoryNomenclatureValues, Shared.NomenclatureCode.CreationMethod,
                    inventoryDraft.Id, BusinessObjectType.Inventory, true);

                if (creationMethodValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(creationMethodValuesToAdd);
                }
            }

            var creationMethodValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.CreationMethodCodes, inventoryNomenclatureValues, Shared.NomenclatureCode.CreationMethod);

            if(creationMethodValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(creationMethodValuesToDelete);
            }


            //Update file type values
            if (model.FileTypeCodes?.Count() > 0)
            {
                var fileTypeValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.FileTypeCodes, inventoryNomenclatureValues, Shared.NomenclatureCode.FileType,
                    inventoryDraft.Id, BusinessObjectType.Inventory, true);

                if (fileTypeValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(fileTypeValuesToAdd);
                }
            }

            var fileTypeValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.FileTypeCodes, inventoryNomenclatureValues, Shared.NomenclatureCode.FileType);

            if(fileTypeValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(fileTypeValuesToDelete);
            }


            //Update language values
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, inventoryNomenclatureValues, Shared.NomenclatureCode.Language,
                    inventoryDraft.Id, BusinessObjectType.Inventory, true);

                if (languageValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(languageValuesToAdd);
                }
            }

            var languageValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.LanguageCodes, inventoryNomenclatureValues, Shared.NomenclatureCode.Language);

            if(languageValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(languageValuesToDelete);
            }


            await _context.SaveAsync("Inventory draft updated");

            return inventoryDraft.SystemIdentifier;
        }

        public async Task<OperationResult> UpdateDraftAsync(InventoryDraftModel model)
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
                var inventorySysId = await ((IInventoryServiceBase)this).UpdateDraftInternalAsync(model);

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

        async Task<Guid> IInventoryServiceBase.UpdateInventoryInternalAsync(InventoryModel model, Guid? updatedBy, DateTime? updatedOn)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            if (!model.SystemIdentifier.HasValue)
            {
                throw new SystemIdentifierNullException(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            var inventory = await _context.Inventories.FindAsync(model.Id);
            if (inventory == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), model.Id!.Value.ToString());
            }

            inventory.ArchiveId = model.ArchiveId;
            inventory.FundSystemIdentifier = model.FundSystemIdentifier!.Value;
            inventory.NumberArray = model.NumberArray;
            inventory.NumberNumeric = model.NumberNumeric;
            inventory.Number = model.Number;
            inventory.StatusCode = model.StatusCode;
            inventory.AvailabilityStatusCode = model.AvailabilityStatusCode;
            inventory.DescriptionLevelCode = model.DescriptionLevelCode;
            inventory.AcquisitionMethodId = model.AcquisitionMethodId;
            inventory.ApproxmateChronologicalScope = model.ApproxmateChronologicalScope;
            inventory.HasNoChronologicalScope = model.HasNoChronologicalScope;
            inventory.StartDateDay = model.StartDateDay;
            inventory.StartDateMonth = model.StartDateMonth;
            inventory.StartDateYear = model.StartDateYear;
            inventory.EndDateDay = model.EndDateDay;
            inventory.EndDateMonth = model.EndDateMonth;
            inventory.EndDateYear = model.EndDateYear;
            inventory.FundCreatorBiographicalHistory = model.FundCreatorBiographicalHistory;
            inventory.FundCreatorTitleHistory = model.FundCreatorTitleHistory;
            inventory.History = model.History;
            inventory.DocumentsAccessDescription = model.DocumentsAccessDescription;
            inventory.DocumentsDescription = model.DocumentsDescription;
            inventory.DocumentsProvider = model.DocumentsProvider;
            inventory.LinearMeters = model.LinearMeters;
            inventory.OtherMetrics = model.OtherMetrics;
            inventory.Notes = model.Notes;
            inventory.ClassificationScheme = model.ClassificationScheme;
            inventory.AbbreviationList = model.AbbreviationList;
            inventory.Bytes = model.Bytes;
            inventory.ArchivalEntityCount = model.ArchivalEntityCount;
            inventory.DocumentCount = model.DocumentCount;
            inventory.DigitizedArchivalEntityCount = model.DigitizedArchivalEntityCount;
            inventory.AudioDocumentArchivalEntityCount = model.AudioDocumentArchivalEntityCount;
            inventory.DigitalDocumentArchivalEntityCount = model.DigitalDocumentArchivalEntityCount;
            inventory.MicrofilmedArchivalEntityCount = model.MicrofilmedArchivalEntityCount;
            inventory.PhotoDocumentArchivalEntityCount = model.PhotoDocumentArchivalEntityCount;
            inventory.VideoDocumentArchivalEntityCount = model.VideoDocumentArchivalEntityCount;
            inventory.NegativeFrameCount = model.NegativeFrameCount;
            inventory.PositiveFrameCount = model.PositiveFrameCount;
            inventory.BoxCount = model.BoxCount;
            inventory.RollCount = model.RollCount;
            inventory.HasExternalSource = model.HasExternalSource;
            inventory.ExternalIdentifier = model.ExternalIdentifier;
            inventory.ApplicationId = model.ApplicationId;
            inventory.PackageAid = model.PackageAId;
            inventory.PackageBid = model.PackageBId;
            inventory.OtherLanguage = model.OtherLanguage;

            if (model.HasExternalSource)
            {
                inventory.ExternalSourceUpdatedOn = DateTime.UtcNow;
            }
            bool overwriteModified = updatedBy.HasValue && updatedOn.HasValue;
            if (overwriteModified)
            {
                inventory.UpdatedBy = updatedBy;
                inventory.UpdatedOn = updatedOn;
            }

            _context.Update(inventory);

            var inventoryNomenclatureValues = _nomenclatureService.GetEntityNomenclatureValues(
                inventory.Id, BusinessObjectType.Inventory, false, null);


            //Update originality values
            if (model.OriginalityCodes?.Count() > 0)
            {
                var originalityValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.OriginalityCodes, inventoryNomenclatureValues, Shared.NomenclatureCode.Originality,
                    inventory.Id, BusinessObjectType.Inventory, false,
                    overwriteModified, updatedBy, updatedOn);

                if (originalityValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(originalityValuesToAdd);
                }
            }

            var originalityValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.OriginalityCodes, inventoryNomenclatureValues, Shared.NomenclatureCode.Originality);

            if(originalityValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(originalityValuesToDelete);
            }


            //Update creation method values
            if (model.CreationMethodCodes?.Count() > 0)
            {
                var creationMethodValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.CreationMethodCodes, inventoryNomenclatureValues, Shared.NomenclatureCode.CreationMethod,
                    inventory.Id, BusinessObjectType.Inventory, false,
                    overwriteModified, updatedBy, updatedOn);

                if (creationMethodValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(creationMethodValuesToAdd);
                }
            }

            var creationMethodValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.CreationMethodCodes, inventoryNomenclatureValues, Shared.NomenclatureCode.CreationMethod);

            if (creationMethodValuesToDelete != null) 
            {
                _context.NomenclatureValues.RemoveRange(creationMethodValuesToDelete);
            }


            //Update file type values
            if (model.FileTypeCodes?.Count() > 0)
            {
                var fileTypeValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.FileTypeCodes, inventoryNomenclatureValues, Shared.NomenclatureCode.FileType,
                    inventory.Id, BusinessObjectType.Inventory, false,
                    overwriteModified, updatedBy, updatedOn);

                if (fileTypeValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(fileTypeValuesToAdd);
                }
            }

            var fileTypeValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(
                model.FileTypeCodes, inventoryNomenclatureValues, Shared.NomenclatureCode.FileType);

            if(fileTypeValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(fileTypeValuesToDelete);
            }


            //Update language values
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, inventoryNomenclatureValues, Shared.NomenclatureCode.Language,
                    inventory.Id, BusinessObjectType.Inventory, false,
                    overwriteModified, updatedBy, updatedOn);

                if (languageValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(languageValuesToAdd);
                }
            }

            var languageValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(model.LanguageCodes, inventoryNomenclatureValues, Shared.NomenclatureCode.Language);
            if(languageValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(languageValuesToDelete);
            }

            await _context.SaveAsync("Inventory updated", overwriteModified, overwriteModified);

            return inventory.SystemIdentifier;
        }

        public async Task<OperationResult> UpdateInventoryAsync(InventoryModel model)
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
                var inventorySysId = await ((IInventoryServiceBase)this).UpdateInventoryInternalAsync(model);

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

        async Task IInventoryServiceBase.DeleteDraftInternalAsync(int id)
        {
            //TODO: Да се добави изтриването на всички нива под описа?
            var inventoryDraft = await _context.InventoryDrafts.FindAsync(id);
            if (inventoryDraft == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), id.ToString());
            }
            if (!inventoryDraft.IsCurrent)
            {
                throw new ItemDraftNotCurrentException(_localizer.GetString("Error_DraftNotCurrent").ToString(), id.ToString());
            }

            inventoryDraft.IsCurrent = false;
            inventoryDraft.ReadOnly = true;
            inventoryDraft.Deleted = true;
            inventoryDraft.DeletedOn = DateTime.UtcNow;
            inventoryDraft.DeletedBy = _userInfo.CurrentUserId;

            _context.Update(inventoryDraft);

            var draftNomValues = _nomenclatureService.GetEntityNomenclatureValues(inventoryDraft.Id, BusinessObjectType.Inventory, true, null);
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

            await _context.SaveAsync("Inventory draft deleted");
        }

        public async Task<OperationResult> DeleteDraftAsync(int id)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await ((IInventoryServiceBase)this).DeleteDraftInternalAsync(id);

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
                return OperationResult.Failed(exc.ToString());
            }
        }

        async Task IInventoryServiceBase.DeleteInventoryInternalAsync(Guid sysId)
        {
            //TODO: Да се добави изтриването на всички нива под описа?
            var inventoryDrafts =
                _context.InventoryDrafts
                .Where(inv => inv.SystemIdentifier == sysId && !inv.Deleted)
                .Select(inv => inv);

            await inventoryDrafts.ForEachAsync(inv =>
            {
                inv.IsCurrent = false;
                inv.ReadOnly = true;
                inv.Deleted = true;
                inv.DeletedBy = _userInfo.CurrentUserId;
                inv.DeletedOn = DateTime.UtcNow;
            });

            var draftNomValues = _nomenclatureService.GetEntityNomenclatureValues(inventoryDrafts.Select(inv => inv.Id).ToList(), BusinessObjectType.Inventory, true, null);
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

            var inventory =
                await _context.Inventories
                .Where(inv => inv.SystemIdentifier == sysId && !inv.Deleted)
                .SingleOrDefaultAsync();

            if (inventory != null)
            {
                inventory.Deleted = true;
                inventory.DeletedOn = DateTime.UtcNow;
                inventory.DeletedBy = _userInfo.CurrentUserId;

                _context.Update(inventory);

                var entityNomValues = _nomenclatureService.GetEntityNomenclatureValues(inventory.Id, BusinessObjectType.Inventory, false, null);
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

            await _context.SaveAsync("Inventory deleted");
        }

        public async Task<OperationResult> DeleteInventoryAsync(Guid sysId)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await ((IInventoryServiceBase)this).DeleteInventoryInternalAsync(sysId);

                transaction.Commit();
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<InventoryDisplayModel?> GetFromExternalSourceAsync(
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

            var archiveId = await _archiveService.GetArchiveIdByCodeAsync(result.ArchiveCode!.Value);
            if (!fundSystemIdentifier.HasValue)
            {
                fundSystemIdentifier = await _fundService.GetSystemIdentifierByExternalIdentifierAsync(result.FundExternalIdentifier!.Value);
            }


            InventoryDisplayModel model = new InventoryDisplayModel()
            {
                Id = result.Id,
                SystemIdentifier = systemIdentifier,
                IsDraft = false,
                HasExternalSource = result.HasExternalSource ?? false,
                ExternalIdentifier = result.ExternalIdentifier,
                ArchiveId = archiveId,
                ArchiveCode = result.ArchiveCode,
                ArchiveName = result.ArchiveName,
                FundNumber = result.FundNumber,
                FundSystemIdentifier = fundSystemIdentifier,
                FundHasExternalSource = result.FundHasExternalSource!.Value,
                FundExternalIdentifier = result.FundExternalIdentifier,
                NumberArray = result.NumberArray,
                NumberNumeric = result.NumberNumeric,
                Number = result.Number,
                StatusCode = result.StatusCode!,
                StatusText = result.StatusText,
                DescriptionLevelCode =
                    !string.IsNullOrEmpty(result.DescriptionLevelCode)
                    ? DescriptionLevelMapping.InventoryDescriptionLevel.GetValueOrDefault(result.DescriptionLevelCode)!
                    : string.Empty,
                DescriptionLevelText = result.DescriptionLevelText,
                AvailabilityStatusCode = result.AvailabilityStatusCode,
                AvailabilityStatusText = result.AvailabilityStatusText,
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
                RollCount = result.RollCount,
                AudioDocumentArchivalEntityCount = result.AudioDocumentArchivalEntityCount,
                PhotoDocumentArchivalEntityCount = result.PhotoDocumentArchivalEntityCount,
                VideoDocumentArchivalEntityCount = result.VideoDocumentArchivalEntityCount,
                DigitalDocumentArchivalEntityCount = result.VideoDocumentArchivalEntityCount,
                ClassificationScheme = result.ClassificationScheme,
                AbbreviationList = result.AbbreviationList,
                MicrofilmedArchivalEntityCount = result.MicrofilmedArchivalEntityCount,
                DigitizedArchivalEntityCount = result.DigitizedArchivalEntityCount,
                NegativeFrameCount = result.NegativeFrameCount,
                PositiveFrameCount = result.PositiveFrameCount,
                CreatedOn = result.CreatedOn,
                CreatedByDisplayName = result.CreatedByDisplayName,
                UpdatedOn = result.UpdatedOn,
                UpdatedByDisplayName = result.UpdatedByDisplayName,
                EnrolledAECount = result.EnrolledAECount,
                EnrolledBytes = result.EnrolledBytes,
                EnrolledLinearMeters = result.EnrolledLinearMeters,
                DeductedAECount = result.DeductedAECount,
                DeductedBytes = result.DeductedBytes,
                DeductedLinearMeters = result.DeductedLinearMeters,
            };

            if (systemIdentifier != null)
            {
                var sizeInfo = await _context.VInventorySizeInfos
                   .Where(x => x.InventorySystemIdentifier == systemIdentifier && x.IsDraft == 0)
                   .SingleOrDefaultAsync();
                if (sizeInfo != null)
                {
                    model.ArchivalEntityCount = model.ArchivalEntityCount.HasValue ? model.ArchivalEntityCount.Value + sizeInfo.EnrolledArchivalEntityCount : sizeInfo.EnrolledArchivalEntityCount;
                    model.DigitalDocumentArchivalEntityCount = model.DigitalDocumentArchivalEntityCount.HasValue ? model.DigitalDocumentArchivalEntityCount.Value + sizeInfo.EnrolledArchivalEntityCount : sizeInfo.EnrolledArchivalEntityCount;
                    model.DocumentCount = sizeInfo.EnrolledDocumentCount;
                    model.Bytes = model.EnrolledBytes.HasValue ? sizeInfo.EnrolledBytes + model.EnrolledBytes : sizeInfo.EnrolledBytes;
                    model.EnrolledBytes = model.EnrolledBytes.HasValue ? sizeInfo.EnrolledBytes + model.EnrolledBytes : sizeInfo.EnrolledBytes;
                    model.DeductedBytes = model.DeductedBytes.HasValue ? model.DeductedBytes + sizeInfo.DeductedBytes : sizeInfo.DeductedBytes;
                    model.EnrolledAECount = model.EnrolledAECount.HasValue ? model.EnrolledAECount + sizeInfo.EnrolledArchivalEntityCount : sizeInfo.EnrolledArchivalEntityCount;
                    model.DeductedAECount = model.DeductedAECount.HasValue ? model.DeductedAECount + sizeInfo.DeductedArchivalEntityCount : sizeInfo.DeductedArchivalEntityCount;
                    string fileTypes = sizeInfo.FileTypes != null
                        ? String.Join(
                            System.Globalization.CultureInfo.CurrentCulture.TextInfo.ListSeparator + " ",
                            sizeInfo.FileTypes.Split("; ").Distinct()).ToUpper()
                        : String.Empty;
                    model.FileTypeText = fileTypes;
                    model.TextDocsCount = sizeInfo.TextDocsCount;
                    model.GraphicalDocsCount = sizeInfo.GraphicalDocsCount;
                }
            }

            return model;
        }

        public async Task<IEnumerable<SearchedInventoryShortDisplayModel>> GetShortByFundId(int fundId)
        {
            var result = await _context.Inventories
                    //.Where(x => !x.Deleted && x.FundId == fundId)
                    .Select(x => new SearchedInventoryShortDisplayModel()
                    {
                        Id = x.Id,
                        CommonId = $"{x.Id}_{x.ExternalIdentifier}",
                        //Name = CommonHelper.GenerateCompositeName(x.Number, x.Title)
                        Name = x.Number
                    })
                    .ToListAsync();

            return result;
        }

        public async Task<int?> GetIdByExternalIdentifier(int externalIdentifier)
        {
            return
                await _context.Inventories
                .Where(inv => inv.ExternalIdentifier == externalIdentifier)
                .Select(inv => inv.Id)
                .SingleOrDefaultAsync();
        }

        public async Task<Guid?> GetSystemIdentifierByExternalIdentifierAsync(int externalIdentifier)
        {
            return
                await _context.Inventories
                .Where(inv => inv.ExternalIdentifier == externalIdentifier)
                .Select(inv => inv.SystemIdentifier)
                .SingleOrDefaultAsync();
        }

        public async Task<int?> GetArchiveIdAsync(Guid sysId)
        {
            var entity =
                await _context.VInventories
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
                var entity = await _context.VInventories
                    .Where(x => x.SystemIdentifier == process.InventorySystemIdentifier && !x.Deleted)
                    .SingleOrDefaultAsync();

                return entity?.ArchiveId;
            }

            return null;
        }

        public async Task<int?> GetDescriptionLevelAsync(Guid sysId)
        {
            var inventory = await GetInventoryBySystemIdentifierAsync(sysId);
            if (inventory == null)
            {
                return null;
            }
            //var descriptionLevelCode = await _context.VInventories
            //                            .Where(inv => inv.SystemIdentifier == sysId && (!inv.HasExternalSource.HasValue || !inv.HasExternalSource.Value) && !inv.Deleted)
            //                            .Select(inv => inv.DescriptionLevelCode)
            //                            .SingleOrDefaultAsync();
            //if (string.IsNullOrWhiteSpace(descriptionLevelCode))
            //{
            //    return null;
            //}

            //if (!int.TryParse(descriptionLevelCode, out var inventoryDescriptionLevel))
            //{
            //    _logger.LogError($"Error parsing description level code for inventory with sysId {sysId}");
            //    throw new InvalidDataException(nameof(descriptionLevelCode));
            //}
            if (!int.TryParse(inventory.DescriptionLevelCode, out var inventoryDescriptionLevel))
            {
                _logger.LogError($"Error parsing description level code for inventory with sysId {sysId}");
                throw new InvalidDataException(nameof(inventory.DescriptionLevelCode));
            }
            return inventoryDescriptionLevel;
        }

        public async Task<DataSourceResponseModel<PublicUserReviewDisplayModel>> GetInventoryPublicUsersReviewsAsync(Guid? systemIdentifier)
        {
            int totalCount = 0;
            IEnumerable<PublicUserReviewDisplayModel> items = Enumerable.Empty<PublicUserReviewDisplayModel>();
            List<object> errors = new List<object>();

            if (systemIdentifier.HasValue)
            {
                var publicUserReviews =
                    _context.UserReviews
                    .Where(r => r.InventorySystemIdentifier == systemIdentifier.Value && r.User.UserType == ApplicationUserType.External)
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

        public async Task<OperationResult?> CreateInventoryReviewAsync(Guid? inventorySystemIdentifier, int? inventoryExternalIdentifier)
        {

            Guid systemIdentifier = Guid.NewGuid();

            UserReview employeeReview = new UserReview
            {
                SystemIdentifier = systemIdentifier,
                UserId = _userInfo.CurrentUserId.Value,
                Date = DateTime.UtcNow
            };

            if ((inventorySystemIdentifier.HasValue && inventorySystemIdentifier.Value != Guid.Empty) || inventoryExternalIdentifier.HasValue)
            {
                if (inventorySystemIdentifier.HasValue && inventorySystemIdentifier.Value != Guid.Empty)
                {
                    employeeReview.InventorySystemIdentifier = inventorySystemIdentifier.Value;
                }
                if (inventoryExternalIdentifier.HasValue)
                {
                    employeeReview.InventoryExternalIdentifier = inventoryExternalIdentifier;
                }
            }
            else
            {
                return OperationResult.Succeed("No review for missing inventory system identifier");
            }

            await _context.UserReviews.AddAsync(employeeReview);
            await _context.SaveAsync("Employee review created");

            return OperationResult.Success;
        }

    }
}
