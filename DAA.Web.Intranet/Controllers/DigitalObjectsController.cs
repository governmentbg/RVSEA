using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Models.ArchiveEntities;
using DAA.Models.DigitalObjects;
using DAA.Models.Documents;
using DAA.Models.File;
using DAA.Models.Funds;
using DAA.Models.Inventories;
using DAA.Models.Reports;
using DAA.Services.ArchivalEntities;
using DAA.Services.DigitalObjects;
using DAA.Services.Documents;
using DAA.Services.Files;
using DAA.Services.Funds;
using DAA.Services.Inventories;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Intranet.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class DigitalObjectsController : BaseApiController
    {
        private readonly IFundService _fundService;
        private readonly IInventoryService _inventoryService;
        private readonly IArchivalEntityService _archivalEntityService;
        private readonly IDocumentService _documentService;
        private readonly IDigitalObjectService _digitalObjectService;
        private readonly IFileService _fileService;

        public DigitalObjectsController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IFundService fundService,
           IInventoryService inventoryService,
           IArchivalEntityService archivalEntityService,
           IDocumentService documentService,
           IDigitalObjectService digitalObjectService,
           IFileService fileService)
           : base(localizer, logger, userInfo)
        {
            _fundService = fundService;
            _inventoryService = inventoryService;
            _archivalEntityService = archivalEntityService;
            _documentService = documentService;
            _digitalObjectService = digitalObjectService;
            _fileService = fileService;
        }

        [HttpPost("listByDocument/{documentSysId?}")]
        public async Task<IActionResult> ListByDocument(
            DataSourceRequestModel model,
            Guid? documentSysId,
            [FromQuery] bool documentHasExternalSource,
            [FromQuery] int? documentExternalIdentifier,
            [FromQuery] bool? digitized)
        {
            try
            {
                var digitalObjects =
                    await _digitalObjectService.GetByDocumentIdentifierAsync(
                        model,
                        documentSysId,
                        documentHasExternalSource,
                        documentExternalIdentifier,
                        digitized);
                if (digitalObjects?.Errors != null)
                {
                    if (digitalObjects.IsExternalSourceSnapshot.HasValue && digitalObjects.IsExternalSourceSnapshot.Value)
                    {
                        _logger.LogWarning(string.Join(";", digitalObjects.Errors));
                    }
                    else
                    {
                        _logger.LogError(string.Join(";", digitalObjects.Errors));
                        return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                    }
                }

                return Success(digitalObjects);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting digital objects list for document {documentSysId} {documentHasExternalSource} {documentExternalIdentifier}");
                return InternalServerError();
            }
        }

        [HttpPost("listByInventory/{inventorySysId?}")]
        public async Task<IActionResult> ListByInventory(
            DataSourceRequestModel model,
            Guid? inventorySysId,
            [FromQuery] bool inventoryHasExternalSource,
            [FromQuery] int? inventoryExternalIdentifier)
        {
            try
            {
                var digitalObjects =
                    await _digitalObjectService.GetByInventoryIdentifierAsync(
                        model,
                        inventorySysId,
                        inventoryHasExternalSource,
                        inventoryExternalIdentifier);
                if (digitalObjects?.Errors != null)
                {
                    if (digitalObjects.IsExternalSourceSnapshot.HasValue && digitalObjects.IsExternalSourceSnapshot.Value)
                    {
                        _logger.LogWarning(string.Join(";", digitalObjects.Errors));
                    }
                    else
                    {
                        _logger.LogError(string.Join(";", digitalObjects.Errors));
                        return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                    }
                }

                return Success(digitalObjects);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting digital objects list for document {inventorySysId} {inventoryHasExternalSource} {inventoryExternalIdentifier}");
                return InternalServerError();
            }
        }

        //[HttpGet("download/{sysId}")]
        //public async Task<IActionResult> Download(Guid sysId, bool? isInline)
        //{
        //    try
        //    {
        //        var digitalObject = await _digitalObjectService.GetDigitalObjectBySystemIdentifierAsync(sysId);
        //        if (digitalObject == null)
        //        {
        //            _logger.LogError($"Digital object {sysId} is null");
        //            return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
        //        }

        //        try
        //        {
        //            await _digitalObjectService.ManageDigitalObjectReviewAsync(digitalObject);
        //        }
        //        catch (Exception exc)
        //        {
        //            _logger.LogError(exc, $"Error getting/creating digital object review");
        //        }

        //        var file =
        //           await _fileService.GetFileAsync(
        //                !string.IsNullOrWhiteSpace(digitalObject.WatermarkUncPath) ? digitalObject.WatermarkUncPath : digitalObject.UncPath!,
        //                digitalObject.IsDraft ? Shared.FileStreamLocation.Buffer : Shared.FileStreamLocation.File);

        //        //var file =
        //        //   await _fileService.GetFileAsync(
        //        //       digitalObject.UncPath!,
        //        //       digitalObject.IsDraft ? Shared.FileStreamLocation.Buffer : Shared.FileStreamLocation.File);

        //        if (file == null || file.Content == null)
        //        {
        //            _logger.LogError($"File for digital object {sysId} or file content is null");
        //            return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
        //        }

        //        if (file.Type.ToUpper() == "PDF")
        //        {
        //            return Success(Convert.ToBase64String(file.Content));
        //        }
        //        if (file.Type.ToUpper() == "TIF" || file.Type.ToUpper() == "TIFF")
        //        {
        //            var resut = await _digitalObjectService.ConvertTiffToImage(file.Content);
        //            return new FileContentResult(resut, "image/gpeg");
        //        }
        //        //return File(file.Content, digitalObject.ContentType!, digitalObject.SourceName);
        //        Response.Headers.Add("Content-Disposition", $"{(isInline == true ? "inline" : "attachment")}; filename={digitalObject.SourceName}");
        //        string? extension = Path.GetExtension(digitalObject.SourceName);
        //        string contentType =
        //            extension == ".png" ? "image/png" :
        //            extension == ".tif" || extension == ".tiff" ? "image/jpg" :
        //            digitalObject.ContentType!;
        //        return new FileContentResult(file.Content, contentType);
        //    }
        //    catch (Exception x)
        //    {
        //        _logger.LogError(x.ToString());
        //        return InternalServerError();
        //    }
        //}

        [HttpPost]
        [RequestFormLimits(ValueLengthLimit = MaxContentSizeInBytes, MultipartBodyLengthLimit = MaxMultipartContentSizeInBytes)]
        public async Task<IActionResult> Post([FromForm] DigitalObjectDraftModel model, [FromQuery]bool? autogenerateDerivative)
        {  
            try
            {
                if (model.FundHasExternalSource
                    && !model.FundDraftId.HasValue
                    && (!model.FundSystemIdentifier.HasValue || model.FundSystemIdentifier.Value == Guid.Empty))
                {
                    if (!model.FundExternalIdentifier.HasValue)
                    {
                        _logger.LogError("Model missing FundExternalIdentifier");
                        return BadRequest(_localizer.GetString("InvalidData").ToString());
                    }

                    var fundEntity = await _fundService.GetFromExternalSourceAsync(model.FundExternalIdentifier.Value);
                    if (fundEntity == null)
                    {
                        _logger.LogError($"No fund with identifier {model.FundExternalIdentifier} in the external source.");
                        return BadRequest(_localizer.GetString("InvalidData").ToString());
                    }

                    if (!fundEntity.SystemIdentifier.HasValue || fundEntity.SystemIdentifier.Value == Guid.Empty)
                    {
                        //var fund = new FundModel()
                        //{
                        //    ArchiveId = model.ArchiveId,
                        //    HasExternalSource = model.FundHasExternalSource,
                        //    ExternalIdentifier = model.FundExternalIdentifier,
                        //    //NumberArray = fundNumberArray,
                        //    NumberArray = fundEntity.NumberArray,
                        //    Number = fundEntity.Number,
                        //    NumberNumeric = fundEntity.NumberNumeric,
                        //    Title = fundEntity.Title,
                        //    HasNoChronologicalScope = fundEntity.HasNoChronologicalScope,
                        //    StartDateYear = fundEntity.StartDateYear,
                        //    StartDateMonth = fundEntity.StartDateMonth,
                        //    StartDateDay = fundEntity.StartDateDay,
                        //    EndDateYear = fundEntity.EndDateYear,
                        //    EndDateMonth = fundEntity.EndDateMonth,
                        //    EndDateDay = fundEntity.EndDateDay,
                        //    ApproxmateChronologicalScope = fundEntity.ApproxmateChronologicalScope,
                        //    Bytes = fundEntity.Bytes,
                        //    LinearMeters = fundEntity.LinearMeters,
                        //    OtherMetrics = fundEntity.OtherMetrics,
                        //    InventoryCount = fundEntity.InventoryCount,
                        //    ArchivalEntityCount = fundEntity.ArchivalEntityCount,
                        //    DocumentCount = fundEntity.DocumentCount,
                        //    FundCreatorTitleHistory = fundEntity.FundCreatorTitleHistory,
                        //    FundCreatorActivityHistory = fundEntity.FundCreatorActivityHistory,
                        //    FundCreatorBiographicalHistory = fundEntity.FundCreatorBiographicalHistory,
                        //    DocumentsProvider = fundEntity.DocumentsProvider,
                        //    DocumentsDescription = fundEntity.DocumentsDescription,
                        //    ValuableDocumentsInventoryCount = fundEntity.ValuableDocumentsInventoryCount,
                        //    InvaluableDocumentsInventoryCount = fundEntity.InvaluableDocumentsInventoryCount,
                        //    DocumentsAccessDescription = fundEntity.DocumentsAccessDescription,
                        //    History = fundEntity.History,
                        //    RelatedFunds = fundEntity.RelatedFunds,
                        //    Notes = fundEntity.Notes,
                        //    EnrolledBytes = fundEntity.EnrolledBytes,
                        //    EnrolledInventoryCount = fundEntity.EnrolledInventoryCount,
                        //    DeductedBytes = fundEntity.DeductedBytes,
                        //    DeductedInventoryCount = fundEntity.DeductedInventoryCount,
                        //};
                        var fund = new FundModel();
                        fund.Assign(fundEntity, true);

                        var fundResult = await _fundService.CreateFundAsync(fund);
                        if (!fundResult.Succeeded)
                        {
                            _logger.LogError(fundResult.ToString());
                            return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                        }

                        model.FundSystemIdentifier = Guid.Parse(fundResult.Data!.ToString()!);
                    }
                    else
                    {
                        model.FundSystemIdentifier = fundEntity.SystemIdentifier;
                    }
                }

                if (model.InventoryHasExternalSource
                    && !model.InventoryDraftId.HasValue
                    && (!model.InventorySystemIdentifier.HasValue || model.InventorySystemIdentifier.Value == Guid.Empty))
                {
                    var inventoryEntity = await _inventoryService.GetFromExternalSourceAsync(model.InventoryExternalIdentifier!.Value);
                    if (inventoryEntity == null)
                    {
                        _logger.LogError($"No inventory with identifier {model.InventoryExternalIdentifier} in the external source.");
                        return BadRequest(_localizer.GetString("InvalidData").ToString());
                    }

                    if (!inventoryEntity.SystemIdentifier.HasValue || inventoryEntity.SystemIdentifier.Value == Guid.Empty)
                    {
                        //var inventory = new InventoryModel()
                        //{
                        //    ArchiveId = model.ArchiveId!.Value,
                        //    FundSystemIdentifier = model.FundSystemIdentifier,
                        //    ExternalIdentifier = model.InventoryExternalIdentifier,
                        //    HasExternalSource = model.InventoryHasExternalSource,
                        //    //NumberArray = inventoryEntity.NumberArray,
                        //    Number = inventoryEntity.Number,
                        //    NumberNumeric= inventoryEntity.NumberNumeric,
                        //    HasNoChronologicalScope = inventoryEntity.HasNoChronologicalScope,
                        //    StartDateYear = inventoryEntity.StartDateYear,
                        //    StartDateMonth = inventoryEntity.StartDateMonth,
                        //    StartDateDay = inventoryEntity.StartDateDay,
                        //    EndDateYear = inventoryEntity.EndDateYear,
                        //    EndDateMonth = inventoryEntity.EndDateMonth,
                        //    EndDateDay = inventoryEntity.EndDateDay,
                        //    ApproxmateChronologicalScope = inventoryEntity.ApproxmateChronologicalScope,
                        //    Bytes = inventoryEntity.Bytes,
                        //    LinearMeters = inventoryEntity.LinearMeters,
                        //    OtherMetrics = inventoryEntity.OtherMetrics,
                        //    ArchivalEntityCount = inventoryEntity.ArchivalEntityCount,
                        //    DocumentCount = inventoryEntity.DocumentCount,
                        //    BoxCount = inventoryEntity.BoxCount,
                        //    RollCount = inventoryEntity.RollCount,
                        //    AudioDocumentArchivalEntityCount = inventoryEntity.AudioDocumentArchivalEntityCount,
                        //    PhotoDocumentArchivalEntityCount = inventoryEntity.PhotoDocumentArchivalEntityCount,
                        //    VideoDocumentArchivalEntityCount = inventoryEntity.VideoDocumentArchivalEntityCount,
                        //    DigitalDocumentArchivalEntityCount = inventoryEntity.DigitalDocumentArchivalEntityCount,
                        //    FundCreatorTitleHistory = inventoryEntity.FundCreatorTitleHistory,
                        //    FundCreatorBiographicalHistory = inventoryEntity.FundCreatorBiographicalHistory,
                        //    History = inventoryEntity.History,
                        //    DocumentsProvider = inventoryEntity.DocumentsProvider,
                        //    DocumentsDescription = inventoryEntity.DocumentsDescription,
                        //    DocumentsAccessDescription = inventoryEntity.DocumentsAccessDescription,
                        //    ClassificationScheme = inventoryEntity.ClassificationScheme,
                        //    AbbreviationList = inventoryEntity.AbbreviationList,
                        //    MicrofilmedArchivalEntityCount = inventoryEntity.MicrofilmedArchivalEntityCount,
                        //    DigitizedArchivalEntityCount = inventoryEntity.DigitizedArchivalEntityCount,
                        //    NegativeFrameCount = inventoryEntity.NegativeFrameCount,
                        //    PositiveFrameCount = inventoryEntity.PositiveFrameCount,
                        //    Notes = inventoryEntity.Notes
                        //};
                        var inventory = new InventoryModel();
                        inventory.Assign(inventoryEntity, true);
                        inventory.NumberArray = null;

                        var inventoryResult = await _inventoryService.CreateInventoryAsync(inventory);
                        if (!inventoryResult.Succeeded)
                        {
                            _logger.LogError(inventoryResult.ToString());
                            return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                        }

                        model.InventorySystemIdentifier = Guid.Parse(inventoryResult.Data!.ToString()!);
                    }
                    else
                    {
                        model.InventorySystemIdentifier = inventoryEntity.SystemIdentifier;
                    }
                }

                if (model.ArchivalEntityHasExternalSource
                    && !model.ArchivalEntityDraftId.HasValue
                    && (!model.ArchivalEntitySystemIdentifier.HasValue || model.ArchivalEntitySystemIdentifier.Value == Guid.Empty))
                {
                    var archivalEntityEntity = await _archivalEntityService.GetFromExternalSourceAsync(model.ArchivalEntityExternalIdentifier!.Value);
                    if (archivalEntityEntity == null)
                    {
                        _logger.LogError($"No archival entity with identifier {model.ArchivalEntityExternalIdentifier} in the external source.");
                        return BadRequest(_localizer.GetString("InvalidData").ToString());
                    }

                    if (!archivalEntityEntity.SystemIdentifier.HasValue || archivalEntityEntity.SystemIdentifier.Value == Guid.Empty)
                    {
                        //var archivalEntity = new ArchivalEntityModel()
                        //{
                        //    ArchiveId = model.ArchiveId!.Value,
                        //    FundSystemIdentifier = model.FundSystemIdentifier,
                        //    InventorySystemIdentifier = model.InventorySystemIdentifier,
                        //    ExternalIdentifier = model.ArchivalEntityExternalIdentifier,
                        //    HasExternalSource = model.ArchivalEntityHasExternalSource,
                        //    Number = archivalEntityEntity.Number,
                        //    NumberNumeric= archivalEntityEntity.NumberNumeric,
                        //    HasNoChronologicalScope = archivalEntityEntity.HasNoChronologicalScope,
                        //    StartDateYear = archivalEntityEntity.StartDateYear,
                        //    StartDateMonth = archivalEntityEntity.StartDateMonth,
                        //    StartDateDay = archivalEntityEntity.StartDateDay,
                        //    EndDateYear = archivalEntityEntity.EndDateYear,
                        //    EndDateMonth = archivalEntityEntity.EndDateMonth,
                        //    EndDateDay = archivalEntityEntity.EndDateDay,
                        //    ApproximateChronologicalScope = archivalEntityEntity.ApproximateChronologicalScope,
                        //    Bytes = archivalEntityEntity.Bytes,
                        //    OtherMetrics = archivalEntityEntity.OtherMetrics,
                        //    DocumentsAccessDescription = archivalEntityEntity.DocumentsAccessDescription,
                        //    NegativeFrameCount = archivalEntityEntity.NegativeFrameCount,
                        //    PositiveFrameCount = archivalEntityEntity.PositiveFrameCount,
                        //    Notes = archivalEntityEntity.Notes,
                        //    Author = archivalEntityEntity.Author,
                        //    Condition= archivalEntityEntity.Condition,
                        //    Description= archivalEntityEntity.Description,
                        //    Title= archivalEntityEntity.Title,
                        //    Features= archivalEntityEntity.Features,
                        //    Location= archivalEntityEntity.Location,
                        //};
                        var archivalEntity = new ArchivalEntityModel();
                        archivalEntity.Assign(archivalEntityEntity, true);

                        var archivalEntityResult = await _archivalEntityService.CreateArchivalEntityAsync(archivalEntity);
                        if (!archivalEntityResult.Succeeded)
                        {
                            _logger.LogError(archivalEntityResult.ToString());
                            return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                        }

                        model.ArchivalEntitySystemIdentifier = Guid.Parse(archivalEntityResult.Data!.ToString()!);
                    }
                    else
                    {
                        model.ArchivalEntitySystemIdentifier = archivalEntityEntity.SystemIdentifier;
                    }
                }

                if (model.DocumentHasExternalSource
                    && !model.DocumentDraftId.HasValue
                    && (!model.DocumentSystemIdentifier.HasValue || model.DocumentSystemIdentifier.Value == Guid.Empty))
                {
                    var documentEntity = await _documentService.GetFromExternalSourceAsync(model.DocumentExternalIdentifier!.Value);
                    if (documentEntity == null)
                    {
                        _logger.LogError($"No document with identifier {model.DocumentExternalIdentifier} in the external source.");
                        return BadRequest(_localizer.GetString("InvalidData").ToString());
                    }

                    if (!documentEntity.SystemIdentifier.HasValue || documentEntity.SystemIdentifier.Value == Guid.Empty)
                    {
                        //var document = new DocumentModel()
                        //{
                        //    ArchiveId = model.ArchiveId!.Value,
                        //    FundSystemIdentifier = model.FundSystemIdentifier,
                        //    InventorySystemIdentifier = model.InventorySystemIdentifier,
                        //    ArchivalEntitySystemIdentifier = model.ArchivalEntitySystemIdentifier,
                        //    ExternalIdentifier = model.DocumentExternalIdentifier,
                        //    HasExternalSource = model.DocumentHasExternalSource,
                        //    Title = documentEntity.Title,
                        //    Number = documentEntity.Number,
                        //    HasNoChronologicalScope = documentEntity.HasNoChronologicalScope,
                        //    StartDateYear = documentEntity.StartDateYear,
                        //    StartDateMonth = documentEntity.StartDateMonth,
                        //    StartDateDay = documentEntity.StartDateDay,
                        //    EndDateYear = documentEntity.EndDateYear,
                        //    EndDateMonth = documentEntity.EndDateMonth,
                        //    EndDateDay = documentEntity.EndDateDay,
                        //    Bytes = documentEntity.Bytes,
                        //    OtherMetrics = documentEntity.OtherMetrics,
                        //    DocumentsAccessDescription = documentEntity.DocumentsAccessDescription,
                        //    NegativeFrameCount = documentEntity.NegativeFrameCount,
                        //    PositiveFrameCount = documentEntity.PositiveFrameCount,
                        //    Notes = documentEntity.Notes,
                        //    ApproximateChronologicalScope = documentEntity.ApproximateChronologicalScope,
                        //    Author = documentEntity.Author,
                        //    Description = documentEntity.Description,
                        //    DigitalDevice = documentEntity.DigitalDevice,
                        //    DigitizedCopyCount = documentEntity.DigitizedCopyCount,
                        //    Duration = documentEntity.Duration,
                        //    EndSheetNumber = documentEntity.EndSheetNumber,
                        //    Features = documentEntity.Features,
                        //    FileFormatCode = documentEntity.FileFormatCode,
                        //    Location = documentEntity.Location,
                        //    MicrofilmedCopyCount = documentEntity.MicrofilmedCopyCount,
                        //    OtherCopyCount = documentEntity.OtherCopyCount,
                        //    PaperCopyCount = documentEntity.PaperCopyCount,
                        //    Scaling = documentEntity.Scaling,
                        //    SheetCount = documentEntity.SheetCount,
                        //    SizeCm = documentEntity.SizeCm,
                        //    StartSheetNumber = documentEntity.StartSheetNumber,
                        //    Transcription = documentEntity.Transcription
                        //};
                        var document = new DocumentModel();
                        document.Assign(documentEntity, true);

                        var documentResult = await _documentService.CreateDocumentAsync(document);
                        if (!documentResult.Succeeded)
                        {
                            _logger.LogError(documentResult.ToString());
                            return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                        }

                        model.DocumentSystemIdentifier = Guid.Parse(documentResult.Data!.ToString()!);
                    }
                    else
                    {
                        model.DocumentSystemIdentifier = documentEntity.SystemIdentifier;
                    }
                }

                var result = await _digitalObjectService.CreateDraftAsync(model, autogenerateDerivative ?? false);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(result.Errors.First().ToString());
                }

                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating digital object");
                return InternalServerError();
            }
        }

        [HttpGet("{sysId?}")]
        public async Task<IActionResult> Get(Guid? sysId, [FromQuery] bool? hasExternalSource, [FromQuery] int? externalIdentifier)
        {
            try
            {
                if (sysId.HasValue)
                {
                    DigitalObjectDisplayModel? digitalObject = await _digitalObjectService.GetDigitalObjectBySystemIdentifierAsync(sysId.Value);
                    try
                    {
                        await _digitalObjectService.ManageDigitalObjectReviewAsync(digitalObject);
                    }
                    catch (Exception exc)
                    {
                        _logger.LogError(exc, $"Error getting/creating digital object review");
                    }
                    return Success(digitalObject);
                }
                else
                {
                    if (hasExternalSource.HasValue && hasExternalSource.Value && externalIdentifier.HasValue)
                    {
                        return Success(await _digitalObjectService.GetFromExternalSourceAsync(externalIdentifier.Value));
                    }
                    else
                    {
                        _logger.LogError($"Digital object has no system identifier ({sysId}) and external source ({hasExternalSource} {externalIdentifier})");
                        return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                    }
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting digital object {sysId} {hasExternalSource} {externalIdentifier}");
                return InternalServerError();
            }
        }

        [HttpPut]
        public async Task<IActionResult> Put([FromForm] DigitalObjectDraftModel model)
        {
            try
            {
                if (!model.SystemIdentifier.HasValue)
                {
                    var digitalObject = await _digitalObjectService.GetDigitalObjectByDocumentIdentifierAsync(model.Name!, model.DocumentSystemIdentifier!.Value);
                    if (digitalObject == null)
                    {
                        var createResult = await _digitalObjectService.CreateDraftAsync(model);
                        if (!createResult.Succeeded)
                        {
                            _logger.LogError(createResult.ToString());
                            var message = FormatMessage(createResult, _localizer.GetString("Error_ExecutingAction").ToString());
                            return BadRequest(message);
                        }

                        return Success(createResult.Data);
                    }
                    else
                    {
                        if (digitalObject.IsDraft)
                        {
                            model.Id = digitalObject.Id;
                        }
                        model.SystemIdentifier = digitalObject.SystemIdentifier;
                    }
                }
                var result = await _digitalObjectService.UpdateDraftAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    return BadRequest(message);
                }

                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error updating digital object draft {model.SystemIdentifier}");
                return InternalServerError();
            }
        }

        [HttpDelete("{sysId}")]
        public async Task<IActionResult> DeleteDigitalObject(Guid sysId, [FromQuery] bool? includeRelated)
        {
            try
            {
                var result = await _digitalObjectService.DeleteDigitalObjectAsync(sysId, includeRelated.HasValue && includeRelated.Value);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    return BadRequest(message);
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting digital object {sysId}");
                return InternalServerError();
            }
        }

        [HttpDelete("draft/{id}")]
        public async Task<IActionResult> DeleteDraft(int id, [FromQuery] bool? includeRelated)
        {
            try
            {
                var result = await _digitalObjectService.DeleteDraftAsync(id, includeRelated.HasValue && includeRelated.Value);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    var message = FormatMessage(result, _localizer.GetString("Error_ExecutingAction").ToString());
                    return BadRequest(message);
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting digital object draft {id}");
                return InternalServerError();
            }
        }

        [HttpPost("digitalObjectReviews")]
        public IActionResult GetDigitalObjectReviews(ReportGridRequestModel<DigitalObjectReviewSearchModel> model)
        {
            try
            {
                return Ok(_digitalObjectService.GetDigitalObjectReviewsAsync(model));
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString($"Error getting digital object reviews for period {model.Filters.StartDate} - {model.Filters.EndDate}"));
                return InternalServerError();
            }
        }

        //[HttpGet("downloadDarivative/{sysId}")]
        //public async Task<IActionResult> DownloadDerivative(Guid sysId, bool? download)
        //{
        //    try
        //    {
        //        var digitalObject = await _digitalObjectService.GetDigitalObjectDraftBySystemIdentifierAsync(sysId);

        //        if (digitalObject == null)
        //        {
        //            _logger.LogError($"Digital object draft {sysId} is null");
        //            return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
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

        [HttpGet("stream/{sysId}")]
        public async Task<IActionResult> Stream(Guid sysId, [FromQuery] bool? inline)
        {
            try
            {
                var digitalObject = await _digitalObjectService.GetDigitalObjectBySystemIdentifierAsync(sysId);
                if (digitalObject == null)
                {
                    _logger.LogError($"Digital object {sysId} is null");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                try
                {
                    await _digitalObjectService.ManageDigitalObjectReviewAsync(digitalObject);
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
                            await _fileService.GetFileBase64StringAsync(
                                !string.IsNullOrWhiteSpace(digitalObject.WatermarkUncPath) ? digitalObject.WatermarkUncPath : digitalObject.UncPath!,
                                digitalObject.IsDraft ? Shared.FileStreamLocation.Buffer : Shared.FileStreamLocation.File
                        ));
                    }
                    if (extension == ".TIF" || extension == ".TIFF")
                    {
                        var resut = await _fileService.TryConvertFileToImageAsync(!string.IsNullOrWhiteSpace(digitalObject.WatermarkUncPath) ? digitalObject.WatermarkUncPath : digitalObject.UncPath!,
                                digitalObject.IsDraft ? Shared.FileStreamLocation.Buffer : Shared.FileStreamLocation.File);
                        return File(resut, "image/jpeg");
                    }
                }

                string contentType = string.IsNullOrWhiteSpace(digitalObject.ContentType)
                                        ? "application/octet-stream"
                                        : digitalObject.ContentType!;

                var fileStream =
                   await _fileService.GetFileStreamAsync(
                        !string.IsNullOrWhiteSpace(digitalObject.WatermarkUncPath) ? digitalObject.WatermarkUncPath : digitalObject.UncPath!,
                        digitalObject.IsDraft ? Shared.FileStreamLocation.Buffer : Shared.FileStreamLocation.File);

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

        [HttpGet("draft/stream/{sysId}")]
        public async Task<IActionResult> StreamDraft(Guid sysId, [FromQuery] bool? inline)
        {
            try
            {
                var digitalObjectDraft = await _digitalObjectService.GetDigitalObjectDraftBySystemIdentifierAsync(sysId);
                if (digitalObjectDraft == null)
                {
                    _logger.LogError($"Digital object draft {sysId} is null");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                string? extension = Path.GetExtension(digitalObjectDraft.SourceName)?.ToUpper();

                if (inline.HasValue && inline.Value)
                {
                    if (extension == ".PDF")
                    {
                        //return as base64 string to be able to display?
                        return Success<string>(
                            await _fileService.GetFileBase64StringAsync(digitalObjectDraft.UncPath!, Shared.FileStreamLocation.Buffer));
                    }
                    if (extension == ".TIF" || extension == ".TIFF")
                    {
                        var resut = await _fileService.TryConvertFileToImageAsync(digitalObjectDraft.UncPath!, Shared.FileStreamLocation.Buffer);
                        return File(resut, "image/jpeg");
                    }
                }

                string contentType = string.IsNullOrWhiteSpace(digitalObjectDraft.ContentType)
                                        ? "application/octet-stream"
                                        : digitalObjectDraft.ContentType!;

                var fileStream =
                   await _fileService.GetFileStreamAsync(digitalObjectDraft.UncPath!, Shared.FileStreamLocation.Buffer);

                if (inline.HasValue)
                {
                    Response.Headers.Add("Content-Disposition", $"{(inline.HasValue && inline.Value ? "inline" : "attachment")}");
                }

                return File(fileStream, contentType, digitalObjectDraft.SourceName, true);

            }
            catch (FileNotFoundException exc)
            {
                _logger.LogError(exc, $"File for digital object draft {sysId} not found");
                return NotFound();
            }
            catch (Exception x)
            {
                _logger.LogError(x, $"Error streaming file for digital object draft {sysId}");
                return InternalServerError();
            }
        }
    }
}
