using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Information;
using DAA.Services.Information;
using DAA.Services.Tasks;
using DAA.Shared.Authorization;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Intranet.Controllers
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
            IInformationService service,
            ITaskService taskService)
            : base(localizer, logger, userInfo)
        {
            _service = service;
        }

        [HttpPost("list")]
        public IActionResult List(DataSourceRequestModel model)
        {
            try
            {
                var result = _service.List(model, true);
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
                _logger.LogError(exc, $"{nameof(List)} Error getting information item list");
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

        [HttpPost("listCalendarItems")]
        public async Task<IActionResult> ListCalendarItems(CalendarRequestModel model, CancellationToken cancellationToken)
        {
            try
            {
                var result = await _service.ListCalendarItems(model, cancellationToken);
                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"{nameof(ListCarouselItems)} Error getting calendar item list");
                return InternalServerError();
            }
        }

        [HttpPost("")]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> Post(InformationItemModel model)
        {
            try
            {
                var result = await _service.Create(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    if (!result.RawErrors)
                    {
                        return BadRequest(result.ToString(false));
                    }
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"{nameof(Post)} Error creating information item");
                return InternalServerError();
            }
        }

        [HttpPut("")]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> Put(InformationItemModel model)
        {
            try
            {
                var result = await _service.Update(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    if (!result.RawErrors)
                    {
                        return BadRequest(result.ToString(false));
                    }
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"{nameof(Post)} Error updating information item");
                return InternalServerError();
            }
        }

        [HttpDelete("{id}")]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                var result = await _service.Delete(id);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    if (!result.RawErrors)
                    {
                        return BadRequest(result.ToString(false));
                    }
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"{nameof(Post)} Error deleting information item");
                return InternalServerError();
            }
        }
    }
}
