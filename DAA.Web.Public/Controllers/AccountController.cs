using DAA.Extensions.Controller;
using DAA.Models.Authentication;
using DAA.Models.Identity;
using DAA.Services.Authentication;
using DAA.Identity;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using SystemClaimTypes = System.Security.Claims.ClaimTypes;
using ArchivingClaimTypes = DAA.Shared.Security.ClaimTypes;
using DAA.Shared.Security;
using Microsoft.AspNetCore.Authorization;
using DAA.Services.Users;
using DAA.Shared;
using DAA.Models.Users;
using DAA.Services.Interfaces;
using DAA.Services.LibraryCardService;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Options;
using DAA.Models.Configuration;

namespace DAA.Web.Public.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AccountController : BaseApiController
    {
        private readonly ITokenService _tokenService;
        private readonly IUserProfileService _userProfileService;
        private readonly ApplicationUserManager _userManager;
        private readonly IEmailService _emailService;
        private readonly ILibraryCardService _libraryCardService;
        private readonly EmailTokenSettings _emailTokenSettings;

        public AccountController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<AccountController> logger,
            IUserInfo userInfo,
            ITokenService tokenService,
            IOptions<EmailTokenSettings> emailTokenSettings,
            IUserProfileService userProfileService,
            ApplicationUserManager userManager,
            IEmailService emailService,
            ILibraryCardService libraryCardService)
            : base(localizer, logger, userInfo)
        {
            _tokenService = tokenService;
            _emailTokenSettings = emailTokenSettings.Value;
            _userProfileService = userProfileService;
            _userManager = userManager;
            _emailService = emailService;
            _libraryCardService = libraryCardService;
        }

        [HttpPost("register")]
        [AllowAnonymous]
        public async Task<IActionResult> Register(RegistrationModel model)
        {
            try
            {
                if (model == null)
                {
                    throw new ArgumentNullException(nameof(model));
                }
                if (!model.Email.Equals(model.EmailConfirmation, StringComparison.OrdinalIgnoreCase))
                {
                    _logger.LogWarning($"Username mismatch {model.Email} {model.EmailConfirmation}");
                    return BadRequest(AuthenticationMessageCodes.EmailMismatch);
                }
                if (!model.Password.Equals(model.PasswordConfirmation, StringComparison.Ordinal))
                {
                    _logger.LogWarning($"Password mismatch {model.Email}");
                    return BadRequest(AuthenticationMessageCodes.PasswordMismatch);
                }

                var user = await _userManager.FindByNameAsync(model.Email);
                if (user != null)
                {
                    _logger.LogWarning($"User with username {model.Email} already exists");
                    return BadRequest(AuthenticationMessageCodes.UserExists);
                }
                var userFoundByEmail = await _userManager.FindByEmailAsync(model.Email);
                if (userFoundByEmail != null)
                {
                    _logger.LogWarning($"User with email {model.Email} already exists");
                    return BadRequest(AuthenticationMessageCodes.UserExists);
                }

                try
                {
                    if (model.ProfileType == ApplicationUserProfileType.CardHolder)
                    {
                        var isLibraryCardValid = await _libraryCardService.IsValid(model.LibraryCardNumber!);
                        if (!isLibraryCardValid)
                        {
                            _logger.LogWarning($"Library card invalid: {model.LibraryCardNumber}");
                            return BadRequest(AuthenticationMessageCodes.LibraryCardInvalid);
                        }
                    }

                }
                catch (Exception exc)
                {
                    _logger.LogError(exc, "Error validating library card");
                    return InternalServerError(LibraryCardService.CannotValidateLibraryCardBecauseOfISDAConnectionMissingMessageKey);
                }

                user = new ApplicationUser
                {
                    //DisplayName = string.Join(" ", model.FirstName.Trim(), model.Surname?.Trim(), model.LastName.Trim()),
                    UserName = model.Email.Trim(),
                    Email = model.Email.Trim(),
                    UserType = ApplicationUserType.External,
                    //UserProfileType = model.ProfileType,
                    AuthenticationType = AuthenticationType.Password,
                };

                var userResult = await _userManager.CreateAsync(user, model.Password);
                if (!userResult.Succeeded)
                {
                    _logger.LogError("Error creating user", userResult.ToString());
                    if (userResult.ToString() == "Failed : PasswordTooShort")
                    {
                        return BadRequest(AuthenticationMessageCodes.PasswordTooShort);
                    }
                    return BadRequest(AuthenticationMessageCodes.Error);
                }

                var profile = new UserProfileModel()
                {
                    UserId = user.Id,
                    Address = model.Address,
                    Department = model.Department,
                    EntityType = model.ProfileEntityType,
                    FirstName = model.FirstName,
                    LastName = model.LastName,
                    JobTitle = model.JobTitle,
                    LibraryCardNumber = model.LibraryCardNumber,
                    Organization = model.Organization,
                    ProfileType = model.ProfileType,
                    Surname = model.Surname,
                    Eik = model.Eik,
                    Phone = model.Phone,
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

                    return BadRequest(AuthenticationMessageCodes.Error);
                }

                try
                {
                    await SendEmailConfirmation(user);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, $"Error sending confirmation mail to {user.Email}");
                    return BadRequest(AuthenticationMessageCodes.ConfirmationMailNotSent);
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error registering user");
                return InternalServerError();
            }

        }

        [HttpGet("userProfile")]
        [Authorize]
        public async Task<IActionResult> GetUserProfile()
        {
            try
            {
                UserProfileModel user = await _userProfileService.GetProfileAsync(_currentUserInfo.CurrentUserId.Value);

                if (user == null)
                {
                    _logger.LogInformation(_localizer.GetString("Error_UserDoesNotExists").ToString(), _currentUserInfo.CurrentUserId.Value);
                    return BadRequest(AuthenticationMessageCodes.InvalidUserOrPass);
                }

                return Success(user);
            }
            catch (Exception x)
            {
                _logger.LogError(x, "User get profile error");
                return InternalServerError();
            }
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login(LoginModel model)
        {
            try
            {
                ApplicationUser user = await _userManager.FindByNameAsync(model.Email);
                if (user == null)
                {
                    _logger.LogInformation(_localizer.GetString("Error_UserDoesNotExists").ToString(), model.Email);
                    return BadRequest(AuthenticationMessageCodes.InvalidUserOrPass);
                }
                else
                {
                    if (!user.Deleted)
                    {
                        if (!user.EmailConfirmed)
                        {
                            _logger.LogWarning($"Email {model.Email} not confirmed");
                            return BadRequest(AuthenticationMessageCodes.EmailNotConfirmed);
                        }

                        bool checkPassword = await _userManager.CheckPasswordAsync(user, model.Password);
                        if (checkPassword)
                        {
                            try
                            {
                                var userClaims = await _userManager.GetClaimsAsync(user);
                                var userProfile = await _userProfileService.GetProfileAsync(user.Id);
                                if (userClaims.Any(claim => claim.Type == ArchivingClaimTypes.AdminType && claim.Value == AdminType.Admin))
                                {
                                    user.IsAdmin = true;
                                    user.AdminType = AdminType.Admin;
                                }

                                var token = _tokenService.GenerateToken(user, null!);
                                string tokenStr = _tokenService.WriteToken(token);

                                bool isLibraryCardValid = true;
                                bool isExpiring = false;
                                if (userProfile?.ProfileType == ApplicationUserProfileType.CardHolder)
                                {
                                    isLibraryCardValid = await _libraryCardService.IsValidCardOfCurrentUser(user.Id);
                                    isExpiring = await _libraryCardService.IsExpiringInAWeekCurrentUser(user.Id);
                                }

                                _logger.LogInformation($"User {user.Id} logged in successfully");

                                return Success(
                                    new ApplicationUserResult()
                                    {
                                        Token = tokenStr,
                                        TokenExpiration = token.ValidTo,
                                        Id = user.Id,
                                        Name = user.UserName,
                                        DisplayName = userProfile?.DisplayName,
                                        Email = user.Email,
                                        IsAdmin = user.IsAdmin,
                                        AdminType = user.AdminType,
                                        ProfileType = userProfile?.ProfileType,
                                    },
                                    isExpiring && isLibraryCardValid ? "Читателската Ви карта изтича скоро!" : !isLibraryCardValid ? "Читателската Ви карта е изтекла!" : "");
                            }
                            catch (Exception exc)
                            {
                                _logger.LogError(exc, "User login error");
                                return InternalServerError();
                            }
                        }
                    }

                    return BadRequest(AuthenticationMessageCodes.InvalidUserOrPass);
                }
            }
            catch (Exception x)
            {
                _logger.LogError(x, "User login error");
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
                return BadRequest(AuthenticationMessageCodes.UserDoesNotExist);
            }

            var isTokenValid = await _userManager.VerifyUserTokenAsync(
                user,
                TokenOptions.DefaultEmailProvider,
                UserManager<ApplicationUser>.ConfirmEmailTokenPurpose,
                model.ConfirmationToken);
            if (!isTokenValid)
            {
                _logger.LogError($"Invalid confirmation token {model.ConfirmationToken} for user {user.UserName}, {user.Email}");
                return BadRequest(AuthenticationMessageCodes.InvalidToken);
            }

            var confirmationResult = await _userManager.ConfirmEmailAsync(user, model.ConfirmationToken);
            if (!confirmationResult.Succeeded)
            {
                _logger.LogError(confirmationResult.ToString());
                return BadRequest(AuthenticationMessageCodes.AccountNotConfirmed);
            }

            return Success();
        }

        [HttpPost("password/reset")]
        [AllowAnonymous]
        public async Task<IActionResult> ResetPassword([FromBody] string email)
        {
            try
            {
                ApplicationUser user = await _userManager.FindByNameAsync(email);
                if (user == null)
                {
                    _logger.LogWarning(_localizer.GetString("Error_UserDoesNotExists").ToString(), email);
                    return BadRequest(AuthenticationMessageCodes.UserDoesNotExist);
                }
                if (!user.EmailConfirmed)
                {
                    _logger.LogWarning($"Email {email} not confirmed");
                    return BadRequest(AuthenticationMessageCodes.EmailNotConfirmed);
                }

                try
                {
                    await SendResetPasswordMail(user);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, $"Error sending password reset mail to {user.Email}");
                    return BadRequest(AuthenticationMessageCodes.PasswordResetMailNotSent);
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Password reset error");
                return InternalServerError();
            }
        }

        [HttpPost("password/set")]
        [AllowAnonymous]
        public async Task<IActionResult> SetPassword(PasswordModel model)
        {
            if (model == null)
            {
                _logger.LogWarning(_localizer.GetString("InvalidData").ToString());
                return BadRequest(AuthenticationMessageCodes.Error);
            }
            if (!model.Password.Equals(model.PasswordConfirmation, StringComparison.Ordinal))
            {
                _logger.LogWarning($"Password mismatch {model.UserId}");
                return BadRequest(AuthenticationMessageCodes.PasswordMismatch);
            }

            try
            {
                var user = await _userManager.FindByIdAsync(model.UserId.ToString());
                if (user == null)
                {
                    _logger.LogWarning(_localizer.GetString("Error_UserDoesNotExists").ToString(), model.UserId);
                    return BadRequest(AuthenticationMessageCodes.UserDoesNotExist);
                }
                if (user.Deleted)
                {
                    _logger.LogWarning($"User {model.UserId} is deleted");
                    return BadRequest(AuthenticationMessageCodes.UserDoesNotExist);
                }

                var code = model.PasswordToken.Replace(" ", "+");
                var passwordSetResult = await _userManager.ResetPasswordAsync(user, model.PasswordToken, model.Password);
                if (!passwordSetResult.Succeeded)
                {
                    if (passwordSetResult.Errors.Any(err => err.Code == "InvalidToken"))
                    {
                        return BadRequest(AuthenticationMessageCodes.Error);
                    }

                    if (passwordSetResult.Errors.Any(err => err.Code == "PasswordMismatch"))
                    {
                        return BadRequest(AuthenticationMessageCodes.PasswordMismatch);
                    }

                    if (passwordSetResult.Errors.Any(err =>
                        err.Code == "PasswordTooShort"
                        || err.Code == "PasswordRequiresUniqueChar"
                        || err.Code == "PasswordRequiresNonAlphanumeric"
                        || err.Code == "PasswordRequiresDigit"
                        || err.Code == "PasswordRequiresLower"
                        || err.Code == "PasswordRequiresUpper"))
                    {
                        var errorMessage = string.Join("\n\r",
                            passwordSetResult.Errors.Where(err =>
                                err.Code == "PasswordTooShort"
                                || err.Code == "PasswordRequiresUniqueChar"
                                || err.Code == "PasswordRequiresNonAlphanumeric"
                                || err.Code == "PasswordRequiresDigit"
                                || err.Code == "PasswordRequiresLower"
                                || err.Code == "PasswordRequiresUpper")
                            .Select(err => err.Description));
                        return BadRequest(AuthenticationMessageCodes.Error);
                    }
                    _logger.LogError(passwordSetResult.ToString());
                    return BadRequest(AuthenticationMessageCodes.Error);
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError("Error setting password", exc);
                return InternalServerError();
            }

        }

        [HttpPost("profile/set")]
        public async Task<IActionResult> SetProfile(UserProfileModel model)
        {
            try
            {
                if (model == null)
                {
                    throw new ArgumentNullException(nameof(model));
                }

                if (model.ProfileType == ApplicationUserProfileType.CardHolder)
                {
                    var isLibraryCardValid = await _libraryCardService.IsValid(model.LibraryCardNumber!);
                    if (!isLibraryCardValid)
                    {
                        _logger.LogWarning($"Library card invalid: {model.LibraryCardNumber}");
                        return BadRequest(AuthenticationMessageCodes.LibraryCardInvalid);
                    }
                }

                var user = await _userManager.FindByIdAsync(model.UserId.ToString());
                if (user == null)
                {
                    _logger.LogWarning($"User {model.UserId} does not exists");
                    return BadRequest(AuthenticationMessageCodes.UserDoesNotExist);
                }

                var profile = await _userProfileService.GetProfileAsync(model.UserId);
                if (profile == null)
                {
                    _logger.LogError($"Error getting profile for user {model.UserId}. Profile does not exists");
                    return BadRequest(AuthenticationMessageCodes.Error);
                }
                model.Id = profile.Id;
                var profileResult = await _userProfileService.UpdateProfileAsync(model);
                if (!profileResult.Succeeded)
                {
                    _logger.LogError("Error setting user profile", profileResult.ToString());
                    return BadRequest(AuthenticationMessageCodes.Error);
                }

                //user.UserProfileType = model.ProfileType;
                //user.DisplayName = model.DisplayName;
                var userResult = await _userManager.UpdateAsync(user);
                if (!userResult.Succeeded)
                {
                    _logger.LogError("Error setting user profile type", userResult.ToString());
                    return BadRequest(AuthenticationMessageCodes.Error);
                }

                var token = _tokenService.GenerateToken(user, null!);
                string tokenStr = _tokenService.WriteToken(token);

                _logger.LogInformation($"User profile set successfully. UserId: {user.Id}");

                return Success(
                    new ApplicationUserResult()
                    {
                        Token = tokenStr,
                        TokenExpiration = token.ValidTo,
                        Id = user.Id,
                        Name = user.UserName,
                        //DisplayName = user.DisplayName,
                        Email = user.Email,
                        IsAdmin = user.IsAdmin,
                        AdminType = user.AdminType,
                        // ProfileType = user.UserProfileType,
                    });
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error setting user profile");
                return InternalServerError();
            }

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
                    _localizer.GetString("EmailConfirmation_Body", callbackUrl, _emailTokenSettings.ExpirationHours).ToString());
                if (!string.IsNullOrEmpty(emailResult))
                {
                    throw new Exception(emailResult);
                }
            }
        }

        [NonAction]
        private async Task SendResetPasswordMail(ApplicationUser user)
        {
            var passwordToken = await _userManager.GeneratePasswordResetTokenAsync(user);
            var encodedPasswordToken = System.Web.HttpUtility.UrlEncode(passwordToken);

            var referer = Request.GetTypedHeaders().Referer;
            var basePath = Request.PathBase.Value?.TrimEnd('/');
            var relativePath = "setPassword";
            var url = new UriBuilder()
            {
                Scheme = referer.Scheme,
                Host = referer.Host,
                Port = referer.Port,
                Path = $"{basePath}/{relativePath}",
                Query = $"uid={user.Id}&code={encodedPasswordToken}"
            };

            //var callbackUrl = $"{Request.GetTypedHeaders().Referer.ToString().TrimEnd('/')}/#/resetPassword?uid={model.Id}&code={encodedPasswordToken}";
            var callbackUrl = url.ToString();
            var emailResult = await _emailService.SendEmailAsync(user.Email,
                string.Empty,
                string.Empty,
                _localizer.GetString("PasswordReset_Subject").ToString(),
                _localizer.GetString("PasswordReset_Body", callbackUrl, _emailTokenSettings.ExpirationHours).ToString());

            if (!string.IsNullOrEmpty(emailResult))
            {
                throw new Exception(emailResult);
            }
        }

        [HttpPost("loginReader")]
        [AllowAnonymous]
        public async Task<IActionResult> LoginReader(LoginReaderModel model)
        {
            try
            {
                ApplicationUser user = await _userManager.FindByNameAsync(model.Username);
                if (user == null)
                {
                    _logger.LogInformation(_localizer.GetString("Error_UserDoesNotExists").ToString(), model.Username);
                    return BadRequest(_localizer.GetString("Error_InvalidUserOrPass").ToString());
                }
                else
                {
                    var userProfile = await _userProfileService.GetProfileAsync(user.Id);
                    if (userProfile?.ProfileType != ApplicationUserProfileType.ReaderInReadingRoom)
                    {
                        _logger.LogWarning($"Email {model.Username} not confirmed");
                        return BadRequest(_localizer.GetString("Error_InvalidUserOrPass").ToString());
                    }
                    if (!user.Deleted)
                    {
                        if (!user.EmailConfirmed)
                        {
                            _logger.LogWarning($"Email {model.Username} not confirmed");
                            return BadRequest(_localizer.GetString("Error_InvalidUserOrPass").ToString());
                        }

                        bool checkPassword = await _userManager.CheckPasswordAsync(user, model.Password);
                        if (checkPassword)
                        {
                            try
                            {
                                var userClaims = await _userManager.GetClaimsAsync(user);
                                if (userClaims.Any(claim => claim.Type == ArchivingClaimTypes.AdminType && claim.Value == AdminType.Admin))
                                {
                                    user.IsAdmin = true;
                                    user.AdminType = AdminType.Admin;
                                }

                                var token = _tokenService.GenerateToken(user, null!);
                                string tokenStr = _tokenService.WriteToken(token);

                                _logger.LogInformation($"User {user.Id} logged in successfully");

                                return Success(
                                    new ApplicationUserResult()
                                    {
                                        Token = tokenStr,
                                        TokenExpiration = token.ValidTo,
                                        Id = user.Id,
                                        Name = user.UserName,
                                        DisplayName = userProfile?.DisplayName,
                                        Email = user.Email,
                                        IsAdmin = user.IsAdmin,
                                        AdminType = user.AdminType,
                                        ProfileType = userProfile?.ProfileType,
                                    });
                            }
                            catch (Exception exc)
                            {
                                _logger.LogError(exc, "User login error");
                                return InternalServerError();
                            }
                        }
                    }

                    return BadRequest(_localizer.GetString("Error_InvalidUserOrPass").ToString());
                }
            }
            catch (Exception x)
            {
                _logger.LogError(x, "User login error");
                return InternalServerError();
            }
        }

        [HttpPut("profile/edit")]
        public async Task<IActionResult> EditProfile(UserProfileModel model)
        {
            try
            {
                if (model == null)
                {
                    throw new ArgumentNullException(nameof(model));
                }

                if (model.ProfileType == ApplicationUserProfileType.CardHolder)
                {
                    var isLibraryCardValid = await _libraryCardService.IsValid(model.LibraryCardNumber!);
                    if (!isLibraryCardValid)
                    {
                        _logger.LogWarning($"Library card invalid: {model.LibraryCardNumber}");
                        return BadRequest(AuthenticationMessageCodes.LibraryCardInvalid);
                    }
                }

                var user = await _userManager.FindByIdAsync(model.UserId.ToString());
                if (user == null)
                {
                    _logger.LogWarning($"User {model.UserId} does not exists");
                    return BadRequest(AuthenticationMessageCodes.UserDoesNotExist);
                }

                var profile = await _userProfileService.GetProfileAsync(model.UserId);
                if (profile == null)
                {
                    _logger.LogError($"Error getting profile for user {model.UserId}. Profile does not exists");
                    return BadRequest(AuthenticationMessageCodes.Error);
                }
                model.Id = profile.Id;
                var profileResult = await _userProfileService.UpdateProfileAsync(model);
                if (!profileResult.Succeeded)
                {
                    _logger.LogError("Error setting user profile", profileResult.ToString());
                    return BadRequest(AuthenticationMessageCodes.Error);
                }

                //user.UserProfileType = model.ProfileType;
                //user.DisplayName = model.DisplayName;
                var userResult = await _userManager.UpdateAsync(user);
                if (!userResult.Succeeded)
                {
                    _logger.LogError("Error setting user profile type", userResult.ToString());
                    return BadRequest(AuthenticationMessageCodes.Error);
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error setting user profile");
                return InternalServerError();
            }

        }
    }
}
