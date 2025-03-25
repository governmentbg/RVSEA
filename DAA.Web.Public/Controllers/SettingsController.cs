using DAA.Extensions.Controller;
using DAA.Models.Configuration;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;

namespace DAA.Web.Public.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SettingsController : BaseApiController
    {
        private readonly IOptions<ApplicationSettings> _appSettings;

        public SettingsController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IOptions<ApplicationSettings> appSettings)
           : base(localizer, logger, userInfo)
        {
            _appSettings = appSettings;
        }

       
        [AllowAnonymous]
        [HttpGet("Version")]
        public string GetVersion()
        {
            return String.IsNullOrWhiteSpace(_appSettings.Value.Version) ? "1.0.0" : _appSettings.Value.Version;
        }

    }
}
