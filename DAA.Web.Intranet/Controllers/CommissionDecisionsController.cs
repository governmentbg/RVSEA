using DAA.Extensions.Controller;
using DAA.Models.Commission;
using DAA.Services.CommissionDecisions;
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
    public class CommissionDecisionsController: BaseApiController
    {
        private readonly ICommissionDecisionService _commissionDecisionService;
        public CommissionDecisionsController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<BaseApiController> logger,
            IUserInfo userInfo,
            ICommissionDecisionService commissionDecisionService)
            : base(localizer, logger, userInfo)
        {
            _commissionDecisionService = commissionDecisionService;
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            try
            {
                var decision = await _commissionDecisionService.GetByIdAsync(id);
                return Success(decision);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting commission decision {id}");
                return InternalServerError();
            }
        }

        [HttpGet("session/agenda/{sessionAgendaId}")]
        public async Task<IActionResult> GetBySessionAgendaId(int sessionAgendaId)
        {
            try
            {
                var decision = await _commissionDecisionService.GetBySessionAgendaIdAsync(sessionAgendaId);
                return Success(decision);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting commission decision for session agenda item {sessionAgendaId}");
                return InternalServerError();
            }
        }

        [HttpGet("process/{processId}")]
        public async Task<IActionResult> GetByProcessId(int processId)
        {
            try
            {
                var decision = await _commissionDecisionService.GetByProcessIdAsync(processId);
                return Success(decision);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting commission decision for process {processId}");
                return InternalServerError();
            }
        }

        [HttpGet("session/{sessionId}")]
        public IActionResult GetBySessionId(int sessionId)
        {
            try
            {
                var decisions = _commissionDecisionService.GetBySessionId(sessionId);
                return Success(decisions);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting commission decision for session {sessionId}");
                return InternalServerError();
            }
        }

        [HttpGet("count/session/{sessionId}")]
        public async Task<IActionResult> GetCountBySessionId(int sessionId)
        {
            try
            {
                return Success(await _commissionDecisionService.GetCommissionSessionDecisionCountAsync(sessionId));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting commission decision count for session {sessionId}");
                return InternalServerError();
            }
        }

        [HttpPost]
        public async Task<IActionResult> Post(CommissionDecisionModel model)
        {
            try
            {
                var result = await _commissionDecisionService.CreateDecisionAsync(model);
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
                _logger.LogError(exc, $"Error creating commission deicision");
                return InternalServerError();
            }
        }

        [HttpPut]
        public async Task<IActionResult> Put(CommissionDecisionModel model)
        {
            try
            {
                var result = await _commissionDecisionService.UpdateDecisionAsync(model);
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
                _logger.LogError(exc, $"Error creating commission deicision");
                return InternalServerError();
            }
        }

        [HttpPost("createOrUpdate")]
        public async Task<IActionResult> Create(CommissionDecisionModel model)
        {
            try
            {
                var create = await _commissionDecisionService.CreateOrUpdate(model);
                return Success(create);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error create or update EPK decision model{model}");
                return InternalServerError();
            }
        }
        [HttpGet("download/{agendaId}")]
        public async Task<IActionResult> Download(int agendaId)
        {
            try
            {
                var file = await _commissionDecisionService.GetFile(agendaId);
                if (file == null || file.Content == null)
                {
                    _logger.LogError($"File agendaId {agendaId} or file content is null");
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
                _logger.LogError(ex, $"Error downloading protocol file agendaId {agendaId}");
                return InternalServerError(ex.Message);
            }
        }


        //[HttpGet("{id}")]
        //public async Task<IActionResult> GetDecisionById(int id)
        //{
        //    try
        //    {
        //        var result = await _commissionDecisionService.GetById(id);
        //        return Success(result);
        //    }
        //    catch (Exception exc)
        //    {
        //        _logger.LogError(exc, $"Error getting view model 'EPK decision model'{id}");
        //        return InternalServerError();
        //    }
        //}
    }
}