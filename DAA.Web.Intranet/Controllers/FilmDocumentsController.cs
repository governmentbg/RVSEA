using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Films;
using DAA.Services.Authorization;
using DAA.Services.Films;
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
    public class FilmDocumentsController : BaseApiController
    {
        private readonly IFilmDocumentService _filmDocumentService;
        private readonly IFilmService _filmService;
        //private readonly ISystemAuthorizationService _authorizationService;

        public FilmDocumentsController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IFilmDocumentService filmDocumentService,
           IFilmService filmService,
           ISystemAuthorizationService authorizationService)
           : base(localizer, logger, userInfo, authorizationService)
        {
            _filmDocumentService = filmDocumentService;
            _filmService = filmService;
            //_authorizationService = authorizationService;
        }

        [HttpPost("listall/{packageId}")]
        public IActionResult ListAll(DataSourceRequestModel model, int packageId)
        {
            try
            {
                var result = _filmDocumentService.GetAll(model, packageId);
                if (result?.Errors != null)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting film documents list");
                return InternalServerError();
            }
        }

        [HttpPost]
        [RequestFormLimits(ValueLengthLimit = MaxContentSizeInBytes, MultipartBodyLengthLimit = MaxMultipartContentSizeInBytes)]
        public async Task<IActionResult> Post([FromForm] FilmPackageDocumentCreateModel model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(_localizer.GetString("Error_InvalidData").Value);
            }

            try
            {
                int? archiveId = null;
                if(model.EntityType == Shared.BusinessObjectType.Film)
                {
                    archiveId = await _filmService.GetFilmArchiveAsync(model.EntitySystemIdentifier);
                }

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupI });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _filmDocumentService.CreateAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating film document {model}");
                return InternalServerError();
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> Get(int id)
        {
            try
            {
                return Success(await _filmDocumentService.GetById(id));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting film document {id}");
                return InternalServerError();
            }
        }

        [HttpPut]
        [RequestFormLimits(ValueLengthLimit = MaxContentSizeInBytes, MultipartBodyLengthLimit = MaxMultipartContentSizeInBytes)]
        public async Task<IActionResult> Put([FromForm] FilmPackageDocumentUpdateModel model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(_localizer.GetString("Error_InvalidData").Value);
            }

            try
            {
                int? archiveId = null;
                if (model.EntityType == Shared.BusinessObjectType.Film)
                {
                    archiveId = await _filmService.GetFilmArchiveAsync(model.EntitySystemIdentifier);
                }

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupI });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _filmDocumentService.UpdateAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error updating film document {model.Id}");
                return InternalServerError();
            }
        }

        [HttpDelete("{id}/{entityType}/{entitySystemIdentifier}")]
        public async Task<IActionResult> Delete(int id, string entityType, Guid entitySystemIdentifier)
        {
            try
            {
                int? archiveId = null;
                if (entityType == Shared.BusinessObjectType.Film)
                {
                    archiveId = await _filmService.GetFilmArchiveAsync(entitySystemIdentifier);
                }

                var authResultStatusCode = await AuthorizeRolesInArchive(archiveId, new string[] { ApplicationRoleType.GroupI });
                if (authResultStatusCode != StatusCodes.Status200OK)
                {
                    return Forbid();
                }

                var result = await _filmDocumentService.DeleteAsync(id);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(String.Join(";", result.Errors));
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting film document {id}");
                return InternalServerError();
            }
        }

        [HttpGet("download/{docId}")]
        public async Task<IActionResult> Download(int docId, bool? isInline)
        {
            try
            {
                var file = await _filmDocumentService.GetFile(docId);
                if (file == null || file.Content == null)
                {
                    _logger.LogError($"File docId {docId} or file content is null");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                //return File(file.Content, file.ContentType, file.Name);
                Response.Headers.Add("Content-Disposition", $"{(isInline == true ? "inline" : "attachment")}; filename={file.Name}");
                string? extension = Path.GetExtension(file.Name);
                string contentType =
                    extension == ".png" ? "image/png" :
                    extension == ".tif" || extension == ".tiff" ? "image/tiff" :
                    file.ContentType!;
                return new FileContentResult(file.Content, contentType);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error downloading film document {docId}");
                return InternalServerError(ex.Message);
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
