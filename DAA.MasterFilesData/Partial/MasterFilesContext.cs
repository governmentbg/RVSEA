using DAA.Shared.Data;
using DAA.Shared.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;

namespace DAA.MasterFilesData
{
    public partial class MasterFilesContext
    {
        private readonly IUserInfo _userInfo;

        public MasterFilesContext(DbContextOptions<MasterFilesContext> options,
            IUserInfo userInfo)
            : base(options)
        {
            _userInfo = userInfo;
        }

        public virtual async Task<int> SaveAsync(CancellationToken cancellationToken = default)
        {
            if (_userInfo != null && _userInfo.CurrentUserId != Guid.Empty)
            {
                DateTime utcNow = DateTime.UtcNow;

                foreach (EntityEntry<ICreatable> entry in ChangeTracker.Entries<ICreatable>())
                {
                    if (entry.State == EntityState.Added)
                    {
                        entry.Entity.CreatedBy = _userInfo.CurrentUserId;
                        entry.Entity.CreatedOn = utcNow;
                    }
                }

                foreach (EntityEntry<IEditable> entry in ChangeTracker.Entries<IEditable>())
                {
                    if (entry.State == EntityState.Modified)
                    {
                        entry.Entity.UpdatedBy = _userInfo.CurrentUserId;
                        entry.Entity.UpdatedOn = utcNow;
                    }
                }

                foreach (EntityEntry<IDeletable> entry in ChangeTracker.Entries<IDeletable>())
                {
                    if (entry.State == EntityState.Deleted || entry.Entity.Deleted)
                    {
                        entry.Entity.DeletedBy = _userInfo.CurrentUserId;
                        entry.Entity.DeletedOn = utcNow;
                    }
                }
            }

            var rowsAffected = await base.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

            return rowsAffected;
        }

        public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            return SaveAsync(cancellationToken);
        }        
    }

}
