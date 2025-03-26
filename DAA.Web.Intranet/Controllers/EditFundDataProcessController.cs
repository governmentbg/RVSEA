using DAA.Extensions.Controller;
using DAA.Models.Processes;
using DAA.Services.Authorization;
using DAA.Services.EditFundDataProcess;
using DAA.Services.Funds;
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
    public class EditFundDataProcessController : BaseApiController
    {
        private readonly IFundService _fundService;
        private readonly IEditFundDataProcessService _editFundDataProcessService;

        public EditFundDataProcessController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           ISystemAuthorizationService authorizationService,
           IFundService fundService,
           IEditFundDataProcessService editFundDataProcessService)
           : base(localizer, logger, userInfo, authorizationService)
        {
            _fundService = fundService;
            _editFundDataProcessService = editFundDataProcessService;
        }

        [NonAction]
        private async Task<int> AuthorizeAsync(Guid fundSysId, params string[] applicationRoles)
        {
            int? archiveId = await _fundService.GetArchiveIdAsync(fundSysId);

            var authorizationStatusCode =
                await AuthorizeAsync(archiveId, new ArchiveAuthorizationRequirement(applicationRoles));
            
            return authorizationStatusCode;
        }

        [NonAction]
        private async Task<int> AuthorizeAsync(int processId, params string[] applicationRoles)
        {
            int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(processId);

            var authorizationStatusCode =
                await AuthorizeAsync(archiveId, new ArchiveAuthorizationRequirement(applicationRoles));

            return authorizationStatusCode;
        }

        [HttpPost("start")]
        public async Task<IActionResult> StartProcess(ProcessModel model)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(model.FundSystemIdentifier!.Value, ApplicationRoleType.GroupB);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to start process {model.ProcessTypeId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editFundDataProcessService.StartProcessAsync(model);
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
        public async Task<IActionResult> CompleteProcess(int processId)
        {
            try
            {
                var result = await _editFundDataProcessService.CompleteProcessAsync(processId);
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
        public async Task<IActionResult> UndoProcessChanges(int processId)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(processId, ApplicationRoleType.GroupB);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to undo process changes in process {processId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editFundDataProcessService.UndoProcessChangesAsync(processId);
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
                _logger.LogError(exc, $"Error undoing process changes for {processId}");
                return InternalServerError();
            }
        }

        [HttpPost("changes/start")]
        public async Task<IActionResult> StartApplyingChanges(ProcessStepModel model)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(model.ProcessId, ApplicationRoleType.GroupB);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to execute step {model.StepTypeId} in process {model.ProcessId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editFundDataProcessService.StartApplyingChangesAsync(model);
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
                _logger.LogError(exc, $"Error executing step type {model.StepTypeId} for process {model.ProcessId}");
                return InternalServerError();
            }
        }

        [HttpPost("report/create")]
        public async Task<IActionResult> CreateReport(ProcessStepModel model)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(model.ProcessId, ApplicationRoleType.GroupB);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to execute step {model.StepTypeId} in process {model.ProcessId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editFundDataProcessService.CreateReportAsync(model);
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
                _logger.LogError(exc, $"Error executing EditFundData_CreateReport step for process for {model.ProcessId}");
                return InternalServerError();
            }
        }

        [HttpPost("report/send")]
        public async Task<IActionResult> SendReport(ProcessStepModel model)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(model.ProcessId, ApplicationRoleType.GroupB);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to execute step {model.StepTypeId} in process {model.ProcessId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editFundDataProcessService.SendReportAsync(model);
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
                _logger.LogError(exc, $"Error executing EditFundData_SendReport step for process for {model.ProcessId}");
                return InternalServerError();
            }
        }

        //[HttpPost("report/addtoagenda")]
        //public async Task<IActionResult> AddReportToSessionAgenda(ProcessStepModel model)
        //{
        //    try
        //    {
        //        var result = await _editFundDataProcessService.AddReportToSessionAgendaAsync(model);
        //        if (!result.Succeeded)
        //        {
        //            var message = result.RawErrors
        //                ? _localizer.GetString("Error_ExecutingAction").ToString()
        //                : result.ToString(false);
        //            _logger.LogError(result.ToString());
        //            return BadRequest(message);
        //        }

        //        return Success();
        //    }
        //    catch (Exception exc)
        //    {
        //        _logger.LogError(exc, $"Error executing EditFundData_AddReportToSessionAgenda step for process for {model.ProcessId}");
        //        return InternalServerError();
        //    }
        //}

        [HttpPost("report/approval")]
        public async Task<IActionResult> SendReportApprovalResult(ProcessStepModel model)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(model.ProcessId, ApplicationRoleType.GroupV1);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to execute step {model.StepTypeId} in process {model.ProcessId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editFundDataProcessService.SendReportApprovalResultAsync(model);
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
                _logger.LogError(exc, $"Error executing step type {model.StepTypeId} for process for {model.ProcessId}");
                return InternalServerError();
            }
        }

        [HttpPost("report/applychanges")]
        public async Task<IActionResult> ApplyReportModifications(ProcessStepModel model)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(model.ProcessId, ApplicationRoleType.GroupB);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to execute step {model.StepTypeId} in process {model.ProcessId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editFundDataProcessService.ApplyReportModificationsAsync(model);
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
                _logger.LogError(exc, $"Error executing step type {model.StepTypeId} for process for {model.ProcessId}");
                return InternalServerError();
            }
        }

        [HttpPost("report/sendchanges")]
        public async Task<IActionResult> SendReportModifications(ProcessStepModel model)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(model.ProcessId, ApplicationRoleType.GroupB);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to execute step {model.StepTypeId} in process {model.ProcessId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editFundDataProcessService.SendForModificationsRevisionAsync(model);
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
                _logger.LogError(exc, $"Error executing step type {model.StepTypeId} for process for {model.ProcessId}");
                return InternalServerError();
            }
        }

        [HttpPost("report/revision")]
        public async Task<IActionResult> ModificationsRevision(ProcessStepModel model)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(model.ProcessId, ApplicationRoleType.GroupV1);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to execute step {model.StepTypeId} in process {model.ProcessId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editFundDataProcessService.ModificationsRevisionAsync(model);
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
                _logger.LogError(exc, $"Error executing step type {model.StepTypeId} for process for {model.ProcessId}");
                return InternalServerError();
            }
        }

        [HttpPost("report/affirmation/send")]
        public async Task<IActionResult> SendForModificationsAffirmation(ProcessStepModel model)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(model.ProcessId, ApplicationRoleType.GroupV1);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to execute step {model.StepTypeId} in process {model.ProcessId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editFundDataProcessService.SendForModificationAffirmationAsync(model);
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
                _logger.LogError(exc, $"Error executing step type {model.StepTypeId} for process for {model.ProcessId}");
                return InternalServerError();
            }
        }

        [HttpPost("report/affirmation")]
        public async Task<IActionResult> ModificationsAffirmation(ProcessStepModel model)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(model.ProcessId, ApplicationRoleType.GroupG);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to execute step {model.StepTypeId} in process {model.ProcessId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editFundDataProcessService.SendModificationsAffirmationResultAsync(model);
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
                _logger.LogError(exc, $"Error executing step type {model.StepTypeId} for process for {model.ProcessId}");
                return InternalServerError();
            }
        }

        [HttpPost("agendaitem/send")]
        public async Task<IActionResult> SendToAddSessionAgendaStandpoint(ProcessStepModel model)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(model.ProcessId, ApplicationRoleType.GroupV1);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to execute step {model.StepTypeId} in process {model.ProcessId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editFundDataProcessService.SendToAddStandpointAsync(model);
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
                _logger.LogError(exc, $"Error executing step type {model.StepTypeId} for process for {model.ProcessId}");
                return InternalServerError();
            }
        }

        //[HttpPost("standpoint/send")]
        //public async Task<IActionResult> SendSessionAgendaStandpoint(ProcessStepModel model)
        //{
        //    try
        //    {
        //        var result = await _editFundDataProcessService.SendSessionAgendaStandpointAsync(model);
        //        if (!result.Succeeded)
        //        {
        //            var message = result.RawErrors
        //                ? _localizer.GetString("Error_ExecutingAction").ToString()
        //                : result.ToString(false);
        //            _logger.LogError(result.ToString());
        //            return BadRequest(message);
        //        }

        //        return Success();
        //    }
        //    catch (Exception exc)
        //    {
        //        _logger.LogError(exc, $"Error executing EditFundData_SendToAddSessionAgendaStandpoint step for process for {model.ProcessId}");
        //        return InternalServerError();
        //    }
        //}

        [HttpPost("standpoint/addcomment")]
        public async Task<IActionResult> SendToAddSessionAgendaStandpointComment(ProcessStepModel model)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(model.ProcessId, ApplicationRoleType.GroupV1);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to execute step {model.StepTypeId} in process {model.ProcessId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editFundDataProcessService.SendToAddCommentAsync(model);
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
                _logger.LogError(exc, $"Error executing EditFundData_SendToAddSessionAgendaStandpointComment step for process for {model.ProcessId}");
                return InternalServerError();
            }
        }

        [HttpPost("standpoint/createcomment")]
        public async Task<IActionResult> AddSessionAgendaStandpointComment(ProcessStepModel model)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(model.ProcessId, ApplicationRoleType.GroupB);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to execute step {model.StepTypeId} in process {model.ProcessId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editFundDataProcessService.AddCommentToSessionAgendaStandpointAsync(model);
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
                _logger.LogError(exc, $"Error executing EditFundData_AddSessionAgendaStandpointComment step for process for {model.ProcessId}");
                return InternalServerError();
            }
        }

        [HttpPost("standpoint/sendcomment")]
        public async Task<IActionResult> SendSessionAgendaStandpointComment(ProcessStepModel model)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(model.ProcessId, ApplicationRoleType.GroupB);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to execute step {model.StepTypeId} in process {model.ProcessId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editFundDataProcessService.SendCommentAsync(model);
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
                _logger.LogError(exc, $"Error executing EditFundData_SendToAddSessionAgendaStandpointComment step for process for {model.ProcessId}");
                return InternalServerError();
            }
        }

        [HttpPost("agendaitem/set")]
        public async Task<IActionResult> SetSessionAgendaItem(ProcessStepModel model)
        {
            try
            {
                var authorizationStatusCode = await AuthorizeAsync(model.ProcessId, ApplicationRoleType.GroupV1);
                if (authorizationStatusCode != StatusCodes.Status200OK)
                {
                    _logger.LogError($"Authorization failed. User {_currentUserInfo.CurrentUserId} is not authorized to execute step {model.StepTypeId} in process {model.ProcessId}. Status code {authorizationStatusCode}");
                    return StatusCode(authorizationStatusCode);
                }

                var result = await _editFundDataProcessService.SetSessionAgendaItemAsync(model);
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
                _logger.LogError(exc, $"Error executing EditFundData_CommissionSession step for process for {model.ProcessId}");
                return InternalServerError();
            }
        }

    }
}
