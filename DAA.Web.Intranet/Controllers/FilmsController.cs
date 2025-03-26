using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Films;
using DAA.Models.Processes;
using DAA.Services.Authorization;
using DAA.Services.Films;
using DAA.Shared;
using DAA.Shared.Authorization;
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
    public class FilmsController : BaseApiController
    {
        private readonly IFilmService _filmService;
        //private readonly ISystemAuthorizationService _authorizationService;

        public FilmsController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IFilmService filmService,
           ISystemAuthorizationService authorizationService)
           : base(localizer, logger, userInfo, authorizationService)
        {
            _filmService = filmService;
            //_authorizationService = authorizationService;
        }

        [HttpPost("listall")]
        public async Task<IActionResult> ListAll(DataSourceRequestModel model, [FromQuery] bool? hasExternalSource)
        {
            try
            {
                if (hasExternalSource.HasValue && hasExternalSource.Value)
                {
                    var result = await _filmService.GetAllFromExternalSourceAsync(model);
                    if (result?.Errors != null)
                    {
                        _logger.LogError(String.Join(";", result.Errors));
                        return BadRequest(String.Join(";", result.Errors));
                    }

                    return Success(result);
                }
                else
                {
                    var result = _filmService.GetAll(model);
                    if (result?.Errors != null)
                    {
                        _logger.LogError(String.Join(";", result.Errors));
                        return BadRequest(String.Join(";", result.Errors));
                    }
                    
                    return Success(result);
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting films list");
                return InternalServerError();
            }
        }

        [HttpPost]
        public async Task<IActionResult> Post(FilmModel model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(_localizer.GetString("Error_InvalidData").Value);
            }

            try
            {
                var authResultStatusCode = await AuthorizeRolesInArchive(model.ArchiveId, new string[] { ApplicationRoleType.GroupI });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _filmService.CreateDraftAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating inventory number {model}");
                return InternalServerError();
            }
        }

        [HttpGet("nextNumber")]
        public async Task<IActionResult> GetNextInventoryNumber()
        {
            try
            {
                var result = await _filmService.GetNextInventoryNumber();

                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting next inventory number");
                return InternalServerError();
            }
        }

        [HttpGet("{sysId?}")]
        public async Task<IActionResult> Get(Guid? sysId, [FromQuery] bool? hasExternalSource, [FromQuery] int? externalIdentifier)
        {
            try
            {

                if (hasExternalSource.HasValue && hasExternalSource.Value && externalIdentifier.HasValue)
                {
                    return Success(await _filmService.GetFromExternalSourceAsync(externalIdentifier.Value));
                }
                else if (sysId.HasValue && sysId.Value != Guid.Empty)
                {
                    return Success(await _filmService.GetBySystemIdentifierAsync(sysId.Value));
                }
                else
                {
                    _logger.LogError($"Film has no system identifier ({sysId}) and external source ({hasExternalSource} {externalIdentifier})");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting film {sysId}");
                return InternalServerError();
            }
        }

        [HttpPut]
        public async Task<IActionResult> Put(FilmDraftModel model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(_localizer.GetString("Error_InvalidData").Value);
            }

            try
            {
                var authResultStatusCode = await AuthorizeRolesInArchive(model.ArchiveId, new string[] { ApplicationRoleType.GroupI });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _filmService.UpdateDraftAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error updating film {model.Id}");
                return InternalServerError();
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(Guid id)
        {
            try
            {
                int? archiveId = await _filmService.GetFilmArchiveAsync(id);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupI });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _filmService.DeleteFilmAsync(id);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(String.Join(";", result.Errors));
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting film {id}");
                return InternalServerError();
            }
        }

        [HttpDelete("draft/{id}")]
        public async Task<IActionResult> DeleteDraft(int id)
        {
            try
            {
                int? archiveId = await _filmService.GetFilmDraftArchiveAsync(id);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupI });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _filmService.DeleteDraftAsync(id);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(String.Join(";", result.Errors));
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting film {id}");
                return InternalServerError();
            }
        }

        [HttpPost("changeStep")]
        public async Task<IActionResult> ChangeStep(FilmChangeStepModel model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(_localizer.GetString("Error_InvalidData").Value);
            }

            var roles = new string[] { ApplicationRoleType.GroupI };
            if (IsRejectionStep(model))
            {
                roles = new string[] { ApplicationRoleType.GroupI, ApplicationRoleType.GroupG };
            }
            else if (IsApproveStep(model) || IsReturnForEditStep(model))
            {
                roles = new string[] { ApplicationRoleType.GroupG };
            }

            try
            {
                int? archiveId = await _filmService.GetFilmArchiveAsync(model.FilmSystemIdentifier);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, roles);
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _filmService.ChangeStepAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(result.ToString(false));
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error changing film step to {(int)model.StepType} for id {model.FilmId}");
                return InternalServerError();
            }
        }

        private bool IsRejectionStep(FilmChangeStepModel model)
        {
            return (model.StepType == ProcessStepType.Film_Rejection ||
                model.StepType == ProcessStepType.Film_AllRejection ||
                model.StepType == ProcessStepType.Film_CardRejection);
        }

        private bool IsApproveStep(FilmChangeStepModel model)
        {
            return (model.StepType == ProcessStepType.Film_Approval ||
                model.StepType == ProcessStepType.Film_AllApproval ||
                model.StepType == ProcessStepType.Film_CardApproval);
        }

        private bool IsReturnForEditStep(FilmChangeStepModel model)
        {
            return (model.StepType == ProcessStepType.Film_ReturnForEdit ||
                model.StepType == ProcessStepType.Film_ReturnAllForEdit ||
                model.StepType == ProcessStepType.Film_ReturnCardForEdit);
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

        [HttpPost("startProcess")]
        public async Task<IActionResult> StartProcess(ProcessModel model)
        {
            try
            {
                var result = await _filmService.StartProcessAsync(model);
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
                _logger.LogError(exc, $"Error starting process {model.ProcessTypeId}");
                return InternalServerError();
            }
        }



        [HttpPost("listAllFilmReviews")]
        [Roles(ApplicationRoleType.GroupI1)]
        public async Task<IActionResult> ListAllFilmReviews(DataSourceRequestModel model)
        {

            try
            {
                var result = _filmService.GetAllFilmReviews(model);
                if (result?.Errors != null)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting films list");
                return InternalServerError();
            }
        }

        [HttpPost("filmReview")]
        [Roles(ApplicationRoleType.GroupI1)]
        public async Task<IActionResult> FilmReview(FilmReviewModel model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(_localizer.GetString("Error_InvalidData").Value);
            }

            try
            {
                /*var authResultStatusCode = await AuthorizeRolesInArchive(model.ArchiveId, new string[] { ApplicationRoleType.GroupI });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }*/

                var result = await _filmService.CreateFilmReviewAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating inventory number {model}");
                return InternalServerError();
            }
        }

        [HttpPut("updateAccess")]
        [Roles(ApplicationRoleType.GroupI1)]
        public async Task<IActionResult> UpdateAccess(FilmReviewModel model)
        {
           
            try
            {
                var result = await _filmService.UpdateFilmReviewAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error updating film access {model}");
                return InternalServerError();
            }
        }
    }
}
