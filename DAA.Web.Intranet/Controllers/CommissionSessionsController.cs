using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Commission;
using DAA.Services.CommissionSessions;
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
    public class CommissionSessionsController : BaseApiController
    {
        private readonly ICommissionSessionService _commissionSessionService;

        public CommissionSessionsController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<BaseApiController> logger,
            IUserInfo userInfo,
            ICommissionSessionService commissionSessionService)
            : base(localizer, logger, userInfo)
        {
            _commissionSessionService = commissionSessionService;
        }

        [HttpPost("listall")]
        public IActionResult GetAll(DataSourceRequestModel model)
        {
            try
            {
                var result = _commissionSessionService.GetAllSessions(model);
                if (result?.Errors != null)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting commission sessions list");
                return InternalServerError();
            }
        }

        [HttpPost("list/upcoming")]
        public IActionResult GetUpcoming(DataSourceRequestModel model)
        {
            try
            {
                var result = _commissionSessionService.GetUpcomingSessions(model);
                if (result?.Errors != null)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting upcoming commission sessions list");
                return InternalServerError();
            }
        }

        [HttpPost("list/past")]
        public IActionResult GetPast(DataSourceRequestModel model)
        {
            try
            {
                var result = _commissionSessionService.GetPastSessions(model);
                if (result?.Errors != null)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting past commission sessions list");
                return InternalServerError();
            }
        }

        [HttpPost("create")]
        public async Task<IActionResult> Post(CommissionSessionModel model)
        {
            try
            {
                var createResult = await _commissionSessionService.CreateSessionAsync(model);
                if (!createResult.Succeeded)
                {
                    var message = createResult.RawErrors
                        ? _localizer.GetString("Error_ExecutingAction").ToString()
                        : createResult.ToString(false);
                    _logger.LogError(createResult.ToString());
                    return BadRequest(message);
                }

                return Success(createResult.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating commission session");
                return InternalServerError();
            }
        }
        [HttpPut("edit")]
        public async Task<IActionResult> Edit(CommissionSessionModel model)
        {
            try
            {
                var editResult = await _commissionSessionService.EditSessionAsync(model);
                if (!editResult.Succeeded)
                {
                    var message = editResult.RawErrors
                        ? _localizer.GetString("Error_ExecutingAction").ToString()
                        : editResult.ToString(false);
                    _logger.LogError(editResult.ToString());
                    return BadRequest(message);
                }

                return Success(editResult.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating commission session");
                return InternalServerError();
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> Get(int id)
        {
            try
            {
                return Success(await _commissionSessionService.GetSessionByIdAsync(id));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting commission session {id}");
                return InternalServerError();
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                var result = await _commissionSessionService.DeleteSessionAsync(id);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting commission session {id}");
                return InternalServerError();
            }
        }

        [HttpPost("generate")]
        public async Task<IActionResult> GenerateSessionProtocol([FromBody] SessionGenerateProtocolModel model)
        {
            try
            {
                var result = await _commissionSessionService.GenerateProtocol(model);
                if (!result.Succeeded)
                {
                    var message = result.RawErrors
                        ? _localizer.GetString("Error_ExecutingAction").ToString()
                        : result.ToString(false);
                    _logger.LogError(result.ToString());
                    return BadRequest(message);
                }
                return Success(result.Succeeded);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error generating minutes of meeting for session {model.SessionId}");
                return InternalServerError();
            }
        }

        [HttpGet("getProtocolContent/{id}")]
        public async Task<IActionResult> GetSessionProtocolContent(int id)
        {
            try
            {
                var ress = await _commissionSessionService.GetSessionProtocol(id);

                if (!ress.Succeeded)
                {
                    _logger.LogError(String.Join(";", ress.Errors));
                    return BadRequest(String.Join(";", ress.Errors));
                }

                return Success(ress.Data);

            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting commission session {id}");
                return InternalServerError();
            }
        }
        [HttpPut("rejectProtocol/{id}")]
        public async Task<IActionResult> RejectProtocol([FromRoute]int id,[FromBody]string rejectReason)
        {
            try
            {
                var ress = await _commissionSessionService.RejectProtocol(id,rejectReason);

                if (!ress.Succeeded)
                {
                    _logger.LogError(String.Join(";", ress.Errors));
                    return BadRequest(String.Join(";", ress.Errors));
                }

                return Success();

            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting commission session {id}");
                return InternalServerError();
            }
        }

        [HttpPut("editProtocolContent")]
        public async Task<IActionResult> EditSessionProtocol(SessionProtocolEditModel model)
        {
            try
            {
                var editResult = await _commissionSessionService.EditSessionProtocolContent(model);

                if (!editResult.Succeeded)
                {
                    _logger.LogError(String.Join(";", editResult.Errors));
                    return BadRequest(String.Join(";", editResult.Errors));
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error editing commission session protocol id {model}");
                return InternalServerError();
            }
        }

        [HttpPut("sendProtocolForApproval")]
        public async Task<IActionResult> SendProtocolForApproval([FromBody] int sessionId)
        {
            try
            {
                var approval = await _commissionSessionService.SendProtocolForApproval(sessionId);

                if (!approval.Succeeded)
                {
                    _logger.LogError(String.Join(";", approval.Errors));
                    return BadRequest(String.Join(";", approval.Errors));
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error sending commission session protocol for approval protocolId: {sessionId}");
                return InternalServerError();
            }
        }

        [HttpPut("approvalProtocol")]
        public async Task<IActionResult> ApprovalProtocol([FromBody] int sessionId)
        {
            try
            {
                var approval = await _commissionSessionService.ApprovalProtocol(sessionId);

                if (!approval.Succeeded)
                {
                    _logger.LogError(String.Join(";", approval.Errors));
                    return BadRequest(String.Join(";", approval.Errors));
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error sending commission session protocol for approval protocolId: {sessionId}");
                return InternalServerError();
            }
        }

        [HttpPut("upload")]
        public async Task<IActionResult> UploadSessionProtocol([FromForm]CommissionSessionUploadProtocolModel model)
        {
            try
            {
                var upload = await _commissionSessionService.UploadProtocolFile(model);

                if (!upload.Succeeded)
                {
                    _logger.LogError(String.Join(";", upload.Errors));
                    return BadRequest(String.Join(";", upload.Errors));
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error uploading commission session protocol file sessionId: {model.SessionId}");
                return InternalServerError();
            }
        }

        [HttpGet("download/{sessionId}")]
        public async Task<IActionResult> Download(int sessionId)
        {
            try
            {
                var file = await _commissionSessionService.GetFile(sessionId);
                if (file == null || file.Content == null)
                {
                    _logger.LogError($"File sessionId {sessionId} or file content is null");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                if (file.ContentType == null)
                {
                    file.ContentType = "text/plain";
                }

                return File(file.Content, file.ContentType, file.Name);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error downloading protocol document {sessionId}");
                return InternalServerError(ex.Message);
            }
        }


        [HttpPut("getProtocolData")]
        public async Task<IActionResult> GetProtocolData([FromBody] SessionProtocolEditModel model )
        {
            try
            {
                var result = await _commissionSessionService.GetProtocolData(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }
                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error updating session agenda item standpoint {model}");
                return InternalServerError();
            }
        }


        [HttpPut("editSessionAgendaList")]
        public async Task<IActionResult> EditSessionAgendaList([FromBody] SessionReportEditListModel model)
        {
            try
            {
                var result = await _commissionSessionService.EditSessionAgendaList(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }
                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error updating session agenda item standpoint {model}");
                return InternalServerError();
            }
        }
    }
}
