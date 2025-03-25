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
    public class SessionAgendaController : BaseApiController
    {
        private readonly ISessionAgendaService _sessionAgendaService;

        public SessionAgendaController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           ISessionAgendaService sessionAgendaService)
           : base(localizer, logger, userInfo)
        {
            _sessionAgendaService = sessionAgendaService;
        }

        [HttpGet("list/{sessionId}")]
        public IActionResult ListSessionAgenda(int sessionId)
        {
            try
            {
                var sessionAgendaItems = _sessionAgendaService.GetSessionAgenda(sessionId);
                
                return Success(sessionAgendaItems);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting session agenda for session {sessionId}");
                return InternalServerError();
            }
        }

        [HttpGet("item/count/session/{sessionId}")]
        public async Task<IActionResult> GetCountBySessionId(int sessionId)
        {
            try
            {
                return Success(await _sessionAgendaService.GetSessionAgendaItemCountAsync(sessionId));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting session agenda item count for session {sessionId}");
                return InternalServerError();
            }
        }

        [HttpGet("standpoint/list/{itemId}")]
        public IActionResult ListAllStandpoints(int itemId)
        {
            try
            {
                var sessionAgendaItemStandpoints = _sessionAgendaService.GetAllSessionAgendaItemStandpoints(itemId);
                
                return Success(sessionAgendaItemStandpoints);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting session agenda item standpoints list");
                return InternalServerError();
            }
        }

        [HttpGet("standpoint/list/process/{processId}")]
        public IActionResult ListAllStandpointsByProcess(int processId)
        {
            try
            {
                var sessionAgendaItemStandpoints = _sessionAgendaService.GetAllSessionAgendaItemStandpointsByProcess(processId);

                return Success(sessionAgendaItemStandpoints);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting session agenda item standpoints list");
                return InternalServerError();
            }
        }

        [HttpGet("item/{id}")]
        public async Task<IActionResult> GetSessionAgendaItem(int id)
        {
            try
            {
                return Success(await _sessionAgendaService.GetSessionAgendaItemAsync(id));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting session agenda item {id}");
                return InternalServerError();
            }
        }

        [HttpGet("standpoint/{id}")]
        public async Task<IActionResult> GetSessionAgendaItemStandpoint(int id)
        {
            try
            {
                return Success(await _sessionAgendaService.GetSessionAgendaItemStandpointAsync(id));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting session agenda item standpoint {id}");
                return InternalServerError();
            }
        }

        [HttpGet("item/process/{processId}")]
        public async Task<IActionResult> GetSessionAgendaItemByProcess(int processId)
        {
            try
            {
                return Success(await _sessionAgendaService.GetSessionAgendaItemByProcessAsync(processId));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting session agenda item by process {processId}");
                return InternalServerError();
            }
        }

        [HttpGet("standpoint/item/{itemId}")]
        public async Task<IActionResult> GetSessionAgendaItemStandpointByItem(int itemId)
        {
            try
            {
                return Success(await _sessionAgendaService.GetSessionAgendaItemStandpointByItemAsync(itemId, _currentUserInfo.CurrentUserId!.Value));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting session agenda item standpoint by item {itemId}");
                return InternalServerError();
            }
        }

        [HttpGet("standpoint/process/{processId}")]
        public async Task<IActionResult> GetSessionAgendaItemStandpointByProcess(int processId)
        {
            try
            {
                return Success(await _sessionAgendaService.GetSessionAgendaItemStandpointByProcessAsync(processId, _currentUserInfo.CurrentUserId!.Value));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting session agenda item standpoint by process {processId}");
                return InternalServerError();
            }
        }

        [HttpPost("item")]
        public async Task<IActionResult> CreateSessionAgendaItem(SessionAgendaItemModel model)
        {
            try
            {
                var result = await _sessionAgendaService.CreateSessionAgendaItemAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                //Return created session agenda item id
                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating session agenda item");
                return InternalServerError();
            }
        }

        [HttpPost("standpoint")]
        public async Task<IActionResult> CreateSessionAgendaItemStandpoint(SessionAgendaItemStandpointModel model)
        {
            try
            {
                var result = await _sessionAgendaService.CreateSessionAgendaItemStandpointAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                //Return created session agenda item standpoint id
                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating session agenda item standpoint");
                return InternalServerError();
            }
        }

        [HttpPut("item")]
        public async Task<IActionResult> UpdateSessionAgendaItem(SessionAgendaItemModel model)
        {
            try
            {
                var result = await _sessionAgendaService.UpdateSessionAgendaItemAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                //Return created session agenda item id
                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error updating session agenda item {model.Id}");
                return InternalServerError();
            }
        }

        [HttpPut("standpoint")]
        public async Task<IActionResult> UpdateSessionAgendaItemStandpoint(SessionAgendaItemStandpointModel model)
        {
            try
            {
                var standpoint = await _sessionAgendaService.GetSessionAgendaItemStandpointAsync(model.Id!.Value);
                /*if (standpoint != null && !standpoint.IsDraft)
                {
                    _logger.LogWarning($"Session agenda item standpoint {model.Id} is not draft");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }*/

                var result = await _sessionAgendaService.UpdateSessionAgendaItemStandpointAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                //Return created session agenda item standpoint id
                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error updating session agenda item standpoint {model.Id}");
                return InternalServerError();
            }
        }

        [HttpPut("standpoint/status")]
        public async Task<IActionResult> SetSessionAgendaItemStandpointStatus(SessionAgendaItemStandpointModel model)
        {
            try
            {
                var standpoint = await _sessionAgendaService.GetSessionAgendaItemStandpointAsync(model.Id!.Value);
                if (standpoint == null )
                {
                    _logger.LogWarning($"Session agenda item standpoint {model.Id} does not exists.");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                standpoint.StatusCode = model.StatusCode;

                var result = await _sessionAgendaService.UpdateSessionAgendaItemStandpointAsync(standpoint);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error setting session agenda item standpoint {model.Id} status {model.StatusCode}");
                return InternalServerError();
            }
        }


        [HttpDelete("item/{id}")]
        public async Task<IActionResult> DeleteSessionAgendaItem(int id)
        {
            try
            {
                var result = await _sessionAgendaService.DeleteSessionAgendaItemAsync(id);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting session agenda {id}");
                return InternalServerError();
            }
        }
    }
}
