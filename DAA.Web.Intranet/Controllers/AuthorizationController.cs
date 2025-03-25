using DAA.Extensions.Controller;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Intranet.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class AuthorizationController : BaseApiController
    {
        protected new DAA.Services.Authorization.IAuthorizationService _authorizationService;
        public AuthorizationController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<BaseApiController> logger,
            IUserInfo userInfo,
            DAA.Services.Authorization.IAuthorizationService authorizationService)
            : base(localizer, logger, userInfo)
        {
            _authorizationService = authorizationService;
        }


        [HttpPost("roles")]
        public async Task<IActionResult> GetRoles()
        {
            try
            {
                var roles = await _authorizationService.GetRoles(_currentUserInfo.CurrentUser);
                return Success(roles);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Authorization error - Error getting roles");
                return Forbid();
            }
        }

    }
}
