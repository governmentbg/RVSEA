using DAA.Shared;
using DAA.Shared.Authorization;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System.Text;
using ISystemAuthorizationService = Microsoft.AspNetCore.Authorization.IAuthorizationService;

namespace DAA.Extensions.Controller
{
    [Route("api/[controller]")]
    [ApiController]
    public partial class BaseApiController : ControllerBase
    {
        protected readonly ILogger<BaseApiController> _logger;
        protected readonly IStringLocalizer<SharedResources> _localizer;
        protected readonly IUserInfo _currentUserInfo;
        protected readonly ISystemAuthorizationService _authorizationService;

        //protected const int MaxContentSizeInBytes = 104857600; // 100MB 
        protected const int MaxContentSizeInBytes = int.MaxValue;// ~2GB 
        protected const uint MaxMultipartContentSizeInBytes = uint.MaxValue; // ~4GB 

        public BaseApiController(
            IStringLocalizer<SharedResources> localizer = null!, 
            ILogger<BaseApiController> logger = null!, 
            IUserInfo userInfo = null!,
            ISystemAuthorizationService authorizationService = null!)
        {
            _localizer = localizer;
            _logger = logger;
            _currentUserInfo = userInfo;
            _authorizationService = authorizationService;
        }

        protected virtual string FormatMessage(OperationResult result, string defaultMessage)
        {
            var message = result.RawErrors
                                ? defaultMessage
                                : result.ToString(false);
            return message;
        }
        protected virtual ObjectResult InternalServerError()
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError, 
                new ResponseResult()
                {
                    Success = false,
                    Code = 500,
                    Message = _localizer.GetString("Error_500").ToString(),
                    ShowMessage = true,
                });
        }
        protected virtual ObjectResult InternalServerError(string message)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new ResponseResult()
                {
                    Success = false,
                    Code = 500,
                    Message = message,
                    ShowMessage = true,
                });
        }

        protected virtual BadRequestObjectResult BadRequest(string message = null!)
        {
            return BadRequest(
                new ResponseResult()
                {
                    Success = false,
                    Code = 400,
                    Message = message,
                    ShowMessage = !string.IsNullOrWhiteSpace(message)
                });
        }

        protected virtual OkObjectResult Success(string message = null!)
        {
            return Ok(
                new ResponseResult() 
                { 
                    Success = true, 
                    Code = 200, 
                    Message = message, 
                    ShowMessage = !string.IsNullOrWhiteSpace(message) 
                });
        }
        protected virtual OkObjectResult Success<T>(T data)
        {
            return Ok(new ResponseResult<T>() { Success = true, Code = 200, Data = data });
        }
        protected virtual OkObjectResult Success<T>(T data, string? message)
        {
            return Ok(
                new ResponseResult<T>()
                {
                    Success = true,
                    Code = 200,
                    Data = data,
                    Message = message,
                    ShowMessage = !string.IsNullOrWhiteSpace(message)
                });
        }

        protected virtual async Task<int> AuthorizeAsync(int? archiveId, IArchiveAuthorizationRequirement requirement)
        {
            try
            {
                AuthorizationResult authorizationResult =
                    await _authorizationService.AuthorizeAsync(_currentUserInfo.CurrentUser, archiveId, requirement);

                if (!authorizationResult.Succeeded)
                {
                    string failureReasons = "";
                    if (authorizationResult.Failure?.FailureReasons != null && authorizationResult.Failure.FailureReasons.Count() > 0)
                    {
                        failureReasons = String.Join(";", authorizationResult.Failure.FailureReasons.Select(reason => reason.Message));
                    }

                    _logger.LogError($"Authorization Failed for user {_currentUserInfo.CurrentUserId}. {failureReasons}");

                    return StatusCodes.Status403Forbidden;
                }

                return StatusCodes.Status200OK;
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error authorizing roles in archive");
                return StatusCodes.Status500InternalServerError;
            }
        }

    }
}
