using DAA.Extensions.Controller;
using DAA.Extensions.Exceptions;
using DAA.Services.Numbers;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Intranet.Controllers
{
    public class NumberController : BaseApiController
    {
        private readonly INumberService _numberService;

        public NumberController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<NumberController> logger,
            IUserInfo userInfo, 
            INumberService numberService) : base(localizer, logger, userInfo)
        {
            _numberService = numberService;
        }

        [HttpGet("fund")]
        public async Task<IActionResult> GetFundNumberNumeric([FromQuery]int archiveId, [FromQuery]string descriptionLevel, [FromQuery] string fundArray)
        {
            try
            {
                try
                { 
                    var fundNumberNumeric = await _numberService.GetFundNumberNumeric(archiveId, descriptionLevel, fundArray);

                    return Success(fundNumberNumeric);
                }
                catch (ExternalConnectionException exc) 
                {
                    _logger.LogError(exc, $"Error getting fund number from external source.");
                    return BadRequest(_localizer.GetString("Error_NoExternalConnection").ToString());
                }
                catch
                {
                    throw;
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting fund number numeric");
                return InternalServerError();
            }
        }

        [HttpGet("inventory")]
        public async Task<IActionResult> GetInventoryNumberNumeric([FromQuery] int archiveId, [FromQuery] Guid fundSystemIdentifier, [FromQuery] string descriptionLevel, [FromQuery] string inventoryArray)
        {
            try
            {
                try
                {
                    var inventoryNumberNumeric = await _numberService.GetInventoryNumberNumeric(archiveId, fundSystemIdentifier, descriptionLevel, inventoryArray);

                    return Success(inventoryNumberNumeric);
                }
                catch (ExternalConnectionException exc)
                {
                    _logger.LogError(exc, $"Error getting inventory number from external source.");
                    return BadRequest(_localizer.GetString("Error_NoExternalConnection").ToString());
                }
                catch
                {
                    throw;
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting inventory number numeric (archiveId: {archiveId}, descriptionLevel: {descriptionLevel})");
                return InternalServerError();
            }
        }


        [HttpGet("archivalEntity")]
        public async Task<IActionResult> GetArchivalEntityNumberNumeric([FromQuery] int archiveId, [FromQuery] Guid inventorySystemIdentifier, [FromQuery] string descriptionLevel)
        {
            try
            {
                try
                {
                    var archivalEntityNumberNumeric = await _numberService.GetArchivalEntityNumberNumeric(archiveId, inventorySystemIdentifier, descriptionLevel);

                    return Success(archivalEntityNumberNumeric);
                }
                catch (ExternalConnectionException exc)
                {
                    _logger.LogError(exc, $"Error getting archival entity number from external source.");
                    return BadRequest(_localizer.GetString("Error_NoExternalConnection").ToString());
                }
                catch
                {
                    throw;
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting archival entity number numeric (archiveId: {archiveId}, inventorySysId: {inventorySystemIdentifier}, descriptionLevel: {descriptionLevel})");
                return InternalServerError();
            }
        }


        [HttpGet("document")]
        public async Task<IActionResult> GetDocumentNumberNumeric([FromQuery] int archiveId, [FromQuery] Guid inventorySystemIdentifier, [FromQuery] string archivalEntitySystemIdentifier)
        {
            try
            {
                try
                {
                    var documentNumberNumeric = await _numberService.GetDocumentNumberNumeric(archiveId, inventorySystemIdentifier, archivalEntitySystemIdentifier);

                    return Success(documentNumberNumeric);
                }
                catch (ExternalConnectionException exc)
                {
                    _logger.LogError(exc, $"Error getting document number from external source.");
                    return BadRequest(_localizer.GetString("Error_NoExternalConnection").ToString());
                }
                catch
                {
                    throw;
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting document number numeric (archiveId: {archiveId}, inventorySysId: {inventorySystemIdentifier}, archivalEntitySystemIdentifier: {archivalEntitySystemIdentifier})");
                return InternalServerError();
            }
        }

        //[HttpGet("getLastFundNumberExternal/{archive}/{fundArray}/{levelOfDescriptionCode}")]
        //public async Task<IActionResult> GetLastFundNumberExternal(int archive, string fundArray, int levelOfDescriptionCode)
        //{
        //    try
        //    {
        //        var fundNumber = await _numberService.GetLastFundNumberExternal(archive, fundArray, levelOfDescriptionCode);

        //        return Success(fundNumber);
        //    }
        //    catch (Exception exc)
        //    {
        //        base._logger.LogError(exc, "Error generating fund number");
        //        return InternalServerError();
        //    }
        //}

        //[HttpGet("generateInventoryNumber/{archive}/{fundExternalIdentifier}/{fundSystemIdentifier},{inventoryArray}/{levelOfDescriptionCode}")]

        //[HttpGet("getLastInventoryNumberExternal/{archive}/{fundExternalIdentifier}/{inventoryArray}/{levelOfDescriptionCode}")]
        //public async Task<IActionResult> GetLastInventoryNumberExternal(int archive, int fundExternalIdentifier, string inventoryArray, int levelOfDescriptionCode)
        //{
        //    try
        //    {
        //        var inventoryNumber = await _numberService.GetLastInventoryNumberExternal(archive, fundExternalIdentifier, inventoryArray, levelOfDescriptionCode);

        //        return Success(inventoryNumber);
        //    }
        //    catch (Exception exc)
        //    {
        //        base._logger.LogError(exc, "Error generating inventory number");
        //        return InternalServerError();
        //    }
        //}

        //[HttpGet("getNextArchivalEntityNumberExternal/{archive}/{inventoryExternalIdentifier}")]
        //public async Task<IActionResult> GetNextArchivalEntityNumberExternal(int archive, int inventoryExternalIdentifier)
        //{
        //    try
        //    {
        //        var searchDataResult = await _numberService.GetNextArchivalEntityNumberExternal(archive, inventoryExternalIdentifier);

        //        return Success(searchDataResult);
        //    }
        //    catch (Exception exc)
        //    {
        //        base._logger.LogError(exc, "Error generating archival entity number");
        //        return InternalServerError();
        //    }
        //}
    }
}
