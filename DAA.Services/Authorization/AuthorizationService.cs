using DAA.Data.RemoteDBEntities;
using DAA.Identity;
using DAA.Models.Identity;
using DAA.Services.Admin;
using DAA.Shared.Security;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using ArchivingClaimTypes = DAA.Shared.Security.ClaimTypes;
using SystemClaimTypes = System.Security.Claims.ClaimTypes;

namespace DAA.Services.Authorization
{
    public class AuthorizationService : IAuthorizationService
    {
        protected readonly ApplicationUserManager _userManager;
        protected readonly ApplicationRoleManager _roleManager;
        private readonly IGlobalAdministratorService _adminService;

        public AuthorizationService(
            ApplicationUserManager userManager,
            ApplicationRoleManager roleManager,
            IGlobalAdministratorService adminService)
        {
            _userManager = userManager;
            _roleManager = roleManager;
            _adminService = adminService;
        }

        public async Task<bool> IsAdmin(ClaimsPrincipal principal, string adminType)
        {
            bool isAdmin = false;
            switch (adminType)
            {
                case AdminType.GlobalAdmin:
                    isAdmin = _adminService.GetUserIsAdmin(principal);
                    break;
                case AdminType.Admin:
                    var user = await _userManager.GetUserAsync(principal);
                    if (user != null)
                    {
                        isAdmin = await _userManager.Users
                            .Include(u => u.Claims)
                            .Where(u => u.Id == user.Id)
                            .SelectMany(u => u.Claims)
                            .AnyAsync(uc => uc.ClaimType == ArchivingClaimTypes.AdminType && uc.ClaimValue == AdminType.Admin);
                    }
                    break;
            }

            return isAdmin;
        }

        public async Task<bool> HasRole(ClaimsPrincipal principal, IEnumerable<string> roles, int? archiveId = null)
        {
            if(roles == null || !roles.Any())
            {
                return false;
            }

            var user = await _userManager.FindByIdAsync(principal.GetUserId().ToString("D"));
            if (user == null)
            {
                return false;
            }

            foreach (var role in roles)
            {
                bool hasRole = archiveId.HasValue && archiveId.Value > 0
                    ? await _userManager.IsInRoleAsync(user, role, archiveId.Value)
                    : await _userManager.IsInRoleAsync(user, role);
                if (hasRole)
                {
                    return true;
                }
            }

            return false;
        }

        //public async Task<IEnumerable<string>> GetRoles(ClaimsPrincipal principal)
        //{
        //    var user = await _userManager.GetUserAsync(principal);
        //    if (user != null)
        //    {
        //        var roles = _userManager.Users
        //            .Include(u => u.UserRoles)
        //            .ThenInclude(ur => ur.Role)
        //            .Where(u => u.Id == user.Id)
        //            .SelectMany(u => u.UserRoles)
        //            .Select(ur => ur.Role.Name);

        //        return roles;
        //    }
        //    return null;
        //}

        public async Task<string[]?> GetRoles(ClaimsPrincipal principal)
        {
            ApplicationUser user = await _userManager.GetUserAsync(principal);
            return user != null ? await GetRoles(user.Id) : null;
        }

        public async Task<string[]> GetRoles(Guid userId)
        {
            return await _userManager.Users
                .Where(u => u.Id == userId)
                .SelectMany(u => u.UserRoles)
                .Select(ur => ur.Role.Name).ToArrayAsync();
        }
    }
}
