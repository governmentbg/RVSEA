using DAA.Models.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;

namespace DAA.Identity
{
    public class ApplicationRoleManager : RoleManager<ApplicationRole>
    {
        protected new IApplicationRoleStore Store { get; private set; }

        public ApplicationRoleManager(
            IApplicationRoleStore store,
            IEnumerable<IRoleValidator<ApplicationRole>> roleValidators,
            ILookupNormalizer keyNormalizer,
            ILogger<RoleManager<ApplicationRole>> logger,
            IdentityErrorDescriber errors = null!)
            : base(store, roleValidators, keyNormalizer, errors, logger)
        {
            Store = store;
        }

        /// <summary>
        /// Gets a flag indicating whether the specified <paramref name="roleName"/> exists in the specified <paramref name="unitId"/>.
        /// </summary>
        /// <param name="roleName">The role name whose existence should be checked.</param>
        /// <param name="archiveId">The archive id againts whitch should be checked.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing true if the role name exists, otherwise false.
        /// </returns>
        public virtual async Task<bool> RoleExistsAsync(string roleName, int archiveId)
        {
            ThrowIfDisposed();
            if (roleName == null)
            {
                throw new ArgumentNullException(nameof(roleName));
            }

            return await FindByNameAsync(NormalizeKey(roleName), archiveId) != null;
        }

        /// <summary>
        /// Gets the ID of the specified <paramref name="role"/>.
        /// </summary>
        /// <param name="role">The role whose ID should be retrieved.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing the ID of the
        /// specified <paramref name="role"/>.
        /// </returns>
        public override Task<string> GetRoleIdAsync(ApplicationRole role)
        {
            ThrowIfDisposed();
            return Store.GetRoleIdAsync(role, CancellationToken);
        }

        /// <summary>
        /// Gets the ID of the specified <paramref name="role"/>.
        /// </summary>
        /// <param name="role">The role whose ID should be retrieved.</param>
        /// <param name="archiveId">The archive id againts whitch should be checked.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing the ID of the
        /// specified <paramref name="role"/>.
        /// </returns>
        public virtual Task<Guid> GetRoleIdAsync(ApplicationRole role, int? archiveId)
        {
            ThrowIfDisposed();
            return Store.GetRoleIdAsync(role, archiveId, CancellationToken);
        }

        /// <summary>
        /// Finds the role associated with the specified <paramref name="roleName"/> if any in the specified <paramref name="unitId"/>.
        /// </summary>
        /// <param name="roleName">The name of the role to be returned.</param>
        /// <param name="archiveId">The archive id againts whitch should be checked.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing the role
        /// associated with the specified <paramref name="roleName"/>
        /// </returns>
        public virtual Task<ApplicationRole> FindByNameAsync(string roleName, int? archiveId)
        {
            ThrowIfDisposed();
            if (roleName == null)
            {
                throw new ArgumentNullException(nameof(roleName));
            }

            return Store.FindByNameAsync(NormalizeKey(roleName), archiveId, CancellationToken);
        }

        /// <summary>
        /// Finds the role associated with the specified <paramref name="roleId"/> if any.
        /// </summary>
        /// <param name="roleId">The role ID whose role should be returned.</param>
        /// <param name="archiveId">The archive id againts whitch should be checked.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing the role
        /// associated with the specified <paramref name="roleId"/>
        /// </returns>
        public virtual Task<ApplicationRole> FindByIdAsync(Guid roleId, int? archiveId)
        {
            ThrowIfDisposed();
            return Store.FindByIdAsync(roleId, archiveId, CancellationToken);
        }

        /// <summary>
        /// Should return <see cref="IdentityResult.Success"/> if validation is successful. This is
        /// called before saving the role via Create or Update.
        /// </summary>
        /// <param name="role">The role</param>
        /// <returns>A <see cref="IdentityResult"/> representing whether validation was successful.</returns>
        protected override async Task<IdentityResult> ValidateRoleAsync(ApplicationRole role)
        {
            var errors = new List<IdentityError>();
            foreach (var v in RoleValidators)
            {
                var result = await v.ValidateAsync(this, role);
                if (!result.Succeeded)
                {
                    errors.AddRange(result.Errors);
                }
            }
            if (errors.Count > 0)
            {
                //Logger.LogWarning(LoggerEventIds.RoleValidationFailed, "Role {roleId} validation failed: {errors}.", await GetRoleIdAsync(role), string.Join(";", errors.Select(e => e.Code)));
                return IdentityResult.Failed(errors.ToArray());
            }
            return IdentityResult.Success;
        }

        /// <summary>
        /// Creates the specified <paramref name="role"/> in the persistence store.
        /// </summary>
        /// <param name="role">The role to create.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation.
        /// </returns>
        public override async Task<IdentityResult> CreateAsync(ApplicationRole role)
        {
            ThrowIfDisposed();
            if (role == null)
            {
                throw new ArgumentNullException(nameof(role));
            }
            var result = await ValidateRoleAsync(role);
            if (!result.Succeeded)
            {
                return result;
            }
            await UpdateNormalizedRoleNameAsync(role);
            result = await Store.CreateAsync(role, CancellationToken);
            return result;
        }
    }
}
