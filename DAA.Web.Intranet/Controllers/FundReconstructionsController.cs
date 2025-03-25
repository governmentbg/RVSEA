using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Models.FundReconstructions;
using DAA.Services.FundReconstructions;
using DAA.Services.Process;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Intranet.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class FundReconstructionsController : BaseApiController
    {
        private readonly IProcessService _processService;
        private readonly IFundReconstructionService _fundReconstructionService;


        public FundReconstructionsController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IProcessService processService,
           IFundReconstructionService fundReconstructionService)
           : base(localizer, logger, userInfo)
        {
            _processService = processService;
            _fundReconstructionService = fundReconstructionService;
        }

        [HttpGet("process/archivalEntity/{processId}")]
        public async Task<IActionResult> GetReconstructionArchivalEntities(int processId, [FromQuery]bool? target)
        {
            try
            {
                var process = await _processService.GetProcessAsync(processId);
                if (process == null)
                {
                    _logger.LogError($"Process {processId} does not exists");
                    return BadRequest(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }
                if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.ReconstructFundData)
                {
                    _logger.LogError($"Process {processId} is not type {ProcessType.ReconstructFundData}");
                    return BadRequest(string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
                }
                if (process.Completed)
                {
                    _logger.LogError($"Process {processId} is already completed");
                    return BadRequest(string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
                }
                if (target.HasValue && target.Value)
                {
                    return Success(_fundReconstructionService.GetTargetArchivalEntities(process.FundSystemIdentifier!.Value));
                }

                return Success(_fundReconstructionService.GetSourceArchivalEntities(process.FundSystemIdentifier!.Value));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc.ToString(), $"Error getting recontruction archival entities for process {processId}");
                return InternalServerError();
            }
        }

        [HttpGet("process/inventory/{processId}")]
        public async Task<IActionResult> GetReconstructionInventories(int processId, [FromQuery] bool? target)
        {
            try
            {
                var process = await _processService.GetProcessAsync(processId);
                if (process == null)
                {
                    _logger.LogError($"Process {processId} does not exists");
                    return BadRequest(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }
                if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.ReconstructFundData)
                {
                    _logger.LogError($"Process {processId} is not type {ProcessType.ReconstructFundData}");
                    return BadRequest(string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
                }
                if (process.Completed)
                {
                    _logger.LogError($"Process {processId} is already completed");
                    return BadRequest(string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
                }
                if (target.HasValue && target.Value)
                {
                    return Success(_fundReconstructionService.GetTargetInventories(process.FundSystemIdentifier!.Value));
                }

                return Success(_fundReconstructionService.GetSourceInventories(process.FundSystemIdentifier!.Value));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc.ToString(), $"Error getting recontruction inventories for process {processId}");
                return InternalServerError();
            }
        }

        [HttpGet("process/{processId}")]
        public async Task<IActionResult> GetReconstructionsByProcess(int processId, [FromQuery]int? availabilityStatus)
        {
            try
            {
                var process = await _processService.GetProcessAsync(processId);
                if (process == null)
                {
                    _logger.LogError($"Process {processId} does not exists");
                    return BadRequest(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }
                if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.ReconstructFundData)
                {
                    _logger.LogError($"Process {processId} is not type {ProcessType.ReconstructFundData}");
                    return BadRequest(string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
                }
                if (process.Completed)
                {
                    _logger.LogError($"Process {processId} is already completed");
                    return BadRequest(string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
                }

                return Success(_fundReconstructionService.GetReconstructionsByProcess(processId));

            }
            catch (Exception exc)
            {
                _logger.LogError(exc.ToString(), $"Error getting fund reconstructions for process {processId}");
                return InternalServerError();
            }
        }

        [HttpGet("process/byParent/{processId}")]
        public async Task<IActionResult> GetReconstructionsBySourceParent(
            int processId,
            [FromQuery] int availabilityStatus,
            [FromQuery] Guid? inventorySysId,
            [FromQuery] Guid? aeSysId,
            [FromQuery] bool target = false)
        {
            try
            {
                var process = await _processService.GetProcessAsync(processId);
                if (process == null)
                {
                    _logger.LogError($"Process {processId} does not exists");
                    return BadRequest(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }
                if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.ReconstructFundData)
                {
                    _logger.LogError($"Process {processId} is not type {ProcessType.ReconstructFundData}");
                    return BadRequest(string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
                }
                if (process.Completed)
                {
                    _logger.LogError($"Process {processId} is already completed");
                    return BadRequest(string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
                }
                
                if (target)
                {
                    return Success(
                        _fundReconstructionService.GetReconstructionsByTargetParent(
                            processId, 
                            availabilityStatus, 
                            inventorySysId, 
                            aeSysId));
                }

                return Success(
                        _fundReconstructionService.GetReconstructionsBySourceParent(
                            processId, 
                            availabilityStatus, 
                            inventorySysId, 
                            aeSysId));

            }
            catch (Exception exc)
            {
                _logger.LogError(exc.ToString(), $"Error getting fund reconstructions for process {processId}");
                return InternalServerError();
            }
        }

        [HttpPost("list")]
        public async Task<IActionResult> ListReconstructionsByProcess(DataSourceRequestModel model, [FromQuery] int processId)
        {
            try
            {
                var process = await _processService.GetProcessAsync(processId);
                if (process == null)
                {
                    _logger.LogError($"Process {processId} does not exists");
                    return BadRequest(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }
                if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.ReconstructFundData)
                {
                    _logger.LogError($"Process {processId} is not type {ProcessType.ReconstructFundData}");
                    return BadRequest(string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
                }
                if (process.Completed)
                {
                    _logger.LogError($"Process {processId} is already completed");
                    return BadRequest(string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
                }

                return Success(_fundReconstructionService.GetReconstructionsByProcess(model, processId));

            }
            catch (Exception exc)
            {
                _logger.LogError(exc.ToString(), $"Error getting fund reconstructions for process {processId}");
                return InternalServerError();
            }
        }

        [HttpPost]
        public async Task<IActionResult> CreateReconstruction(FundReconstructionModel model)
        {
            try
            {
                if (model == null)
                {
                    throw new ArgumentNullException(nameof(model));
                }

                var process = await _processService.GetProcessAsync(model.ProcessId);
                if (process == null)
                {
                    _logger.LogError($"Process {model.ProcessId} does not exists");
                    return BadRequest(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }
                if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.ReconstructFundData)
                {
                    _logger.LogError($"Process {model.ProcessId} is not type {ProcessType.ReconstructFundData}");
                    return BadRequest(string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
                }
                if (process.Completed)
                {
                    _logger.LogError($"Process {model.ProcessId} is already completed");
                    return BadRequest(string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
                }

                var result = await _fundReconstructionService.CreateReconstructionAsync(model);

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
                _logger.LogError(exc.ToString(), $"Error creating fund reconstruction for process {model.ProcessId}");
                return InternalServerError();
            }
        }

        [HttpPost("array")]
        public async Task<IActionResult> CreateReconstructions(IEnumerable<FundReconstructionModel> model)
        {
            try
            {
                if (model == null || !model.Any())
                {
                    throw new ArgumentNullException(nameof(model));
                }

                var processId = model.Select(rec => rec.ProcessId).Distinct().SingleOrDefault();

                var process = await _processService.GetProcessAsync(processId);
                if (process == null)
                {
                    _logger.LogError($"Process {processId} does not exists");
                    return BadRequest(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }
                if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.ReconstructFundData)
                {
                    _logger.LogError($"Process {processId} is not type {ProcessType.ReconstructFundData}");
                    return BadRequest(string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
                }
                if (process.Completed)
                {
                    _logger.LogError($"Process {processId} is already completed");
                    return BadRequest(string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
                }

                var result = await _fundReconstructionService.CreateReconstructionsAsync(model);

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
                _logger.LogError(exc.ToString(), $"Error creating fund reconstructions for process");
                return InternalServerError();
            }
        }

        [HttpPost("array/bySource")]
        public async Task<IActionResult> CreateOrUpdateReconstructionsBySource(IEnumerable<FundReconstructionModel> model)
        {
            try
            {
                if (model == null || !model.Any())
                {
                    throw new ArgumentNullException(nameof(model));
                }

                //Data should include only one process
                var processId = model.Select(rec => rec.ProcessId).Distinct().SingleOrDefault();
                
                var process = await _processService.GetProcessAsync(processId);
                if (process == null)
                {
                    _logger.LogError($"Process {processId} does not exists");
                    return BadRequest(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }
                if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.ReconstructFundData)
                {
                    _logger.LogError($"Process {processId} is not type {ProcessType.ReconstructFundData}");
                    return BadRequest(string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
                }
                if (process.Completed)
                {
                    _logger.LogError($"Process {processId} is already completed");
                    return BadRequest(string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
                }

                var result = await _fundReconstructionService.CreateOrUpdateReconstructionsBySourceAsync(model);
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
                _logger.LogError(exc.ToString(), $"Error creating fund reconstructions for process");
                return InternalServerError();
            }
        }

        [HttpPut("array/move/byTarget")]
        public async Task<IActionResult> UpdateMoveFundReconstructionsByTarget(IEnumerable<FundReconstructionModel> model)
        {
            try
            {
                if (model == null || !model.Any())
                {
                    throw new ArgumentNullException(nameof(model));
                }

                //Data should include only one process
                var processId = model.Select(rec => rec.ProcessId).Distinct().SingleOrDefault();
                
                var process = await _processService.GetProcessAsync(processId);
                if (process == null)
                {
                    _logger.LogError($"Process {processId} does not exists");
                    return BadRequest(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }
                if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.ReconstructFundData)
                {
                    _logger.LogError($"Process {processId} is not type {ProcessType.ReconstructFundData}");
                    return BadRequest(string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
                }
                if (process.Completed)
                {
                    _logger.LogError($"Process {processId} is already completed");
                    return BadRequest(string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
                }

                var result = await _fundReconstructionService.UpdateMoveFundReconstructionsByTargetAsync(model);
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
                _logger.LogError(exc.ToString(), $"Error updating move fund reconstructions for process");
                return InternalServerError();
            }
        }

        [HttpPut("merge")]
        public async Task<IActionResult> UpdateMergeFundReconstructionsByTarget(FundReconstructionModel model)
        {
            try
            {
                if (model == null)
                {
                    throw new ArgumentNullException(nameof(model));
                }

                var processId = model.ProcessId;

                var process = await _processService.GetProcessAsync(processId);
                if (process == null)
                {
                    _logger.LogError($"Process {processId} does not exists");
                    return BadRequest(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }
                if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.ReconstructFundData)
                {
                    _logger.LogError($"Process {processId} is not type {ProcessType.ReconstructFundData}");
                    return BadRequest(string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
                }
                if (process.Completed)
                {
                    _logger.LogError($"Process {processId} is already completed");
                    return BadRequest(string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
                }

                var result = await _fundReconstructionService.UpdateMergeFundReconstructionAsync(model);
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
                _logger.LogError(exc.ToString(), $"Error updating move fund reconstructions for process");
                return InternalServerError();
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteReconstruction(int id, [FromQuery]int processId)
        {
            try
            {
                var process = await _processService.GetProcessAsync(processId);
                if (process == null)
                {
                    _logger.LogError($"Process {processId} does not exists");
                    return BadRequest(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }
                if ((ProcessType)process.ProcessTypeId!.Value != ProcessType.ReconstructFundData)
                {
                    _logger.LogError($"Process {processId} is not type {ProcessType.ReconstructFundData}");
                    return BadRequest(string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), process.ProcessTypeTitle));
                }
                if (process.Completed)
                {
                    _logger.LogError($"Process {processId} is already completed");
                    return BadRequest(string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), process.ProcessTypeTitle));
                }


                var result = await _fundReconstructionService.DeleteFundReconstructionAsync(processId, id);
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
                _logger.LogError(exc.ToString(), $"Error deleting fund reconstruction for process");
                return InternalServerError();
            }
        }
    }
}
