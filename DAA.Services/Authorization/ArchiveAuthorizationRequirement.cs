using DAA.Shared.Authorization;
using Microsoft.AspNetCore.Authorization;

namespace DAA.Services.Authorization
{
    public class ArchiveAuthorizationRequirement : IArchiveAuthorizationRequirement
    {
        public IEnumerable<string> AllowedRoles { get; }

        public ArchiveAuthorizationRequirement(IEnumerable<string> allowedRoles)
        {
            AllowedRoles = allowedRoles;
        }

        public ArchiveAuthorizationRequirement(params string[] allowedRoles)
        {
            AllowedRoles = allowedRoles;
        }
    }
}
