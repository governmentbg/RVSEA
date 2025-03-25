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

namespace DAA.Web.Public.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FilmDocumentsController : BaseApiController
    {
        private readonly IFilmDocumentPublicService _filmDocumentPublicService;
        private readonly IFilmPublicService _filmPublicService;
        private readonly ISystemAuthorizationService _authorizationService;

        public FilmDocumentsController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IFilmDocumentPublicService filmDocumentPublicService,
           IFilmPublicService filmPublicService,
           ISystemAuthorizationService authorizationService)
           : base(localizer, logger, userInfo)
        {
            _filmDocumentPublicService = filmDocumentPublicService;
            _filmPublicService = filmPublicService;
            _authorizationService = authorizationService;
        }

        [HttpPost("listall/{packageId}")]
        public IActionResult ListAll(DataSourceRequestModel model, int packageId)
        {
            try
            {
                var result = _filmDocumentPublicService.GetAll(model, packageId);
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

        [HttpGet("download/{docId}")]
        public async Task<IActionResult> Download(int docId)
        {
            try
            {
                var file = await _filmDocumentPublicService.GetFile(docId);
                if (file == null || file.Content == null)
                {
                    _logger.LogError($"File docId {docId} or file content is null");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return File(file.Content, file.ContentType, file.Name);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error downloading film document {docId}");
                return InternalServerError(ex.Message);
            }
        }
    }
}
