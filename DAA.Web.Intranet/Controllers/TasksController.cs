using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Films;
using DAA.Services.Authorization;
using DAA.Services.Films;
using DAA.Services.Tasks;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Intranet.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class TasksController : BaseApiController
    {
        private readonly ITaskService _taskService;
        //private readonly ISystemAuthorizationService _authorizationService;

        public TasksController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           ITaskService taskService/*,
           ISystemAuthorizationService authorizationService*/)
           : base(localizer, logger, userInfo)
        {
            _taskService = taskService;
            //_authorizationService = authorizationService;
        }

        [HttpPost("my")]
        public IActionResult ListMyTasks(DataSourceRequestModel model)
        {
            try
            {
                var result = _taskService.GetMyTasks(model);
                if (result?.Errors != null)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting my tasks list");
                return InternalServerError();
            }
        }

        [HttpGet("getMyNewTasksCount")]
        public async Task<IActionResult> GetMyNewTasksCount()
        {
            try
            {
                var result = await _taskService.GetMyNewTasksCount();

                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting my new tasks count");
                return InternalServerError();
            }
        }

        [HttpPost("assignedByMe")]
        public IActionResult ListAssignedByMe(DataSourceRequestModel model)
        {
            try
            {
                var result = _taskService.GetAssignedByMe(model);
                if (result?.Errors != null)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting assigned by me tasks list");
                return InternalServerError();
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> Get(int id)
        {
            try
            {
                return Success(await _taskService.GetById(id));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting task {id}");
                return InternalServerError();
            }
        }

        //[HttpDelete("{id}")]
        //public async Task<IActionResult> Cancel(int id)
        //{
        //    try
        //    {
        //        var result = await _taskService.ChangeTaskStatus(id, Shared.TaskStatus.Canceled);
        //        if (result?.Errors != null)
        //        {
        //            _logger.LogError(String.Join(";", result.Errors));
        //            return BadRequest(String.Join(";", result.Errors));
        //        }
        //        return Success();
        //    }
        //    catch (Exception exc)
        //    {
        //        _logger.LogError(exc, $"Error cancelling task {id}");
        //        return InternalServerError();
        //    }
        //}

        //public async Task<int> AuthorizeRolesInArchive(int? archiveId, IEnumerable<string> roles)
        //{
        //    try
        //    {
        //        AuthorizationResult authorizationResult =
        //        await _authorizationService.AuthorizeAsync(
        //            _currentUserInfo.CurrentUser,
        //            archiveId,
        //            new ArchiveAuthorizationRequirement(roles));

        //        if (!authorizationResult.Succeeded)
        //        {
        //            string failureReasons = "";
        //            if (authorizationResult.Failure?.FailureReasons != null && authorizationResult.Failure.FailureReasons.Count() > 0)
        //            {
        //                failureReasons = String.Join(";", authorizationResult.Failure.FailureReasons.Select(reason => reason.Message));
        //            }
        //            _logger.LogError($"Authorization Failed for user {_currentUserInfo.CurrentUserId}. {failureReasons}");

        //            return StatusCodes.Status403Forbidden;
        //        }

        //        return StatusCodes.Status200OK;
        //    }
        //    catch (Exception exc)
        //    {
        //        _logger.LogError(exc, $"Error authorizing roles in archive");
        //        return StatusCodes.Status500InternalServerError;
        //    }
        //}
    }
}
