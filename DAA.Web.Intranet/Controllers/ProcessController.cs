using DAA.Extensions.Controller;
using DAA.Models.Processes;
using DAA.Services.Process;
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
    public class ProcessController : BaseApiController
    {
        private readonly IProcessService _processService;

        public ProcessController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IProcessService processService)
           : base(localizer, logger, userInfo)
        {
            _processService = processService;
        }

        [HttpGet("{processId}")]
        public async Task<IActionResult> GetProcess(int processId)
        {
            try
            {
                return Success(await _processService.GetProcessAsync(processId));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting process {processId}");
                return InternalServerError();
            }
        }

        [HttpGet("timeline/{processId}")]
        public async Task<IActionResult> GetTimeline(int processId)
        {
            try
            {
                return Success(await _processService.GetTimelineAsync(processId));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting timeline for process {processId}");
                return InternalServerError();
            }
        }

        //[HttpPost("startProcess")]
        //public async Task<IActionResult> StartProcess(ProcessModel model)
        //{
        //    try
        //    {
        //        var result = await _processService.StartProcessAsync(model);
        //        if (!result.Succeeded)
        //        {   var message = result.RawErrors 
        //                ? _localizer.GetString("Error_ExecutingAction").ToString() 
        //                : result.ToString(false);
        //            _logger.LogError(result.ToString());
        //            return BadRequest(message);
        //        }

        //        return Success(result.Data);
        //    }
        //    catch (Exception exc)
        //    {
        //        _logger.LogError(exc, $"Error starting process {model.ProcessTypeId}");
        //        return InternalServerError();
        //    }
        //}

        //[HttpPost("completeProcess/{id}")]
        //public async Task<IActionResult> CompleteProcess(int id)
        //{
        //    try
        //    {
        //        var result = await _processService.CompleteProcessAsync(id);
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
        //        _logger.LogError(exc, $"Error completing process {id}");
        //        return InternalServerError();
        //    }
        //}

        //[HttpPost("activestep/{processId}")]
        //public async Task<IActionResult> SetActiveStep(int processId, [FromQuery]int processStepType)
        //{
        //    try
        //    {
        //        var result = await _processService.SetActiveProcessStepAsync(processId, processStepType);
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
        //        _logger.LogError(exc, $"Error setting active process step {processStepType} for process {processId}");
        //        return InternalServerError();
        //    }
        //}

        [HttpGet("current/{entityType}")]
        public async Task<IActionResult> GetCurrentActiveProcess(string entityType, [FromQuery] Guid? entitySysId, [FromQuery]bool? includeParent, [FromQuery] int? externalIdentifier)
        {
            try
            {
                return Success(await _processService.GetCurrentActiveProcess(entityType, entitySysId, includeParent, externalIdentifier));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting active process for {entityType} {entitySysId}");
                return InternalServerError();
            }
        }

        [HttpGet("currentUser/inProcess/{processId}")]
        public async Task<IActionResult> GetIsCurrentUserInProcess(int processId)
        {
            try
           {
                return Success(await _processService.IsCurrentUserInProcessAsync(processId));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting if current user is in process {processId}");
                return InternalServerError();
            }
        }

        [HttpGet("currentUser/inStep/{processStepId}")]
        public async Task<IActionResult> GetIsCurrentUserInProcessStep(int processStepId, [FromQuery]int processId)
        {
            try
            {
                return Success(await _processService.IsCurrentUserInProcessStepAsync(processId, processStepId));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting if current user is in process step {processStepId} for process {processId}");
                return InternalServerError();
            }
        }


        [HttpGet("lastProcessType/{sysId}")]
        public async Task<IActionResult> LastProcessType(Guid sysId)
        {
            try
            {
                return Success(await _processService.GetLastProcessType(sysId));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting last process {sysId}");
                return InternalServerError();
            }
        }
        
    }
}
