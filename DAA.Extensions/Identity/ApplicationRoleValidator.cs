using DAA.Models.Identity;
using DAA.Identity;
using Microsoft.AspNetCore.Identity;
using DAAIdentityErrorDescriber = DAA.Identity.IdentityErrorDescriber;

namespace DAA.Identity
{
    public class ApplicationRoleValidator : IRoleValidator<ApplicationRole>
    {
        private DAAIdentityErrorDescriber Describer { get; set; }

        public ApplicationRoleValidator(DAAIdentityErrorDescriber errors = null!)
        {
            Describer = errors ?? new DAAIdentityErrorDescriber();
        }

        public virtual async Task<IdentityResult> ValidateAsync(RoleManager<ApplicationRole> manager, ApplicationRole role)
        {
            if (manager == null)
            {
                throw new ArgumentNullException(nameof(manager));
            }
            if (role == null)
            {
                throw new ArgumentNullException(nameof(role));
            }
            var errors = new List<IdentityError>();
            await ValidateRoleName((ApplicationRoleManager)manager, role, errors);
            if (errors.Count > 0)
            {
                return IdentityResult.Failed(errors.ToArray());
            }
            return IdentityResult.Success;
        }

        private async Task ValidateRoleName(ApplicationRoleManager manager, ApplicationRole role, ICollection<IdentityError> errors)
        {
            var roleName = await manager.GetRoleNameAsync(role);
            if (string.IsNullOrWhiteSpace(roleName))
            {
                errors.Add(Describer.InvalidRoleName(roleName));
            }
            else
            {
                var roleArchiveId = role.ArchiveId;
                var owner = await manager.FindByNameAsync(roleName, roleArchiveId);
                if (owner != null &&
                    !string.Equals(await manager.GetRoleIdAsync(owner, roleArchiveId), await manager.GetRoleIdAsync(role, roleArchiveId)))
                {
                    errors.Add(Describer.DuplicateRoleName(roleName));
                }
            }
        }
    }
}
