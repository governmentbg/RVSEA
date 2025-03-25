using DAA.Extensions.Controller;
using DAA.Models.Documents.DocumentsProcedure;
using DAA.Services.Authorization;
using DAA.Services.DocsCreatingProc;
using DAA.Services.Process;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using ISystemAuthorizationService = Microsoft.AspNetCore.Authorization.IAuthorizationService;

namespace DAA.Web.Intranet.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class DocumentCreatingProcedureController : BaseApiController
    {
        private readonly IDocsCreatingProcedureService _documentService;

        public DocumentCreatingProcedureController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           ISystemAuthorizationService authorizationService,
           IProcessService processService,
           IDocsCreatingProcedureService documentService)
           : base(localizer, logger, userInfo, authorizationService)
        {
            _documentService = documentService;
        }


        [HttpPost("startProcess")]
        public async Task<IActionResult> StartProcess(DocumentProcedureCreateModel model)
        {
            var authResultStatusCode = await AuthorizeRolesInArchive(model.ArchiveId, new string[] { ApplicationRoleType.GroupB, ApplicationRoleType.GroupJ });

            if (authResultStatusCode != StatusCodes.Status200OK)
            {
                return Forbid();
            }
            try
            {
                var result = await _documentService.Start(model);

                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    return BadRequest(message!);
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error starting document creating procedure{model.DocumentSys}");
                return InternalServerError();
            }
        }

        [HttpGet("id/{id}")]
        public async Task<IActionResult> Get(string id)
        {
            try
            {
                var result = await _documentService.Get(id);
                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting view model 'document creating procedure'{id}");
                return InternalServerError();
            }
        }

        [HttpPut("nextStep")]
        [RequestFormLimits(ValueLengthLimit = MaxContentSizeInBytes, MultipartBodyLengthLimit = MaxMultipartContentSizeInBytes)]
        public async Task<IActionResult> GoToNextStep([FromForm] DocumentProcedureUpdateModel model)
        {
            try
            {
                var result = await _documentService.UpdateStep(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    return BadRequest(message!);
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error starting document creating procedure{model.Id}");
                return InternalServerError();
            }
        }

        [HttpPut("saveChanges")]
        [RequestFormLimits(ValueLengthLimit = MaxContentSizeInBytes, MultipartBodyLengthLimit = MaxMultipartContentSizeInBytes)]
        public async Task<IActionResult> SaveChanges([FromForm] DocumentProcedureUpdateModel model)
        {
            try
            {
                var result = await _documentService.SaveChanges(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    return BadRequest(message!);
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error with reverse step document creating procedure{model.Id}");
                return InternalServerError();
            }
        }

        [HttpPut("previousStep")]
        public async Task<IActionResult> GoToPreviousStep(DocumentProdecureViewModel model)
        {
            try
            {
                var result = await _documentService.StepBack(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    return BadRequest(message!);
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error with reverse step document creating procedure{model.Id}");
                return InternalServerError();
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
