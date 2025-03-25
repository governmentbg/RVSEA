using DAA.Data;
using DAA.Models.Identity;
using DAA.Shared;
using DAA.Shared.Security;
using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using SystemClaimTypes = System.Security.Claims.ClaimTypes;
using ArchivingClaimTypes = DAA.Shared.Security.ClaimTypes;
using Microsoft.Extensions.Localization;
using DAA.Shared.Localization;
using DAA.Models.Authentication;

namespace DAA.Services.Admin
{
    public class GlobalAdministratorService : BaseService, IGlobalAdministratorService
    {
        private UserManager<ApplicationUser> _userManager;

        public GlobalAdministratorService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            UserManager<ApplicationUser> userManager)
            : base(context, localizer)
        {
            _userManager = userManager;
        }

        public async Task<OperationResult> CreateAnonymousUser()
        {
            var user = await _userManager.FindByIdAsync(AnonymousSystemUser.Id.ToString("D"));
            if (user != null)
            {
                return OperationResult.Failed("Anonymous System User Exists");
            }

            user = new ApplicationUser()
            {
                Id = AnonymousSystemUser.Id,
                AuthenticationType = AuthenticationType.Password,
                UserType = ApplicationUserType.System,
                //UserProfileType = ApplicationUserProfileType.System,
                //DisplayName = AnonymousSystemUser.DisplayName,
                UserName = AnonymousSystemUser.Username,
                Email = AnonymousSystemUser.Username,
            };

            var createUserResult = await _userManager.CreateAsync(user);
            if (!createUserResult.Succeeded)
            {
                return OperationResult.Failed(createUserResult.Errors.Select(err => err.Description).ToArray());
            }

            return OperationResult.Success;
        }
        public Task<OperationResult> CreateAdmin()
        {
            return CreateUser();
        }
        public ApplicationUser CheckLogin(LoginModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            ApplicationUser user = null!;

            if (CheckLogin(model.Email, model.Password))
            {
                user = GetUser();
            }

            return user;
        }

        public ApplicationUser GetUser(ClaimsPrincipal principal)
        {
            if (principal == null)
            {
                throw new ArgumentNullException(nameof(principal));
            }

            if (GlobalAdministrator.CheckUsername(principal.Identity!.Name!)
                && principal.FindFirstValue(ArchivingClaimTypes.AdminType) == AdminType.GlobalAdmin
                && principal.HasClaim(claim => claim.Type == ArchivingClaimTypes.IsAdmin)
                && bool.Parse(principal.FindFirstValue(ArchivingClaimTypes.IsAdmin)))
            {
                return GetUser();
            }

            return null!;
        }

        public bool GetUserIsAdmin(ClaimsPrincipal principal)
        {
            if (principal == null)
            {
                throw new ArgumentNullException(nameof(principal));
            }
            bool isAdmin = false;
            if (GlobalAdministrator.CheckUsername(principal.Identity!.Name!)
                && principal.HasClaim(claim => claim.Type == ArchivingClaimTypes.AdminType)
                && principal.HasClaim(claim => claim.Type == ArchivingClaimTypes.IsAdmin))
            {
                isAdmin = principal.FindFirstValue(ArchivingClaimTypes.AdminType) == AdminType.GlobalAdmin
                            && bool.Parse(principal.FindFirstValue(ArchivingClaimTypes.IsAdmin));
            }
            return isAdmin;
        }

        private bool CheckLogin(string username, string password)
        {
            return GlobalAdministrator.CheckUsername(username) && GlobalAdministrator.CheckPassword(password);
        }

        private ApplicationUser GetUser()
        {
            return new ApplicationUser()
            {
                Id = GlobalAdministrator.Id,
                AuthenticationType = AuthenticationType.Password,
                UserType = ApplicationUserType.System,
                //UserProfileType = ApplicationUserProfileType.System,
                //DisplayName = GlobalAdministrator.DisplayName,
                UserName = GlobalAdministrator.Username,
                Email = GlobalAdministrator.Email,
                EmailConfirmed = true,
                IsAdmin = true,
                AdminType = AdminType.GlobalAdmin,
                Deleted = false,
            };
        }

        private async Task<OperationResult> CreateUser()
        {
            var user = await _userManager.FindByIdAsync(GlobalAdministrator.Id.ToString("D"));
            if (user != null)
            {
                return OperationResult.Failed("Global Admin User Exists");
            }

            user = new ApplicationUser()
            {
                Id = GlobalAdministrator.Id,
                AuthenticationType = AuthenticationType.Password,
                UserType = ApplicationUserType.System,
                //UserProfileType = ApplicationUserProfileType.System,
                //DisplayName = GlobalAdministrator.DisplayName,
                UserName = GlobalAdministrator.Username,
                Email = GlobalAdministrator.Username,
            };

            var createUserResult = await _userManager.CreateAsync(user);
            if (!createUserResult.Succeeded)
            {
                return OperationResult.Failed(createUserResult.Errors.Select(err => err.Description).ToArray());
            }

            var addClaimResult = 
                await _userManager.AddClaimAsync(user, new Claim(ArchivingClaimTypes.AdminType, AdminType.GlobalAdmin));
            if (!addClaimResult.Succeeded)
            {
                return OperationResult.Failed(addClaimResult.Errors.Select(err => err.Description).ToArray());
            }

            return OperationResult.Success;
        }
    }
}
