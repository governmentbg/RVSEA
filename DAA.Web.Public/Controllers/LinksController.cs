using DAA.Extensions.Controller;
using DAA.Services.Interfaces;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;

namespace DAA.Web.Public.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LinksController : BaseApiController
    {
        private readonly ILinksService _linksService;

        public LinksController(
           IStringLocalizer<SharedResources> localizer,
           ILinksService linksService)

             : base(localizer)
        {
            _linksService = linksService;
        }

        [HttpGet("getLink")]
        public async Task<IActionResult> GetDaaSurveysLink()
        {
            var link = _linksService.GetDaaSurveysLink();

            return Ok(link);
        }
    }
}
