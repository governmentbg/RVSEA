using DAA.Models.Identity;
using Microsoft.AspNetCore.Identity;

namespace DAA.Services.Identity
{
    public interface IApplicationUserStore : 
        IUserStore<ApplicationUser>, 
        IUserRoleStore<ApplicationUser>, 
        IUserClaimStore<ApplicationUser>,
        IUserLoginStore<ApplicationUser>,
        IUserPasswordStore<ApplicationUser>,
        IUserSecurityStampStore<ApplicationUser>,
        IUserTwoFactorStore<ApplicationUser>,
        IUserPhoneNumberStore<ApplicationUser>,
        IUserEmailStore<ApplicationUser>,
        IUserLockoutStore<ApplicationUser>,
        IQueryableUserStore<ApplicationUser>
    {
        /// <summary>
        /// Add the specified <paramref name="user"/> to the named role.
        /// </summary>
        /// <param name="user">The user to add to the named role.</param>
        /// <param name="roleName">The name of the role to add the user to.</param>
        /// <param name="archiveId">The identifier of the archive in which resides the role to add the user to.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>The <see cref="Task"/> that represents the asynchronous operation.</returns>
        Task AddToRoleAsync(ApplicationUser user, string roleName, int archiveId, CancellationToken cancellationToken);

        /// <summary>
        /// Add the specified <paramref name="user"/> to the named role.
        /// </summary>
        /// <param name="user">The user to add to the named role.</param>
        /// <param name="roleId">The identifier of the role to add the user to.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>The <see cref="Task"/> that represents the asynchronous operation.</returns>
        Task AddToRoleByIdAsync(ApplicationUser user, Guid roleId, CancellationToken cancellationToken);

        /// <summary>
        /// Remove the specified <paramref name="user"/> from the named role.
        /// </summary>
        /// <param name="user">The user to remove the named role from.</param>
        /// <param name="roleName">The name of the role to remove.</param>
        /// <param name="archiveId">The identifier of the archive in which resides the role to remove.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>The <see cref="Task"/> that represents the asynchronous operation.</returns>
        Task RemoveFromRoleAsync(ApplicationUser user, string roleName, int archiveId, CancellationToken cancellationToken);

        /// <summary>
        /// Remove the specified <paramref name="user"/> from the named role.
        /// </summary>
        /// <param name="user">The user to remove the named role from.</param>
        /// <param name="roleId">The identifier of the role to remove.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>The <see cref="Task"/> that represents the asynchronous operation.</returns>
        Task RemoveFromRoleByIdAsync(ApplicationUser user, Guid roleId, CancellationToken cancellationToken);

        /// <summary>
        /// Gets a list of role names the specified <paramref name="user"/> belongs to.
        /// </summary>
        /// <param name="user">The user whose role names to retrieve.</param>
        /// <param name="archiveId">The identifier of the archive in which reside the role names to retrieve.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>The <see cref="Task"/> that represents the asynchronous operation, containing a list of role names.</returns>
        Task<IList<string>> GetRolesAsync(ApplicationUser user, int archiveId, CancellationToken cancellationToken);

        /// <summary>
        /// Returns a flag indicating whether the specified <paramref name="user"/> is a member of the given named role.
        /// </summary>
        /// <param name="user">The user whose role membership should be checked.</param>
        /// <param name="roleName">The name of the role to be checked.</param>
        /// <param name="archiveId">The identifier of the archive in which resides the role to be checked.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing a flag indicating whether the specified <paramref name="user"/> is
        /// a member of the named role.
        /// </returns>
        Task<bool> IsInRoleAsync(ApplicationUser user, string roleName, int archiveId, CancellationToken cancellationToken);

        /// <summary>
        /// Returns a flag indicating whether the specified <paramref name="user"/> is a member of the given named role.
        /// </summary>
        /// <param name="user">The user whose role membership should be checked.</param>
        /// <param name="roleId">The identifier of the role to be checked.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing a flag indicating whether the specified <paramref name="user"/> is
        /// a member of the named role.
        /// </returns>
        Task<bool> IsInRoleByIdAsync(ApplicationUser user, Guid roleId, CancellationToken cancellationToken);

        /// <summary>
        /// Returns a list of Users who are members of the named role.
        /// </summary>
        /// <param name="roleName">The name of the role whose membership should be returned.</param>
        /// <param name="archiveId">The identifier of the archive in which resides the role whose membership should be returned.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing a list of users who are in the named role.
        /// </returns>
        Task<IList<ApplicationUser>> GetUsersInRoleAsync(string roleName, int archiveId, CancellationToken cancellationToken);

        /// <summary>
        /// Returns a list of Users who are members of the named role.
        /// </summary>
        /// <param name="roleId">The identifier of the role whose membership should be returned.</param>
        /// <param name="unitId">The identifier of the unit in which resides the role whose membership should be returned.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>
        /// The <see cref="Task"/> that represents the asynchronous operation, containing a list of users who are in the named role.
        /// </returns>
        Task<IList<ApplicationUser>> GetUsersInRoleByIdAsync(Guid roleId, CancellationToken cancellationToken);
    }
}
