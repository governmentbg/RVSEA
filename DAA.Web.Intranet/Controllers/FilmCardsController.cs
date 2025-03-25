using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Films;
using DAA.Services.Authorization;
using DAA.Services.Films;
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
    public class FilmCardsController : BaseApiController
    {
        private readonly IFilmCardService _filmCardService;
        //private readonly ISystemAuthorizationService _authorizationService;

        public FilmCardsController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IFilmCardService filmCardService,
           ISystemAuthorizationService authorizationService)
           : base(localizer, logger, userInfo, authorizationService)
        {
            _filmCardService = filmCardService;
            //_authorizationService = authorizationService;
        }

        [HttpPost("listall/{filmSysId}")]
        public async Task<IActionResult> ListAll(DataSourceRequestModel model, Guid? filmSysId, [FromQuery] bool? hasExternalSource, [FromQuery] int? externalIdentifier)
        {
            try
            {
                if (hasExternalSource.HasValue && hasExternalSource.Value && externalIdentifier.HasValue)
                {
                    var result = await _filmCardService.GetAllFromExternalSourceAsync(model, externalIdentifier.Value);
                    if (result?.Errors != null)
                    {
                        _logger.LogError(String.Join(";", result.Errors));
                        return BadRequest(String.Join(";", result.Errors));
                    }

                    return Success(result);
                }
                else
                {
                    var result = _filmCardService.GetAll(model, filmSysId);
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
                _logger.LogError(exc, "Error getting film cards list");
                return InternalServerError();
            }
        }

        [HttpGet("parentData/{filmSysId}")]
        public async Task<IActionResult> GetParentData(Guid filmSysId)
        {
            try
            {
                return Success(await _filmCardService.GetParentData(filmSysId));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting parent data for film {filmSysId}");
                return InternalServerError();
            }
        }

        [HttpPost]
        public async Task<IActionResult> Post(FilmCardModel model)
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

                var result = await _filmCardService.CreateDraftAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating film card {model}");
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
                    return Success(await _filmCardService.GetFromExternalSourceAsync(externalIdentifier.Value));
                }
                else if (sysId.HasValue)
                {
                    return Success(await _filmCardService.GetBySystemIdentifierAsync(sysId.Value));
                }
                else
                {
                    _logger.LogError($"Film card has no system identifier ({sysId}) and external source ({hasExternalSource} {externalIdentifier})");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting film card {sysId}");
                return InternalServerError();
            }
        }

        [HttpPut]
        public async Task<IActionResult> Put(FilmCardDraftModel model)
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

                var result = await _filmCardService.UpdateDraftAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error updating film card {model.Id}");
                return InternalServerError();
            }
        }

        [HttpDelete("draft/{id}")]
        public async Task<IActionResult> DeleteDraft(int id)
        {
            try
            {
                int? archiveId = await _filmCardService.GetFilmCardDraftArchiveAsync(id);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupI });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _filmCardService.DeleteDraftAsync(id);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting film card draft {id}");
                return InternalServerError();
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(Guid id)
        {
            try
            {
                int? archiveId = await _filmCardService.GetFilmCardArchiveAsync(id);

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupI });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _filmCardService.DeleteFilmCardAsync(id);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting film card {id}");
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

        [HttpGet("printed/{sysId}")]
        public async Task<IActionResult> GetPrinted(Guid sysId)
        {
            try
            {
                return Success(await _filmCardService.GetPrintedBySystemIdentifierAsync(sysId));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting printed film card {sysId}");
                return InternalServerError();
            }
        }
    }
}
