using DAA.Models.Configuration;
using DAA.Models.Identity;
using DAA.Models.Users;
using DAA.Services.Authentication;
using DAA.Identity;
using DAA.Services.Interfaces;
using DAA.Services.Users;
using DAA.Shared.Certificates;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using System.Security.Cryptography.X509Certificates;
using DAA.Shared;

namespace DAA.Web.Public.Controllers
{
    [Route("[controller]")]
    [ApiExplorerSettings(IgnoreApi = true)]
    public class CertificateController : Controller
    {
        private const string _returnPath = "login/result";
        private readonly ITokenService _tokenService;
        private readonly IUserProfileService _userProfileService;
        private readonly ApplicationUserManager _userManager;
        private readonly IEmailService _emailService;
        protected readonly IStringLocalizer<SharedResources> _localizer;
        protected readonly ILogger<CertificateController> _logger;

        public CertificateController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<CertificateController> logger,
            ApplicationUserManager userManager,
            ITokenService tokenService,
            IUserProfileService profileService,
            IEmailService emailService
            )
        {
            _localizer = localizer;
            _logger = logger;
            _tokenService = tokenService;
            _userManager = userManager;
            _userProfileService = profileService;
            _emailService = emailService;
        }

        [AllowAnonymous]
        [Route("login")]
        public async Task<IActionResult> Login(string email)
        {
            //string referer = Request.Headers["Referer"].ToString().TrimEnd('/');
            //string returnUrl = referer + _returnPath;

            var referer = Request.GetTypedHeaders().Referer;
            var basePath = Request.PathBase.Value?.TrimEnd('/');
            var relativePath = _returnPath;
            var returnUrl = new UriBuilder()
            {
                Scheme = referer.Scheme,
                Host = referer.Host,
                Port = referer.Port,
                Path = $"{basePath}/{relativePath}",
                //Query = $"uid={user.Id}&code={encodedConfirmationToken}"
            };

            if (HttpContext.Connection.ClientCertificate == null)
            {
                //returnUrl += $"?error=true";
                //return Redirect(returnUrl);
                _logger.LogError("Certificate is null");
                returnUrl.Query = $"error=true&message={AuthenticationMessageCodes.NullCert}";
                return Redirect(returnUrl.ToString());
            }

            try
            {
                //Parse client certificate
                X509Certificate2 certificate = HttpContext.Connection.ClientCertificate;
                ParseResult parseResult = CertificateParser.DecodeCert(certificate);

                if (parseResult.Success)
                {
                    ApplicationUser? user = _userManager.Users.SingleOrDefault(u => u.CertificateUniqueIdentifier == parseResult.HolderEGN.Trim() && !u.Deleted);

                    if (user == null)
                    {
                        //Register new user
                        if (string.IsNullOrWhiteSpace(parseResult.HolderEmail))
                        {
                            if (string.IsNullOrWhiteSpace(email))
                            {
                                //Redirect to register page with parameter to gather additional info
                                //returnUrl += "?requireEmail=true";
                                //return Redirect(returnUrl);
                                _logger.LogInformation($"Certificate is missing holder email {certificate.SerialNumber} {certificate.Subject}");
                                returnUrl.Query = "requireEmail=true";
                                return Redirect(returnUrl.ToString());
                            }
                            else
                            {
                                parseResult.HolderEmail = email;
                            }
                        }

                        //return await Register(certificate, parseResult, returnUrl);
                        return await Register(certificate, parseResult, returnUrl);
                    }
                    else
                    {
                        /*
                         * Ако потребителя е сменил своето име в подписа, го променяме и в базата
                         * т.е. ако жена се омъжи и смени фамилията си и т.н.
                         * Ако подписа е променен също запазваме данните
                         */
                        if (user.CertificateName == null
                            || user.CertificateName.ToLower().Trim() != parseResult.HolderName.ToLower().Trim()
                            || user.CertificateThumbprint != certificate.Thumbprint)
                        {
                            //Check if certificate is the same and update user info if needed
                            user.Certificate = certificate.RawData;
                            user.CertificateThumbprint = certificate.Thumbprint;
                            user.CertificateName = parseResult.HolderName;
                            await _userManager.UpdateAsync(user);
                        }
                    }

                    //sign in existing user
                    //return await SignInExistingUser(user, returnUrl);
                    return await SignInExistingUser(user, returnUrl);
                }

                _logger.LogError($"Error parsing login certificate {certificate.SerialNumber} {certificate.Subject} {String.Join(", ", parseResult.Errors)}");
                //returnUrl += $"?error=true";
                //return Redirect(returnUrl);
                returnUrl.Query = "error=true";
                return Redirect(returnUrl.ToString());
            }
            catch (Exception x)
            {
                _logger.LogError(x, "Error parsing login certificate");
                //returnUrl += $"?error=true";
                //return Redirect(returnUrl);
                returnUrl.Query = "error=true";
                return Redirect(returnUrl.ToString());
            }
        }

        private async Task<IActionResult> Register(X509Certificate2 certificate, ParseResult parseResult, UriBuilder returnUrl)
        {
            try
            {
                //Create new User with Person
                //check email
                var normalizedMail = _userManager.NormalizeEmail(parseResult.HolderEmail.Trim());
                bool isDuplicateEmail = _userManager.Users.Any(u => u.NormalizedEmail == normalizedMail && !u.Deleted);

                if (isDuplicateEmail)
                {
                    //returnUrl += $"?error=true&message=duplicateEmail";
                    //return Redirect(returnUrl);
                    _logger.LogWarning($"Certificate duplicate email {certificate.SerialNumber} {certificate.Subject} {parseResult.HolderEmail}");
                    returnUrl.Query = $"error=true&message={AuthenticationMessageCodes.DuplicateEmail}";
                    return Redirect(returnUrl.ToString());
                }

                //Create new user
                string username = parseResult.HolderName.Trim().Replace(' ', '.');
                var normalizedName = _userManager.NormalizeName(username);
                bool usersWithSameName = _userManager.Users
                                                     .Any(x => x.NormalizedUserName == normalizedName && !x.Deleted);

                if (usersWithSameName)
                {
                    //Add random number to username when there are more than one user with same name
                    Random rand = new Random(999999);
                    username += rand.Next().ToString().Trim();
                }

                ApplicationUser user = new ApplicationUser()
                {
                    UserType = ApplicationUserType.External,
                    AuthenticationType = AuthenticationType.Signature,
                    Certificate = certificate.RawData,
                    CertificateThumbprint = certificate.Thumbprint,
                    Email = parseResult.HolderEmail,
                    EmailConfirmed = true,
                    UserName = username,
                    CertificateName = parseResult.HolderName.Trim(),
                    CertificateUniqueIdentifier = parseResult.HolderEGN.Trim()
                };

                var userResult = await _userManager.CreateAsync(user);
                if (!userResult.Succeeded)
                {
                    //create new user fail
                    //returnUrl += $"?error=true";
                    //return Redirect(returnUrl);
                    _logger.LogError("Error creating user", userResult.ToString());
                    returnUrl.Query = "error=true";
                    return Redirect(returnUrl.ToString());
                }

                try
                {
                    //create initial user profile
                    string[] holderNames = parseResult.HolderName.Split(' ');

                    //PersonModel person = new PersonModel()
                    //{
                    //    FirstName = holderNames[0],
                    //    MiddleName = holderNames.Length == 3 ? holderNames[1] : null,
                    //    LastName = holderNames.Length == 3 ? holderNames[2] : holderNames[1],
                    //    Email = parseResult.HolderEmail,
                    //    PersonIdentification = new PersonIdentificationModel()
                    //    {
                    //        IdentificationTypeId = (int)IdentificationType.EGN,
                    //        Number = parseResult.HolderEGN
                    //    }
                    //};

                    //var dbPerson = await _personService.RegisterAsync(person, true, false, user.Id);

                    //sign in the user when person is created
                    //return await SignInExistingUser(user, returnUrl);

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

                        returnUrl.Query = "error=true";
                        return Redirect(returnUrl.ToString());
                    }

                    return await SignInExistingUser(user, returnUrl);
                }
                catch (Exception x)
                {
                    _logger.LogError(x, "Error sining existing user with certificate");
                    //var cleanupResult = await _userManager.DeleteAsync(user);
                    //if (!cleanupResult.Succeeded)
                    //{
                    //    _logger.LogError("Error cleaning up created user", cleanupResult.ToString());
                    //}

                    //returnUrl += $"?error=true";
                    //return Redirect(returnUrl);
                    returnUrl.Query = "error=true";
                    return Redirect(returnUrl.ToString());
                }
            }
            catch (Exception exc)
            {
                //cannot parse certificate
                _logger.LogError(exc, "Error parsing login certificate");
                //returnUrl += $"?error=true";
                //return Redirect(returnUrl);
                returnUrl.Query = "error=true";
                return Redirect(returnUrl.ToString());
            }
        }

        private async Task<IActionResult> SignInExistingUser(ApplicationUser user, UriBuilder returnUrl)
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
                            email = user.Email,
                            isAdmin = user.IsAdmin,
                            adminType = user.AdminType,
                        });

                //returnUrl += $"?auth={infoAsJson}";
                //return Redirect(returnUrl);
                returnUrl.Query = $"auth={infoAsJson}";
                return Redirect(returnUrl.ToString());
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error sining existing user with certificate {user.UserName} {user.CertificateName} {user.CertificateUniqueIdentifier}");
                //returnUrl += $"?error=true";
                //return Redirect(returnUrl);
                returnUrl.Query = "error=true";
                return Redirect(returnUrl.ToString());
            };
        }
    }
}
