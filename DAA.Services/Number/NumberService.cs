using DAA.Data;
using DAA.Extensions.Exceptions;
using DAA.Models.Configuration;
using DAA.Services.Interfaces;
using DAA.Shared.Data;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace DAA.Services.Numbers
{
    public class NumberService : BaseService, INumberService

    {
        private readonly IDropdownService _dropdownService;
        private readonly LinkedServerSettings _linkedServerSettings;

        public NumberService(
           ArchivingContext context,
           IStringLocalizer<SharedResources> localizer,
           ILogger<NumberService> logger,
           IOptions<LinkedServerSettings> linkedServerConfig,
           IUserInfo userInfo,
           IDropdownService dropdownService) : base(context, localizer, logger)
        {
            _dropdownService = dropdownService;
            _linkedServerSettings = linkedServerConfig.Value;
        }

        public async Task<int> GetFundNumberNumeric(int archiveId, string descriptionLevelCode, string fundArray)
        {
            int numberNumeric = 1;

            try
            {
                var archiveCode = await _context.Archives
                                        .Where(a => a.Id == archiveId && a.Deleted == false)
                                        .Select(a => a.Code)
                                        .SingleAsync();

                var externalSourceDescLevelCode = DescriptionLevelMapping.FundDescriptionLevel.Where(map => map.Value == descriptionLevelCode).Select(map => map.Key).FirstOrDefault();

                string remoteQuery = "exec @ReturnValue = sp_GetLastFundNumberNumeric @LinkedServer, @ArchiveCode, @DescriptionLevelCode, @FundArray";
                List<SqlParameter> remoteQueryParams = new List<SqlParameter>()
                    {
                        new SqlParameter("LinkedServer", _linkedServerSettings.LinkedServer),
                        new SqlParameter("ArchiveCode", archiveCode),
                        new SqlParameter("DescriptionLevelCode", !string.IsNullOrWhiteSpace(externalSourceDescLevelCode) ? externalSourceDescLevelCode : DBNull.Value),
                        new SqlParameter("FundArray", fundArray),
                    };
                SqlParameter queryReturnValue = new SqlParameter()
                {
                    ParameterName = "ReturnValue",
                    SqlDbType = System.Data.SqlDbType.Int,
                    Direction = System.Data.ParameterDirection.Output
                };
                remoteQueryParams.Add(queryReturnValue);

                await _context.Database.ExecuteSqlRawAsync(remoteQuery, remoteQueryParams.ToArray());

                int remoteNumberNumeric = (int)queryReturnValue.Value;
                if (numberNumeric <= remoteNumberNumeric)
                {
                    numberNumeric = remoteNumberNumeric + 1;
                }

            }
            catch (Exception exc)
            {
                _logger.LogWarning(exc, $"Error getting last generated number from external source (archiveId: {archiveId}, fundArray: {fundArray}, descriptionLevel: {descriptionLevelCode})");
                throw new ExternalConnectionException("Error getting last generated number numeric", exc);
            }

            var localQuery = _context.VFunds
                                .Where(f => f.ArchiveId == archiveId
                                    && f.NumberArray == fundArray
                                    && !f.Deleted
                                    && (f.HasExternalSource.HasValue && !f.HasExternalSource.Value));

            int.TryParse(descriptionLevelCode, out int descriptionLevelCodeNumeric);
            if (descriptionLevelCodeNumeric == (int)Shared.FundDescriptionLevel.Fund || descriptionLevelCodeNumeric == (int)Shared.FundDescriptionLevel.RawFund)
            {
                localQuery = localQuery.Where(f =>
                                            f.DescriptionLevelCode == Shared.FundDescriptionLevel.Fund.ToString("d")
                                            || f.DescriptionLevelCode == Shared.FundDescriptionLevel.RawFund.ToString("d"));
            }
            else
            {
                localQuery = localQuery.Where(f => f.DescriptionLevelCode == descriptionLevelCode);
            }

            int? localNumberNumeric = await localQuery.MaxAsync(f => f.NumberNumeric);
            if (localNumberNumeric.HasValue && numberNumeric <= localNumberNumeric.Value)
            {
                numberNumeric = localNumberNumeric.Value + 1;
            }

            return numberNumeric;
        }

        //public async Task<string> GenerateFundNumber(int archive, string fundArray, int descriptionLevelCode)
        //{    
        //    var fundArrayExternal = fundArray;
        //    var fundArrayInternal = fundArray;
        //    if (fundArray == "noIndex")
        //    {
        //        fundArrayExternal = "Без индекс";
        //        fundArrayInternal = string.Empty;
        //        fundArray = string.Empty;
        //    }

        //    // Взимат се последните n на брой реда, подредени в намаляващ ред, където n е броят на стойностите на levelOfDescriptionCode в ИСДА
        //    var rowsExternal = await _context.LastNumbers.FromSqlRaw("EXECUTE dbo.sp_GetLastFundNumbers {0},{1},{2}",
        //        _linkedServerSettings.LinkedServer!,
        //        archive,
        //        fundArrayExternal
        //    ).ToListAsync();


        //    DbFunctions? dbFunc = null;

        //    var fundArraysInternalCount = _dropdownService.GetFundArrays().Count();
        //    var rowsInternal = await _context.VFunds // Дали е това?
        //        .Where(f => f.ArchiveCode == archive && f.NumberArray == fundArray 
        //            && f.Deleted == false && !f.HasExternalSource!.Value && f.Number != null 
        //            && dbFunc!.Like(f.Number, "[0-9]%"))
        //        .Select(f => new Number()
        //        {
        //            Num = f.Number,
        //            LevelOfDescriptionCode = int.Parse(f.DescriptionLevelCode!),
        //            Id = f.Id
        //        })
        //        .OrderByDescending(f => f.Id)
        //        .Take(fundArraysInternalCount)
        //        .ToListAsync();


        //    if (rowsExternal.Count == 0 && rowsInternal.Count == 0)
        //    {
        //        return $"1{fundArray}";
        //    }

        //    int? intPart = null;
        //    if (rowsExternal.Count > 0 && rowsInternal.Count > 0)
        //    {
        //        var groupWithLastNumberExternal = rowsExternal.GroupBy(x => x.Num).First();
        //        var groupWithLastNumberInternal = rowsInternal.GroupBy(x => x.Num).First();
        //        IGrouping<string?, Number> groupWithLastNumber = groupWithLastNumberInternal;
        //        if (ExtractInt(groupWithLastNumberExternal.First().Num!) > ExtractInt(groupWithLastNumberInternal.First().Num!))
        //        {
        //            groupWithLastNumber = groupWithLastNumberExternal;
        //        }

        //        intPart = GetIntNumber(groupWithLastNumber, descriptionLevelCode);
        //        return intPart != null ? $"{intPart}{fundArray}" : string.Empty;
        //    }
        //    else if (rowsExternal.Count == 0 && rowsInternal.Count > 0)
        //    {
        //        var groupWithLastNumberInternal = rowsInternal.GroupBy(x => x.Num).First();
        //        IGrouping<string?, Number> groupWithLastNumber = groupWithLastNumberInternal;

        //        intPart = GetIntNumber(groupWithLastNumber, descriptionLevelCode);
        //        return $"{intPart}{fundArray}";
        //    }
        //    else if (rowsExternal.Count > 0 && rowsInternal.Count == 0)
        //    {
        //        var groupWithLastNumberExternal = rowsExternal.GroupBy(x => x.Num).First();
        //        IGrouping<string?, Number> groupWithLastNumber = groupWithLastNumberExternal;

        //        intPart = GetIntNumber(groupWithLastNumber, descriptionLevelCode);
        //        return $"{intPart}{fundArray}";
        //    }

        //    return string.Empty;
        //}

        //public async Task<int> GetLastFundNumberExternal(int archive, string fundArray, int levelOfDescriptionCode)
        //{
        //    var fundArrayExternal = fundArray;
        //    var fundArrayInternal = fundArray;
        //    //if (fundArray == "noIndex")
        //    //{
        //    //    fundArrayExternal = "Без индекс";
        //    //    fundArrayInternal = string.Empty;
        //    //    fundArray = string.Empty;
        //    //}

        //    // Взимат се последните n на брой реда, подредени в намаляващ ред, където n е броят на стойностите на levelOfDescriptionCode в ИСДА
        //    var rowsExternal = await _context.LastNumbers.FromSqlRaw("EXECUTE dbo.sp_GetLastFundNumbers {0},{1},{2}",
        //        _linkedServerSettings.LinkedServer!,
        //        archive,
        //        fundArrayExternal
        //    ).ToListAsync();

        //    if (rowsExternal.Count == 0)
        //    {
        //        //return $"1{(fundArray.Equals(_localizer.GetString("Fund_NumberArrayNoIndex").ToString(), StringComparison.OrdinalIgnoreCase) ? string.Empty : fundArray)}";
        //        return 1;
        //    }

        //    var groupWithLastNumberExternal = rowsExternal.GroupBy(x => x.Num).First();
        //    IGrouping<string?, Number> groupWithLastNumber = groupWithLastNumberExternal;

        //    var intPart = GetIntNumber(groupWithLastNumber, levelOfDescriptionCode);
        //    //return $"{intPart}{(fundArray.Equals(_localizer.GetString("Fund_NumberArrayNoIndex").ToString(), StringComparison.OrdinalIgnoreCase) ? string.Empty : fundArray)}";
        //    return intPart ?? 1;
        //}


        public async Task<bool> IsValidFundNumber(int archiveId, string number, string fundArray, string descriptionLevelCode, Guid? systemIdentifier = null)
        {
            bool numberValidationRequired = true;
            if (systemIdentifier.HasValue && systemIdentifier.Value != Guid.Empty)
            {
                numberValidationRequired = !await _context.VFunds.Where(f => f.SystemIdentifier == systemIdentifier && f.Number == number).AnyAsync();
            }

            bool numberExists = false;

            if (numberValidationRequired)
            {
                var localQuery = _context.VFunds
                                .Where(f => f.ArchiveId == archiveId
                                    && f.NumberArray == fundArray
                                    && f.Number == number
                                    && !f.Deleted
                                    && (!systemIdentifier.HasValue || (f.SystemIdentifier != systemIdentifier.Value))
                                    && (f.HasExternalSource.HasValue && !f.HasExternalSource.Value));

                int.TryParse(descriptionLevelCode, out int descriptionLevelCodeNumeric);
                if (descriptionLevelCodeNumeric == (int)Shared.FundDescriptionLevel.Fund || descriptionLevelCodeNumeric == (int)Shared.FundDescriptionLevel.RawFund)
                {
                    localQuery = localQuery.Where(f =>
                                                f.DescriptionLevelCode == Shared.FundDescriptionLevel.Fund.ToString("d")
                                                || f.DescriptionLevelCode == Shared.FundDescriptionLevel.RawFund.ToString("d"));
                }
                else
                {
                    localQuery = localQuery.Where(f => f.DescriptionLevelCode == descriptionLevelCode);
                }

                numberExists = await localQuery.AnyAsync();

                if (!numberExists)
                {
                    var archiveCode = await _context.Archives
                                        .Where(a => a.Id == archiveId && a.Deleted == false)
                                        .Select(a => a.Code)
                                        .SingleAsync();

                    try
                    {
                        var externalSourceDescLevelCode = DescriptionLevelMapping.FundDescriptionLevel.Where(map => map.Value == descriptionLevelCode).Select(map => map.Key).FirstOrDefault();

                        string remoteQuery = "exec @ReturnValue = sp_CheckIfNewFundNumberIsValid @LinkedServer, @ArchiveCode, @Number, @FundArray, @DescriptionLevel";
                        List<SqlParameter> remoteQueryParams = new List<SqlParameter>()
                        {
                            new SqlParameter("LinkedServer", _linkedServerSettings.LinkedServer),
                            new SqlParameter("ArchiveCode", archiveCode),
                            new SqlParameter("Number", number),
                            new SqlParameter("FundArray", fundArray),
                            new SqlParameter("DescriptionLevel", !string.IsNullOrWhiteSpace(externalSourceDescLevelCode) ? externalSourceDescLevelCode : DBNull.Value),

                        };
                        SqlParameter queryReturnValue = new SqlParameter()
                        {
                            ParameterName = "ReturnValue",
                            SqlDbType = System.Data.SqlDbType.Bit,
                            Direction = System.Data.ParameterDirection.Output
                        };
                        remoteQueryParams.Add(queryReturnValue);

                        await _context.Database.ExecuteSqlRawAsync(remoteQuery, remoteQueryParams.ToArray());

                        numberExists = !(bool)queryReturnValue.Value;
                    }
                    catch (Exception exc)
                    {
                        throw new ExternalConnectionException("Cannot validate fund number", exc);
                    }
                }
            }

            return !numberExists;
        }

        public async Task<int> GetInventoryNumberNumeric(int archiveId, Guid fundSystemIdentifier, string descriptionLevelCode, string inventoryArray)
        {
            int numberNumeric = 1;

            var fundExternalIdentifier = await _context.VFunds
                                            .Where(f => f.SystemIdentifier == fundSystemIdentifier && (f.HasExternalSource.HasValue && f.HasExternalSource.Value) && !f.Deleted)
                                            .Select(f => f.ExternalIdentifier)
                                            .SingleOrDefaultAsync();

            if (fundExternalIdentifier.HasValue)
            {
                try
                {
                    var archiveCode = await _context.Archives
                                            .Where(a => a.Id == archiveId && a.Deleted == false)
                                            .Select(a => a.Code)
                                            .SingleAsync();

                    var externalSourceDescLevelCode = DescriptionLevelMapping.InventoryDescriptionLevel
                                                        .Where(map => map.Value == descriptionLevelCode)
                                                        .Select(map => map.Key)
                                                        .FirstOrDefault();
                    var externalInventoryArray = await _context.InventoryArrays
                                                        .Where(arr => arr.Code == inventoryArray)
                                                        .Select(arr => arr.ExternalSourceCode)
                                                        .SingleAsync();

                    string remoteQuery = "exec @ReturnValue = sp_GetLastInventoryNumberNumeric @LinkedServer, @ArchiveCode, @FundIdentifier, @DescriptionLevelCode, @InventoryArray";
                    List<SqlParameter> remoteQueryParams = new List<SqlParameter>()
                    {
                        new SqlParameter("LinkedServer", _linkedServerSettings.LinkedServer),
                        new SqlParameter("ArchiveCode", archiveCode),
                        new SqlParameter("FundIdentifier", fundExternalIdentifier.Value),
                        new SqlParameter("DescriptionLevelCode", !string.IsNullOrWhiteSpace(externalSourceDescLevelCode) ? externalSourceDescLevelCode : DBNull.Value),
                        new SqlParameter("InventoryArray", externalInventoryArray),
                    };
                    SqlParameter queryReturnValue = new SqlParameter()
                    {
                        ParameterName = "ReturnValue",
                        SqlDbType = System.Data.SqlDbType.Int,
                        Direction = System.Data.ParameterDirection.Output
                    };
                    remoteQueryParams.Add(queryReturnValue);

                    await _context.Database.ExecuteSqlRawAsync(remoteQuery, remoteQueryParams.ToArray());

                    int remoteNumberNumeric = (int)queryReturnValue.Value;
                    if (numberNumeric <= remoteNumberNumeric)
                    {
                        numberNumeric = remoteNumberNumeric + 1;
                    }
                }
                catch (Exception exc)
                {
                    _logger.LogWarning(exc, $"Error getting last generated number from external source (archiveId: {archiveId}, fundSysId: {fundSystemIdentifier}, inventoryArray: {inventoryArray}, descriptionLevel: {descriptionLevelCode})");
                    throw new ExternalConnectionException("Error getting last generated number numeric", exc);
                }
            }

            int.TryParse(descriptionLevelCode, out int descriptionLevelCodeNumeric);

            var localQuery = _context.VInventories
                                .Where(inv => inv.ArchiveId == archiveId
                                    && inv.FundSystemIdentifier == fundSystemIdentifier
                                    && inv.DescriptionLevelCode == descriptionLevelCode
                                    && inv.NumberArray == inventoryArray
                                    && !inv.Deleted
                                    && (inv.HasExternalSource.HasValue && !inv.HasExternalSource.Value));

            int? localNumberNumeric = await localQuery.MaxAsync(f => f.NumberNumeric);
            if (localNumberNumeric.HasValue && numberNumeric <= localNumberNumeric.Value)
            {
                numberNumeric = localNumberNumeric.Value + 1;
            }

            return numberNumeric;
        }


        //public async Task<string> GenerateInventoryNumber(
        //    int archive, int fundExternalIdentifier, Guid fundSystemIdentifier, string inventoryArray, int levelOfDescriptionCode)
        //{
        //    // test
        //    //archive = 12;
        //    //archive = 14; 
        //    //inventoryArray = "Н";
        //    //levelOfDescriptionCode = 6;
        //    //fundExternalIdentifier = 11526808;

        //    var inventoryArrayExternal = inventoryArray;
        //    var inventoryArrayInternal = inventoryArray;
        //    if (inventoryArray == "noIndex")
        //    {
        //        inventoryArrayExternal = "Без индекс";
        //        inventoryArrayInternal = string.Empty;
        //        inventoryArray = string.Empty;
        //    }

        //    List<Number> rowsExternal = new();
        //    if (fundExternalIdentifier != -1)
        //    {
        //        // Взимат се последните n на брой реда, подредени в намаляващ ред, където n е броят на стойностите на levelOfDescriptionCode в ИСДА
        //        rowsExternal = await _context.LastNumbers.FromSqlRaw("EXECUTE dbo.sp_GetLastInventoryNumbers {0},{1},{2},{3}",
        //            _linkedServerSettings.LinkedServer!,
        //            archive,
        //            fundExternalIdentifier!,
        //            inventoryArrayExternal
        //        ).ToListAsync();

        //    }

        //    // тест
        //    //var rowsExternal = new List<Number>()
        //    //{
        //    //    new Number() { Num = "2A", LevelOfDescriptionCode = 2 },
        //    //    new Number() { Num = "2A", LevelOfDescriptionCode = 1 },
        //    //    new Number() { Num = "1А", LevelOfDescriptionCode = 2 },
        //    //    new Number() { Num = "1А", LevelOfDescriptionCode = 1 },
        //    //};

        //    DbFunctions? dbFunc = null;

        //    var inventoryArraysInternalCount = _dropdownService.GetInventoryArrays().Count();
        //    var rowsInternal = await _context.VInventories // Дали е това?
        //    .Where(i => i.ArchiveCode == archive && i.NumberArray == inventoryArray 
        //        && i.FundSystemIdentifier == fundSystemIdentifier
        //        && i.Deleted == false && !i.HasExternalSource!.Value && i.Number != null
        //        && dbFunc!.Like(i.Number, "[0-9]%")
        //        )
        //    .Select(i => new Number()
        //    {
        //        Num = i.Number,
        //        LevelOfDescriptionCode = int.Parse(i.DescriptionLevelCode!),
        //        Id = i.Id
        //    })
        //    .OrderByDescending(i => i.Id)
        //    .Take(inventoryArraysInternalCount)
        //    .ToListAsync();          

        //    // test
        //    //var rowsInternal = new List<Number>()
        //    //{
        //    //    new Number() { Num = "4", LevelOfDescriptionCode = 2 },
        //    //    new Number() { Num = "4", LevelOfDescriptionCode = 3 },
        //    //    new Number() { Num = "3", LevelOfDescriptionCode = 2 },
        //    //    new Number() { Num = "3", LevelOfDescriptionCode = 1 },
        //    //};

        //    if (rowsExternal.Count == 0 && rowsInternal.Count == 0)
        //    {
        //        return $"1{inventoryArray}";
        //    }

        //    int? intPart = null;
        //    if (rowsExternal.Count > 0 && rowsInternal.Count > 0)
        //    {
        //        var groupWithLastNumberExternal = rowsExternal.GroupBy(x => x.Num).First();
        //        var groupWithLastNumberInternal = rowsInternal.GroupBy(x => x.Num).First();
        //        IGrouping<string?, Number> groupWithLastNumber = groupWithLastNumberInternal;
        //        if (ExtractInt(groupWithLastNumberExternal.First().Num!) > ExtractInt(groupWithLastNumberInternal.First().Num!))
        //        {
        //            groupWithLastNumber = groupWithLastNumberExternal;
        //        }

        //        intPart = GetIntNumber(groupWithLastNumber, levelOfDescriptionCode);
        //        return intPart != null ? $"{intPart}{inventoryArray}" : string.Empty;
        //    }
        //    else if (rowsExternal.Count == 0 && rowsInternal.Count > 0)
        //    {
        //        var groupWithLastNumberInternal = rowsInternal.GroupBy(x => x.Num).First();
        //        IGrouping<string?, Number> groupWithLastNumber = groupWithLastNumberInternal;

        //        intPart = GetIntNumber(groupWithLastNumber, levelOfDescriptionCode);
        //        return intPart != null ? $"{intPart}{inventoryArray}" : string.Empty;
        //    }
        //    else if (rowsExternal.Count > 0 && rowsInternal.Count == 0)
        //    {
        //        var groupWithLastNumberExternal = rowsExternal.GroupBy(x => x.Num).First();
        //        IGrouping<string?, Number> groupWithLastNumber = groupWithLastNumberExternal;

        //        intPart = GetIntNumber(groupWithLastNumber, levelOfDescriptionCode);
        //        return intPart != null ? $"{intPart}{inventoryArray}" : string.Empty;
        //    }

        //    return string.Empty;
        //}

        //public async Task<int?> GetLastInventoryNumberExternal(
        //    int archive, int fundExternalIdentifier, string inventoryArray, int levelOfDescriptionCode)
        //{
        //    if (fundExternalIdentifier == -1)
        //    {
        //        return null;
        //    }

        //    var inventoryArrayExternal = inventoryArray;
        //    var inventoryArrayInternal = inventoryArray;
        //    //if (inventoryArray == "noIndex")
        //    //{
        //    //    inventoryArrayExternal = "Без индекс";
        //    //    inventoryArrayInternal = string.Empty;
        //    //    inventoryArray = string.Empty;
        //    //}

        //    List<Number> rowsExternal = new();

        //    // Взимат се последните n на брой реда, подредени в намаляващ ред, където n е броят на стойностите на levelOfDescriptionCode в ИСДА
        //    rowsExternal = await _context.LastNumbers.FromSqlRaw("EXECUTE dbo.sp_GetLastInventoryNumbers {0},{1},{2},{3}",
        //        _linkedServerSettings.LinkedServer!,
        //        archive,
        //        fundExternalIdentifier!,
        //        inventoryArrayExternal
        //    ).ToListAsync();

        //    if (rowsExternal.Count == 0)
        //    {
        //        //return $"1{(inventoryArray.Equals(_localizer.GetString("Fund_NumberArrayNoIndex").ToString(), StringComparison.OrdinalIgnoreCase) ? string.Empty : inventoryArray)}";
        //        return 1;
        //    }

        //    var groupWithLastNumberExternal = rowsExternal.GroupBy(x => x.Num).First();
        //    IGrouping<string?, Number> groupWithLastNumber = groupWithLastNumberExternal;

        //    var intPart = GetIntNumber(groupWithLastNumber, levelOfDescriptionCode);
        //    //return $"{intPart}{(inventoryArray.Equals(_localizer.GetString("Fund_NumberArrayNoIndex").ToString(), StringComparison.OrdinalIgnoreCase) ? string.Empty : inventoryArray)}";
        //    return intPart;
        //}

        public async Task<bool> IsValidInventoryNumber(
            int archiveId,
            Guid fundSystemIdentifier,
            int numberNumeric,
            string inventoryArray,
            string descriptionLevelCode,
            Guid? systemIdentifier = null)
        {

            bool numberValidationRequired = true;
            if (systemIdentifier.HasValue && systemIdentifier.Value != Guid.Empty)
            {
                numberValidationRequired = !await _context.VInventories
                                                    .Where(inv => inv.SystemIdentifier == systemIdentifier
                                                            && inv.NumberNumeric == numberNumeric
                                                            && inv.NumberArray == inventoryArray
                                                            && !inv.Deleted)
                                                    .AnyAsync();
            }

            bool numberExists = false;

            if (numberValidationRequired)
            {
                numberExists = await _context.VInventories
                            .Where(inv => inv.ArchiveId == archiveId
                                && inv.FundSystemIdentifier == fundSystemIdentifier
                                && inv.DescriptionLevelCode == descriptionLevelCode
                                && inv.NumberArray == inventoryArray
                                && inv.NumberNumeric == numberNumeric
                                && !inv.Deleted
                                && (!systemIdentifier.HasValue || (inv.SystemIdentifier != systemIdentifier.Value))
                                && (inv.HasExternalSource.HasValue && !inv.HasExternalSource.Value))
                            .AnyAsync();

                int? fundExternalIdentifier = await _context.VFunds
                                                    .Where(f => f.SystemIdentifier == fundSystemIdentifier
                                                            && !f.Deleted
                                                            && (f.HasExternalSource.HasValue && f.HasExternalSource.Value))
                                                    .Select(f => f.ExternalIdentifier)
                                                    .SingleOrDefaultAsync();

                if (!numberExists && fundExternalIdentifier.HasValue)
                {
                    var archiveCode = await _context.Archives
                                    .Where(a => a.Id == archiveId && a.Deleted == false)
                                    .Select(a => a.Code)
                                    .SingleAsync();

                    var externalSourceDescLevelCode = DescriptionLevelMapping.InventoryDescriptionLevel
                                                        .Where(map => map.Value == descriptionLevelCode)
                                                        .Select(map => map.Key).FirstOrDefault();

                    var externalInventoryArray = await _context.InventoryArrays
                                                        .Where(arr => arr.Code == inventoryArray)
                                                        .Select(arr => arr.ExternalSourceCode)
                                                        .SingleAsync();
                    try
                    {


                        string remoteQuery = "exec @ReturnValue = sp_CheckIfNewInventoryNumberIsValid @LinkedServer, @ArchiveCode, @FundExternalIdentifier, @NumberNumeric, @InventoryArray, @DescriptionLevel";
                        List<SqlParameter> remoteQueryParams = new List<SqlParameter>()
                        {
                            new SqlParameter("LinkedServer", _linkedServerSettings.LinkedServer),
                            new SqlParameter("ArchiveCode", archiveCode),
                            new SqlParameter("FundExternalIdentifier", fundExternalIdentifier.Value),
                            new SqlParameter("NumberNumeric", numberNumeric),
                            new SqlParameter("InventoryArray", !string.IsNullOrWhiteSpace(externalInventoryArray) ? externalInventoryArray : DBNull.Value),
                            new SqlParameter("DescriptionLevel", !string.IsNullOrWhiteSpace(externalSourceDescLevelCode) ? externalSourceDescLevelCode : DBNull.Value),

                        };
                        SqlParameter queryReturnValue = new SqlParameter()
                        {
                            ParameterName = "ReturnValue",
                            SqlDbType = System.Data.SqlDbType.Bit,
                            Direction = System.Data.ParameterDirection.Output
                        };
                        remoteQueryParams.Add(queryReturnValue);

                        await _context.Database.ExecuteSqlRawAsync(remoteQuery, remoteQueryParams.ToArray());

                        numberExists = !(bool)queryReturnValue.Value;
                    }
                    catch (Exception exc)
                    {
                        throw new ExternalConnectionException("Cannot validate inventory number", exc);
                    }
                }
            }

            return !numberExists;
        }

        //public async Task<string> GetNextArchivalEntityNumberExternal(int archive, int inventoryExternalIdentifier)
        //{
        //    List<Number> rowsExternal = new();
        //    if (inventoryExternalIdentifier != -1)
        //    {
        //        rowsExternal = await _context.LastNumbers.FromSqlRaw("EXECUTE dbo.sp_GetLastArchiveEntityNumbers {0},{1},{2}",
        //            _linkedServerSettings.LinkedServer!,
        //            archive,
        //            inventoryExternalIdentifier!
        //        ).ToListAsync();

        //    }
        //    else
        //    {
        //        return string.Empty;
        //    }

        //    if (rowsExternal.Count == 0)
        //    {
        //        return "1";
        //    } 
        //    else if (rowsExternal.Count == 1) 
        //    {
        //        var intPart = ExtractInt(rowsExternal.First().Num!);

        //        if (intPart != null)
        //        {
        //            return $"{intPart + 1}";
        //        }
        //    }

        //    return string.Empty;
        //}

        public async Task<int> GetArchivalEntityNumberNumeric(int archiveId, Guid inventorySystemIdentifier, string descriptionLevelCode)
        {
            int numberNumeric = 1;

            var inventoryExternalIdentifier = await _context.VInventories
                                            .Where(inv => inv.SystemIdentifier == inventorySystemIdentifier && (inv.HasExternalSource.HasValue && inv.HasExternalSource.Value) && !inv.Deleted)
                                            .Select(inv => inv.ExternalIdentifier)
                                            .SingleOrDefaultAsync();

            if (inventoryExternalIdentifier.HasValue)
            {
                try
                {
                    var archiveCode = await _context.Archives
                                            .Where(a => a.Id == archiveId && a.Deleted == false)
                                            .Select(a => a.Code)
                                            .SingleAsync();

                    var externalSourceDescLevelCode = DescriptionLevelMapping.ArchivalEntityDescriptionLevel
                                                        .Where(map => map.Value == descriptionLevelCode)
                                                        .Select(map => map.Key)
                                                        .FirstOrDefault();

                    string remoteQuery = "exec @ReturnValue = sp_GetLastArchivalEntityNumberNumeric @LinkedServer, @ArchiveCode, @InventoryIdentifier, @DescriptionLevelCode";
                    List<SqlParameter> remoteQueryParams = new List<SqlParameter>()
                    {
                        new SqlParameter("LinkedServer", _linkedServerSettings.LinkedServer),
                        new SqlParameter("ArchiveCode", archiveCode),
                        new SqlParameter("InventoryIdentifier", inventoryExternalIdentifier.Value),
                        new SqlParameter("DescriptionLevelCode", !string.IsNullOrWhiteSpace(externalSourceDescLevelCode) ? externalSourceDescLevelCode : DBNull.Value),
                    };
                    SqlParameter queryReturnValue = new SqlParameter()
                    {
                        ParameterName = "ReturnValue",
                        SqlDbType = System.Data.SqlDbType.Int,
                        Direction = System.Data.ParameterDirection.Output
                    };
                    remoteQueryParams.Add(queryReturnValue);

                    await _context.Database.ExecuteSqlRawAsync(remoteQuery, remoteQueryParams.ToArray());

                    int remoteNumberNumeric = (int)queryReturnValue.Value;
                    if (numberNumeric <= remoteNumberNumeric)
                    {
                        numberNumeric = remoteNumberNumeric + 1;
                    }
                }
                catch (Exception exc)
                {
                    _logger.LogWarning(exc, $"Error getting last generated number from external source (archiveId: {archiveId}, inventorySysId: {inventorySystemIdentifier}, descriptionLevel: {descriptionLevelCode})");
                    throw new ExternalConnectionException("Error getting last generated number numeric", exc);
                }
            }

            var localQuery = _context.VArchivalEntities
                                .Where(ae => ae.ArchiveId == archiveId
                                    && ae.InventorySystemIdentifier == inventorySystemIdentifier
                                    && ae.DescriptionLevelCode == descriptionLevelCode
                                    && !ae.Deleted
                                    && (ae.HasExternalSource.HasValue && !ae.HasExternalSource.Value));

            int? localNumberNumeric = await localQuery.MaxAsync(f => f.NumberNumeric);
            if (localNumberNumeric.HasValue && numberNumeric <= localNumberNumeric.Value)
            {
                numberNumeric = localNumberNumeric.Value + 1;
            }

            return numberNumeric;
        }

        public async Task<bool> IsValidArchivalEntityNumber(int archiveId, Guid inventorySystemIdentifier, string number, string descriptionLevelCode, Guid? systemIdentifier = null)
        {

            bool numberValidationRequired = true;
            if (systemIdentifier.HasValue && systemIdentifier.Value != Guid.Empty)
            {
                numberValidationRequired = !await _context.VArchivalEntities
                                                    .Where(ae => ae.SystemIdentifier == systemIdentifier
                                                            && ae.Number == number
                                                            && !ae.Deleted)
                                                    .AnyAsync();
            }

            bool numberExists = false;

            if (numberValidationRequired)
            {
                numberExists = await _context.VArchivalEntities
                            .Where(ae => ae.ArchiveId == archiveId
                                && ae.InventorySystemIdentifier == inventorySystemIdentifier
                                && ae.DescriptionLevelCode == descriptionLevelCode
                                && ae.Number == number
                                && !ae.Deleted
                                && (!systemIdentifier.HasValue || (ae.SystemIdentifier != systemIdentifier.Value))
                                && (ae.HasExternalSource.HasValue && !ae.HasExternalSource.Value))
                            .AnyAsync();

                int? inventoryExternalIdentifier = await _context.VInventories
                                                    .Where(inv => inv.SystemIdentifier == inventorySystemIdentifier
                                                            && !inv.Deleted
                                                            && (inv.HasExternalSource.HasValue && inv.HasExternalSource.Value))
                                                    .Select(inv => inv.ExternalIdentifier)
                                                    .SingleOrDefaultAsync();

                if (!numberExists && inventoryExternalIdentifier.HasValue)
                {
                    var archiveCode = await _context.Archives
                                    .Where(a => a.Id == archiveId && a.Deleted == false)
                                    .Select(a => a.Code)
                                    .SingleAsync();

                    var externalSourceDescLevelCode = DescriptionLevelMapping.ArchivalEntityDescriptionLevel
                                                        .Where(map => map.Value == descriptionLevelCode)
                                                        .Select(map => map.Key).FirstOrDefault();

                    try
                    {

                        string remoteQuery = "exec @ReturnValue = sp_CheckIfNewArchivalEntityNumberIsValid @LinkedServer, @ArchiveCode, @InventoryExternalIdentifier, @Number, @DescriptionLevel";
                        List<SqlParameter> remoteQueryParams = new List<SqlParameter>()
                        {
                            new SqlParameter("LinkedServer", _linkedServerSettings.LinkedServer),
                            new SqlParameter("ArchiveCode", archiveCode),
                            new SqlParameter("InventoryExternalIdentifier", inventoryExternalIdentifier.Value),
                            new SqlParameter("Number", number),
                            new SqlParameter("DescriptionLevel", !string.IsNullOrWhiteSpace(externalSourceDescLevelCode) ? externalSourceDescLevelCode : DBNull.Value),

                        };
                        SqlParameter queryReturnValue = new SqlParameter()
                        {
                            ParameterName = "ReturnValue",
                            SqlDbType = System.Data.SqlDbType.Bit,
                            Direction = System.Data.ParameterDirection.Output
                        };
                        remoteQueryParams.Add(queryReturnValue);

                        await _context.Database.ExecuteSqlRawAsync(remoteQuery, remoteQueryParams.ToArray());

                        numberExists = !(bool)queryReturnValue.Value;
                    }
                    catch (Exception exc)
                    {
                        throw new ExternalConnectionException("Cannot validate archival entity number", exc);
                    }
                }
            }

            return !numberExists;
        }

        public async Task<int> GetDocumentNumberNumeric(int archiveId, Guid inventorySystemIdentifier, string archivalEntitySystemIdentifier)
        {

            List<int> numbers = new();

            var stringhNumber = await _context.VDocuments
                                            .Where(d => d.ArchiveId == archiveId
                                                && d.InventorySystemIdentifier == inventorySystemIdentifier
                                                && d.ArchivalEntitySystemIdentifier == new Guid(archivalEntitySystemIdentifier)
                                                && !d.Deleted
                                                && !String.IsNullOrEmpty(d.Number)
                                                ).Select(d => d.Number).ToListAsync();

            foreach (var item in stringhNumber)
            {
                if (int.TryParse(item, out int number))
                {
                    numbers.Add(number);
                }
            }

            if (numbers.Any())
            {
                return numbers.Max() + 1;
            }

            return 1;

        }

        public async Task<bool> IsValidDocumentNumber(int archiveId, Guid inventorySystemIdentifier, Guid archivalEntitySystemIdentifier, string number, Guid? systemIdentifier)
        {

            bool numberValidationRequired = true;

            if (systemIdentifier.HasValue && systemIdentifier.Value != Guid.Empty)
            {
                numberValidationRequired = !await _context.VDocuments
                                                    .Where(ae => ae.SystemIdentifier == systemIdentifier
                                                            && ae.Number == number
                                                            && !ae.Deleted)
                                                    .AnyAsync();
            }

            bool numberExists = false;

            if (numberValidationRequired)
            {
                numberExists = await _context.VDocuments
                              .Where(d => d.ArchiveId == archiveId
                                  && d.InventorySystemIdentifier == inventorySystemIdentifier
                                  && d.ArchivalEntitySystemIdentifier == archivalEntitySystemIdentifier
                                  && d.Number == number
                                  && !d.Deleted
                                  && !String.IsNullOrEmpty(d.Number)
                                  && d.Number == number)
                                  .AnyAsync();
            }

            return !numberExists;
        }


        //private static int? ExtractInt(string str)
        //{
        //    if (!Regex.IsMatch(str, @"(^[0-9]+\D*)")) {
        //        return null;
        //    }

        //    var pattern = @"(\D)";
        //    return int.Parse(Regex.Replace(str, pattern, string.Empty));
        //}

        //private static int? GetIntNumber(IGrouping<string?, Number> groupWithLastNumber, int levelOfDescriptionCode)
        //{
        //    var matchedRow = groupWithLastNumber.SingleOrDefault(x => x.LevelOfDescriptionCode == levelOfDescriptionCode);
        //    int? intPart = null;
        //    if (matchedRow == null)
        //    {
        //        intPart = ExtractInt(groupWithLastNumber.First().Num!);
        //        return intPart;
        //    }
        //    else
        //    {
        //        intPart = ExtractInt(groupWithLastNumber.First().Num!);
        //        return intPart + 1;
        //    }
        //}
    }
}
