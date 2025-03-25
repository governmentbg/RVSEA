using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Inventories;
using DAA.Services.Inventories;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Public.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class InventoriesController : BaseApiController
    {
       
        private readonly IInventoryPublicService _inventoryService;

        public InventoriesController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<InventoriesController> logger,
           IUserInfo userInfo,
           IInventoryPublicService inventoryService
         )
           : base(localizer, logger, userInfo)
        {
            _inventoryService = inventoryService;
        }

       
        [HttpGet("{sysId?}")]
        [AllowAnonymous]
        public async Task<IActionResult> Get(Guid? sysId, [FromQuery] bool? hasExternalSource, [FromQuery] int? externalIdentifier)
        {
            try
            {
                if (sysId.HasValue && sysId.Value != Guid.Empty)
                {
                    try
                    {
                        await _inventoryService.CreateInventoryReviewAsync(sysId, externalIdentifier);
                    }
                    catch (Exception exc)
                    {
                        _logger.LogError(exc, $"Error creating inventory user review (sysId: {sysId}, extId: {externalIdentifier}, userId: {_currentUserInfo.CurrentUserId})");
                    }

                    return Success(await _inventoryService.GetInventoryBySystemIdentifierAsync(sysId.Value));
                }
                else
                {
                    if (hasExternalSource.HasValue && hasExternalSource.Value && externalIdentifier.HasValue)
                    {
                        try
                        {
                            await _inventoryService.CreateInventoryReviewAsync(sysId, externalIdentifier);
                        }
                        catch (Exception exc)
                        {
                            _logger.LogError(exc, $"Error creating inventory user review (sysId: {sysId}, extId: {externalIdentifier}, userId: {_currentUserInfo.CurrentUserId})");
                        }

                        return Success(await _inventoryService.GetFromExternalSourceAsync(externalIdentifier.Value));
                    }
                    else
                    {
                        _logger.LogError($"Inventory has no system identifier ({sysId}) and external source ({hasExternalSource} {externalIdentifier})");
                        return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                    }
                }

            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting inventory {sysId}");
                return InternalServerError();
            }
        }
       
        [HttpPost("listbyfund/{fundSysId?}")]
        [AllowAnonymous]
        public async Task<IActionResult> ListByFund(DataSourceRequestModel model, Guid? fundSysId, [FromQuery] bool hasExternalSource, [FromQuery] int? externalIdentifier)
        {
            try
            {
                var inventories = await _inventoryService.GetByFundIdentifier(model, fundSysId, hasExternalSource, externalIdentifier);
                if (inventories?.Errors != null)
                {
                    _logger.LogError(String.Join(";", inventories.Errors));
                    return BadRequest(String.Join(";", inventories.Errors));
                }

                return Success(inventories);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting inventories list for fund");
                return InternalServerError();
            }
        }




        [HttpGet("getDraft/{sysId?}")]
        [Authorize]
        public async Task<IActionResult> GetDraft(Guid sysId)
        {
            try
            {
                if (sysId != Guid.Empty)
                {
                    InventoryPublicImportModel? result = await _inventoryService.GetInventoryDraftBySysIdAsync(sysId);
                    return Success(result);
                }
                else
                {
                    _logger.LogError($"Inventory has no system identifier ({sysId})");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting inventory draft {sysId}");
                return InternalServerError();
            }
        }

        [HttpPost]
        public async Task<IActionResult> ModifyDraft(InventoryPublicImportModel model)
        {
            try
            {
                if (model == null)
                {
                    throw new ArgumentException(nameof(model));
                }

                var result = await _inventoryService.UpdateDraftAsync(model, _currentUserInfo.CurrentUserId);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error modifying inventory draft {model}");
                return InternalServerError();
            }
        }


    }
}
