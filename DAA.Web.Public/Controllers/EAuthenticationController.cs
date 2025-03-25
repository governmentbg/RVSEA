using DAA.Extensions.Controller;
using DAA.Identity;
using DAA.Models.EAuthentication;
using DAA.Models.Identity;
using DAA.Models.Users;
using DAA.Services.ApplicationStore;
using DAA.Services.Authentication;
using DAA.Services.Interfaces;
using DAA.Services.Users;
using DAA.Shared;
using DAA.Shared.EAuthentication;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;

namespace DAA.Web.Public.Controllers
{
    [Route("[controller]")]
    public class EAuthenticationController : BaseApiController
    {
        private const string _loginReturnPath = "/login/result";

        private const string _clientCertNotSelected = "ClientCertNotSelected";

        private readonly Models.Configuration.EAuthSettings _eAuthSettings;
        private readonly ApplicationUserManager _userManager;
        private readonly IEAuthenticationService _eAuthService;
        private readonly ITokenService _tokenService;
        private readonly IApplicationStoreService _applicationStoreService;
        private readonly IUserProfileService _userProfileService;
        private readonly IEmailService _emailService;
        protected new readonly ILogger<CertificateController> _logger;

        public EAuthenticationController(
            IOptions<Models.Configuration.EAuthSettings> eAuthConfig, 
            ApplicationUserManager userManager,
            IEAuthenticationService eAuthService,
            ITokenService tokenService,
            IApplicationStoreService applicationStoreService,
            IUserProfileService userProfileService,
            IEmailService emailService,
            ILogger<CertificateController> logger,
            IStringLocalizer<SharedResources> localizer
        ) : base(localizer)
        {
            _eAuthSettings = eAuthConfig.Value;
            _userManager = userManager;
            _eAuthService = eAuthService;
            _tokenService = tokenService;
            _applicationStoreService = applicationStoreService;
            _userProfileService = userProfileService;
            _emailService = emailService;
            _logger = logger;
        }

        [AllowAnonymous]
        [HttpPost("LoginCallback")]
        public async Task<IActionResult> LoginCallback([FromForm] Models.EAuthentication.EAuthCallbackModel model)
        {
            (IActionResult actionResult, string requestId) = await Login(model);
            _applicationStoreService.Clear(requestId);

            return actionResult;
        }        
        
        [AllowAnonymous]
        [HttpGet("login")]
        public async Task<IActionResult> Login(string certNames, string certPersonIdentifier, string email)
        {
            var referer = Request.GetTypedHeaders().Referer;
            var basePath = Request.PathBase.Value?.TrimEnd('/');
            var urlPart1 = new UriBuilder()
            {
                Scheme = referer!.Scheme,
                Host = referer.Host,
                Port = referer.Port,
                Path = $"{basePath}",
            };

            //var returnUrl = Request.Headers["Referer"].ToString().TrimEnd('/') + _loginReturnPath; // на тестова среда се долепва /login към това, което е проблем
            var returnUrl = urlPart1.ToString().TrimEnd('/') + _loginReturnPath;
            _logger.LogInformation($"Return URL Host: {referer}");

            try
            {
                ApplicationUser? user = _userManager.Users.SingleOrDefault(u => u.CertificateUniqueIdentifier == certPersonIdentifier.Trim() && !u.Deleted);

                if (user == null)
                {
                    return await Register(certNames, certPersonIdentifier, returnUrl, email!);
                }

                return await SignInExistingUser(user, returnUrl);
            }
            catch (Exception x)
            {
                _logger.LogError(x, "User login error");

                returnUrl += "?error=true";
                return Redirect(returnUrl);
            }
        }

        [AllowAnonymous]
        [HttpGet("eauthRequest/{email?}")]
        public ActionResult EAuthRequest(string? email)
        {
            try
            {
                EAuthRequestViewModel? model = null;

                // Създава се SAML заявка и се записва в журнал.
                string requestUrl = Url.Action(nameof(EAuthRequest), null, null, Request.Scheme)!;
                string callbackUrl = Url.Action(nameof(LoginCallback), null, null, Request.Scheme)!;

                model = _eAuthService.CreateRequestAsync(requestUrl, callbackUrl,
                    _eAuthSettings.RequestedServiceOid!, _eAuthSettings.RequestedProviderOid!, null, false, _eAuthSettings?.CertificateThumbprint!);

                var referer = Request.GetTypedHeaders().Referer;
                var basePath = Request.PathBase.Value?.TrimEnd('/');
                var urlPart1 = new UriBuilder()
                {
                    Scheme = referer!.Scheme,
                    Host = referer.Host,
                    Port = referer.Port,
                    Path = $"{basePath}",
                };

                var returnUrl = urlPart1.ToString().TrimEnd('/');

                _applicationStoreService.SetApplicationBaseUrl(model.RequestId, returnUrl);
                _applicationStoreService.SetEmail(model.RequestId, email);

                return Ok(model);
            }
            catch (Exception x)
            {
                _logger.LogError(x, "Creating EAuth request error");
                return InternalServerError();
            }
        }

        private async Task<(IActionResult actionResult, string requestId)> Login(Models.EAuthentication.EAuthCallbackModel model)
        {
            string requestId = string.Empty;
            string returnUrl = string.Empty;

            try
            {
                (EAuthResponseModel eAuthResponseModel, ResponseType response) = _eAuthService.Parse(model);
                requestId = eAuthResponseModel!.RequestId;
                returnUrl = _applicationStoreService.GetApplicationBaseUrl(requestId) + _loginReturnPath;

                bool hasEAuthErrors = eAuthResponseModel != null && eAuthResponseModel.Errors != null && eAuthResponseModel.Errors.Count > 0;
                if (hasEAuthErrors)
                {
                    _logger.LogInformation($"ParseSamlResponse {new string('-', 20)}");
                    _logger.LogInformation(JsonConvert.SerializeObject(eAuthResponseModel));
                }

                (string personIdentifier, string holderName, string certificateEmail) = ExtractPersonData(eAuthResponseModel!);
                var formEmail = _applicationStoreService.GetEmail(requestId);

                if (hasEAuthErrors)
                {
                    _logger.LogError(JsonConvert.SerializeObject(new { personIdentifier, holderName, certificateEmail }));
                    if (eAuthResponseModel!.Errors![0] == _clientCertNotSelected)
                    {
                        returnUrl += $"?error=true&message={AuthenticationMessageCodes.InvalidCertificateSelected}";
                    }
                    else
                    {
                        returnUrl += $"?error=true&message={AuthenticationMessageCodes.EAuthError}";
                    }

                    return (Redirect(returnUrl), requestId);
                }

                ApplicationUser? user = _userManager.Users.SingleOrDefault(u => u.CertificateUniqueIdentifier == eAuthResponseModel!.PersonIdentifier.Trim() && !u.Deleted);

                if (user == null)
                {
                    //Register new user
                    var email = certificateEmail;
                    if (string.IsNullOrWhiteSpace(certificateEmail))
                    {
                        if (string.IsNullOrWhiteSpace(formEmail))
                        {
                            _logger.LogInformation($"Certificate is missing holder email - EGN: {eAuthResponseModel!.PersonIdentifier.Trim()}");

                            returnUrl += $"?requireEmail=true&isEAuth=true&certPersonIdentifier={personIdentifier}&certNames={eAuthResponseModel.PersonNamesLatin}";
                            return (Redirect(returnUrl), requestId);
                        }
                        else
                        {
                            email = formEmail;
                        }                      
                    }

                    return (
                        await Register(eAuthResponseModel!.PersonNamesLatin, eAuthResponseModel!.PersonIdentifier, returnUrl,  email!), 
                        requestId);
                }
                else
                {
                    /*
                    * Ако потребителя е сменил своето име в подписа, го променяме и в базата
                    * т.е. ако жена се омъжи и смени фамилията си и т.н.
                    * Ако подписа е променен също запазваме данните
                    */
                    if (user.CertificateName == null
                        || user.CertificateName.ToLower().Trim() != eAuthResponseModel!.PersonNamesLatin.ToLower().Trim()
                        || user.CertificateUniqueIdentifier != eAuthResponseModel.PersonIdentifier)
                    {
                        // тези ги няма в response-а на МЕУ:
                        //user.Certificate = certificate.RawData;
                        //user.CertificateThumbprint = certificate.Thumbprint;

                        //Check if certificate is the same and update user info if needed
                        user.CertificateName = eAuthResponseModel!.PersonNamesLatin.ToLower().Trim();
                        await _userManager.UpdateAsync(user);
                    }
                }

                return (await SignInExistingUser(user, returnUrl), requestId);
            }
            catch (Exception x)
            {
                _logger.LogError(x, "User login error");

                returnUrl += "?error=true";
                return (Redirect(returnUrl), requestId);
            }
        }

        private async Task<IActionResult> Register(string certificateNames, string certificatePersonIdentifier, string returnUrl, string email)
        {
            certificateNames = certificateNames.Trim();

            try
            {
                //Create new User with Person
                //check email
                var normalizedMail = _userManager.NormalizeEmail(email.Trim());
                bool isDuplicateEmail = _userManager.Users.Any(u => u.NormalizedEmail == normalizedMail && !u.Deleted);

                if (isDuplicateEmail)
                { 
                    _logger.LogWarning($"Certificate duplicate email {email} {certificatePersonIdentifier}");

                    returnUrl += $"?error=true&message={AuthenticationMessageCodes.DuplicateEmail}";
                    return Redirect(returnUrl);
                }

                //Create new user
                string username = certificateNames.Replace(' ', '.');
                var normalizedName = _userManager.NormalizeName(username);
                bool usersWithSameName = _userManager.Users.Any(x => x.NormalizedUserName == normalizedName && !x.Deleted);

                if (usersWithSameName)
                {
                    //Add random number to username when there are more than one user with same name
                    Random rand = new(999999);
                    username += rand.Next().ToString().Trim();
                }

                ApplicationUser user = new ApplicationUser()
                {
                    //DisplayName = certificateNames,
                    UserType = ApplicationUserType.External,
                    AuthenticationType = AuthenticationType.EAuth,
                    //Certificate = certificate.RawData,
                    //CertificateThumbprint = certificate.Thumbprint,
                    Email = email,
                    EmailConfirmed = true,
                    UserName = username,
                    CertificateName = certificateNames,
                    CertificateUniqueIdentifier = certificatePersonIdentifier.Trim()
                };

                var userResult = await _userManager.CreateAsync(user);
                if (!userResult.Succeeded)
                {
                    _logger.LogError("Error creating user", userResult.ToString());

                    returnUrl += $"?error=true";
                    return Redirect(returnUrl);
                }

                try
                {
                    //create initial user profile
                    string[] holderNames = certificateNames.Split(' ');

                    var profile = new UserProfileModel()
                    {
                        UserId = user.Id,
                        FirstName = holderNames[0],
                        Surname = holderNames.Length == 3 ? holderNames[1] : null,
                        LastName = holderNames.Length == 3 ? holderNames[2] : holderNames[1],
                        //Address = model.Address,
                        //Department = model.Department,
                        //EntityType = model.ProfileEntityType,
                        //JobTitle = model.JobTitle,
                        //LibraryCardNumber = model.LibraryCardNumber,
                        //Organization = model.Organization,
                        //ProfileType = model.ProfileType,
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

                        returnUrl += $"?error=true";

                        return Redirect(returnUrl);
                    }

                    return await SignInExistingUser(user, returnUrl);
                }
                catch (Exception x)
                {
                    _logger.LogError(x, "Error sining existing user with certificate");

                    returnUrl += $"?error=true";

                    return Redirect(returnUrl);
                }
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error parsing login certificate");

                returnUrl += $"?error=true";
                return Redirect(returnUrl);
            }
        }

        private async Task<IActionResult> SignInExistingUser(ApplicationUser user, string returnUrl)
        {
            try
            {
                var roles = await _userManager.GetRolesAsync(user);
                //var token = JwtManager.GenerateToken(user, units, null, _tokenConfig);
                //string tokenStr = JwtManager.WriteToken(token);
                var token = _tokenService.GenerateToken(user, roles);
                string tokenStr = _tokenService.WriteToken(token);


                //await InvalidateToken(Request.Headers[AuthHeaderName]);
                //var userClaims = await _claimService.ValidClaimsForUserAsync(user.Id);

                string infoAsJson =
                    JsonConvert.SerializeObject(
                        new
                        {
                            token = tokenStr,
                            tokenExpiration = token.ValidTo,
                            id = user.Id,
                            name = user.UserName,
                            //displayName = user.DisplayName,
                            email = user.Email,
                            isAdmin = user.IsAdmin,
                            adminType = user.AdminType,
                            //profileType = user.UserProfileType,
                        });

                returnUrl += $"?auth={infoAsJson}";
                return Redirect(returnUrl);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error sining existing user with certificate {user.UserName} {user.CertificateName} {user.CertificateUniqueIdentifier}");

                returnUrl += "?error=true";
                return Redirect(returnUrl);
            };
        }

        private (string personIdentifier, string holderName, string email) ExtractPersonData(EAuthResponseModel eAuthResponseModel)
        {
            if (eAuthResponseModel == null) throw new ArgumentNullException(nameof(EAuthResponseModel));


            string holderName = eAuthResponseModel!.PersonNamesLatin;
            string email = eAuthResponseModel!.Email;
            string? personIdentifier = null;

            if (!string.IsNullOrWhiteSpace(eAuthResponseModel?.PersonIdentifier))
            {
                string[] split = eAuthResponseModel.PersonIdentifier.Split(" ", StringSplitOptions.RemoveEmptyEntries);
                personIdentifier = split.Length == 0
                    ? ""
                    : (split.Length == 1 ? split[0].Trim() : split.LastOrDefault()?.Trim());
            }

            var result = (personIdentifier!, holderName, email);
            return result;
        }
    }
}
