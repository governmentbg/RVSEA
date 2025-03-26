using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Extensions.Exceptions;
using DAA.Models;
using DAA.Models.Configuration;
using DAA.Services.Interfaces;
using DAA.Shared;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace DAA.Services
{

    public class DropdownService : BaseService, IDropdownService
    {
        private readonly LinkedServerSettings _settings;
        private readonly BusinessSettings _businessSettings;
        //FIX Тези променливи са безмислени. Има enum за тези цели.
        private readonly string _userTypeInternal = "INT";
        private readonly string _userProfileTypeEmployee = "EMP";
        private readonly string _fundArrayCodeB = "Б";
        private readonly string _fundArrayCodeV = "В";
        private readonly string _fundTypeGenus = "4";
        private readonly string _fundTypeFamily = "5";
        private readonly string _statusCodeRough = "10";
        private readonly string _statusCodeChangedName = "11";
        private readonly string _statusCodeProcessed = "13";
        private readonly string _statusCodeImproved = "3";
        private readonly string _statusCodeDeleted = "4";
        private readonly string _statusCodeRestored = "5";
        private readonly string _statusCodeRecreated = "8";
        private readonly string _statusCodeRebuilt = "9";
        private readonly string _statusCodeRenamed = "11";
        private readonly string _statusCodeDismissed = "12";
        private readonly string _statusCodeRegis = "2";
        private readonly string _statusCodeMoved = "14";
        private readonly string _statusCodeEdited = "7";
        private readonly string _statusCodeNew = "1";
        private const string _processTypeCodePreparationOfADigitalObject = "PreparationOfADigitalObject";
        private const string _processStepTypeCodePreparationOfADigitalObject = "PreparationOfADigitalObject";
        private const string _processStepTypeCodeQualityControl = "QualityControl";
        private const string _fundTypeCodePersonal = "3";
        private const string _fundTypeCodeInstitutional = "6";

        public DropdownService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            ILogger<DropdownService> logger,
            IOptions<LinkedServerSettings> settings,
            IOptions<BusinessSettings> businessSettings)
            : base(context, localizer, logger)
        {
            _settings = settings.Value;
            _businessSettings = businessSettings.Value;
        }

        public IQueryable<DropdownOption> GetArchives()
        {
            return _context.Archives
                    .Where(a => !a.Deleted)
                    .OrderBy(a => a.SortOrder)
                    .Select(a => new DropdownOption()
                    {
                        Id = a.Id,
                        Code = a.Code.ToString(),
                        Label = a.Name,
                    });
        }

        public async Task<IEnumerable<DropdownOption>> GetExternalSourceArchivesAsync()
        {
            try
            {
                var archives = await GetArchivesFromExternalSourceAsync();
                return archives
                        .OrderBy(a => a.SortOrder)
                        .Select(a => new DropdownOption()
                        {
                            Id = a.Id,
                            Code = a.Code.ToString(),
                            Label = a.Name,
                            HasExternalSource = true
                        });
            }
            catch (SqlException exc)
            {
                _logger.LogWarning(exc, $"{nameof(GetExternalSourceArchivesAsync)}: Cannot get archive list from external source");
                throw new ExternalConnectionException("Cannot get archives from external source", exc);
            }
            catch
            {
                throw;
            }
        }

        public async Task<IEnumerable<DropdownOption>> GetAllArchivesAsync(bool includeExternalSource = false)
        {
            List<Archive> archives = await _context.Archives
                                        .Where(a => !a.Deleted)
                                        .ToListAsync();
            if (includeExternalSource)
            {
                try
                {
                    archives.AddRange(await GetArchivesFromExternalSourceAsync());
                }
                catch (SqlException exc)
                {
                    _logger.LogWarning(exc, $"{nameof(GetAllArchivesAsync)}: Cannot get archives from external source");
                    throw new ExternalConnectionException("Cannot get archives from external source", exc);
                }
                catch
                {
                    throw;
                }
            }

            return archives
                    .OrderBy(a => a.SortOrder)
                    .Select(a => new DropdownOption()
                    {
                        Id = a.Id,
                        Code = a.Code.ToString(),
                        Label = a.Name,
                        HasExternalSource = a.Id == -1
                    });
        }

        private async Task<IEnumerable<Archive>> GetArchivesFromExternalSourceAsync()
        {
            string query = "exec sp_GetArchives @LinkedServer, @SearchText";
            List<SqlParameter> queryParams = new List<SqlParameter>()
            {
                new SqlParameter("LinkedServer", _settings.LinkedServer),
                new SqlParameter("SearchText", String.Empty),
            };
            var result = await _context.Archives
                    .FromSqlRaw(query, queryParams.ToArray())
                    .AsNoTracking()
                    .ToListAsync();

            return result;
        }

        public IQueryable<DropdownOption> GetRoles()
        {
            return _context.AspNetRoles
                        .Where(r => r.ArchiveId == null || !r.Archive!.Deleted)
                        .OrderBy(r => r.Name)
                        .Select(r => new DropdownOption()
                        {
                            Code = r.Id.ToString("D"),
                            Label = r.Name!,
                            GroupName = r.Archive!.Name
                        });
        }

        public IQueryable<DropdownOption> GetRolesInArchive(int archiveId, string[] roles)
        {
            return _context.AspNetRoles
                        .Where(r => r.ArchiveId == archiveId && (roles.Length == 0 || roles.Contains(r.Name)))
                        .OrderBy(r => r.Name)
                        .Select(r => new DropdownOption()
                        {
                            Code = r.Id.ToString("D"),
                            Label = r.Name!,
                            GroupName = r.Archive!.Name
                        });
        }

        public IQueryable<DropdownOption> GetStatuses()
        {
            return _context.Statuses
                    .OrderBy(s => s.SortOrder)
                    .Select(s => new DropdownOption()
                    {
                        Code = s.Code,
                        Label = s.Text,
                        ExternalIdentifier = s.ExternalIdentifier,
                    });
        }

        //FIX Да се ползва enum-a за статус!
        public IQueryable<DropdownOption> GetFundMemoriesReportStatuses() => GetStatuses()
          .Where(x => x.Code == _statusCodeRegis
                 || x.Code == _statusCodeMoved
                 || x.Code == _statusCodeEdited
                 || x.Code == _statusCodeRenamed
                 || x.Code == _statusCodeDismissed
             );

        //FIX Да се ползва enum-a за статус!
        public IQueryable<DropdownOption> GetStatusesReduced() => GetStatuses()
            .Where(x =>
                x.Code != _statusCodeRough
                && x.Code != _statusCodeProcessed
                && x.Code != _statusCodeImproved
                && x.Code != _statusCodeDeleted
                && x.Code != _statusCodeRestored
                && x.Code != _statusCodeRecreated
                && x.Code != _statusCodeRebuilt);

        //FIX Да се ползва enum-a за статус!
        public IQueryable<DropdownOption> GetStatusesReduced2() => GetStatuses()
            .Where(x =>
                x.Code != _statusCodeRough
                && x.Code != _statusCodeProcessed
                && x.Code != _statusCodeChangedName
                && x.Code != _statusCodeDeleted
                && x.Code != _statusCodeRestored
                && x.Code != _statusCodeRebuilt);

        //FIX Да се ползва enum-a за статус!
        public IQueryable<DropdownOption> GetRoughDocumentsStatuses() => GetStatuses()
            .Where(x => x.Code != _statusCodeProcessed
                && x.Code != _statusCodeImproved
                && x.Code != _statusCodeDeleted
                && x.Code != _statusCodeRestored
                && x.Code != _statusCodeRecreated
                && x.Code != _statusCodeRenamed
                && x.Code != _statusCodeDismissed
                && x.Code != _statusCodeRebuilt);

        public IQueryable<DropdownOption> GetAvailabilityStatuses()
        {
            return _context.AvailabilityStatuses
                    .OrderBy(s => s.SortOrder)
                    .Select(s => new DropdownOption()
                    {
                        Code = s.Code.ToString(),
                        Label = s.Text,
                    });
        }

        public IQueryable<DropdownOption> GetFundArrays()
        {
            return _context.FundArrays
                    .OrderBy(fa => fa.SortOrder)
                    .Select(fa => new DropdownOption()
                    {
                        Code = fa.Code,
                        Label = fa.Text,
                        ExternalIdentifier = fa.ExternalIdentifier,
                    });
        }

        public async Task<IEnumerable<DropdownOption>> GetAllFundArraysAsync(int reportResultType)
        {
            List<DropdownOption> fundArrays = new List<DropdownOption>();

            if (reportResultType == (int)Shared.ReportResultType.AllDB || reportResultType == (int)Shared.ReportResultType.InternalDB)
            {
                fundArrays = await GetFundArrays().ToListAsync();
            }
            //reportResultType == (int)Shared.ReportResultType.AllDB || 
            if (reportResultType == (int)Shared.ReportResultType.ExternalDB)
            {
                try
                {
                    fundArrays.AddRange(await GetNomenclatureFromExternalSourceAsync(NomenclatureTypeExternal.FundArray));
                }
                catch (SqlException exc)
                {
                    _logger.LogWarning(exc, $"{nameof(GetAllFundArraysAsync)}: Cannot get fund arrays from external source");
                    throw new ExternalConnectionException("Cannot get fund arrays from external source", exc);
                }
                catch
                {
                    throw;
                }
            }

            //if (reportResultType == (int)Shared.ReportResultType.AllDB)
            //{
            //    fundArrays.OrderBy(fa => fa.Label);
            //}

            return fundArrays;
        }

        //public IList<DropdownOption> GetFundArraysInternalAndExternal(int reportResultType)
        //{
        //    if (reportResultType == (int)Shared.ReportResultType.ExternalDB)
        //    {
        //        var externalList = GetNomenclatureExternalViaProcedure(NomenclatureTypeExternal.FundArray);

        //        return externalList.OrderBy(x => x.Label).ToList();
        //    }
        //    else if (reportResultType == (int)Shared.ReportResultType.InternalDB)
        //    {
        //        var internalList = GetFundArrays().ToList();
        //        internalList.ForEach(x => x.HasExternalSource = false);

        //        return internalList.OrderBy(x => x.Label).ToList();
        //    }

        //    var nomenclatureExternal = GetNomenclatureExternalViaProcedure(NomenclatureTypeExternal.FundArray);

        //    var nomenclatureInternal = GetFundArrays().ToList();
        //    nomenclatureInternal.ForEach(x => x.HasExternalSource = false);

        //    var nomenclature = nomenclatureExternal
        //       .Concat(nomenclatureInternal)
        //       .OrderBy(x => x.Label)
        //       .ToList();

        //    return nomenclature;

        //}

        public IQueryable<DropdownOption> GetFundArraysReduced()
        {
            var fundArrays = GetFundArrays().Where(fa => fa.Code != _fundArrayCodeB && fa.Code != _fundArrayCodeV);
            return fundArrays;
        }

        public async Task<IEnumerable<DropdownOption>> GetFundArraysInternalAndExternalReducedAsync(int reportResultType)
        {
            var fundArrays = await GetAllFundArraysAsync(reportResultType);
            return fundArrays.Where(x => x.Code != _fundArrayCodeB && x.Code != _fundArrayCodeV);
        }

        //public IList<DropdownOption> GetFundArraysInternalAndExternalReduced(int reportResultType) => GetFundArraysInternalAndExternal(reportResultType).Where(x => x.Code != _fundArrayCodeB && x.Code != _fundArrayCodeV).ToList();

        public IQueryable<DropdownOption> GetFundTypes()
        {
            return _context.FundTypes
                    .Where(x => x.Code != _fundTypeFamily && x.Code != _fundTypeGenus)
                    .OrderBy(ft => ft.SortOrder)
                    .Select(ft => new DropdownOption()
                    {
                        Code = ft.Code,
                        Label = ft.Text,
                        ExternalIdentifier = ft.ExternalIdentifier,
                    });
        }

        public IList<DropdownOption> GetFundTypesReduced() => GetFundTypes().Where(x => x.Code != _fundTypeFamily && x.Code != _fundTypeGenus).ToList();

        public IList<DropdownOption> GetFundTypesInternalAndExternal(int reportResultType)
        {
            try
            {
                if (reportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    var externalList = GetNomenclatureExternalViaProcedure(NomenclatureTypeExternal.FundType);

                    return externalList.OrderBy(x => x.Label).ToList();
                }
                else
                {
                    var internalList = GetFundTypes().ToList();
                    //internalList.ForEach(x => x.HasExternalSource = false);

                    return internalList.OrderBy(x => x.Label).ToList();
                }


                //var nomenclatureExternal = GetNomenclatureExternalViaProcedure(NomenclatureTypeExternal.FundType);

                //var nomenclatureInternal = GetFundTypes().ToList();
                //nomenclatureInternal.ForEach(x => x.HasExternalSource = false);

                //var nomenclature = nomenclatureExternal
                //    .Concat(nomenclatureInternal)
                //    .OrderBy(x => x.Label)
                //    .ToList();

                //return nomenclature;
            }
            catch (SqlException exc)
            {
                _logger.LogWarning(exc, $"{nameof(GetFundTypesInternalAndExternal)}: Cannot get fund types from external source");
                throw new ExternalConnectionException("Cannot get fund types from external source", exc);
            }
            catch
            {
                throw;
            }
        }

        public IList<DropdownOption> GetFundTypesInternalAndExternalReduced(int reportResultType) => GetFundTypesInternalAndExternal(reportResultType).Where(x => x.Code != _fundTypeFamily && x.Code != _fundTypeGenus).ToList();

        public IList<DropdownOption> GetFundStatusesInternal(int reportResultType)
        {
            return GetStatuses()
             .Where(x => x.Code != _statusCodeRebuilt
                && x.Code != _statusCodeNew
                && x.Code != _statusCodeDeleted
                && x.Code != _statusCodeRestored)
                .OrderBy(s => s.Label)
                .ToList();
        }

        public IList<DropdownOption> GetFundStatusesFundMemorieReport(int reportResultType)
        {
            var nomenclatureInternal = GetFundMemoriesReportStatuses().OrderBy(s => s.Label).ToList();
            return nomenclatureInternal;
        }
        public IList<DropdownOption> GetFundStatusesInternalAndExternal(int reportResultType)
        {
            try
            {
                if (reportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    var externalList = GetNomenclatureExternalViaProcedure(NomenclatureTypeExternal.Status);

                    return externalList.OrderBy(x => x.Label).ToList();
                }
                else
                {
                    var internalList = GetStatuses().OrderBy(x => x.Label).ToList();

                    internalList.ForEach(x => x.HasExternalSource = false);

                    return internalList;
                }
            }
            catch (SqlException exc)
            {
                _logger.LogWarning(exc, $"{nameof(GetFundStatusesInternalAndExternal)}: Cannot get fund statuses from external source");
                throw new ExternalConnectionException("Cannot get fund statuses from external source", exc);
            }
            catch
            {
                throw;
            }
        }

        public IQueryable<DropdownOption> GetFundDescriptionLevels()
        {
            return _context.FundDescriptionLevels
                    .OrderBy(fdl => fdl.SortOrder)
                    .Select(fdl => new DropdownOption()
                    {
                        Code = fdl.Code,
                        Label = fdl.Text,
                        ExternalIdentifier = fdl.ExternalIdentifier,
                    });
        }

        public IList<DropdownOption> GetDescriptionLevelsExternal() => GetNomenclatureExternalViaProcedure(NomenclatureTypeExternal.DescriptionLevel);

        public IQueryable<DropdownOption> GetInventoryArrays()
        {
            return _context.InventoryArrays
                    .OrderBy(ia => ia.SortOrder)
                    .Select(ia => new DropdownOption()
                    {
                        Code = ia.Code,
                        Label = ia.Text,
                        ExternalIdentifier = ia.ExternalIdentifier,
                    });
        }

        public IList<DropdownOption> GetInventoryArraysInternalAndExternal()
        {
            try
            {
                var inventoriesExternal = GetNomenclatureExternalViaProcedure(NomenclatureTypeExternal.InventoryArray);

                var inventoriesInternal = GetInventoryArrays().ToList();
                inventoriesInternal.ForEach(x => x.HasExternalSource = false);

                var inventories = inventoriesExternal
                    .ToList()
                    .Concat(inventoriesInternal)
                    .OrderBy(x => x.Label)
                    .ToList();

                return inventories;
            }
            catch (Exception ex)
            {
                return GetInventoryArrays().ToList();
            }
        }

        public IQueryable<DropdownOption> GetInventoryDescriptionLevels(int? fundDescriptionLevel = null)
        {
            var query = _context.InventoryDescriptionLevels.AsQueryable();

            if (fundDescriptionLevel.HasValue)
            {
                switch ((Shared.FundDescriptionLevel)fundDescriptionLevel.Value)
                {
                    case Shared.FundDescriptionLevel.Fund:
                        query = query.Where(idl => idl.Code != Shared.InventoryDescriptionLevel.SystemInventory.ToString("D"));
                        break;
                    case Shared.FundDescriptionLevel.RawFund:
                        query = query.Where(idl => idl.Code == Shared.InventoryDescriptionLevel.RawInventory.ToString("D"));
                        break;
                    case Shared.FundDescriptionLevel.ChP:
                    case Shared.FundDescriptionLevel.Memory:
                        query = query.Where(idl => idl.Code == Shared.InventoryDescriptionLevel.SystemInventory.ToString("D"));
                        break;
                }
            }

            return query
                    .OrderBy(idl => idl.SortOrder)
                    .Select(idl => new DropdownOption()
                    {
                        Code = idl.Code,
                        Label = idl.Text,
                        ExternalIdentifier = idl.ExternalIdentifier,
                    });

            //return _context.InventoryDescriptionLevels
            //        .OrderBy(idl => idl.SortOrder)
            //        .Select(idl => new DropdownOption()
            //        {
            //            Code = idl.Code,
            //            Label = idl.Text,
            //        });
        }

        //FIX защо изобщо е необходим подобен метод?
        public IQueryable<DropdownOption> GetAcquisitionMethods()
        {
            return GetNomenclatures(Shared.NomenclatureCode.AcquisitionMethod);
        }
        //WTF???
        public IList<DropdownOption> GetAcquisitionMethodsInternal()
        {
            var nomenclatureInternal = GetNomenclatures(Shared.NomenclatureCode.AcquisitionMethod).ToList();
            return nomenclatureInternal;
        }

        public IList<DropdownOption> GetAcquisitionMethodsInternalAndExternal(int reportResultType)
        {
            try
            {
                if (reportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    var externalList = GetNomenclatureExternalViaProcedure(NomenclatureTypeExternal.AcquisitionMethods);

                    return externalList.OrderBy(x => x.Label).ToList();
                }
                else if (reportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    var internalList = GetNomenclatures(Shared.NomenclatureCode.AcquisitionMethod).ToList();
                    internalList.ForEach(x => x.HasExternalSource = false);

                    return internalList.OrderBy(x => x.Label).ToList();
                }
                // var nomenclatureExternal = GetNomenclatureExternalViaProcedure(NomenclatureTypeExternal.AcquisitionMethods);

                var nomenclature = GetNomenclatures(Shared.NomenclatureCode.AcquisitionMethod).ToList();
                nomenclature.ForEach(x => x.HasExternalSource = false);

                return nomenclature;
            }
            catch (SqlException exc)
            {
                _logger.LogWarning(exc, $"{nameof(GetAcquisitionMethodsInternalAndExternal)}: Cannot get acquisitionMethods from external source");
                throw new ExternalConnectionException("Cannot get archives from external source", exc);
            }
            catch
            {
                throw;
            }
        }

        //public IQueryable<DropdownOption> GetProcessTypes(string? entityType = null)
        public IQueryable<DropdownOption> GetProcessTypes(string[]? entityType = null)
        {

            if (entityType == null)
            {

                return
                    _context.ProcessTypes
                    .OrderBy(p => p.Name)
                    .Select(p => new DropdownOption()
                    {
                        Id = p.Id,
                        Code = p.Code,
                        Label = p.Name
                    });
            }


            var res = _context.ProcessTypeLevels
                 .Where(lvl => (entityType == null || entityType.Contains(lvl.EntityType)) && !lvl.Inactive)
                 .OrderBy(lvl => lvl.ProcessType.Name)
                 .Select(lvl => new DropdownOption()
                 {
                     Id = lvl.ProcessTypeId,
                     Code = lvl.ProcessType.Code,
                     Label = lvl.ProcessType.Name
                 });

            return res;
        }

        public async Task<IEnumerable<DAA.Models.Funds.FundShortDisplayModel>> GetFunds(string searchText, int archiveCode, string[]? descriptionLevel)
        {

            string query = "exec sp_SearchFunds @LinkedServer, @ArchiveCode, @DescriptionLevel, @SearchText, @Limit";
            List<SqlParameter> queryParams = new List<SqlParameter>()
            {
                new SqlParameter("LinkedServer", _settings.LinkedServer),
                new SqlParameter("SearchText", searchText.Trim()),
                new SqlParameter("ArchiveCode", archiveCode),
                new SqlParameter("DescriptionLevel", descriptionLevel != null && descriptionLevel.Length > 0 ? string.Join(",", descriptionLevel) : DBNull.Value),
                new SqlParameter("Limit", 100),
            };
            var result = await _context.FundsBasicData
                    .FromSqlRaw(query, queryParams.ToArray())
                    .AsNoTracking()
                    .ToListAsync();

            return result.Select(f => new DAA.Models.Funds.FundShortDisplayModel()
            {
                Id = f.Id,
                SystemIdentifier = f.SystemIdentifier,
                IsDraft = f.IsDraft,
                ArchiveId = f.ArchiveId,
                ArchiveCode = f.ArchiveCode,
                ArchiveName = f.ArchiveName,
                ExternalIdentifier = f.ExternalIdentifier,
                HasExternalSource = f.HasExternalSource,
                NumberArray = f.NumberArray,
                Number = f.Number,
                Title = f.Title,
            });
        }

        public async Task<IEnumerable<DAA.Models.Inventories.InventoryShortDisplayModel>> GetInventories(
            string searchText,
            Guid? fundSysId,
            bool? fundHasExternalSource,
            int? fundExternalIdentifier,
            string[]? descriptionLevel)
        {
            string query = "exec sp_SearchInventories @LinkedServer, @FundSystemIdentifier, @FundHasExternalSource, @FundExternalIdentifier, @DescriptionLevel, @SearchText, @Limit";
            List<SqlParameter> queryParams = new List<SqlParameter>()
            {
                new SqlParameter("LinkedServer", _settings.LinkedServer),
                new SqlParameter("SearchText", searchText.Trim()),
                new SqlParameter("FundSystemIdentifier", fundSysId.HasValue ? fundSysId.Value : DBNull.Value),
                new SqlParameter("FundHasExternalSource", fundHasExternalSource.HasValue ? fundHasExternalSource.Value : DBNull.Value),
                new SqlParameter("FundExternalIdentifier", fundExternalIdentifier.HasValue ? fundExternalIdentifier.Value : DBNull.Value),
                new SqlParameter("DescriptionLevel", descriptionLevel != null && descriptionLevel.Length > 0 ? string.Join(",", descriptionLevel) : DBNull.Value),
                new SqlParameter("Limit", 100),
            };
            var result = await _context.InventoriesBasicData
                    .FromSqlRaw(query, queryParams.ToArray())
                    .AsNoTracking()
                    .ToListAsync();

            return result.Select(f => new DAA.Models.Inventories.InventoryShortDisplayModel()
            {
                Id = f.Id,
                SystemIdentifier = f.SystemIdentifier,
                IsDraft = f.IsDraft,
                ArchiveId = f.ArchiveId,
                ArchiveCode = f.ArchiveCode,
                ArchiveName = f.ArchiveName,
                FundDraftId = f.FundDraftId,
                FundSystemIdentifier = f.FundSystemIdentifier,
                FundExternalIdentifier = f.FundExternalIdentifier,
                FundHasExternalSource = f.FundHasExternalSource,
                FundNumber = f.FundNumber,
                ExternalIdentifier = f.ExternalIdentifier,
                HasExternalSource = f.HasExternalSource,
                NumberArray = f.NumberArray,
                Number = f.Number,
            });
        }

        public IQueryable<DropdownOption> GetNomenclatures(int? parentId = null)
        {
            var nomenclatures = _context.Nomenclatures
                .Where(n => n.ParentId == parentId && n.Inactive == false && n.Deleted == false)
                .OrderBy(n => n.SortOrder)
                .Select(n => new DropdownOption()
                {
                    Id = n.Id,
                    Code = n.Code,
                    Label = n.Text,
                    Description = n.Description,
                });
            return nomenclatures;
        }

        public IQueryable<DropdownOption> GetNomenclatures(string code)
        {
            var nomenclatures = _context.Nomenclatures
                .Where(n => n.Parent!.Code == code && n.Inactive == false && n.Deleted == false)
                .OrderBy(n => n.SortOrder)
                .Select(n => new DropdownOption()
                {
                    Id = n.Id,
                    Code = n.Code,
                    Label = n.Text,
                    Description = n.Description,
                    ExternalIdentifier = n.ExternalIdentifier,
                });
            return nomenclatures;
        }

        public IQueryable<DropdownOption> GetNomenclatureCodes()
        {
            var nomCodes = _context.NomenclatureCodes
                .OrderBy(nc => nc.SortOrder)
                .ThenBy(nc => nc.Text)
                .Select(nc => new DropdownOption()
                {
                    Code = nc.Code,
                    Label = nc.Text,
                    Description = nc.Description,
                });
            return nomCodes;
        }

        public IQueryable<DropdownOption> GetArchiveEntityDescriptionLevels()
        {
            return _context.ArchivalEntityDescriptionLevels
                    .OrderBy(aedl => aedl.SortOrder)
                    .Select(aedl => new DropdownOption()
                    {
                        Code = aedl.Code,
                        Label = aedl.Text,
                        ExternalIdentifier = aedl.ExternalIdentifier,
                    });
        }

        public IList<DropdownOption> GetArchiveEntityDescriptionLevelsInternalAndExternal()
        {
            try
            {
                var ArchiveEntityDescriptionLevelsExternal = GetNomenclatureExternalViaProcedure(NomenclatureTypeExternal.DescriptionLevel).Where(x => x.Code == "2174" || x.Code == "2371" || x.Code == "2373");
                var ArchiveEntityDescriptionLevelsInternal = GetArchiveEntityDescriptionLevels().ToList();

                ArchiveEntityDescriptionLevelsInternal.ForEach(x => x.HasExternalSource = false);

                var nomenclature = ArchiveEntityDescriptionLevelsExternal // тук се налага да се пресметне израза след взимане от базата, понеже "could not be translated"
                    .ToList()
                    .Concat(ArchiveEntityDescriptionLevelsInternal)
                    .OrderBy(x => x.Label)
                    .ToList();

                return nomenclature;
            }
            catch (Exception exc)
            {
                return GetArchiveEntityDescriptionLevels().ToList();
            }
        }

        public IQueryable<DropdownOption> GetDocumentDescriptionLevels()
        {
            return _context.DocumentDescriptionLevels
                    .OrderBy(fdl => fdl.SortOrder)
                    .Select(fdl => new DropdownOption()
                    {
                        Code = fdl.Code,
                        Label = fdl.Text,
                        ExternalIdentifier = fdl.ExternalIdentifier,
                    });
        }

        public IQueryable<DropdownOption> GetCentralArchive()
        {
            int code = _businessSettings.CentralArchiveCode.HasValue ? _businessSettings.CentralArchiveCode.Value : 0;
            return _context.Archives
                    .Where(a => !a.Deleted && a.Code == code)
                    .Select(a => new DropdownOption()
                    {
                        Id = a.Id,
                        Code = a.Code.ToString(),
                        Label = a.Name,
                    });
        }


        public IQueryable<DropdownOption> GetApplicationTypes()
        {
            var culture = Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName;
            return _context.EdocsCollectingApplicationTypes
                    //.Where(a => !a.Deleted)
                    .Select(a => new DropdownOption()
                    {
                        Code = a.Code,
                        //Label = culture == "en" ? a.TextEn : a.Text,
                        Label = a.Text
                    });
        }

        public IQueryable<DropdownOption> GetIndustryIndexes() => GetNomenclatures(Shared.NomenclatureCode.IndustryType);

        public IList<DropdownOption> GetIndustryIndexesInternalAndExternal(int reportResultType)
        {
            try
            {
                if (reportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    var externalList = GetNomenclatureExternalViaProcedure(NomenclatureTypeExternal.IndustryIndex);

                    return externalList.OrderBy(x => x.Label).ToList();
                }
                else
                {
                    var internalList = GetIndustryIndexes().ToList();
                    // internalList.ForEach(x => x.HasExternalSource = false);

                    return internalList.OrderBy(x => x.Label).ToList();
                }

                //var nomenclature = GetIndustryIndexes().ToList();
                //nomenclature.ForEach(x => x.HasExternalSource = false);

                //return nomenclature;
            }
            catch (SqlException exc)
            {
                _logger.LogWarning(exc, $"{nameof(GetIndustryIndexesInternalAndExternal)}: Cannot get public IndexesInternal  from external source");
                throw new ExternalConnectionException("Cannot get public IndexesInternal  from external source", exc);
            }
            catch
            {
                throw;
            }
        }

        public IQueryable<DropdownOption> GetReportResultTypes()
        {
            return _context.ReportResultTypes
                    .Select(rt => new DropdownOption()
                    {
                        Code = rt.Code,
                        Label = rt.Text,
                    });
        }


        private async Task<IEnumerable<DropdownOption>> GetNomenclatureFromExternalSourceAsync(string type)
        {
            string query = "exec sp_GetNomenclatureByType @LinkedServer, @Type";
            List<SqlParameter> queryParams = new()
            {
                new SqlParameter("LinkedServer", _settings.LinkedServer),
                new SqlParameter("Type", type)
            };

            var remoteNomenclature = await _context.RemoteNomenclatures
                    .FromSqlRaw(query, queryParams.ToArray())
                    .AsNoTracking()
                    .ToListAsync();

            return remoteNomenclature.Select(fa => new DropdownOption()
            {
                Code = fa.Gid.ToString(),
                Label = fa.Name,
                HasExternalSource = true,
            });
        }

        private IList<DropdownOption> GetNomenclatureExternalViaProcedure(string type)
        {
            string sql = "exec sp_GetNomenclatureByType @LinkedServer, @Type";
            List<SqlParameter> queryParams = new()
            {
                new SqlParameter("LinkedServer", _settings.LinkedServer),
                new SqlParameter("Type", type)
            };
            var nomenclature = _context.RemoteNomenclatures
                    .FromSqlRaw(sql, queryParams.ToArray())
                    .AsNoTracking()
                    .AsEnumerable() // Цялата заявка не може да се изпълни на сървъра, затова се слага този ред
                    .Select(x => new DropdownOption()
                    {
                        Code = x.Gid.ToString(),
                        Label = x.Name,
                        HasExternalSource = true,
                    })
                    .ToList();

            return nomenclature;
        }

        public IQueryable<DropdownOption> GetCollectingProcedures()
        {
            return _context.ProcessTypes.Select(x => new DropdownOption { Id = x.Id, Label = x.Name });
        }

        public IList<DropdownOption> GetProcessTypesInternalAndExternal(int reportResultType)
        {
            try
            {
                if (reportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    var externalList = GetNomenclatureExternalViaProcedure(NomenclatureTypeExternal.Process);

                    return externalList.OrderBy(x => x.Label).ToList();
                }
                else if (reportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    var internalList = _context.ProcessTypes
                          .Select(x => new DropdownOption()
                          {
                              Code = x.Id.ToString(), // фронтендът по принцип ползва Code вместо Id
                              Label = x.Name,
                              HasExternalSource = false,
                          })
                          .OrderBy(x => x.Label)
                          .ToList();

                    return internalList;
                }
                else
                {
                    var nomenclatureExternal = GetNomenclatureExternalViaProcedure(NomenclatureTypeExternal.Process);

                    var nomenclatureInternal = _context.ProcessTypes
                        .Select(x => new DropdownOption()
                        {
                            Code = x.Id.ToString(),
                            Label = x.Name,
                            ExternalIdentifier = x.ExternalIdentifier,
                        })
                        .OrderBy(x => x.Label)
                        .ToList();

                    /////nomenclatureInternal.ForEach(x => x.HasExternalSource = false);

                    //var nomenclature = nomenclatureExternal // тук се налага да се пресметне израза след взимане от базата, понеже "could not be translated"
                    //    .ToList()
                    //    .Concat(nomenclatureInternal)
                    //    .OrderBy(x => x.Label)
                    //    .ToList();

                    return nomenclatureInternal;
                }
            }
            catch (SqlException exc)
            {
                if (reportResultType == 1 || reportResultType == 2)
                {
                    _logger.LogWarning(exc, $"{nameof(GetProcessTypesInternalAndExternal)}: Cannot get ProcessTypes from external source");
                    throw new ExternalConnectionException("Cannot get ProcessTypes from external source", exc);
                }
                throw;
            }
            catch
            {
                throw;
            }
        }

        public IQueryable<DropdownOption> GetFilmDocTypes(string packageType)
        {
            return _context.FilmDocumentTypes
                .Where(x => x.PackageType == packageType)
                .OrderByDescending(x => x.IsRequired).ThenBy(x => x.Text)
                .Select(x => new DropdownOption()
                {
                    Id = x.Id,
                    Code = x.Code,
                    Label = x.IsRequired ? x.Text + "*" : x.Text,
                });
        }

        public IQueryable<DropdownOption> GetFilmPackageBDocs(string filmSysId)
        {
            Guid filmGuid = new Guid(filmSysId);

            var film = _context.VFilms
                .Where(x => x.SystemIdentifier == filmGuid && !x.Deleted)
                .FirstOrDefault();

            var docs = _context.FilmPackageDocuments
                .Include(x => x.DocumentType)
                .Where(x => x.PackageId == film!.PackageBid && !x.Deleted)
                .Select(x => new DropdownOption()
                {
                    Id = x.Id,
                    Code = x.Id.ToString(),
                    Label = $"{x.DocumentType.Text} / {x.FileName} / {(String.IsNullOrWhiteSpace(x.Description) || x.Description.Length <= 100 ? $"{x.Description}" : $"{x.Description.Substring(0, 97)}...")}",
                });

            return docs;
        }

        public async Task<List<DropdownOption>> GetUnusedFilmPackageBDocs(string filmSysId, Guid cardSysId)
        {
            Guid filmGuid = new Guid(filmSysId);

            // get film package B info
            var film = await _context.VFilms
                .Where(x => x.SystemIdentifier == filmGuid && !x.Deleted)
                .FirstOrDefaultAsync();

            // get all package B docs
            var docs = await _context.FilmPackageDocuments
                .Include(x => x.DocumentType)
                .Where(x => x.PackageId == film!.PackageBid && !x.Deleted)
                .ToListAsync();

            List<int> docIds = docs.Select(x => x.Id).ToList();

            // find cards and card drafts using these docs
            var cardsUsingDocuments = await _context.FilmCardDocuments
                .Where(x => docIds.Contains(x.PackageDocumentId))
                .ToListAsync();

            var cardIds = cardsUsingDocuments.Where(x => !x.IsDraft).Select(x => x.CardId).ToList();
            var cardDraftIds = cardsUsingDocuments.Where(x => x.IsDraft).Select(x => x.CardId).ToList();

            // filter only active card drafts
            var activeDraftCards = await _context.FilmCardDrafts
                .Where(x => cardDraftIds.Contains(x.Id) && x.SystemIdentifier != cardSysId && !x.Deleted && x.IsCurrent)
                .ToListAsync();

            var activeDraftCardIds = activeDraftCards.Select(x => x.Id).ToList();

            // filter active cards
            var activeCards = await _context.FilmCards
                .Where(x => cardIds.Contains(x.Id) && x.SystemIdentifier != cardSysId && !x.Deleted)
                .ToListAsync();

            var activeCardsSysIds = activeCards.Select(x => x.SystemIdentifier).ToList();

            // skip active cards with active deleted draft!
            var deletedCards = await _context.FilmCardDrafts
                .Where(x => activeCardsSysIds.Contains(x.SystemIdentifier) && x.Deleted && x.IsCurrent)
                .Select(x => x.SystemIdentifier)
                .ToListAsync();
            activeCardsSysIds = activeCardsSysIds.Where(x => !deletedCards.Contains(x)).ToList();

            // skip active cards with active draft 
            var editedCards = await _context.FilmCardDrafts
                .Where(x => activeCardsSysIds.Contains(x.SystemIdentifier) && x.IsCurrent && activeDraftCardIds.Contains(x.Id))
                .Select(x => x.SystemIdentifier)
                .ToListAsync();
            activeCardsSysIds = activeCardsSysIds.Where(x => !editedCards.Contains(x)).ToList();

            // filtered active cards list
            activeCards = activeCards.Where(x => activeCardsSysIds.Contains(x.SystemIdentifier)).ToList();
            var activeCardIds = activeCards.Select(x => x.Id).ToList();

            // remove used docs from list
            var usedDocsIds = cardsUsingDocuments
                .Where(x =>
                (activeDraftCardIds.Contains(x.CardId) && x.IsDraft) ||
                (activeCardIds.Contains(x.CardId) && !x.IsDraft))
                .Select(x => x.PackageDocumentId)
                .ToList();

            var finalDocsList = docs
                .Where(x => !usedDocsIds.Contains(x.Id))
                .Select(x => new DropdownOption()
                {
                    Id = x.Id,
                    Code = x.Id.ToString(),
                    Label = $"{x.DocumentType.Text} / {x.FileName} / {(String.IsNullOrWhiteSpace(x.Description) || x.Description.Length <= 100 ? $"{x.Description}" : $"{x.Description.Substring(0, 97)}...")}",
                })
                .ToList();

            return finalDocsList;
        }

        public IQueryable<DropdownOption> GetUsersInRoles(int archiveId, string[] roles)
        {
            var result = _context.AspNetUsers
                .Join(
                    _context.AspNetUserProfiles,
                    user => user.Id,
                    userProfile => userProfile.UserId,
                    (user, userProfile) => new { User = user, UserProfile = userProfile })
                .Where(x => !x.User.Deleted &&
                    (roles.Length == 0 ||
                    x.User.Roles.Where(r => roles.Contains(r.Name) &&
                                ((archiveId == 0 && !r.ArchiveId.HasValue) ||
                                 (archiveId > 0 && r.ArchiveId.HasValue && r.ArchiveId.Value == archiveId)
                                 )).Count() > 0))
                .OrderBy(x => x.UserProfile.DisplayName)
                .Select(x => new DropdownOption()
                {
                    Code = x.User.Id.ToString(),
                    Label = $"{x.UserProfile.DisplayName}",
                });


            return result;
        }

        public IQueryable<DropdownOption> GetUsersInRolesAllArchives(string[] roles)
        {
            var result = _context.AspNetUsers
                .Join(
                    _context.AspNetUserProfiles,
                    user => user.Id,
                    userProfile => userProfile.UserId,
                    (user, userProfile) => new { User = user, UserProfile = userProfile })
                .Where(x => !x.User.Deleted &&
                    (roles.Length == 0 ||
                    x.User.Roles.Where(r => roles.Contains(r.Name)).Count() > 0))
                .OrderBy(x => x.User.UserName)
                .Select(x => new DropdownOption()
                {
                    Code = x.User.Id.ToString(),
                    Label = $"{x.User.UserName} ({x.UserProfile.DisplayName})",
                });


            return result;
        }
        public IQueryable<DropdownOption> GetCommissionSessions(int archiveId)
        {
            return _context.Sessions
                .Where(s =>
                    s.ArchiveId == archiveId
                    && s.SessionDate.Date >= DateTime.UtcNow.Date
                    && !s.Deleted
                    && (!s.MinutesOfMeetingId.HasValue
                        || s.MinutesOfMeeting!.Status == Shared.MinutesOfMeetingStatus.New))
                .OrderBy(s => s.SessionDate)
                .Select(s => new DropdownOption()
                {
                    Id = s.Id,
                    Code = s.Id.ToString(),
                    Label = s.SessionDate.UtcToLocalTime().ToShortDateString(),
                });

        }

        //FIX защо изобщо е необходим подобен метод?
        public IList<DropdownOption> GetFileFormats()
        {
            return GetNomenclatures(Shared.NomenclatureCode.FileType).ToList();
        }

        //FIX: защо е нужен този метод, след като е абсолюно същия като GetArchives?
        public IQueryable<DropdownOption> GetPublicArchives()
        {
            return _context.Archives
                  .Where(a => !a.Deleted)
                  .OrderBy(a => a.SortOrder)
                  .Select(a => new DropdownOption()
                  {
                      Id = a.Id,
                      Code = a.Code.ToString(),
                      Label = a.Name,
                  });
        }

        public IList<DropdownOption> GetEmployeeNamesExternalViaProcedure()
        {
            string sql = "exec sp_GetUsers @LinkedServer";
            List<SqlParameter> queryParams = new()
            {
                new SqlParameter("LinkedServer", _settings.LinkedServer),
            };

            var employeeNames = _context.RemoteUsers
                                        .FromSqlRaw(sql, queryParams.ToArray())
                                        .AsNoTracking()
                                        .AsEnumerable()
                                        .OrderBy(u => u.Name)
                                        .Select(x => new DropdownOption()
                                        {
                                            Code = x.Gid.ToString(),
                                            Label = x.Name,
                                            HasExternalSource = true,
                                        })
                                        .ToList();
            return employeeNames;
        }
        public IList<DropdownOption> GetEmployeeNamesInternalAndExternal(int reportResultType)
        {
            try
            {
                if (reportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    var externalList = GetEmployeeNamesExternalViaProcedure();

                    return externalList.OrderBy(x => x.Label).ToList();
                }
                else if (reportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    return _context.AspNetUsers
                        .Join(
                            _context.AspNetUserProfiles,
                            user => user.Id,
                            userProfile => userProfile.UserId,
                            (user, userProfile) => new { User = user, UserProfile = userProfile })
                        .Where(x => x.User.UserType == _userTypeInternal && x.UserProfile.ProfileType == _userProfileTypeEmployee)
                         .Select(x => new DropdownOption()
                         {
                             Code = x.User.Id.ToString(),
                             Label = x.UserProfile.DisplayName,
                             HasExternalSource = false,
                         })
                         .OrderBy(x => x.Label)
                         .ToList();

                }
                else
                {
                    var employeeNamesExternal = GetEmployeeNamesExternalViaProcedure();
                    //Заявката е грешна - това ще зареди абсолютно всички потребители на системата.
                    var employeeNamesInternal = _context.AspNetUsers
                                                        .Join(
                                                            _context.AspNetUserProfiles,
                                                            user => user.Id,
                                                            userProfile => userProfile.UserId,
                                                            (user, userProfile) => new { User = user, UserProfile = userProfile })
                                                       .Where(x => x.User.UserType == _userTypeInternal && x.UserProfile.ProfileType == _userProfileTypeEmployee)
                                                       .Select(x => new DropdownOption()
                                                       {
                                                           Code = x.User.Id.ToString(),
                                                           Label = x.UserProfile.DisplayName,
                                                       })
                                                       .ToList();
                    employeeNamesInternal.ForEach(x => x.HasExternalSource = false);

                    var employeeNames = employeeNamesExternal // тук се налага да се пресметне израза след взимане от базата, понеже "could not be translated"
                        .ToList()
                        .Concat(employeeNamesInternal)
                        .OrderBy(x => x.Label)
                        .ToList();

                    return employeeNames;
                }
            }
            catch (SqlException exc)
            {
                if (reportResultType == 1 || reportResultType == 2)
                {
                    _logger.LogWarning(exc, $"{nameof(GetEmployeeNamesInternalAndExternal)}: Cannot get employee names  from external source");
                    throw new ExternalConnectionException(" Cannot get employee names  from external source", exc);
                }
                throw;
            }
            catch
            {
                throw;
            }
        }

        public IList<DropdownOption> GetEmployeeNamesInternal()
        {
            return _context.AspNetUsers
                           .Join(
                                _context.AspNetUserProfiles,
                                user => user.Id,
                                userProfile => userProfile.UserId,
                                (user, userProfile) => new { User = user, UserProfile = userProfile })
                           .Where(x => x.UserProfile.ProfileType == ApplicationUserProfileType.Employee)
                           .Select(x => new DropdownOption()
                           {
                               Code = x.User.Id.ToString(),
                               Label = x.UserProfile.DisplayName,
                           })
                           .ToList();
        }

        public IQueryable<DropdownOption> GetAssignedToUserApplications(Guid userId, string? applicationType = null, Guid? inventorySysId = null, int? archiveId = null)
        {
            var applications = from a in _context.EdocsCollectingApplications
                               let profile = a.CreatedByNavigation.AspNetUserProfileUsers.FirstOrDefault()
                               let organization = profile != null ? a.Organization : null
                               where a.AssignToUserId == userId
                                  && (a.StatusId == (int)ApplicationStatus.Approved || (inventorySysId.HasValue && _context.VInventories.Where(inv => inv.SystemIdentifier == inventorySysId && !inv.Deleted).Select(inv => inv.ApplicationId).Contains(a.Id)))
                                  && (string.IsNullOrEmpty(applicationType) || a.Type == applicationType)
                                  && !a.Deleted
                                  && (!archiveId.HasValue || a.ArchiveId == archiveId)
                               orderby a.Number
                               select new DropdownOption()
                               {
                                   Id = a.Id,
                                   Label = a.Number.ToString() + " / " + a.CreatedOn.Value.ToString("dd.MM.yyyy") + " " + profile.DisplayName + (organization != null ? " (" + organization + ")" : "")
                               };



            return applications;
        }

        public IQueryable<DropdownOption> GetReaderProfiles()
        {
            var result = _context.AspNetUserProfiles
                    .Where(p => p.ProfileType == ApplicationUserProfileType.ReaderInReadingRoom && p.Deleted == false)
                    .OrderBy(p => p.CreatedOn)
                    .Select(p => new DropdownOption()
                    {
                        Code = _context.AspNetUsers
                                       .Where(u => u.Id == p.UserId)
                                       .Select(u => u.Id)
                                       .FirstOrDefault()
                                       .ToString(),
                        Label = p.DisplayName.ToString(),
                    });

            return result;
        }

        public IQueryable<DropdownOption> GetAllFilms()
        {
            var result = _context.Films
                        .Where(f => f.Deleted == false)
                        .OrderBy(f => f.SystemIdentifier.ToString())
                        .Select(f => new DropdownOption()
                        {
                            Code = f.SystemIdentifier.ToString(),
                            Label = $"{_context.Nomenclatures.Where(n => n.Id == f.CountryId).Select(n => n.Text).FirstOrDefault()} - {f.InventoryNumber} ({f.SystemIdentifier.ToString()})",
                        });

            return result;
        }

        public IList<DropdownOption> GetAllDescriptionLevelsExternalAndInternal(bool getOnlyInternal = false)
        {
            int ResultType = 1;
            if (getOnlyInternal)
            {
                ResultType = 3;
            }
            string sql = "exec sp_GetAllDescriptionLevelsInOrder @LinkedServer, @ResultType";
            List<SqlParameter> queryParams = new()
            {
                new SqlParameter("LinkedServer", _settings.LinkedServer),
                new SqlParameter("ResultType", ResultType),
            };

            var descLevels = _context.AllDescriptionLevelsInOrder
                    .FromSqlRaw(sql, queryParams.ToArray())
                    .AsNoTracking()
                    .AsEnumerable() // Цялата заявка не може да се изпълни на сървъра, затова се слага този ред
                    .Select(x => new DropdownOption()
                    {
                        Code = x.Code,
                        Label = x.Label,
                        HasExternalSource = x.HasExternalSource,
                    })
                    .ToList();

            var extra = new List<DropdownOption>() {
                new DropdownOption()
                {
                Code = "fc_" + 0,
                Label = "КМФ картон"
                }};

            var finalDescLevels = descLevels.ToList().Concat(extra).ToList();

            return finalDescLevels;
        }

        //public IList<DropdownOption> GetAllPublicDescriptionLevels()
        //{
        //    const int ResultType = 1; //от 2 те системи
        //    string sql = "exec sp_GetAllPublicDescriptionLevels @LinkedServer, @ResultType";
        //    List<SqlParameter> queryParams = new()
        //    {
        //        new SqlParameter("LinkedServer", _settings.LinkedServer),
        //        new SqlParameter("ResultType", ResultType),
        //    };

        //    var descLevels = _context.AllDescriptionLevelsInOrder
        //            .FromSqlRaw(sql, queryParams.ToArray())
        //            .AsNoTracking()
        //            .AsEnumerable()
        //            .Select(x => new DropdownOption()
        //            {
        //                Code = x.Code,
        //                Label = x.Label,
        //                HasExternalSource = x.HasExternalSource,
        //            })
        //            .ToList();

        //    var extra = new List<DropdownOption>() {
        //        new DropdownOption()
        //        {
        //        Code = "fc_" + 0,
        //        Label = "КМФ картон"
        //        }};

        //    var finalDescLevels = descLevels.ToList().Concat(extra).ToList();

        //    return finalDescLevels;
        //}

        public async Task<IEnumerable<DropdownOption>> GetAllPublicDescriptionLevelsAsync(int resultType = 1)
        {
            //TODO: Това да се документира като enum!
            //const int ResultType = 1; //от 2 те системи
            try
            {
                string sql = "exec sp_GetAllPublicDescriptionLevels @LinkedServer, @ResultType";
                List<SqlParameter> queryParams = new()
                {
                    new SqlParameter("LinkedServer", _settings.LinkedServer),
                    new SqlParameter("ResultType", resultType),
                };

                var descriptionLevels = await _context.AllDescriptionLevelsInOrder
                        .FromSqlRaw(sql, queryParams.ToArray())
                        .AsNoTracking()
                        .ToListAsync();

                descriptionLevels.Add(new AllDescriptionLevelsInOrder
                {
                    Code = "fc_" + 0,
                    Label = "КМФ картон"
                });

                return descriptionLevels.Select(dl => new DropdownOption()
                {
                    Code = dl.Code,
                    Label = dl.Label,
                    HasExternalSource = dl.HasExternalSource,
                });
            }
            catch (SqlException exc)
            {
                if (resultType == 1 || resultType == 2)
                {
                    _logger.LogWarning(exc, $"{nameof(GetAllPublicDescriptionLevelsAsync)}: Cannot get public description levels from external source");
                    throw new ExternalConnectionException("Cannot get public description levels from external source", exc);
                }
                throw;
            }
            catch
            {
                throw;
            }

        }

        public IList<DropdownOption> GetFundInventoryAEDocumentDescriptionLevelsExternalAndInternal(int reportResultType)
        {
            try
            {
                if (reportResultType == (int)Shared.ReportResultType.ExternalDB)
                {
                    var externalDescLevel = GetDescriptionLevelsExternal()
                        .Select(x => new DropdownOption()
                        {
                            Code = x.Code + "_ext",
                            Label = x.Label,

                        }).OrderBy(x => x.Label)
                        .ToList();

                    return externalDescLevel;

                }
                if (reportResultType == (int)Shared.ReportResultType.InternalDB)
                {
                    var intranetsDesLevel = GetFundInventoryAEDocumentDescriptionLevelsInternal(false);

                    return intranetsDesLevel
                        .OrderBy(x => x.Label)
                        .ToList();
                }
                else
                {
                    var intranetsDesLevel = GetFundInventoryAEDocumentDescriptionLevelsInternal();

                    return intranetsDesLevel
                         .OrderBy(x => x.Label)
                         .ToList();
                }
            }
            catch (Exception ex)
            {
                return GetFundInventoryAEDocumentDescriptionLevelsInternal();

            }
        }

        private IList<DropdownOption> GetFundInventoryAEDocumentDescriptionLevelsInternal(bool showCMFInventoryAndArchEntDescLevel = true)
        {

            var fundIntranetsDesLevel = GetFundDescriptionLevels()
               .Select(x => new DropdownOption()
               {
                   Code = "fund_" + x.Code,
                   Label = x.Label,
                   ExternalIdentifier = x.ExternalIdentifier,
               }).ToList();

            var inventIntranetsDesLevel = GetInventoryDescriptionLevels()
            .Select(x => new DropdownOption()
            {
                Code = "inv_" + x.Code,
                Label = x.Label,
                ExternalIdentifier = x.ExternalIdentifier,
            }).ToList();

            var archIntranetsDesLevel = GetArchiveEntityDescriptionLevels()
               .Select(x => new DropdownOption()
               {
                   Code = "ae_" + x.Code,
                   Label = x.Label,
                   ExternalIdentifier = x.ExternalIdentifier,
               }).ToList();

            var docs = GetDocumentDescriptionLevels()
            .Select(x => new DropdownOption()
            {
                Code = "doc_" + x.Code,
                Label = x.Label,
                ExternalIdentifier = x.ExternalIdentifier,
            }).ToList();

            var films = showCMFInventoryAndArchEntDescLevel
                ?
                _context.FilmDescriptionLevels
                 .OrderBy(fdl => fdl.SortOrder)
                 .Select(fdl => new DropdownOption()
                 {
                     Code = "film_" + fdl.Code,
                     Label = fdl.Text,
                     ExternalIdentifier = fdl.ExternalIdentifier,
                 })
               :
                  _context.FilmDescriptionLevels
                  .Where(fld => fld.Code != "-2" && fld.Code != "-1")
                 .OrderBy(fdl => fdl.SortOrder)
                 .Select(fdl => new DropdownOption()
                 {
                     Code = "film_" + fdl.Code,
                     Label = fdl.Text,
                     ExternalIdentifier = fdl.ExternalIdentifier,
                 });

            return fundIntranetsDesLevel.Concat(inventIntranetsDesLevel).Concat(archIntranetsDesLevel).Concat(docs).Concat(films)
                .ToList();
        }

        public IQueryable<DropdownOption> GetProcessesSteps()
        {
            //FIX Текста да се изнесе в ресурсен файл!
            //var result = _context.ProcessSteps
            //                     .OrderBy(ps => ps.Text)
            //                     .Select(ps => new DropdownOption()
            //                     {
            //                         Code = ps.Id.ToString(),
            //                         Label = $"Стъпка '{ps.Text}' в процес '{_context.ProcessTypes.Where(pt => pt.Id == ps.ProcessTypeId).Select(pt => pt.Name).FirstOrDefault()}'"
            //                     });
            var result = _context.ProcessSteps
                .Where(x => x.AllowTaskTemplate == true)
                .OrderBy(step => step.ProcessTypeId)
                .ThenBy(step => step.Text)
                .Select(ps => new DropdownOption()
                {
                    Id = ps.Id,
                    Code = ps.Id.ToString(),
                    Label = $"{ps.ProcessType!.Name} - {ps.Text}"
                });
            return result;
        }

        public IQueryable<DropdownOption> GetPreparationOfDigitalObjectProcessSteps()
        {
            var result = _context.ProcessSteps
                .Where(x => x.AllowTaskTemplate == true && x.ProcessType!.Code == _processTypeCodePreparationOfADigitalObject
                    && (x.Code == _processStepTypeCodePreparationOfADigitalObject || x.Code == _processStepTypeCodeQualityControl))
                .OrderBy(step => step.Text)
                .Select(ps => new DropdownOption()
                {
                    Code = ps.Code.ToString(),
                    Label = ps.Text
                });
            return result;
        }

        public IQueryable<DropdownOption> GetSessionTypes()
        {
            return _context.SessionTypes
             .Select(a => new DropdownOption()
             {
                 Code = a.Code,
                 Label = a.Text,
             });
        }

        public IQueryable<DropdownOption> GetFilmCountries()
        {
            return GetNomenclatures(Shared.NomenclatureCode.FilmCountry);
        }

        public IQueryable<DropdownOption> GetLibraryCards()
        {
            var result = _context.AspNetUserProfiles
                                 .Where(p => p.Deleted == false && p.LibraryCardNumber != null && p.LibraryCardNumber != "")
                                 .Select(p => new DropdownOption()
                                 {
                                     Code = p.LibraryCardNumber!,
                                     Label = p.LibraryCardNumber!,
                                 });

            return result;
        }

        //FIX: Защо е необходим изобщо този подобен метод???
        public IList<DropdownOption> GeProcessesExternal() => GetNomenclatureExternalViaProcedure(NomenclatureTypeExternal.Process);

        public IQueryable<DropdownOption> GetFundTypesReducedCHP() => GetFundTypes().Where(f => f.Code == _fundTypeCodePersonal || f.Code == _fundTypeCodeInstitutional);

        public IQueryable<DropdownOption> GetFundStatusesNTOReportReduced() => GetStatuses()
            .Where(s => s.Code != _statusCodeNew
                   && s.Code != _statusCodeDeleted
                   && s.Code != _statusCodeRestored
                   && s.Code != _statusCodeRebuilt);

        public IList<DropdownOption> GetAllDescLevelsForPublicSearch() => GetFundInventoryAEDocumentDescriptionLevelsInternal()
            .Where(s => s.ExternalIdentifier.HasValue
            && (s.ExternalIdentifier.Value != (int)DescriptionLevelExternalIdentifier.RawFund
            && s.ExternalIdentifier.Value != (int)DescriptionLevelExternalIdentifier.CPMemoryArchiveEntity
            && s.ExternalIdentifier.Value != (int)DescriptionLevelExternalIdentifier.CPMemoryInventory
            && s.ExternalIdentifier.Value != (int)DescriptionLevelExternalIdentifier.RawInventory)
            || !s.ExternalIdentifier.HasValue && s.Label != "Служебен документ"
            ).OrderBy(s => s.Label).ToList();
    }
}
