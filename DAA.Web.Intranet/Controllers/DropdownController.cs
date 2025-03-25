using DAA.Data;
using DAA.Extensions.Controller;
using DAA.Extensions.Exceptions;
using DAA.Services.Interfaces;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Intranet.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DropdownController : BaseApiController
    {
        private readonly IDropdownService _dropdownService;
        public DropdownController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<AccountController> logger,
            IUserInfo userInfo,
            IDropdownService dropdownService)
            : base(localizer, logger, userInfo)
        {
            _dropdownService = dropdownService;
        }

        [HttpGet("archives")]
        public IActionResult GetArchives()
        {
            try
            {
                return Success(_dropdownService.GetArchives());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting archives list");
                return InternalServerError();
            }
        }

        [HttpGet("external/archives")]
        public async Task<IActionResult> GetExternalSourceArchives()
        {
            try
            {
                return Success(await _dropdownService.GetExternalSourceArchivesAsync());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting external archives list");
                return InternalServerError();
            }
        }

        [HttpGet("internalAndExternal/archives")]
        public async Task<IActionResult> GetArchivesInternalAndExternal()
        {
            try
            {
                return Success(await _dropdownService.GetAllArchivesAsync(true));
            }
            catch (ExternalConnectionException exc)
            {
                _logger.LogWarning(exc, "Error getting archives list from external source.");

                return Success(_dropdownService.GetArchives(), _localizer.GetString("Error_NoExternalConnection"));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting archives list");
                return InternalServerError();
            }
        }

        [HttpGet("fileFormats")]
        public IActionResult GetFileFormats()
        {
            try
            {
                return Success(_dropdownService.GetFileFormats());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting internal and external processes list");
                return InternalServerError();
            }
        }

        [HttpGet("roles")]
        public IActionResult GetRoles()
        {
            try
            {
                return Success(_dropdownService.GetRoles());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting role list");
                return InternalServerError();
            }
        }


        [HttpGet("statusesFundMemoriesReport")]
        public IActionResult GetStatusesReducedFundMemoriesReport()
        {
            try
            {
                return Success(_dropdownService.GetFundMemoriesReportStatuses());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting status list");
                return InternalServerError();
            }
        }

        [HttpGet("statuses")]
        public IActionResult GetStatuses()
        {
            try
            {
                return Success(_dropdownService.GetStatuses());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting status list");
                return InternalServerError();
            }
        }

        [HttpGet("statusesReduced")]
        public IActionResult GetStatusesReduced()
        {
            try
            {
                return Success(_dropdownService.GetStatusesReduced());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting status list");
                return InternalServerError();
            }
        }

        [HttpGet("fundTypesReducedCHP")]
        public IActionResult GetFundTypesReducedCHP()
        {
            try
            {
                return Success(_dropdownService.GetFundTypesReducedCHP());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting status list");
                return InternalServerError();
            }
        }
        
        [HttpGet("statusesReduced2")]
        public IActionResult GetStatusesReduce2d()
        {
            try
            {
                return Success(_dropdownService.GetStatusesReduced2());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting status list");
                return InternalServerError();
            }
        }

        [HttpGet("roughDocumentsStatuses")]
        public IActionResult GetRoughDocumentsStatuses()
        {
            try
            {
                return Success(_dropdownService.GetRoughDocumentsStatuses());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting status list");
                return InternalServerError();
            }
        }

        [HttpGet("availabilitystatuses")]
        public IActionResult GetAvailabilityStatuses()
        {
            try
            {
                return Success(_dropdownService.GetAvailabilityStatuses());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting availability status list");
                return InternalServerError();
            }
        }

        [HttpGet("rolesInArchive/{archiveId}/{roles?}")]
        public IActionResult GetRolesInArchive(int archiveId, string roles)
        {
            try
            {
                var rolesList = roles != null ? roles.Split(',') : new string[] { };
                var result = _dropdownService.GetRolesInArchive(archiveId, rolesList);
                return Success(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error getting roles {roles} in archive {archiveId}");
                return InternalServerError();
            }
        }

        [HttpGet("fundArrays")]
        public IActionResult GetFundArrays()
        {
            try
            {
                return Success(_dropdownService.GetFundArrays());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting fund array list");
                return InternalServerError();
            }
        }

        [HttpGet("internalAndExternal/fundArrays/{reportResultType}")]
        public async Task<IActionResult> GetFundArraysInternalAndExternal(int reportResultType)
        {
            try
            {
                return Success(await _dropdownService.GetAllFundArraysAsync(reportResultType));
            }
            catch (ExternalConnectionException exc)
            {
                _logger.LogWarning(exc, "Error getting fund array list from external source.");

                return Success(_dropdownService.GetFundArrays(), _localizer.GetString("Error_NoExternalConnection"));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting fund array list");
                return InternalServerError();
            }
        }

        [HttpGet("internalAndExternal/fundArraysReduced/{reportResultType}")]
        public async Task<IActionResult> GetFundArraysInternalAndExternalReduced(int reportResultType)
        {
            try
            {
                return Success(await _dropdownService.GetFundArraysInternalAndExternalReducedAsync(reportResultType));
            }
            catch (ExternalConnectionException exc)
            {
                _logger.LogWarning(exc, "Error getting reduced fund array list from external source.");

                return Success(_dropdownService.GetFundArrays(), _localizer.GetString("Error_NoExternalConnection"));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting reduced fund array list");
                return InternalServerError();
            }
        }

        [HttpGet("fundTypes")]
        public IActionResult GetFundTypes()
        {
            try
            {
                return Success(_dropdownService.GetFundTypes());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting fund type list");
                return InternalServerError();
            }
        }

        [HttpGet("internalAndExternal/fundTypes/{reportResultType}")]
        public IActionResult GetFundTypesInternalAndExternal(int reportResultType)
        {
            try
            {
                return Success(_dropdownService.GetFundTypesInternalAndExternal(reportResultType));
            }
            catch (ExternalConnectionException exc)
            {
                _logger.LogWarning(exc, "Error getting fundTypesReduced list from external source.");

                return Success(_dropdownService.GetFundTypesInternalAndExternal((int)Shared.ReportResultType.InternalDB), _localizer.GetString("Error_NoExternalConnection"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting internal and external fund type list");
                return InternalServerError();
            }
        }

        [HttpGet("internalAndExternal/fundTypesReduced/{reportResultType}")]
        public IActionResult GetFundTypesInternalAndExternalReduced(int reportResultType)
       {
            try
            {
              var result = _dropdownService.GetFundTypesInternalAndExternalReduced(reportResultType);

                return Success(result);
            }
            catch (ExternalConnectionException exc)
            {
                _logger.LogWarning(exc, "Error getting fundTypesReduced list from external source.");

                return Success(_dropdownService.GetFundTypesInternalAndExternalReduced((int)Shared.ReportResultType.InternalDB), _localizer.GetString("Error_NoExternalConnection"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting internal and external fund type list");
                return InternalServerError();
            }
        }

        [HttpGet("fundTypesReduced")]
        public IActionResult GetFundTypesReduced()
        {
            try
            {
                return Success(_dropdownService.GetFundTypesReduced());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting fund type list");
                return InternalServerError();
            }
        }

        [HttpGet("fundStatuses/{reportResultType}")]
        public IActionResult GetFundStatuses(int reportResultType)
        {
            try
            {
                return Success(_dropdownService.GetFundStatusesInternal(reportResultType));
            }
            catch (Exception ex)
            {
                //_logger.LogError(ex, "Error getting internal fund status list");
                return InternalServerError();
            }
        }

        [HttpGet("fundStatusesNTOReportReduce")]
        public IActionResult GetFundStatusesNTOReportReduce()
        {
            try
            {
              
                    var res = _dropdownService.GetFundStatusesNTOReportReduced();

                return Success(res);
            }
            catch (Exception ex)
            {
                //_logger.LogError(ex, "Error getting internal fund status list");
                return InternalServerError();
            }
        }

        [HttpGet("internalAndExternal/fundStatuses/{reportResultType}")]
        public IActionResult GetFundStatusesExternal(int reportResultType)
        {
            try
            {
                return Success(_dropdownService.GetFundStatusesInternalAndExternal(reportResultType));
            }
            catch (ExternalConnectionException exc)
            {
                _logger.LogWarning(exc, "Error getting acquisitionMethods list from external source.");

                return Success(_dropdownService.GetFundStatusesInternalAndExternal((int)Shared.ReportResultType.InternalDB), _localizer.GetString("Error_NoExternalConnection"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting internal and external fund status list");
                return InternalServerError();
            }
        }

        [HttpGet("fundDescLevels")]
        public IActionResult GetFundDescriptionLevels()
        {
            try
            {
                return Success(_dropdownService.GetFundDescriptionLevels());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting fund description level list");
                return InternalServerError();
            }
        }

        [HttpGet("external/descLevels")]
        public IActionResult GetDescriptionLevelsExternal()
        {
            try
            {
                return Success(_dropdownService.GetDescriptionLevelsExternal());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting description level external list");
                return InternalServerError();
            }
        }

        [HttpGet("inventoryArrays")]
        public IActionResult GetInventoryArrays()
        {
            try
            {
                return Success(_dropdownService.GetInventoryArrays());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting inventory array list");
                return InternalServerError();
            }
        }

        [HttpGet("internalAndExternal/inventoryArrays")]
        public IActionResult GetInventoryArraysInternalAndExternal()
        {
            try
            {
                return Success(_dropdownService.GetInventoryArraysInternalAndExternal());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting internal and external inventory array list");
                return InternalServerError();
            }
        }

        [HttpGet("inventoryDescLevels")]
        public IActionResult GetInventoryDescriptionLevels([FromQuery] int? fundDescLevel = null)
        {
            try
            {
                return Success(_dropdownService.GetInventoryDescriptionLevels(fundDescLevel));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting inventory description level list");
                return InternalServerError();
            }
        }

        [HttpGet("internalAndExternal/acquisitionMethods/{reportResultType}")]
        public IActionResult GetAcquisitionMethodsExternal(int reportResultType)
        {
            try
            {
                return Success(_dropdownService.GetAcquisitionMethodsInternalAndExternal(reportResultType));
            }
            catch (ExternalConnectionException exc)
            {
                _logger.LogWarning(exc, "Error getting acquisitionMethods list from external source.");

                return Success(_dropdownService.GetAcquisitionMethodsInternalAndExternal((int)Shared.ReportResultType.InternalDB), _localizer.GetString("Error_NoExternalConnection"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting internal and external acquisition method list");
                return InternalServerError();
            }
        }

        [HttpGet("acquisitionMethods")]
        public IActionResult GetAcquisitionMethods()
        {
            try
            {
                return Success(_dropdownService.GetAcquisitionMethodsInternal());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting internal acquisition method list");
                return InternalServerError();
            }
        }

        //[HttpGet("processTypes/entityType/{entityType?}")]
        [HttpGet("processTypes")]
        public IActionResult GetProcessTypes([FromQuery] string[]? entityType)
        {
            try
            {
                return Success(_dropdownService.GetProcessTypes(entityType));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error getting process types list for entity type {entityType}");
                return InternalServerError();
            }
        }

        [HttpGet("funds")]
        public async Task<IActionResult> GetFunds([FromQuery] string searchText, [FromQuery] int archiveCode, [FromQuery] string[]? descriptionLevel)
        {
            try
            {
                return Success(await _dropdownService.GetFunds(searchText, archiveCode, descriptionLevel));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting funds list");
                return InternalServerError();
            }
        }

        [HttpGet("inventories")]
        public async Task<IActionResult> GetInventories(
            [FromQuery] string searchText,
            [FromQuery] Guid? fundSysId,
            [FromQuery] bool? fundHasExternalSource,
            [FromQuery] int? fundExternalIdentifier,
            [FromQuery] string[]? descriptionLevel)
        {
            try
            {
                return Success(await _dropdownService.GetInventories(searchText, fundSysId, fundHasExternalSource, fundExternalIdentifier, descriptionLevel));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting inventories list");
                return InternalServerError();
            }
        }


        [HttpGet("nomenclatures/{parentId?}")]
        public IActionResult GetNomenclaturesByParentId(int? parentId)
        {
            try
            {
                return Success(_dropdownService.GetNomenclatures(parentId));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error getting nommenclature values (parentId: {parentId})");
                return InternalServerError();
            }
        }

        [HttpGet("nomenclatures/code/{code?}")]
        public IActionResult GetNomenclaturesByCode(string code)
        {
            try
            {
                return Success(_dropdownService.GetNomenclatures(code));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error getting nomenclature values (code: {code})");
                return InternalServerError();
            }
        }

        [HttpGet("nomenclatureCodes")]
        public IActionResult GetNomenclatureCodes()
        {
            try
            {
                return Success(_dropdownService.GetNomenclatureCodes());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error getting nomenclature codes");
                return InternalServerError();
            }
        }

        [HttpGet("archiveEntityDescLevels")]
        public IActionResult GetArchiveEntityDescriptionLevels()
        {
            try
            {
                return Success(_dropdownService.GetArchiveEntityDescriptionLevels());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting inventory description level list");
                return InternalServerError();
            }
        }

        [HttpGet("internalAndExternal/archiveEntityDescLevels")]
        public IActionResult GetArchiveEntityDescriptionLevelsInternalAndExternal()
        {
            try
            {
                return Success(_dropdownService.GetArchiveEntityDescriptionLevelsInternalAndExternal());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting inventory description level internal and external list");
                return InternalServerError();
            }
        }

        [HttpGet("documentDescLevels")]
        public IActionResult GetDocumentDescriptionLevels()
        {
            try
            {
                return Success(_dropdownService.GetDocumentDescriptionLevels());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting document description level list");
                return InternalServerError();
            }
        }

        [HttpGet("centralArchive")]
        public IActionResult GetCentralArchive()
        {
            try
            {
                return Success(_dropdownService.GetCentralArchive());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting central archive");
                return InternalServerError();
            }
        }

        [HttpGet("CollectingProcedures")]
        public IActionResult GetCollectingProcedures()
        {
            try
            {
                return Success(_dropdownService.GetCollectingProcedures());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting central archive");
                return InternalServerError();
            }
        }

        [HttpGet("internalAndExternal/processTypes/{reportResultType}")]
        public IActionResult GetProcessTypesInternalAndExternal(int reportResultType)
        {
            try
            {
                return Success(_dropdownService.GetProcessTypesInternalAndExternal(reportResultType));
            }
            catch (ExternalConnectionException exc)
            {
                _logger.LogWarning(exc, "Error getting processType list from external source.");

                return Success(_dropdownService.GetProcessTypesInternalAndExternal((int)Shared.ReportResultType.InternalDB), _localizer.GetString("Error_NoExternalConnection"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting internal and external processType list");
                return InternalServerError();
            }
        }

        [HttpGet("reportResultTypes")]
        public IActionResult GetReportResultTypes()
        {
            try
            {
                return Success(_dropdownService.GetReportResultTypes());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting report result types list");
                return InternalServerError();
            }
        }

        [HttpGet("filmDocTypes/{packageType}")]
        public IActionResult GetFilmDocTypes(string packageType)
        {
            try
            {
                return Success(_dropdownService.GetFilmDocTypes(packageType));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error getting film document types for package type {packageType}");
                return InternalServerError();
            }
        }

        [HttpGet("filmPackageBDocs/{filmSysId}")]
        public IActionResult GetFilmPackageBDoc(string filmSysId)
        {
            try
            {
                return Success(_dropdownService.GetFilmPackageBDocs(filmSysId));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error getting package B documents for film {filmSysId}");
                return InternalServerError();
            }
        }

        [HttpGet("filmPackageBDocsUnused/{filmSysId}/{cardSysId}")]
        public async Task<IActionResult> GetUnusedFilmPackageBDocs(string filmSysId, Guid cardSysId)
        {
            try
            {
                return Success(await _dropdownService.GetUnusedFilmPackageBDocs(filmSysId, cardSysId));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error getting package B unused documents for film {filmSysId}, card {cardSysId}");
                return InternalServerError();
            }
        }

        [HttpGet("internalAndExternal/industryIndexes/{reportResultType}")]
        public IActionResult GetIndustryIndexesInternalAndExternal(int reportResultType)
        {
            try
            {
                return Success(_dropdownService.GetIndustryIndexesInternalAndExternal(reportResultType));
            }
            catch (ExternalConnectionException exc)
            {
                _logger.LogWarning(exc, "Error getting industryIndexes list from external source.");

                return Success(_dropdownService.GetIndustryIndexesInternalAndExternal((int)Shared.ReportResultType.InternalDB), _localizer.GetString("Error_NoExternalConnection"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting internal and external industry indexes");
                return InternalServerError();
            }
        }

        [HttpGet("usersInRoles/{archiveId}/{roles?}")]
        public IActionResult GetUsersInRoles(int archiveId, string roles)
        {
            try
            {
                var rolesList = roles != null ? roles.Split(',') : new string[] { };
                var result = _dropdownService.GetUsersInRoles(archiveId, rolesList);
                return Success(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error getting users in roles {roles} for archive {archiveId}");
                return InternalServerError();
            }
        }

        [HttpGet("usersInRolesAllArchives/{roles?}")]
        public IActionResult GetUsersInRolesAllArchives(string roles)
        {
            try
            {
                var rolesList = roles != null ? roles.Split(',') : new string[] { };
                var result = _dropdownService.GetUsersInRolesAllArchives(rolesList);
                return Success(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error getting users in roles {roles}");
                return InternalServerError();
            }
        }

        [HttpGet("getEPKSessions/{archiveId}")]
        public IActionResult GetEPKSessions(int archiveId)
        {
            try
            {
                return Success(_dropdownService.GetCommissionSessions(archiveId));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting EPK Session Dates list");
                return InternalServerError();
            }
        }

        [HttpGet("internalAndExternal/getEmployeeNames/{reportResultType}")]
        public IActionResult GetEmployeeNames(int reportResultType)
        {
            try
            {
                return Success(_dropdownService.GetEmployeeNamesInternalAndExternal(reportResultType));
            }
            catch (ExternalConnectionException exc)
            {
                _logger.LogWarning(exc, "Error getting employee names from external source.");

                return Success(_dropdownService.GetEmployeeNamesInternalAndExternal((int)Shared.ReportResultType.InternalDB), _localizer.GetString("Error_NoExternalConnection"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting employee names");
                return InternalServerError();
            }
        }
        [HttpGet("internal/getEmployeeNames")]
        public IActionResult GetInternalEmployeeNames()
        {
            try
            {
                return Success(_dropdownService.GetEmployeeNamesInternal());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting employee names");
                return InternalServerError();
            }
        }
        [Authorize]
        [HttpGet("approvedApplications")]
        public IActionResult GetApprovedApplications([FromQuery] string? applicationType = null, [FromQuery] Guid? inventorySysId = null, [FromQuery] int? archiveId = null)
        {
            try
            {
                return Success(_dropdownService.GetAssignedToUserApplications(_currentUserInfo.CurrentUserId.Value, applicationType, inventorySysId, archiveId));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting applications list");
                return InternalServerError();
            }
        }

        [Authorize]
        [HttpGet("readerProfiles")]
        public IActionResult GetReaderProfiles()
        {
            try
            {
                return Success(_dropdownService.GetReaderProfiles());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting reader profiles list");
                return InternalServerError();
            }
        }

        [Authorize]
        [HttpGet("films")]
        public IActionResult GetAllFilms()
        {
            try
            {
                return Success(_dropdownService.GetAllFilms());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting films list");
                return InternalServerError();
            }
        }

        [HttpGet("getAllDescLevels")]
        public IActionResult GetAllDescLevels()
        {
            try
            {
                return Success(_dropdownService.GetAllDescriptionLevelsExternalAndInternal());
            }
            catch (Exception ex1)
            {
                _logger.LogWarning(ex1, "Error getting internal and external all description levels");

                try
                {
                    return Success(_dropdownService.GetAllDescriptionLevelsExternalAndInternal(true));
                }
                catch (Exception ex2)
                {
                    _logger.LogError(ex2, "Error getting internal and external all description levels");
                    return InternalServerError();
                }
            }
        }

        [HttpGet("getFundInventoryAEDocumentDescLevels/{reportResultType}")]
        public IActionResult GetFundInventoryAEDocumentDescLevels(int reportResultType)
        {
            try
            {
                return Success(_dropdownService.GetFundInventoryAEDocumentDescriptionLevelsExternalAndInternal(reportResultType));
            }
            catch (Exception ex1)
            {
                _logger.LogWarning(ex1, "Error getting internal and external fund, inventory, archival entity and document description levels");

                try
                {
                    return Success(_dropdownService.GetFundInventoryAEDocumentDescriptionLevelsExternalAndInternal((int)Shared.ReportResultType.InternalDB));
                }
                catch (Exception ex2)
                {
                    _logger.LogError(ex2, "Error getting internal fund, inventory, archival entity and document description levels");
                    return InternalServerError();
                }
            }
        }

        [HttpGet("processesSteps")]
        public IActionResult GetProcessesSteps()
        {
            try
            {
                return Success(_dropdownService.GetProcessesSteps());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting processes steps");
                return InternalServerError();
            }
        }


        [HttpGet("preparationOfDigitalObjectProcessSteps")]
        public IActionResult GetPreparationOfDigitalObjectProcessSteps()
        {
            try
            {
                return Success(_dropdownService.GetPreparationOfDigitalObjectProcessSteps());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting preparation of digital object process steps");
                return InternalServerError();
            }
        }


        [HttpGet("getSessionTypes")]
        public IActionResult GetSessionTypes()
        {
            try
            {
                return Success(_dropdownService.GetSessionTypes());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting sessionTypes nomeclatures table");
                return InternalServerError();
            }

        }

        [HttpGet("filmCountries")]
        public IActionResult GetFilmCountries()
        {
            try
            {
                return Success(_dropdownService.GetFilmCountries());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting film countries list");
                return InternalServerError();
            }
        }

        [HttpGet("libraryCards")]
        public IActionResult GetLibraryCards()
        {
            try
            {
                return Success(_dropdownService.GetLibraryCards());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting library cards list");
                return InternalServerError();
            }
        }

        [HttpGet("employeeNamesExternal")]
        public IActionResult GetEmployeeNamesExternal()
        {
            try
            {
                return Success(_dropdownService.GetEmployeeNamesExternalViaProcedure());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting employee names external list");
                return InternalServerError();
            }
        }

        [HttpGet("external/processes")]
        public IActionResult GetProcessesExternal()
        {
            try
            {
                return Success(_dropdownService.GeProcessesExternal());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting external processes list");
                return InternalServerError();
            }
        }
    }
}
