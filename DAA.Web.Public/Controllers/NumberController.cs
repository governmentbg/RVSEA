using DAA.Extensions.Controller;
using DAA.Extensions.Exceptions;
using DAA.Services.Numbers;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Public.Controllers
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

    }
}
