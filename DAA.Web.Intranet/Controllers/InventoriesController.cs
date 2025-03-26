using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Models.Funds;
using DAA.Models.Inventories;
using DAA.Services.Applications;
using DAA.Services.Funds;
using DAA.Services.Inventories;
using DAA.Services.Numbers;
using DAA.Services.Process;
using DAA.Shared;
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
    public class InventoriesController : BaseApiController
    {
        private readonly IFundService _fundService;
        private readonly IInventoryService _inventoryService;
        private readonly IProcessService _processService;
        private readonly INumberService _numberService;
        private readonly IApplicationsService _applicationService;

        public InventoriesController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IFundService fundService,
           IInventoryService inventoryService,
           IProcessService processService,
           INumberService numberService,
           IApplicationsService applicationService)
           : base(localizer, logger, userInfo)
        {
            _fundService = fundService;
            _inventoryService = inventoryService;
            _processService = processService;
            _numberService = numberService;
            _applicationService = applicationService;
        }

        [HttpPost("listall")]
        public IActionResult ListAll(DataSourceRequestModel model, [FromQuery] bool? includeDrafts)
        {
            try
            {
                DataSourceResponseModel<InventoryDisplayModel>? inventories = null;
                
                if(includeDrafts.HasValue)
                {
                    inventories = _inventoryService.GetAll(model, includeDrafts.Value, false);   
                }
                else
                {
                    inventories = _inventoryService.GetAll(model);
                }
                
                if (inventories?.Errors != null)
                {
                    _logger.LogError(String.Join(";", inventories.Errors));
                    return BadRequest(String.Join(";", inventories.Errors));
                }

                return Success(inventories);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting inventories list");
                return InternalServerError();
            }
        }

        [HttpPost("listbyfund/{fundSysId?}")]
        public async Task<IActionResult> ListByFund(DataSourceRequestModel model, Guid? fundSysId, [FromQuery] bool hasExternalSource, [FromQuery] int? externalIdentifier)
        {
            try
            {
                var inventories = await _inventoryService.GetByFundIdentifier(model, fundSysId, hasExternalSource, externalIdentifier);
                if (inventories?.Errors != null)
                {
                    _logger.LogError(String.Join(";", inventories.Errors));
                    return BadRequest(String.Join(";", inventories.Errors));
                }

                return Success(inventories);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting inventories list for fund");
                return InternalServerError();
            }
        }

        [HttpGet("{sysId?}")]
        public async Task<IActionResult> Get(Guid? sysId, [FromQuery] bool? hasExternalSource, [FromQuery] int? externalIdentifier, [FromQuery] bool? includeDrafts)
        {
            try
            {
                _logger.LogInformation($"Getting inventory (sysId: {sysId}, hasExternalSource: {hasExternalSource}, externalIdentifier: {externalIdentifier}, userId: {_currentUserInfo.CurrentUserId})");

                if (sysId.HasValue && sysId.Value != Guid.Empty)
                {
                    try
                    {
                        await _inventoryService.CreateInventoryReviewAsync(sysId, externalIdentifier);
                    }
                    catch (Exception exc)
                    {
                        _logger.LogError(exc, $"Error creating inventory user review (sysId: {sysId}, extId: {externalIdentifier}, userId: {_currentUserInfo.CurrentUserId})");
                    }
                    
                    if (includeDrafts.HasValue)
                    {
                        return Success(await _inventoryService.GetInventoryBySystemIdentifierAsync(sysId.Value, includeDrafts.Value));
                    }

                    return Success(await _inventoryService.GetInventoryBySystemIdentifierAsync(sysId.Value));
                }
                else
                {
                    if (hasExternalSource.HasValue && hasExternalSource.Value && externalIdentifier.HasValue)
                    {
                        try
                        {
                            await _inventoryService.CreateInventoryReviewAsync(sysId, externalIdentifier);
                        }
                        catch (Exception exc)
                        {
                            _logger.LogError(exc, $"Error creating inventory user review (sysId: {sysId}, extId: {externalIdentifier}, userId: {_currentUserInfo.CurrentUserId})");
                        }

                        return Success(await _inventoryService.GetFromExternalSourceAsync(externalIdentifier.Value));
                    }
                    else
                    {
                        _logger.LogError($"Inventory has no system identifier ({sysId}) and external source ({hasExternalSource} {externalIdentifier})");
                        return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                    }
                }

            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting inventory {sysId}");
                return InternalServerError();
            }
        }

        [HttpPost]
        public async Task<IActionResult> Post(InventoryDraftCreateModel model)
        {
            try
            {
                if (model == null)
                {
                    throw new ArgumentException(nameof(model));
                }


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

                //check fund description level and inventory description level
                string descLevelErrorMessage = string.Empty;
                bool invalidDescriptionLevel = false;
                var fundDescriptionLevel = await _fundService.GetDescriptionLevelAsync(model.FundSystemIdentifier!.Value);
                int.TryParse(model.DescriptionLevelCode, out int descriptionLevel);
                if (fundDescriptionLevel.HasValue)
                {
                    switch ((FundDescriptionLevel)fundDescriptionLevel.Value)
                    {
                        case FundDescriptionLevel.Fund:
                            if ((InventoryDescriptionLevel)descriptionLevel == InventoryDescriptionLevel.SystemInventory)
                            {
                                invalidDescriptionLevel = true;
                                descLevelErrorMessage = _localizer.GetString("Error_CannotAddSystemInventory").ToString();
                            }
                            break;
                        case FundDescriptionLevel.RawFund:
                            if ((InventoryDescriptionLevel)descriptionLevel != InventoryDescriptionLevel.RawInventory)
                            {
                                invalidDescriptionLevel = true;
                                descLevelErrorMessage =
                                    (InventoryDescriptionLevel)descriptionLevel == InventoryDescriptionLevel.Inventory
                                    ? _localizer.GetString("Error_CannotAddInventory").ToString()
                                    : _localizer.GetString("Error_CannotAddSystemInventory").ToString();
                            }
                            break;
                        case FundDescriptionLevel.ChP:
                        case FundDescriptionLevel.Memory:
                            if ((InventoryDescriptionLevel)descriptionLevel != InventoryDescriptionLevel.SystemInventory)
                            {
                                invalidDescriptionLevel = true;
                                descLevelErrorMessage =
                                    (InventoryDescriptionLevel)descriptionLevel == InventoryDescriptionLevel.Inventory
                                    ? _localizer.GetString("Error_CannotAddInventory").ToString()
                                    : _localizer.GetString("Error_CannotRawSystemInventory").ToString();
                            }
                            break;
                    }

                    if (invalidDescriptionLevel)
                    {
                        _logger.LogError($"{nameof(Post)}: Cannot create inventory. Invalid inventory description level {model.DescriptionLevelCode} for fund with sysId {model.FundSystemIdentifier}");
                        return BadRequest(_localizer.GetString("Error_CannotCreateInventory", descLevelErrorMessage).ToString());
                    }
                }

                var result = await _inventoryService.CreateDraftAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating inventory draft {model}");
                return InternalServerError();
            }
        }

        [HttpPost("inventory/{sysId}")]
        public async Task<IActionResult> CreateInventoryFromDraft(Guid sysId)
        {
            try
            {
                var inventoryResult = await _inventoryService.CreateOrUpdateInventoryFromDraftAsync(sysId);
                if (!inventoryResult.Succeeded)
                {
                    _logger.LogError(inventoryResult.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating inventory from draft {sysId}");
                return InternalServerError();
            }
        }

        [HttpPut]
        public async Task<IActionResult> Put(InventoryDraftModel model)
        {
            try
            {
                string checkErrorMessage = string.Empty;

                if (!string.IsNullOrWhiteSpace(model.Number))
                {
                    try
                    { 
                        var isInventoryNumberValid = await _numberService.IsValidInventoryNumber(
                                                        model.ArchiveId, 
                                                        model.FundSystemIdentifier!.Value, 
                                                        model.NumberNumeric!.Value, 
                                                        model.NumberArray!, 
                                                        model.DescriptionLevelCode, 
                                                        model.SystemIdentifier);
                        if (!isInventoryNumberValid)
                        {
                            _logger.LogError(_localizer.GetString("Error_NumberIsAlreadyUsed", model.Number).ToString());
                            return BadRequest(_localizer.GetString("Error_NumberIsAlreadyUsed", model.Number).ToString());
                        }
                    }
                    catch (ExternalConnectionException exc)
                    {
                        _logger.LogError(exc, $"Error checking inventory number for inventorySysId: {model.SystemIdentifier}");
                        checkErrorMessage = _localizer.GetString("Error_NoExternalConnection").ToString();
                    }
                    catch
                    {
                        throw;
                    }
                }

                var activeProcess = await _processService.GetCurrentActiveProcess(BusinessObjectType.Inventory, model.SystemIdentifier!.Value, true);
                var validateProcessResult = _processService.ValidateProcess(
                                                activeProcess,
                                                ProcessType.AddFundAndInventory,
                                                ProcessType.AddRawFundAndRawInventory,
                                                ProcessType.AddInventory,
                                                ProcessType.AddRawInventory,
                                                ProcessType.AddRawInventoryToRawFund);
                if (activeProcess != null && validateProcessResult.Succeeded)
                {
                    var inventory = await _inventoryService.GetInventoryBySystemIdentifierAsync(model.SystemIdentifier.Value);
                    if (inventory == null)
                    {
                        _logger.LogError($"Inventory not found (sysId: {model.SystemIdentifier})");
                        return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                    }
                    //След като веднъж е посочен номер на заявление,не може да бъде премахнат, защото се променя начина на работа на процеса за комплектуване.
                    if (inventory.ApplicationId.HasValue && !model.ApplicationId.HasValue)
                    {
                        _logger.LogError($"Inventory model missing ApplicationId (sysId: {model.SystemIdentifier})");
                        return BadRequest(_localizer.GetString("Error_MissingApplication").ToString());
                    }
                    //Ако заявление вече има пакети А и Б, то вече не може да бъде подменено
                    if (inventory.ApplicationId.HasValue 
                        && inventory.ApplicationId != model.ApplicationId
                        && await _applicationService.HasAnyPackagesAsync(inventory.ApplicationId.Value))
                    {
                        _logger.LogError($"Inventory model missing ApplicationId (sysId: {model.SystemIdentifier})");
                        return BadRequest(String.Concat(_localizer.GetString("Error_CannotModifyInventoryApplication").ToString(), " ", _localizer.GetString("Error_ApplicationPackagesAlreadyExist").ToString()));
                    }
                }

                
                var result = await _inventoryService.UpdateDraftAsync(model);
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
                _logger.LogError(exc, $"Error updating inventory {model.SystemIdentifier}");
                return InternalServerError();
            }
        }

        [HttpDelete("{sysId}")]
        public async Task<IActionResult> DeleteInventory(Guid sysId)
        {
            try
            {
                var result = await _inventoryService.DeleteInventoryAsync(sysId);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting inventory {sysId}");
                return InternalServerError();
            }
        }

        [HttpDelete("draft/{id}")]
        public async Task<IActionResult> DeleteDraft(int id)
        {
            try
            {
                var result = await _inventoryService.DeleteDraftAsync(id);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting inventory draft {id}");
                return InternalServerError();
            }
        }

        [HttpGet("getByFundId/{fundId}")]
        public IActionResult GetByFundId(int fundId)
        {
            try
            {
                var funds = _inventoryService.GetShortByFundId(fundId);

                return Success(funds);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting inventories list");
                return InternalServerError();
            }
        }

        [HttpPost("inventoryPublicUsersReviews/{systemIdentifier?}")]
        public async Task<IActionResult> GetInventoryPublicUsersReviews(Guid? systemIdentifier)
        {
            try
            {
                var publicUserReveiws =
                    await _inventoryService.GetInventoryPublicUsersReviewsAsync(systemIdentifier);
                if (publicUserReveiws?.Errors != null)
                {
                    _logger.LogError(string.Join(";", publicUserReveiws.Errors));
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success(publicUserReveiws);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting public user reviews for inventory!");
                return InternalServerError();
            }
        }
    }
}
