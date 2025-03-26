using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Linq;
using DAA.Models.Identity;
using DAA.Shared.Localization;

namespace DAA.Services.Identity
{
    public class ApplicationUserStore<TContext> : UserStore<
        ApplicationUser, 
        ApplicationRole, 
        TContext, 
        Guid, 
        ApplicationUserClaim, 
        ApplicationUserRole, 
        ApplicationUserLogin, 
        ApplicationUserToken, 
        ApplicationRoleClaim>,
        IApplicationUserStore
        where TContext : IdentityDbContext<
            ApplicationUser,
            ApplicationRole,
            Guid,
            ApplicationUserClaim,
            ApplicationUserRole,
            ApplicationUserLogin,
            ApplicationRoleClaim,
            ApplicationUserToken>
    {
        private readonly IStringLocalizer<SharedResources> _localizer;

        /// <summary>
        /// Creates a new instance of the store.
        /// </summary>
        /// <param name="context">The context used to access the store.</param>
        /// <param name="describer">The <see cref="IdentityErrorDescriber"/> used to describe store errors.</param>
        public ApplicationUserStore(TContext context, IStringLocalizer<SharedResources> localizer = null!, IdentityErrorDescriber describer = null!) 
            : base(context, describer)
        {
            _localizer = localizer;
        }

        //private DbSet<ApplicationUser> UsersSet { get { return Context.Set<ApplicationUser>(); } }
        private DbSet<ApplicationRole> Roles { get { return Context.Set<ApplicationRole>(); } }
        //private DbSet<ApplicationUserClaim> UserClaims { get { return Context.Set<ApplicationUserClaim>(); } }
        private DbSet<ApplicationUserRole> UserRoles { get { return Context.Set<ApplicationUserRole>(); } }
        //private DbSet<ApplicationUserLogin> UserLogins { get { return Context.Set<ApplicationUserLogin>(); } }
        //private DbSet<ApplicationUserToken> UserTokens { get { return Context.Set<ApplicationUserToken>(); } }

        /// <summary>
        /// Called to create a new instance of a <see cref="IdentityUserRole{TKey}"/>.
        /// </summary>
        /// <param name="user">The associated user.</param>
        /// <param name="role">The associated role.</param>
        /// <returns></returns>
        protected override ApplicationUserRole CreateUserRole(ApplicationUser user, ApplicationRole role)
        {
            return new ApplicationUserRole()
            {
                UserId = user.Id,
                RoleId = role.Id
            };
        }

        /// <summary>
        /// Return a role with the normalized name if it exists in unit.
        /// </summary>
        /// <param name="normalizedRoleName">The normalized role name.</param>
        /// <param name="archiveId">The identifier of the archive in which the role resides.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>The role if it exists.</returns>
        protected Task<ApplicationRole> FindRoleAsync(string normalizedRoleName, int archiveId, CancellationToken cancellationToken)
        {
            return Roles.SingleOrDefaultAsync(r => r.NormalizedName == normalizedRoleName && r.ArchiveId == archiveId, cancellationToken)!;
        }

        /// <summary>
        /// Return a user role for the userId and roleId if it exists.
        /// </summary>
        /// <param name="userId">The user's id.</param>
        /// <param name="roleId">The role's id.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>The user role if it exists.</returns>
        protected override Task<ApplicationUserRole> FindUserRoleAsync(Guid userId, Guid roleId, CancellationToken cancellationToken)
        {
            return UserRoles.FindAsync(new object[] { userId, roleId }, cancellationToken).AsTask()!;
        }

        /// <summary>
        /// Return a role with the specified indentifier if it exists.
        /// </summary>
        /// <param name="roleId">The role identifier.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>The role if it exists.</returns>
        protected Task<ApplicationRole> FindRoleByIdAsync(Guid roleId, CancellationToken cancellationToken)
        {
            return Roles.SingleOrDefaultAsync(r => r.Id == roleId, cancellationToken)!;
        }

        /// <summary>
        /// Adds the given <paramref name="normalizedRoleName"/> to the specified <paramref name="user"/>.
        /// </summary>
        /// <param name="user">The user to add the role to.</param>
        /// <param name="normalizedRoleName">The role to add.</param>
        /// <param name="archiveId">The identifier of the archive in which resides the role to add.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>The <see cref="Task"/> that represents the asynchronous operation.</returns>
        public async Task AddToRoleAsync(ApplicationUser user, string normalizedRoleName, int archiveId, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }
            if (string.IsNullOrWhiteSpace(normalizedRoleName))
            {
                throw new ArgumentException(_localizer.GetString("Error_ValueCannotBeNullOrEmpty").ToString(), nameof(normalizedRoleName));
            }
            var roleEntity = await FindRoleAsync(normalizedRoleName, archiveId, cancellationToken);
            if (roleEntity == null)
            {
                throw new InvalidOperationException(string.Format(CultureInfo.CurrentCulture, _localizer.GetString("Error_RoleNotFound").ToString(), normalizedRoleName));
            }
            UserRoles.Add(CreateUserRole(user, roleEntity));
        }

        /// <summary>
        /// Adds the given role with <paramref name="roleId"/> to the specified <paramref name="user"/>.
        /// </summary>
        /// <param name="user">The user to add the role to.</param>
        /// <param name="roleId">The identifier if the role to add.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>The <see cref="Task"/> that represents the asynchronous operation.</returns>
        public async Task AddToRoleByIdAsync(ApplicationUser user, Guid roleId, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }
            if (roleId.Equals(Guid.Empty))
            {
                throw new ArgumentException(_localizer.GetString("Error_ValueCannotBeNullOrEmpty").ToString(), nameof(roleId));
            }
            var roleEntity = await FindRoleByIdAsync(roleId, cancellationToken);
            if (roleEntity == null)
            {
                throw new InvalidOperationException(string.Format(CultureInfo.CurrentCulture, _localizer.GetString("Error_RoleWithIdNotFound").ToString(), roleId));
            }
            UserRoles.Add(CreateUserRole(user, roleEntity));
        }

        /// <summary>
        /// Removes the given <paramref name="normalizedRoleName"/> from the specified <paramref name="user"/>.
        /// </summary>
        /// <param name="user">The user to remove the role from.</param>
        /// <param name="normalizedRoleName">The role to remove.</param>
        /// <param name="archiveId">The identifier of the archive in which resides the role to remove.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>The <see cref="Task"/> that represents the asynchronous operation.</returns>
        public async Task RemoveFromRoleAsync(ApplicationUser user, string normalizedRoleName, int archiveId, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }
            if (string.IsNullOrWhiteSpace(normalizedRoleName))
            {
                throw new ArgumentException(_localizer.GetString("Error_ValueCannotBeNullOrEmpty").ToString(), nameof(normalizedRoleName));
            }
            var roleEntity = await FindRoleAsync(normalizedRoleName, archiveId, cancellationToken);
            if (roleEntity != null)
            {
                var userRole = await FindUserRoleAsync(user.Id, roleEntity.Id, cancellationToken);
                if (userRole != null)
                {
                    UserRoles.Remove(userRole);
                }
            }
        }

        /// <summary>
        /// Removes the role with given <paramref name="roleId"/> from the specified <paramref name="user"/>.
        /// </summary>
        /// <param name="user">The user to remove the role from.</param>
        /// <param name="roleId">The identifier of the role to remove.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>The <see cref="Task"/> that represents the asynchronous operation.</returns>
        public async Task RemoveFromRoleByIdAsync(ApplicationUser user, Guid roleId, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }
            if (roleId.Equals(Guid.Empty))
            {
                throw new ArgumentException(_localizer.GetString("Error_ValueCannotBeNullOrEmpty").ToString(), nameof(roleId));
            }
            var roleEntity = await FindRoleByIdAsync(roleId, cancellationToken);
            if (roleEntity != null)
            {
                var userRole = await FindUserRoleAsync(user.Id, roleEntity.Id, cancellationToken);
                if (userRole != null)
                {
                    UserRoles.Remove(userRole);
                }
            }
        }

        /// <summary>
        /// Retrieves the roles the specified <paramref name="user"/> is a member of in unit.
        /// </summary>
        /// <param name="user">The user whose roles should be retrieved.</param>
        /// <param name="archiveId">The identifier of the archive in which reside the roles.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>A <see cref="Task{TResult}"/> that contains the roles the user is a member of.</returns>
        public async Task<IList<string>> GetRolesAsync(ApplicationUser user, int archiveId, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }
            var userId = user.Id;
            var query = from userRole in UserRoles
                        join role in Roles on userRole.RoleId equals role.Id
                       where userRole.UserId.Equals(userId) && role.ArchiveId.Equals(archiveId)
                      select role.Name;
            return await query.ToListAsync(cancellationToken);
        }

        /// <summary>
        /// Returns a flag indicating if the specified user is a member of the give <paramref name="normalizedRoleName"/>.
        /// </summary>
        /// <param name="user">The user whose role membership should be checked.</param>
        /// <param name="normalizedRoleName">The role to check membership of</param>
        /// <param name="archiveId">The identifier of the archive in which resides the role to check membership of.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>A <see cref="Task{TResult}"/> containing a flag indicating if the specified user is a member of the given group. If the
        /// user is a member of the group the returned value with be true, otherwise it will be false.</returns>
        public async Task<bool> IsInRoleAsync(ApplicationUser user, string normalizedRoleName, int archiveId, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }
            if (string.IsNullOrWhiteSpace(normalizedRoleName))
            {
                throw new ArgumentException(_localizer.GetString("Error_ValueCannotBeNullOrEmpty").ToString(), nameof(normalizedRoleName));
            }
            var role = await FindRoleAsync(normalizedRoleName, archiveId, cancellationToken);
            if (role != null)
            {
                var userRole = await FindUserRoleAsync(user.Id, role.Id, cancellationToken);
                return userRole != null;
            }
            return false;
        }

        /// <summary>
        /// Returns a flag indicating if the specified user is a member of the give <paramref name="normalizedRoleName"/>.
        /// </summary>
        /// <param name="user">The user whose role membership should be checked.</param>
        /// <param name="roleId">The identifier of the role to check membership of</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>A <see cref="Task{TResult}"/> containing a flag indicating if the specified user is a member of the given group. If the
        /// user is a member of the group the returned value with be true, otherwise it will be false.</returns>
        public async Task<bool> IsInRoleByIdAsync(ApplicationUser user, Guid roleId, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }
            if (roleId.Equals(Guid.Empty))
            {
                throw new ArgumentException(_localizer.GetString("Error_ValueCannotBeNullOrEmpty").ToString(), nameof(roleId));
            }
            var role = await FindRoleByIdAsync(roleId, cancellationToken);
            if (role != null)
            {
                var userRole = await FindUserRoleAsync(user.Id, role.Id, cancellationToken);
                return userRole != null;
            }
            return false;
        }
        /// <summary>
        /// Retrieves all users in the specified role in unit.
        /// </summary>
        /// <param name="normalizedRoleName">The role whose users should be retrieved.</param>
        /// <param name="archiveId">The identifier of the archive in which resides the role whose users should be retrieved.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>
        /// The <see cref="Task"/> contains a list of users, if any, that are in the specified role.
        /// </returns>
        public async Task<IList<ApplicationUser>> GetUsersInRoleAsync(string normalizedRoleName, int archiveId, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (string.IsNullOrEmpty(normalizedRoleName))
            {
                throw new ArgumentNullException(nameof(normalizedRoleName));
            }

            var role = await FindRoleAsync(normalizedRoleName, archiveId, cancellationToken);

            if (role != null)
            {
                var query = from userRole in UserRoles
                            join user in Users on userRole.UserId equals user.Id
                            where userRole.RoleId.Equals(role.Id)
                            select user;

                return await query.ToListAsync(cancellationToken);
            }
            return new List<ApplicationUser>();
        }

        /// <summary>
        /// Retrieves all users in the specified role.
        /// </summary>
        /// <param name="roleId">The identifier of the role whose users should be retrieved.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>
        /// The <see cref="Task"/> contains a list of users, if any, that are in the specified role.
        /// </returns>
        public async Task<IList<ApplicationUser>> GetUsersInRoleByIdAsync(Guid roleId, CancellationToken cancellationToken)
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (roleId.Equals(Guid.Empty))
            {
                throw new ArgumentNullException(nameof(roleId));
            }

            var role = await FindRoleByIdAsync(roleId, cancellationToken);

            if (role != null)
            {
                var query = from userRole in UserRoles
                            join user in Users on userRole.UserId equals user.Id
                            where userRole.RoleId.Equals(role.Id)
                            select user;

                return await query.ToListAsync(cancellationToken);
            }
            return new List<ApplicationUser>();
        }
    }
}
