
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using DAA.Shared;

namespace DAA.Web.Public.Controllers
{
    [Route("[controller]")]
    public class CertificateErrorController : Controller
    {
        private const string _returnPath = "login/result";
        protected readonly IStringLocalizer<SharedResources> _localizer;
        protected readonly ILogger<CertificateController> _logger;

        public CertificateErrorController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<CertificateController> logger
        )
        {
            _localizer = localizer;
            _logger = logger;
        }

        /// <summary>
        /// IIS custom error page за грешка 403.7: не е избран или не е инсталиран сертификат.
        /// </summary>
        [AllowAnonymous]
        [HttpGet("notSelected")]
        public ActionResult NotSelected()
        {
            var referer = Request.GetTypedHeaders().Referer;
            var basePath = Request.PathBase.Value?.TrimEnd('/');
            var returnUrl = new UriBuilder()
            {
                Scheme = referer!.Scheme,
                Host = referer.Host,
                Port = referer.Port,
                Path = $"{basePath}/{_returnPath}",
            };
            returnUrl.Query = $"error=true&message={AuthenticationMessageCodes.CertificateNotSelected}";

            _logger.LogError($"Certificate not selected or not installed");

            return Redirect(returnUrl.ToString());
        }

        /// <summary>
        /// IIS custom error page за грешки 403.16: untrusted or invalid; 403.17: expired or future; 403.13: revoked.
        /// </summary>
        [AllowAnonymous]
        [HttpGet("invalid")]
        public ActionResult Invalid()
        {
            var referer = Request.GetTypedHeaders().Referer;
            var basePath = Request.PathBase.Value?.TrimEnd('/');
            var returnUrl = new UriBuilder()
            {
                Scheme = referer!.Scheme,
                Host = referer.Host,
                Port = referer.Port,
                Path = $"{basePath}/{_returnPath}",
            };
            returnUrl.Query = $"error=true&message={AuthenticationMessageCodes.InvalidCertificateSelected}";

            _logger.LogError($"Invalid or untrusted certificate selected");

            return Redirect(returnUrl.ToString());
        }
    }
}
