using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace DAA.Data.Files
{
    public partial class BufferFileContext : DbContext
    {
        public BufferFileContext()
        {
        }

        public BufferFileContext(DbContextOptions<BufferFileContext> options)
            : base(options)
        {
        }

        public virtual DbSet<VFileContent> VFileContents { get; set; } = null!;

        // Unable to generate entity type for table 'dbo.FileContent' since its primary key could not be scaffolded. Please see the warning messages.

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlServer("name=BufferFilesConnection");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<VFileContent>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_FileContent");

                entity.Property(e => e.CachedFileSize).HasColumnName("cached_file_size");

                entity.Property(e => e.CreationTime).HasColumnName("creation_time");

                entity.Property(e => e.FileStream).HasColumnName("file_stream");

                entity.Property(e => e.FileType)
                    .HasMaxLength(255)
                    .HasColumnName("file_type");

                entity.Property(e => e.IsArchive).HasColumnName("is_archive");

                entity.Property(e => e.IsDirectory).HasColumnName("is_directory");

                entity.Property(e => e.IsHidden).HasColumnName("is_hidden");

                entity.Property(e => e.IsOffline).HasColumnName("is_offline");

                entity.Property(e => e.IsReadonly).HasColumnName("is_readonly");

                entity.Property(e => e.IsSystem).HasColumnName("is_system");

                entity.Property(e => e.IsTemporary).HasColumnName("is_temporary");

                entity.Property(e => e.LastAccessTime).HasColumnName("last_access_time");

                entity.Property(e => e.LastWriteTime).HasColumnName("last_write_time");

                entity.Property(e => e.Name)
                    .HasMaxLength(255)
                    .HasColumnName("name");

                entity.Property(e => e.StreamId).HasColumnName("stream_id");

                entity.Property(e => e.UncPath).HasColumnName("unc_path");
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
