using DAA.Extensions.Controller;
using DAA.Models.Search;
using DAA.Services.Search;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using DAA.Extensions.Exceptions;

namespace DAA.Web.Public.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SearchController : BaseApiController
    {
        private readonly ISearchService _searchEngine;
        private new readonly ILogger<BaseApiController> _logger;

        private const string TimeoutMessage = "Timeout";

        public SearchController(
            IStringLocalizer<SharedResources> localizer,
            ISearchService searchEngine,
            ILogger<BaseApiController> logger)
            : base(localizer, logger)
        {
            _searchEngine = searchEngine;
            _logger = logger;
        }

        [HttpPost("getall")]
        public  async Task<IActionResult> GetDataByFilterCriteria(CancellationToken token, SearchModel model)
        {
            try
            {
                var searchDataResult = await _searchEngine.GetAll(token, model);

                if (searchDataResult?.Errors != null)
                {
                    _logger.LogError(string.Join(";", searchDataResult.Errors));
                    return BadRequest(string.Join(";", searchDataResult.Errors));
                }

                return Success(searchDataResult);
            }
            catch (OperationCanceledException exc)
            {
                _logger.LogInformation(exc, "Cancellation requested");
                return Success(_localizer.GetString("Search_Canceled").ToString());
            }
            catch (DBRequestTimeoutException exc)
            {
                _logger.LogWarning(exc, "Database request timeout");
                return InternalServerError(_localizer.GetString("Search_Timeout").ToString());
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error executing search");
                return InternalServerError();
            }
        }
    }
}
