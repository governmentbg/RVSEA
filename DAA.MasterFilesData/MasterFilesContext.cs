using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace DAA.MasterFilesData
{
    public partial class MasterFilesContext : DbContext
    {
        public MasterFilesContext()
        {
        }

        public MasterFilesContext(DbContextOptions<MasterFilesContext> options)
            : base(options)
        {
        }

        public virtual DbSet<File> Files { get; set; } = null!;

        // Unable to generate entity type for table 'dbo.FileContent' since its primary key could not be scaffolded. Please see the warning messages.

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlServer("name=MasterFilesConnection");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<File>(entity =>
            {
                entity.Property(e => e.ContentType).HasMaxLength(100);

                entity.Property(e => e.FileName).HasMaxLength(500);

                entity.Property(e => e.FileType).HasMaxLength(10);
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
