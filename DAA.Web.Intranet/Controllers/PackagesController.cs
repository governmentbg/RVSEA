using DAA.Extensions.Controller;
using DAA.Extensions.Exceptions;
using DAA.Models.Packages;
using DAA.Services.Files;
using DAA.Services.Packages;
using DAA.Services.Settings;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Newtonsoft.Json;

namespace DAA.Web.Intranet.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PackagesController : BaseApiController
    {
        private readonly IPackagesService _packagesService;
        private readonly IFileService _fileService;
        private readonly IPackageATemplatesService _templatesService;

        public PackagesController(IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IPackagesService packService,
           IFileService fileService,
           IPackageATemplatesService templatesService
           )
            : base(localizer, logger, userInfo)
        {
            _packagesService = packService;
            _fileService = fileService;
            _templatesService = templatesService;
        }

        [HttpGet("{packageId}")]
        public IActionResult Get(int packageId, [FromQuery] bool? hasTemplate = null)
        {
            return Ok(_packagesService.GetPackageDocumentsById(packageId, hasTemplate));
        }

        [HttpPost("AddFileToPackage")]
        [RequestFormLimits(ValueLengthLimit = MaxContentSizeInBytes, MultipartBodyLengthLimit = MaxMultipartContentSizeInBytes)]
        public async Task<IActionResult> AddFileToPackage([FromForm] PackageDocumentCreateModel model)
        {
            try
            {
                if (model.File != null && model.File.Length > 0)
                {
                    var result = await _packagesService.CreateFileAsync(model, model.PackageId, model.InventorySysIdentifier);
                    if (!result.Succeeded)
                    {
                        _logger.LogError(result.ToString());
                        var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                        return BadRequest(message);
                    }

                    return Success(result.Data);
                }

                if (model.Files != null && model.Files.Length > 0)
                {
                    var result = await _packagesService.CreateFilesAsync(model, model.PackageId);

                    if (!result.Succeeded)
                    {
                        _logger.LogError(result.ToString());
                        var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                        return BadRequest(message);
                    }

                    return Success(result.Data);
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error adding files to package with id {model.PackageId}");
                return InternalServerError();
            }

            //if (model.Files != null && model.File.Length == 0)
            //{
            //    try
            //    {
            //        var result = await _packagesService.CreateFilesAsync(model, model.PackageId);

            //        if (!result.Succeeded)
            //        {
            //            _logger.LogError(result.ToString());
            //            return BadRequest(result.Errors.First().ToString());
            //        }

            //        return Success(result.Data);
            //    }
            //    catch (Exception x)
            //    {
            //        _logger.LogError(x, "ERROR AddFileToPackage", model);
            //        return InternalServerError(x.Message);
            //    }
            //}
            //if (ModelState.IsValid)
            //{
            //    try
            //    {
            //        var result = await _packagesService.CreateFileAsync(model, model.PackageId);
            //        if (!result.Succeeded)
            //        {
            //            _logger.LogError(result.ToString());
            //            return BadRequest(result.Errors.First().ToString());
            //        }

            //        return Success(result.Data);
            //    }
            //    catch (Exception x)
            //    {
            //        _logger.LogError(x, "ERROR AddFileToPackage", model);
            //        return InternalServerError(x.Message);
            //    }
            //}

            return BadRequest();
        }

        [HttpGet("getPackageAIdByProcess/{id}")]
        public async Task<IActionResult> GetetPackageAIdByProcess(int id)
        {
            return Ok(await _packagesService.GetPackageIdAByProcess(id));
        }

        [HttpGet("getPackageIdByInventory/{inventorySystemIdentifier}")]
        [Authorize]
        public async Task<IActionResult> GetPackageIdByInventory(Guid inventorySystemIdentifier, [FromQuery] string type)
        {
            try
            {
                return Success(await _packagesService.GetPackageIdByInventory(type, inventorySystemIdentifier));

            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error getting package id for package with type {type} for inventory {inventorySystemIdentifier}");
                return InternalServerError();
            }
        }

        [HttpDelete("removeFileFromPackage/{id}")]
        public async Task<IActionResult> RemoveFileFromPackage(int id)
        {
            try
            {
                OperationResult result = await _packagesService.RemoveFileFromPackageAsync(id);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString(result.Errors.First()).ToString());
                }

                return Ok();
            }
            catch (Exception x)
            {
                _logger.LogError(x, "Error removing file from package", id);
                return InternalServerError();
            }
        }

        [HttpGet("getAvailableDocsForAE/{inventorySystemIdentifier}/{packageId}")]
        public async Task<IActionResult> GetAvailablePackageDocumentsForArchivalEntity(Guid? inventorySystemIdentifier, int packageId)
        {
            try
            {
                var result = await _packagesService.GetAvailablePackageDocumentsForArchivalEntity(inventorySystemIdentifier, packageId);
                return Success(result);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting available package documents for archival entity");
                return InternalServerError();
            }
        }

        [HttpGet("files/download/{id}")]
        [Authorize]
        public async Task<IActionResult> GetPackageFile(int id, [FromQuery] int packageId)
        {
            var packageDocument = await _packagesService.GetPackageDocument(id);

            if (packageDocument == null)
            {
                _logger.LogError($"Package document {id} does not exists");
                return NotFound();
            }
            if (packageDocument.PackageId != packageId)
            {
                _logger.LogWarning($"Package document {id} is not in package with id {packageId}");
                return NotFound();
            }

            //var packageFile = await _fileService.GetFileAsync(packageDocument.FilePath!, (FileStreamLocation)packageDocument.FileLocation!);
            //return File(packageFile.Content!, packageDocument.ContentType!, packageDocument.FileName);
            var packageFile = await _fileService.GetFileStreamAsync(packageDocument.FilePath!, (FileStreamLocation)packageDocument.FileLocation!);

            return File(packageFile, packageDocument.ContentType!, packageDocument.FileName);
        }

        [HttpPost("files/add/{packageId?}")]
        [Authorize]
        public async Task<IActionResult> AddPackageFiles([FromForm] IFormFileCollection files, int? packageId, [FromQuery] string? type, [FromQuery] Guid? inventorySystemIdentiifer)
        {
            try
            {
                if (!packageId.HasValue && string.IsNullOrEmpty(type) && !inventorySystemIdentiifer.HasValue)
                {
                    _logger.LogError("Empty packageId, type and inventorySystemIdentiifer");
                    return BadRequest(_localizer.GetString("InvalidData").ToString());
                }

                var result = await _packagesService.AddPackageFilesAsync(files, packageId, type, inventorySystemIdentiifer);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    if (!result.RawErrors)
                    {
                        return BadRequest(result.ToString(false));
                    }
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(result.Data);

            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error creating package with type {type} for inventory {inventorySystemIdentiifer}");
                return InternalServerError();
            }
        }

        [HttpDelete("files/delete/{id}")]
        [Authorize]
        public async Task<IActionResult> DeletePackageFile(int id, [FromQuery] int packageId)
        {
            try
            {
                var result = await _packagesService.DeletePackageFileAsync(id, packageId);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    if (!result.RawErrors)
                    {
                        return BadRequest(result.ToString(false));
                    }
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success();

            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error deleting package document {id} in package {packageId}");
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

        [HttpGet("structureByInventory/{inventoryId}")]
        public async Task<IActionResult> GetStructureBInventory([FromRoute] Guid inventoryId)
        {
            try
            {
                var struc = await _packagesService.GetPackageBStructureForInventory(inventoryId);
                return Success(struc);
            }
            catch (Exception x)
            {
                return InternalServerError(x.Message);
            }
        }

        [HttpGet("PackageBById/{packageId}")]
        public async Task<IActionResult> GetByApplication([FromRoute] int packageId)
        {
            try
            {
                var packages = _packagesService.GetPackageBById(packageId);
                return Success(packages);
            }
            catch (Exception x)
            {
                return InternalServerError(x.Message);
            }
        }

        [HttpPost("packageWithImport")]
        [RequestFormLimits(ValueLengthLimit = MaxContentSizeInBytes, MultipartBodyLengthLimit = MaxMultipartContentSizeInBytes)]
        public async Task<IActionResult> CreateApplicationPackageWithImport([FromForm] string model, [FromForm] IEnumerable<IFormFile> packageBFiles)
        {
            try
            {
                PackageBImportModel? data = JsonConvert.DeserializeObject<PackageBImportModel>(model);

                if (data != null) //TODO Validate data
                {
                    //Link files to list objects
                    foreach (var doc in data.PackageB)
                    {
                        IFormFile? f = packageBFiles.FirstOrDefault(x => x.FileName == doc.FileName && doc.FileSize == x.Length);

                        if (f != null)
                        {
                            doc.File = f;
                        }
                    };

                    await _packagesService.CreateInventoryPackageBWithImport(data);
                    return Success();
                }

                return BadRequest();
            }
            catch (FileTypeNotSupportedException exc)
            {
                _logger.LogError(exc, "Error creating application package with import");
                return BadRequest(exc.Message);
            }
            catch (CustomException exc)
            {
                _logger.LogError(exc, "Error creating application package with import");
                return BadRequest(exc.Message);
            }
            catch (Exception x)
            {
                _logger.LogError(x, "Error creating application package with import");
                return InternalServerError(x.Message);
            }
        }
    }
}
