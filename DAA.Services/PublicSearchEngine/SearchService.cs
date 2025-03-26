using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Models.Configuration;
using DAA.Models.Search;
using DAA.Shared;
using DAA.Shared.Localization;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace DAA.Services.Search
{
    public class SearchService : BaseService, ISearchService
    {
        private readonly LinkedServerSettings _linkedServerOptions;
        private readonly FileStreamSettings _fileStreamOptions;

        private const string ExternalEntitySufix = "_ext";
        private const string EntityTypeFundPrefix = "fund_";
        private const string EntityTypeInventoryPrefix = "inv_";
        private const string EntityTypeArchivalEntityPrefix = "ae_";
        private const string EntityTypeDocumentPrefix = "doc_";
        private const string EntityTypeFilmPrefix = "film_";
        private const string EntityTypeFilmCardPrefix = "fc_";
        private const string FundArrayNoIndexPlaceHolder = "NoIndex";
        private const string CodeSellectNone = "-111";
        private const string DropdownOptionCodeSellectAll = "-999";
        private const string DropdownOptionCodeSellectAllInternal = "-998";
        private const string DropdownOptionCodeSellectAllExternal = "-997";
        private const int DBRequestTimeoutTypeNumber = -2;

        public SearchService
            (ArchivingContext context,
            ILogger<ISearchService> logger,
            IStringLocalizer<SharedResources> localizer,
            IOptions<LinkedServerSettings> linkedServerConfig,
            IOptions<FileStreamSettings> fileStreamOptions)
            : base(context, localizer, logger)
        {
            _linkedServerOptions = linkedServerConfig.Value;
            _fileStreamOptions = fileStreamOptions.Value;
        }

        public async Task<DataSourceResponseModel<SearchResult>?> GetAll(CancellationToken token, SearchModel model, bool includeDrafts = false)
        {
            //_context.Database.SetCommandTimeout(60);

            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
        
            List<string> archiveCodesInternal = new();
            List<string> archiveCodesExternal = new();
            List<string> externalArchiveIdentifiers = new();
            foreach (var item in model.ArchiveId!)
            {
                if (item == DropdownOptionCodeSellectAll)
                {
                    archiveCodesInternal.Add(DropdownOptionCodeSellectAll);
                    archiveCodesExternal.Add(DropdownOptionCodeSellectAll);
                    externalArchiveIdentifiers.Add(DropdownOptionCodeSellectAll);
                }
                else
                {
                    archiveCodesExternal.Add(StripStrings(item));
                    archiveCodesInternal.Add(StripStrings(item));
                }
            }
            if (archiveCodesExternal.Count == 0 && archiveCodesInternal.Count == 0)
            {
                archiveCodesExternal.Add(DropdownOptionCodeSellectAll);
                archiveCodesInternal.Add(DropdownOptionCodeSellectAll);
                externalArchiveIdentifiers.Add(DropdownOptionCodeSellectAll);
            }
            if (archiveCodesExternal.Count == 0)
            {
                archiveCodesExternal.Add(CodeSellectNone);
                externalArchiveIdentifiers.Add(CodeSellectNone);
            }
            else
            {
                //TODO: Трябва да се коригира изчитането на архивите за ИСДА, за да взима ИД-тата
                var archiveIdentifiers = await _context.Archives.Where(a => archiveCodesExternal.Contains(a.Code.ToString())).Select(a => a.ExternalIdentifier.HasValue ? a.ExternalIdentifier.Value.ToString() : string.Empty).ToListAsync();
                archiveIdentifiers = archiveIdentifiers.Where(id => !string.IsNullOrWhiteSpace(id)).ToList();
                externalArchiveIdentifiers.AddRange(archiveIdentifiers);
            }
            if (archiveCodesInternal.Count == 0)
            {
                archiveCodesInternal.Add(CodeSellectNone);
            }

            List<string> entityType = new();

            List<string> fundDescriptionLevelCodesInternal = new();
            List<string> inventoryDescriptionLevelCodesInternal = new();
            List<string> archivalEntityDescriptionLevelCodesInternal = new();
            List<string> documentDescriptionLevelCodesInternal = new();
            List<string> levelOfDescriptionExternal = new();

            if (model.DescriptionLevelCode != null && model.DescriptionLevelCode.Any())
            {
                foreach (var item in model.DescriptionLevelCode)
                {
                    if (item == DropdownOptionCodeSellectAll)
                    {
                        fundDescriptionLevelCodesInternal.Add(DropdownOptionCodeSellectAll);
                        inventoryDescriptionLevelCodesInternal.Add(DropdownOptionCodeSellectAll);
                        archivalEntityDescriptionLevelCodesInternal.Add(DropdownOptionCodeSellectAll);
                        documentDescriptionLevelCodesInternal.Add(DropdownOptionCodeSellectAll);
                        levelOfDescriptionExternal.Add(DropdownOptionCodeSellectAll);
                        entityType.Add(BusinessObjectType.Document);
                        entityType.Add(BusinessObjectType.Film);
                        entityType.Add(BusinessObjectType.FilmCard);
                    }
                    else
                    {
                        if (item.Contains(EntityTypeFundPrefix))
                        {
                            fundDescriptionLevelCodesInternal.Add(StripStrings(item));
                        }
                        else if (item.Contains(EntityTypeInventoryPrefix))
                        {
                            inventoryDescriptionLevelCodesInternal.Add(StripStrings(item));
                        }
                        else if (item.Contains(EntityTypeArchivalEntityPrefix))
                        {
                            archivalEntityDescriptionLevelCodesInternal.Add(StripStrings(item));
                        }
                        else if (item.Contains(EntityTypeDocumentPrefix))
                        {
                            documentDescriptionLevelCodesInternal.Add(StripStrings(item));
                        }
                        else if (item.Contains(EntityTypeFilmPrefix))
                        {
                            entityType.Add(StripStrings(BusinessObjectType.Film));
                        }
                        else if (item.Contains(EntityTypeFilmCardPrefix))
                        {
                            entityType.Add(StripStrings(BusinessObjectType.FilmCard));
                        }
                        else if (item.Contains(EntityTypeDocumentPrefix))
                        {
                            entityType.Add(StripStrings(BusinessObjectType.Document));
                        }

                    }
                }
            }

            if (model.DescriptionLevelCodeExternal != null)
            {
                foreach (var item in model.DescriptionLevelCodeExternal)
                {
                    levelOfDescriptionExternal.Add(StripStrings(item));
                }
            }
            //TODO DA SE PROVERI SLED PROMENITE KAK SE IZBIRA KMF OT SPRAVKATA
            if (!levelOfDescriptionExternal.Any() && 
                !fundDescriptionLevelCodesInternal.Any()
                && !inventoryDescriptionLevelCodesInternal.Any()
                && !archivalEntityDescriptionLevelCodesInternal.Any()
                && !documentDescriptionLevelCodesInternal.Any()
                && !entityType.Any())
            {
                levelOfDescriptionExternal.Add(DropdownOptionCodeSellectAll);
                fundDescriptionLevelCodesInternal.Add(DropdownOptionCodeSellectAll);
                inventoryDescriptionLevelCodesInternal.Add(DropdownOptionCodeSellectAll);
                archivalEntityDescriptionLevelCodesInternal.Add(DropdownOptionCodeSellectAll);
                documentDescriptionLevelCodesInternal.Add(DropdownOptionCodeSellectAll);
            }

            if (!levelOfDescriptionExternal.Any())
            {
                levelOfDescriptionExternal.Add(CodeSellectNone);
            }
            if (!fundDescriptionLevelCodesInternal.Any())
            {
                fundDescriptionLevelCodesInternal.Add(CodeSellectNone);
            }
            if (!inventoryDescriptionLevelCodesInternal.Any())
            {
                inventoryDescriptionLevelCodesInternal.Add(CodeSellectNone);
            }
            if (!archivalEntityDescriptionLevelCodesInternal.Any())
            {
                archivalEntityDescriptionLevelCodesInternal.Add(CodeSellectNone);
            }
            if (!documentDescriptionLevelCodesInternal.Any())
            {
                documentDescriptionLevelCodesInternal.Add(CodeSellectNone);
            }

            List<string> fundArrayCodeInternal = new();
            List<string> fundArrayCodeExternal = new();

            if (model.FundArrayCode != null && model.FundArrayCode.Any())
            {
                foreach (var item in model.FundArrayCode)
                {
                    if (item == DropdownOptionCodeSellectAll)
                    {
                        fundArrayCodeInternal.Add(DropdownOptionCodeSellectAll);
                        fundArrayCodeExternal.Add(DropdownOptionCodeSellectAll);
                    }
                    else if (String.IsNullOrWhiteSpace(item))
                    {
                        fundArrayCodeInternal.Add(FundArrayNoIndexPlaceHolder);
                    }
                    else
                    {
                        fundArrayCodeInternal.Add(StripStrings(item));
                    }
                }
            }

            if (model.FundArrayCodeExternal != null)
            {
                foreach (var item in model.FundArrayCodeExternal)
                {
                    if (item != DropdownOptionCodeSellectAll)
                    {
                        fundArrayCodeExternal.Add(item);
                    }
                }
            }

            if (!fundArrayCodeExternal.Any() && !fundArrayCodeInternal.Any())
            {
                fundArrayCodeExternal.Add(DropdownOptionCodeSellectAll);
                fundArrayCodeInternal.Add(DropdownOptionCodeSellectAll);
            }
            if (!fundArrayCodeExternal.Any())
            {
                fundArrayCodeExternal.Add(CodeSellectNone);
            }
            if (!fundArrayCodeInternal.Any())
            {
                fundArrayCodeInternal.Add(CodeSellectNone);
            }

            string fundArrayCodeInternalStr = JoinStrings(fundArrayCodeInternal);
            if (fundArrayCodeInternalStr.IndexOf(FundArrayNoIndexPlaceHolder) >= 0)
            {
                fundArrayCodeInternalStr = fundArrayCodeInternalStr.Replace(FundArrayNoIndexPlaceHolder, string.Empty);
            }

            bool? searchByDigitalCopies = null;
            if (model.SearchByDigitalCopies == "1")
            {
                searchByDigitalCopies = true;
            }
            else if (model.SearchByDigitalCopies == "2")
            {
                searchByDigitalCopies = false;
            }

            if (!fundDescriptionLevelCodesInternal.Contains(CodeSellectNone) || model.FundNumber != null)
            {
                entityType.Add(BusinessObjectType.Fund);
            }
            if (!inventoryDescriptionLevelCodesInternal.Contains(CodeSellectNone) || model.InventoryNumber != null)
            {
                entityType.Add(BusinessObjectType.Inventory);
            }
            if (!archivalEntityDescriptionLevelCodesInternal.Contains(CodeSellectNone) || model.ArchivalEntityNumber != null)
            {
                entityType.Add(BusinessObjectType.ArchivalEntity);
            }
            if (!documentDescriptionLevelCodesInternal.Contains(CodeSellectNone))
            {
                entityType.Add(BusinessObjectType.Document);
            }
            if (!string.IsNullOrWhiteSpace(model.CmfNumber))
            {
                entityType.Add(BusinessObjectType.Film);
                entityType.Add(BusinessObjectType.FilmCard);
            }

            // за да може избран елемент да се намери, така че нивата на описание на по-старшите от него елементи(свързани с него) да са произволни,
            // когато тези нива на описание за по-старшите елементи не са оказани в пад. меню
            if (inventoryDescriptionLevelCodesInternal[0] != CodeSellectNone)
            {
                if (fundDescriptionLevelCodesInternal[0] == CodeSellectNone)
                {
                    fundDescriptionLevelCodesInternal[0] = DropdownOptionCodeSellectAll;
                }
            }
            if (archivalEntityDescriptionLevelCodesInternal[0] != CodeSellectNone)
            {
                if (fundDescriptionLevelCodesInternal[0] == CodeSellectNone)
                {
                    fundDescriptionLevelCodesInternal[0] = DropdownOptionCodeSellectAll;
                }
                if (inventoryDescriptionLevelCodesInternal[0] == CodeSellectNone)
                {
                    inventoryDescriptionLevelCodesInternal[0] = DropdownOptionCodeSellectAll;
                }
            }
            if (documentDescriptionLevelCodesInternal[0] != CodeSellectNone)
            {
                if (fundDescriptionLevelCodesInternal[0] == CodeSellectNone)
                {
                    fundDescriptionLevelCodesInternal[0] = DropdownOptionCodeSellectAll;
                }
                if (inventoryDescriptionLevelCodesInternal[0] == CodeSellectNone)
                {
                    inventoryDescriptionLevelCodesInternal[0] = DropdownOptionCodeSellectAll;
                }
                if (archivalEntityDescriptionLevelCodesInternal[0] == CodeSellectNone)
                {
                    archivalEntityDescriptionLevelCodesInternal[0] = DropdownOptionCodeSellectAll;
                }
            }

            var cmfCountriesOfOriginCodes = DropdownOptionCodeSellectAll;
            if (model.CmfCountriesOfOriginCodes != null && model.CmfCountriesOfOriginCodes.Count() > 0)
            {
                cmfCountriesOfOriginCodes = JoinStrings(model.CmfCountriesOfOriginCodes!.ToList());
            }

            try
            {
                //var rows = await _context.SearchResults.FromSqlRaw("EXECUTE dbo.MainSearchComponent {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19},{20},{21},{22},{23},{24}",
                //    _linkedServerOptions.LinkedServer!,
                //    includeDrafts,
                //    //JoinStrings(archiveCodesExternal),
                //    JoinStrings(externalArchiveIdentifiers),
                //    JoinStrings(archiveCodesInternal),
                //    model.FundNumber != null ? model.FundNumber : DBNull.Value,
                //    model.InventoryNumber != null ? model.InventoryNumber : DBNull.Value,
                //    model.ArchivalEntityNumber != null ? model.ArchivalEntityNumber : DBNull.Value,
                //    JoinStrings(levelOfDescriptionExternal),
                //    JoinStrings(fundDescriptionLevelCodesInternal),
                //    JoinStrings(inventoryDescriptionLevelCodesInternal),
                //    JoinStrings(archivalEntityDescriptionLevelCodesInternal),
                //    JoinStrings(documentDescriptionLevelCodesInternal),
                //    JoinStrings(fundArrayCodeExternal),
                //    fundArrayCodeInternalStr,
                //    model.CmfNumber != null ? model.CmfNumber!.ToString() : DBNull.Value,
                //    cmfCountriesOfOriginCodes,
                //    model.DateTo != null ? model.DateTo : DBNull.Value,
                //    model.DateFrom != null ? model.DateFrom : DBNull.Value,
                //    model.Name != null ? model.Name : DBNull.Value,
                //    model.KeyWords != null ? model.KeyWords : DBNull.Value,
                //    searchByDigitalCopies != null ? searchByDigitalCopies : DBNull.Value,
                //    JoinStrings(entityType),
                //    model.AdvancedSearch != null ? model.AdvancedSearch : false,
                //    model.ItemsPerPage!,
                //    model.Page!
                //).ToListAsync(token);



                string query = "exec MainSearchComponent @LinkedServer, @SearchDrafts,@ArchiveGids, @ArchiveCodesInternal, @FundNumber, @InventoryNumber, @ArchivalEntityNumber, @LevelOfDescriptionGids, @FundDescriptionLevelCodesInternal, @InventoryDescriptionLevelCodesInternal, @ArchivalEntityDescriptionLevelCodesInternal, @DocumentDescriptionLevelCodesInternal, @FundArrayGids, @FundArraysInternal, @KMFNumber, @KMFCountriesOfOriginCodes, @ToDate, @FromDate, @Title, @KeyWords, @SearchDigitalObject,@EntityType,@ExtendedSearch, @SearchFileContent, @FileDbName, @FileBufferDbName, @RowsOfPage, @Page";
                List<SqlParameter> queryParams = new List<SqlParameter>()
                {
                    new SqlParameter("LinkedServer", _linkedServerOptions.LinkedServer),
                    new SqlParameter("SearchDrafts", includeDrafts),
                    new SqlParameter("ArchiveGids",JoinStrings(externalArchiveIdentifiers)), 
                    new SqlParameter("ArchiveCodesInternal", JoinStrings(archiveCodesInternal)), 
                    new SqlParameter("FundNumber", !string.IsNullOrWhiteSpace(model.FundNumber) ? model.FundNumber : DBNull.Value), 
                    new SqlParameter("InventoryNumber", !string.IsNullOrWhiteSpace(model.InventoryNumber) ? model.InventoryNumber : DBNull.Value), 
                    new SqlParameter("ArchivalEntityNumber", !string.IsNullOrWhiteSpace(model.ArchivalEntityNumber) ? model.ArchivalEntityNumber : DBNull.Value), 
                    new SqlParameter("LevelOfDescriptionGids", JoinStrings(levelOfDescriptionExternal)), 
                    new SqlParameter("FundDescriptionLevelCodesInternal", JoinStrings(fundDescriptionLevelCodesInternal)),
                    new SqlParameter("InventoryDescriptionLevelCodesInternal", JoinStrings(inventoryDescriptionLevelCodesInternal)), 
                    new SqlParameter("ArchivalEntityDescriptionLevelCodesInternal", JoinStrings(archivalEntityDescriptionLevelCodesInternal)), 
                    new SqlParameter("DocumentDescriptionLevelCodesInternal", JoinStrings(documentDescriptionLevelCodesInternal)), 
                    new SqlParameter("FundArrayGids", JoinStrings(fundArrayCodeExternal)), 
                    new SqlParameter("FundArraysInternal", fundArrayCodeInternalStr), 
                    new SqlParameter("KMFNumber", !string.IsNullOrWhiteSpace(model.CmfNumber) ? model.CmfNumber : DBNull.Value), 
                    new SqlParameter("KMFCountriesOfOriginCodes", !string.IsNullOrWhiteSpace(cmfCountriesOfOriginCodes) ? cmfCountriesOfOriginCodes : DBNull.Value), 
                    new SqlParameter("ToDate", model.DateTo.HasValue ? model.DateTo : DBNull.Value), 
                    new SqlParameter("FromDate", model.DateFrom.HasValue ? model.DateFrom : DBNull.Value), 
                    new SqlParameter("Title", !string.IsNullOrWhiteSpace(model.Name) ? model.Name : DBNull.Value),
                    new SqlParameter("KeyWords", !string.IsNullOrWhiteSpace(model.KeyWords) ? model.KeyWords : DBNull.Value), 
                    new SqlParameter("SearchDigitalObject", searchByDigitalCopies.HasValue ? searchByDigitalCopies : DBNull.Value),
                    new SqlParameter("EntityType", JoinStrings(entityType)),
                    new SqlParameter("ExtendedSearch", model.AdvancedSearch.HasValue ? model.AdvancedSearch : false),
                    new SqlParameter("SearchFileContent", model.SearchFileContent.HasValue ? model.SearchFileContent : false), 
                    new SqlParameter("FileDbName", _fileStreamOptions.Files?.DbName), 
                    new SqlParameter("FileBufferDbName", _fileStreamOptions.BufferFiles?.DbName), 
                    new SqlParameter("RowsOfPage", model.ItemsPerPage.HasValue ? model.ItemsPerPage : 10),
                    new SqlParameter("Page", model.Page.HasValue ? model.Page : 1)

                };
                var queryResult =
                    await _context.SearchResults
                            .FromSqlRaw(query, queryParams.ToArray())
                            .AsNoTracking()
                            .ToListAsync(token);


                //DataSourceResponseModel<SearchResult> resultData = new()
                //{
                //    TotalCount = rows.Count > 0 ? rows[0].TotalRows : 0,
                //    Items = rows
                //};
                DataSourceResponseModel<SearchResult> resultData = new()
                {
                    TotalCount = (queryResult != null && queryResult.Count > 0) ? queryResult[0].TotalRows : 0,
                    Items = queryResult,
                };

                return resultData;
            }
            catch (OperationCanceledException)
            {
                throw;
            }
            catch (SqlException e)
            {
                if (e.Number == DBRequestTimeoutTypeNumber)
                {
                    throw new DBRequestTimeoutException();
                }
                if (token.IsCancellationRequested)
                {
                    _logger.LogWarning(e, "Cancellation requested");
                    token.ThrowIfCancellationRequested();
                }

                _logger.LogWarning(e, "Error retrieving data from ISDA");

                //var rows = await _context.SearchResults.FromSqlRaw("EXECUTE dbo.MainSearchComponentInternal {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19},{20},{21}",
                //    _linkedServerOptions.LinkedServer!,
                //    includeDrafts,
                //    JoinStrings(archiveCodesInternal),
                //    model.FundNumber != null ? model.FundNumber : DBNull.Value,
                //    model.InventoryNumber != null ? model.InventoryNumber : DBNull.Value,
                //    model.ArchivalEntityNumber != null ? model.ArchivalEntityNumber : DBNull.Value,
                //    JoinStrings(fundDescriptionLevelCodesInternal),
                //    JoinStrings(inventoryDescriptionLevelCodesInternal),
                //    JoinStrings(archivalEntityDescriptionLevelCodesInternal),
                //    JoinStrings(documentDescriptionLevelCodesInternal),
                //    fundArrayCodeInternalStr,
                //    model.CmfNumber != null ? model.CmfNumber!.ToString() : DBNull.Value,
                //    cmfCountriesOfOriginCodes,
                //    model.DateTo != null ? model.DateTo : DBNull.Value,
                //    model.DateFrom != null ? model.DateFrom : DBNull.Value,
                //    model.Name != null ? model.Name : DBNull.Value,
                //    model.KeyWords != null ? model.KeyWords : DBNull.Value,
                //    searchByDigitalCopies != null ? searchByDigitalCopies : DBNull.Value,
                //    JoinStrings(entityType),
                //    model.AdvancedSearch != null ? model.AdvancedSearch : false,
                //    model.ItemsPerPage!,
                //    model.Page!
                //).ToListAsync(token);


                string query = "exec MainSearchComponentInternal @LinkedServer, @SearchDrafts, @ArchiveCodes, @FundNumber, @InventoryNumber, @ArchivalEntityNumber, @FundDescriptionLevelCodes, @InventoryDescriptionLevelCodes, @ArchivalEntityDescriptionLevelCodes, @DocumentDescriptionLevelCodes, @FundArrays, @KMFNumber, @KMFCountriesOfOriginCodes, @ToDate, @FromDate, @Title, @KeyWords, @SearchDigitalObject, @EntityType, @ExtendedSearch, @SearchFileContent, @FileDbName, @FileBufferDbName, @RowsOfPage, @Page";
                List<SqlParameter> queryParams = new List<SqlParameter>()
                {
                    new SqlParameter("LinkedServer", _linkedServerOptions.LinkedServer),
                    new SqlParameter("SearchDrafts", includeDrafts),
                    new SqlParameter("ArchiveCodes", JoinStrings(archiveCodesInternal)),
                    new SqlParameter("FundNumber", !string.IsNullOrWhiteSpace(model.FundNumber) ? model.FundNumber : DBNull.Value),
                    new SqlParameter("InventoryNumber", !string.IsNullOrWhiteSpace(model.InventoryNumber) ? model.InventoryNumber : DBNull.Value),
                    new SqlParameter("ArchivalEntityNumber", !string.IsNullOrWhiteSpace(model.ArchivalEntityNumber) ? model.ArchivalEntityNumber : DBNull.Value),
                    new SqlParameter("FundDescriptionLevelCodes", JoinStrings(fundDescriptionLevelCodesInternal)),
                    new SqlParameter("InventoryDescriptionLevelCodes", JoinStrings(inventoryDescriptionLevelCodesInternal)),
                    new SqlParameter("ArchivalEntityDescriptionLevelCodes", JoinStrings(archivalEntityDescriptionLevelCodesInternal)),
                    new SqlParameter("DocumentDescriptionLevelCodes", JoinStrings(documentDescriptionLevelCodesInternal)),
                    new SqlParameter("FundArrays", fundArrayCodeInternalStr),
                    new SqlParameter("KMFNumber", !string.IsNullOrWhiteSpace(model.CmfNumber) ? model.CmfNumber!.ToString() : DBNull.Value),
                    new SqlParameter("KMFCountriesOfOriginCodes", !string.IsNullOrWhiteSpace(cmfCountriesOfOriginCodes) ? cmfCountriesOfOriginCodes : DBNull.Value),
                    new SqlParameter("ToDate", model.DateTo.HasValue ? model.DateTo : DBNull.Value),
                    new SqlParameter("FromDate", model.DateFrom.HasValue ? model.DateFrom : DBNull.Value),
                    new SqlParameter("Title", !string.IsNullOrWhiteSpace(model.Name) ? model.Name : DBNull.Value),
                    new SqlParameter("KeyWords", !string.IsNullOrWhiteSpace(model.KeyWords) ? model.KeyWords : DBNull.Value),
                    new SqlParameter("SearchDigitalObject", searchByDigitalCopies.HasValue ? searchByDigitalCopies : DBNull.Value),
                    new SqlParameter("EntityType", JoinStrings(entityType)),
                    new SqlParameter("ExtendedSearch", model.AdvancedSearch.HasValue ? model.AdvancedSearch : false),
                    new SqlParameter("SearchFileContent", model.SearchFileContent.HasValue ? model.SearchFileContent : false),
                    new SqlParameter("FileDbName", _fileStreamOptions.Files?.DbName),
                    new SqlParameter("FileBufferDbName", _fileStreamOptions.BufferFiles?.DbName),
                    new SqlParameter("RowsOfPage", model.ItemsPerPage.HasValue ? model.ItemsPerPage : 10),
                    new SqlParameter("Page", model.Page.HasValue ? model.Page : 1)

                };
                var queryResult =
                    await _context.SearchResults
                            .FromSqlRaw(query, queryParams.ToArray())
                            .AsNoTracking()
                            .ToListAsync(token);


                //DataSourceResponseModel<SearchResult> resultData = new()
                //{
                //    TotalCount = rows.Count > 0 ? rows[0].TotalRows : 0,
                //    Items = rows
                //};

                DataSourceResponseModel<SearchResult> resultData = new()
                {
                    TotalCount = (queryResult != null && queryResult.Count > 0) ? queryResult[0].TotalRows : 0,
                    Items = queryResult,
                    IsExternalSourceSnapshot = true,
                };

                return resultData;
            }
        }

        private static string JoinStrings(IList<string> strings) => string.Join(",", strings);

        private static string StripStrings(string originalStr)
        {
            return originalStr
                .Replace(ExternalEntitySufix, string.Empty)
                .Replace(EntityTypeFundPrefix, string.Empty)
                .Replace(EntityTypeInventoryPrefix, string.Empty)
                .Replace(EntityTypeArchivalEntityPrefix, string.Empty)
                .Replace(EntityTypeDocumentPrefix, string.Empty);
        }
    }
}


