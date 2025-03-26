using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Services.Information;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Public.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class InformationController : BaseApiController
    {
        private readonly IInformationService _service;

        public InformationController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IInformationService service)
           : base(localizer, logger, userInfo)
        {
            _service = service;
        }


        [HttpPost("listCarouselItems")]
        public IActionResult ListCarouselItems(DataSourceRequestModel model)
        {
            try
            {
                var result = _service.List(model, false);
                if (result?.Errors != null)
                {
                    _logger.LogError(string.Join(";", result.Errors));
                    return BadRequest(result.Errors);
                }
                else
                {
                    return Success(result);
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"{nameof(ListCarouselItems)} Error getting information item list");
                return InternalServerError();
            }
        }


        [HttpGet("getById/{id}")]
        public async Task<IActionResult> Get(int id, CancellationToken cancellationToken)
        {
            try
            {
                return Success(await _service.Get(id, cancellationToken));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"{nameof(Get)} Error getting information item {id}");
                return InternalServerError();
            }
        }
    }
}
