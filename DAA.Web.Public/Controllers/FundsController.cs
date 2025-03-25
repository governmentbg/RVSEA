using DAA.Extensions.Controller;
using DAA.Services.Funds;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Public.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FundsController : BaseApiController
    {
        private readonly IFundPublicService _fundService;

        public FundsController(IStringLocalizer<SharedResources> localizer,
           ILogger<FundsController> logger,
           IUserInfo userInfo,
           IFundPublicService fundService)
           : base(localizer, logger, userInfo)
        {
            _fundService = fundService;
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
                        await _fundService.CreateFundReviewAsync(sysId, externalIdentifier);
                    }
                    catch (Exception exc)
                    {
                        _logger.LogError(exc, $"Error creating fund user review (sysId: {sysId}, extId: {externalIdentifier}, userId: {_currentUserInfo.CurrentUserId})");
                    }

                    return Success(await _fundService.GetFundBySystemIdentifierAsync(sysId.Value));
                }
                else
                {
                    if (hasExternalSource.HasValue && hasExternalSource.Value && externalIdentifier.HasValue)
                    {
                        try
                        {
                            await _fundService.CreateFundReviewAsync(sysId, externalIdentifier);
                        }
                        catch (Exception exc)
                        {
                            _logger.LogError(exc, $"Error creating fund user review (sysId: {sysId}, extId: {externalIdentifier}, userId: {_currentUserInfo.CurrentUserId})");
                        }

                        return Success(await _fundService.GetFromExternalSourceAsync(externalIdentifier.Value));
                   }
                   else
                    {
                        _logger.LogError($"Fund has no system identifier ({sysId}) and external source ({hasExternalSource} {externalIdentifier})");
                       return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                    }
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting fund {sysId}");
                return InternalServerError();
            }
        }

      
    }
}
