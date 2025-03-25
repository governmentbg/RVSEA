using DAA.Extensions.Controller;
using DAA.Models.Processes;
using DAA.Services;
using DAA.Services.Authorization;
using DAA.Services.EditDataProcess;
using DAA.Shared.Authorization;
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
    public class EditDataProcessController : BaseApiController
    {
        private readonly IEditDataProcessService _editDataProcessService;

        public EditDataProcessController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<BaseApiController> logger,
            IUserInfo userInfo,
            ISystemAuthorizationService authorizationService,
            IEditDataProcessService editDataProcessService)
           : base(localizer, logger, userInfo, authorizationService)
        {
            _editDataProcessService = editDataProcessService;
        }

        [NonAction]
        private async Task<int> AuthorizeAsync(ProcessModel process, params string[] applicationRoles)
        {
            int? archiveId = await _editDataProcessService.GetEntityArchiveIdAsync(process);

            var authorizationStatusCode =  await AuthorizeAsync(archiveId, new ArchiveAuthorizationRequirement(applicationRoles));

            return authorizationStatusCode;
        }

        [NonAction]
        private async Task<int> AuthorizeAsync(int processId, params string[] applicationRoles)
        {

            int? archiveId = await _editDataProcessService.GetEntityArchiveIdAsync(processId);

            var authorizationStatusCode =
                await AuthorizeAsync(archiveId, new ArchiveAuthorizationRequirement(applicationRoles));

            return authorizationStatusCode;
        }

        [HttpPost("start")]
        //[Admin(AdminType.GlobalAdmin,AdminType.Admin)]
        public async Task<IActionResult> StartProcess(ProcessModel model)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(model, ApplicationRoleType.GroupB1);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to start process {model.ProcessTypeId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editDataProcessService.StartProcessAsync(model);
                if (!result.Succeeded)
                {
                    var message = result.RawErrors
                        ? _localizer.GetString("Error_ExecutingAction").ToString()
                        : result.ToString(false);
                    _logger.LogError(result.ToString());
                    return BadRequest(message);
                }

                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error starting process {model.ProcessTypeId}");
                return InternalServerError();
            }
        }

        [HttpPost("complete/{processId}")]
        //[Admin(AdminType.GlobalAdmin, AdminType.Admin)]
        public async Task<IActionResult> CompleteProcess(int processId)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(processId, ApplicationRoleType.GroupB1);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to complete process {processId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editDataProcessService.CompleteProcessAsync(processId);
                if (!result.Succeeded)
                {
                    var message = result.RawErrors
                        ? _localizer.GetString("Error_ExecutingAction").ToString()
                        : result.ToString(false);
                    _logger.LogError(result.ToString());
                    return BadRequest(message);
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error completing process for {processId}");
                return InternalServerError();
            }
        }

        [HttpPost("undochanges/{processId}")]
        //[Admin(AdminType.GlobalAdmin, AdminType.Admin)]
        public async Task<IActionResult> UndoProcessChanges(int processId)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(processId, ApplicationRoleType.GroupB1);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to undo process changes in process {processId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editDataProcessService.UndoProcessChangesAsync(processId);
                if (!result.Succeeded)
                {
                    var message = result.RawErrors
                        ? _localizer.GetString("Error_ExecutingAction").ToString()
                        : result.ToString(false);
                    _logger.LogError(result.ToString());
                    return BadRequest(message);
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error undoing process changes in process for {processId}");
                return InternalServerError();
            }
        }

    }
}
