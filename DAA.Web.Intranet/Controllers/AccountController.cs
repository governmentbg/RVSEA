using DAA.Extensions.Controller;
using DAA.Identity;
using DAA.Models.Authentication;
using DAA.Models.Configuration;
using DAA.Models.Identity;
using DAA.Models.Users;
using DAA.Services.Admin;
using DAA.Services.Authentication;
using DAA.Services.Interfaces;
using DAA.Services.Users;
using DAA.Shared.Authorization;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http.Extensions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using ArchivingClaimTypes = DAA.Shared.Security.ClaimTypes;
using SystemClaimTypes = System.Security.Claims.ClaimTypes;

namespace DAA.Web.Intranet.Controllers
{
    [Route("api/[controller]")]
    [ApiController]

    public class AccountController : BaseApiController
    {
        private readonly IGlobalAdministratorService _globalAdministratorService;
        private readonly ITokenService _tokenService;
        private readonly ApplicationUserManager _userManager;
        private readonly IEmailService _emailService;
        private readonly IUserProfileService _userProfileService;
        private readonly IsdaOfficeRRRMail _isdaOfficeRRRMail;

        public AccountController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<AccountController> logger,
            IUserInfo userInfo,
            IGlobalAdministratorService globalAdministratorService,
            ITokenService tokenService,
            ApplicationUserManager userManager,
            IEmailService emailService,
            IUserProfileService userProfileService,
            IOptions<IsdaOfficeRRRMail> mail)
            : base(localizer, logger, userInfo)
        {
            _globalAdministratorService = globalAdministratorService;
            _tokenService = tokenService;
            _userManager = userManager;
            _emailService = emailService;
            _userProfileService = userProfileService;
            _isdaOfficeRRRMail = mail.Value;
        }

        private async Task<ApplicationUserResult?> AdminLogin(LoginModel model)
        {
            ApplicationUser user = _globalAdministratorService.CheckLogin(model);
            if (user == null)
            {
                _logger.LogInformation(String.Format(_localizer.GetString("NotGlobalAdministratorLogin").ToString(), model.Email));
                return null;
            }

            try
            {
                var token = _tokenService.GenerateToken(user, null!);
                string tokenStr = _tokenService.WriteToken(token);

                _logger.LogWarning($"Admin login for user {model.Email}");

                await _emailService.SendEmailAsync(
                    GlobalAdministrator.Email,
                    string.Empty,
                    string.Empty,
                    "DAA Admin Login",
                    $"Admin login in {HttpContext.Request.GetDisplayUrl()} for user {model.Email}");

                return new ApplicationUserResult()
                {
                    Token = tokenStr,
                    TokenExpiration = token.ValidTo,
                    Id = user.Id,
                    Name = user.UserName,
                    //DisplayName = user.DisplayName,
                    Email = user.Email,
                    IsAdmin = user.IsAdmin,
                    AdminType = user.AdminType,
                };
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Admin login error");
                return null;
            }
        }

        [HttpPost("authenticate")]
        [AllowAnonymous]
        public IActionResult Authenticate()
        {
            ClaimsPrincipal principal = _currentUserInfo.CurrentUser;
            ClaimsIdentity? identity = principal.Identity as ClaimsIdentity;
            if (principal == null || principal.Identity == null)
            {
                _logger.LogError("No windows identity available.");
                return Challenge();
            }

            if(!principal.Identity.IsAuthenticated)
            {
                _logger.LogWarning("No windows identity authenticated");
                return Challenge();
            }

            _logger.LogInformation($"{nameof(Authenticate)}: NameIdentifier {identity?.FindFirst(SystemClaimTypes.NameIdentifier)?.Value}");
            _logger.LogInformation($"{nameof(Authenticate)}: Name {identity?.Name}");
            _logger.LogInformation($"{nameof(Authenticate)}: IsAuthenticated {identity?.IsAuthenticated}");
            _logger.LogInformation($"{nameof(Authenticate)}: AuthenticationType {identity?.AuthenticationType}");

            Guid.TryParse(identity?.FindFirst(SystemClaimTypes.NameIdentifier)?.Value, out Guid userId);
            if (userId == Guid.Empty)
            {
                _logger.LogWarning($"Windows user {identity?.Name} authenticated, but is not user in the application.");
                return Forbid();
                //return Challenge();
            }

            bool.TryParse(identity?.FindFirst(ArchivingClaimTypes.IsAdmin)?.Value, out bool isAdmin);

            string? adminType = identity?.FindFirst(ArchivingClaimTypes.AdminType)?.Value;

            JwtSecurityToken token = _tokenService.GenerateToken(principal);
            string tokenString = _tokenService.WriteToken(token);

            _logger.LogInformation($"Token for user {identity?.Name} created successfully.");

            return Success(new ApplicationUserResult()
            {
                Token = tokenString,
                TokenExpiration = token.ValidTo,
                Id = userId,
                Name = identity?.Name,
                DisplayName = identity?.FindFirst(SystemClaimTypes.GivenName)?.Value,
                Email = identity?.FindFirst(SystemClaimTypes.Email)?.Value,
                ProfileType = identity?.FindFirst(ArchivingClaimTypes.ProfileType)?.Value,
                IsAdmin = isAdmin,
                AdminType = adminType,
            });
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login(LoginModel model)
        {
            try
            {
                var globalAdmin = await AdminLogin(model);
                if (globalAdmin != null)
                {
                    _logger.LogInformation("System admin logged in successfully");
                    return Success(globalAdmin);
                }

                _logger.LogWarning($"Non system admin tried to login {model.Email}");
                return BadRequest(_localizer.GetString("Error_InvalidUserOrPass").ToString());
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error logging system admin user");
                return InternalServerError();
            }
        }

        [HttpPost("registerReader")]
        //[Authorize(Roles = "Role_I1")]
        [Roles(ApplicationRoleType.GroupI1)]
        public async Task<IActionResult> RegisterReader(RegistrationReaderModel model)
        {
            try
            {
                if (model == null)
                {
                    throw new ArgumentNullException(nameof(model));
                }

                if (!model.Password.Equals(model.PasswordConfirmation, StringComparison.Ordinal))
                {
                    _logger.LogWarning($"Password mismatch {model.Username}");
                    return BadRequest(_localizer.GetString("Error_PasswordMismatch").ToString());
                }

                var user = await _userManager.FindByNameAsync(model.Username);
                if (user != null)
                {
                    _logger.LogWarning($"User with username {model.Username} already exists");
                    return BadRequest(_localizer.GetString("Error_UserExists", user.UserName).ToString());
                }

                user = new ApplicationUser
                {
                    //DisplayName = user.DisplayName,
                    UserName = model.Username,
                    Email = "ISDA@office.bg",
                    UserType = ApplicationUserType.Internal,
                    //UserProfileType = model.ProfileType,
                    AuthenticationType = AuthenticationType.Password,
                    EmailConfirmed = true,

                };

                _userManager.Options.User.RequireUniqueEmail = false;
                var userResult = await _userManager.CreateAsync(user, model.Password);
                _userManager.Options.User.RequireUniqueEmail = true;

                if (!userResult.Succeeded)
                {
                    _logger.LogError("Error creating user", userResult.ToString());
                    return BadRequest(String.Join("\\n\\r", userResult.Errors.Select(err => err.Description)));
                }

                var profile = new UserProfileModel()
                {
                    UserId = user.Id,
                    Address = model.Address,
                    Department = model.Department,
                    EntityType = model.ProfileEntityType,
                    FirstName = model.Username,
                    LastName = model.LastName,
                    JobTitle = model.JobTitle,
                    LibraryCardNumber = model.LibraryCardNumber,
                    Organization = model.Organization,
                    ProfileType = model.ProfileType,
                    Surname = model.Surname,
                };
                var profileResult = await _userProfileService.CreateProfileAsync(profile);
                if (!profileResult.Succeeded)
                {
                    _logger.LogError("Error creating user profile", profileResult.ToString());

                    var cleanupResult = await _userManager.DeleteAsync(user);
                    if (!cleanupResult.Succeeded)
                    {
                        _logger.LogError("Error cleaning up created user", cleanupResult.ToString());
                    }

                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error registering user");
                return InternalServerError();
            }

        }

        [HttpPost("confirm")]
        [AllowAnonymous]
        public async Task<IActionResult> ConfirmEmail(AccountConfirmationModel model)
        {
            ApplicationUser user = await _userManager.FindByIdAsync(model.UserId.ToString());

            if (user == null)
            {
                _logger.LogInformation(_localizer.GetString("Error_UserDoesNotExists").ToString(), model.UserId);
                return BadRequest(_localizer.GetString("Error_UserDoesNotExists").ToString());
            }

            var confirmationResult = await _userManager.ConfirmEmailAsync(user, model.ConfirmationToken);
            if (!confirmationResult.Succeeded)
            {
                _logger.LogError(confirmationResult.ToString());
                return BadRequest(_localizer.GetString("Error_AccountNotConfirmed").ToString());
            }

            return Success();
        }

        [NonAction]
        private async Task SendEmailConfirmation(ApplicationUser user)
        {
            var isEmailConfirmed = await _userManager.IsEmailConfirmedAsync(user);
            if (!isEmailConfirmed)
            {
                var confirmationToken = await _userManager.GenerateEmailConfirmationTokenAsync(user);
                var encodedConfirmationToken = System.Web.HttpUtility.UrlEncode(confirmationToken);

                var referer = Request.GetTypedHeaders().Referer;
                var basePath = Request.PathBase.Value?.TrimEnd('/');
                var relativePath = "confirm";
                var url = new UriBuilder()
                {
                    Scheme = referer.Scheme,
                    Host = referer.Host,
                    Port = referer.Port,
                    Path = $"{basePath}/{relativePath}",
                    Query = $"uid={user.Id}&code={encodedConfirmationToken}"
                };

                //var callbackUrl = $"{Request.GetTypedHeaders().Referer.ToString().TrimEnd('/')}/#/resetPassword?uid={model.Id}&code={encodedPasswordToken}";
                var callbackUrl = url.ToString();
                var emailResult = await _emailService.SendEmailAsync(user.Email,
                    string.Empty,
                    string.Empty,
                    _localizer.GetString("EmailConfirmation_Subject").ToString(),
                    String.Format(_localizer.GetString("EmailConfirmation_Body").ToString(), callbackUrl));
                if (!string.IsNullOrEmpty(emailResult))
                {
                    throw new Exception(emailResult);
                }
            }
        }

        [HttpGet("userInfo")]
        [Authorize]
        public async Task<IActionResult> GetCurrentUserInfo()
        {
            try
            {
                return Success(await _userProfileService.GetProfileAndProfileRoles(_currentUserInfo.CurrentUserId!.Value));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting user {_currentUserInfo.CurrentUserId!.Value}");
                return InternalServerError();
            }
        }
    }
}
