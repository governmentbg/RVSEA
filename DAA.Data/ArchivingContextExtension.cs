using DAA.Shared.Identity;
using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    public class ArchivingContextExtension : ArchivingContext
    {
        private readonly ArchivingContextConnection _dbContextConnection;

        public ArchivingContextExtension(
            ArchivingContextConnection dbContextConnection,
            DbContextOptions<ArchivingContext> options,
            IUserInfo userInfo)
            : base(options, userInfo)
        {
            _dbContextConnection = dbContextConnection;
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            //base.OnConfiguring(optionsBuilder); НЕ трябва да се вика!

            optionsBuilder.UseSqlServer(_dbContextConnection.Connection);
        }
    }
}
