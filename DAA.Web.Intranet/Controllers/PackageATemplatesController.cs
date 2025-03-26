using DAA.Extensions.Controller;
using DAA.Models.Settings;
using DAA.Services.Settings;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Intranet.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PackageATemplatesController : BaseApiController
    {
        private readonly IPackageATemplatesService _templatesService;

        public PackageATemplatesController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IPackageATemplatesService templatesService,
           IUserInfo userInfo)
           : base(localizer, logger, userInfo)
        {
            _templatesService = templatesService;
        }

        [HttpGet("{processId}")]
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

        [HttpGet("Template/{id}")]
        public IActionResult GetTemplateById([FromRoute] int id)
        {
            try
            {
                var template = _templatesService.GetTemplateById(id);
                return Success(template);
            }
            catch (Exception x)
            {
                return InternalServerError(x.Message);
            }
        }

        [HttpGet("EmptyTemplatesByPackage")]
        public async Task<IActionResult> GetEmptyTemplatesByPackageId([FromQuery] int packageId, [FromQuery] int processId)
        {
            try
            {
                var template = await _templatesService.GetEmptyPackageTemplatesByInventoryId(packageId, processId);
                return Success(template);
            }
            catch (Exception x)
            {
                return InternalServerError(x.Message);
            }
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromForm] PackageATemplateCreateModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    var templateId = await _templatesService.AddTemplate(model);
                    return Success(templateId);
                }
                catch (Exception x)
                {
                    return InternalServerError(x.Message);
                }
            }

            return BadRequest(_localizer.GetString("Error_InvalidData").Value);
        }

        [HttpPut]
        public async Task<IActionResult> Update([FromForm] PackageATemplateUpdateModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    await _templatesService.UpdateTemplate(model);
                    return Success();
                }
                catch (Exception x)
                {
                    return InternalServerError(x.Message);
                }
            }

            return BadRequest(_localizer.GetString("Error_InvalidData").Value);
        }

        [HttpDelete("{templateId}")]
        public async Task<IActionResult> Delete([FromRoute] int templateId)
        {
            try
            {
                await _templatesService.RemoveTemplate(templateId);
                return Success();
            }
            catch (Exception x)
            {
                return InternalServerError(x.Message);
            }
        }

        [HttpGet("Download/{templateId}")]
        public async Task<IActionResult> Download([FromRoute] int templateId)
        {
            try
            {
                var file = await _templatesService.GetFile(templateId);
                return File(file.Content, file.ContentType, file.FileName);
            }
            catch (Exception x)
            {
                return InternalServerError(x.Message);
            }
        }
    }
}
