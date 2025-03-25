using Microsoft.AspNetCore.Authorization;

namespace DAA.Services.Authorization
{
    public class RolesAuthorizationRequirement : IAuthorizationRequirement
    {
        public IEnumerable<string> AllowedRoles { get; }

        public RolesAuthorizationRequirement(IEnumerable<string> allowedRoles)
        {
            AllowedRoles = allowedRoles;
        }
    }
}
