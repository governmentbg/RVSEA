using DAA.Extensions.Controller;
using DAA.Models.Comments;
using DAA.Models.Documents.DocumentsProcedure;
using DAA.Services.Comments;
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
    public class CommentsController : BaseApiController
    {
        private readonly ICommentsService _service;
        public CommentsController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<BaseApiController> logger,
            IUserInfo userInfo,
            ICommentsService service)
            : base(localizer, logger, userInfo)
        {

            _service = service;
        }


        [HttpPost]
        public async Task<IActionResult> Post(CommentModel model)
        {
            try
            {
                var result = await _service.CreateAsync(model);
                if (!result.Succeeded)
                {
                    var message = result.RawErrors
                        ? _localizer.GetString("Error_ExecutingAction").ToString()
                        : result.ToString(false);
                    _logger.LogError(result.ToString());
                    return BadRequest(message);
                }

                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating comment"); 
                return InternalServerError();
            }
        }

        [HttpPut]
        public async Task<IActionResult> Put(CommentModel model)
        {
            try
            {
                var result = await _service.UpdateAsync(model);
                if (!result.Succeeded)
                {
                    var message = result.RawErrors
                        ? _localizer.GetString("Error_ExecutingAction").ToString()
                        : result.ToString(false);
                    _logger.LogError(result.ToString());
                    return BadRequest(message);
                }

                return Success(result.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error updating comment {model.Id}");
                return InternalServerError();
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            try
            {
                return Success(await _service.GetCommentAsync(id));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting comment {id}");
                return InternalServerError();
            }
        }

        [HttpGet("standpoint/{standpointId}")]
        public IActionResult GetByStandpoiontId(int standpointId)
        {
            try
            {
                return Success(_service.GetBySessionAgendaStandpointId(standpointId));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting comments list for standpoint {standpointId}");
                return InternalServerError();
            }
        }

        [HttpGet("getAll/{processId}/{processStepId}")]
        public IActionResult GetAll([FromRoute] int processId, int processStepId)
        {
            try
            {
                return Success(_service.GetAll(processId, processStepId));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting view models  'comment process'{processId}");
                return InternalServerError();
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                var result = await _service.DeleteAsync(id);
                if (!result.Succeeded)
                {
                    var message = result.RawErrors
                        ? _localizer.GetString("Error_ExecutingAction").ToString()
                        : result.ToString(false);
                    _logger.LogError(result.ToString());
                    return BadRequest(message);
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error deleting comment {id}");
                return InternalServerError();
            }
        }
    }
}



