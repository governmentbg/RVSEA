using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Archives;
using DAA.Services;
using DAA.Shared.Authorization;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Intranet.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ArchivesController : BaseApiController
    {
        private readonly IArchiveService _archiveService;

        public ArchivesController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           IArchiveService archiveService)
           : base(localizer, logger, userInfo)
        {
            _archiveService = archiveService;
        }

        [HttpPost("listall")]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public IActionResult ListAll(DataSourceRequestModel model)
        {
            try
            {
                var archives = _archiveService.GetAll(model);
                if (archives?.Errors != null)
                {
                    _logger.LogError(String.Join(";", archives.Errors));
                    return BadRequest(String.Join(";", archives.Errors));
                }

                return Success(archives);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting archives list");
                return InternalServerError();
            }
        }

        [HttpGet("{id}")]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> Get(int id)
        {
            try
            {
                return Success(await _archiveService.GetById(id));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting archive {id}");
                return InternalServerError();
            }
        }


        [HttpGet("getArchiveDirectorName")]
        public async Task<IActionResult> GetDiroctorNameByArchiveId([FromQuery] int id)
        {
            try
            {
                var result = await _archiveService.GetDiroctorNameByArchiveId(id);

                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting archive {id}");
                return InternalServerError();
            }
        }

        [HttpGet("external")]
        //[Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> GetFromExternalSource([FromQuery] string searchText)
        {
            try
            {
                return Success(await _archiveService.GetFromExternalSourceBySearchTextAsync(searchText));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting external archive data");
                return InternalServerError();
            }
        }

        [HttpPost]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> Post(ArchiveModel model)
        {
            try
            {
                var result = await _archiveService.CreateAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating archive {model}");
                return InternalServerError();
            }
        }

        [HttpPut]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> Put(ArchiveModel model)
        {
            try
            {
                var result = await _archiveService.UpdateAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error updating archive {model.Id}");
                return InternalServerError();
            }
        }

        [HttpDelete("{id}")]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                var result = await _archiveService.DeleteAsync(id);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting archive {id}");
                return InternalServerError();
            }
        }
    }
}
