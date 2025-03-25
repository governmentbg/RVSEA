using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Models.Funds;
using DAA.Services.Funds;
using DAA.Services.Numbers;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Intranet.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class FundsController : BaseApiController
    {
        private readonly IFundService _fundService;
        private readonly INumberService _generateNumberService;

        public FundsController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IFundService fundService,
           INumberService generateNumberService)
           : base(localizer, logger, userInfo)
        {
            _fundService = fundService;
            _generateNumberService = generateNumberService;
        }

        [HttpPost("listall")]
        public IActionResult ListAll(DataSourceRequestModel model)
        {
            try
            {
                var funds = _fundService.GetAll(model);
                if (funds?.Errors != null)
                {
                    _logger.LogError(String.Join(";", funds.Errors));
                    return BadRequest(String.Join(";", funds.Errors));
                }

                return Success(funds);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting funds list");
                return InternalServerError();
            }
        }

        [HttpGet("{sysId?}")]
        public async Task<IActionResult> Get(Guid? sysId, [FromQuery] bool? hasExternalSource, [FromQuery] int? externalIdentifier)
        {
            try
            {
                _logger.LogInformation($"Getting fund (sysId: {sysId}, hasExternalSource: {hasExternalSource}, externalIdentifier: {externalIdentifier}, userId: {_currentUserInfo.CurrentUserId})");

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
                _logger.LogError(exc, $"Error getting fund (sysId: {sysId}, extSrc: {hasExternalSource}, extId: {externalIdentifier})");
                return InternalServerError();
            }
        }

        [HttpPost("fund/{sysId}")]
        public async Task<IActionResult> CreateFundFromDraft(Guid sysId)
        {
            try
            {
                var fundResult = await _fundService.CreateOrUpdateFundFromDraftAsync(sysId);
                if (!fundResult.Succeeded)
                {
                    _logger.LogError(fundResult.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(fundResult.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating fund from draft {sysId}");
                return InternalServerError();
            }
        }
        
        [HttpPost]
        public async Task<IActionResult> Post(FundDraftModel model, [FromQuery]bool isCreate = false)
        {
            try
            {
                var result = await _fundService.CreateDraftAsync(model, isCreate);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                //Return created fund System Identifier
                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating fund draft {model}");
                return InternalServerError();
            }
        }

        [HttpPut]
        public async Task<IActionResult> Put(FundDraftModel model)
        {
            try
            {
                string checkErrorMessage = string.Empty;

                if (!string.IsNullOrWhiteSpace(model.Number))
                {
                    try
                    { 
                        var isNewFundNumberValid = await _generateNumberService.IsValidFundNumber(
                        model.ArchiveId!.Value, model.Number, model.NumberArray!, model.DescriptionLevelCode, model.SystemIdentifier);
                        if (!isNewFundNumberValid) 
                        {
                            _logger.LogError(string.Format(_localizer.GetString("Error_NumberIsAlreadyUsed").ToString(), model.Number));
                            return BadRequest(string.Format(_localizer.GetString("Error_NumberIsAlreadyUsed").ToString(), model.Number));
                        }
                    }
                    catch (ExternalConnectionException exc)
                    {
                        _logger.LogError(exc, $"Error checking fund number for fundSysId: {model.SystemIdentifier}");
                        checkErrorMessage = _localizer.GetString("Error_NoExternalConnection").ToString();
                    }
                    catch
                    {
                        throw;
                    }
                }                

                var result = await _fundService.UpdateDraftAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(checkErrorMessage);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error updating fund {model.SystemIdentifier}");
                return InternalServerError();
            }
        }

        [HttpDelete("{sysId}")]
        public async Task<IActionResult> DeleteFund(Guid sysId)
        {
            try
            {
                var result = await _fundService.DeleteFundAsync(sysId);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting fund {sysId}");
                return InternalServerError();
            }
        }
        
        [HttpDelete("draft/{id}")]
        public async Task<IActionResult> DeleteDraft(int id)
        {
            try
            {
                var result = await _fundService.DeleteDraftAsync(id);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting fund draft {id}");
                return InternalServerError();
            }
        }

        [HttpGet("search")]
        public IActionResult Search([FromQuery]string searchText, [FromQuery]int archiveCode)
        {
            try
            {
                var funds = Array.Empty<object>();//_fundService.GetShortBySearchText(searchText, archiveCode);

                return Success(funds);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting funds list");
                return InternalServerError();
            }
        }

        [HttpPost("fundPublicUsersReviews/{systemIdentifier?}")]
        public async Task<IActionResult> GetFundPublicUsersReviews(Guid? systemIdentifier)
        {
            try
            {
                var publicUserReveiws =
                    await _fundService.GetFundPublicUsersReviewsAsync(systemIdentifier);
                if (publicUserReveiws?.Errors != null)
                {
                    _logger.LogError(string.Join(";", publicUserReveiws.Errors));
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(publicUserReveiws);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting public user reviews for fund!");
                return InternalServerError();
            }
        }

    }
}
