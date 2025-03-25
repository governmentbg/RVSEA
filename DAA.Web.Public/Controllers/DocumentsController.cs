using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Documents;
using DAA.Services.Documents;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Public.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DocumentsController : BaseApiController
    {

        private readonly IDocumentPublicService _documentService;

        public DocumentsController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<DocumentsController> logger,
           IUserInfo userInfo,
           IDocumentPublicService documentService)
           : base(localizer, logger, userInfo)
        {
            _documentService = documentService;
        }


        [AllowAnonymous]
        [HttpGet("{sysId?}")]
        public async Task<IActionResult> Get(Guid? sysId, [FromQuery] bool? hasExternalSource, [FromQuery] int? externalIdentifier)
        {
            try
            {
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
        [AllowAnonymous]
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

        [HttpGet("getDraft/{sysId?}")]
        [Authorize]
        public async Task<IActionResult> GetDraft(Guid sysId)
        {
            try
            {
                if (sysId != Guid.Empty)
                {
                    DocumentPublicImportModel? result = await _documentService.GetDocumentDraftBySysIdAsync(sysId);
                    return Success(result);
                }
                else
                {
                    _logger.LogError($"Document has no system identifier ({sysId})");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting document draft {sysId}");
                return InternalServerError();
            }
        }

        [HttpPost]
        public async Task<IActionResult> ModifyDraft(DocumentPublicImportModel model)
        {
            try
            {
                if (model == null)
                {
                    throw new ArgumentException(nameof(model));
                }

                var result = await _documentService.UpdateDraftAsync(model, _currentUserInfo.CurrentUserId);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(String.Join("; ", result.Errors));
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error modifying document draft {model}");
                return InternalServerError();
            }
        }

    }
}
