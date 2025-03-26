using DAA.Extensions.Controller;
using DAA.Services.LibraryCardService;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Public.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LibraryCardsController : BaseApiController
    {
        private readonly ILibraryCardService _libraryCardService;

        public LibraryCardsController(
           IStringLocalizer<SharedResources> localizer,
           ILogger<BaseApiController> logger,
           IUserInfo userInfo,
           ILibraryCardService libraryCardService)
           : base(localizer, logger, userInfo)
        {
            _libraryCardService = libraryCardService;
        }


        [HttpGet("{number}")]
        public async Task<IActionResult> IsValid(string number)
        {
            try
            {
                if (string.IsNullOrEmpty(number))
                {
                    throw new ArgumentNullException("Card number");
                }

                var isValid = await _libraryCardService.IsValid(number);

                return Success(isValid);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error validating card number {number}" );
                return InternalServerError();
            }
        }
    }
}
