using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Services.Notifications;
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
    public class NotificationsController : BaseApiController
    {
        private readonly INotificationService _service;

        public NotificationsController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           INotificationService notificationService)
           : base(localizer, logger, userInfo)
        {
            _service = notificationService;
        }

        [HttpPost("list")]
        public IActionResult List(DataSourceRequestModel model)
        {
            try
            {
                var result = _service.GetAllForUser(model, _currentUserInfo.CurrentUserId);
                if (result?.Errors != null)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user notifications list");
                return InternalServerError();
            }
        }

        [HttpPut("markAsSeen/{id}")]
        public async Task<IActionResult> MarkAsSeen(int id)
        {
            try
            {
                var result = await _service.MarkAsSeen(id);
                if (!result.Succeeded)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error marking notification {id} as seen by user {_currentUserInfo.CurrentUserId}/{_currentUserInfo.CurrentUserUsername}");
                return InternalServerError();
            }
        }

        [HttpGet("getUnseenNotifications")]
        public async Task<IActionResult> GetUnseenNotifications()
        {
            try
            {
                var result = await _service.GetUnseenNotifications(_currentUserInfo.CurrentUserId);
                return Success(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting unseen user notifications");
                return InternalServerError();
            }

        }

    }
}
