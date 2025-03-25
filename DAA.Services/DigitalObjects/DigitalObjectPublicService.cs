using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.FileUtils;
using DAA.Models.Configuration;
using DAA.Models.DigitalObjects;
using DAA.Services.LibraryCardService;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;


namespace DAA.Services.DigitalObjects
{
    public class DigitalObjectPublicService : BaseService, IDigitalObjectPublicService
    {
        private readonly LinkedServerSettings _settings;
        private readonly IUserInfo _userInfo;
        private readonly ILibraryCardService _cardService;

        public DigitalObjectPublicService
            (ArchivingContext context,
             IOptions<LinkedServerSettings> settings,
             IUserInfo userInfo,
             ILibraryCardService cardService,
             ILogger<IDigitalObjectPublicService> logger,
             IStringLocalizer<SharedResources> localizer)
            : base(context, localizer, logger)
        {
            _cardService = cardService;
            _settings = settings.Value;
            _userInfo = userInfo;
        }

        public async Task<DataSourceResponseModel<DigitalObjectPublicDisplayModel>> GetByDocumentIdentifierAsync(
            DataSourceRequestModel model,
            Guid? documentSysId,
            bool documentHasExternalSource = false,
            int? documentExternalIdentifier = null,
            bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            int totalCount = 0;
            IEnumerable<DigitalObjectPublicDisplayModel> items = Enumerable.Empty<DigitalObjectPublicDisplayModel>();
            List<object> errors = new();

            bool currUserHaveReaderCard = await _cardService.IsValidCardOfCurrentUser();

            try
            {
                string countQuery = "exec @ReturnValue = sp_GetPublicDocumentDigitalObjectsCount @LinkedServer, @DocumentIdentifier, @DocumentHasExternalSource, @DocumentExternalIdentifier, @PublicAccessOnly";
                List<SqlParameter> countQueryParams = new List<SqlParameter>()
                {
                    new SqlParameter("LinkedServer", _settings.LinkedServer),
                    new SqlParameter("DocumentIdentifier", documentSysId.HasValue ? documentSysId.Value : DBNull.Value),
                    new SqlParameter("DocumentHasExternalSource", documentHasExternalSource),
                    new SqlParameter("DocumentExternalIdentifier", documentExternalIdentifier.HasValue ? documentExternalIdentifier.Value : DBNull.Value),
                    new SqlParameter("PublicAccessOnly", !currUserHaveReaderCard),

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
                _logger.LogWarning(exc, "Error getting digital objects count for document from external source");
                // най-вероятно случай с липса на връзка с ИСДА, затова не логвай грешка; за това ще се появи warning
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting digital objects count for document from external source");

                errors.Add(exc.ToString());
            }

            try
            {
                string query = "exec sp_GetPublicDocumentDigitalObjects " +
                "@LinkedServer, @DocumentIdentifier, @DocumentHasExternalSource, @DocumentExternalIdentifier, @Paging, @PageNumber, @PageSize";
                List<SqlParameter> queryParams = new()
                {
                    new SqlParameter("LinkedServer", _settings.LinkedServer),
                    new SqlParameter("DocumentIdentifier", documentSysId.HasValue ? documentSysId.Value : DBNull.Value),
                    new SqlParameter("DocumentHasExternalSource", documentHasExternalSource),
                    new SqlParameter("DocumentExternalIdentifier", documentExternalIdentifier.HasValue ? documentExternalIdentifier.Value : DBNull.Value),
                    new SqlParameter("Paging", true),
                    new SqlParameter("PageNumber", model.Page),
                    new SqlParameter("PageSize", model.ItemsPerPage),
                };
                var queryResult = await _context.RemoteDigitalObjects
                        .FromSqlRaw(query, queryParams.ToArray())
                        .AsNoTracking()
                        .ToListAsync();
                                
                
                items = queryResult
                    .Select(d => new DigitalObjectPublicDisplayModel()
                    {
                        SystemIdentifier = d.SystemIdentifier,
                        HasExternalSource = d.HasExternalSource,
                        ExternalIdentifier = d.ExternalIdentifier,
                        ArchiveName = d.ArchiveName,
                        FundNumber = d.FundNumber,
                        InventoryNumber = d.InventoryNumber,
                        ArchivalEntityNumber = d.ArchivalEntityNumber,
                        TypeCode = d.TypeCode,
                        FileType = d.FileType,
                        Name = d.Name,
                        SourceName = d.SourceName,
                    });

                if (!currUserHaveReaderCard)
                {
                    items = items.Where(d => (d.HasExternalSource && d.TypeCode != (int)DigitalObjectType.MasterFile) || (d.TypeCode.HasValue && d.TypeCode.Value == (int)DigitalObjectType.DemoFile));
                }   
            }
            catch (Exception exc)
            {
                _logger.LogWarning(exc, "Error getting digital objects for document from external source");

                if (documentSysId.HasValue && documentSysId.Value != Guid.Empty)
                {
                    var localQuery =
                        _context.VPublicDigitalObjects
                        .Where(d => d.DocumentSystemIdentifier == documentSysId)
                        .Select(d => new DigitalObjectPublicDisplayModel()
                        {
                            SystemIdentifier = d.SystemIdentifier,
                            HasExternalSource = d.HasExternalSource,
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
                            IsExternalSourceSnapshot = true,
                        });

                    if (!currUserHaveReaderCard)
                    {
                        localQuery = localQuery.Where(d => !d.TypeCode.HasValue || d.TypeCode.Value == (int)DigitalObjectType.DemoFile);
                    }

                    totalCount = await localQuery.CountAsync();
                    items = await localQuery.ToListAsync();
                }
            }

            DataSourceResponseModel<DigitalObjectPublicDisplayModel> result = new DataSourceResponseModel<DigitalObjectPublicDisplayModel>()
            {
                TotalCount = totalCount,
                Errors = errors.Count > 0 ? errors : null,
                Items = items
            };

            return result;


            //if (documentSysId != null && !currUserHaveReaderCard)
            //{
            //    var localQuery =
            //        _context.DigitalObjects
            //        .Where(d => d.DocumentSystemIdentifier == documentSysId
            //               && !d.Deleted
            //               && d.StatusCode != Shared.Status.Deducted
            //               && d.TypeCode == (int)DigitalObjectType.DemoFile)
            //        .Select(entity => new DigitalObjectPublicDisplayModel()
            //        {
            //            SystemIdentifier = entity.SystemIdentifier,
            //            HasExternalSource = entity.HasExternalSource,
            //            ExternalIdentifier = entity.ExternalIdentifier,
            //            ArchiveName = entity.Archive.Name,
            //            FundNumber = entity.FundSystemIdentifierNavigation.Number,
            //            InventoryNumber = entity.InventorySystemIdentifierNavigation.Number,
            //            ArchivalEntityNumber = entity.ArchivalEntitySystemIdentifierNavigation.Number,
            //            DocumentSystemIdentifier = entity.DocumentSystemIdentifier,
            //            DocumentHasExternalSource = entity.DocumentSystemIdentifierNavigation.HasExternalSource,
            //            DocumentExternalIdentifier = entity.DocumentSystemIdentifierNavigation.ExternalIdentifier,
            //            DocumentNumber = entity.DocumentSystemIdentifierNavigation.Number,
            //            TypeCode = entity.TypeCode,
            //            ContentType = entity.ContentType,
            //            FileType = entity.FileType,
            //            Name = entity.Name,
            //            SourceName = entity.SourceName,
            //            StatusCode = entity.StatusCode!,
            //            StatusText = entity.StatusCodeNavigation.Text,
            //        });

            //    totalCount = await localQuery.CountAsync();
            //    items = await localQuery.ToListAsync();
            //}
            //else if (documentSysId != null && currUserHaveReaderCard)
            //{
            //    var localQuery =
            //           _context.DigitalObjects
            //           .Where(d => d.DocumentSystemIdentifier == documentSysId
            //                    && !d.Deleted
            //                    && d.StatusCode != Shared.Status.Deducted
            //                    && (d.TypeCode == (int)DigitalObjectType.DemoFile || d.TypeCode == (int)DigitalObjectType.DerivativeFile))
            //           .Select(entity => new DigitalObjectPublicDisplayModel()
            //           {
            //               SystemIdentifier = entity.SystemIdentifier,
            //               HasExternalSource = entity.HasExternalSource,
            //               ExternalIdentifier = entity.ExternalIdentifier,
            //               ArchiveName = entity.Archive.Name,
            //               FundNumber = entity.FundSystemIdentifierNavigation.Number,
            //               InventoryNumber = entity.InventorySystemIdentifierNavigation.Number,
            //               ArchivalEntityNumber = entity.ArchivalEntitySystemIdentifierNavigation.Number,
            //               DocumentSystemIdentifier = entity.DocumentSystemIdentifier,
            //               DocumentHasExternalSource = entity.DocumentSystemIdentifierNavigation.HasExternalSource,
            //               DocumentExternalIdentifier = entity.DocumentSystemIdentifierNavigation.ExternalIdentifier,
            //               DocumentNumber = entity.DocumentSystemIdentifierNavigation.Number,
            //               TypeCode = entity.TypeCode,
            //               ContentType = entity.ContentType,
            //               FileType = entity.FileType,
            //               Name = entity.Name,
            //               SourceName = entity.SourceName,
            //               StatusCode = entity.StatusCode!,
            //               StatusText = entity.StatusCodeNavigation.Text,
            //           });

            //    totalCount = await localQuery.CountAsync();
            //    items = await localQuery.ToListAsync();
            //}

            //DataSourceResponseModel<DigitalObjectPublicDisplayModel> result = new()
            //{
            //    TotalCount = totalCount,
            //    Errors = errors.Count > 0 ? errors : null,
            //    Items = items
            //};

            //return result;
        }

        public async Task<OperationResult> ManageDigitalObjectReviewAsync(DigitalObjectPublicDisplayModel digitalObject, Guid? userId)
        {
            //FIX Каква точно е целта на тази заявка и какво трябва да се случи ако обекта е null?
            // - Заявката проверява дали в последната минута същият потребител не е прегледал същия обект, за да не създава твърде много записи в базата
            // - Ако е null се създава нов запис за преглед на DO

            DigitalObjectReview[]? reviews = _context.DigitalObjectReviews
                                  .Where(r => (r.UserSystemIdentifier == _userInfo.CurrentUserId || r.UserSystemIdentifier == AnonymousSystemUser.Id)
                                      && r.DigitalObjectSystemIdentifier == digitalObject.SystemIdentifier).ToArray();

            DigitalObjectReview? lastReview = reviews.Length > 0 ? reviews[reviews.Length - 1] : null;
            bool lastMinuteReview = lastReview != null
                                    && lastReview.Date.Year == DateTime.UtcNow.Year
                                    && lastReview.Date.Month == DateTime.UtcNow.Month
                                    && lastReview.Date.Day == DateTime.UtcNow.Day
                                    && lastReview.Date.Hour == DateTime.UtcNow.Hour
                                    && lastReview.Date.Minute == DateTime.UtcNow.Minute;

            //FIX Какво общо има число с разширението на файла???
            if (!lastMinuteReview && !(FileType.Video.ToString().Contains(digitalObject.FileType) || FileType.Audio.ToString().Contains(digitalObject.FileType)) && digitalObject.SystemIdentifier != null)
            {
                return await CreateDigitalObjectReviewAsync(digitalObject.SystemIdentifier.Value, userId);
            }
            if (lastMinuteReview) return OperationResult.Success;
            return OperationResult.Failed($"Review of {nameof(digitalObject.SystemIdentifier)}");
        }

        public async Task<DigitalObjectPublicDisplayModel?> GetDigitalObjectBySystemIdentifierAsync(Guid sysId)
        {
            var digitalObject =
                await _context.DigitalObjects
                .Where(d => d.SystemIdentifier == sysId && !d.Deleted)
                .Select(entity => new DigitalObjectPublicDisplayModel()
                {
                    SystemIdentifier = entity.SystemIdentifier,
                    HasExternalSource = entity.HasExternalSource,
                    ExternalIdentifier = entity.ExternalIdentifier,
                    ArchiveName = entity.Archive.Name,
                    FundNumber = entity.FundSystemIdentifierNavigation.Number,
                    InventoryNumber = entity.InventorySystemIdentifierNavigation.Number,
                    ArchivalEntityNumber = entity.ArchivalEntitySystemIdentifierNavigation.Number,
                    DocumentSystemIdentifier = entity.DocumentSystemIdentifier,
                    DocumentHasExternalSource = entity.DocumentSystemIdentifierNavigation.HasExternalSource,
                    DocumentExternalIdentifier = entity.DocumentSystemIdentifierNavigation.ExternalIdentifier,
                    DocumentNumber = entity.DocumentSystemIdentifierNavigation.Number,
                    TypeCode = entity.TypeCode,
                    ContentType = entity.ContentType,
                    FileType = entity.FileType,
                    Name = entity.Name,
                    SourceName = entity.SourceName,
                    StatusCode = entity.StatusCode!,
                    StatusText = entity.StatusCodeNavigation.Text,
                })
                .SingleOrDefaultAsync();

            if (digitalObject != null && digitalObject.HasExternalSource && digitalObject.ExternalIdentifier.HasValue)
            {
                try
                {
                    digitalObject = await GetFromExternalSourceAsync(digitalObject.ExternalIdentifier.Value, digitalObject.SystemIdentifier);
                }
                catch (Exception exc)
                {
                    _logger.LogWarning(exc, "Error getting digital object from external source");
                    digitalObject.IsExternalSourceSnapshot = true;

                }
            }

            /*//FIX ТОва не трябваше ли да се изнесе в контролера?! И каква точно е целта на тази заявка и какво трябва да се случи ако обекта е null?
            // - Заявката проверява дали в последната минута същият потребител не е прегледал същия обект, за да не създава твърде много записи в базата
            // - Ако е null се създава нов запис за преглед на DO

            var doReview = await _context.DigitalObjectReviews
                                         .Where(r => r.UserSystemIdentifier == _userInfo.CurrentUserId
                                             && r.DigitalObjectSystemIdentifier == digitalObject.SystemIdentifier
                                             && r.Date.Year == DateTime.UtcNow.Year
                                             && r.Date.Month == DateTime.UtcNow.Month
                                             && r.Date.Day == DateTime.UtcNow.Day
                                             && r.Date.Hour == DateTime.UtcNow.Hour
                                             && r.Date.Minute == DateTime.UtcNow.Minute)
                                         .FirstOrDefaultAsync();

            
            //FIX Какво общо има число с разширението на файла???
            // - Проверката за преглед в последната минута е логична за видео и аудио файлове, тъй като повече кликове в една минута на такъвв файл
            // - най-вероятно би означавала, че файлът НЕ е прегледан изцяло при всеки от кликовете.
            if (_userInfo.CurrentUserId != Guid.Empty && doReview == null && !(FileType.Video.ToString().Contains(digitalObject.FileType) || FileType.Audio.ToString().Contains(digitalObject.FileType)))
            {
                //FIX Защо не е обработен резултата???
                await CreateDigitalObjectReviewAsync(sysId);
            }*/
            return digitalObject;
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

        public async Task<Tuple<string, string>> GetUncPathAndWatermarkUncPathAsync(Guid sysId)
        {
            var digitalObject = 
                await _context.DigitalObjects
                .Where(d=> d.SystemIdentifier == sysId && !d.Deleted)
                .Select(d=> new DigitalObjectDisplayModel()
                {
                    UncPath = d.UncPath,
                    WatermarkUncPath = d.WatermarkUncPath,
                }).SingleOrDefaultAsync();

            return new Tuple<string, string>(digitalObject?.UncPath!, digitalObject?.WatermarkUncPath!);
        }

        public async Task<DigitalObjectPublicDisplayModel?> GetFromExternalSourceAsync(
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

            //var archiveId = await _archiveService.GetArchiveIdByCodeAsync(result.ArchiveCode!.Value);
            //if (!documentSystemIdentifier.HasValue)
            //{
            //    documentSystemIdentifier = await _documentService.GetSystemIdentifierByExternalIdentifierAsync(result.DocumentExternalIdentifier!.Value);
            //}
            //if (!archivalEntitySystemIdentifier.HasValue)
            //{
            //    archivalEntitySystemIdentifier = await _archivalEntityService.GetSystemIdentifierByExternalIdentifierAsync(result.ArchivalEntityExternalIdentifier!.Value);
            //}
            //if (!inventorySystemIdentifier.HasValue)
            //{
            //    inventorySystemIdentifier = await _inventoryService.GetSystemIdentifierByExternalIdentifierAsync(result.InventoryExternalIdentifier!.Value);
            //}
            //if (!fundSystemIdentifier.HasValue)
            //{
            //    fundSystemIdentifier = await _fundService.GetSystemIdentifierByExternalIdentifierAsync(result.FundExternalIdentifier!.Value);
            //}

            return new DigitalObjectPublicDisplayModel()
            {
                SystemIdentifier = systemIdentifier,
                HasExternalSource = result.HasExternalSource,
                ExternalIdentifier = result.ExternalIdentifier,
                ArchiveName = result.ArchiveName,
                FundNumber = result.FundNumber,
                InventoryNumber = result.InventoryNumber,
                ArchivalEntityNumber = result.ArchivalEntityNumber,
                DocumentSystemIdentifier = documentSystemIdentifier,
                DocumentHasExternalSource = result.DocumentHasExternalSource ?? false,
                DocumentExternalIdentifier = result.DocumentExternalIdentifier,
                DocumentNumber = result.DocumentNumber,
                FileType = result.FileType,
                Name = result.Name,
                SourceName = result.Name,
            };
        }


        private async Task<OperationResult?> CreateDigitalObjectReviewAsync(Guid? digitalObjectSystemIdentifier, Guid? userId)
        {
            try
            { 
                if (!digitalObjectSystemIdentifier.HasValue || digitalObjectSystemIdentifier.Value == Guid.Empty)
                {
                    return OperationResult.Succeed("No review for missing digital object system identifier");
                }

                var ids = await _context.DigitalObjects
                    .Where(x => x.SystemIdentifier == digitalObjectSystemIdentifier && !x.Deleted)
                    .Select(x => new
                    {
                        DocumentSystemIdentifier = x.DocumentSystemIdentifier,
                        ArchivalEntitySystemIdentifier = x.ArchivalEntitySystemIdentifier,
                        InventorySystemIdentifier = x.InventorySystemIdentifier,
                        FundSystemIdentifier = x.FundSystemIdentifier
                    })
                    .SingleOrDefaultAsync();

                if (ids == null)
                {
                    return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                /*if (_userInfo == null || !_userInfo.CurrentUserId.HasValue)
                {
                    return OperationResult.Failed("No user info for digital object preview");
                }*/

                Guid systemIdentifier = Guid.NewGuid();
                Guid userGuid = _userInfo.CurrentUserId != null && _userInfo.CurrentUserId.Value != Guid.Empty ? _userInfo.CurrentUserId.Value : userId ?? AnonymousSystemUser.Id;

                DigitalObjectReview digitalObjectReview = new DigitalObjectReview()
                {
                    SystemIdentifier = systemIdentifier,
                    DigitalObjectSystemIdentifier = digitalObjectSystemIdentifier.Value,
                    DocumentSystemIdentifier = ids.DocumentSystemIdentifier,
                    ArchivalEntitySystemIdentifier = ids.ArchivalEntitySystemIdentifier,
                    UserSystemIdentifier = userGuid,
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

      
    }
}
