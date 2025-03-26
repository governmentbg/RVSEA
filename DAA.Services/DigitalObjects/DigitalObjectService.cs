using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Extensions.Models;
using DAA.FileUtils;
using DAA.Models.Configuration;
using DAA.Models.DigitalObjects;
using DAA.Models.File;
using DAA.Models.Reports;
using DAA.Services.ArchivalEntities;
using DAA.Services.Documents;
using DAA.Services.Files;
using DAA.Services.FileUploadApp;
using DAA.Services.Funds;
using DAA.Services.Interfaces;
using DAA.Services.Inventories;
using DAA.Services.Watermark;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Http;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Drawing;
using System.Drawing.Imaging;
using System.Text;

namespace DAA.Services.DigitalObjects
{
    public class DigitalObjectService : BaseService, IDigitalObjectService
    {
        private readonly LinkedServerSettings _settings;
        private readonly IUserInfo _userInfo;
        private readonly IArchiveService _archiveService;
        private readonly IFundService _fundService;
        private readonly IInventoryService _inventoryService;
        private readonly IArchivalEntityService _archivalEntityService;
        private readonly IDocumentService _documentService;
        private readonly IFileService _fileService;
        private readonly IFileUploadAppService _fileUploadAppService;
        private readonly IWatermarkService _watermarkService;
        private readonly IUtilityService _utilityService;

        public DigitalObjectService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            ILogger<DigitalObjectService> logger,
            IOptions<LinkedServerSettings> settings,
            IUserInfo userInfo,
            IArchiveService archiveService,
            IFundService fundService,
            IInventoryService inventoryService,
            IArchivalEntityService archiveEntityService,
            IDocumentService documentService,
            IFileService fileService,
            IWatermarkService watermarkService,
            IFileUploadAppService fileUploadAppService,
            IUtilityService utilityService)
            : base(context, localizer, logger)
        {
            _settings = settings.Value;
            _userInfo = userInfo;
            _archiveService = archiveService;
            _fundService = fundService;
            _inventoryService = inventoryService;
            _archivalEntityService = archiveEntityService;
            _documentService = documentService;
            _fileService = fileService;
            _fileUploadAppService = fileUploadAppService;
            _watermarkService = watermarkService;
            _utilityService = utilityService;
        }

        public async Task<DataSourceResponseModel<DigitalObjectDisplayModel?>> GetByDocumentIdentifierAsync(
            DataSourceRequestModel model,
            Guid? documentSysId,
            bool documentHasExternalSource = false,
            int? documentExternalIdentifier = null,
            bool? digitized = null,
            bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            int totalCount = 0;
            IEnumerable<DigitalObjectDisplayModel?> items = Enumerable.Empty<DigitalObjectDisplayModel?>();
            List<object> errors = new List<object>();
            bool isExternalSourceSnapshot = false;

            try
            {
                //Get item count
                string countQuery = "exec @ReturnValue = sp_GetDocumentDigitalObjectsCount @LinkedServer, @DocumentIdentifier, @DocumentHasExternalSource, @DocumentExternalIdentifier, @Digitized, @IncludeDeleted";
                List<SqlParameter> countQueryParams = new List<SqlParameter>()
                {
                    new SqlParameter("LinkedServer", _settings.LinkedServer),
                    new SqlParameter("DocumentIdentifier", documentSysId.HasValue ? documentSysId.Value : DBNull.Value),
                    new SqlParameter("DocumentHasExternalSource", documentHasExternalSource),
                    new SqlParameter("DocumentExternalIdentifier", documentExternalIdentifier.HasValue ? documentExternalIdentifier.Value : DBNull.Value),
                    new SqlParameter("Digitized", digitized.HasValue ? digitized.Value : DBNull.Value),
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

                //Get items
                string query = "exec sp_GetDocumentDigitalObjects " +
                "@LinkedServer, @DocumentIdentifier, @DocumentHasExternalSource, @DocumentExternalIdentifier, @Digitized, @IncludeDeleted, @Paging, @PageNumber, @PageSize";
                List<SqlParameter> queryParams = new()
                {
                    new SqlParameter("LinkedServer", _settings.LinkedServer),
                    new SqlParameter("DocumentIdentifier", documentSysId.HasValue ? documentSysId.Value : DBNull.Value),
                    new SqlParameter("DocumentHasExternalSource", documentHasExternalSource),
                    new SqlParameter("DocumentExternalIdentifier", documentExternalIdentifier.HasValue ? documentExternalIdentifier.Value : DBNull.Value),
                    new SqlParameter("Digitized", digitized.HasValue ? digitized.Value : DBNull.Value),
                    new SqlParameter("IncludeDeleted", includeDeleted),
                    new SqlParameter("Paging", false),
                    new SqlParameter("PageNumber", model.Page),
                    new SqlParameter("PageSize", model.ItemsPerPage),
                };
                var queryResult = await _context.RemoteDigitalObjects
                        .FromSqlRaw(query, queryParams.ToArray())
                        .AsNoTracking()
                        .ToListAsync();

                items = queryResult
                    .Select(d => new DigitalObjectDisplayModel()
                    {
                        Id = d.Id,
                        SystemIdentifier = d.SystemIdentifier,
                        HasExternalSource = d.HasExternalSource,
                        ExternalIdentifier = d.ExternalIdentifier,
                        IsDraft = d.IsDraft ?? false,
                        ArchiveName = d.ArchiveName,
                        FundNumber = d.FundNumber,
                        InventoryNumber = d.InventoryNumber,
                        ArchivalEntityNumber = d.ArchivalEntityNumber,
                        DocumentNumber = d.DocumentNumber,
                        ParentSystemIdentifier = d.ParentSystemIdentifier,
                        TypeCode = d.TypeCode,
                        FileType = d.FileType,
                        Name = d.Name,
                        SourceName = d.SourceName,
                        IsDigitized = d.IsDigitized ?? false,
                        ParentId = d.ParentId,
                        IsImported = d.IsImported ?? false,
                    });

            }
            catch (SqlException exc) //Най-вероятната причина е липса на връзка с ИСДА
            {
                _logger.LogWarning(exc, $"Error getting digital objects count for document (docSysId: {documentSysId}, docExternalIdentifier: {documentExternalIdentifier}) from external source");

                //Get items from local database
                if (documentSysId.HasValue && documentSysId.Value != Guid.Empty)
                {
                    var localQuery =
                            _context.VDigitalObjects
                            .Where(d => d.DocumentSystemIdentifier == documentSysId.Value);
                    if (digitized.HasValue)
                    {
                        localQuery = localQuery.Where(d => d.IsDigitized == digitized);
                    }
                    if (!includeDeleted)
                    {
                        localQuery = localQuery.Where(d => !d.Deleted);
                    }

                    totalCount = await localQuery.CountAsync();
                    items = await localQuery
                        .Select(d => new DigitalObjectDisplayModel()
                        {
                            Id = d.Id,
                            SystemIdentifier = d.SystemIdentifier,
                            HasExternalSource = d.HasExternalSource ?? false,
                            ExternalIdentifier = d.ExternalIdentifier,
                            IsDraft = d.IsDraft ?? false,
                            ArchiveName = d.ArchiveName,
                            FundNumber = d.FundNumber,
                            InventoryNumber = d.InventoryNumber,
                            ArchivalEntityNumber = d.ArchivalEntityNumber,
                            ParentSystemIdentifier = d.ParentSystemIdentifier,
                            StatusCode = d.StatusCode!,
                            TypeCode = d.TypeCode,
                            FileType = d.FileType,
                            Name = d.Name,
                            SourceName = d.SourceName,
                            ContentType = d.ContentType,
                            IsDigitized = d.IsDigitized,
                            IsExternalSourceSnapshot = true,
                        })
                        .ToListAsync();
                    isExternalSourceSnapshot = true;
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting digital objects count for document (docSysId: {documentSysId}, docExternalIdentifier: {documentExternalIdentifier}) from external source");
                errors.Add(exc.ToString());
            }

            DataSourceResponseModel<DigitalObjectDisplayModel?> result = new DataSourceResponseModel<DigitalObjectDisplayModel?>()
            {
                TotalCount = totalCount,
                Errors = errors.Count > 0 ? errors : null,
                IsExternalSourceSnapshot = isExternalSourceSnapshot,
                Items = items != null && items.Count() > 0 ? items.OrderBy(x => x!.TypeCode).ThenBy(x => x!.Id).ThenBy(x => x!.ParentId) : null
            };

            return result;
        }

        public async Task<DataSourceResponseModel<DigitalObjectDisplayModel?>> GetByInventoryIdentifierAsync(
            DataSourceRequestModel model,
            Guid? inventorySysId,
            bool inventoryHasExternalSource = false,
            int? inventoryExternalIdentifier = null,
            bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            int totalCount = 0;
            IEnumerable<DigitalObjectDisplayModel?> items = Enumerable.Empty<DigitalObjectDisplayModel?>();
            List<object> errors = new List<object>();

            //TODO: Add data from external source

            if (inventorySysId.HasValue && inventorySysId.Value != Guid.Empty)
            {
                var localQuery =
                        _context.VDigitalObjects
                        .Where(d => d.InventorySystemIdentifier == inventorySysId.Value);
                if (!includeDeleted)
                {
                    localQuery = localQuery.Where(d => !d.Deleted);
                }

                totalCount = await localQuery.CountAsync();
                items = await localQuery
                    .Select(d => new DigitalObjectDisplayModel()
                    {
                        SystemIdentifier = d.SystemIdentifier,
                        HasExternalSource = d.HasExternalSource ?? false,
                        ExternalIdentifier = d.ExternalIdentifier,
                        ArchiveName = d.ArchiveName,
                        FundNumber = d.FundNumber,
                        InventoryNumber = d.InventoryNumber,
                        ArchivalEntityNumber = d.ArchivalEntityNumber,
                        StatusCode = d.StatusCode!,
                        TypeCode = d.TypeCode,
                        FileType = d.FileType,
                        Name = d.Name,
                        SourceName = d.SourceName,
                        ContentType = d.ContentType,
                        IsDigitized = d.IsDigitized,
                        IsExternalSourceSnapshot = true,
                    })
                    .ToListAsync();
            }

            DataSourceResponseModel<DigitalObjectDisplayModel?> result = new DataSourceResponseModel<DigitalObjectDisplayModel?>()
            {
                TotalCount = totalCount,
                Errors = errors.Count > 0 ? errors : null,
                Items = items
            };

            return result;
        }


        public async Task<DigitalObjectDisplayModel?> GetDigitalObjectByDocumentIdentifierAsync(
            string digitalObjectName,
            Guid documentSysId)
        {
            return await _context.VDigitalObjects
                .Where(d => d.DocumentSystemIdentifier == documentSysId && d.SourceName == digitalObjectName && !d.Deleted)
                .Select(d => d.ToDisplayModel())
                .SingleOrDefaultAsync();
        }

        public async Task<OperationResult> ManageDigitalObjectReviewAsync(DigitalObjectDisplayModel digitalObject)
        {
            DigitalObjectReview[]? reviews = _context.DigitalObjectReviews
                                  .Where(r => r.UserSystemIdentifier == _userInfo.CurrentUserId
                                      && r.DigitalObjectSystemIdentifier == digitalObject.SystemIdentifier).ToArray();

            DigitalObjectReview? lastReview = reviews.Length > 0 ? reviews[reviews.Length - 1] : null;
            bool lastMinuteReview = lastReview != null
                                    && lastReview.Date.Year == DateTime.UtcNow.Year
                                    && lastReview.Date.Month == DateTime.UtcNow.Month
                                    && lastReview.Date.Day == DateTime.UtcNow.Day
                                    && lastReview.Date.Hour == DateTime.UtcNow.Hour
                                    && lastReview.Date.Minute == DateTime.UtcNow.Minute;

            if (!lastMinuteReview && !(FileType.Video.ToString().Contains(digitalObject.FileType) || FileType.Audio.ToString().Contains(digitalObject.FileType)) && digitalObject.SystemIdentifier != null)
            {
                return await CreateDigitalObjectReviewAsync(digitalObject.SystemIdentifier.Value);
            }
            if (lastMinuteReview) return OperationResult.Success;
            return OperationResult.Failed($"Review of {nameof(digitalObject.SystemIdentifier)}");
        }

        public async Task<DigitalObjectDisplayModel?> GetDigitalObjectBySystemIdentifierAsync(Guid sysId)
        {
            var digitalObjectDraft = await GetCurrentDraftAsync(sysId);
            if (digitalObjectDraft != null)
            {
                return digitalObjectDraft;
            }

            var digitalObject =
                await _context.DigitalObjects
                .Where(d => d.SystemIdentifier == sysId && !d.Deleted)
                .Select(entity => new DigitalObjectDisplayModel()
                {
                    Id = entity.Id,
                    SystemIdentifier = entity.SystemIdentifier,
                    HasExternalSource = entity.HasExternalSource,
                    ExternalIdentifier = entity.ExternalIdentifier,
                    ParentId = entity.ParentId,
                    ParentSystemIdentifier = entity.ParentSystemIdentifier,
                    ExternalSourceUpdatedOn = entity.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    ArchiveId = entity.ArchiveId,
                    ArchiveCode = entity.Archive.Code,
                    ArchiveName = entity.Archive.Name,
                    FundSystemIdentifier = entity.FundSystemIdentifier,
                    FundHasExternalSource = entity.FundSystemIdentifierNavigation.HasExternalSource,
                    FundExternalIdentifier = entity.FundSystemIdentifierNavigation.ExternalIdentifier,
                    FundNumber = entity.FundSystemIdentifierNavigation.Number,
                    InventorySystemIdentifier = entity.InventorySystemIdentifier,
                    InventoryHasExternalSource = entity.InventorySystemIdentifierNavigation.HasExternalSource,
                    InventoryExternalIdentifier = entity.InventorySystemIdentifierNavigation.ExternalIdentifier,
                    InventoryNumber = entity.InventorySystemIdentifierNavigation.Number,
                    ArchivalEntitySystemIdentifier = entity.ArchivalEntitySystemIdentifier,
                    ArchivalEntityHasExternalSource = entity.ArchivalEntitySystemIdentifierNavigation.HasExternalSource,
                    ArchivalEntityExternalIdentifier = entity.ArchivalEntitySystemIdentifierNavigation.ExternalIdentifier,
                    ArchivalEntityNumber = entity.ArchivalEntitySystemIdentifierNavigation.Number,
                    DocumentSystemIdentifier = entity.DocumentSystemIdentifier,
                    DocumentHasExternalSource = entity.DocumentSystemIdentifierNavigation.HasExternalSource,
                    DocumentExternalIdentifier = entity.DocumentSystemIdentifierNavigation.ExternalIdentifier,
                    DocumentNumber = entity.DocumentSystemIdentifierNavigation.Number,
                    TypeCode = entity.TypeCode,
                    ContentType = entity.ContentType,
                    FileType = entity.FileType,
                    FileSize = entity.FileSize,
                    Name = entity.Name,
                    SourceName = entity.SourceName,
                    UncPath = entity.UncPath,
                    StatusCode = entity.StatusCode,
                    StatusText = entity.StatusCodeNavigation.Text,
                    CreatedBy = entity.CreatedBy,
                    CreatedByDisplayName = entity.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == entity.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = entity.CreatedByNavigation!.UserName,
                    CreatedOn = entity.CreatedOn.UtcToLocalTime(),
                    Deleted = entity.Deleted,
                    DeletedBy = entity.DeletedBy,
                    DeletedByDisplayName = entity.DeletedByNavigation != null ? entity.DeletedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == entity.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName : null,
                    DeletedByUserName = entity.DeletedByNavigation != null ? entity.DeletedByNavigation.UserName : null,
                    DeletedOn = entity.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = entity.UpdatedBy,
                    UpdatedByDisplayName = entity.UpdatedByNavigation != null ? entity.UpdatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == entity.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName : null,
                    UpdatedByUserName = entity.UpdatedByNavigation != null ? entity.UpdatedByNavigation.UserName : null,
                    UpdatedOn = entity.UpdatedOn.UtcToLocalTime(),
                    WatermarkName = entity.WatermarkName,
                    WatermarkUncPath = entity.WatermarkUncPath,
                    HashCode = entity.HashCode,
                    Duration = entity.Duration,
                    IsDigitized = entity.IsDigitized,
                    IsImported = entity.IsImported,
                    IsSuspended = entity.IsSuspended,
                })
                .SingleOrDefaultAsync();

            if (digitalObject != null)
            {
                digitalObject.IsDraft = false;
            }

            if (digitalObject != null && digitalObject.HasExternalSource && digitalObject.ExternalIdentifier.HasValue)
            {
                try
                {
                    digitalObject = await GetFromExternalSourceAsync(digitalObject.ExternalIdentifier.Value, digitalObject.SystemIdentifier);
                }
                catch (Exception exc)
                {
                    _logger.LogWarning(exc, $"Error getting digital object from external source (systemIdentifier: {digitalObject?.SystemIdentifier}, externalIdentifier: {digitalObject?.ExternalIdentifier})");

                    digitalObject.IsExternalSourceSnapshot = true;
                }
            }
            return digitalObject;
        }

        public async Task<DigitalObjectDisplayModel?> GetCurrentDraftAsync(Guid sysId)
        {
            var digitalObjectDraft =
                await _context.DigitalObjectDrafts
                .Where(draft => draft.SystemIdentifier == sysId && draft.IsCurrent && !draft.Deleted)
                .Select(entity => new DigitalObjectDisplayModel()
                {
                    Id = entity.Id,
                    SystemIdentifier = entity.SystemIdentifier,
                    HasExternalSource = entity.HasExternalSource ?? false,
                    ExternalIdentifier = entity.ExternalIdentifier,
                    ExternalSourceUpdatedOn = entity.ExternalSourceUpdatedOn.UtcToLocalTime(),
                    ParentId = entity.ParentId,
                    ParentSystemIdentifier = entity.ParentSystemIdentifier,
                    ArchiveId = entity.ArchiveId,
                    ArchiveCode = entity.Archive.Code,
                    ArchiveName = entity.Archive.Name,
                    FundDraftId = entity.FundDraftId,
                    FundSystemIdentifier = entity.FundSystemIdentifier,
                    InventoryDraftId = entity.InventoryDraftId,
                    InventorySystemIdentifier = entity.InventorySystemIdentifier,
                    ArchivalEntityDraftId = entity.ArchivalEntityDraftId,
                    ArchivalEntitySystemIdentifier = entity.ArchivalEntitySystemIdentifier,
                    DocumentDraftId = entity.DocumentDraftId,
                    DocumentSystemIdentifier = entity.DocumentSystemIdentifier,
                    TypeCode = entity.TypeCode,
                    ContentType = entity.ContentType,
                    FileType = entity.FileType,
                    FileSize = entity.FileSize,
                    Name = entity.Name,
                    SourceName = entity.SourceName,
                    UncPath = entity.UncPath,
                    StatusCode = entity.StatusCode!,
                    StatusText = entity.StatusCodeNavigation!.Text,
                    CreatedBy = entity.CreatedBy,
                    CreatedByDisplayName = entity.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == entity.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = entity.CreatedByNavigation!.UserName,
                    CreatedOn = entity.CreatedOn.UtcToLocalTime(),
                    Deleted = entity.Deleted,
                    DeletedBy = entity.DeletedBy,
                    DeletedByDisplayName = entity.DeletedByNavigation != null ? entity.DeletedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == entity.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName : null,
                    DeletedByUserName = entity.DeletedByNavigation != null ? entity.DeletedByNavigation.UserName : null,
                    DeletedOn = entity.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = entity.UpdatedBy,
                    UpdatedByDisplayName = entity.UpdatedByNavigation != null ? entity.UpdatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == entity.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName : null,
                    UpdatedByUserName = entity.UpdatedByNavigation != null ? entity.UpdatedByNavigation.UserName : null,
                    UpdatedOn = entity.UpdatedOn.UtcToLocalTime(),
                    WatermarkUncPath = entity.WatermarkUncPath,
                    WatermarkName = entity.WatermarkName,
                    HashCode = entity.HashCode,
                    Duration = entity.Duration,
                    PackageDocumentId = entity.PackageDocumentId,
                    IsImported = entity.IsImported,
                    IsDigitized = entity.IsDigitized,
                })
                .SingleOrDefaultAsync();

            if (digitalObjectDraft != null)
            {
                digitalObjectDraft.IsDraft = true;
            }

            return digitalObjectDraft;
        }

        public async Task<bool> HasCurrentDraftAsync(Guid sysId)
        {
            return await _context.DigitalObjectDrafts
                    .Where(dod => dod.SystemIdentifier == sysId && dod.IsCurrent && !dod.Deleted)
                    .AnyAsync();
        }

        public async Task<bool> IsCurrentDraftAsync(DigitalObjectDraftModel model)
        {
            return
                await _context.DigitalObjectDrafts
                .Where(dod => dod.Id == model.Id && dod.IsCurrent && !dod.Deleted)
                .AnyAsync();
        }

        public async Task<bool> IsReadOnlyDraftAsync(DigitalObjectDraftModel model)
        {
            return
                await _context.DigitalObjectDrafts
                .Where(dod => dod.Id == model.Id && (dod.ReadOnly || !dod.IsCurrent || dod.Deleted))
                .AnyAsync();
        }

        async Task<Guid> IDigitalObjectServiceBase.CreateDraftInternalAsync(DigitalObjectDraftModel model, bool fileExists, bool autogenerateDerivative)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            if (!fileExists && model.Content == null)
            {
                throw new ArgumentNullException(nameof(model.Content));
            }

            //If there is new document draft on edit
            if (!model.DocumentDraftId.HasValue)
            {
                var documentDraft = await _documentService.GetCurrentDraftAsync(model.DocumentSystemIdentifier!.Value);
                if (documentDraft != null)
                {
                    model.FundDraftId = documentDraft.FundDraftId;
                    model.InventoryDraftId = documentDraft.InventoryDraftId;
                    model.ArchivalEntityDraftId = documentDraft.ArchivalEntityDraftId;
                    model.DocumentDraftId = documentDraft.Id;
                }
            }

            string? uncFilePath = model.UncPath;
            string? sourceFilename = model.SourceName;
            string? systemFilename = model.Name;
            string? contentType = model.ContentType;
            string? fileType = model.FileType;
            long? fileSize = model.FileSize;
            string? hashCode = model.HashCode;
            string? watermarkFileName = model.WatermarkName;
            string? watermarkUncPath = model.WatermarkUncPath;
            double? duration = null;


            if (!fileExists)
            {
                FileModel fileModel = await ParseAttachmentAsync(model.Content!);

                bool isValidExtension = await _fileUploadAppService.IsFileExtensionValid(fileModel.Name);
                if (!isValidExtension)
                {
                    throw new FileTypeNotSupportedException(_localizer.GetString("Error_UnsupportedFileType", fileModel.Type).ToString());
                }

                var result = await _fileService.CreateFileAsync(fileModel, FileStreamLocation.Buffer);
                if (!result.Succeeded)
                {
                    throw new Exception(result.ToString());
                }

                sourceFilename = fileModel.Name;
                systemFilename = fileModel.SystemName;
                contentType = fileModel.ContentType;
                fileType = fileModel.Type;
                fileSize = fileModel.Size;
                hashCode = ChecksumUtil.Calculate(fileModel.Content!);
                uncFilePath = result.Data?.ToString();

                if (model.TypeCode == (int)DigitalObjectType.MasterFile)
                {
                    duration = await _fileService.TryGetFileDurationAsync(uncFilePath!, FileStreamLocation.Buffer);
                }
            }

            try
            {
                if (!model.SystemIdentifier.HasValue)
                {
                    model.SystemIdentifier = Guid.NewGuid();
                }
                else
                {
                    var currentDraft =
                        await _context.DigitalObjectDrafts
                        .Where(d => d.SystemIdentifier == model.SystemIdentifier && d.IsCurrent)
                        .SingleOrDefaultAsync();
                    if (currentDraft != null)
                    {
                        currentDraft.IsCurrent = false;
                        currentDraft.ReadOnly = true;
                        _context.Update(currentDraft);
                    }
                }

                var digitalObjectDraft = new DigitalObjectDraft()
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
                    DocumentDraftId = model.DocumentDraftId,
                    DocumentSystemIdentifier = model.DocumentSystemIdentifier!.Value,
                    ParentId = model.ParentId,
                    ParentSystemIdentifier = model.ParentSystemIdentifier,
                    PackageDocumentId = model.PackageDocumentId,
                    TypeCode = model.TypeCode!.Value,
                    StatusCode = model.StatusCode!,
                    ContentType = contentType,
                    FileType = fileType!,
                    FileSize = fileSize!.Value,
                    Name = systemFilename!,
                    SourceName = sourceFilename!,
                    UncPath = uncFilePath!,
                    HashCode = hashCode,
                    IsImported = model.IsImported,
                    IsDigitized = model.IsDigitized,
                    HasExternalSource = model.HasExternalSource,
                    ExternalIdentifier = model.ExternalIdentifier,
                };

                if (!fileExists && model.TypeCode != (int)DigitalObjectType.MasterFile)
                {
                    var waterMarkInfo = await _watermarkService.AddWatermark(model.Content!, systemFilename!);

                    if (waterMarkInfo != null)
                    {
                        watermarkFileName = waterMarkInfo.Item1;
                        watermarkUncPath = waterMarkInfo.Item2;
                    }
                }

                digitalObjectDraft.Duration = (duration.HasValue && duration.Value > 0) ? (int)duration : null;
                digitalObjectDraft.WatermarkName = watermarkFileName;
                digitalObjectDraft.WatermarkUncPath = watermarkUncPath;

                if (model.HasExternalSource)
                    digitalObjectDraft.ExternalSourceUpdatedOn = DateTime.UtcNow;

                _context.DigitalObjectDrafts.Add(digitalObjectDraft);
                await _context.SaveAsync("Digital object draft created");

                if (!model.SkipValidation)
                {
                    await _fileUploadAppService.ValidateFile(digitalObjectDraft.UncPath!, digitalObjectDraft.HashCode!, digitalObjectDraft);
                }
                else
                {
                    _logger.LogInformation($"Skip validation for file {digitalObjectDraft.UncPath} ({digitalObjectDraft.SourceName})");
                    await _fileUploadAppService.ValidateFile(digitalObjectDraft.UncPath!, digitalObjectDraft.HashCode!, digitalObjectDraft, true);
                }

                //Try to create derivative PDF file
                //If there is exception the operation should continue
                if (autogenerateDerivative && model.TypeCode == (int)DigitalObjectType.MasterFile)
                {
                    DigitalObjectDraftModel derivativeDigitalObjectDraft = new DigitalObjectDraftModel()
                    {
                        ArchiveId = digitalObjectDraft.ArchiveId,
                        FundDraftId = digitalObjectDraft.FundDraftId,
                        FundSystemIdentifier = digitalObjectDraft.FundSystemIdentifier,
                        InventoryDraftId = digitalObjectDraft.InventoryDraftId,
                        InventorySystemIdentifier = digitalObjectDraft.InventorySystemIdentifier,
                        ArchivalEntityDraftId = digitalObjectDraft.ArchivalEntityDraftId,
                        ArchivalEntitySystemIdentifier = digitalObjectDraft.ArchivalEntitySystemIdentifier,
                        DocumentDraftId = digitalObjectDraft.DocumentDraftId,
                        DocumentSystemIdentifier = digitalObjectDraft.DocumentSystemIdentifier,
                        ParentId = digitalObjectDraft.Id,
                        ParentSystemIdentifier = digitalObjectDraft.SystemIdentifier,
                        IsCurrent = true,
                        ReadOnly = false,
                        IsDigitized = digitalObjectDraft.IsDigitized,
                        IsImported = digitalObjectDraft.IsImported,
                        TypeCode = (int)DigitalObjectType.DerivativeFile,
                        StatusCode = digitalObjectDraft.StatusCode,
                        SourceName = sourceFilename,
                    };

                    await _fileUploadAppService.CreateDerivativeDraftAsync(uncFilePath!, FileStreamLocation.Buffer, FileStreamLocation.Buffer, derivativeDigitalObjectDraft);
                }

                return digitalObjectDraft.SystemIdentifier;
            }
            catch (CustomException ex)
            {
                throw new CustomException(ex.Message.Split('(')[0]);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating digital object draft");
                //var errors = new List<string>() { _localizer.GetString("Error_InvalidFile", fileModel.Name) };
                var errors = new List<string>() { _localizer.GetString("Error_InvalidFile", sourceFilename!) };
                if (!fileExists)
                {
                    var deleteFileResult = _fileService.DeleteFile(uncFilePath!, FileStreamLocation.Buffer);
                    if (!deleteFileResult.Succeeded)
                    {
                        errors.Add(deleteFileResult.ToString());
                    }
                }
                throw new Exception(String.Join(";", errors.ToArray()));
            }
        }

        async Task<Guid?> CreateDerivativeDraftAsyncNotUsed(string sourceUncPath, FileStreamLocation sourceLocation, FileStreamLocation targetLocation, DigitalObjectDraftModel model)
        {
            Guid? pdfSystemIdentifier = null;
            try
            {
                FileModel? sourceFile = await _fileService.GetFileAsync(sourceUncPath, sourceLocation);
                if (sourceFile == null)
                {
                    throw new ItemNotFoundException("File does not exists", sourceUncPath);
                }

                var pdfConversionResult = await _fileService.TryCreateFileAsPdfAsync(sourceFile, targetLocation);
                if (!pdfConversionResult.Succeeded)
                {
                    throw new Exception(pdfConversionResult.ToString());
                }

                var pdfUncPath = pdfConversionResult.Data?.ToString();
                if (string.IsNullOrWhiteSpace(pdfUncPath))
                {
                    throw new Exception("Empty PDF UNC path");
                }

                var pdfFileInfo = await _fileService.GetFileAsync(pdfUncPath, targetLocation, false);
                if (pdfFileInfo == null)
                {
                    throw new ItemNotFoundException("File does not exists", pdfUncPath);
                }

                var pdfSourceName =
                    string.IsNullOrWhiteSpace(model.SourceName)
                    ? pdfFileInfo.Name
                    : $"{Path.GetFileNameWithoutExtension(model.SourceName)}{Path.GetExtension(pdfFileInfo.Name)}";

                DigitalObjectDraft pdfDigitalObjectDraft = new DigitalObjectDraft()
                {
                    SystemIdentifier = Guid.NewGuid(),
                    ArchiveId = model.ArchiveId!.Value,
                    FundDraftId = model.FundDraftId,
                    FundSystemIdentifier = model.FundSystemIdentifier!.Value,
                    InventoryDraftId = model.InventoryDraftId,
                    InventorySystemIdentifier = model.InventorySystemIdentifier!.Value,
                    ArchivalEntityDraftId = model.ArchivalEntityDraftId,
                    ArchivalEntitySystemIdentifier = model.ArchivalEntitySystemIdentifier!.Value,
                    DocumentDraftId = model.DocumentDraftId,
                    DocumentSystemIdentifier = model.DocumentSystemIdentifier!.Value,
                    ParentId = model.ParentId,
                    ParentSystemIdentifier = model.ParentSystemIdentifier,
                    AvailabilityStatusCode = (int)Shared.AvailabilityStatus.Enrollment,
                    IsCurrent = model.IsCurrent,
                    ReadOnly = model.ReadOnly,
                    IsDigitized = model.IsDigitized,
                    IsImported = model.IsImported,
                    TypeCode = model.TypeCode!.Value,
                    StatusCode = model.StatusCode!,
                    ContentType = "application/pdf",
                    FileSize = pdfFileInfo.Size,
                    FileType = pdfFileInfo.Type,
                    Name = pdfFileInfo.SystemName,
                    SourceName = pdfSourceName,
                    UncPath = pdfUncPath,
                };

                _context.DigitalObjectDrafts.Add(pdfDigitalObjectDraft);
                await _context.SaveAsync("Digital object draft created");

                pdfSystemIdentifier = pdfDigitalObjectDraft.SystemIdentifier;
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error creating derivative PDF digital object");
            }

            return pdfSystemIdentifier;
        }

        public async Task<OperationResult> CreateDraftAsync(DigitalObjectDraftModel model, bool autogenerateDerivative = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            if (model.Content == null)
            {
                throw new ArgumentNullException(nameof(model.Content));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var digitalObjectSysId = await ((IDigitalObjectServiceBase)this).CreateDraftInternalAsync(model, false, autogenerateDerivative);

                transaction.Commit();
                return OperationResult.Succeed(digitalObjectSysId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.Message.ToString());
            }

        }

        async Task<Guid> IDigitalObjectServiceBase.CreateDigitalObjectInternalAsync(DigitalObjectModel model, Guid? createdBy, DateTime? createdOn)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            if (!model.HasExternalSource && !model.SystemIdentifier.HasValue)
            {
                throw new SystemIdentifierNullException(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            double? duration = null;
            string? uncMasterFilePath = string.Empty;

            if (model.Content != null)
            {
                FileModel fileModel = await ParseAttachmentAsync(model.Content);

                bool isValidExtension = await _fileUploadAppService.IsFileExtensionValid(fileModel.Name);
                if (!isValidExtension)
                {
                    throw new FileTypeNotSupportedException(_localizer.GetString("Error_UnsupportedFileType", fileModel.Type).ToString());
                }

                if (model.TypeCode == (int)DigitalObjectType.MasterFile)
                {
                    var masterResult = await _fileService.CreateFileAsync(fileModel, FileStreamLocation.Master);
                    if (!masterResult.Succeeded)
                    {
                        throw new Exception(masterResult.ToString());
                    }
                    uncMasterFilePath = masterResult.Data?.ToString();

                    duration = await _fileService.TryGetFileDurationAsync(uncMasterFilePath!, FileStreamLocation.Master);
                }

                var result = await _fileService.CreateFileAsync(fileModel, FileStreamLocation.File);
                if (!result.Succeeded)
                {
                    throw new Exception(result.ToString());
                }
                string? uncFilePath = result.Data?.ToString();

                model.ContentType = fileModel.ContentType;
                model.FileType = fileModel.Type;
                model.FileSize = fileModel.Size;
                model.Name = fileModel.SystemName;
                model.SourceName = fileModel.Name;
                model.UncPath = uncFilePath;
            }

            if (!model.SystemIdentifier.HasValue)
            {
                model.SystemIdentifier = Guid.NewGuid();
            }

            try
            {
                var digitalObject = new DigitalObject()
                {
                    SystemIdentifier = model.SystemIdentifier!.Value,
                    ArchiveId = model.ArchiveId!.Value,
                    FundSystemIdentifier = model.FundSystemIdentifier!.Value,
                    InventorySystemIdentifier = model.InventorySystemIdentifier!.Value,
                    ArchivalEntitySystemIdentifier = model.ArchivalEntitySystemIdentifier!.Value,
                    DocumentSystemIdentifier = model.DocumentSystemIdentifier!.Value,
                    ParentSystemIdentifier = model.ParentSystemIdentifier,
                    TypeCode = model.TypeCode!.Value,
                    StatusCode = model.StatusCode!,
                    ContentType = model.ContentType,
                    Name = model.Name!,
                    HashCode = model.HashCode,
                    SourceName = model.SourceName!,
                    FileType = model.FileType!,
                    FileSize = model.FileSize,
                    UncPath = model.UncPath!,
                    WatermarkName = model.WatermarkName,
                    WatermarkUncPath = model.WatermarkUncPath,
                    HasExternalSource = model.HasExternalSource,
                    ExternalIdentifier = model.ExternalIdentifier,
                    IsImported = model.IsImported,
                    IsDigitized = model.IsDigitized,
                    Duration = (duration.HasValue && duration > 0) ? (int)duration : model.Duration,
                };

                if (model.HasExternalSource)
                    digitalObject.ExternalSourceUpdatedOn = DateTime.UtcNow;

                bool overwriteCreated = createdBy.HasValue && createdOn.HasValue;
                if (overwriteCreated)
                {
                    digitalObject.CreatedBy = createdBy;
                    digitalObject.CreatedOn = createdOn;
                }

                _context.DigitalObjects.Add(digitalObject);
                await _context.SaveAsync("Digital object created", overwriteCreated);

                return digitalObject.SystemIdentifier;
            }
            catch
            {
                if (!string.IsNullOrEmpty(model.UncPath))
                {
                    var deleteFileResult = _fileService.DeleteFile(model.UncPath, FileStreamLocation.File);
                    if (!deleteFileResult.Succeeded)
                    {
                        throw new Exception(deleteFileResult.ToString());
                    }

                    if (!string.IsNullOrEmpty(uncMasterFilePath))
                    {
                        deleteFileResult = _fileService.DeleteFile(uncMasterFilePath, FileStreamLocation.Master);
                        if (!deleteFileResult.Succeeded)
                        {
                            throw new Exception(deleteFileResult.ToString());
                        }
                    }
                }

                throw;
            }
        }

        public async Task<OperationResult> CreateDigitalObjectAsync(DigitalObjectModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            if (!model.HasExternalSource && !model.SystemIdentifier.HasValue)
            {
                return OperationResult.Failed(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            using var tranasaction = _context.Database.BeginTransaction();
            try
            {
                var digitalObjectSysId = await ((IDigitalObjectServiceBase)this).CreateDigitalObjectInternalAsync(model);

                tranasaction.Commit();
                return OperationResult.Succeed(digitalObjectSysId);
            }
            catch (Exception exc)
            {
                tranasaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        async Task<Guid> IDigitalObjectServiceBase.CreateOrUpdateDigitalObjectFromDraftInternalAsync(
            Guid sysId,
            bool updateFileContent,
            bool overwriteCreatedFromDraft,
            bool overwriteModifiedFromDraft)
        {
            var digitalObjectDraft = await GetCurrentDraftAsync(sysId);
            if (digitalObjectDraft == null)
            {
                throw new ItemDraftNotCurrentException(_localizer.GetString("Error_DraftNotCurrent").ToString(), sysId.ToString());
            }

            Guid? createdBy = null;
            Guid? updatedBy = null;
            DateTime? createdOn = null;
            DateTime? updatedOn = null;
            double? duration = null;
            string? uncMasterFilePath = string.Empty;

            if (overwriteCreatedFromDraft)
            {
                createdBy = digitalObjectDraft.CreatedBy;
                createdOn = digitalObjectDraft.CreatedOn;
            }
            if (overwriteModifiedFromDraft)
            {
                updatedBy = digitalObjectDraft.UpdatedBy ?? digitalObjectDraft.CreatedBy;
                updatedOn = digitalObjectDraft.UpdatedOn ?? digitalObjectDraft.CreatedOn;
            }

            var digitalObject =
                await _context.DigitalObjects
                .Where(dig => dig.SystemIdentifier == sysId && !dig.Deleted)
                .Select(dig => new DigitalObjectModel()
                {
                    Id = dig.Id,
                    SystemIdentifier = dig.SystemIdentifier,
                    ArchiveId = dig.ArchiveId,
                    FundSystemIdentifier = dig.FundSystemIdentifier,
                    InventorySystemIdentifier = dig.InventorySystemIdentifier,
                    ArchivalEntitySystemIdentifier = dig.ArchivalEntitySystemIdentifier,
                    DocumentSystemIdentifier = dig.DocumentSystemIdentifier,
                    ParentSystemIdentifier = dig.ParentSystemIdentifier,
                    TypeCode = dig.TypeCode,
                    ContentType = dig.ContentType,
                    FileType = dig.FileType,
                    FileSize = dig.FileSize,
                    Name = dig.Name,
                    SourceName = dig.SourceName,
                    UncPath = dig.UncPath,
                    StatusCode = dig.StatusCode,
                    HasExternalSource = dig.HasExternalSource,
                    ExternalIdentifier = dig.ExternalIdentifier,
                    WatermarkName = dig.WatermarkName,
                    WatermarkUncPath = dig.WatermarkUncPath,
                    HashCode = dig.HashCode,
                    Duration = dig.Duration,
                    IsImported = dig.IsImported,
                    IsDigitized = dig.IsDigitized,
                })
                .SingleOrDefaultAsync();

            if (digitalObject != null)
            {
                string uncFilePath = string.Empty;
                string watermarkPath = string.Empty;

                if (updateFileContent)
                {
                    // copy file directly from path to path
                    var fileData = await _fileService.GetFileAsync(digitalObjectDraft.UncPath!, FileStreamLocation.Buffer, false);

                    if (!String.IsNullOrEmpty(digitalObjectDraft.WatermarkUncPath))
                    {
                        var watermarkFileContent = await _fileService.GetFileAsync(digitalObjectDraft.WatermarkUncPath!, FileStreamLocation.Buffer);

                        if (watermarkFileContent != null)
                        {
                            var updateResult = await _fileService.UpdateFileAsync(watermarkFileContent, FileStreamLocation.File);

                            if (!updateResult.Succeeded)
                            {
                                throw new Exception(updateResult.ToString());
                            }

                            watermarkPath = updateResult.Data!.ToString()!;
                        }
                    }

                    if (fileData != null)
                    {
                        if (digitalObjectDraft.TypeCode == (int)DigitalObjectType.MasterFile)
                        {
                            //var masterUpdateResult = await _fileService.UpdateFileAsync(fileData, FileStreamLocation.Master);
                            //var masterUpdateResult = await _fileService.CopyFileAsync(fileData.SystemName, digitalObjectDraft.UncPath!, fileData.Name, FileStreamLocation.Master);
                            var masterUpdateResult = 
                                await _fileService.CopyFileAsync(
                                    fileData.SystemName, 
                                    digitalObjectDraft.UncPath!, 
                                    fileData.Name, 
                                    FileStreamLocation.Buffer, 
                                    FileStreamLocation.Master);

                            if (!masterUpdateResult.Succeeded)
                            {
                                throw new Exception(masterUpdateResult.ToString());
                            }
                            uncMasterFilePath = masterUpdateResult.Data?.ToString();

                            duration = await _fileService.TryGetFileDurationAsync(uncFilePath!, FileStreamLocation.Master);
                        }
                        //var fileUpdateResult = await _fileService.UpdateFileAsync(fileData, FileStreamLocation.File);
                        //var fileUpdateResult = await _fileService.CopyFileAsync(fileData.SystemName, digitalObjectDraft.UncPath!, fileData.Name, FileStreamLocation.File);
                        var fileUpdateResult = 
                            await _fileService.CopyFileAsync(
                                fileData.SystemName, 
                                digitalObjectDraft.UncPath!, 
                                fileData.Name, 
                                FileStreamLocation.Buffer, 
                                FileStreamLocation.File);

                        if (!fileUpdateResult.Succeeded)
                        {
                            throw new Exception(fileUpdateResult.ToString());
                        }
                        uncFilePath = fileUpdateResult.Data!.ToString()!;
                    }
                }

                digitalObject.SystemIdentifier = digitalObjectDraft.SystemIdentifier;
                digitalObject.ArchiveId = digitalObjectDraft.ArchiveId;
                digitalObject.FundSystemIdentifier = digitalObjectDraft.FundSystemIdentifier;
                digitalObject.InventorySystemIdentifier = digitalObjectDraft.InventorySystemIdentifier;
                digitalObject.ArchivalEntitySystemIdentifier = digitalObjectDraft.ArchivalEntitySystemIdentifier;
                digitalObject.DocumentSystemIdentifier = digitalObjectDraft.DocumentSystemIdentifier;
                digitalObject.ParentSystemIdentifier = digitalObjectDraft.ParentSystemIdentifier;
                digitalObject.TypeCode = digitalObjectDraft.TypeCode;
                digitalObject.ContentType = digitalObjectDraft.ContentType;
                digitalObject.FileType = digitalObjectDraft.FileType;
                digitalObject.FileSize = digitalObjectDraft.FileSize;
                digitalObject.Name = digitalObjectDraft.Name;
                digitalObject.SourceName = digitalObjectDraft.SourceName;
                digitalObject.UncPath = updateFileContent ? uncFilePath : digitalObject.UncPath;
                digitalObject.StatusCode = digitalObjectDraft.StatusCode;
                digitalObject.HasExternalSource = digitalObjectDraft.HasExternalSource;
                digitalObject.ExternalIdentifier = digitalObjectDraft.ExternalIdentifier;
                digitalObject.WatermarkName = digitalObjectDraft.WatermarkName;
                digitalObject.WatermarkUncPath = watermarkPath;
                digitalObject.HashCode = digitalObjectDraft.HashCode;
                digitalObject.Duration = (duration.HasValue && duration.Value > 0) ? (int)duration : digitalObject.Duration;
                digitalObject.IsImported = digitalObjectDraft.IsImported;
                digitalObject.IsDigitized = digitalObjectDraft.IsDigitized;

                await ((IDigitalObjectServiceBase)this).UpdateDigitalObjectInternalAsync(digitalObject, updatedBy, updatedOn);
            }
            else
            {
                string uncFilePath = string.Empty;
                string watermarkPath = string.Empty;

                var fileData = await _fileService.GetFileAsync(digitalObjectDraft.UncPath!, FileStreamLocation.Buffer, false);

                if (fileData != null)
                {
                    // copy file directly from path to path
                    if (digitalObjectDraft.TypeCode == (int)DigitalObjectType.MasterFile)
                    {
                        //var masterCreateResult = await _fileService.CreateFileAsync(fileData, FileStreamLocation.Master);
                        //var masterCreateResult = await _fileService.CopyFileAsync(fileData.SystemName, digitalObjectDraft.UncPath!, fileData.Name, FileStreamLocation.Master);
                        var masterCreateResult = 
                            await _fileService.CopyFileAsync(
                                fileData.SystemName, 
                                digitalObjectDraft.UncPath!, 
                                fileData.Name, 
                                FileStreamLocation.Buffer, 
                                FileStreamLocation.Master);

                        if (!masterCreateResult.Succeeded)
                        {
                            if (masterCreateResult.HResult.HasValue
                                && (masterCreateResult.HResult.Value == 80 || masterCreateResult.HResult.Value == 183))
                            {
                                //TODO Check if the file has related digital object
                            }
                            throw new Exception(masterCreateResult.ToString());
                        }
                        uncMasterFilePath = masterCreateResult.Data?.ToString();

                        duration = await _fileService.TryGetFileDurationAsync(uncMasterFilePath!, FileStreamLocation.Master);
                    }
                    //var fileCreateResult = await _fileService.CreateFileAsync(fileData, FileStreamLocation.File);
                    //var fileCreateResult = await _fileService.CopyFileAsync(fileData.SystemName, digitalObjectDraft.UncPath!, fileData.Name, FileStreamLocation.File);
                    var fileCreateResult = 
                        await _fileService.CopyFileAsync(
                            fileData.SystemName, 
                            digitalObjectDraft.UncPath!, 
                            fileData.Name, 
                            FileStreamLocation.Buffer, 
                            FileStreamLocation.File);

                    if (!fileCreateResult.Succeeded)
                    {
                        throw new Exception(fileCreateResult.ToString());
                    }
                    uncFilePath = fileCreateResult.Data!.ToString()!;
                }


                if (!String.IsNullOrEmpty(digitalObjectDraft.WatermarkUncPath))
                {
                    var watermarkFileContent = await _fileService.GetFileAsync(digitalObjectDraft.WatermarkUncPath!, FileStreamLocation.Buffer);

                    if (watermarkFileContent != null)
                    {
                        var updateResult = await _fileService.CreateFileAsync(watermarkFileContent, FileStreamLocation.File);

                        if (!updateResult.Succeeded)
                        {
                            throw new Exception(updateResult.ToString());
                        }

                        watermarkPath = updateResult.Data!.ToString()!;
                    }
                }

                digitalObject = new DigitalObjectModel()
                {
                    SystemIdentifier = digitalObjectDraft.SystemIdentifier,
                    ArchiveId = digitalObjectDraft.ArchiveId,
                    FundSystemIdentifier = digitalObjectDraft.FundSystemIdentifier,
                    InventorySystemIdentifier = digitalObjectDraft.InventorySystemIdentifier,
                    ArchivalEntitySystemIdentifier = digitalObjectDraft.ArchivalEntitySystemIdentifier,
                    DocumentSystemIdentifier = digitalObjectDraft.DocumentSystemIdentifier,
                    ParentSystemIdentifier = digitalObjectDraft.ParentSystemIdentifier,
                    TypeCode = digitalObjectDraft.TypeCode,
                    ContentType = digitalObjectDraft.ContentType,
                    FileType = digitalObjectDraft.FileType,
                    FileSize = digitalObjectDraft.FileSize,
                    Name = digitalObjectDraft.Name,
                    SourceName = digitalObjectDraft.SourceName,
                    UncPath = uncFilePath,
                    StatusCode = digitalObjectDraft.StatusCode,
                    HasExternalSource = digitalObjectDraft.HasExternalSource,
                    ExternalIdentifier = digitalObjectDraft.ExternalIdentifier,
                    WatermarkName = digitalObjectDraft.WatermarkName,
                    WatermarkUncPath = watermarkPath,
                    HashCode = digitalObjectDraft.HashCode,
                    Duration = (duration.HasValue && duration.Value > 0) ? (int)duration : null,
                    PackageDocumentId = digitalObjectDraft.PackageDocumentId,
                    IsImported = digitalObjectDraft.IsImported,
                    IsDigitized = digitalObjectDraft.IsDigitized,
                };

                await ((IDigitalObjectServiceBase)this).CreateDigitalObjectInternalAsync(digitalObject, createdBy, createdOn);
            }

            var modifiedDigitalObjectDraft = new DigitalObjectDraftModel();
            modifiedDigitalObjectDraft.Assign(digitalObjectDraft);
            modifiedDigitalObjectDraft.IsCurrent = false;
            modifiedDigitalObjectDraft.ReadOnly = true;

            await ((IDigitalObjectServiceBase)this).UpdateDraftInternalAsync(modifiedDigitalObjectDraft, false);

            return sysId;
        }

        public async Task<OperationResult> CreateOrUpdateDigitalObjectFromDraftAsync(Guid sysId, bool updateFileContent = false)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await ((IDigitalObjectServiceBase)this).CreateOrUpdateDigitalObjectFromDraftInternalAsync(sysId, updateFileContent);

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

        async Task<Guid> IDigitalObjectServiceBase.UpdateDraftInternalAsync(DigitalObjectDraftModel model, bool updateFile)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            if (!model.SystemIdentifier.HasValue)
            {
                throw new SystemIdentifierNullException(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }

            var currentdigitalObjectDraft = await GetCurrentDraftAsync(model.SystemIdentifier.Value);
            if (currentdigitalObjectDraft == null)
            {
                return await ((IDigitalObjectServiceBase)this).CreateDraftInternalAsync(model);
            }

            bool isReadOnly = await IsReadOnlyDraftAsync(new DigitalObjectDraftModel() { Id = currentdigitalObjectDraft.Id });
            if (isReadOnly)
            {
                return await ((IDigitalObjectServiceBase)this).CreateDraftInternalAsync(model);
            }

            var digitalObjectDraft = await _context.DigitalObjectDrafts.FindAsync(currentdigitalObjectDraft.Id);
            if (digitalObjectDraft == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), model.Id!.Value.ToString());
            }

            string uncFilePath = String.Empty;
            double? duration = null;
            try
            {
                if (updateFile)
                {
                    if (model.Content != null)
                    {
                        FileModel fileModel = await ParseAttachmentAsync(model.Content);

                        bool isValidExtension = await _fileUploadAppService.IsFileExtensionValid(fileModel.Name);
                        if (!isValidExtension)
                        {
                            throw new FileTypeNotSupportedException(_localizer.GetString("Error_UnsupportedFileType", fileModel.Type).ToString());
                        }

                        var result = await _fileService.UpdateFileAsync(fileModel, FileStreamLocation.Buffer);
                        if (!result.Succeeded)
                        {
                            throw new Exception(result.ToString());
                        }
                        uncFilePath = result.Data?.ToString()!;

                        //try
                        //{
                        //    var file = Create(uncFilePath);

                        //    duration = file.Properties.Duration.TotalSeconds;
                        //}
                        //catch (TagLib.UnsupportedFormatException exc)
                        //{
                        //    _logger.LogWarning(exc, $"Cannot get duration for file format {fileModel.Type}");
                        //}
                        ////TODO Throw the exception up?
                        //catch (TagLib.CorruptFileException exc)
                        //{
                        //    _logger.LogError(exc, $"Corrupt file {fileModel.Name} ({fileModel.SystemName})");
                        //}
                        duration = await _fileService.TryGetFileDurationAsync(uncFilePath!, FileStreamLocation.Buffer);

                        digitalObjectDraft.Duration = (duration.HasValue && duration.Value > 0) ? (int)duration : null;
                        digitalObjectDraft.FileType = fileModel.Type;
                        digitalObjectDraft.FileSize = fileModel.Size;
                        digitalObjectDraft.ContentType = fileModel.ContentType;
                        digitalObjectDraft.Name = fileModel.SystemName;
                        digitalObjectDraft.SourceName = fileModel.Name;
                        digitalObjectDraft.UncPath = uncFilePath!;
                        digitalObjectDraft.HashCode = FileUtils.ChecksumUtil.Calculate(fileModel.Content!);
                    }
                }

                digitalObjectDraft.IsCurrent = model.IsCurrent;
                digitalObjectDraft.ReadOnly = model.ReadOnly;
                digitalObjectDraft.SystemIdentifier = model.SystemIdentifier!.Value;
                digitalObjectDraft.ArchiveId = model.ArchiveId!.Value;
                digitalObjectDraft.FundDraftId = model.FundDraftId;
                digitalObjectDraft.FundSystemIdentifier = model.FundSystemIdentifier!.Value;
                digitalObjectDraft.InventoryDraftId = model.InventoryDraftId;
                digitalObjectDraft.InventorySystemIdentifier = model.InventorySystemIdentifier!.Value;
                digitalObjectDraft.ArchivalEntityDraftId = model.ArchivalEntityDraftId;
                digitalObjectDraft.ArchivalEntitySystemIdentifier = model.ArchivalEntitySystemIdentifier!.Value;
                digitalObjectDraft.DocumentDraftId = model.DocumentDraftId;
                digitalObjectDraft.DocumentSystemIdentifier = model.DocumentSystemIdentifier!.Value;
                digitalObjectDraft.ParentId = model.ParentId;
                digitalObjectDraft.ParentSystemIdentifier = model.ParentSystemIdentifier;
                digitalObjectDraft.TypeCode = model.TypeCode!.Value;
                digitalObjectDraft.StatusCode = model.StatusCode!;
                digitalObjectDraft.HasExternalSource = model.HasExternalSource;
                digitalObjectDraft.ExternalIdentifier = model.ExternalIdentifier;
                digitalObjectDraft.IsDigitized = model.IsDigitized;
                digitalObjectDraft.IsImported = model.IsImported;
                digitalObjectDraft.PackageDocumentId = model.PackageDocumentId;

                if (model.HasExternalSource)
                {
                    digitalObjectDraft.ExternalSourceUpdatedOn = DateTime.UtcNow;
                }

                _context.DigitalObjectDrafts.Update(digitalObjectDraft);

                await _context.SaveAsync("Digital object draft updated");

                if (updateFile)
                {
                    if (!model.SkipValidation)
                    {
                        await _fileUploadAppService.ValidateFile(digitalObjectDraft.UncPath!, digitalObjectDraft.HashCode!, digitalObjectDraft);
                    }
                    else
                    {
                        _logger.LogInformation($"Skip validation for file {digitalObjectDraft.UncPath} ({digitalObjectDraft.SourceName})");
                        await _fileUploadAppService.ValidateFile(digitalObjectDraft.UncPath!, digitalObjectDraft.HashCode!, digitalObjectDraft, true);
                    }
                }

                return digitalObjectDraft.SystemIdentifier;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error updating digital object draft (id: {model.Id}, sysId: {model.SystemIdentifier})");

                var errors = new List<string>() { _localizer.GetString("Error_InvalidFile", digitalObjectDraft.SourceName) };

                if (updateFile)
                {
                    var deleteFileResult = _fileService.DeleteFile(uncFilePath!, FileStreamLocation.Buffer);
                    if (!deleteFileResult.Succeeded)
                    {
                        errors.Add(deleteFileResult.ToString());
                    }
                }
                throw new Exception(String.Join("; ", errors.ToArray()));
            }
        }

        public async Task<OperationResult> UpdateDraftAsync(DigitalObjectDraftModel model)
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
                var digitalObjectSysId = await ((IDigitalObjectServiceBase)this).UpdateDraftInternalAsync(model, true);

                transaction.Commit();
                return OperationResult.Succeed(digitalObjectSysId);
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

        async Task<Guid> IDigitalObjectServiceBase.UpdateDigitalObjectInternalAsync(DigitalObjectModel model, Guid? updatedBy, DateTime? updatedOn)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            if (!model.SystemIdentifier.HasValue)
            {
                throw new SystemIdentifierNullException(_localizer.GetString("Error_SystemIdentifierNullOrEmpty").ToString());
            }
            double? duration = null;
            string? uncMasterFilePath = string.Empty;

            if (model.Content != null)
            {
                FileModel fileModel = await ParseAttachmentAsync(model.Content);

                bool isValidExtension = await _fileUploadAppService.IsFileExtensionValid(fileModel.Name);
                if (!isValidExtension)
                {
                    throw new FileTypeNotSupportedException(_localizer.GetString("Error_UnsupportedFileType", fileModel.Type).ToString());
                }

                if (model.TypeCode == (int)DigitalObjectType.MasterFile)
                {
                    var masterResult = await _fileService.UpdateFileAsync(fileModel, FileStreamLocation.Master);
                    if (!masterResult.Succeeded)
                    {
                        throw new Exception(masterResult.ToString());
                    }
                    uncMasterFilePath = masterResult.Data?.ToString();

                    //try
                    //{
                    //    var file = Create(uncMasterFilePath);

                    //    duration = file.Properties.Duration.TotalSeconds;
                    //}
                    //catch (TagLib.UnsupportedFormatException exc)
                    //{
                    //    _logger.LogWarning(exc, $"Cannot get duration for file format {fileModel.Type}");
                    //}
                    ////TODO Throw the exception up?
                    //catch (TagLib.CorruptFileException exc)
                    //{
                    //    _logger.LogError(exc, $"Corrupt file {fileModel.Name} ({fileModel.SystemName})");
                    //}
                    duration = await _fileService.TryGetFileDurationAsync(uncMasterFilePath!, FileStreamLocation.Master);
                }

                var result = await _fileService.UpdateFileAsync(fileModel, FileStreamLocation.File);
                if (!result.Succeeded)
                {
                    throw new Exception(result.ToString());
                }
                string? uncFilePath = result.Data?.ToString();

                model.ContentType = fileModel.ContentType;
                model.FileType = fileModel.Type;
                model.FileSize = fileModel.Size;
                model.Name = fileModel.SystemName;
                model.SourceName = fileModel.Name;
                model.UncPath = uncFilePath;
            }

            var digitalObject = await _context.DigitalObjects.FindAsync(model.Id);
            if (digitalObject == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), model.Id!.Value.ToString());
            }

            digitalObject.ArchiveId = model.ArchiveId!.Value;
            digitalObject.FundSystemIdentifier = model.FundSystemIdentifier!.Value;
            digitalObject.InventorySystemIdentifier = model.InventorySystemIdentifier!.Value;
            digitalObject.ArchivalEntitySystemIdentifier = model.ArchivalEntitySystemIdentifier!.Value;
            digitalObject.DocumentSystemIdentifier = model.DocumentSystemIdentifier!.Value;
            digitalObject.ParentSystemIdentifier = model.ParentSystemIdentifier;
            digitalObject.TypeCode = model.TypeCode!.Value;
            digitalObject.ContentType = model.ContentType;
            digitalObject.FileType = model.FileType!;
            digitalObject.FileSize = model.FileSize;
            digitalObject.Name = model.Name!;
            digitalObject.SourceName = model.SourceName!;
            digitalObject.UncPath = model.UncPath!;
            digitalObject.StatusCode = model.StatusCode!;
            digitalObject.HasExternalSource = model.HasExternalSource;
            digitalObject.ExternalIdentifier = model.ExternalIdentifier;
            digitalObject.Duration = (duration.HasValue && duration.Value > 0) ? (int)duration : model.Duration;
            digitalObject.IsImported = model.IsImported;
            digitalObject.IsDigitized = model.IsDigitized;

            if (model.HasExternalSource)
            {
                digitalObject.ExternalSourceUpdatedOn = DateTime.UtcNow;
            }

            bool overwriteModified = updatedBy.HasValue && updatedOn.HasValue;
            if (overwriteModified)
            {
                digitalObject.UpdatedBy = updatedBy;
                digitalObject.UpdatedOn = updatedOn;
            }

            _context.Update(digitalObject);

            await _context.SaveAsync("Digital object updated", overwriteModified, overwriteModified);

            return digitalObject.SystemIdentifier;
        }

        public async Task<OperationResult> UpdateDigitalObjectAsync(DigitalObjectModel model)
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
                var digitalObjectSysId = await ((IDigitalObjectServiceBase)this).UpdateDigitalObjectInternalAsync(model);

                transaction.Commit();
                return OperationResult.Succeed(digitalObjectSysId);
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

        async System.Threading.Tasks.Task IDigitalObjectServiceBase.DeleteDraftInternalAsync(int id, bool includeRelated, bool includeFiles)
        {
            var digitalObjectDraft = await _context.DigitalObjectDrafts.FindAsync(id);
            if (digitalObjectDraft == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), id.ToString());
            }
            if (!digitalObjectDraft.IsCurrent)
            {
                throw new ItemDraftNotCurrentException(_localizer.GetString("Error_DraftNotCurrent").ToString(), digitalObjectDraft.Id.ToString());
            }

            // Delete digital object file
            if (includeFiles)
            {
                OperationResult result = _fileService.DeleteFile(digitalObjectDraft.UncPath, FileStreamLocation.Buffer);
                if (!result.Succeeded)
                {
                    throw new Exception(result.ToString());
                }
            }

            digitalObjectDraft.IsCurrent = false;
            digitalObjectDraft.ReadOnly = true;
            digitalObjectDraft.Deleted = true;
            digitalObjectDraft.DeletedOn = DateTime.UtcNow;
            digitalObjectDraft.DeletedBy = _userInfo.CurrentUserId;

            _context.Update(digitalObjectDraft);

            if (includeRelated)
            {
                var relatedDrafts = _context.DigitalObjectDrafts
                                        .Where(d =>
                                            d.ParentSystemIdentifier == digitalObjectDraft.SystemIdentifier
                                            && d.IsCurrent
                                            && !d.Deleted)
                                        .Select(d => d);
                if (includeFiles)
                {
                    foreach (var relatedDraft in relatedDrafts)
                    {
                        // Delete watermark file 
                        if (!String.IsNullOrWhiteSpace(relatedDraft.WatermarkUncPath))
                        {
                            OperationResult deleteWatermarkedResult = _fileService.DeleteFile(relatedDraft.WatermarkUncPath, FileStreamLocation.Buffer);
                            if (!deleteWatermarkedResult.Succeeded)
                            {
                                throw new Exception(deleteWatermarkedResult.ToString());
                            }
                        }

                        // Delete file
                        OperationResult deleteResult = _fileService.DeleteFile(relatedDraft.UncPath, FileStreamLocation.Buffer);
                        if (!deleteResult.Succeeded)
                        {
                            throw new Exception(deleteResult.ToString());
                        }
                    }
                }

                await relatedDrafts.ForEachAsync(d =>
                {
                    d.IsCurrent = false;
                    d.ReadOnly = true;
                    d.Deleted = true;
                    d.DeletedOn = DateTime.UtcNow;
                    d.DeletedBy = _userInfo.CurrentUserId;
                });
            }

            await _context.SaveAsync("Digital object draft deleted");
        }

        public async Task<OperationResult> DeleteDraftAsync(int id, bool includeRelated, bool includeFiles)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await ((IDigitalObjectServiceBase)this).DeleteDraftInternalAsync(id, includeRelated, includeFiles);

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

        async System.Threading.Tasks.Task IDigitalObjectServiceBase.DeleteDigitalObjectInternalAsync(Guid sysId, bool includeRelated, bool includeFiles)
        {

            //var digitalObjectDraftChilds = _context.DigitalObjectDrafts
            //        .Where(d => d.ParentSystemIdentifier == sysId && !d.Deleted)
            //        .Select(d => d);

            //if (digitalObjectDraftChilds.Any())
            //{
            //    foreach (var draft in digitalObjectDraftChilds)
            //    {
            //        // Delete file 
            //        OperationResult result = _fileService.DeleteFile(draft.UncPath, FileStreamLocation.Buffer);
            //        if (!result.Succeeded)
            //        {
            //            throw new Exception(String.Join("; ", result.Errors));
            //        }
            //        // Delete watermark file 
            //        if (!String.IsNullOrEmpty(draft.WatermarkUncPath))
            //        {
            //            OperationResult resultWaterMark = _fileService.DeleteFile(draft.WatermarkUncPath, FileStreamLocation.Buffer);
            //            if (!resultWaterMark.Succeeded)
            //            {
            //                throw new Exception(String.Join("; ", result.Errors));
            //            }
            //        }
            //    }

            //    await digitalObjectDraftChilds.ForEachAsync(d =>
            //    {
            //        d.IsCurrent = false;
            //        d.ReadOnly = true;
            //        d.Deleted = true;
            //        d.DeletedBy = _userInfo.CurrentUserId;
            //        d.DeletedOn = DateTime.UtcNow;
            //    });
            //}

            var digitalObjectDrafts =
                   _context.DigitalObjectDrafts
                   .Where(d => (d.SystemIdentifier == sysId || (includeRelated && d.ParentSystemIdentifier == sysId)) && !d.Deleted)
                   .Select(d => d);

            if (includeFiles)
            {
                foreach (var digitalObjectDraft in digitalObjectDrafts)
                {
                    // Delete watermark file 
                    if (!String.IsNullOrWhiteSpace(digitalObjectDraft.WatermarkUncPath))
                    {
                        OperationResult deleteWatermarkedResult = _fileService.DeleteFile(digitalObjectDraft.WatermarkUncPath, FileStreamLocation.Buffer);
                        if (!deleteWatermarkedResult.Succeeded)
                        {
                            throw new Exception(deleteWatermarkedResult.ToString());
                        }
                    }

                    // Delete file
                    OperationResult deleteResult = _fileService.DeleteFile(digitalObjectDraft.UncPath, FileStreamLocation.Buffer);
                    if (!deleteResult.Succeeded)
                    {
                        throw new Exception(deleteResult.ToString());
                    }
                }
            }

            await digitalObjectDrafts.ForEachAsync(d =>
            {
                d.IsCurrent = false;
                d.ReadOnly = true;
                d.Deleted = true;
                d.DeletedBy = _userInfo.CurrentUserId;
                d.DeletedOn = DateTime.UtcNow;
            });

            //var digitalObject =
            //    await _context.DigitalObjects
            //    .Where(d => d.SystemIdentifier == sysId && !d.Deleted)
            //    .SingleOrDefaultAsync();

            //if (digitalObject != null)
            //{
            //    digitalObject.Deleted = true;
            //    digitalObject.DeletedOn = DateTime.UtcNow;
            //    digitalObject.DeletedBy = _userInfo.CurrentUserId;

            //    _context.Update(digitalObject);
            //}
            var digitalObjects = _context.DigitalObjects
                                    .Where(d => (d.SystemIdentifier == sysId || (includeRelated && d.ParentSystemIdentifier == sysId)) && !d.Deleted)
                                    .Select(d => d);

            if (includeFiles)
            {
                foreach (var digitalObject in digitalObjects)
                {
                    // Delete watermark file 
                    if (!String.IsNullOrWhiteSpace(digitalObject.WatermarkUncPath))
                    {
                        OperationResult deleteWatermarkedResult = _fileService.DeleteFile(digitalObject.WatermarkUncPath, FileStreamLocation.File);
                        if (!deleteWatermarkedResult.Succeeded)
                        {
                            throw new Exception(deleteWatermarkedResult.ToString());
                        }
                    }

                    // Delete file
                    OperationResult deleteResult = _fileService.DeleteFile(digitalObject.UncPath, FileStreamLocation.File);
                    if (!deleteResult.Succeeded)
                    {
                        throw new Exception(deleteResult.ToString());
                    }
                }
            }

            await digitalObjects.ForEachAsync(d =>
            {
                d.Deleted = true;
                d.DeletedOn = DateTime.UtcNow;
                d.DeletedBy = _userInfo.CurrentUserId;
            });

            await _context.SaveAsync("Digital object deleted");
        }

        public async Task<OperationResult> DeleteDigitalObjectAsync(Guid sysId, bool includeRelated, bool includeFiles)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                await ((IDigitalObjectServiceBase)this).DeleteDigitalObjectInternalAsync(sysId, includeRelated, includeFiles);

                transaction.Commit();
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<DigitalObjectDisplayModel?> GetFromExternalSourceAsync(
            int externalIdentifier,
            Guid? systemIdentifier = null,
            Guid? documentSystemIdentifier = null,
            Guid? archivalEntitySystemIdentifier = null,
            Guid? inventorySystemIdentifier = null,
            Guid? fundSystemIdentifier = null)
        {
            string query = "exec sp_GetDigitalObject @LinkedServer, @Identifier";
            List<SqlParameter> queryParams = new()
            {
                new SqlParameter("LinkedServer", _settings.LinkedServer),
                new SqlParameter("Identifier", externalIdentifier),
            };
            var result = (await _context.RemoteDigitalObjects
                        .FromSqlRaw(query, queryParams.ToArray())
                        .AsNoTracking()
                        .ToListAsync())
                    .SingleOrDefault();

            if (result == null)
            {
                return null;
            }

            var archiveId = await _archiveService.GetArchiveIdByCodeAsync(result.ArchiveCode!.Value);
            if (!documentSystemIdentifier.HasValue)
            {
                documentSystemIdentifier = await _documentService.GetSystemIdentifierByExternalIdentifierAsync(result.DocumentExternalIdentifier!.Value);
            }
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

            return new DigitalObjectDisplayModel()
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
                DocumentSystemIdentifier = documentSystemIdentifier,
                DocumentHasExternalSource = result.DocumentHasExternalSource ?? false,
                DocumentExternalIdentifier = result.DocumentExternalIdentifier,
                DocumentNumber = result.DocumentNumber,
                FileType = result.FileType,
                Name = result.Name,
                SourceName = result.Name,
                IsDigitized = result.IsDigitized ?? false,
            };
        }


        private async Task<OperationResult?> CreateDigitalObjectReviewAsync(Guid digitalObjectSystemIdentifier)
        {
            try
            {
                var SystemIdentifiers = _context.VDigitalObjects
                                                   .Where(dobj => dobj.SystemIdentifier == digitalObjectSystemIdentifier && !dobj.Deleted)
                                                   .Select(dobj => new
                                                   {
                                                       dobj.DocumentSystemIdentifier,
                                                       dobj.ArchivalEntitySystemIdentifier
                                                   })
                                                   .SingleOrDefault();

                if (SystemIdentifiers.DocumentSystemIdentifier == null)
                {
                    return OperationResult.Failed(nameof(SystemIdentifiers.DocumentSystemIdentifier));
                }

                if (SystemIdentifiers.ArchivalEntitySystemIdentifier == null)
                {
                    return OperationResult.Failed(nameof(SystemIdentifiers.ArchivalEntitySystemIdentifier));
                }

                DigitalObjectReview digitalObjectReview = new()
                {
                    SystemIdentifier = Guid.NewGuid(),
                    DigitalObjectSystemIdentifier = digitalObjectSystemIdentifier,
                    DocumentSystemIdentifier = SystemIdentifiers.DocumentSystemIdentifier,
                    ArchivalEntitySystemIdentifier = SystemIdentifiers.ArchivalEntitySystemIdentifier,
                    UserSystemIdentifier = _userInfo.CurrentUserId!.Value,
                    Date = DateTime.UtcNow
                };

                await _context.DigitalObjectReviews.AddAsync(digitalObjectReview);
                await _context.SaveAsync("Digital object review created");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }
        public ReportGridResponseModel<DigitalObjectReviewDisplayModel> GetDigitalObjectReviewsAsync(ReportGridRequestModel<DigitalObjectReviewSearchModel> model)
        {
            var query = _context.DigitalObjectReviews
                                .Where(o => o.ArchivalEntitySystemIdentifier.ToString() == model.Filters.ArchivalEntitySystemIdentifier && (o.Date >= model.Filters.StartDate && o.Date <= model.Filters.EndDate))
                                .Select(o => new DigitalObjectReviewDisplayModel()
                                {
                                    SystemIdentifier = o.SystemIdentifier,
                                    DigitalObjectName = _context.DigitalObjects
                                                                .Where(d => d.SystemIdentifier == o.DigitalObjectSystemIdentifier)
                                                                .Select(d => d.Name)
                                                                .SingleOrDefault(),
                                    ArchivalEntityNumber = _context.ArchivalEntities
                                                                   .Where(a => a.SystemIdentifier == o.ArchivalEntitySystemIdentifier)
                                                                   .Select(a => a.Number)
                                                                   .SingleOrDefault(),
                                    DocumentNumber = _context.Documents
                                                             .Where(d => d.SystemIdentifier == o.DocumentSystemIdentifier)
                                                             .Select(d => d.Number)
                                                             .SingleOrDefault(),
                                    UserDisplayName = _context.AspNetUserProfiles
                                                              .Where(up => up.UserId == o.UserSystemIdentifier)
                                                              .Select(up => up.DisplayName)
                                                              .SingleOrDefault(),
                                    UserType = _context.AspNetUsers
                                                       .Where(u => u.Id == o.UserSystemIdentifier)
                                                       .Select(u => u.UserType)
                                                       .SingleOrDefault(),
                                    UserSystemIdentifier = o.UserSystemIdentifier,
                                    Date = o.Date.UtcToLocalTime()
                                });
            DataSourceRequestModel dataSourceRequestModel = new DataSourceRequestModel()
            {
                Page = model.Page,
                ItemsPerPage = model.ItemsPerPage,
                SearchString = model.Filters.SearchString,
                SortBy = model.Filters.SortBy,
                SortDesc = model.Filters.SortDesc,
                SortByType = model.Filters.SortByType
            };
            QueryResponseModel<DigitalObjectReviewDisplayModel> queryResponse = query.SortAndFilter(dataSourceRequestModel);
            ReportGridResponseModel<DigitalObjectReviewDisplayModel> result = new ReportGridResponseModel<DigitalObjectReviewDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Items = queryResponse.Query.Select(x => x)
            };

            return result;
        }
        async Task<Guid> IDigitalObjectServiceBase.CreateDraftFromPackageDocumentInternalAsync(PackageDocument doc, DigitalObjectDraftModel model, bool autogenerateDerivative)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            if (doc == null)
            {
                throw new ArgumentNullException(nameof(doc));
            }

            if (!model.DocumentDraftId.HasValue)
            {
                var documentDraft = await _documentService.GetCurrentDraftAsync(model.DocumentSystemIdentifier!.Value);
                if (documentDraft != null)
                {
                    model.FundDraftId = documentDraft.FundDraftId;
                    model.InventoryDraftId = documentDraft.InventoryDraftId;
                    model.ArchivalEntityDraftId = documentDraft.ArchivalEntityDraftId;
                    model.DocumentDraftId = documentDraft.Id;
                }
            }
            double? duration = null;

            FileStreamLocation location = doc.FileLocation != null ? (FileStreamLocation)doc.FileLocation : FileStreamLocation.Buffer;
            FileModel? fileModel = await _fileService.GetFileAsync(doc.FilePath!, location);
            if (fileModel == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), doc.Id.ToString());
            }

            fileModel.SystemName = $"{Guid.NewGuid()}.{fileModel.Type}";

            var result = await _fileService.CreateFileAsync(fileModel, FileStreamLocation.Buffer);
            if (!result.Succeeded)
            {
                throw new Exception(result.ToString());
            }

            string? uncFilePath = result.Data?.ToString();
            model.SystemIdentifier = Guid.NewGuid();

            if (model.TypeCode == (int)DigitalObjectType.MasterFile)
            {
                //try
                //{
                //    var file = Create(uncFilePath);

                //    duration = file.Properties.Duration.TotalSeconds;
                //}
                //catch (TagLib.UnsupportedFormatException exc)
                //{
                //    _logger.LogWarning(exc, $"Cannot get duration for file format {fileModel.Type}");
                //}
                ////TODO Throw the exception up?
                //catch (TagLib.CorruptFileException exc)
                //{
                //    _logger.LogError(exc, $"Corrupt file {fileModel.Name} ({fileModel.SystemName})");
                //}
                duration = await _fileService.TryGetFileDurationAsync(uncFilePath!, FileStreamLocation.Buffer);
            }

            var digitalObjectDraft = new DigitalObjectDraft()
            {
                IsCurrent = true,
                ReadOnly = false,
                SystemIdentifier = model.SystemIdentifier!.Value,
                ArchiveId = model.ArchiveId!.Value,
                FundDraftId = model.FundDraftId,
                FundSystemIdentifier = model.FundSystemIdentifier!.Value,
                InventoryDraftId = model.InventoryDraftId,
                InventorySystemIdentifier = model.InventorySystemIdentifier!.Value,
                ArchivalEntityDraftId = model.ArchivalEntityDraftId,
                ArchivalEntitySystemIdentifier = model.ArchivalEntitySystemIdentifier!.Value,
                DocumentDraftId = model.DocumentDraftId,
                DocumentSystemIdentifier = model.DocumentSystemIdentifier!.Value,
                TypeCode = model.TypeCode!.Value,
                StatusCode = model.StatusCode!,
                Duration = (duration.HasValue && duration.Value > 0) ? (int)duration : null,
                ContentType = model.ContentType,
                FileType = fileModel.Type,
                FileSize = fileModel.Size,
                Name = fileModel.SystemName,
                SourceName = model.SourceName!,
                UncPath = uncFilePath!,
                HashCode = FileUtils.ChecksumUtil.Calculate(fileModel.Content!),
                PackageDocumentId = model.PackageDocumentId,
                IsImported = model.IsImported,
                IsDigitized = model.IsDigitized,

                WorkflowId = model.WorkflowId,
                WorkflowTypeCode = model.WorkflowTypeCode,
                WorkflowStepId = model.WorkflowStepId,
                WorkflowStepTypeCode = model.WorkflowStepTypeCode,
            };

            _context.DigitalObjectDrafts.Add(digitalObjectDraft);
            await _context.SaveAsync("Digital object draft created");

            //Try to create derivative PDF file
            //If there is exception the operation should continue
            if (autogenerateDerivative && model.TypeCode == (int)DigitalObjectType.MasterFile)
            {
                try
                {
                    var pdfConversionResult = await _fileService.TryCreateFileAsPdfAsync(fileModel, location);
                    if (!pdfConversionResult.Succeeded)
                    {
                        throw new Exception(pdfConversionResult.ToString());
                    }

                    var pdfUncPath = pdfConversionResult.Data?.ToString();
                    if (string.IsNullOrWhiteSpace(pdfUncPath))
                    {
                        throw new Exception("Empty PDF UNC path");
                    }

                    var pdfFileInfo = await _fileService.GetFileAsync(pdfUncPath, location, false);
                    if (pdfFileInfo == null)
                    {
                        throw new ItemNotFoundException("File does not exists", pdfUncPath);
                    }

                    var pdfSourceName = 
                        string.IsNullOrWhiteSpace(model.SourceName) 
                        ? pdfFileInfo.Name 
                        : $"{Path.GetFileNameWithoutExtension(model.SourceName)}{Path.GetExtension(pdfFileInfo.Name)}";

                    DigitalObjectDraft pdfDigitalObjectDraft = new DigitalObjectDraft()
                    {
                        IsCurrent = true,
                        ReadOnly = false,
                        SystemIdentifier = Guid.NewGuid(),
                        ArchiveId = digitalObjectDraft.ArchiveId,
                        FundDraftId = digitalObjectDraft.FundDraftId,
                        FundSystemIdentifier = digitalObjectDraft.FundSystemIdentifier,
                        InventoryDraftId = digitalObjectDraft.InventoryDraftId,
                        InventorySystemIdentifier = digitalObjectDraft.InventorySystemIdentifier,
                        ArchivalEntityDraftId = digitalObjectDraft.ArchivalEntityDraftId,
                        ArchivalEntitySystemIdentifier = digitalObjectDraft.ArchivalEntitySystemIdentifier,
                        DocumentDraftId = digitalObjectDraft.DocumentDraftId,
                        DocumentSystemIdentifier = digitalObjectDraft.DocumentSystemIdentifier,
                        ParentId = digitalObjectDraft.Id,
                        ParentSystemIdentifier = digitalObjectDraft.SystemIdentifier,
                        AvailabilityStatusCode = (int)Shared.AvailabilityStatus.Enrollment,
                        TypeCode = (int)DigitalObjectType.DerivativeFile,
                        StatusCode = digitalObjectDraft.StatusCode,
                        ContentType = "application/pdf",
                        FileType = pdfFileInfo.Type,
                        FileSize = pdfFileInfo.Size,
                        Name = pdfFileInfo.SystemName,
                        SourceName = pdfSourceName,
                        UncPath = pdfUncPath,
                        IsImported = digitalObjectDraft.IsImported,
                        IsDigitized = digitalObjectDraft.IsDigitized,

                        WorkflowId = digitalObjectDraft.WorkflowId,
                        WorkflowTypeCode = digitalObjectDraft.WorkflowTypeCode,
                        WorkflowStepId = digitalObjectDraft.WorkflowStepId,
                        WorkflowStepTypeCode = digitalObjectDraft.WorkflowStepTypeCode,
                    };

                    _context.DigitalObjectDrafts.Add(pdfDigitalObjectDraft);
                    await _context.SaveAsync("Digital object draft created");
                }
                catch (Exception exc)
                {
                    _logger.LogError(exc, "Error creating derivative PDF digital object");
                }
            }

            return digitalObjectDraft.SystemIdentifier;
        }

        public async Task<byte[]> ConvertTiffToImage(byte[] content)
        {
            byte[] bytes;

            using Stream contentStream = new MemoryStream(content);
            contentStream.Position = 0;

            Bitmap bm = (Bitmap)Bitmap.FromStream(contentStream);
            bm.Save("photo.jpg", ImageFormat.Jpeg);

            bytes = ImageToByteArray(bm);

            return bytes;
        }

        public async Task<DigitalObjectPublicDisplayModel?> GetDigitalObjectDraftBySystemIdentifierAsync(Guid sysId)
        {
            var digitalObject =
                await _context.DigitalObjectDrafts
                .Where(d => d.SystemIdentifier == sysId && !d.Deleted)
                .Select(entity => new DigitalObjectPublicDisplayModel()
                {
                    SystemIdentifier = entity.SystemIdentifier,
                    ExternalIdentifier = entity.ExternalIdentifier,
                    ArchiveName = entity.Archive.Name,
                    DocumentSystemIdentifier = entity.DocumentSystemIdentifier,
                    TypeCode = entity.TypeCode,
                    ContentType = entity.ContentType,
                    FileType = entity.FileType,
                    Name = entity.Name,
                    SourceName = entity.SourceName,
                    StatusCode = entity.StatusCode!,
                    StatusText = entity.StatusCodeNavigation.Text,
                    UncPath = entity.UncPath,
                })
                .SingleOrDefaultAsync();

            return digitalObject;
        }

        private static byte[] ImageToByteArray(Bitmap img)
        {
            using (var stream = new MemoryStream())
            {
                img.Save(stream, System.Drawing.Imaging.ImageFormat.Png);
                return stream.ToArray();
            }
        }
    }
}