using DAA.Models.Identity;
using DAA.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel;
using System.Security.Claims;
using DAAIdentityErrorDescriber = DAA.Identity.IdentityErrorDescriber;

namespace DAA.Identity
{
    public class ApplicationRoleStore<TContext> : IApplicationRoleStore, IQueryableRoleStore<ApplicationRole>, IRoleClaimStore<ApplicationRole>
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
        private bool _disposed;

        public virtual TContext Context { get; private set; }

        public DAAIdentityErrorDescriber ErrorDescriber { get; set; }

        public bool AutoSaveChanges { get; set; } = true;

        public ApplicationRoleStore(TContext context, DAAIdentityErrorDescriber describer = null!)
        {
            if (context == null)
            {
                throw new ArgumentNullException(nameof(context));
            }
            Context = context;
            ErrorDescriber = describer ?? new DAAIdentityErrorDescriber();
        }

        private async Task SaveChanges(CancellationToken cancellationToken)
        {
            if (AutoSaveChanges)
            {
                await Context.SaveChangesAsync(cancellationToken);
            }
        }

        public virtual async Task<IdentityResult> CreateAsync(ApplicationRole role, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (role == null)
            {
                throw new ArgumentNullException(nameof(role));
            }
            Context.Add(role);
            await SaveChanges(cancellationToken);
            return IdentityResult.Success;
        }

        public virtual async Task<IdentityResult> UpdateAsync(ApplicationRole role, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (role == null)
            {
                throw new ArgumentNullException(nameof(role));
            }
            Context.Attach(role);
            role.ConcurrencyStamp = Guid.NewGuid().ToString();
            Context.Update(role);
            try
            {
                await SaveChanges(cancellationToken);
            }
            catch (DbUpdateConcurrencyException)
            {
                return IdentityResult.Failed(ErrorDescriber.ConcurrencyFailure());
            }
            return IdentityResult.Success;
        }

        public virtual async Task<IdentityResult> DeleteAsync(ApplicationRole role, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (role == null)
            {
                throw new ArgumentNullException(nameof(role));
            }
            Context.Remove(role);
            try
            {
                await SaveChanges(cancellationToken);
            }
            catch (DbUpdateConcurrencyException)
            {
                return IdentityResult.Failed(ErrorDescriber.ConcurrencyFailure());
            }
            return IdentityResult.Success;
        }

        public virtual Task<string> GetRoleIdAsync(ApplicationRole role, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (role == null)
            {
                throw new ArgumentNullException(nameof(role));
            }
            return Task.FromResult(ConvertIdToString(role.Id));
        }

        public virtual Task<Guid> GetRoleRawIdAsync(ApplicationRole role, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (role == null)
            {
                throw new ArgumentNullException(nameof(role));
            }
            return Task.FromResult(role.Id);
        }

        public virtual Task<Guid> GetRoleIdAsync(ApplicationRole role, int? archiveId, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (role == null)
            {
                throw new ArgumentNullException(nameof(role));
            }
            return Task.FromResult(role.ArchiveId == archiveId ? role.Id : default(Guid));
        }

        public virtual Task<string> GetRoleNameAsync(ApplicationRole role, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (role == null)
            {
                throw new ArgumentNullException(nameof(role));
            }
            return Task.FromResult(role.Name);
        }

        public virtual Task SetRoleNameAsync(ApplicationRole role, string roleName, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (role == null)
            {
                throw new ArgumentNullException(nameof(role));
            }
            role.Name = roleName;
            return Task.CompletedTask;
        }

        public virtual Guid ConvertIdFromString(string id)
        {
            if (id == null)
            {
                return default(Guid);
            }
            return (Guid)TypeDescriptor.GetConverter(typeof(Guid)).ConvertFromInvariantString(id)!;
        }

        public virtual string ConvertIdToString(Guid id)
        {
            if (id.Equals(default(Guid)))
            {
                return null!;
            }
            return id.ToString("D");
        }

        /// <summary>
        /// Finds the role who has the specified ID as an asynchronous operation.
        /// </summary>
        /// <param name="id">The role ID to look for.</param>
        /// <param name="archiveId">The archie id againts whitch should be checked.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>A <see cref="Task{TResult}"/> that result of the look up.</returns>
        public virtual Task<ApplicationRole> FindByIdAsync(Guid id, int? archiveId, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            //var roleId = ConvertIdFromString(id);
            var roleId = id;
            return Roles.FirstOrDefaultAsync(u => u.Id.Equals(roleId) && u.ArchiveId.Equals(archiveId), cancellationToken)!;
        }

        /// <summary>
        /// Finds the role who has the specified ID as an asynchronous operation.
        /// </summary>
        /// <param name="id">The role ID to look for.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>A <see cref="Task{TResult}"/> that result of the look up.</returns>
        public virtual Task<ApplicationRole> FindByIdAsync(Guid id, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            var roleId = id;
            return Roles.FirstOrDefaultAsync(u => u.Id.Equals(roleId), cancellationToken)!;
        }

        public virtual Task<ApplicationRole> FindByIdAsync(string id, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            var roleId = ConvertIdFromString(id);
            return Roles.FirstOrDefaultAsync(u => u.Id.Equals(roleId), cancellationToken)!;
        }

        /// <summary>
        /// Finds the role who has the specified normalized name as an asynchronous operation.
        /// </summary>
        /// <param name="normalizedName">The normalized role name to look for.</param>
        /// <param name="archiveId">The archive id againts whitch should be checked.</param>
        /// <param name="cancellationToken">The <see cref="CancellationToken"/> used to propagate notifications that the operation should be canceled.</param>
        /// <returns>A <see cref="Task{TResult}"/> that result of the look up.</returns>
        public virtual Task<ApplicationRole> FindByNameAsync(string normalizedName, int? archiveId, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            return Roles.FirstOrDefaultAsync(r => r.NormalizedName == normalizedName && r.ArchiveId == archiveId, cancellationToken)!;
        }

        public virtual Task<ApplicationRole> FindByNameAsync(string normalizedName, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            return Roles.FirstOrDefaultAsync(r => r.NormalizedName == normalizedName, cancellationToken)!;
        }

        public virtual Task<string> GetNormalizedRoleNameAsync(ApplicationRole role, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (role == null)
            {
                throw new ArgumentNullException(nameof(role));
            }
            return Task.FromResult(role.NormalizedName);
        }

        public virtual Task SetNormalizedRoleNameAsync(ApplicationRole role, string normalizedName, CancellationToken cancellationToken = default(CancellationToken))
        {
            cancellationToken.ThrowIfCancellationRequested();
            ThrowIfDisposed();
            if (role == null)
            {
                throw new ArgumentNullException(nameof(role));
            }
            role.NormalizedName = normalizedName;
            return Task.CompletedTask;
        }

        protected void ThrowIfDisposed()
        {
            if (_disposed)
            {
                throw new ObjectDisposedException(GetType().Name);
            }
        }

        public void Dispose() => _disposed = true;

        public virtual async Task<IList<Claim>> GetClaimsAsync(ApplicationRole role, CancellationToken cancellationToken = default(CancellationToken))
        {
            ThrowIfDisposed();
            if (role == null)
            {
                throw new ArgumentNullException(nameof(role));
            }

            return await RoleClaims.Where(rc => rc.RoleId.Equals(role.Id)).Select(c => new Claim(c.ClaimType, c.ClaimValue)).ToListAsync(cancellationToken);
        }

        public virtual Task AddClaimAsync(ApplicationRole role, Claim claim, CancellationToken cancellationToken = default(CancellationToken))
        {
            ThrowIfDisposed();
            if (role == null)
            {
                throw new ArgumentNullException(nameof(role));
            }
            if (claim == null)
            {
                throw new ArgumentNullException(nameof(claim));
            }

            RoleClaims.Add(CreateRoleClaim(role, claim));
            return Task.FromResult(false);
        }

        public virtual async Task RemoveClaimAsync(ApplicationRole role, Claim claim, CancellationToken cancellationToken = default(CancellationToken))
        {
            ThrowIfDisposed();
            if (role == null)
            {
                throw new ArgumentNullException(nameof(role));
            }
            if (claim == null)
            {
                throw new ArgumentNullException(nameof(claim));
            }
            var claims = await RoleClaims.Where(rc => rc.RoleId.Equals(role.Id) && rc.ClaimValue == claim.Value && rc.ClaimType == claim.Type).ToListAsync(cancellationToken);
            foreach (var c in claims)
            {
                RoleClaims.Remove(c);
            }
        }

        public virtual IQueryable<ApplicationRole> Roles => Context.Set<ApplicationRole>();

        private DbSet<ApplicationRoleClaim> RoleClaims { get { return Context.Set<ApplicationRoleClaim>(); } }

        protected virtual ApplicationRoleClaim CreateRoleClaim(ApplicationRole role, Claim claim)
            => new ApplicationRoleClaim { RoleId = role.Id, ClaimType = claim.Type, ClaimValue = claim.Value };
    }
}
