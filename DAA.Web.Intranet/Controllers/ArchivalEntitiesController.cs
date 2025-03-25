using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Models.ArchiveEntities;
using DAA.Models.Funds;
using DAA.Models.Inventories;
using DAA.Services.ArchivalEntities;
using DAA.Services.Funds;
using DAA.Services.Inventories;
using DAA.Services.Numbers;
using DAA.Services.ProcessRawInventoriesProcess;
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
    public class ArchivalEntitiesController : BaseApiController
    {
        private readonly IFundService _fundService;
        private readonly IInventoryService _inventoryService;
        private readonly IArchivalEntityService _archivalEntityService;
        private readonly IProcessRawInventoriesProcessService _processRawInventoriesProcessService;
        private readonly INumberService _numberService;

        public ArchivalEntitiesController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IFundService fundService,
           IInventoryService inventoryService,
           IArchivalEntityService archivalEntityService,
           IProcessRawInventoriesProcessService processRawInventoriesProcessService,
           INumberService numberService)
           : base(localizer, logger, userInfo)
        {
            _fundService = fundService;
            _inventoryService = inventoryService;
            _archivalEntityService = archivalEntityService;
            _processRawInventoriesProcessService = processRawInventoriesProcessService;
            _numberService = numberService;
        }

        [HttpPost("listall")]
        public IActionResult ListAll(DataSourceRequestModel model)
        {
            try
            {
                var archivalEntities =  _archivalEntityService.GetAll(model);
                if (archivalEntities?.Errors != null)
                {
                    _logger.LogError(string.Join(";", archivalEntities.Errors));
                    return BadRequest(string.Join(";", archivalEntities.Errors));
                }

                return Success(archivalEntities);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting archival entities list");
                return InternalServerError();
            }
        }

        [HttpGet("{sysId?}")]
        public async Task<IActionResult> Get(Guid? sysId, [FromQuery] bool? hasExternalSource, [FromQuery] int? externalIdentifier)
        {
            try
            {
                _logger.LogInformation($"Getting archival entity (sysId: {sysId}, hasExternalSource: {hasExternalSource}, externalIdentifier: {externalIdentifier}, userId: {_currentUserInfo.CurrentUserId})");

                if (sysId.HasValue && sysId.Value != Guid.Empty)
                {
                    try
                    {
                        await _archivalEntityService.CreateArchivalEntityReviewAsync(sysId, externalIdentifier);
                    }
                    catch (Exception exc)
                    {
                        _logger.LogError(exc, $"Error creating archival entity user review (sysId: {sysId}, extId: {externalIdentifier}, userId: {_currentUserInfo.CurrentUserId})");
                    }
                    
                    return Success(await _archivalEntityService.GetArchivalEntityBySystemIdentifierAsync(sysId.Value));
                }
                else
                {
                    if (hasExternalSource.HasValue && hasExternalSource.Value && externalIdentifier.HasValue)
                    {
                        try
                        {
                            await _archivalEntityService.CreateArchivalEntityReviewAsync(sysId, externalIdentifier);
                        }
                        catch (Exception exc)
                        {
                            _logger.LogError(exc, $"Error creating archival entity user review (sysId: {sysId}, extId: {externalIdentifier}, userId: {_currentUserInfo.CurrentUserId})");
                        }

                        return Success(await _archivalEntityService.GetFromExternalSourceAsync(externalIdentifier.Value));
                    }
                    else
                    {
                        _logger.LogError($"Archival entity has no system identifier ({sysId}) and external source ({hasExternalSource} {externalIdentifier})");
                        return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                    }
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting archival entity {sysId}");
                return InternalServerError();
            }
        }

        [HttpPost("listByInventory/{inventorySysId?}")]
        public async Task<IActionResult> ListByInventory(
            DataSourceRequestModel model, 
            Guid? inventorySysId, 
            [FromQuery] bool inventoryHasExternalSource, 
            [FromQuery] int? inventoryExternalIdentifier,
            [FromQuery] string? searchInventoryNumberString)
        {
            try
            {
                var arhivalEntities = 
                    await _archivalEntityService.GetByInventoryIdentifierAsync(
                        model,
                        inventorySysId, 
                        inventoryHasExternalSource, 
                        inventoryExternalIdentifier, 
                        searchInventoryNumberString);
                if (arhivalEntities?.Errors != null)
                {
                    _logger.LogError(string.Join(";", arhivalEntities.Errors));
                    return BadRequest(string.Join(";", arhivalEntities.Errors));
                }

                return Success(arhivalEntities);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting archival entities list");
                return InternalServerError();
            }
        }

        [HttpPost("listByAvailabilityStatus/{availabilityStatus}")]
        public IActionResult ListByAvailabilityStatus(
            DataSourceRequestModel model,
            int availabilityStatus,
            [FromQuery] Guid fundSystemIdentifier,
            [FromQuery] string? searchInventoryNumberString)
        {
            try
            {
                var archivalEntities =
                    _archivalEntityService.GetByAvailabilityStatus(
                        model,
                        availabilityStatus,
                        fundSystemIdentifier,
                        searchInventoryNumberString);
                if (archivalEntities?.Errors != null)
                {
                    _logger.LogError(string.Join(";", archivalEntities.Errors));
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(archivalEntities);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting documents list by availability status {availabilityStatus} for fund {fundSystemIdentifier}");
                return InternalServerError();
            }
        }

        [HttpPost]
        public async Task<IActionResult> Post(ArchivalEntityDraftModel model)
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

                string checkErrorMessage = string.Empty;

                if (!string.IsNullOrWhiteSpace(model.Number))
                {
                    try
                    {
                        var isArchivalEntityNumberValid = await _numberService.IsValidArchivalEntityNumber(
                                                        model.ArchiveId!.Value,
                                                        model.InventorySystemIdentifier!.Value,
                                                        model.Number,
                                                        model.DescriptionLevelCode);
                        if (!isArchivalEntityNumberValid)
                        {
                            _logger.LogError(_localizer.GetString("Error_NumberIsAlreadyUsed", model.Number).ToString());
                            return BadRequest(_localizer.GetString("Error_NumberIsAlreadyUsed", model.Number).ToString());
                        }
                    }
                    catch (ExternalConnectionException exc)
                    {
                        _logger.LogError(exc, $"Error checking archival entity number (archiveId: {model.ArchiveId}, inventorySysId: {model.InventorySystemIdentifier})");
                        checkErrorMessage = _localizer.GetString("Error_NoExternalConnection").ToString();
                    }
                    catch
                    {
                        throw;
                    }
                }

                var result = await _archivalEntityService.CreateDraftAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating archival entity draft {model}");
                return InternalServerError();
            }
        }

        [HttpPost("archivalEntity/{sysId}")]
        public async Task<IActionResult> CreateArchivalEntityFromDraft(Guid sysId)
        {
            try
            {
                var archivalEntityResult = await _archivalEntityService.CreateOrUpdateArchivalEntityFromDraftAsync(sysId);
                if (!archivalEntityResult.Succeeded)
                {
                    _logger.LogError(archivalEntityResult.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                
                return Success(archivalEntityResult.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating archival entity from draft {sysId}");
                return InternalServerError();
            }
        }

        [HttpPut]
        public async Task<IActionResult> Put(ArchivalEntityDraftModel model)
        {
            try
            {
                string checkErrorMessage = string.Empty;

                if (!string.IsNullOrWhiteSpace(model.Number))
                {
                    try
                    {
                        var isArchivalEntityNumberValid = await _numberService.IsValidArchivalEntityNumber(
                                                        model.ArchiveId!.Value,
                                                        model.InventorySystemIdentifier!.Value,
                                                        model.Number,
                                                        model.DescriptionLevelCode,
                                                        model.SystemIdentifier);
                        if (!isArchivalEntityNumberValid)
                        {
                            _logger.LogError(_localizer.GetString("Error_NumberIsAlreadyUsed", model.Number).ToString());
                            return BadRequest(_localizer.GetString("Error_NumberIsAlreadyUsed", model.Number).ToString());
                        }
                    }
                    catch (ExternalConnectionException exc)
                    {
                        _logger.LogError(exc, $"Error checking archival entity number for archivalEntitySysId: {model.SystemIdentifier}");
                        checkErrorMessage = _localizer.GetString("Error_NoExternalConnection").ToString();
                    }
                    catch
                    {
                        throw;
                    }
                }

                var result = await _archivalEntityService.UpdateDraftAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                //return Success(result.Data);
                return Success(checkErrorMessage);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error updating archival entity draft {model}");
                return InternalServerError();
            }
        }

        [HttpDelete("{sysId}")]
        public async Task<IActionResult> DeleteArchivalEntity(Guid sysId)
        {
            try
            {
                var result = await _archivalEntityService.DeleteArchivalEntityAsync(sysId);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting archival entity {sysId}");
                return InternalServerError();
            }
        }

        [HttpDelete("draft/{id}")]
        public async Task<IActionResult> DeleteDraft(int id)
        {
            try
            {
                var result = await _archivalEntityService.DeleteDraftAsync(id);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting archival entity draft {id}");
                return InternalServerError();
            }
        }

        [HttpPost("search")]
        public IActionResult Search(SearchedArchiveEntityRequestModel model)
        {
            try
            {
                var funds = _archivalEntityService.GetShortBySearchText(model);

                return Success(funds);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting archive entities list");
                return InternalServerError();
            }
        }

        [HttpPost("archivalEntityFromPackage/{inventorySysId}")]
        public async Task<IActionResult> CreateArchivalEntityFromPackage(Guid inventorySysId, [FromBody]List<int> packageDocuments)
        {
            if (packageDocuments == null || packageDocuments.Count == 0)
            {
                return BadRequest(_localizer.GetString("Error_InvalidData").Value);
            }

            try
            {
                var archivalEntityResult = await _processRawInventoriesProcessService.CreateEmptyArchivalEntityDraftFromPackageFilesAsync(inventorySysId, packageDocuments);
                if (!archivalEntityResult.Succeeded)
                {
                    _logger.LogError(archivalEntityResult.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(archivalEntityResult.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating archival entity from package for inventory {inventorySysId}");
                return InternalServerError();
            }
        }

        [HttpPost("archivalEntityPublicUsersReviews/{systemIdentifier?}")]
        public async Task<IActionResult> GetArchivalEntityPublicUsersReviews(Guid? systemIdentifier)
        {
            try
            {
                var publicUserReveiws =
                    await _archivalEntityService.GetArchivalEntityPublicUsersReviewsAsync(systemIdentifier);
                if (publicUserReveiws?.Errors != null)
                {
                    _logger.LogError(string.Join(";", publicUserReveiws.Errors));
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(publicUserReveiws);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting public user reviews for archival entity!");
                return InternalServerError();
            }
        }

    }
}
