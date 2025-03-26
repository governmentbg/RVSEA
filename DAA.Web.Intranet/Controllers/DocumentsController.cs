using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Models.ArchiveEntities;
using DAA.Models.Documents;
using DAA.Models.Funds;
using DAA.Models.Inventories;
using DAA.Services.ArchivalEntities;
using DAA.Services.Documents;
using DAA.Services.Funds;
using DAA.Services.Inventories;
using DAA.Services.Numbers;
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
    public class DocumentsController : BaseApiController
    {
        private readonly IFundService _fundService;
        private readonly IInventoryService _inventoryService;
        private readonly IArchivalEntityService _archivalEntityService;
        private readonly IDocumentService _documentService;
        private readonly INumberService _numberService;

        public DocumentsController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IFundService fundService,
           IInventoryService inventoryService,
           IArchivalEntityService archivalEntityService,
           INumberService numberService,
           IDocumentService documentService)
           : base(localizer, logger, userInfo)
        {
            _fundService = fundService;
            _inventoryService = inventoryService;
            _archivalEntityService = archivalEntityService;
            _documentService = documentService;
            _numberService = numberService;
        }

        [HttpPost("listall")]
        public IActionResult ListAll(DataSourceRequestModel model)
        {
            try
            {
                var documents = _documentService.GetAll(model);
                if (documents?.Errors != null)
                {
                    _logger.LogError(string.Join(";", documents.Errors));
                    return BadRequest(string.Join(";", documents.Errors));
                }

                return Success(documents);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting documents list");
                return InternalServerError();
            }
        }

        [HttpPost("listByArchivalEntity/{archivalEntitySysId?}")]
        public async Task<IActionResult> ListByArchivalEntity(
            DataSourceRequestModel model,
            Guid? archivalEntitySysId,
            [FromQuery] bool archivalEntityHasExternalSource,
            [FromQuery] int? archivalEntityExternalIdentifier,
            [FromQuery] string? searchArchivalEntityNumber,
            [FromQuery] int? searchArchivalEntityStartSheet,
            [FromQuery] int? searchArchivalEntityEndSheet)
        {
            try
            {
                var documents =
                    await _documentService.GetByArchivalEntityIdentifierAsync(
                        model,
                        archivalEntitySysId,
                        archivalEntityHasExternalSource,
                        archivalEntityExternalIdentifier,
                        searchArchivalEntityNumber,
                        searchArchivalEntityStartSheet,
                        searchArchivalEntityEndSheet);
                if (documents?.Errors != null)
                {
                    _logger.LogError(string.Join(";", documents.Errors));
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(documents);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting documents list for archival entity {archivalEntitySysId}");
                return InternalServerError();
            }
        }

        [HttpPost("listByAvailabilityStatus/{availabilityStatus}")]
        public IActionResult ListByAvailabilityStatus(
            DataSourceRequestModel model,
            int availabilityStatus,
            [FromQuery] Guid fundSystemIdentifier,
            [FromQuery] string? searchArchivalEntityNumber,
            [FromQuery] int? searchArchivalEntityStartSheet,
            [FromQuery] int? searchArchivalEntityEndSheet)
        {
            try
            {
                var documents =
                    _documentService.GetByAvailabilityStatus(
                        model,
                        availabilityStatus,
                        fundSystemIdentifier,
                        searchArchivalEntityNumber,
                        searchArchivalEntityStartSheet,
                        searchArchivalEntityEndSheet);
                if (documents?.Errors != null)
                {
                    _logger.LogError(string.Join(";", documents.Errors));
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(documents);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting documents list by availability status {availabilityStatus} for fund {fundSystemIdentifier}");
                return InternalServerError();
            }
        }

        [HttpPost]
        public async Task<IActionResult> Post(DocumentDraftModel model)
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
                        //    DeductedInventoryCount = fundEntity.DeductedInventoryCount
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
                        //    NumberNumeric = inventoryEntity.NumberNumeric,
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
                };

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
                        //    NumberNumeric = archivalEntityEntity.NumberNumeric,
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
                        //    Notes = archivalEntityEntity.Notes
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
                };
                string checkErrorMessage = string.Empty;

                if (!string.IsNullOrWhiteSpace(model.Number))
                {
                    try
                    {
                        var isDocumentNumberValid = await _numberService.IsValidDocumentNumber(
                                                        model.ArchiveId!.Value,
                                                        model.InventorySystemIdentifier!.Value,
                                                        model.ArchivalEntitySystemIdentifier!.Value,
                                                        model.Number);

                        if (!isDocumentNumberValid)
                        {
                            _logger.LogError(_localizer.GetString("Error_NumberIsAlreadyUsed", model.Number).ToString());
                            return BadRequest(_localizer.GetString("Error_NumberIsAlreadyUsed", model.Number).ToString());
                        }
                    }
                    catch (Exception е)
                    {
                        _logger.LogError(е, $"Error checking document number for documentSysId: {model.SystemIdentifier}");
                        checkErrorMessage = _localizer.GetString("Error_NoExternalConnection").ToString();
                    }
                }

                var result = await _documentService.CreateDraftAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating document {model}");
                return InternalServerError();
            }
        }

        [HttpGet("{sysId?}")]
        public async Task<IActionResult> Get(Guid? sysId, [FromQuery] bool? hasExternalSource, [FromQuery] int? externalIdentifier)
        {
            try
            {
                _logger.LogInformation($"Getting document (sysId: {sysId}, hasExternalSource: {hasExternalSource}, externalIdentifier: {externalIdentifier}, userId: {_currentUserInfo.CurrentUserId})");

                if (sysId.HasValue && sysId.Value != Guid.Empty)
                {
                    try
                    {
                        await _documentService.CreateDocumentReviewAsync(sysId, externalIdentifier);
                    }
                    catch (Exception exc)
                    {
                        _logger.LogError(exc, $"Error creating document user review (sysId: {sysId}, extId: {externalIdentifier}, userId: {_currentUserInfo.CurrentUserId})");
                    }

                    return Success(await _documentService.GetDocumentBySystemIdentifierAsync(sysId.Value));
                }
                else
                {
                    if (hasExternalSource.HasValue && hasExternalSource.Value && externalIdentifier.HasValue)
                    {
                        try
                        {
                            await _documentService.CreateDocumentReviewAsync(sysId, externalIdentifier);
                        }
                        catch (Exception exc)
                        {
                            _logger.LogError(exc, $"Error creating document user review (sysId: {sysId}, extId: {externalIdentifier}, userId: {_currentUserInfo.CurrentUserId})");
                        }

                        return Success(await _documentService.GetFromExternalSourceAsync(externalIdentifier.Value));
                    }
                    else
                    {
                        _logger.LogError($"Document has no system identifier ({sysId}) and external source ({hasExternalSource} {externalIdentifier})");
                        return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                    }
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting document {sysId}");
                return InternalServerError();
            }
        }

        [HttpPut]
        public async Task<IActionResult> Put(DocumentDraftModel model)
        {
            try
            {
                string checkErrorMessage = string.Empty;

                if (!string.IsNullOrWhiteSpace(model.Number))
                {
                    try
                    {
                        var isDocumentNumberValid = await _numberService.IsValidDocumentNumber(
                                                        model.ArchiveId!.Value,
                                                        model.InventorySystemIdentifier!.Value,
                                                        model.ArchivalEntitySystemIdentifier!.Value,
                                                        model.Number,
                                                        model.SystemIdentifier);

                        if (!isDocumentNumberValid)
                        {
                            _logger.LogError(_localizer.GetString("Error_NumberIsAlreadyUsed", model.Number).ToString());
                            return BadRequest(_localizer.GetString("Error_NumberIsAlreadyUsed", model.Number).ToString());
                        }
                    }
                    catch (Exception е)
                    {
                        _logger.LogError(е, $"Error checking document number for documentSysId: {model.SystemIdentifier}");
                        checkErrorMessage = _localizer.GetString("Error_NoExternalConnection").ToString();
                    }
                }

                var result = await _documentService.UpdateDraftAsync(model);

                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(checkErrorMessage);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error updating document draft {model}");
                return InternalServerError();
            }
        }

        [HttpDelete("{sysId}")]
        public async Task<IActionResult> DeleteDocument(Guid sysId)
        {
            try
            {
                var result = await _documentService.DeleteDocumentAsync(sysId);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting document {sysId}");
                return InternalServerError();
            }
        }

        [HttpDelete("draft/{id}")]
        public async Task<IActionResult> DeleteDraft(int id)
        {
            try
            {
                var result = await _documentService.DeleteDraftAsync(id);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting document draft {id}");
                return InternalServerError();
            }
        }

        [HttpPost("documentPublicUsersReviews/{systemIdentifier?}")]
        public async Task<IActionResult> GetDocumentPublicUsersReviews(Guid? systemIdentifier)
        {
            try
            {
                var publicUserReveiws =
                    await _documentService.GetDocumentPublicUsersReviewsAsync(systemIdentifier);
                if (publicUserReveiws?.Errors != null)
                {
                    _logger.LogError(string.Join(";", publicUserReveiws.Errors));
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(publicUserReveiws);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting public user reviews for document!");
                return InternalServerError();
            }
        }
    }
}
