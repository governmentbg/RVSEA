using DAA.Extensions.Controller;
using DAA.Models.Configuration;
using DAA.Services.Authorization;
using DAA.Services.Settings;
using DAA.Extensions.Exceptions;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using DocFlow.Models.File;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;
using ISystemAuthorizationService = Microsoft.AspNetCore.Authorization.IAuthorizationService;

namespace DAA.Web.Intranet.Controllers
{

    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class SettingsController : BaseApiController
    {
        private readonly ISettingsService _service;
        private readonly ISystemAuthorizationService _authorizationService;
        private readonly IOptions<ApplicationSettings> _appSettings;

        public SettingsController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           ISettingsService settingsService,
           ISystemAuthorizationService authorizationService,
           IOptions<ApplicationSettings> appSettings)
           : base(localizer, logger, userInfo)
        {
            _service = settingsService;
            _authorizationService = authorizationService;
            _appSettings = appSettings;
        }

        [HttpGet("download/fileUploaderApp/{version}")]
        public async Task<IActionResult> DownloadFileUploaderApp(int version)
        {
            try
            {
                var authResultStatusCode = await AuthorizeRolesInArchive(0, new string[] { ApplicationRoleType.GroupI, ApplicationRoleType.GroupJ, ApplicationRoleType.GroupZ });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                FileDownloadModel? file = await _service.GetFileUploaderApp(version);
                if (file == null || file.Data == null)
                {
                    _logger.LogError($"FileUploaderApp file or file content is null");
                    return BadRequest(_localizer.GetString("Error_FileUploaderFileNull").ToString());
                }

                return Success(file);
            }
            catch(CustomException ex)
            {
                _logger.LogError(ex, ex.Message);
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error downloading file uploader app");
                return InternalServerError(_localizer.GetString("Error_ExecutingAction").ToString());
            }
        }

        [AllowAnonymous]
        [HttpGet("Version")]
        public string GetVersion()
        {
            return String.IsNullOrWhiteSpace(_appSettings.Value.Version) ? "1.0.0" : _appSettings.Value.Version;
        }


        [HttpPut("converter")]
        public async Task<IActionResult> ConvertToPdf([FromForm] IFormFile? uploadedFile)
        {
            try
            {
                FileDownloadModel? file = await _service.ConvertToPdf(uploadedFile);
                if (file == null || file.Data == null)
                {
                    string msg = $"File {uploadedFile?.Name} could not be converted to pdf!";
                    _logger.LogError(msg);
                    return BadRequest(msg);
                }

                return Success(file);
            }
            catch (CustomException ex)
            {
                _logger.LogError(ex, ex.Message);
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                string msg = $"Error converting file to pdf";
                _logger.LogError(ex, msg);
                return InternalServerError(msg);
            }
        }


        [NonAction]
        private async Task<int> AuthorizeRolesInArchive(int? archiveId, IEnumerable<string> roles)
        {
            try
            {
                AuthorizationResult authorizationResult =
                await _authorizationService.AuthorizeAsync(
                    _currentUserInfo.CurrentUser,
                    archiveId,
                    new ArchiveAuthorizationRequirement(roles));

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
