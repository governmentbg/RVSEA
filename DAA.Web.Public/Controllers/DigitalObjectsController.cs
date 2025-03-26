using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Identity;
using DAA.Models.File;
using DAA.Models.Identity;
using DAA.Services.DigitalObjects;
using DAA.Services.Files;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Public.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DigitalObjectsController : BaseApiController
    {
        private readonly IDigitalObjectPublicService _digitalObjectService;
        private readonly IFileService _fileService;
        private readonly ApplicationUserManager _userManager;

        public DigitalObjectsController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<DigitalObjectsController> logger,
           IDigitalObjectPublicService digitalObjectService,
           IUserInfo userInfo,
           IFileService fileService,
           ApplicationUserManager userManager)
           : base(localizer, logger, userInfo)
        {
            _digitalObjectService = digitalObjectService;
            _fileService = fileService;
            _userManager = userManager;
        }

        [HttpPost("listByDocument/{documentSysId?}")]
        public async Task<IActionResult> ListByDocument(
         DataSourceRequestModel model,
          Guid? documentSysId,
         [FromQuery] bool documentHasExternalSource,
         [FromQuery] int? documentExternalIdentifier)
        {
            try
            {
                ApplicationUser? user = await _userManager.FindByIdAsync(_currentUserInfo.CurrentUserId.ToString());
                string? token = null;
                if (user != null)
                {
                    token = await _userManager.GenerateUserTokenAsync(user, TokenOptions.DefaultEmailProvider, "purpose");
                }
                var digitalObjects =
                    await _digitalObjectService.GetByDocumentIdentifierAsync(
                        model,
                        documentSysId,
                        documentHasExternalSource,
                        documentExternalIdentifier);
                if (digitalObjects?.Errors != null)
                {
                    _logger.LogError(string.Join(";", digitalObjects.Errors));
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(digitalObjects, token);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting digital object list for document {documentSysId} {documentHasExternalSource} {documentExternalIdentifier}");
                return InternalServerError();
            }
        }

        //[HttpGet("download/{sysId}")]
        //public async Task<IActionResult> Download(Guid sysId, bool? isInline, Guid? userId, string? token)
        //{
        //    try
        //    {
        //        bool isTokenValid = false;

        //        if (userId != null && token != null)
        //        {
        //            ApplicationUser? user = await _userManager.FindByIdAsync(userId.ToString());
        //            isTokenValid = await _userManager.VerifyUserTokenAsync(
        //            user,
        //            TokenOptions.DefaultEmailProvider,
        //            "purpose",
        //            token);
        //        }

        //        var digitalObject = await _digitalObjectService.GetDigitalObjectBySystemIdentifierAsync(sysId);

        //        if (digitalObject == null)
        //        {
        //            _logger.LogError($"Digital object {sysId} is null");
        //            return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
        //        }

        //        try
        //        {
        //            await _digitalObjectService.ManageDigitalObjectReviewAsync(digitalObject, isTokenValid ? userId : null);
        //        }
        //        catch (Exception exc)
        //        {
        //            _logger.LogError(exc, $"Error getting/creating digital object review");
        //        }

        //        var tuple = await _digitalObjectService.GetUncPathAndWatermarkUncPathAsync(sysId);
        //        //FIX
        //        FileModel? file = null;
        //        if (!string.IsNullOrWhiteSpace(tuple.Item2))
        //        {
        //            file = await _fileService.GetFileAsync(tuple.Item2, Shared.FileStreamLocation.File);
        //        }
        //        else
        //        {
        //            file = await _fileService.GetFileAsync(tuple.Item1, Shared.FileStreamLocation.File);
        //        }
        //        if (file == null || file.Content == null)
        //        {
        //            _logger.LogError($"File for digital object {sysId} or file content is null");
        //            return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
        //        }
        //        if (string.Equals(file.Type, "pdf") || string.Equals(file.Type, "PDF"))
        //        {
        //            return Success(Convert.ToBase64String(file.Content));
        //        }

        //        Response.Headers.Add("Content-Disposition", $"{(isInline == true ? "inline" : "attachment")}; filename={digitalObject.SourceName}");
        //        string? extension = Path.GetExtension(digitalObject.SourceName);
        //        string contentType =
        //            extension == ".png" ? "image/png" :
        //            extension == ".tif" || extension == ".tiff" ? "image/tiff" :
        //            digitalObject.ContentType!;
        //        return new FileContentResult(file.Content, contentType);
        //    }
        //    catch (Exception x)
        //    {
        //        return InternalServerError(x.Message);
        //    }
        //}


        [HttpGet("stream/{sysId}")]
        public async Task<IActionResult> Stream(Guid sysId, [FromQuery]bool? inline, [FromQuery] Guid? userId, [FromQuery] string? token)
        {
            try
            {
                bool isTokenValid = false;

                if (userId != null && token != null)
                {
                    ApplicationUser? user = await _userManager.FindByIdAsync(userId.ToString());
                    isTokenValid = await _userManager.VerifyUserTokenAsync(
                    user,
                    TokenOptions.DefaultEmailProvider,
                    "purpose",
                    token);
                }

                var digitalObject = await _digitalObjectService.GetDigitalObjectBySystemIdentifierAsync(sysId);

                if (digitalObject == null)
                {
                    _logger.LogError($"Digital object {sysId} is null");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                try
                {
                    await _digitalObjectService.ManageDigitalObjectReviewAsync(digitalObject, isTokenValid ? userId : null);
                }
                catch (Exception exc)
                {
                    _logger.LogError(exc, $"Error getting/creating digital object review");
                }


                string? extension = Path.GetExtension(digitalObject.SourceName)?.ToUpper();

                var digitalObjectUncPath = await _digitalObjectService.GetUncPathAndWatermarkUncPathAsync(sysId);

                if (inline.HasValue && inline.Value)
                {
                    if (extension == ".PDF")
                    {
                        //return as base64 string to be able to display
                        return Success<string>(
                            await _fileService.GetFileBase64StringAsync(
                                !string.IsNullOrWhiteSpace(digitalObjectUncPath.Item2) ? digitalObjectUncPath.Item2 : digitalObjectUncPath.Item1,
                                Shared.FileStreamLocation.File
                        ));
                    }
                    if (extension == ".TIF" || extension == ".TIFF")
                    {
                        var result = 
                            await _fileService.TryConvertFileToImageAsync(
                                !string.IsNullOrWhiteSpace(digitalObjectUncPath.Item2) ? digitalObjectUncPath.Item2 : digitalObjectUncPath.Item1,
                                Shared.FileStreamLocation.File
                            );
                        return File(result, "image/jpeg");
                    }
                }

                string contentType = string.IsNullOrWhiteSpace(digitalObject.ContentType)
                                        ? "application/octet-stream"
                                        : digitalObject.ContentType!;

                var fileStream =
                   await _fileService.GetFileStreamAsync(
                        !string.IsNullOrWhiteSpace(digitalObjectUncPath.Item2) ? digitalObjectUncPath.Item2 : digitalObjectUncPath.Item1,
                        Shared.FileStreamLocation.File);

                if (inline.HasValue)
                {
                    Response.Headers.Add("Content-Disposition", $"{(inline.HasValue && inline.Value ? "inline" : "attachment")}");
                }

                return File(fileStream, contentType, digitalObject.SourceName, true);

            }
            catch (FileNotFoundException exc)
            {
                _logger.LogError(exc, $"File for digital object {sysId} not found");
                return NotFound();
            }
            catch (Exception x)
            {
                _logger.LogError(x, $"Error streaming file for digital object {sysId}");
                return InternalServerError();
            }
        }


        //[HttpGet("downloadDarivative/{sysId}")]
        //public async Task<IActionResult> DownloadDerivative(Guid sysId, bool? download, Guid? userId, string? token)
        //{
        //    try
        //    {
        //        bool isTokenValid = false;

        //        if (userId != null && token != null)
        //        {
        //            ApplicationUser? user = await _userManager.FindByIdAsync(userId.ToString());
        //            isTokenValid = await _userManager.VerifyUserTokenAsync(
        //            user,
        //            TokenOptions.DefaultEmailProvider,
        //            "purpose",
        //            token);
        //        }

        //        var digitalObject = await _digitalObjectService.GetDigitalObjectDraftBySystemIdentifierAsync(sysId);

        //        if (digitalObject == null)
        //        {
        //            _logger.LogError($"Digital object draft {sysId} is null");
        //            return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
        //        }

        //        try
        //        {
        //            await _digitalObjectService.ManageDigitalObjectReviewAsync(digitalObject, isTokenValid ? userId : null);
        //        }
        //        catch (Exception exc)
        //        {
        //            _logger.LogError(exc, $"Error getting/creating digital object review");
        //        }

        //        FileModel? file = null;
        //        file = await _fileService.GetFileAsync(digitalObject.UncPath, Shared.FileStreamLocation.Buffer);

        //        if (file == null || file.Content == null)
        //        {
        //            _logger.LogError($"File for digital object {sysId} or file content is null");
        //            return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
        //        }
        //        if (string.Equals(file.Type, "pdf") || string.Equals(file.Type, "PDF"))
        //        {
        //            if (download ?? false)
        //            {
        //                return File(file.Content, "application/pdf", file.Name);
        //            }
        //            return Success(Convert.ToBase64String(file.Content!));
        //        }

        //        return File(file.Content, file.ContentType, file.Name);
        //    }
        //    catch (Exception x)
        //    {
        //        return InternalServerError(x.Message);
        //    }
        //}

        [HttpGet("draft/stream/{sysId}")]
        public async Task<IActionResult> StreamDraft(Guid sysId, [FromQuery] bool? inline, [FromQuery] Guid? userId, [FromQuery] string? token)
        {
            try
            {
                bool isTokenValid = false;

                if (userId != null && token != null)
                {
                    ApplicationUser? user = await _userManager.FindByIdAsync(userId.ToString());
                    isTokenValid = await _userManager.VerifyUserTokenAsync(
                    user,
                    TokenOptions.DefaultEmailProvider,
                    "purpose",
                    token);
                }

                var digitalObject = await _digitalObjectService.GetDigitalObjectDraftBySystemIdentifierAsync(sysId);

                if (digitalObject == null)
                {
                    _logger.LogError($"Digital object draft {sysId} is null");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                try
                {
                    await _digitalObjectService.ManageDigitalObjectReviewAsync(digitalObject, isTokenValid ? userId : null);
                }
                catch (Exception exc)
                {
                    _logger.LogError(exc, $"Error getting/creating digital object review");
                }


                string? extension = Path.GetExtension(digitalObject.SourceName)?.ToUpper();

                if (inline.HasValue && inline.Value)
                {
                    if (extension == ".PDF")
                    {
                        //return as base64 string to be able to display
                        return Success<string>(
                            await _fileService.GetFileBase64StringAsync(digitalObject.UncPath!, Shared.FileStreamLocation.Buffer));
                    }
                    if (extension == ".TIF" || extension == ".TIFF")
                    {
                        var result =
                            await _fileService.TryConvertFileToImageAsync(digitalObject.UncPath!, Shared.FileStreamLocation.Buffer);
                        return File(result, "image/jpeg");
                    }
                }

                string contentType = string.IsNullOrWhiteSpace(digitalObject.ContentType)
                                        ? "application/octet-stream"
                                        : digitalObject.ContentType!;

                var fileStream =
                   await _fileService.GetFileStreamAsync(digitalObject.UncPath!, Shared.FileStreamLocation.Buffer);

                if (inline.HasValue)
                {
                    Response.Headers.Add("Content-Disposition", $"{(inline.HasValue && inline.Value ? "inline" : "attachment")}");
                }

                return File(fileStream, contentType, digitalObject.SourceName, true);

            }
            catch (FileNotFoundException exc)
            {
                _logger.LogError(exc, $"File for digital object {sysId} not found");
                return NotFound();
            }
            catch (Exception x)
            {
                _logger.LogError(x, $"Error streaming file for digital object {sysId}");
                return InternalServerError();
            }
        }
    }
}
