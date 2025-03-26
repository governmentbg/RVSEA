using DAA.Models.Identity;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using System.Security.Claims;
using ArchivingClaimTypes = DAA.Shared.Security.ClaimTypes;
using SystemClaimTypes = System.Security.Claims.ClaimTypes;


namespace DAA.Extensions.Authentication
{
    public class ClaimsTransformationService : IClaimsTransformation
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly RoleManager<ApplicationRole> _roleManager;
        ILogger<ClaimsTransformationService> _logger;

        public ClaimsTransformationService(
            UserManager<ApplicationUser> userManager,
            RoleManager<ApplicationRole> roleManager,
            ILogger<ClaimsTransformationService> logger)
        {
            _userManager = userManager;
            _roleManager = roleManager;
            _logger = logger;
        }
        public async Task<ClaimsPrincipal> TransformAsync(ClaimsPrincipal principal)
        {
            _logger.LogInformation($"Claims transform: Identity name {principal.Identity?.Name}");

            if (principal.Identity?.IsAuthenticated == false)
            {
                _logger.LogWarning($"Identity not authenticated");
                return new ClaimsPrincipal();
            }
            
            var identity = principal.Identity as ClaimsIdentity;
            var user = await _userManager.FindByNameAsync(principal.Identity?.Name);

            if (user != null && identity != null)
            {
                _logger.LogInformation($"Claims transform: User id {user.Id}");
                _logger.LogInformation($"Claims transform: User name {user.UserName}");

                var userClaims = await _userManager.GetClaimsAsync(user);
                if (userClaims.Any(claim => claim.Type == ArchivingClaimTypes.AdminType))
                {
                    user.IsAdmin = true;
                    user.AdminType = userClaims.FirstOrDefault(claim => claim.Type == ArchivingClaimTypes.AdminType)?.Value!;
                }

                if (!identity.HasClaim(claim => claim.Type == SystemClaimTypes.NameIdentifier))
                {
                    identity.AddClaim(new Claim(SystemClaimTypes.NameIdentifier, user.Id.ToString("D")));
                }
                if (!identity.HasClaim(claim => claim.Type == SystemClaimTypes.Email))
                {
                    identity.AddClaim(new Claim(SystemClaimTypes.Email, user.Email));
                }
                /*if (!identity.HasClaim(claim => claim.Type == SystemClaimTypes.GivenName))
                {
                    identity.AddClaim(new Claim(SystemClaimTypes.GivenName, user.DisplayName ?? user.UserName));
                }
                if (!identity.HasClaim(claim => claim.Type == ArchivingClaimTypes.ProfileType))
                {
                    identity.AddClaim(new Claim(ArchivingClaimTypes.ProfileType, user.UserProfileType!));
                }*/
                if (!identity.HasClaim(claim => claim.Type == ArchivingClaimTypes.IsAdmin))
                {
                    identity.AddClaim(new Claim(ArchivingClaimTypes.IsAdmin, user.IsAdmin.ToString()));
                }
                if (!identity.HasClaim(claim => claim.Type == ArchivingClaimTypes.AdminType))
                {
                    if (!string.IsNullOrEmpty(user.AdminType))
                    {
                        identity.AddClaim(new Claim(ArchivingClaimTypes.AdminType, user.AdminType));
                    }
                }
            }

            return principal;
        }
    }
}
