using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Films;
using DAA.Services.Authorization;
using DAA.Services.Films;
using DAA.Shared.Authorization;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using ISystemAuthorizationService = Microsoft.AspNetCore.Authorization.IAuthorizationService;

namespace DAA.Web.Intranet.Controllers
{

    [Route("api/[controller]")]
    [ApiController]
    public class FilmCardsController : BaseApiController
    {
        private readonly IFilmCardPublicService _filmCardService;
        private readonly ISystemAuthorizationService _authorizationService;

        public FilmCardsController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IFilmCardPublicService filmCardService,
           ISystemAuthorizationService authorizationService)
           : base(localizer, logger, userInfo)
        {
            _filmCardService = filmCardService;
            _authorizationService = authorizationService;
        }

        [AllowAnonymous]
        [HttpPost("listall/{filmSysId}")]
        public IActionResult ListAll(DataSourceRequestModel model, Guid? filmSysId)
        {
            try
            {
                var result = _filmCardService.GetAll(model, filmSysId);
                if (result?.Errors != null)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting film cards list");
                return InternalServerError();
            }
        }

        [HttpGet("{sysId}")]
        public async Task<IActionResult> Get(Guid? sysId, [FromQuery] bool? hasExternalSource, [FromQuery] int? externalIdentifier)
        {
            try
            {
                if (hasExternalSource.HasValue && hasExternalSource.Value && externalIdentifier.HasValue)
                {
                    return Success(await _filmCardService.GetFromExternalSourceAsync(externalIdentifier.Value));
                }
                else if (sysId.HasValue)
                {
                    return Success(await _filmCardService.GetBySystemIdentifierAsync(sysId.Value));
                }
                else
                {
                    _logger.LogError($"Film card has no system identifier ({sysId}) and external source ({hasExternalSource} {externalIdentifier})");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting film card {sysId}");
                return InternalServerError();
            }
        }
    }
}
