using DAA.Data;
using DAA.Shared.Identity;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Extensions.Data
{
    public class ExtendedArchivingContext : ArchivingContext
    {
        private readonly ArchivingContextConnection _dbContextConnection;

        public ExtendedArchivingContext(
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
