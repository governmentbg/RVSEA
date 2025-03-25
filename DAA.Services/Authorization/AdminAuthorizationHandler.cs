using Microsoft.AspNetCore.Authorization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace DAA.Services.Authorization
{
    public class AdminAuthorizationHandler : AuthorizationHandler<AdminAuthorizationRequirement>
    {
        private readonly IAuthorizationService _authorizationService;

        /// <summary>
        /// Creates a new instance of <see cref="AdminAuthorizationRequirement"/>.
        /// </summary>
        /// <param name="authorizationService">Instance of <see cref="IAuthorizationService"/>.</param>
        public AdminAuthorizationHandler(IAuthorizationService authorizationService)
        {
            _authorizationService = authorizationService;
        }

        /// <summary>
        /// Makes a decision if authorization is allowed based on a specific requirement.
        /// </summary>
        /// <param name="context">The authorization context.</param>
        /// <param name="requirement">The requirement to evaluate.</param>

        protected override async Task HandleRequirementAsync(AuthorizationHandlerContext context, AdminAuthorizationRequirement requirement)
        {
            if (context.User != null)
            {
                bool found = false;
                if (requirement.AllowedAdminTypes == null || !requirement.AllowedAdminTypes.Any())
                {
                    // Review: What do we want to do here?  No admin type requested is auto success?
                }
                else
                {
                    //found = requirement.AllowedRoles.Any(r => context.User.IsInRole(r));
                    foreach(var adminType in requirement.AllowedAdminTypes)
                    {
                        if ( await _authorizationService.IsAdmin(context.User, adminType))
                        {
                            found = true;
                        }
                    }
                }
                if (found)
                {
                    context.Succeed(requirement);
                }
            }
            //return Task.CompletedTask;
            return;
        }

    }
}
