using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Identity;
using DAA.Models.Authentication;
using DAA.Models.Configuration;
using DAA.Models.Identity;
using DAA.Models.Users;
using DAA.Services.Interfaces;
using DAA.Services.Users;
using DAA.Shared;
using DAA.Shared.Authorization;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;

namespace DAA.Web.Intranet.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class UsersController : BaseApiController
    {
        private readonly IUserService _userService;
        private readonly IEmailService _emailService;
        private readonly ApplicationUserManager _userManager;
        private readonly ApplicationSettings _appSettings;
        private readonly EmailTokenSettings _emailTokenSettings;

        public UsersController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<BaseApiController> logger,
            IUserInfo userInfo,
            ApplicationUserManager userManager,
            IUserService userService,
            IEmailService emailService,
            IOptions<ApplicationSettings> appSettings,
            IOptions<EmailTokenSettings> emailTokenSettings)
            : base(localizer, logger, userInfo)
        {
            _userManager = userManager;
            _userService = userService;
            _emailService = emailService;
            _appSettings = appSettings.Value;
            _emailTokenSettings = emailTokenSettings.Value;
        }

        [HttpPost("listall")]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public IActionResult ListAll(DataSourceRequestModel model)
        {
            try
            {
                var users = _userService.GetAll(model);
                if (users?.Errors != null)
                {
                    _logger.LogError(String.Join(";", users.Errors));
                    return BadRequest(String.Join(";", users.Errors));
                }

                return Success(users);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting user list");
                return InternalServerError();
            }
        }

        [HttpPost("list/{userType}")]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public IActionResult List(DataSourceRequestModel model, string userType)
        {
            try
            {
                var users = _userService.GetByType(model, userType);
                if (users?.Errors != null)
                {
                    _logger.LogError(String.Join(";", users.Errors));
                    return BadRequest(String.Join(";", users.Errors));
                }

                return Success(users);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting user list");
                return InternalServerError();
            }
        }

        //[HttpPost("admins/listall")]
        //[RequireAdmin(AdminType.GlobalAdmin)]
        //public IActionResult ListAllAdmins(DataSourceRequestModel model)
        //{
        //    try
        //    {
        //        var users = _usersService.GetAllAdmins(model);
        //        if (users?.Errors != null)
        //        {
        //            Log.Error(String.Join(";", users.Errors));
        //            return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
        //        }
        //        return Ok(users);
        //    }
        //    catch (Exception exc)
        //    {
        //        Log.Error(exc, "Error getting user list for global admin");
        //        return StatusCode(StatusCodes.Status500InternalServerError, _localizer.GetString("Error_500").ToString());
        //    }
        //}

        //[HttpGet("searchall")]
        //[RequireAdmin(AdminType.GlobalAdmin)]
        //public IActionResult GetAllBySearchText(string searchText)
        //{
        //    try
        //    {
        //        var users = _usersService.GetBySearchText(searchText);
        //        return Ok(users);
        //    }
        //    catch (Exception exc)
        //    {
        //        Log.Error(exc, $"{nameof(GetAllBySearchText)} Error getting search result for search text {searchText}");
        //        return StatusCode(StatusCodes.Status500InternalServerError, _localizer.GetString("Error_500").ToString());
        //    }
        //}

        [HttpGet("userInfo/{id}")]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> GetAdminUserInfo(Guid id)
        {
            try
            {
                return Success(await _userService.GetById(id));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting user {id}");
                return InternalServerError();
            }
        }

        [HttpGet("reader/{id}")]
        [Roles(ApplicationRoleType.GroupI1)]
        public async Task<IActionResult> GetReader(Guid id)
        {
            try
            {
                return Success(await _userService.GetById(id));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting user {id}");
                return InternalServerError();
            }
        }

        //[HttpGet("getbyid/{id}")]
        //[RequireAdmin(AdminType.GlobalAdmin)]
        //public async Task<IActionResult> GetById(string id)
        //{
        //    try
        //    {
        //        return Ok(await _usersService.GetById(id, null));
        //    }
        //    catch (Exception exc)
        //    {
        //        Log.Error(exc, "Error getting user with id {0}", id);
        //        return StatusCode(StatusCodes.Status500InternalServerError, _localizer.GetString("Error_500").ToString());
        //    }
        //}

        //[HttpGet("role/{id}")]
        //[RequirePermissions(Permissions.ListUsers)]
        //public async Task<IActionResult> GetByRole(string id)
        //{
        //    try
        //    {
        //        int unitId = CurrentUserUnitId.Value;
        //        if (CurrentUserIsAdmin.Value)
        //        {
        //            return Ok(await _usersService.GetByRoleIdAsync(id));
        //        }
        //        return Ok(await _usersService.GetByRoleIdAsync(id, unitId));
        //    }
        //    catch (Exception exc)
        //    {
        //        Log.Error(exc, $"Error getting users by role with id {id}");
        //        return StatusCode(StatusCodes.Status500InternalServerError, _localizer.GetString("Error_500").ToString());
        //    }
        //}

        [HttpPost]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> Post(UserCreateModel model)
        {
            try
            {
                var userExists = await _userService.UserExistsAsync(model.UserName);
                if (userExists)
                {
                    return BadRequest(String.Format(_localizer.GetString("Error_UserExists", model.UserName).ToString()));
                }

                var result = await _userService.CreateAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error creating user {0}", model);
                return InternalServerError();
            }
        }

        //[HttpPost("admins/{id}")]
        //[RequirePermissions(Permissions.FullControl)]
        //public async Task<IActionResult> CreateAdmin(string id)
        //{
        //    try
        //    {
        //        int clientId = CurrentUserClientId.Value;
        //        if (!CurrentUserIsAdmin.Value && !await _usersService.UserExistsAsync(id, clientId))
        //        {
        //            Log.Debug($"{nameof(CreateAdmin)} user with id {id} does not exists for client with id {clientId}");
        //            return BadRequest(_localizer.GetString("Error_CannotCompleteAction").ToString());
        //        }

        //        var adminClaimResult = await _usersService.AddClaimAsync(id, DocFlowClaimTypes.AdminType, AdminType.ClientAdmin);
        //        if (!adminClaimResult.Succeeded)
        //        {
        //            Log.Error($"{nameof(CreateAdmin)} {adminClaimResult}");
        //            return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
        //        }
        //        var permissionClaimResult = await _usersService.AddClaimAsync(id, DocFlowClaimTypes.Permission, Permissions.FullControl);
        //        if (!permissionClaimResult.Succeeded)
        //        {
        //            Log.Error($"{nameof(CreateAdmin)} {permissionClaimResult}");
        //            return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
        //        }
        //        return Ok();
        //    }
        //    catch (Exception exc)
        //    {
        //        Log.Error(exc, $"Error adding user with id {id} as administrator for client with id {CurrentUserClientId.Value}");
        //        return StatusCode(StatusCodes.Status500InternalServerError, _localizer.GetString("Error_500").ToString());
        //    }
        //}

        [HttpPut]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> Put(UserEditModel model)
        {
            try
            {
                var result = await _userService.UpdateAsync(model);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error updating user {model.UserName}");
                return InternalServerError();
            }
        }

        [HttpPost("resetPassword")]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> ResetPassword(UserDisplayModel model)
        {
            try
            {
                if (model.AuthenticationType == AuthenticationType.Password)
                {
                    await SendResetPasswordMail(
                        model,
                        _localizer.GetString("PasswordReset_Subject").ToString(),
                        _localizer.GetString("PasswordReset_Body").ToString());

                    return Success();
                }

                return BadRequest(_localizer.GetString("Error_CannotResetPasswordForUserType").ToString());
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error reseting password for user {model.UserName}");
                return StatusCode(StatusCodes.Status500InternalServerError, _localizer.GetString("Error_500").ToString());
            }
        }

        [HttpDelete("{id}")]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> Delete(Guid id)
        {
            try
            {
                var result = await _userService.DeleteAsync(id);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }
                return Ok();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error deleting user with id {0}", id);
                return InternalServerError();
            }
        }

        //[HttpDelete("admins/{id}")]
        //[RequirePermissions(Permissions.FullControl)]
        //public async Task<IActionResult> DeleteAdmin(string id)
        //{
        //    try
        //    {
        //        int clientId = CurrentUserClientId.Value;
        //        if (!CurrentUserIsAdmin.Value && !await _usersService.UserExistsAsync(id, clientId))
        //        {
        //            Log.Debug($"{nameof(DeleteAdmin)} user with id {id} does not exists for client with id {clientId}");
        //            return BadRequest(_localizer.GetString("Error_CannotCompleteAction").ToString());
        //        }

        //        var permissionClaimResult = await _usersService.RemoveClaimAsync(id, DocFlowClaimTypes.Permission, Permissions.FullControl);
        //        if (!permissionClaimResult.Succeeded)
        //        {
        //            Log.Error($"{nameof(DeleteAdmin)} {permissionClaimResult}");
        //            return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
        //        }
        //        var adminClaimResult = await _usersService.RemoveClaimAsync(id, DocFlowClaimTypes.AdminType, AdminType.ClientAdmin);
        //        if (!adminClaimResult.Succeeded)
        //        {
        //            Log.Error($"{nameof(DeleteAdmin)} {adminClaimResult}");
        //            return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
        //        }

        //        return Ok();
        //    }
        //    catch (Exception exc)
        //    {
        //        Log.Error(exc, "Error deleting user from admins with id {0}", id);
        //        return StatusCode(StatusCodes.Status500InternalServerError, _localizer.GetString("Error_500").ToString());
        //    }
        //}

        [NonAction]
        private async Task SendResetPasswordMail(UserDisplayModel model, string subject, string body)
        {
            var passwordToken = await _userService.ResetPasswordToken(model.Id);
            var encodedPasswordToken = System.Web.HttpUtility.UrlEncode(passwordToken);

            var baseUri = new Uri(_appSettings.UriExternal!);
            //var referer = Request.GetTypedHeaders().Referer;
            //var basePath = Request.PathBase.Value.TrimEnd('/');
            var relativePath = "setPassword";
            var url = new UriBuilder()
            {
                //Scheme = referer.Scheme,
                //Host = referer.Host,
                //Port = referer.Port,
                //Path = $"{basePath}/{relativePath}",
                Scheme = baseUri.Scheme,
                Host = baseUri.Host,
                Port = baseUri.Port,
                Path = $"{baseUri.AbsolutePath.TrimEnd('/')}/{relativePath}",
                Query = $"uid={model.Id}&code={encodedPasswordToken}"
            };

            //var callbackUrl = $"{Request.GetTypedHeaders().Referer.ToString().TrimEnd('/')}/#/resetPassword?uid={model.Id}&code={encodedPasswordToken}";
            var callbackUrl = url.ToString();
            await _emailService.SendEmailAsync(
                model.Email,
                string.Empty,
                string.Empty,
                subject,
                String.Format(body, callbackUrl, _emailTokenSettings.ExpirationHours));
        }

        [HttpPost("list/profileType/{profileType}")]
        //[Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        //[Authorize(Roles = "Role_I1")]
        [Roles(ApplicationRoleType.GroupI1)]
        public IActionResult ListProfileType(DataSourceRequestModel model, string profileType)
        {
            try
            {
                var users = _userService.GetByProfileType(model, profileType);
                if (users?.Errors != null)
                {
                    _logger.LogError(String.Join(";", users.Errors));
                    return BadRequest(String.Join(";", users.Errors));
                }

                return Success(users);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error getting user list");
                return InternalServerError();
            }
        }

        [HttpPut("sendAgainConfirmedMail")]
        [Admin(AdminType.Admin, AdminType.GlobalAdmin)]
        public async Task<IActionResult> SendAgainConfirmedMail([FromBody] string id)
        {
            try
            {
                var result = await SendConfirmationEmail(id);
                if (result.Errors.Any())
                {
                    _logger.LogError(String.Join(";", result.Errors));
                    return BadRequest(String.Join(";", result.Errors));
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error sending again confirmed mail");
                return InternalServerError();
            }
        }

        [HttpPost("changePassword")]
        [Roles(ApplicationRoleType.GroupI1)]
        public async Task<IActionResult> ChangePassword(ChangePasswordModel model)
        {
            try
            {
                if (model == null)
                {
                    throw new ArgumentNullException(nameof(model));
                }

                if (!model.Password.Equals(model.PasswordConfirmation, StringComparison.Ordinal))
                {
                    _logger.LogWarning($"Password mismatch {model.UserName}");
                    return BadRequest(_localizer.GetString("Error_PasswordMismatch").ToString());
                }

                ApplicationUser user = await _userManager.FindByNameAsync(model.UserName);
                if (user == null)
                {
                    _logger.LogWarning($"User with username {model.UserName} does not exists");
                    return BadRequest(_localizer.GetString("Error_UserExists").ToString());
                }

                bool samePassword = await _userManager.CheckPasswordAsync(user, model.Password);
                if (samePassword)
                {
                    _logger.LogWarning($"Password for {model.UserName} is the same as old password");
                    return Success(_localizer.GetString("Error_PasswordIsSame").ToString());
                }

                try
                {
                    var res = await _userService.ChangePassword(user, model.Password);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, $"Error changing {model.UserName}`s password");
                    return BadRequest();
                }

                return Success();

            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error changing {model.UserName}`s password");
                return InternalServerError();
            }
        }

        [NonAction]
        private async Task<OperationResult> SendConfirmationEmail(string id)
        {
            try
            {
                var user = await _userManager.FindByIdAsync(id);

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

                    var callbackUrl = url.ToString();
                    var emailResult = await _emailService.SendEmailAsync(user.Email,
                        string.Empty,
                        string.Empty,
                        _localizer.GetString("EmailConfirmation_Subject").ToString(),
                        string.Format(_localizer.GetString("EmailConfirmation_Body").ToString(), callbackUrl));
                    if (!string.IsNullOrEmpty(emailResult))
                    {
                        throw new Exception(emailResult);
                    }
                }
                else 
                {
                   return OperationResult.Failed(_localizer.GetString("ConfirmedEmail"));
                }

                return OperationResult.Succeed("");
            }
            catch (Exception ex)
            {
                return OperationResult.Failed(ex.Message.ToString());
            }
        }

    }
}
