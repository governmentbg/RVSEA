
using DAA.Extensions.Controller;
using DAA.Models.Settings;
using DAA.Services.Settings;
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
    public class TaskTemplatesController : BaseApiController
    {
        private readonly ITaskTemplatesService _templatesService;
        public TaskTemplatesController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           ITaskTemplatesService templatesService,
           IUserInfo userInfo)
           : base(localizer, logger, userInfo)
        {
            _templatesService = templatesService;
        }

        [HttpGet("{processStepId}")]
        public IActionResult GetByProcessStep([FromRoute] int processStepId)
        {
            try
            {
                var templates = _templatesService.GetTemplates(processStepId);
                return Success(templates);
            }
            catch (Exception x)
            {
                return InternalServerError(x.Message);
            }
        }

        [HttpGet("template/{id}")]
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

        [HttpPost]
        public async Task<IActionResult> Create(TaskTemplateCreateModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    var templateId = await _templatesService.AddTemplate(model);

                    if (templateId.Errors.Any())
                    {
                        return BadRequest(_localizer.GetString("Error_CreateNewTaskTemplate").Value);
                    }

                    return Success(templateId.Data);

                }
                catch (Exception x)
                {
                    return InternalServerError(x.Message);
                   
                }
            }
            return BadRequest();
        }

        [HttpPut]
        public async Task<IActionResult> Update(TaskTemplateUpdateModel model)
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
    }
}
