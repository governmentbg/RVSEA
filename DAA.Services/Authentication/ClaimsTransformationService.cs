using DAA.Models.Identity;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using SystemClaimTypes = System.Security.Claims.ClaimTypes;
using ArchivingClaimTypes = DAA.Shared.Security.ClaimTypes;

namespace DAA.Services.Authentication
{
    public class ClaimsTransformationService : IClaimsTransformation
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly RoleManager<ApplicationRole> _roleManager;

        public ClaimsTransformationService(
            UserManager<ApplicationUser> userManager,
            RoleManager<ApplicationRole> roleManager)
        {
            _userManager = userManager;
            _roleManager = roleManager;
        }
        public async Task<ClaimsPrincipal> TransformAsync(ClaimsPrincipal principal)
        {
            if (principal.Identity?.IsAuthenticated == false)
            {
                return new ClaimsPrincipal();
            }

            var identity = principal.Identity as ClaimsIdentity;
            var user = await _userManager.FindByNameAsync(principal.Identity?.Name);
            if (user != null && identity != null)
            {
                var userClaims = await _userManager.GetClaimsAsync(user);
                //if (userClaims.Any(claim => claim.Type == DocFlowClaimTypes.AdminType && claim.Value == AdminType.ClientAdmin))
                //{
                //    user.AdminType = AdminType.ClientAdmin;
                //    user.IsAdmin = true;
                //}
                if (!identity.HasClaim(claim => claim.Type == SystemClaimTypes.NameIdentifier))
                {
                    identity.AddClaim(new Claim(SystemClaimTypes.NameIdentifier, user.Id.ToString("D")));
                }
                if (!identity.HasClaim(claim => claim.Type == SystemClaimTypes.Email))
                {
                    identity.AddClaim(new Claim(SystemClaimTypes.Email, user.Email));
                }
                if (!identity.HasClaim(claim => claim.Type == SystemClaimTypes.GivenName))
                {
                    identity.AddClaim(new Claim(SystemClaimTypes.GivenName, user.UserName));
                }
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
