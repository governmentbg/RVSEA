using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Applications;
using DAA.Models.Commission;
using DAA.Models.DocsCollectionProcedure;
using DAA.Models.Processes;
using DAA.Services.DocsCollectingProc;
using DAA.Services.Process;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Public.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [ApiExplorerSettings(IgnoreApi = true)]
    [Authorize]
    public class CollectingProcedureController : BaseApiController
    {
        private readonly IDocsCollectingProcedureService _procService;
        private readonly IProcessService _processService;

        public CollectingProcedureController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<BaseApiController> logger,
            IDocsCollectingProcedureService procService,
            IProcessService processService)
            : base(localizer, logger)
        {
            _procService = procService;
            _processService = processService;
        }

        [HttpPost("List")]
        public ActionResult List(DataSourceRequestModel model)
        {
            var result = _procService.List(model);
            return Success(result);
        }

        [HttpPost("CommitComitteeReport")]
        public async Task<IActionResult> CommitComitteeReport(CommissionReportSubmitModel model)
        {
            if (model.ProcessId.HasValue)
            {
                try
                {
                    var result = await _procService.CommitComitteeReport(model);
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
                    _logger.LogError(exc, "Error sending commission report");
                    return InternalServerError();
                }                
            }

            return BadRequest();
        }

        [HttpPost("SendForStandpoints")]
        public async Task<IActionResult> SendForStandpoints(CommissionReportSubmitModel model)
        {
            if (!model.ProcessId.HasValue)
            {
                _logger.LogError($"{nameof(SendForStandpoints)}: Missing process id.");
                return BadRequest(_localizer.GetString("Error_InvalidData"));
            }

            try
            {
                var result = await _procService.SendForStandpoints(model);
                if (!result.Succeeded)
                {
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    _logger.LogError(result.ToString());
                    return BadRequest(message!);
                }
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, $"Error sending report for standpoints (processId: {model.ProcessId})");
                return InternalServerError();
            }
        }

        [HttpPost("ReturnReport")]
        public async Task<IActionResult> ReturnReport(RejectModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    var result = await _procService.RejectReport(model);
                    if (!result.Succeeded)
                    {
                        var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                        _logger.LogError(result.ToString());
                        return BadRequest(message!);
                    }

                    return Success();
                }
                catch (Exception e)
                {
                    _logger.LogError(e.ToString());
                    return InternalServerError();
                }
            }

            return BadRequest();
        }

        [HttpPost("ReturnCommissionChanges")]
        public async Task<IActionResult> ReturnCommissionChanges(ProcessStepModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    await _procService.ReturnCommissionChanges(model);
                    return Ok();
                }
                catch (Exception e)
                {
                    return InternalServerError(e.Message);
                }
            }

            return BadRequest();
        }

        [HttpPost("report/approval")]
        public async Task<IActionResult> ProcessApprovalResult(ProcessDecisionModel model)
        {
            try
            {
                //var result = await _procService.ApplyCommissionDecision(model);
                var result = await _procService.SendCommissionDecisionApprovalResultAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());

                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    return BadRequest(message!);
                }

                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, "ERROR applying process decision.", model);
                return InternalServerError();
            }
        }

        [HttpPost("report/affirmation")]
        public async Task<IActionResult> ProcessAffirmationResult(ProcessDecisionModel model)
        {
            try
            {
                //var result = await _procService.ApplyCommissionDecision(model);
                var result = await _procService.SendModificationsAffirmationResultAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    return BadRequest(message!);
                }

                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, "ERROR apllying process decision.", model);
                return InternalServerError();
            }
        }

        [HttpPost("report/redirect")]
        public async Task<IActionResult> ProcessRedirectResult(ProcessDecisionModel model)
        {
            try
            {
                var result = await _procService.RedirectToArchiveAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());

                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    return BadRequest(message!);
                }

                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, "ERROR redirecting to archive.", model);
                return InternalServerError();
            }
        }

        [HttpPost("MoveToNextStep")]
        public async Task<IActionResult> MoveToNextStep(ProcessStepModel model)
        {
            try
            { 
                //var result = await _processService.MoveToNextStep(model);
                var result = await _procService.MoveToNextStepAsync(model);
                if (!result.Succeeded)
                {
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    _logger.LogError(result.ToString());
                    return BadRequest(message!);
                }
                return Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error moving to next process step (processId: {model.ProcessId}, processStepId: {model.Id}, processStepTypeid: {model.StepTypeId})");
                return InternalServerError();
            }
        }

        [HttpPost("MoveToStep")]
        public async Task<IActionResult> MoveToStep(ProcessStepModel model)
        {
            await _processService.SetActiveProcessStepAsync(model);
            return Ok();
        }

        [HttpPost("ModificationRequest/{processId}")]
        public async Task<IActionResult> SendModificationRequest([FromRoute] int processId, [FromBody]string comment)
        {
            try
            {
                var result = await _procService.SendFundCreatorModificationRequestAsync(processId, comment);
                if(!result.Succeeded)
                {
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    _logger.LogError(result.ToString());
                    return BadRequest(message!);
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error sending modification request");
                return InternalServerError();
            }
        }

        [HttpPost("SignatureRequest")]
        public async Task<IActionResult> SendSignatureRequest([FromQuery]int processId, [FromQuery]int packageId, [FromQuery]IEnumerable<int> packageDocumentId)
        {
            try
            {
                var result = await _procService.SendFundCreatorSignatureRequest(processId, packageId, packageDocumentId);
                if (!result.Succeeded)
                {
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    _logger.LogError(result.ToString());
                    return BadRequest(message!); 
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error sending signature request");
                return InternalServerError();
            }
        }

        [HttpPost("SendForRegistration")]
        public async Task<IActionResult> SendForRegistration(ProcessStepModel model)
        {
            try
            {
                var result = await _procService.SendForRegistration(model);
                if (!result.Succeeded)
                {
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    _logger.LogError(result.ToString());
                    return BadRequest(message!);
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error sending for registration (processId: {model.ProcessId}, stepTypeId: {model.StepTypeId})");
                return InternalServerError();
            }
        }

        [HttpPost("completeProcess/{id}")]
        public async Task<IActionResult> CompleteProcess([FromRoute]int id)
        {
            try
            { 
                var result = await _procService.CompleteProcess(id);
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
                _logger.LogError(exc.ToString());
                return InternalServerError();
            }
        }

        [HttpGet("isExternalProcedure/{processId}")]
        public async Task<IActionResult> IsExternalProcedure(int processId)
        {
            return Success(await _procService.IsExternalCollectingProcedure(processId));
        }

        [HttpGet("application/status/{processId}")]
        public async Task<IActionResult> GetApplicationStatus(int processId)
        {
            try
            {
                return Success(await _procService.GetApplicationStatusAsync(processId));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error sending modification request");
                return InternalServerError();
            }
        }
    }
}