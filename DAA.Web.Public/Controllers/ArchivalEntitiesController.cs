using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Models.ArchiveEntities;
using DAA.Services.ArchivalEntities;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Public.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ArchivalEntitiesController :BaseApiController
    {
        private readonly IArchivalEntityPublicService _archivalEntityService;

        public ArchivalEntitiesController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<ArchivalEntitiesController> logger,
           IUserInfo userInfo,
           IArchivalEntityPublicService archivalEntityService)
           : base(localizer, logger, userInfo)
        {
            _archivalEntityService = archivalEntityService;
        }

        [AllowAnonymous]
        [HttpGet("{sysId?}")]
        public async Task<IActionResult> Get(Guid? sysId, [FromQuery] bool? hasExternalSource, [FromQuery] int? externalIdentifier)
        {
            try
            {
                if (sysId.HasValue && sysId.Value != Guid.Empty)
                {
                    try
                    {
                        await _archivalEntityService.CreateArchivalEntityReviewAsync(sysId, externalIdentifier);
                    }
                    catch (Exception exc)
                    {
                        _logger.LogError(exc, $"Error creating archival entity user review (sysId: {sysId}, extId: {externalIdentifier}, userId: {_currentUserInfo.CurrentUserId})");
                    }

                    return Success(await _archivalEntityService.GetArchivalEntityBySystemIdentifierAsync(sysId.Value));
                }
                else
                {
                    if (hasExternalSource.HasValue && hasExternalSource.Value && externalIdentifier.HasValue)
                    {
                        try
                        {
                            await _archivalEntityService.CreateArchivalEntityReviewAsync(sysId, externalIdentifier);
                        }
                        catch (Exception exc)
                        {
                            _logger.LogError(exc, $"Error creating archival entity user review (sysId: {sysId}, extId: {externalIdentifier}, userId: {_currentUserInfo.CurrentUserId})");
                        }

                        return Success(await _archivalEntityService.GetFromExternalSourceAsync(externalIdentifier.Value));
                    }
                    else
                    {
                        _logger.LogError($"Archival entity has no system identifier ({sysId}) and external source ({hasExternalSource} {externalIdentifier})");
                        return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                    }
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting archival entity {sysId}");
                return InternalServerError();
            }
        }
        [AllowAnonymous]
        [HttpPost("listByInventory/{inventorySysId?}")]
        public async Task<IActionResult> ListByInventory(
          DataSourceRequestModel model,
          Guid? inventorySysId,
          [FromQuery] bool inventoryHasExternalSource,
          [FromQuery] int? inventoryExternalIdentifier,
          [FromQuery] string? searchInventoryNumberString)
        {
            try
            {
                var arhivalEntities =
                    await _archivalEntityService.GetByInventoryIdentifierAsync(
                        model,
                        inventorySysId,
                        inventoryHasExternalSource,
                        inventoryExternalIdentifier,
                        searchInventoryNumberString);
                if (arhivalEntities?.Errors != null)
                {
                    _logger.LogError(string.Join(";", arhivalEntities.Errors));
                    return BadRequest(string.Join(";", arhivalEntities.Errors));
                }

                return Success(arhivalEntities);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting archival entities list");
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
                    ArchivalEntityPublicImportModel? result = await _archivalEntityService.GetArchivalEntityDraftBySysIdAsync(sysId);
                    return Success(result);
                }
                else
                {
                    _logger.LogError($"Archival entity has no system identifier ({sysId})");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting archival entity draft {sysId}");
                return InternalServerError();
            }
        }

        [HttpPost]
        public async Task<IActionResult> ModifyDraft(ArchivalEntityPublicImportModel model)
        {
            try
            {
                if (model == null)
                {
                    throw new ArgumentException(nameof(model));
                }

                var result = await _archivalEntityService.UpdateDraftAsync(model, _currentUserInfo.CurrentUserId);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(String.Join("; ", result.Errors));
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error modifying archival entity  draft {model}");
                return InternalServerError();
            }
        }
    }
}
