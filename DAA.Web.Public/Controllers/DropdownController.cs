using DAA.Extensions.Controller;
using DAA.Extensions.Exceptions;
using DAA.Services.Interfaces;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Public.Controllers
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

        [HttpGet("internalAndExternal/archives")]
        public async Task<IActionResult> GetArchivesInternalAndExternal()
        {
            try
            {
                return Success(await _dropdownService.GetAllArchivesAsync(false));
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

        [HttpGet("internalAndExternal/fundArrays")]
        public async Task<IActionResult> GetFundArraysInternalAndExternal()
        {
            try
            {
                //Справките нямат избор на система.
                return Success(await _dropdownService.GetAllFundArraysAsync((int)Shared.ReportResultType.AllDB));
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

        [HttpGet("internalAndExternal/fundTypes")]
        public IActionResult GetFundTypesInternalAndExternal()
        {
            try
            {
                //Справките нямат избор на система.
                return Success(_dropdownService.GetFundTypesInternalAndExternal((int)Shared.ReportResultType.AllDB));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting internal and external fund type list");
                return InternalServerError();
            }
        }

        [HttpGet("fundStatuses")]
        public IActionResult GetFundStatuses()
        {
            try
            {
                //Справките нямат избор на система.
                return Success(_dropdownService.GetFundStatusesInternal((int)Shared.ReportResultType.AllDB));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting fund status list");
                return InternalServerError();
            }
        }

        [HttpGet("internalAndExternal/fundStatuses")]
        public IActionResult GetFundStatusesInternalAndExternal()
        {
            try
            {
                //Справките нямат избор на система.
                return Success(_dropdownService.GetFundStatusesInternalAndExternal((int)Shared.ReportResultType.AllDB));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting internal and external fund status list");
                return InternalServerError();
            }
        }

        [HttpGet("internalAndExternal/acquisitionMethods")]
        public IActionResult GetAcquisitionMethodsInternalAndExternal()
        {
            try
            {
                //Справките нямат избор на система.
                return Success(_dropdownService.GetAcquisitionMethodsInternalAndExternal((int)Shared.ReportResultType.AllDB));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting internal and external acquisition methods list");
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

        //[HttpGet("archiveEntityStatuses")]
        //public IActionResult GetArchiveEntityStatuses()
        //{
        //    try
        //    {
        //        return Success(_dropdownService.GetArchiveEntityStatuses());
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex, "Error getting inventory status list");
        //        return InternalServerError();
        //    }
        //}

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

        [HttpGet("industryIndexes")]
        public IActionResult GetIndustryIndexes()
        {
            try
            {
                return Success(_dropdownService.GetIndustryIndexes());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting industry indexes");
                return InternalServerError();
            }
        }

        [HttpGet("internalAndExternal/industryIndexes")]
        public IActionResult GetIndustryIndexesInternalAndExternal()
        {
            try
            {
                //Справките нямат избор на система.
                return Success(_dropdownService.GetIndustryIndexesInternalAndExternal((int)Shared.ReportResultType.AllDB));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting external industry indexes");
                return InternalServerError();
            }
        }

        [HttpGet("getAllDescLevels")]
        public async Task<IActionResult> GetAllDescLevels()
        {
            try
            {
                return Success(_dropdownService.GetFundInventoryAEDocumentDescriptionLevelsExternalAndInternal((int)Shared.ReportResultType.AllDB));
            }
            catch (ExternalConnectionException exc)
            {
                _logger.LogWarning(exc, "Error getting public description level list from external source.");

                return Success(await _dropdownService.GetAllPublicDescriptionLevelsAsync((int)Shared.ReportResultType.InternalDB), _localizer.GetString("Error_NoExternalConnection"));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting public description level list");
                return InternalServerError();
            }
        }

        //Защо е необходимо дефиниране на нов метод, след като трябва да се коригира съществуващия???????
        [HttpGet("getAllDescLevelsForPublicSerarch")]
        public async Task<IActionResult> GetAllDescLevelsForPublicSerarch()
        {
            try
            {
                return Success(_dropdownService.GetAllDescLevelsForPublicSearch());
            }
            catch (ExternalConnectionException exc)
            {
                _logger.LogWarning(exc, "Error getting public description level list from external source.");

                return Success(await _dropdownService.GetAllPublicDescriptionLevelsAsync((int)Shared.ReportResultType.InternalDB), _localizer.GetString("Error_NoExternalConnection"));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting public description level list");
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

        [HttpGet("ApplicationTypes")]
        public IActionResult GetApplicationTypes()
        {
            try
            {
                return Success(_dropdownService.GetApplicationTypes());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting application types");
                return InternalServerError();
            }
        }
    }
}


