using DAA.Extensions.Controller;
using DAA.Models.Commission;
using DAA.Models.Processes;
using DAA.Services.Authorization;
using DAA.Services.Funds;
using DAA.Services.ProcessRawInventoriesProcess;
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
    public class ProcessRawInventoriesProcessController : BaseApiController
    {
        private readonly IProcessRawInventoriesProcessService _processRawInventoriesProcessService;
        //private readonly ISystemAuthorizationService _authorizationService;
        private readonly IFundService _fundService;


        public ProcessRawInventoriesProcessController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IProcessRawInventoriesProcessService processRawInventoriesProcessService,
           ISystemAuthorizationService authorizationService,
           IFundService fundService)
           : base(localizer, logger, userInfo, authorizationService)
        {
            _processRawInventoriesProcessService = processRawInventoriesProcessService;
            //_authorizationService = authorizationService;
            _fundService = fundService;
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

        [HttpPost("start")]
        public async Task<IActionResult> StartProcess(ProcessModel model)
        {
            try
            {
                Guid fundGuid = model.FundSystemIdentifier != null ? model.FundSystemIdentifier.Value : Guid.Empty;
                int? archiveId = await _fundService.GetArchiveIdAsync(fundGuid);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupB });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.StartProcessAsync(model);
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

        [HttpPost("undochanges/{processId}")]
        public async Task<IActionResult> UndoProcessChanges(int processId)
        {
            try
            {
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(processId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupB });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.UndoProcessChangesAsync(processId);
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

        [HttpGet("getSelectedRawInventories/{sysId}")]
        public async Task<IActionResult> GetSelectedRawInventories(Guid sysId)
        {
            try
            {
                var result = await _processRawInventoriesProcessService.GetSelectedRawInventoriesForFundAsync(sysId);
                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting selected raw inventories for fund {sysId}");
                return InternalServerError();
            }
        }

        [HttpPost("saveSelectedRawInventories/{fundSystemIdentifier}")]
        public async Task<IActionResult> SaveSelectedRawInventories(Guid fundSystemIdentifier, [FromQuery] int processId, [FromQuery] string? selectedRawInventories)
        {
            try
            {
                int? archiveId = await _fundService.GetArchiveIdAsync(fundSystemIdentifier);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupB });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var selectedList = selectedRawInventories != null ? selectedRawInventories.ToLower().Split(',') : new string[] { };

                var result = await _processRawInventoriesProcessService.SaveSelectedRawInventoriesAsync(fundSystemIdentifier, processId, selectedList);
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
                _logger.LogError(exc, $"Error saving selected raw inventories {String.Join(',', selectedRawInventories!)} for fund {fundSystemIdentifier}");
                return InternalServerError();
            }
        }

        [HttpPost("createnormalinventories/{processId}")]
        public async Task<IActionResult> CreateNormalInventories(int processId)
        {
            try
            {
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(processId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupB });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.CreateNormalInventory(processId);
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
                _logger.LogError(exc, $"Error creating normal inventories for process {processId}");
                return InternalServerError();
            }
        }


        [HttpPost("report/create")]
        public async Task<IActionResult> CreateReport(ProcessStepModel model)
        {
            try
            {
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(model.ProcessId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupB });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.CreateReportAsync(model);
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
                _logger.LogError(exc, $"Error executing ProcessRawFundWithRawInventory_CreateReport step for process {model.ProcessId}");
                return InternalServerError();
            }
        }

        [HttpPost("report/send")]
        public async Task<IActionResult> SendReport(CommissionReportSubmitModel model)
        {
            try
            {
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(model.ProcessId!.Value);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupB });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.SendReportAsync(model);
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
                _logger.LogError(exc, $"Error executing ProcessRawFundWithRawInventory_StepReport step for process {model.ProcessId}");
                return InternalServerError();
            }
        }

        [HttpPost("report/addtoagenda")]
        public async Task<IActionResult> AddReportToSessionAgenda(ProcessStepModel model)
        {
            try
            {
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(model.ProcessId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupV1 });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.AddReportToSessionAgendaAsync(model);
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
                _logger.LogError(exc, $"Error executing step type {model.StepTypeId} for process {model.ProcessId}");
                return InternalServerError();
            }
        }

        [HttpPost("agendaitem/send")]
        public async Task<IActionResult> SendToAddSessionAgendaStandpoint(ProcessStepModel model)
        {
            try
            {
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(model.ProcessId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupV1 });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.SendToAddStandpointAsync(model);
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

        [HttpPost("standpoint/send")]
        public async Task<IActionResult> SendSessionAgendaStandpoint(ProcessStepModel model)
        {
            try
            {
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(model.ProcessId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupV1, ApplicationRoleType.GroupV4 });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.SendSessionAgendaStandpointAsync(model);
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

        [HttpPost("standpoint/addcomment")]
        public async Task<IActionResult> SendToAddSessionAgendaStandpointComment(ProcessStepModel model)
        {
            try
            {
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(model.ProcessId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupV1, ApplicationRoleType.GroupV4 });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.SendToAddCommentAsync(model);
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

        [HttpPost("standpoint/createcomment")]
        public async Task<IActionResult> AddSessionAgendaStandpointComment(ProcessStepModel model)
        {
            try
            {
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(model.ProcessId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupB });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.AddCommentToSessionAgendaStandpointAsync(model);
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

        [HttpPost("standpoint/sendcomment")]
        public async Task<IActionResult> SendSessionAgendaStandpointComment(ProcessStepModel model)
        {
            try
            {
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(model.ProcessId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupB });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.SendCommentAsync(model);
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

        [HttpPost("agendaitem/set")]
        public async Task<IActionResult> SetSessionAgendaItem(ProcessStepModel model)
        {
            try
            {
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(model.ProcessId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupV1, ApplicationRoleType.GroupV4 });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.SetSessionAgendaItemAsync(model);
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

        [HttpPost("report/approval")]
        public async Task<IActionResult> SendReportApprovalResult(ProcessStepModel model)
        {
            try
            {
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(model.ProcessId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupV1 });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.SendReportApprovalResultAsync(model);
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

        [HttpPost("changes/start")]
        public async Task<IActionResult> StartApplyingChanges(ProcessStepModel model)
        {
            try
            {
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(model.ProcessId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupB });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.StartApplyingChangesAsync(model);
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

        [HttpPost("report/applychanges")]
        public async Task<IActionResult> ApplyReportModifications(ProcessStepModel model)
        {
            try
            {
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(model.ProcessId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupB });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.ApplyReportModificationsAsync(model);
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
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(model.ProcessId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupB });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.SendForModificationsRevisionAsync(model);
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
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(model.ProcessId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupV1 });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.ModificationsRevisionAsync(model);
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
                var result = await _processRawInventoriesProcessService.SendForModificationAffirmationAsync(model);
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
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(model.ProcessId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupG });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.SendModificationsAffirmationResultAsync(model);
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


        [HttpPost("sendToRegistrar")]
        public async Task<IActionResult> SendToRegistrar(ProcessStepModel model)
        {
            try
            {
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(model.ProcessId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupB });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.SendToRegistrarAsync(model);
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

        [HttpPost("complete/{processId}")]
        public async Task<IActionResult> CompleteProcess(int processId)
        {
            try
            {
                int? archiveId = await _fundService.GetArchiveIdByProcessIdAsync(processId);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupA });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _processRawInventoriesProcessService.CompleteProcessAsync(processId);
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
                _logger.LogError(exc, $"Error completing process {processId}");
                return InternalServerError();
            }
        }


        [HttpDelete("document/{dratfId}")]
        public async Task<IActionResult> DeleteDocumentDraft(int dratfId)
        {
            try
            {
                var result = await _processRawInventoriesProcessService.DeleteDocumentDraftAsync(dratfId);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting document draft {dratfId}");
                return InternalServerError();
            }
        }

        [HttpDelete("archivalEntity/{draftId}")]
        public async Task<IActionResult> DeleteArchivalEntityDraft(int draftId)
        {
            try
            {
                var result = await _processRawInventoriesProcessService.DeleteArchivalEntityDraftAsync(draftId);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting archival entity draft {draftId}");
                return InternalServerError();
            }
        }


        [HttpPost("markInvaluableFiles/{inventorySysId}")]
        public async Task<IActionResult> MarkInvaluableFiles(Guid inventorySysId)
        {
            try
            {
                var result = await _processRawInventoriesProcessService.MarkInvaluableFilesAsync(inventorySysId);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error marking invaluable files for inventory {inventorySysId}");
                return InternalServerError();
            }
        }
        
        [HttpGet("fundHasRawInventoriesInSEA/{fundSysId}")]
        public async Task<IActionResult> HasRawInventoriesInSEA(Guid fundSysId)
        {
            try
            {
                var result = await _processRawInventoriesProcessService.FundHasRawInventoriesInSEAAsync(fundSysId);
                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error executing ProcessRawInventories_HasRawInventoriesInSEA for {fundSysId}");
                return InternalServerError();
            }
        }
    }
}
