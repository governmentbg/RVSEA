using DAA.Extensions.Controller;
using DAA.Services.Films;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using DAA.Shared.Localization;
using DAA.Models.Configuration;
using Microsoft.Extensions.Options;
using DAA.Extensions.DynamicLinq;
using Microsoft.AspNetCore.Authorization;

namespace DAA.Web.Public.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FilmsController : BaseApiController
    {
        private readonly IFilmPublicService _filmPublicService;

        public FilmsController(
           IFilmPublicService filmPublicService,
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger)
            
             : base(localizer, logger)
        {
            _filmPublicService = filmPublicService;
        }

        [AllowAnonymous]
        [HttpGet("{sysId?}")]
        public async Task<IActionResult> Get(Guid? sysId, [FromQuery] bool? hasExternalSource, [FromQuery] int? externalIdentifier)
        {
            try
            {

                if (sysId.HasValue)
                {
                    return Success(await _filmPublicService.GetBySystemIdentifierAsync(sysId.Value));
                }
                else
                {
                    if (hasExternalSource.HasValue && hasExternalSource.Value && externalIdentifier.HasValue)
                    {
                        return Success(await _filmPublicService.GetFromExternalSourceAsync(externalIdentifier.Value));
                    }
                    else
                    {
                        _logger.LogError($"Film has no system identifier ({sysId}) and external source ({hasExternalSource} {externalIdentifier})");
                        return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                    }
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting film {sysId}");
                return InternalServerError();
            }
        }

        [HttpGet("getLink")]
        public async Task<IActionResult> GetIsdaEServicesLink()
        {
            var link =_filmPublicService.GetIsdaEServicesLink();

            return Ok(link);
        }

        [HttpPost("listallforreader")]
        public async Task<IActionResult> GetAllForReader(DataSourceRequestModel model)
        {
            try
            {
                var result = _filmPublicService.GetAllForReader(model);
                if (result?.Errors != null)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting films list");
                return InternalServerError();
            }
        }

    }
}
