using DAA.Extensions.Controller;
using DAA.Extensions.Exceptions;
using DAA.Models.Packages;
using DAA.Services.Applications;
using DAA.Services.Files;
using DAA.Services.Packages;
using DAA.Services.Settings;
using DAA.Shared;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Newtonsoft.Json;
using Serilog;

namespace DAA.Web.Public.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PackagesController : BaseApiController
    {
        private readonly IApplicationsService _applicationService;
        private readonly IPackagesService _packagesService;
        private readonly IPackageATemplatesService _templatesService;
        private readonly IFileService _fileService;

        public PackagesController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<AccountController> logger,
            IApplicationsService applicationService,
            IPackagesService packagesService,
            IPackageATemplatesService templatesService,
            IFileService fileService)
            : base(localizer, logger)
        {
            _applicationService = applicationService;
            _packagesService = packagesService;
            _templatesService = templatesService;
            _fileService = fileService;
        }

        [HttpPost]
        [RequestFormLimits(ValueLengthLimit = MaxContentSizeInBytes, MultipartBodyLengthLimit = MaxContentSizeInBytes)]
        public async Task<IActionResult> CreateApplicationPackage([FromForm] string model, [FromForm] IEnumerable<IFormFile> packageAFiles, [FromForm] IEnumerable<IFormFile> packageBFiles)
        {
            if (packageAFiles != null && packageBFiles != null)
            {
                try
                {

                    ApplicationPackageModel? data = JsonConvert.DeserializeObject<ApplicationPackageModel>(model);

                    if (data != null)
                    {
                        var applicationStatus = await _applicationService.GetStatusAsync(data.ApplicationId);
                        if (applicationStatus != (int)ApplicationStatus.AddPackages
                            && applicationStatus != (int)ApplicationStatus.EditPackages
                            && applicationStatus != (int)ApplicationStatus.ModificationRequest)
                        {
                            _logger.LogWarning($"Cannot create or edit application packages at this stage, Application status - {applicationStatus}");
                            return BadRequest("Cannot create or edit application packages at this stage");
                        }

                        //Link files to list objects
                        foreach (var doc in data.PackageA)
                        {
                            IFormFile? f = packageAFiles.FirstOrDefault(x => x.FileName == doc.FileName && doc.FileSize == x.Length);

                            if (f != null)
                            {
                                doc.File = f;
                            }
                        };

                        foreach (var doc in data.PackageB)
                        {
                            IFormFile? f = packageBFiles.FirstOrDefault(x => x.FileName == doc.FileName && doc.FileSize == x.Length);

                            if (f != null)
                            {
                                doc.File = f;
                            }
                        };

                        await _packagesService.CreateApplicationPackages(data!);
                        return Ok();
                    }
                }
                catch (Exception x)
                {
                    return InternalServerError(x.Message);
                }
            }

            return BadRequest();
        }

        [HttpPost("packageWithImport")]
        [RequestFormLimits(ValueLengthLimit = MaxContentSizeInBytes, MultipartBodyLengthLimit = MaxContentSizeInBytes)]
        public async Task<IActionResult> CreateApplicationPackageWithImport([FromForm] string model, [FromForm] IEnumerable<IFormFile> packageAFiles, [FromForm] IEnumerable<IFormFile> packageBFiles)
        {
            if (packageAFiles != null && packageBFiles != null)
            {
                try
                {

                    ApplicationPackageModel? data = JsonConvert.DeserializeObject<ApplicationPackageModel>(model);

                    if (data != null)
                    {
                        //Link files to list objects
                        foreach (var doc in data.PackageA)
                        {
                            IFormFile? f = packageAFiles.FirstOrDefault(x => x.FileName == doc.FileName && doc.FileSize == x.Length);

                            if (f != null)
                            {
                                doc.File = f;
                            }
                        };

                        foreach (var doc in data.PackageB)
                        {
                            IFormFile? f = packageBFiles.FirstOrDefault(x => x.FileName == doc.FileName && doc.FileSize == x.Length);

                            if (f != null)
                            {
                                doc.File = f;
                            }
                        };

                        await _packagesService.CreateApplicationPackagesWithImport(data!);
                        return Success();
                    }
                }
                catch (FileTypeNotSupportedException exc)
                {
                    _logger.LogError(exc, "Error creating public application package with import");
                    return BadRequest(exc.Message);
                }
                catch (CustomException exc)
                {
                    _logger.LogError(exc, "Error creating public application package with import");
                    return BadRequest(exc.Message);
                }
                catch (Exception x)
                {
                    _logger.LogError(x, "Error creating public application package with import");
                    return InternalServerError(x.Message);
                }
            }

            return BadRequest();
        }

        [HttpPost("submit/{applicationId}")]
        public async Task<IActionResult> SubmitApplicationPackages([FromRoute] int applicationId)
        {
            try
            {
                var result = await _packagesService.CommitApplicationPackages(applicationId);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success();
            }
            catch (Exception x)
            {
                _logger.LogError(x, $"ERROR Submitting application with id {applicationId}");
                return InternalServerError();
            }
        }

        [HttpPost("signedDocuments/{applicationId}")]
        [RequestFormLimits(ValueLengthLimit = MaxContentSizeInBytes, MultipartBodyLengthLimit = MaxContentSizeInBytes)]
        public async Task<IActionResult> PostSignedPackageDocuments([FromRoute] int applicationId, [FromForm] string model, [FromForm] IEnumerable<IFormFile> signedFiles)
        {
            try
            {
                var processId = await _applicationService.GetActiveProcessIdByApplicationAsync(applicationId);
                if (!processId.HasValue)
                {
                    _logger.LogError($"{nameof(PostSignedPackageDocuments)}: No active process for application with id {applicationId}.");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                var packageAId = await _packagesService.GetPackageIdByApplication(applicationId, PackageType.A);
                if (!packageAId.HasValue)
                {
                    _logger.LogError($"{nameof(PostSignedPackageDocuments)}: Application with id {applicationId} does not have package {PackageType.A}.");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                IEnumerable<PackageDocumentBaseModel>? signedPackageDocuments = JsonConvert.DeserializeObject<IEnumerable<PackageDocumentBaseModel>>(model);
                if (signedPackageDocuments == null || !signedPackageDocuments.Any())
                {
                    _logger.LogError($"{nameof(PostSignedPackageDocuments)}: Invalid signed documents model for application with id {applicationId} ({model}).");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                if (signedFiles.Count() != signedPackageDocuments.Count())
                {
                    _logger.LogError($"{nameof(PostSignedPackageDocuments)}: No attached files for all signed documents for application with id {applicationId} ({model}).");
                    return BadRequest(_localizer.GetString("Error_MissingDocumentFiles").ToString());
                }

                foreach (var document in signedPackageDocuments)
                {
                    IFormFile? f = signedFiles.FirstOrDefault(x => x.FileName == document.FileName && document.FileSize == x.Length);

                    if (f != null)
                    {
                        document.File = f;
                    }
                }

                var result = await _packagesService.AddSignedPackageDocumentsAsync(signedPackageDocuments, applicationId, packageAId.Value, processId.Value);
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
                _logger.LogError(exc, $"Error posting signed documents for application {applicationId}");
                return InternalServerError();
            }
        }

        [HttpGet("templates/{processId}")]
        public IActionResult GetByProcess([FromRoute] int processId)
        {
            try
            {
                var templates = _templatesService.GetTemplates(processId);
                return Success(templates);
            }
            catch (Exception x)
            {
                return InternalServerError(x.Message);
            }
        }

        [HttpGet("templatesByApplication/{applicationId}")]
        public async Task<IActionResult> GetTemplatesByApplication([FromRoute] int applicationId)
        {
            try
            {
                var templates = await _templatesService.GetTemplatesForApplication(applicationId);
                return Success(templates);
            }
            catch (Exception x)
            {
                Log.Error(x, $"Error getting templates for application {applicationId}", new { applicationId });
                return InternalServerError(x.Message);
            }
        }

        [HttpGet("templates/bySignatureRequest/{applicationId}")]
        public async Task<IActionResult> GetTemplatesBySignatureRequest([FromRoute] int applicationId)
        {
            try
            {
                var processId = await _applicationService.GetActiveProcessIdByApplicationAsync(applicationId);
                if (!processId.HasValue)
                {
                    _logger.LogError($"{nameof(GetTemplatesBySignatureRequest)}: No active process for application with id {applicationId}.");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                var packageAId = await _packagesService.GetPackageIdByApplication(applicationId, PackageType.A);
                if (!packageAId.HasValue)
                {
                    _logger.LogError($"{nameof(GetTemplatesBySignatureRequest)}: Application with id {applicationId} does not have package {PackageType.A}.");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                var templates = _templatesService.GetTemplatesForSignatureRequest(packageAId.Value, processId.Value);
                return Success(templates);
            }
            catch (Exception exc)
            {
                Log.Error(exc, $"Error getting templates for signature requests for application {applicationId}");
                return InternalServerError();
            }
        }

        [HttpGet("byApplication/{applicationId}")]
        public async Task<IActionResult> GetByApplication([FromRoute] int applicationId)
        {
            try
            {
                var packages = await _packagesService.GetPackagesForApplication(applicationId);
                return Success(packages);
            }
            catch (Exception x)
            {
                return InternalServerError(x.Message);
            }
        }

        [HttpGet("signatureRequest/has/{applicationId}")]
        public async Task<IActionResult> HasSignatureRequests([FromRoute] int applicationId)
        {
            try
            {
                var processId = await _applicationService.GetActiveProcessIdByApplicationAsync(applicationId);
                if (!processId.HasValue)
                {
                    return Success(false);
                }

                var packageAId = await _packagesService.GetPackageIdByApplication(applicationId, PackageType.A);
                if (!packageAId.HasValue)
                {
                    return Success(false);
                }


                return Success(await _packagesService.HasPackageDocumentsBySignatureRequest(packageAId.Value, processId.Value));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting package document for signing (applicationId: {applicationId})");
                return InternalServerError();
            }
        }

        [HttpGet("signatureRequest/{applicationId}")]
        public async Task<IActionResult> GetBySignatureRequest([FromRoute] int applicationId)
        {
            try
            {
                var processId = await _applicationService.GetActiveProcessIdByApplicationAsync(applicationId);
                if (!processId.HasValue)
                {
                    _logger.LogError($"{nameof(GetBySignatureRequest)}: No active process for application with id {applicationId}.");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                var packageAId = await _packagesService.GetPackageIdByApplication(applicationId, PackageType.A);
                if (!packageAId.HasValue)
                {
                    _logger.LogError($"{nameof(GetBySignatureRequest)}: Application with id {applicationId} does not have package {PackageType.A}.");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(_packagesService.GetPackageDocumentsBySignatureRequest(packageAId.Value, processId.Value));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting package document for signing (applicationId: {applicationId})");
                return InternalServerError();
            }
        }

        [HttpGet("structure/{applicationId}")]
        public async Task<IActionResult> GetStructureByApplication([FromRoute] int applicationId)
        {
            try
            {
                var struc = await _packagesService.GetStructureForApplication(applicationId);
                return Success(struc);
            }
            catch (Exception x)
            {
                return InternalServerError(x.Message);
            }
        }

        [AllowAnonymous] //TODO MUST be fixed!!! WTF???
        [HttpGet("download/{id}")]
        public async Task<IActionResult> GetPackageFile(int id, [FromQuery] bool? inline)
        {
            //var package = await _packagesService.GetPackageDocument(id);
            //var file = await _fileService.GetFileAsync(package.FilePath, FileStreamLocation.Buffer);

            //if (file != null && file.Content != null && string.Equals(file.Type.ToLower(), "pdf"))
            //{
            //    return Success(Convert.ToBase64String(file.Content!));
            //}

            //return File(file.Content, package.ContentType, package.FileName);

            try
            {
                var packageDocument = await _packagesService.GetPackageDocument(id);
                if (packageDocument == null)
                {
                    _logger.LogError($"Package document {id} is null");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                string? extension = Path.GetExtension(packageDocument.FileName)?.ToUpper();

                if (inline.HasValue && inline.Value)
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

                if (inline.HasValue)
                {
                    Response.Headers.Add("Content-Disposition", $"{(inline.Value ? "inline" : "attachment")}");
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

        [HttpGet("downloadtemplate/{templateId}")]
        public async Task<IActionResult> DownloadTemplateFile(int templateId)
        {
            try
            {
                var file = await _templatesService.GetFile(templateId);
                if (file == null || file.Content == null)
                {
                    _logger.LogError($"File docId {templateId} or file content is null");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(Convert.ToBase64String(file.Content!));
                //return File(file.Content, file.ContentType, file.FileName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error downloading film document {templateId}");
                return InternalServerError(ex.Message);
            }
        }
    }
}
