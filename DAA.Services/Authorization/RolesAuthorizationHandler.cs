using DAA.Shared.Security;
using Microsoft.AspNetCore.Authorization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Services.Authorization
{
    public class RolesAuthorizationHandler : AuthorizationHandler<RolesAuthorizationRequirement>
    {
        private readonly IAuthorizationService _authorizationService;

        public RolesAuthorizationHandler(IAuthorizationService authorizationService)
        {
            _authorizationService = authorizationService;
        }

        protected override async Task HandleRequirementAsync(AuthorizationHandlerContext context, RolesAuthorizationRequirement requirement)
        {
            if (context.User != null)
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

                bool hasRole = await _authorizationService.HasRole(context.User, requirement.AllowedRoles);
                if (hasRole)
                {
                    context.Succeed(requirement);
                }
                else
                {
                    context.Fail();
                }
            }
            return;
        }

    }
}
