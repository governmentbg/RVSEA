using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Identity;
using DAA.Models.Applications;
using DAA.Models.Identity;
using DAA.Models.Users;
using DAA.Services.Applications;
using DAA.Services.Users;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Public.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class ApplicationsController : BaseApiController
    {
        private readonly IApplicationsService _applicationsService;
        private readonly ApplicationUserManager _userManager;
        private readonly IUserInfo _userInfo;
        private readonly IUserProfileService _userProfileService;
        public ApplicationsController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<AccountController> logger,
            IApplicationsService applicationsService,
            IUserInfo userInfo,
            IUserProfileService userProfileService,
            ApplicationUserManager userManager)
            : base(localizer, logger, userInfo)
        {
            _applicationsService = applicationsService;
            _userManager = userManager;
            _userInfo = userInfo;
            _userProfileService = userProfileService;
        }

        [HttpPost("List")]
        public async Task<IActionResult> List([FromBody]DataSourceRequestModel model)
        {
            ApplicationUser user =  _userManager.Users.Where(u => u.Id == _userInfo.CurrentUserId).FirstOrDefault();
            UserProfileModel userProfile = await _userProfileService.GetProfileAsync(user.Id);
            if (userProfile.ProfileType != ApplicationUserProfileType.FundCreator) return BadRequest();
            return Ok(_applicationsService.List(model));
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody]ApplicationCreateModel model)
        {
            ApplicationUser user = _userManager.Users.Where(u => u.Id == _userInfo.CurrentUserId).FirstOrDefault();
            UserProfileModel userProfile = await _userProfileService.GetProfileAsync(user.Id);
            if (userProfile.ProfileType != ApplicationUserProfileType.FundCreator) return BadRequest();
            if (ModelState.IsValid)
            {
                try
                {
                    await _applicationsService.CreateApplication(model);
                    return Ok();
                }
                catch (Exception x)
                {
                    return InternalServerError(x.Message);
                }
            }

            return BadRequest();
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> Get(int id)
        {
            ApplicationUser user = _userManager.Users.Where(u => u.Id == _userInfo.CurrentUserId).FirstOrDefault();
            UserProfileModel userProfile = await _userProfileService.GetProfileAsync(user.Id);
            if (userProfile.ProfileType != ApplicationUserProfileType.FundCreator) return BadRequest();
            return Ok(_applicationsService.Display(id));
        }

        [HttpGet("getInventoryDraftSysId/{applicationId}")]
        public async Task<IActionResult> GetInventoryDraftSysId(int applicationId)
        {
            try
            {
                Guid? result = await _applicationsService.GetInventoryDraftSysId(applicationId);
                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting inventory system identifier for application id {applicationId}");
                return InternalServerError();
            }
        }

        [HttpDelete("{id}")]
        public  async Task<IActionResult> Delete(int id)
        {
            try
            {

                ApplicationUser user = _userManager.Users.Where(u => u.Id == _userInfo.CurrentUserId).FirstOrDefault();
                UserProfileModel userProfile = await _userProfileService.GetProfileAsync(user.Id);
                if (userProfile.ProfileType != ApplicationUserProfileType.FundCreator) return BadRequest();

                var result = await _applicationsService.Delete(id);

                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(String.Join(";", result.Errors));
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting film {id}");
                return InternalServerError();
            }
        }
    }
}
