using DAA.Models.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using DAAIdentityErrorDescriber = DAA.Identity.IdentityErrorDescriber;

namespace DAA.Identity
{
    public class ApplicationUserManager : UserManager<ApplicationUser>
    {
        //private readonly IStringLocalizer<SharedResources> _localizer;

        /// <summary>
        /// Gets or sets the persistence store the manager operates over.
        /// </summary>
        /// <value>The persistence store the manager operates over.</value>
        protected internal new IApplicationUserStore Store { get; set; }

        /// <summary>
        /// Constructs a new instance of <see cref="ApplicationUserManager"/>.
        /// </summary>
        /// <param name="store">The persistence store the manager will operate over.</param>
        /// <param name="optionsAccessor">The accessor used to access the <see cref="IdentityOptions"/>.</param>
        /// <param name="passwordHasher">The password hashing implementation to use when saving passwords.</param>
        /// <param name="userValidators">A collection of <see cref="IUserValidator{ApplicationUser}"/> to validate users against.</param>
        /// <param name="passwordValidators">A collection of <see cref="IPasswordValidator{ApplicationUser}"/> to validate passwords against.</param>
        /// <param name="keyNormalizer">The <see cref="ILookupNormalizer"/> to use when generating index keys for users.</param>
        /// <param name="errors">The <see cref="IdentityErrorDescriber"/> used to provider error messages.</param>
        /// <param name="services">The <see cref="IServiceProvider"/> used to resolve services.</param>
        /// <param name="logger">The logger used to log messages, warnings and errors.</param>
        public ApplicationUserManager(IApplicationUserStore store,
            IOptions<IdentityOptions> optionsAccessor,
            IPasswordHasher<ApplicationUser> passwordHasher,
            IEnumerable<IUserValidator<ApplicationUser>> userValidators,
            IEnumerable<IPasswordValidator<ApplicationUser>> passwordValidators,
            ILookupNormalizer keyNormalizer,
            IServiceProvider services,
            ILogger<UserManager<ApplicationUser>> logger,
            DAAIdentityErrorDescriber errors = null!
            )
            : base(store, optionsAccessor,passwordHasher, userValidators, passwordValidators, keyNormalizer, errors, services, logger)
        {
            Store = store;
        }

        private IdentityResult UserAlreadyInRoleError(string role)
        {
            //Logger.LogWarning(LoggerEventIds.UserAlreadyInRole, "User is already in role {role}.", role);
            return IdentityResult.Failed(ErrorDescriber.UserAlreadyInRole(role));
        }

        private IdentityResult UserNotInRoleError(string role)
        {
            //Logger.LogWarning(LoggerEventIds.UserNotInRole, "User is not in role {role}.", role);
            return IdentityResult.Failed(ErrorDescriber.UserNotInRole(role));
        }

        /// <summary>
        /// Add the specified <paramref name="user"/> to the named role.
        /// </summary>
        /// <param name="user">The user to add to the named role.</param>
        /// <param name="role">The name of the role to add the user to.</param>
        /// <param name="archiveId">The identifier of the archive in which resides the role to add the user to.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing the <see cref="IdentityResult"/>
        /// of the operation.
        /// </returns>
        public virtual async Task<IdentityResult> AddToRoleAsync(ApplicationUser user, string role, int archiveId)
        {
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }

            var normalizedRole = NormalizeName(role);
            if (await Store.IsInRoleAsync(user, normalizedRole, archiveId, CancellationToken))
            {
                return UserAlreadyInRoleError(role);
            }
            await Store.AddToRoleAsync(user, normalizedRole, archiveId, CancellationToken);
            return await UpdateUserAsync(user);
        }

        /// <summary>
        /// Add the specified <paramref name="user"/> to the named role.
        /// </summary>
        /// <param name="user">The user to add to the named role.</param>
        /// <param name="roleId">The identifier of the role to add the user to.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing the <see cref="IdentityResult"/>
        /// of the operation.
        /// </returns>
        public virtual async Task<IdentityResult> AddToRoleAsync(ApplicationUser user, Guid roleId)
        {
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }

            if (await Store.IsInRoleAsync(user, roleId, CancellationToken))
            {
                return UserAlreadyInRoleError(roleId.ToString("D"));
            }
            await Store.AddToRoleAsync(user, roleId, CancellationToken);
            return await UpdateUserAsync(user);
        }

        /// <summary>
        /// Add the specified <paramref name="user"/> to the named roles.
        /// </summary>
        /// <param name="user">The user to add to the named roles.</param>
        /// <param name="roles">The name of the roles to add the user to.</param>
        /// <param name="archiveId">The identifier of the unit in which resides the roles to add the user to.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing the <see cref="IdentityResult"/>
        /// of the operation.
        /// </returns>
        public virtual async Task<IdentityResult> AddToRolesAsync(ApplicationUser user, IEnumerable<string> roles, int archiveId)
        {
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }
            if (roles == null)
            {
                throw new ArgumentNullException(nameof(roles));
            }

            foreach (var role in roles.Distinct())
            {
                var normalizedRole = NormalizeName(role);
                if (await Store.IsInRoleAsync(user, normalizedRole, archiveId, CancellationToken))
                {
                    return UserAlreadyInRoleError(role);
                }
                await Store.AddToRoleAsync(user, normalizedRole, archiveId, CancellationToken);
            }
            return await UpdateUserAsync(user);
        }

        /// <summary>
        /// Add the specified <paramref name="user"/> to the named roles.
        /// </summary>
        /// <param name="user">The user to add to the named roles.</param>
        /// <param name="roles">The identifiers of the roles to add the user to.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing the <see cref="IdentityResult"/>
        /// of the operation.
        /// </returns>
        public virtual async Task<IdentityResult> AddToRolesAsync(ApplicationUser user, IEnumerable<Guid> roleIds)
        {
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }
            if (roleIds == null)
            {
                throw new ArgumentNullException(nameof(roleIds));
            }

            foreach (var roleId in roleIds.Distinct())
            {
                if (await Store.IsInRoleAsync(user, roleId, CancellationToken))
                {
                    return UserAlreadyInRoleError(roleId.ToString("D"));
                }
                await Store.AddToRoleAsync(user, roleId, CancellationToken);
            }
            return await UpdateUserAsync(user);
        }

        /// <summary>
        /// Removes the specified <paramref name="user"/> from the named role.
        /// </summary>
        /// <param name="user">The user to remove from the named role.</param>
        /// <param name="role">The name of the role to remove the user from.</param>
        /// <param name="archiveId">The identifier of the archive in which resides the role to remove the user from.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing the <see cref="IdentityResult"/>
        /// of the operation.
        /// </returns>
        public virtual async Task<IdentityResult> RemoveFromRoleAsync(ApplicationUser user, string role, int archiveId)
        {
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }

            var normalizedRole = NormalizeName(role);
            if (!await Store.IsInRoleAsync(user, normalizedRole, archiveId, CancellationToken))
            {
                return UserNotInRoleError(role);
            }
            await Store.RemoveFromRoleAsync(user, normalizedRole, archiveId, CancellationToken);
            return await UpdateUserAsync(user);
        }

        /// <summary>
        /// Removes the specified <paramref name="user"/> from the named role.
        /// </summary>
        /// <param name="user">The user to remove from the named role.</param>
        /// <param name="roleId">The identifier of the role to remove the user from.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing the <see cref="IdentityResult"/>
        /// of the operation.
        /// </returns>
        public virtual async Task<IdentityResult> RemoveFromRoleAsync(ApplicationUser user, Guid roleId)
        {
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }

            if (!await Store.IsInRoleAsync(user, roleId, CancellationToken))
            {
                return UserNotInRoleError(roleId.ToString("D"));
            }
            await Store.RemoveFromRoleAsync(user, roleId, CancellationToken);
            return await UpdateUserAsync(user);
        }

        /// <summary>
        /// Removes the specified <paramref name="user"/> from the named roles.
        /// </summary>
        /// <param name="user">The user to remove from the named roles.</param>
        /// <param name="roles">The name of the roles to remove the user from.</param>
        /// <param name="archiveId">The identifier of the archive in which resides the roles to remove the user from.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing the <see cref="IdentityResult"/>
        /// of the operation.
        /// </returns>
        public virtual async Task<IdentityResult> RemoveFromRolesAsync(ApplicationUser user, IEnumerable<string> roles, int archiveId)
        {
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }
            if (roles == null)
            {
                throw new ArgumentNullException(nameof(roles));
            }

            foreach (var role in roles)
            {
                var normalizedRole = NormalizeName(role);
                if (!await Store.IsInRoleAsync(user, normalizedRole, archiveId, CancellationToken))
                {
                    return UserNotInRoleError(role);
                }
                await Store.RemoveFromRoleAsync(user, normalizedRole, archiveId, CancellationToken);
            }
            return await UpdateUserAsync(user);
        }

        /// <summary>
        /// Removes the specified <paramref name="user"/> from the named roles.
        /// </summary>
        /// <param name="user">The user to remove from the named roles.</param>
        /// <param name="roleIds">The identifier of the roles to remove the user from.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing the <see cref="IdentityResult"/>
        /// of the operation.
        /// </returns>
        public virtual async Task<IdentityResult> RemoveFromRolesAsync(ApplicationUser user, IEnumerable<Guid> roleIds)
        {
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }
            if (roleIds == null)
            {
                throw new ArgumentNullException(nameof(roleIds));
            }

            foreach (var roleId in roleIds)
            {
                if (!await Store.IsInRoleAsync(user, roleId, CancellationToken))
                {
                    return UserNotInRoleError(roleId.ToString("D"));
                }
                await Store.RemoveFromRoleAsync(user, roleId, CancellationToken);
            }
            return await UpdateUserAsync(user);
        }

        /// <summary>
        /// Gets a list of role names the specified <paramref name="user"/> belongs to.
        /// </summary>
        /// <param name="user">The user whose role names to retrieve.</param>
        /// <param name="archiveId">The identifier of the archive in which reside the roles whose names to retrieve.</param>
        /// <returns>The <see cref="Task"/> that represents the asynchronous operation, containing a list of role names.</returns>
        public virtual async Task<IList<string>> GetRolesAsync(ApplicationUser user, int archiveId)
        {
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }
            return await Store.GetRolesAsync(user, archiveId, CancellationToken);
        }

        /// <summary>
        /// Gets a list of role names the specified <paramref name="user"/> belongs to.
        /// </summary>
        /// <param name="user">The user whose role identifiers to retrieve.</param>
        /// <returns>The <see cref="Task"/> that represents the asynchronous operation, containing a list of role names.</returns>
        public virtual async Task<IList<Guid>> GetRolesIdentifiersAsync(ApplicationUser user)
        {
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }
            return await Store.GetRolesIdentifiersAsync(user, CancellationToken);
        }

        /// <summary>
        /// Returns a flag indicating whether the specified <paramref name="user"/> is a member of the given named role.
        /// </summary>
        /// <param name="user">The user whose role membership should be checked.</param>
        /// <param name="roleId">The identifier of the role to be checked.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing a flag indicating whether the specified <paramref name="user"/> is
        /// a member of the named role.
        /// </returns>
        public virtual async Task<bool> IsInRoleAsync(ApplicationUser user, Guid roleId)
        {
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }
            return await Store.IsInRoleAsync(user, roleId, CancellationToken);
        }

        /// <summary>
        /// Returns a flag indicating whether the specified <paramref name="user"/> is a member of the given named role.
        /// </summary>
        /// <param name="user">The user whose role membership should be checked.</param>
        /// <param name="role">The name of the role to be checked.</param>
        /// <param name="archiveId">The identifier of the archive in which reside the role to be checked.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing a flag indicating whether the specified <paramref name="user"/> is
        /// a member of the named role.
        /// </returns>
        public virtual async Task<bool> IsInRoleAsync(ApplicationUser user, string role, int archiveId)
        {
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }
            return await Store.IsInRoleAsync(user, NormalizeName(role), archiveId, CancellationToken);
        }

        /// <summary>
        /// Returns a flag indicating whether the specified <paramref name="user"/> is a member of the given named role regardless of the archive
        /// </summary>
        /// <param name="user">The user whose role membership should be checked.</param>
        /// <param name="role">The name of the role to be checked.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing a flag indicating whether the specified <paramref name="user"/> is
        /// a member of the named role.
        /// </returns>
        //public virtual async Task<bool> IsInRoleAsync(ApplicationUser user, string role)
        //{
        //    ThrowIfDisposed();
        //    if (user == null)
        //    {
        //        throw new ArgumentNullException(nameof(user));
        //    }
        //    return await Store.IsInRoleAsync(user, NormalizeName(role), CancellationToken);
        //}

        /// <summary>
        /// Returns a list of users from the user store who are members of the specified <paramref name="roleName"/>.
        /// </summary>
        /// <param name="roleName">The name of the role whose users should be returned.</param>
        /// <param name="archiveId">The identifier of the unit in which reside the role whose users should be returned.</param>
        /// <returns>
        /// A <see cref="Task{TResult}"/> that represents the result of the asynchronous query, a list of <typeparamref name="TUser"/>s who
        /// are members of the specified role.
        /// </returns>
        public virtual Task<IList<ApplicationUser>> GetUsersInRoleAsync(string roleName, int archiveId)
        {
            ThrowIfDisposed();
            if (roleName == null)
            {
                throw new ArgumentNullException(nameof(roleName));
            }

            return Store.GetUsersInRoleAsync(NormalizeName(roleName),archiveId, CancellationToken);
        }
    }
}
