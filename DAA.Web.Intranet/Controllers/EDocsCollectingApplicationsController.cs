using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Applications;
using DAA.Services.Applications;
using DAA.Services.Files;
using DAA.Services.Packages;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Intranet.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class EDocsCollectingApplicationsController : BaseApiController
    {
        private readonly IApplicationsService _applicationsService;
        private readonly IPackagesService _packagesService;
        private readonly IFileService _fileService;
        public EDocsCollectingApplicationsController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<AccountController> logger,
            IApplicationsService applicationsService,
            IPackagesService packagesService,
            IFileService fileService)
            : base(localizer, logger)
        {
            _applicationsService = applicationsService;
            _packagesService = packagesService;
            _fileService = fileService;
        }

        [HttpPost("List")]
        public IActionResult List([FromBody] DataSourceRequestModel model)
        {
            return Ok(_applicationsService.ListNew(model));
        }

        [HttpGet("{id}")]
        public IActionResult Get(int id)
        {
            return Ok(_applicationsService.Display(id));
        }

        [HttpGet("{id}/process")]
        public IActionResult GetApplicationRelatedProcess(int id)
        {
            try
            {
                return Ok(_applicationsService.ApplicationRelatedProcess(id));
            }
            catch (Exception x)
            {
                _logger.LogError(x, $"ERROR Gettings process by application with id {id}");
                return BadRequest(x.Message);
            }
        }

        [HttpGet("Download/{id}")]
        public IActionResult Download(int id)
        {
            var file = _applicationsService.GetApplicationFile(id);
            if (file == null)
            {
                return BadRequest();
            }

            return File(file.Content, file.ContentType, file.Name);
        }

        [HttpPost("Approve")]
        public async Task<IActionResult> Approve(ApproveModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    //await _applicationsService.Approve(model);
                    //return Ok();

                    var result = await _applicationsService.Approve(model);
                    if (!result.Succeeded)
                    {
                        var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());

                        _logger.LogError(result.ToString());
                        return BadRequest(message!);
                    }

                    return Success(result.Data);
                }
                catch (Exception x)
                {
                    _logger.LogError(x, $"Error approving application {model.Id}");
                    return InternalServerError();
                }
            }

            return BadRequest();
        }

        [HttpPost("Reject")]
        public async Task<IActionResult> Reject(RejectModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    await _applicationsService.Reject(model);
                    return Ok();
                }
                catch (Exception x)
                {
                    return InternalServerError(x.Message);
                }
            }

            return BadRequest();
        }

        [HttpPost("ApprovePackages")]
        public async Task<IActionResult> ApprovePackages(ApproveModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    //await _packagesService.ApprovePackages(model.Id);
                    //return Ok();

                    var result = await _packagesService.ApprovePackages(model.Id);
                    if (!result.Succeeded)
                    {
                        _logger.LogError(result.ToString());
                        return BadRequest(String.Join(";", result.Errors));
                    }

                    return Success(result.Data);
                }
                catch (Exception x)
                {
                    _logger.LogError(x, "Error approving packages");
                    return InternalServerError();
                }
            }

            return BadRequest();
        }

        [HttpPost("RejectPackages")]
        public async Task<IActionResult> RejectPackages(RejectModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    await _packagesService.RejectPackage(model.Id, model.Reason);
                    return Ok();
                }
                catch (Exception x)
                {
                    return InternalServerError(x.Message);
                }
            }

            return BadRequest();
        }

        [HttpPost("CancelPackages")]
        public async Task<IActionResult> CancelPackages(RejectModel model)
         {
            if (ModelState.IsValid)
            {
                try
                {
                    await _packagesService.CancelPackages(model.Id, model.Reason);
                    return Ok();
                }
                catch (Exception x)
                {
                    return InternalServerError(x.Message);
                }
            }

            return BadRequest();
        }

        [HttpGet("Packages/{applicationId}")]
        public async Task<IActionResult> GetPackages(int applicationId)
        {
            return Ok(await _packagesService.GetPackagesForApplication(applicationId));
        }

        //[HttpGet("downloadOrDisplayPackageFile/{id}")]
        //public async Task<IActionResult> GetPackageFile(int id)
        //{
        //    return await GetPackageDocumentFile(id, true);
        //}

        //[HttpGet("onlyDownloadPackageFile/{id}")]
        //public async Task<IActionResult> OnlyDownloadPackageFile(int id)
        //{
        //    return await GetPackageDocumentFile(id, false);
        //}

        [HttpGet("packageDocument/stream/{id}")]
        public async Task<IActionResult> StreamPackageDocument(int id, [FromQuery]bool? inline)
        {
            return await GetPackageDocumentFile(id, inline ?? false);
        }

        [NonAction]
        private async Task<IActionResult> GetPackageDocumentFile(int id, bool inline)
        {
            try
            {
                var packageDocument = await _packagesService.GetPackageDocument(id);
                if (packageDocument == null)
                {
                    _logger.LogError($"Package document {id} is null");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                string? extension = Path.GetExtension(packageDocument.FileName)?.ToUpper();

                if (inline)
                {
                    if (extension == ".PDF")
                    {
                        //return as base64 string to be able to display?
                        return Success<string>(
                            await _fileService.GetFileBase64StringAsync(packageDocument.FilePath!, Shared.FileStreamLocation.Buffer));
                    }
                    if (extension == ".TIF" || extension == ".TIFF")
                    {
                        var resut = await _fileService.TryConvertFileToImageAsync(packageDocument.FilePath!, Shared.FileStreamLocation.Buffer);
                        return File(resut, "image/jpeg");
                    }
                }

                string contentType = string.IsNullOrWhiteSpace(packageDocument.ContentType)
                                        ? "application/octet-stream"
                                        : packageDocument.ContentType!;

                var fileStream =
                   await _fileService.GetFileStreamAsync(packageDocument.FilePath!, Shared.FileStreamLocation.Buffer);

                if (inline)
                {
                    Response.Headers.Add("Content-Disposition", $"{(inline ? "inline" : "attachment")}");
                }

                return File(fileStream, contentType, packageDocument.FileName, true);

            }
            catch (FileNotFoundException exc)
            {
                _logger.LogError(exc, $"File for package document {id} not found");
                return NotFound();
            }
            catch (Exception x)
            {
                _logger.LogError(x, $"Error streaming file for package document {id}");
                return InternalServerError();
            }
        }

    }
}
