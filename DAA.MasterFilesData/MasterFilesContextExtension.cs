using DAA.Data;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.MasterFilesData
{
    public class MasterFilesContextExtension : MasterFilesContext
    {
        private readonly ArchivingContextConnection _dbContextConnection;

        public MasterFilesContextExtension(ArchivingContextConnection dbContextConnection)
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
