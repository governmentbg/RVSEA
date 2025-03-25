using DAA.Data;
using DAA.Data.Files;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Extensions.Data
{
    public class ExtendedFileContent : FileContext
    {
        private readonly ArchivingContextConnection _dbContextConnection;

        public ExtendedFileContent(ArchivingContextConnection dbContextConnection)
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
