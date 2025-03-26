using DAA.Data;
using DAA.Extensions.Controller;
using DAA.Models.DeductionProcess;
using DAA.Services.Authorization;
using DAA.Services.DeductionProcess;
using DAA.Services.Process;
using DAA.Shared;
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
    [Authorize]
    public class DeductionProcessController : BaseApiController
    {
        private readonly IDeductionProcessService _service;
        //private readonly ISystemAuthorizationService _authorizationService;
        public DeductionProcessController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<BaseApiController> logger,
            IUserInfo userInfo,
            ISystemAuthorizationService authorizationService,
           IDeductionProcessService service)
            : base(localizer, logger, userInfo, authorizationService)
        {
            //_authorizationService = authorizationService;
            _service = service;
        }
        [Authorize]
        [HttpPost("create")]
        public async Task<IActionResult> Create(DeductionCreateModel model)
        {
            var authResultStatusCode = await AuthorizeRolesInArchive(model.ArchiveId, new string[] { ApplicationRoleType.GroupB });

            if (authResultStatusCode != StatusCodes.Status200OK)
            {
                return Forbid();
            }

            try
            {
                var result = await _service.Start(model);

                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    return BadRequest(message!);
                }

                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error starting deduction procedure");
                return InternalServerError();
            }
        }
        [HttpGet("{sysId}")]
        public async Task<IActionResult> GetByEntityId(Guid sysId, [FromQuery] string entityType)
        {
            try
            {
                var result = await _service.Get(sysId, entityType);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    return BadRequest(message!);
                }
                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting view model 'deduction process'{sysId}");
                return InternalServerError();
            }
        }
        [HttpPut("updateStep")]
        public async Task<IActionResult> UpdateStep(DeductionViewModel model)
        {
            try
            {
                var result = await _service.UpdateStep(model);

                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    return BadRequest(message);
                }

                return Success(result.Succeeded);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error by updating step deduction prodess{model.Id}");
                return InternalServerError();
            }
        }
        [HttpPut("stepBack")]
        public async Task<IActionResult> StepBack(DeductionViewModel model)
        {
            try
            {
                var result = await _service.StepBack(model);

                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    return BadRequest(message!);
                }

                return Success(result.Succeeded);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error by decrement step deduction prodess{model.Id}");
                return InternalServerError();
            }
        }
        [HttpPut("save")]
        public async Task<IActionResult> Save(DeductionViewModel model)
        {
            try
            {
                var result = await _service.SaveChanges(model);

                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    return BadRequest(message!);
                }

                return Success(result.Succeeded);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error by save news deduction prodess{model.Id}");
                return InternalServerError();
            }
        }
        [HttpPut("terminate")]
        public async Task<IActionResult> ТerminateProcess(DeductionViewModel model)
        {
            try
            {
                var result = await _service.ТerminateProcess(model, false);

                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    return BadRequest(message!);
                }

                return Success(result.Succeeded);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error by save news deduction prodess{model.Id}");
                return InternalServerError();
            }
        }
        [HttpPut("undoChanges")]
        public async Task<IActionResult> UndoChanges(DeductionViewModel model)
        {
            var authResultStatusCode = await AuthorizeRolesInArchive(model.ArchiveId, new string[] { ApplicationRoleType.GroupB });

            if (authResultStatusCode != StatusCodes.Status200OK)
            {
                _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to undo process changes in process {model.Id}. Status code {authResultStatusCode}");
                return StatusCode(authResultStatusCode);
            }

            try
            {
                var result = await _service.ТerminateProcess(model, true);

                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    return BadRequest(message!);
                }

                return Success(result.Succeeded);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error by save news deduction prodess{model.Id}");
                return InternalServerError();
            }
        }
        [NonAction]
        private async Task<int> AuthorizeRolesInArchive(int? archiveId, IEnumerable<string> roles)
        {
            try
            {
                AuthorizationResult authorizationResult =
                await _authorizationService.AuthorizeAsync(
                    _currentUserInfo.CurrentUser,
                    archiveId,
                    new ArchiveAuthorizationRequirement(roles));

                if (!authorizationResult.Succeeded)
                {
                    string failureReasons = "";
                    if (authorizationResult.Failure?.FailureReasons != null && authorizationResult.Failure.FailureReasons.Count() > 0)
                    {
                        failureReasons = String.Join(";", authorizationResult.Failure.FailureReasons.Select(reason => reason.Message));
                    }
                    _logger.LogError($"Authorization Failed for user {_currentUserInfo.CurrentUserId}. {failureReasons}");

                    return StatusCodes.Status403Forbidden;
                }

                return StatusCodes.Status200OK;
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error authorizing roles in archive");
                return StatusCodes.Status500InternalServerError;
            }
        }
    }
}
