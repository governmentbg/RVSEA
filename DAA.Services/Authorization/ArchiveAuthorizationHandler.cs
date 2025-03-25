using DAA.Shared.Security;
using Microsoft.AspNetCore.Authorization;

namespace DAA.Services.Authorization
{
    public class ArchiveAuthorizationHandler : AuthorizationHandler<ArchiveAuthorizationRequirement, int?>
    {
        private readonly IAuthorizationService _authorizationService;

        public ArchiveAuthorizationHandler(IAuthorizationService authorizationService)
        {
            _authorizationService = authorizationService;
        }

        protected override async Task HandleRequirementAsync(
            AuthorizationHandlerContext context,
            ArchiveAuthorizationRequirement requirement, 
            int? resource)
        {

            bool isAdmin = await _authorizationService.IsAdmin(context.User, AdminType.GlobalAdmin);
            if (isAdmin)
            {
                context.Succeed(requirement);
                return;
            }

            isAdmin = await _authorizationService.IsAdmin(context.User, AdminType.Admin);
            if (isAdmin)
            {
                context.Succeed(requirement);
                return;
            }

            bool hasRole = await _authorizationService.HasRole(context.User, requirement.AllowedRoles, resource);
            if (!hasRole)
            {
                context.Fail();
                return;
            }

            if (!context.HasFailed)
            {
                context.Succeed(requirement);
            }

            return;
        }
    }


}
