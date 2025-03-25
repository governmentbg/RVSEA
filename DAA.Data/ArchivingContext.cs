using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace DAA.Data
{
    public partial class ArchivingContext : DbContext
    {
        public ArchivingContext()
        {
        }

        public ArchivingContext(DbContextOptions<ArchivingContext> options)
            : base(options)
        {
        }

        public virtual DbSet<AggregatedCounter> AggregatedCounters { get; set; } = null!;
        public virtual DbSet<ArchivalEntity> ArchivalEntities { get; set; } = null!;
        public virtual DbSet<ArchivalEntityDescriptionLevel> ArchivalEntityDescriptionLevels { get; set; } = null!;
        public virtual DbSet<ArchivalEntityDraft> ArchivalEntityDrafts { get; set; } = null!;
        public virtual DbSet<Archive> Archives { get; set; } = null!;
        public virtual DbSet<ArchivesSpecificOrder> ArchivesSpecificOrders { get; set; } = null!;
        public virtual DbSet<AspNetRole> AspNetRoles { get; set; } = null!;
        public virtual DbSet<AspNetRoleClaim> AspNetRoleClaims { get; set; } = null!;
        public virtual DbSet<AspNetUser> AspNetUsers { get; set; } = null!;
        public virtual DbSet<AspNetUserArchive> AspNetUserArchives { get; set; } = null!;
        public virtual DbSet<AspNetUserClaim> AspNetUserClaims { get; set; } = null!;
        public virtual DbSet<AspNetUserLogin> AspNetUserLogins { get; set; } = null!;
        public virtual DbSet<AspNetUserProfile> AspNetUserProfiles { get; set; } = null!;
        public virtual DbSet<AspNetUserToken> AspNetUserTokens { get; set; } = null!;
        public virtual DbSet<AuditEntry> AuditEntries { get; set; } = null!;
        public virtual DbSet<AuditEntryProperty> AuditEntryProperties { get; set; } = null!;
        public virtual DbSet<AvailabilityStatus> AvailabilityStatuses { get; set; } = null!;
        public virtual DbSet<Comment> Comments { get; set; } = null!;
        public virtual DbSet<CommissionReportFile> CommissionReportFiles { get; set; } = null!;
        public virtual DbSet<Counter> Counters { get; set; } = null!;
        public virtual DbSet<DigitalObject> DigitalObjects { get; set; } = null!;
        public virtual DbSet<DigitalObjectDraft> DigitalObjectDrafts { get; set; } = null!;
        public virtual DbSet<DigitalObjectReview> DigitalObjectReviews { get; set; } = null!;
        public virtual DbSet<Document> Documents { get; set; } = null!;
        public virtual DbSet<DocumentDescriptionLevel> DocumentDescriptionLevels { get; set; } = null!;
        public virtual DbSet<DocumentDraft> DocumentDrafts { get; set; } = null!;
        public virtual DbSet<EdocsCollectingApplication> EdocsCollectingApplications { get; set; } = null!;
        public virtual DbSet<EdocsCollectingApplicationStatus> EdocsCollectingApplicationStatuses { get; set; } = null!;
        public virtual DbSet<EdocsCollectingApplicationType> EdocsCollectingApplicationTypes { get; set; } = null!;
        public virtual DbSet<EdocsCollectingDocumentsOriginType> EdocsCollectingDocumentsOriginTypes { get; set; } = null!;
        public virtual DbSet<Epkreport> Epkreports { get; set; } = null!;
        public virtual DbSet<File> Files { get; set; } = null!;
        public virtual DbSet<FileUploadQueue> FileUploadQueues { get; set; } = null!;
        public virtual DbSet<Film> Films { get; set; } = null!;
        public virtual DbSet<FilmCard> FilmCards { get; set; } = null!;
        public virtual DbSet<FilmCardDocument> FilmCardDocuments { get; set; } = null!;
        public virtual DbSet<FilmCardDraft> FilmCardDrafts { get; set; } = null!;
        public virtual DbSet<FilmDescriptionLevel> FilmDescriptionLevels { get; set; } = null!;
        public virtual DbSet<FilmDocumentType> FilmDocumentTypes { get; set; } = null!;
        public virtual DbSet<FilmDraft> FilmDrafts { get; set; } = null!;
        public virtual DbSet<FilmPackage> FilmPackages { get; set; } = null!;
        public virtual DbSet<FilmPackageDocument> FilmPackageDocuments { get; set; } = null!;
        public virtual DbSet<FilmReview> FilmReviews { get; set; } = null!;
        public virtual DbSet<Fund> Funds { get; set; } = null!;
        public virtual DbSet<FundArray> FundArrays { get; set; } = null!;
        public virtual DbSet<FundDescriptionLevel> FundDescriptionLevels { get; set; } = null!;
        public virtual DbSet<FundDraft> FundDrafts { get; set; } = null!;
        public virtual DbSet<FundReconstruction> FundReconstructions { get; set; } = null!;
        public virtual DbSet<FundType> FundTypes { get; set; } = null!;
        public virtual DbSet<Hash> Hashes { get; set; } = null!;
        public virtual DbSet<InformationItem> InformationItems { get; set; } = null!;
        public virtual DbSet<Inventory> Inventories { get; set; } = null!;
        public virtual DbSet<InventoryArray> InventoryArrays { get; set; } = null!;
        public virtual DbSet<InventoryDescriptionLevel> InventoryDescriptionLevels { get; set; } = null!;
        public virtual DbSet<InventoryDraft> InventoryDrafts { get; set; } = null!;
        public virtual DbSet<InventoryRawToNormal> InventoryRawToNormals { get; set; } = null!;
        public virtual DbSet<Job> Jobs { get; set; } = null!;
        public virtual DbSet<JobParameter> JobParameters { get; set; } = null!;
        public virtual DbSet<JobQueue> JobQueues { get; set; } = null!;
        public virtual DbSet<List> Lists { get; set; } = null!;
        public virtual DbSet<Nomenclature> Nomenclatures { get; set; } = null!;
        public virtual DbSet<NomenclatureCode> NomenclatureCodes { get; set; } = null!;
        public virtual DbSet<NomenclatureValue> NomenclatureValues { get; set; } = null!;
        public virtual DbSet<Notification> Notifications { get; set; } = null!;
        public virtual DbSet<NotificationEvent> NotificationEvents { get; set; } = null!;
        public virtual DbSet<NotificationTemplate> NotificationTemplates { get; set; } = null!;
        public virtual DbSet<NotificationType> NotificationTypes { get; set; } = null!;
        public virtual DbSet<Package> Packages { get; set; } = null!;
        public virtual DbSet<PackageAdocsTemplate> PackageAdocsTemplates { get; set; } = null!;
        public virtual DbSet<PackageDocument> PackageDocuments { get; set; } = null!;
        public virtual DbSet<Process> Processes { get; set; } = null!;
        public virtual DbSet<ProcessRelatedStep> ProcessRelatedSteps { get; set; } = null!;
        public virtual DbSet<ProcessStep> ProcessSteps { get; set; } = null!;
        public virtual DbSet<ProcessTimeline> ProcessTimelines { get; set; } = null!;
        public virtual DbSet<ProcessType> ProcessTypes { get; set; } = null!;
        public virtual DbSet<ProcessTypeLevel> ProcessTypeLevels { get; set; } = null!;
        public virtual DbSet<ReportResultType> ReportResultTypes { get; set; } = null!;
        public virtual DbSet<Schema> Schemas { get; set; } = null!;
        public virtual DbSet<Server> Servers { get; set; } = null!;
        public virtual DbSet<Session> Sessions { get; set; } = null!;
        public virtual DbSet<SessionAgendaStandpoint> SessionAgendaStandpoints { get; set; } = null!;
        public virtual DbSet<SessionAgendum> SessionAgenda { get; set; } = null!;
        public virtual DbSet<SessionDecision> SessionDecisions { get; set; } = null!;
        public virtual DbSet<SessionMinutesOfMeeting> SessionMinutesOfMeetings { get; set; } = null!;
        public virtual DbSet<SessionType> SessionTypes { get; set; } = null!;
        public virtual DbSet<Set> Sets { get; set; } = null!;
        public virtual DbSet<SignatureRequest> SignatureRequests { get; set; } = null!;
        public virtual DbSet<State> States { get; set; } = null!;
        public virtual DbSet<Status> Statuses { get; set; } = null!;
        public virtual DbSet<Task> Tasks { get; set; } = null!;
        public virtual DbSet<TaskStatus> TaskStatuses { get; set; } = null!;
        public virtual DbSet<TaskTemplate> TaskTemplates { get; set; } = null!;
        public virtual DbSet<UserReview> UserReviews { get; set; } = null!;
        public virtual DbSet<VApiPublicDigitalObject> VApiPublicDigitalObjects { get; set; } = null!;
        public virtual DbSet<VArchivalEntity> VArchivalEntities { get; set; } = null!;
        public virtual DbSet<VArchivalEntitySizeInfo> VArchivalEntitySizeInfos { get; set; } = null!;
        public virtual DbSet<VAuditLog> VAuditLogs { get; set; } = null!;
        public virtual DbSet<VAuditLogsWithDetail> VAuditLogsWithDetails { get; set; } = null!;
        public virtual DbSet<VDigitalObject> VDigitalObjects { get; set; } = null!;
        public virtual DbSet<VDigitalObjectSizeInfo> VDigitalObjectSizeInfos { get; set; } = null!;
        public virtual DbSet<VDocument> VDocuments { get; set; } = null!;
        public virtual DbSet<VDocumentSizeInfo> VDocumentSizeInfos { get; set; } = null!;
        public virtual DbSet<VFilm> VFilms { get; set; } = null!;
        public virtual DbSet<VFilmCard> VFilmCards { get; set; } = null!;
        public virtual DbSet<VFilmDocument> VFilmDocuments { get; set; } = null!;
        public virtual DbSet<VFilmReview> VFilmReviews { get; set; } = null!;
        public virtual DbSet<VFund> VFunds { get; set; } = null!;
        public virtual DbSet<VFundReconstruction> VFundReconstructions { get; set; } = null!;
        public virtual DbSet<VFundSizeInfo> VFundSizeInfos { get; set; } = null!;
        public virtual DbSet<VInventory> VInventories { get; set; } = null!;
        public virtual DbSet<VInventorySizeInfo> VInventorySizeInfos { get; set; } = null!;
        public virtual DbSet<VPublicArchivalEntity> VPublicArchivalEntities { get; set; } = null!;
        public virtual DbSet<VPublicDigitalObject> VPublicDigitalObjects { get; set; } = null!;
        public virtual DbSet<VPublicDocument> VPublicDocuments { get; set; } = null!;
        public virtual DbSet<VPublicFilm> VPublicFilms { get; set; } = null!;
        public virtual DbSet<VPublicFilmCard> VPublicFilmCards { get; set; } = null!;
        public virtual DbSet<VPublicFund> VPublicFunds { get; set; } = null!;
        public virtual DbSet<VPublicInventory> VPublicInventories { get; set; } = null!;
        public virtual DbSet<VTask> VTasks { get; set; } = null!;
        public virtual DbSet<Version> Versions { get; set; } = null!;

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlServer("name=DefaultConnection");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<AggregatedCounter>(entity =>
            {
                entity.HasKey(e => e.Key)
                    .HasName("PK_HangFire_CounterAggregated");

                entity.ToTable("AggregatedCounter", "HangFire");

                entity.HasIndex(e => e.ExpireAt, "IX_HangFire_AggregatedCounter_ExpireAt")
                    .HasFilter("([ExpireAt] IS NOT NULL)");

                entity.Property(e => e.Key).HasMaxLength(100);

                entity.Property(e => e.ExpireAt).HasColumnType("datetime");
            });

            modelBuilder.Entity<ArchivalEntity>(entity =>
            {
                entity.HasIndex(e => e.SystemIdentifier, "UI_ArchivalEntitySystemIdentifier")
                    .IsUnique();

                entity.Property(e => e.ApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.ClassificationSchemeIndex).HasMaxLength(250);

                entity.Property(e => e.DescriptionAuthor).HasMaxLength(250);

                entity.Property(e => e.DescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.Number).HasMaxLength(50);

                entity.Property(e => e.NumberArray).HasMaxLength(250);

                entity.Property(e => e.OtherMetrics).HasMaxLength(256);

                entity.Property(e => e.Scaling).HasMaxLength(256);

                entity.Property(e => e.SizeCm).HasMaxLength(256);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.ArchivalEntities)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_ArchivalEntities_Archive");

                entity.HasOne(d => d.AvailabilityStatusCodeNavigation)
                    .WithMany(p => p.ArchivalEntities)
                    .HasForeignKey(d => d.AvailabilityStatusCode)
                    .HasConstraintName("FK_ArchivalEntities_AvailabilityStatus");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.ArchivalEntityCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_ArchivalEntities_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.ArchivalEntityDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_ArchivalEntities_DeletedBy");

                entity.HasOne(d => d.DescriptionLevelCodeNavigation)
                    .WithMany(p => p.ArchivalEntities)
                    .HasForeignKey(d => d.DescriptionLevelCode)
                    .HasConstraintName("FK_ArchivalEntities_DescriptionLevel");

                entity.HasOne(d => d.FundSystemIdentifierNavigation)
                    .WithMany(p => p.ArchivalEntities)
                    .HasPrincipalKey(p => p.SystemIdentifier)
                    .HasForeignKey(d => d.FundSystemIdentifier)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_ArchivalEntities_Fund");

                entity.HasOne(d => d.InventorySystemIdentifierNavigation)
                    .WithMany(p => p.ArchivalEntities)
                    .HasPrincipalKey(p => p.SystemIdentifier)
                    .HasForeignKey(d => d.InventorySystemIdentifier)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_ArchivalEntities_Inventory");

                entity.HasOne(d => d.StatusCodeNavigation)
                    .WithMany(p => p.ArchivalEntities)
                    .HasForeignKey(d => d.StatusCode)
                    .HasConstraintName("FK_ArchivalEntities_Status");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.ArchivalEntityUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_ArchivalEntities_UpdatedBy");
            });

            modelBuilder.Entity<ArchivalEntityDescriptionLevel>(entity =>
            {
                entity.HasKey(e => e.Code)
                    .HasName("PK_EntityDescriptionLevel");

                entity.ToTable("ArchivalEntityDescriptionLevel", "N");

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.Text).HasMaxLength(256);
            });

            modelBuilder.Entity<ArchivalEntityDraft>(entity =>
            {
                entity.HasIndex(e => e.SystemIdentifier, "UI_IsCurrentDraft")
                    .IsUnique()
                    .HasFilter("([IsCurrent]=(1))");

                entity.Property(e => e.ApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.ClassificationSchemeIndex).HasMaxLength(250);

                entity.Property(e => e.DescriptionAuthor).HasMaxLength(250);

                entity.Property(e => e.DescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.Number).HasMaxLength(50);

                entity.Property(e => e.NumberArray).HasMaxLength(250);

                entity.Property(e => e.OtherMetrics).HasMaxLength(256);

                entity.Property(e => e.Scaling).HasMaxLength(256);

                entity.Property(e => e.SizeCm).HasMaxLength(256);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.WorkflowStepTypeCode).HasMaxLength(50);

                entity.Property(e => e.WorkflowTypeCode).HasMaxLength(50);

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.ArchivalEntityDrafts)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_ArchivalEntityDrafts_Archive");

                entity.HasOne(d => d.AvailabilityStatusCodeNavigation)
                    .WithMany(p => p.ArchivalEntityDrafts)
                    .HasForeignKey(d => d.AvailabilityStatusCode)
                    .HasConstraintName("FK_ArchivalEntityDrafts_AvailabilityStatus");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.ArchivalEntityDraftCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_ArchivalEntityDrafts_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.ArchivalEntityDraftDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_ArchivalEntityDrafts_DeletedBy");

                entity.HasOne(d => d.DescriptionLevelCodeNavigation)
                    .WithMany(p => p.ArchivalEntityDrafts)
                    .HasForeignKey(d => d.DescriptionLevelCode)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_ArchivalEntityDrafts_DescriptionLevel");

                entity.HasOne(d => d.FundDraft)
                    .WithMany(p => p.ArchivalEntityDrafts)
                    .HasForeignKey(d => d.FundDraftId)
                    .HasConstraintName("FK_ArchivalEntityDrafts_FundDraft");

                entity.HasOne(d => d.InventoryDraft)
                    .WithMany(p => p.ArchivalEntityDrafts)
                    .HasForeignKey(d => d.InventoryDraftId)
                    .HasConstraintName("FK_ArchivalEntityDrafts_InventoryDraft");

                entity.HasOne(d => d.StatusCodeNavigation)
                    .WithMany(p => p.ArchivalEntityDrafts)
                    .HasForeignKey(d => d.StatusCode)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_ArchivalEntityDrafts_Status");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.ArchivalEntityDraftUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_ArchivalEntityDrafts_UpdatedBy");
            });

            modelBuilder.Entity<Archive>(entity =>
            {
                entity.HasIndex(e => e.Code, "UI_ArchiveCode")
                    .IsUnique();

                entity.Property(e => e.Name).HasMaxLength(255);

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.ArchiveCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_Archives_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.ArchiveDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_Archives_DeletedBy");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.ArchiveUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_Archives_UpdatedBy");
            });

            modelBuilder.Entity<ArchivesSpecificOrder>(entity =>
            {
                entity.ToTable("ArchivesSpecificOrder");

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.ArchivesSpecificOrders)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_ArchivesSpecificOrder_ArchiveId");
            });

            modelBuilder.Entity<AspNetRole>(entity =>
            {
                entity.HasIndex(e => new { e.ArchiveId, e.NormalizedName }, "RoleNameIndex")
                    .IsUnique()
                    .HasFilter("([NormalizedName] IS NOT NULL)");

                entity.Property(e => e.Id).ValueGeneratedNever();

                entity.Property(e => e.Abbreviation).HasMaxLength(5);

                entity.Property(e => e.Name).HasMaxLength(256);

                entity.Property(e => e.NormalizedName).HasMaxLength(256);

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.AspNetRoles)
                    .HasForeignKey(d => d.ArchiveId)
                    .HasConstraintName("FK_AspNetRoles_Archive");
            });

            modelBuilder.Entity<AspNetRoleClaim>(entity =>
            {
                entity.HasIndex(e => e.RoleId, "IX_AspNetRoleClaims_RoleId");

                entity.HasOne(d => d.Role)
                    .WithMany(p => p.AspNetRoleClaims)
                    .HasForeignKey(d => d.RoleId);
            });

            modelBuilder.Entity<AspNetUser>(entity =>
            {
                entity.HasIndex(e => e.NormalizedEmail, "EmailIndex");

                entity.HasIndex(e => e.NormalizedUserName, "UserNameIndex")
                    .IsUnique()
                    .HasFilter("([NormalizedUserName] IS NOT NULL)");

                entity.Property(e => e.Id).ValueGeneratedNever();

                entity.Property(e => e.AuthenticationType).HasMaxLength(20);

                entity.Property(e => e.CertificateName).HasMaxLength(256);

                entity.Property(e => e.CertificateUniqueIdentifier).HasMaxLength(256);

                entity.Property(e => e.CreatedOn).HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Email).HasMaxLength(256);

                entity.Property(e => e.NormalizedEmail).HasMaxLength(256);

                entity.Property(e => e.NormalizedUserName).HasMaxLength(256);

                entity.Property(e => e.UserName).HasMaxLength(256);

                entity.Property(e => e.UserType)
                    .HasMaxLength(3)
                    .IsFixedLength();

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.InverseCreatedByNavigation)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_AspNetUsers_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.InverseDeletedByNavigation)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_AspNetUsers_DeletedBy");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.InverseUpdatedByNavigation)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_AspNetUsers_UpdatedBy");

                entity.HasMany(d => d.Roles)
                    .WithMany(p => p.Users)
                    .UsingEntity<Dictionary<string, object>>(
                        "AspNetUserRole",
                        l => l.HasOne<AspNetRole>().WithMany().HasForeignKey("RoleId"),
                        r => r.HasOne<AspNetUser>().WithMany().HasForeignKey("UserId"),
                        j =>
                        {
                            j.HasKey("UserId", "RoleId");

                            j.ToTable("AspNetUserRoles");

                            j.HasIndex(new[] { "RoleId" }, "IX_AspNetUserRoles_RoleId");
                        });
            });

            modelBuilder.Entity<AspNetUserArchive>(entity =>
            {
                entity.HasKey(e => new { e.ArchiveId, e.UserId });

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.AspNetUserArchives)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_AspNetUserArchives_Archive");

                entity.HasOne(d => d.User)
                    .WithMany(p => p.AspNetUserArchives)
                    .HasForeignKey(d => d.UserId)
                    .HasConstraintName("FK_AspNetUserArchives_User");
            });

            modelBuilder.Entity<AspNetUserClaim>(entity =>
            {
                entity.HasIndex(e => e.UserId, "IX_AspNetUserClaims_UserId");

                entity.HasOne(d => d.User)
                    .WithMany(p => p.AspNetUserClaims)
                    .HasForeignKey(d => d.UserId);
            });

            modelBuilder.Entity<AspNetUserLogin>(entity =>
            {
                entity.HasKey(e => new { e.LoginProvider, e.ProviderKey });

                entity.HasIndex(e => e.UserId, "IX_AspNetUserLogins_UserId");

                entity.Property(e => e.LoginProvider).HasMaxLength(128);

                entity.Property(e => e.ProviderKey).HasMaxLength(256);

                entity.HasOne(d => d.User)
                    .WithMany(p => p.AspNetUserLogins)
                    .HasForeignKey(d => d.UserId);
            });

            modelBuilder.Entity<AspNetUserProfile>(entity =>
            {
                entity.Property(e => e.CreatedOn).HasDefaultValueSql("(getdate())");

                entity.Property(e => e.DisplayName)
                    .HasMaxLength(770)
                    .HasComputedColumnSql("(concat([FirstName],' ',[Surname],' ',[LastName]))", true);

                entity.Property(e => e.EntityType).HasMaxLength(20);

                entity.Property(e => e.FirstName).HasMaxLength(256);

                entity.Property(e => e.LastName).HasMaxLength(256);

                entity.Property(e => e.LibraryCardNumber).HasMaxLength(256);

                entity.Property(e => e.ProfileType)
                    .HasMaxLength(3)
                    .IsFixedLength();

                entity.Property(e => e.Surname).HasMaxLength(256);

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.AspNetUserProfileCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_AspNetUserProfiles_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.AspNetUserProfileDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_AspNetUserProfiles_DeletedBy");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.AspNetUserProfileUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_AspNetUserProfiles_UpdatedBy");

                entity.HasOne(d => d.User)
                    .WithMany(p => p.AspNetUserProfileUsers)
                    .HasForeignKey(d => d.UserId)
                    .HasConstraintName("FK_AspNetUserProfiles_UserId");
            });

            modelBuilder.Entity<AspNetUserToken>(entity =>
            {
                entity.HasKey(e => new { e.UserId, e.LoginProvider, e.Name });

                entity.Property(e => e.LoginProvider).HasMaxLength(128);

                entity.Property(e => e.Name).HasMaxLength(128);

                entity.HasOne(d => d.User)
                    .WithMany(p => p.AspNetUserTokens)
                    .HasForeignKey(d => d.UserId);
            });

            modelBuilder.Entity<AuditEntry>(entity =>
            {
                entity.ToTable("AuditEntries", "A");

                entity.Property(e => e.AuditEntryId).HasColumnName("AuditEntryID");

                entity.Property(e => e.CorrelationId).HasMaxLength(36);

                entity.Property(e => e.CreatedByUsername).HasMaxLength(256);

                entity.Property(e => e.CreatedOn).HasDefaultValueSql("(getutcdate())");

                entity.Property(e => e.EntitySetName).HasMaxLength(255);

                entity.Property(e => e.EntityTypeName).HasMaxLength(255);

                entity.Property(e => e.Ip).HasMaxLength(40);

                entity.Property(e => e.StateName).HasMaxLength(255);

                entity.Property(e => e.UserAgent).HasMaxLength(255);

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.AuditEntries)
                    .HasForeignKey(d => d.CreatedBy)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_AuditEntries_CreatedBy");
            });

            modelBuilder.Entity<AuditEntryProperty>(entity =>
            {
                entity.ToTable("AuditEntryProperties", "A");

                entity.Property(e => e.AuditEntryPropertyId).HasColumnName("AuditEntryPropertyID");

                entity.Property(e => e.AuditEntryId).HasColumnName("AuditEntryID");

                entity.Property(e => e.PropertyName).HasMaxLength(255);

                entity.Property(e => e.RelationName).HasMaxLength(255);

                entity.HasOne(d => d.AuditEntry)
                    .WithMany(p => p.AuditEntryProperties)
                    .HasForeignKey(d => d.AuditEntryId)
                    .HasConstraintName("FK_AuditEntryProperties_AuditEntry");
            });

            modelBuilder.Entity<AvailabilityStatus>(entity =>
            {
                entity.HasKey(e => e.Code);

                entity.ToTable("AvailabilityStatus", "N");

                entity.Property(e => e.Code).ValueGeneratedNever();

                entity.Property(e => e.Text).HasMaxLength(256);
            });

            modelBuilder.Entity<Comment>(entity =>
            {
                entity.Property(e => e.IsDraft)
                    .IsRequired()
                    .HasDefaultValueSql("((1))");

                entity.Property(e => e.UserName).HasMaxLength(255);

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.CommentCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK__Comments__Create__7DB89C09");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.CommentDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK__Comments__Delete__7FA0E47B");

                entity.HasOne(d => d.Process)
                    .WithMany(p => p.Comments)
                    .HasForeignKey(d => d.ProcessId)
                    .HasConstraintName("FK__Comments__Proces__7CC477D0");

                entity.HasOne(d => d.ProcessStep)
                    .WithMany(p => p.Comments)
                    .HasForeignKey(d => d.ProcessStepId)
                    .HasConstraintName("FK__Comments__Proces__064DE20A");

                entity.HasOne(d => d.SessionAgendaStandpoint)
                    .WithMany(p => p.Comments)
                    .HasForeignKey(d => d.SessionAgendaStandpointId)
                    .HasConstraintName("FK_Comments_SessionAgendaStandpoint");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.CommentUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK__Comments__Update__7EACC042");
            });

            modelBuilder.Entity<CommissionReportFile>(entity =>
            {
                entity.Property(e => e.FileType).HasMaxLength(50);

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.CommissionReportFileCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_ReportFiles_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.CommissionReportFileDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_ReportFiles_DeletedBy");

                entity.HasOne(d => d.Report)
                    .WithMany(p => p.CommissionReportFiles)
                    .HasForeignKey(d => d.ReportId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_ReportFiles_Report");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.CommissionReportFileUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_ReportFiles_UpdatedBy");
            });

            modelBuilder.Entity<Counter>(entity =>
            {
                entity.HasNoKey();

                entity.ToTable("Counter", "HangFire");

                entity.HasIndex(e => e.Key, "CX_HangFire_Counter")
                    .IsClustered();

                entity.Property(e => e.ExpireAt).HasColumnType("datetime");

                entity.Property(e => e.Key).HasMaxLength(100);
            });

            modelBuilder.Entity<DigitalObject>(entity =>
            {
                entity.HasIndex(e => e.SystemIdentifier, "UI_DigitalObjectSystemIdentifier")
                    .IsUnique();

                entity.Property(e => e.AntivirusCheckInfo).HasMaxLength(2000);

                entity.Property(e => e.ErrorMessage).HasMaxLength(2000);

                entity.Property(e => e.FileInfo).HasMaxLength(2000);

                entity.Property(e => e.FileType).HasMaxLength(50);

                entity.Property(e => e.HashCode).HasMaxLength(100);

                entity.Property(e => e.Name).HasMaxLength(255);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.HasOne(d => d.ArchivalEntitySystemIdentifierNavigation)
                    .WithMany(p => p.DigitalObjects)
                    .HasPrincipalKey(p => p.SystemIdentifier)
                    .HasForeignKey(d => d.ArchivalEntitySystemIdentifier)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_DigitalObjects_ArchivalEntity");

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.DigitalObjects)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_DigitalObjects_Archive");

                entity.HasOne(d => d.AvailabilityStatusCodeNavigation)
                    .WithMany(p => p.DigitalObjects)
                    .HasForeignKey(d => d.AvailabilityStatusCode)
                    .HasConstraintName("FK_DigitalObjects_AvailabilityStatus");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.DigitalObjectCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_DigitalObjects_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.DigitalObjectDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_DigitalObjects_DeletedBy");

                entity.HasOne(d => d.DocumentSystemIdentifierNavigation)
                    .WithMany(p => p.DigitalObjects)
                    .HasPrincipalKey(p => p.SystemIdentifier)
                    .HasForeignKey(d => d.DocumentSystemIdentifier)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_DigitalObjects_Document");

                entity.HasOne(d => d.FundSystemIdentifierNavigation)
                    .WithMany(p => p.DigitalObjects)
                    .HasPrincipalKey(p => p.SystemIdentifier)
                    .HasForeignKey(d => d.FundSystemIdentifier)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_DigitalObjects_Fund");

                entity.HasOne(d => d.InventorySystemIdentifierNavigation)
                    .WithMany(p => p.DigitalObjects)
                    .HasPrincipalKey(p => p.SystemIdentifier)
                    .HasForeignKey(d => d.InventorySystemIdentifier)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_DigitalObjects_Inventory");

                entity.HasOne(d => d.StatusCodeNavigation)
                    .WithMany(p => p.DigitalObjects)
                    .HasForeignKey(d => d.StatusCode)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_DigitalObjects_Status");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.DigitalObjectUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_DigitalObjects_UpdatedBy");
            });

            modelBuilder.Entity<DigitalObjectDraft>(entity =>
            {
                entity.HasIndex(e => e.SystemIdentifier, "UI_IsCurrentDraft")
                    .IsUnique()
                    .HasFilter("([IsCurrent]=(1))");

                entity.Property(e => e.AntivirusCheckInfo).HasMaxLength(2000);

                entity.Property(e => e.ErrorMessage).HasMaxLength(2000);

                entity.Property(e => e.FileInfo).HasMaxLength(2000);

                entity.Property(e => e.FileType).HasMaxLength(50);

                entity.Property(e => e.HashCode).HasMaxLength(100);

                entity.Property(e => e.Name).HasMaxLength(255);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.WorkflowStepTypeCode).HasMaxLength(50);

                entity.Property(e => e.WorkflowTypeCode).HasMaxLength(50);

                entity.HasOne(d => d.ArchivalEntityDraft)
                    .WithMany(p => p.DigitalObjectDrafts)
                    .HasForeignKey(d => d.ArchivalEntityDraftId)
                    .HasConstraintName("FK_DigitalObjectDrafts_ArchivalEntityDraft");

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.DigitalObjectDrafts)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_DigitalObjectDrafts_Archive");

                entity.HasOne(d => d.AvailabilityStatusCodeNavigation)
                    .WithMany(p => p.DigitalObjectDrafts)
                    .HasForeignKey(d => d.AvailabilityStatusCode)
                    .HasConstraintName("FK_DigitalObjectDrafts_AvailabilityStatus");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.DigitalObjectDraftCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_DigitalObjectDrafts_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.DigitalObjectDraftDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_DigitalObjectDrafts_DeletedBy");

                entity.HasOne(d => d.DocumentDraft)
                    .WithMany(p => p.DigitalObjectDrafts)
                    .HasForeignKey(d => d.DocumentDraftId)
                    .HasConstraintName("FK_DigitalObjectDrafts_DocumentDraft");

                entity.HasOne(d => d.FundDraft)
                    .WithMany(p => p.DigitalObjectDrafts)
                    .HasForeignKey(d => d.FundDraftId)
                    .HasConstraintName("FK_DigitalObjectDrafts_FundDraft");

                entity.HasOne(d => d.InventoryDraft)
                    .WithMany(p => p.DigitalObjectDrafts)
                    .HasForeignKey(d => d.InventoryDraftId)
                    .HasConstraintName("FK_DigitalObjectDrafts_InventoryDraft");

                entity.HasOne(d => d.PackageDocument)
                    .WithMany(p => p.DigitalObjectDrafts)
                    .HasForeignKey(d => d.PackageDocumentId)
                    .HasConstraintName("FK_DigitalObjectDraft_PackageDocument");

                entity.HasOne(d => d.StatusCodeNavigation)
                    .WithMany(p => p.DigitalObjectDrafts)
                    .HasForeignKey(d => d.StatusCode)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_DigitalObjectDrafts_Status");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.DigitalObjectDraftUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_DigitalObjectDrafts_UpdatedBy");
            });

            modelBuilder.Entity<DigitalObjectReview>(entity =>
            {
                entity.HasOne(d => d.UserSystemIdentifierNavigation)
                    .WithMany(p => p.DigitalObjectReviews)
                    .HasForeignKey(d => d.UserSystemIdentifier)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__DigitalOb__UserS__38AF44A5");
            });

            modelBuilder.Entity<Document>(entity =>
            {
                entity.HasIndex(e => e.SystemIdentifier, "UI_DocumentSystemIdentifier")
                    .IsUnique();

                entity.Property(e => e.ApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.DescriptionAuthor).HasMaxLength(250);

                entity.Property(e => e.DescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.FileFormatCode).HasMaxLength(50);

                entity.Property(e => e.Number).HasMaxLength(50);

                entity.Property(e => e.OtherMetrics).HasMaxLength(256);

                entity.Property(e => e.Scaling).HasMaxLength(256);

                entity.Property(e => e.SizeCm).HasMaxLength(256);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.HasOne(d => d.ArchivalEntitySystemIdentifierNavigation)
                    .WithMany(p => p.Documents)
                    .HasPrincipalKey(p => p.SystemIdentifier)
                    .HasForeignKey(d => d.ArchivalEntitySystemIdentifier)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Documents_ArchivalEntity");

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.Documents)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Documents_Archive");

                entity.HasOne(d => d.AvailabilityStatusCodeNavigation)
                    .WithMany(p => p.Documents)
                    .HasForeignKey(d => d.AvailabilityStatusCode)
                    .HasConstraintName("FK_Documents_AvailabilityStatus");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.DocumentCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_Documents_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.DocumentDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_Documents_DeletedBy");

                entity.HasOne(d => d.DescriptionLevelCodeNavigation)
                    .WithMany(p => p.Documents)
                    .HasForeignKey(d => d.DescriptionLevelCode)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Documents_DocumentDescriptionLevel");

                entity.HasOne(d => d.FundSystemIdentifierNavigation)
                    .WithMany(p => p.Documents)
                    .HasPrincipalKey(p => p.SystemIdentifier)
                    .HasForeignKey(d => d.FundSystemIdentifier)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Documents_Fund");

                entity.HasOne(d => d.InventorySystemIdentifierNavigation)
                    .WithMany(p => p.Documents)
                    .HasPrincipalKey(p => p.SystemIdentifier)
                    .HasForeignKey(d => d.InventorySystemIdentifier)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Documents_Inventory");

                entity.HasOne(d => d.StatusCodeNavigation)
                    .WithMany(p => p.Documents)
                    .HasForeignKey(d => d.StatusCode)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Documents_Status");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.DocumentUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_Documents_UpdatedBy");
            });

            modelBuilder.Entity<DocumentDescriptionLevel>(entity =>
            {
                entity.HasKey(e => e.Code);

                entity.ToTable("DocumentDescriptionLevel", "N");

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.Text).HasMaxLength(256);
            });

            modelBuilder.Entity<DocumentDraft>(entity =>
            {
                entity.HasIndex(e => e.SystemIdentifier, "UI_IsCurrentDraft")
                    .IsUnique()
                    .HasFilter("([IsCurrent]=(1))");

                entity.Property(e => e.ApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.DescriptionAuthor).HasMaxLength(250);

                entity.Property(e => e.DescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.FileFormatCode).HasMaxLength(50);

                entity.Property(e => e.Number).HasMaxLength(50);

                entity.Property(e => e.OtherMetrics).HasMaxLength(256);

                entity.Property(e => e.Scaling).HasMaxLength(256);

                entity.Property(e => e.SizeCm).HasMaxLength(256);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.WorkflowStepTypeCode).HasMaxLength(50);

                entity.Property(e => e.WorkflowTypeCode).HasMaxLength(50);

                entity.HasOne(d => d.ArchivalEntityDraft)
                    .WithMany(p => p.DocumentDrafts)
                    .HasForeignKey(d => d.ArchivalEntityDraftId)
                    .HasConstraintName("FK_DocumentDrafts_ArchivalEntityDraft");

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.DocumentDrafts)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_DocumentDrafts_Archive");

                entity.HasOne(d => d.AvailabilityStatusCodeNavigation)
                    .WithMany(p => p.DocumentDrafts)
                    .HasForeignKey(d => d.AvailabilityStatusCode)
                    .HasConstraintName("FK_DocumentDrafts_AvailabilityStatus");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.DocumentDraftCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_DocumentDrafts_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.DocumentDraftDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_DocumentDrafts_DeletedBy");

                entity.HasOne(d => d.DescriptionLevelCodeNavigation)
                    .WithMany(p => p.DocumentDrafts)
                    .HasForeignKey(d => d.DescriptionLevelCode)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_DocumentDrafts_DocumentDescriptionLevel");

                entity.HasOne(d => d.FundDraft)
                    .WithMany(p => p.DocumentDrafts)
                    .HasForeignKey(d => d.FundDraftId)
                    .HasConstraintName("FK_DocumentDrafts_FundDraft");

                entity.HasOne(d => d.InventoryDraft)
                    .WithMany(p => p.DocumentDrafts)
                    .HasForeignKey(d => d.InventoryDraftId)
                    .HasConstraintName("FK_DocumentDrafts_InventoryDraft");

                entity.HasOne(d => d.StatusCodeNavigation)
                    .WithMany(p => p.DocumentDrafts)
                    .HasForeignKey(d => d.StatusCode)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_DocumentDrafts_Status");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.DocumentDraftUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_DocumentDrafts_UpdatedBy");
            });

            modelBuilder.Entity<EdocsCollectingApplication>(entity =>
            {
                entity.ToTable("EDocsCollectingApplication");

                entity.Property(e => e.ApplicantAddress).HasMaxLength(500);

                entity.Property(e => e.ApplicantEmail).HasMaxLength(500);

                entity.Property(e => e.ApplicantFullName).HasMaxLength(500);

                entity.Property(e => e.ApplicantPhone).HasMaxLength(50);

                entity.Property(e => e.DocumentsOriginType).HasMaxLength(50);

                entity.Property(e => e.DocumentsPeriod).HasMaxLength(500);

                entity.Property(e => e.IsFromRedirect).HasDefaultValueSql("((0))");

                entity.Property(e => e.IsSystem).HasDefaultValueSql("((0))");

                entity.Property(e => e.Organization).HasMaxLength(500);

                entity.Property(e => e.OrganizationEik)
                    .HasMaxLength(50)
                    .HasColumnName("OrganizationEIK");

                entity.Property(e => e.OrganizationRepresentative).HasMaxLength(500);

                entity.Property(e => e.PackageAid).HasColumnName("PackageAId");

                entity.Property(e => e.PackageBid).HasColumnName("PackageBId");

                entity.Property(e => e.Type).HasMaxLength(50);

                entity.HasOne(d => d.Applicant)
                    .WithMany(p => p.EdocsCollectingApplicationApplicants)
                    .HasForeignKey(d => d.ApplicantId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_EDocsCollectingApplication_Applicant");

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.EdocsCollectingApplications)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_EDocsCollectingApplication_Archive");

                entity.HasOne(d => d.AssignToUser)
                    .WithMany(p => p.EdocsCollectingApplicationAssignToUsers)
                    .HasForeignKey(d => d.AssignToUserId)
                    .HasConstraintName("FK_EDocsCollectingApplication_AssignTo");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.EdocsCollectingApplicationCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_EDocsCollectingApplication_Creator");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.EdocsCollectingApplicationDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_EDocsCollectingApplication_DeletedBy");

                entity.HasOne(d => d.DocumentsOriginTypeNavigation)
                    .WithMany(p => p.EdocsCollectingApplications)
                    .HasForeignKey(d => d.DocumentsOriginType)
                    .HasConstraintName("FK_EDocsCollectingDocumentsOriginType_EDocsCollectingApplication");

                entity.HasOne(d => d.File)
                    .WithMany(p => p.EdocsCollectingApplications)
                    .HasForeignKey(d => d.FileId)
                    .HasConstraintName("FK_EDocsCollectingApplication_ApplicationFile");

                entity.HasOne(d => d.PackageA)
                    .WithMany(p => p.EdocsCollectingApplicationPackageAs)
                    .HasForeignKey(d => d.PackageAid)
                    .HasConstraintName("FK_EDocsCollectingApplication_PackageA");

                entity.HasOne(d => d.PackageB)
                    .WithMany(p => p.EdocsCollectingApplicationPackageBs)
                    .HasForeignKey(d => d.PackageBid)
                    .HasConstraintName("FK_EDocsCollectingApplication_PackageB");

                entity.HasOne(d => d.RedirectApplication)
                    .WithMany(p => p.InverseRedirectApplication)
                    .HasForeignKey(d => d.RedirectApplicationId)
                    .HasConstraintName("FK_EDocsCollectingApplication_RedirectApplication");

                entity.HasOne(d => d.Status)
                    .WithMany(p => p.EdocsCollectingApplications)
                    .HasForeignKey(d => d.StatusId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_EDocsCollectingApplication_Status");

                entity.HasOne(d => d.TypeNavigation)
                    .WithMany(p => p.EdocsCollectingApplications)
                    .HasForeignKey(d => d.Type)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_EDocsCollectingApplication_Type");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.EdocsCollectingApplicationUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_EDocsCollectingApplication_Updator");
            });

            modelBuilder.Entity<EdocsCollectingApplicationStatus>(entity =>
            {
                entity.ToTable("EDocsCollectingApplicationStatuses", "N");

                entity.Property(e => e.Text).HasMaxLength(50);

                entity.Property(e => e.TextEn).HasMaxLength(50);
            });

            modelBuilder.Entity<EdocsCollectingApplicationType>(entity =>
            {
                entity.HasKey(e => e.Code);

                entity.ToTable("EDocsCollectingApplicationTypes", "N");

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.Text).HasMaxLength(150);

                entity.Property(e => e.TextEn).HasMaxLength(150);
            });

            modelBuilder.Entity<EdocsCollectingDocumentsOriginType>(entity =>
            {
                entity.HasKey(e => e.Code);

                entity.ToTable("EDocsCollectingDocumentsOriginType", "N");

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.Text).HasMaxLength(255);
            });

            modelBuilder.Entity<Epkreport>(entity =>
            {
                entity.ToTable("EPKReports");

                entity.Property(e => e.IsDraft)
                    .IsRequired()
                    .HasDefaultValueSql("((1))");

                entity.Property(e => e.Title).HasMaxLength(255);

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.EpkreportCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_CommissionReports_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.EpkreportDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_CommissionReports_DeletedBy");

                entity.HasOne(d => d.Process)
                    .WithMany(p => p.Epkreports)
                    .HasForeignKey(d => d.ProcessId)
                    .HasConstraintName("FK_CommissionReports_Process");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.EpkreportUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_CommissionReports_UpdatedBy");
            });

            modelBuilder.Entity<File>(entity =>
            {
                entity.Property(e => e.ContentType).HasMaxLength(500);

                entity.Property(e => e.FileName).HasMaxLength(500);

                entity.Property(e => e.FileType).HasMaxLength(50);

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.FileCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_Files_AspNetUsers");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.FileDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_Files_AspNetUsers1");
            });

            modelBuilder.Entity<FileUploadQueue>(entity =>
            {
                entity.ToTable("FileUploadQueue");

                entity.Property(e => e.AntivirusCheckInfo).HasMaxLength(2000);

                entity.Property(e => e.Checksum)
                    .HasMaxLength(100)
                    .IsUnicode(false);

                entity.Property(e => e.ComputerName)
                    .HasMaxLength(256)
                    .IsUnicode(false);

                entity.Property(e => e.DbFileName).HasMaxLength(2000);

                entity.Property(e => e.ErrorMessage).HasMaxLength(2000);

                entity.Property(e => e.FileInfo).HasMaxLength(2000);

                entity.Property(e => e.FileKindCode)
                    .HasMaxLength(20)
                    .IsUnicode(false);

                entity.Property(e => e.FileName).HasMaxLength(2000);

                entity.Property(e => e.LocalFileName).HasMaxLength(2000);

                entity.Property(e => e.Notes).HasMaxLength(2000);

                entity.Property(e => e.ProcessKindCode)
                    .HasMaxLength(20)
                    .IsUnicode(false);

                entity.Property(e => e.UncFileName).HasMaxLength(2000);
            });

            modelBuilder.Entity<Film>(entity =>
            {
                entity.HasIndex(e => e.SystemIdentifier, "UI_FilmSystemIdentifier")
                    .IsUnique();

                entity.Property(e => e.DigitalCopy).HasMaxLength(250);

                entity.Property(e => e.PackageAid).HasColumnName("PackageAId");

                entity.Property(e => e.PackageBid).HasColumnName("PackageBId");

                entity.Property(e => e.PhotoCopy).HasMaxLength(250);

                entity.Property(e => e.Size).HasMaxLength(250);

                entity.Property(e => e.Source).HasMaxLength(250);

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.Films)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Film_Archive");

                entity.HasOne(d => d.Country)
                    .WithMany(p => p.Films)
                    .HasForeignKey(d => d.CountryId)
                    .HasConstraintName("FK_Film_Country");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.FilmCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_Film_CreatedByAspNetUser");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.FilmDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_Film_DeletedByAspNetUser");

                entity.HasOne(d => d.PackageA)
                    .WithMany(p => p.FilmPackageAs)
                    .HasForeignKey(d => d.PackageAid)
                    .HasConstraintName("FK_Film_PackageA");

                entity.HasOne(d => d.PackageB)
                    .WithMany(p => p.FilmPackageBs)
                    .HasForeignKey(d => d.PackageBid)
                    .HasConstraintName("FK_Film_PackageB");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.FilmUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_Film_UpdatedByAspNetUser");
            });

            modelBuilder.Entity<FilmCard>(entity =>
            {
                entity.Property(e => e.AproximateDate).HasMaxLength(250);

                entity.Property(e => e.ArchiveOriginals).HasMaxLength(2000);

                entity.Property(e => e.City).HasMaxLength(250);

                entity.Property(e => e.DigitalCopy).HasMaxLength(250);

                entity.Property(e => e.DocumentsCypher).HasMaxLength(2000);

                entity.Property(e => e.DocumentsFormat).HasMaxLength(250);

                entity.Property(e => e.InventoryNumber).HasMaxLength(50);

                entity.Property(e => e.PhotoCopy).HasMaxLength(250);

                entity.Property(e => e.Size).HasMaxLength(250);

                entity.Property(e => e.Source).HasMaxLength(250);

                entity.Property(e => e.Title).HasMaxLength(500);

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.FilmCards)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_FilmCard_ArchiveCopy");

                entity.HasOne(d => d.Country)
                    .WithMany(p => p.FilmCardCountries)
                    .HasForeignKey(d => d.CountryId)
                    .HasConstraintName("FK_FilmCard_Country");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.FilmCardCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_FilmCard_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.FilmCardDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_FilmCard_DeletedBy");

                entity.HasOne(d => d.FilmSystemIdentifierNavigation)
                    .WithMany(p => p.FilmCards)
                    .HasPrincipalKey(p => p.SystemIdentifier)
                    .HasForeignKey(d => d.FilmSystemIdentifier)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_FilmCard_Film");

                entity.HasOne(d => d.FilmingExtent)
                    .WithMany(p => p.FilmCardFilmingExtents)
                    .HasForeignKey(d => d.FilmingExtentId)
                    .HasConstraintName("FK_FilmCard_FilmingExtent");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.FilmCardUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_FilmCard_UpdatedBy");
            });

            modelBuilder.Entity<FilmCardDocument>(entity =>
            {
                entity.HasOne(d => d.PackageDocument)
                    .WithMany(p => p.FilmCardDocuments)
                    .HasForeignKey(d => d.PackageDocumentId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_FilmCardDoc_FilmPackageDocument");
            });

            modelBuilder.Entity<FilmCardDraft>(entity =>
            {
                entity.HasIndex(e => e.SystemIdentifier, "UI_IsCurrentDraft")
                    .IsUnique()
                    .HasFilter("([IsCurrent]=(1))");

                entity.Property(e => e.AproximateDate).HasMaxLength(250);

                entity.Property(e => e.ArchiveOriginals).HasMaxLength(2000);

                entity.Property(e => e.City).HasMaxLength(250);

                entity.Property(e => e.DigitalCopy).HasMaxLength(250);

                entity.Property(e => e.DocumentsCypher).HasMaxLength(2000);

                entity.Property(e => e.DocumentsFormat).HasMaxLength(250);

                entity.Property(e => e.InventoryNumber).HasMaxLength(50);

                entity.Property(e => e.PhotoCopy).HasMaxLength(250);

                entity.Property(e => e.Size).HasMaxLength(250);

                entity.Property(e => e.Source).HasMaxLength(250);

                entity.Property(e => e.Title).HasMaxLength(500);

                entity.Property(e => e.WorkflowStepTypeCode).HasMaxLength(50);

                entity.Property(e => e.WorkflowTypeCode).HasMaxLength(50);

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.FilmCardDrafts)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_FilmCardDrafts_Archive");

                entity.HasOne(d => d.Country)
                    .WithMany(p => p.FilmCardDraftCountries)
                    .HasForeignKey(d => d.CountryId)
                    .HasConstraintName("FK_FilmCardDraft_Country");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.FilmCardDraftCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_FilmCardDrafts_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.FilmCardDraftDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_FilmCardDrafts_DeletedBy");

                entity.HasOne(d => d.FilmDraft)
                    .WithMany(p => p.FilmCardDrafts)
                    .HasForeignKey(d => d.FilmDraftId)
                    .HasConstraintName("FK_FilmCardDrafts_FilmDraft");

                entity.HasOne(d => d.FilmingExtent)
                    .WithMany(p => p.FilmCardDraftFilmingExtents)
                    .HasForeignKey(d => d.FilmingExtentId)
                    .HasConstraintName("FK_FilmCardDrafts_FilmingExtent");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.FilmCardDraftUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_FilmCardDrafts_UpdatedBy");
            });

            modelBuilder.Entity<FilmDescriptionLevel>(entity =>
            {
                entity.HasKey(e => e.Code);

                entity.ToTable("FilmDescriptionLevel", "N");

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.Text).HasMaxLength(256);
            });

            modelBuilder.Entity<FilmDocumentType>(entity =>
            {
                entity.ToTable("FilmDocumentType", "N");

                entity.Property(e => e.Id).ValueGeneratedNever();

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.PackageType).HasMaxLength(1);

                entity.Property(e => e.Text).HasMaxLength(250);
            });

            modelBuilder.Entity<FilmDraft>(entity =>
            {
                entity.HasIndex(e => e.SystemIdentifier, "UI_IsCurrentDraft")
                    .IsUnique()
                    .HasFilter("([IsCurrent]=(1))");

                entity.Property(e => e.DigitalCopy).HasMaxLength(250);

                entity.Property(e => e.PackageAid).HasColumnName("PackageAId");

                entity.Property(e => e.PackageBid).HasColumnName("PackageBId");

                entity.Property(e => e.PhotoCopy).HasMaxLength(250);

                entity.Property(e => e.Size).HasMaxLength(250);

                entity.Property(e => e.Source).HasMaxLength(250);

                entity.Property(e => e.WorkflowStepTypeCode).HasMaxLength(50);

                entity.Property(e => e.WorkflowTypeCode).HasMaxLength(50);

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.FilmDrafts)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_FilmDrafts_Archive");

                entity.HasOne(d => d.Country)
                    .WithMany(p => p.FilmDrafts)
                    .HasForeignKey(d => d.CountryId)
                    .HasConstraintName("FK_FilmDrafts_Country");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.FilmDraftCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_FilmDrafts_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.FilmDraftDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_FilmDrafts_DeletedBy");

                entity.HasOne(d => d.PackageA)
                    .WithMany(p => p.FilmDraftPackageAs)
                    .HasForeignKey(d => d.PackageAid)
                    .HasConstraintName("FK_FilmDrafts_PackageA");

                entity.HasOne(d => d.PackageB)
                    .WithMany(p => p.FilmDraftPackageBs)
                    .HasForeignKey(d => d.PackageBid)
                    .HasConstraintName("FK_FilmDrafts_PackageB");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.FilmDraftUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_FilmDrafts_UpdatedBy");
            });

            modelBuilder.Entity<FilmPackage>(entity =>
            {
                entity.Property(e => e.Type).HasMaxLength(1);

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.FilmPackageCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_FilmPackage_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.FilmPackageDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_FilmPackage_DeletedBy");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.FilmPackageUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_FilmPackage_UpdatedBy");
            });

            modelBuilder.Entity<FilmPackageDocument>(entity =>
            {
                entity.Property(e => e.AntivirusCheckInfo).HasMaxLength(2000);

                entity.Property(e => e.ErrorMessage).HasMaxLength(2000);

                entity.Property(e => e.FileId).HasMaxLength(450);

                entity.Property(e => e.FileInfo).HasMaxLength(2000);

                entity.Property(e => e.FileName).HasMaxLength(500);

                entity.Property(e => e.FilePath).HasMaxLength(450);

                entity.Property(e => e.FileType).HasMaxLength(10);

                entity.Property(e => e.HashCode).HasMaxLength(100);

                entity.HasOne(d => d.CopiedFrom)
                    .WithMany(p => p.InverseCopiedFrom)
                    .HasForeignKey(d => d.CopiedFromId)
                    .HasConstraintName("FK_FilmPackageDocument_CopyId");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.FilmPackageDocumentCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_FilmPackageDocument_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.FilmPackageDocumentDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_FilmPackageDocument_DeletedBy");

                entity.HasOne(d => d.DocumentType)
                    .WithMany(p => p.FilmPackageDocuments)
                    .HasForeignKey(d => d.DocumentTypeId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_FilmPackageDocument_DocType");

                entity.HasOne(d => d.Package)
                    .WithMany(p => p.FilmPackageDocuments)
                    .HasForeignKey(d => d.PackageId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_FilmPackageDocument_Package");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.FilmPackageDocumentUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_FilmPackageDocument_UpdatedBy");
            });

            modelBuilder.Entity<FilmReview>(entity =>
            {
                entity.HasIndex(e => e.SystemIdentifier, "ID_FilmReviews")
                    .IsUnique();

                entity.Property(e => e.AccessAllowed)
                    .IsRequired()
                    .HasDefaultValueSql("((1))");

                entity.Property(e => e.ReaderName).HasMaxLength(256);

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.FilmReviewCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_FilmReviews_CreatedByAspNetUser");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.FilmReviewDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_FilmReviews_DeletedByAspNetUser");

                entity.HasOne(d => d.FilmSystemIdentifierNavigation)
                    .WithMany(p => p.FilmReviews)
                    .HasPrincipalKey(p => p.SystemIdentifier)
                    .HasForeignKey(d => d.FilmSystemIdentifier)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__FilmRevie__FilmS__294D0584");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.FilmReviewUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_FilmReviews_UpdatedByAspNetUser");

                entity.HasOne(d => d.User)
                    .WithMany(p => p.FilmReviewUsers)
                    .HasForeignKey(d => d.UserId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__FilmRevie__UserI__2858E14B");
            });

            modelBuilder.Entity<Fund>(entity =>
            {
                entity.HasIndex(e => e.SystemIdentifier, "UI_FundSystemIdentifier")
                    .IsUnique();

                entity.Property(e => e.ApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.DescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.Number).HasMaxLength(50);

                entity.Property(e => e.NumberArray).HasMaxLength(50);

                entity.Property(e => e.OtherMetrics).HasMaxLength(256);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.TypeCode).HasMaxLength(50);

                entity.HasOne(d => d.AcquisitionMethod)
                    .WithMany(p => p.Funds)
                    .HasForeignKey(d => d.AcquisitionMethodId)
                    .HasConstraintName("FK_Funds_AcquisitionMethod");

                entity.HasOne(d => d.Application)
                    .WithMany(p => p.Funds)
                    .HasForeignKey(d => d.ApplicationId)
                    .HasConstraintName("FK_Funds_Applications");

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.Funds)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Funds_Archive");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.FundCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_Funds_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.FundDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_Funds_DeletedBy");

                entity.HasOne(d => d.DescriptionLevelCodeNavigation)
                    .WithMany(p => p.Funds)
                    .HasForeignKey(d => d.DescriptionLevelCode)
                    .HasConstraintName("FK_Funds_DescriptionLevel");

                entity.HasOne(d => d.LockedByProcess)
                    .WithMany(p => p.Funds)
                    .HasForeignKey(d => d.LockedByProcessId)
                    .HasConstraintName("FK_Funds_LockingProcess");

                entity.HasOne(d => d.NumberArrayNavigation)
                    .WithMany(p => p.Funds)
                    .HasForeignKey(d => d.NumberArray)
                    .HasConstraintName("FK_Funds_Array");

                entity.HasOne(d => d.StatusCodeNavigation)
                    .WithMany(p => p.Funds)
                    .HasForeignKey(d => d.StatusCode)
                    .HasConstraintName("FK_Funds_Status");

                entity.HasOne(d => d.TypeCodeNavigation)
                    .WithMany(p => p.Funds)
                    .HasForeignKey(d => d.TypeCode)
                    .HasConstraintName("FK_Funds_Type");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.FundUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_Funds_UpdatedBy");
            });

            modelBuilder.Entity<FundArray>(entity =>
            {
                entity.HasKey(e => e.Code);

                entity.ToTable("FundArray", "N");

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.Text).HasMaxLength(256);
            });

            modelBuilder.Entity<FundDescriptionLevel>(entity =>
            {
                entity.HasKey(e => e.Code);

                entity.ToTable("FundDescriptionLevel", "N");

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.Text).HasMaxLength(256);
            });

            modelBuilder.Entity<FundDraft>(entity =>
            {
                entity.HasIndex(e => e.SystemIdentifier, "UI_IsCurrentDraft")
                    .IsUnique()
                    .HasFilter("([IsCurrent]=(1))");

                entity.Property(e => e.ApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.DescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.Number).HasMaxLength(50);

                entity.Property(e => e.NumberArray).HasMaxLength(50);

                entity.Property(e => e.OtherMetrics).HasMaxLength(256);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.TypeCode).HasMaxLength(50);

                entity.Property(e => e.WorkflowStepTypeCode).HasMaxLength(50);

                entity.Property(e => e.WorkflowTypeCode).HasMaxLength(50);

                entity.HasOne(d => d.AcquisitionMethod)
                    .WithMany(p => p.FundDrafts)
                    .HasForeignKey(d => d.AcquisitionMethodId)
                    .HasConstraintName("FK_FundDrafts_AcquisitionMethod");

                entity.HasOne(d => d.Application)
                    .WithMany(p => p.FundDrafts)
                    .HasForeignKey(d => d.ApplicationId)
                    .HasConstraintName("FK_FundDrafts_Applications");

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.FundDrafts)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_FundDrafts_Archive");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.FundDraftCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_FundDrafts_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.FundDraftDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_FundDrafts_DeletedBy");

                entity.HasOne(d => d.DescriptionLevelCodeNavigation)
                    .WithMany(p => p.FundDrafts)
                    .HasForeignKey(d => d.DescriptionLevelCode)
                    .HasConstraintName("FK_FundDrafts_DescriptionLevel");

                entity.HasOne(d => d.NumberArrayNavigation)
                    .WithMany(p => p.FundDrafts)
                    .HasForeignKey(d => d.NumberArray)
                    .HasConstraintName("FK_FundDrafts_Array");

                entity.HasOne(d => d.StatusCodeNavigation)
                    .WithMany(p => p.FundDrafts)
                    .HasForeignKey(d => d.StatusCode)
                    .HasConstraintName("FK_FundDrafts_Status");

                entity.HasOne(d => d.TypeCodeNavigation)
                    .WithMany(p => p.FundDrafts)
                    .HasForeignKey(d => d.TypeCode)
                    .HasConstraintName("FK_FundDrafts_Type");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.FundDraftUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_FundDrafts_UpdatedBy");
            });

            modelBuilder.Entity<FundReconstruction>(entity =>
            {
                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.FundReconstructions)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_FundReconstructions_Archive");

                entity.HasOne(d => d.AvailabilityStatusCodeNavigation)
                    .WithMany(p => p.FundReconstructions)
                    .HasForeignKey(d => d.AvailabilityStatusCode)
                    .HasConstraintName("FK_FundReconstructions_AvailabilityStatus");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.FundReconstructionCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_FundReconstructions_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.FundReconstructionDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_FundReconstructions_DeletedBy");

                entity.HasOne(d => d.FundSystemIdentifierNavigation)
                    .WithMany(p => p.FundReconstructions)
                    .HasPrincipalKey(p => p.SystemIdentifier)
                    .HasForeignKey(d => d.FundSystemIdentifier)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_FundReconstructions_Fund");

                entity.HasOne(d => d.Process)
                    .WithMany(p => p.FundReconstructions)
                    .HasForeignKey(d => d.ProcessId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_FundReconstructions_Process");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.FundReconstructionUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_FundReconstructions_UpdatedBy");
            });

            modelBuilder.Entity<FundType>(entity =>
            {
                entity.HasKey(e => e.Code);

                entity.ToTable("FundType", "N");

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.Text).HasMaxLength(256);
            });

            modelBuilder.Entity<Hash>(entity =>
            {
                entity.HasKey(e => new { e.Key, e.Field })
                    .HasName("PK_HangFire_Hash");

                entity.ToTable("Hash", "HangFire");

                entity.HasIndex(e => e.ExpireAt, "IX_HangFire_Hash_ExpireAt")
                    .HasFilter("([ExpireAt] IS NOT NULL)");

                entity.Property(e => e.Key).HasMaxLength(100);

                entity.Property(e => e.Field).HasMaxLength(100);
            });

            modelBuilder.Entity<InformationItem>(entity =>
            {
                entity.Property(e => e.Title).HasMaxLength(1000);

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.InformationItemCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_InformationItems_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.InformationItemDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_InformationItems_DeletedBy");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.InformationItemUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_InformationItems_UpdatedBy");
            });

            modelBuilder.Entity<Inventory>(entity =>
            {
                entity.HasIndex(e => e.SystemIdentifier, "UI_InventorySystemIdentifier")
                    .IsUnique();

                entity.Property(e => e.ApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.DescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.Number).HasMaxLength(50);

                entity.Property(e => e.NumberArray).HasMaxLength(50);

                entity.Property(e => e.OtherLanguage).HasMaxLength(250);

                entity.Property(e => e.OtherMetrics).HasMaxLength(256);

                entity.Property(e => e.PackageAid).HasColumnName("PackageAId");

                entity.Property(e => e.PackageBid).HasColumnName("PackageBId");

                entity.Property(e => e.PackageCid).HasColumnName("PackageCId");

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.HasOne(d => d.AcquisitionMethod)
                    .WithMany(p => p.Inventories)
                    .HasForeignKey(d => d.AcquisitionMethodId)
                    .HasConstraintName("FK_Inventories_AcquisitionMethod");

                entity.HasOne(d => d.Application)
                    .WithMany(p => p.Inventories)
                    .HasForeignKey(d => d.ApplicationId)
                    .HasConstraintName("FK_Inventories_Applications");

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.Inventories)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Inventories_Archive");

                entity.HasOne(d => d.AvailabilityStatusCodeNavigation)
                    .WithMany(p => p.Inventories)
                    .HasForeignKey(d => d.AvailabilityStatusCode)
                    .HasConstraintName("FK_Inventories_AvailabilityStatus");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.InventoryCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_Inventories_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.InventoryDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_Inventories_DeletedBy");

                entity.HasOne(d => d.DescriptionLevelCodeNavigation)
                    .WithMany(p => p.Inventories)
                    .HasForeignKey(d => d.DescriptionLevelCode)
                    .HasConstraintName("FK_Inventories_DescriptionLevel");

                entity.HasOne(d => d.FundSystemIdentifierNavigation)
                    .WithMany(p => p.Inventories)
                    .HasPrincipalKey(p => p.SystemIdentifier)
                    .HasForeignKey(d => d.FundSystemIdentifier)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Inventories_Fund");

                entity.HasOne(d => d.LockedByProcess)
                    .WithMany(p => p.Inventories)
                    .HasForeignKey(d => d.LockedByProcessId)
                    .HasConstraintName("FK_Inventory_LockingProcess");

                entity.HasOne(d => d.NumberArrayNavigation)
                    .WithMany(p => p.Inventories)
                    .HasForeignKey(d => d.NumberArray)
                    .HasConstraintName("FK_Inventories_Array");

                entity.HasOne(d => d.PackageA)
                    .WithMany(p => p.InventoryPackageAs)
                    .HasForeignKey(d => d.PackageAid)
                    .HasConstraintName("FK_Inventories_PackageA");

                entity.HasOne(d => d.PackageB)
                    .WithMany(p => p.InventoryPackageBs)
                    .HasForeignKey(d => d.PackageBid)
                    .HasConstraintName("FK_Inventories_PackageB");

                entity.HasOne(d => d.PackageC)
                    .WithMany(p => p.InventoryPackageCs)
                    .HasForeignKey(d => d.PackageCid)
                    .HasConstraintName("FK_Inventories_PackageC");

                entity.HasOne(d => d.StatusCodeNavigation)
                    .WithMany(p => p.Inventories)
                    .HasForeignKey(d => d.StatusCode)
                    .HasConstraintName("FK_Inventories_Status");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.InventoryUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_Inventories_UpdatedBy");
            });

            modelBuilder.Entity<InventoryArray>(entity =>
            {
                entity.HasKey(e => e.Code);

                entity.ToTable("InventoryArray", "N");

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.ExternalSourceCode).HasMaxLength(256);

                entity.Property(e => e.Text).HasMaxLength(256);
            });

            modelBuilder.Entity<InventoryDescriptionLevel>(entity =>
            {
                entity.HasKey(e => e.Code);

                entity.ToTable("InventoryDescriptionLevel", "N");

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.Text).HasMaxLength(256);
            });

            modelBuilder.Entity<InventoryDraft>(entity =>
            {
                entity.HasIndex(e => e.SystemIdentifier, "UI_IsCurrentDraft")
                    .IsUnique()
                    .HasFilter("([IsCurrent]=(1))");

                entity.Property(e => e.ApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.DescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.Number).HasMaxLength(50);

                entity.Property(e => e.NumberArray).HasMaxLength(50);

                entity.Property(e => e.OtherLanguage).HasMaxLength(250);

                entity.Property(e => e.OtherMetrics).HasMaxLength(256);

                entity.Property(e => e.PackageAid).HasColumnName("PackageAId");

                entity.Property(e => e.PackageBid).HasColumnName("PackageBId");

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.WorkflowStepTypeCode).HasMaxLength(50);

                entity.Property(e => e.WorkflowTypeCode).HasMaxLength(50);

                entity.HasOne(d => d.AcquisitionMethod)
                    .WithMany(p => p.InventoryDrafts)
                    .HasForeignKey(d => d.AcquisitionMethodId)
                    .HasConstraintName("FK_InventoryDrafts_AcquisitionMethod");

                entity.HasOne(d => d.Application)
                    .WithMany(p => p.InventoryDrafts)
                    .HasForeignKey(d => d.ApplicationId)
                    .HasConstraintName("FK_InventoryDrafts_Applications");

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.InventoryDrafts)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_InventoryDrafts_Archive");

                entity.HasOne(d => d.AvailabilityStatusCodeNavigation)
                    .WithMany(p => p.InventoryDrafts)
                    .HasForeignKey(d => d.AvailabilityStatusCode)
                    .HasConstraintName("FK_InventoryDrafts_AvailabilityStatus");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.InventoryDraftCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_InventoryDrafts_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.InventoryDraftDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_InventoryDrafts_DeletedBy");

                entity.HasOne(d => d.DescriptionLevelCodeNavigation)
                    .WithMany(p => p.InventoryDrafts)
                    .HasForeignKey(d => d.DescriptionLevelCode)
                    .HasConstraintName("FK_InventoryDrafts_DescriptionLevel");

                entity.HasOne(d => d.FundDraft)
                    .WithMany(p => p.InventoryDrafts)
                    .HasForeignKey(d => d.FundDraftId)
                    .HasConstraintName("FK_InventoryDrafts_FundDraft");

                entity.HasOne(d => d.NumberArrayNavigation)
                    .WithMany(p => p.InventoryDrafts)
                    .HasForeignKey(d => d.NumberArray)
                    .HasConstraintName("FK_InventoryDrafts_Array");

                entity.HasOne(d => d.PackageA)
                    .WithMany(p => p.InventoryDraftPackageAs)
                    .HasForeignKey(d => d.PackageAid)
                    .HasConstraintName("FK_InventoryDrafts_PackageA");

                entity.HasOne(d => d.PackageB)
                    .WithMany(p => p.InventoryDraftPackageBs)
                    .HasForeignKey(d => d.PackageBid)
                    .HasConstraintName("FK_InventoryDrafts_PakageB");

                entity.HasOne(d => d.StatusCodeNavigation)
                    .WithMany(p => p.InventoryDrafts)
                    .HasForeignKey(d => d.StatusCode)
                    .HasConstraintName("FK_InventoryDrafts_Status");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.InventoryDraftUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_InventoryDrafts_UpdatedBy");
            });

            modelBuilder.Entity<InventoryRawToNormal>(entity =>
            {
                entity.ToTable("InventoryRawToNormal");

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.InventoryRawToNormals)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_InventoryRawToNormal_Archive");

                entity.HasOne(d => d.Process)
                    .WithMany(p => p.InventoryRawToNormals)
                    .HasForeignKey(d => d.ProcessId)
                    .HasConstraintName("FK_InventoryRawToNormal_Process");
            });

            modelBuilder.Entity<Job>(entity =>
            {
                entity.ToTable("Job", "HangFire");

                entity.HasIndex(e => e.ExpireAt, "IX_HangFire_Job_ExpireAt")
                    .HasFilter("([ExpireAt] IS NOT NULL)");

                entity.HasIndex(e => e.StateName, "IX_HangFire_Job_StateName")
                    .HasFilter("([StateName] IS NOT NULL)");

                entity.Property(e => e.CreatedAt).HasColumnType("datetime");

                entity.Property(e => e.ExpireAt).HasColumnType("datetime");

                entity.Property(e => e.StateName).HasMaxLength(20);
            });

            modelBuilder.Entity<JobParameter>(entity =>
            {
                entity.HasKey(e => new { e.JobId, e.Name })
                    .HasName("PK_HangFire_JobParameter");

                entity.ToTable("JobParameter", "HangFire");

                entity.Property(e => e.Name).HasMaxLength(40);

                entity.HasOne(d => d.Job)
                    .WithMany(p => p.JobParameters)
                    .HasForeignKey(d => d.JobId)
                    .HasConstraintName("FK_HangFire_JobParameter_Job");
            });

            modelBuilder.Entity<JobQueue>(entity =>
            {
                entity.HasKey(e => new { e.Queue, e.Id })
                    .HasName("PK_HangFire_JobQueue");

                entity.ToTable("JobQueue", "HangFire");

                entity.Property(e => e.Queue).HasMaxLength(50);

                entity.Property(e => e.Id).ValueGeneratedOnAdd();

                entity.Property(e => e.FetchedAt).HasColumnType("datetime");
            });

            modelBuilder.Entity<List>(entity =>
            {
                entity.HasKey(e => new { e.Key, e.Id })
                    .HasName("PK_HangFire_List");

                entity.ToTable("List", "HangFire");

                entity.HasIndex(e => e.ExpireAt, "IX_HangFire_List_ExpireAt")
                    .HasFilter("([ExpireAt] IS NOT NULL)");

                entity.Property(e => e.Key).HasMaxLength(100);

                entity.Property(e => e.Id).ValueGeneratedOnAdd();

                entity.Property(e => e.ExpireAt).HasColumnType("datetime");
            });

            modelBuilder.Entity<Nomenclature>(entity =>
            {
                entity.ToTable("Nomenclatures", "N");

                entity.HasIndex(e => new { e.ParentId, e.Code }, "UI_NomenclatureValue_Code")
                    .IsUnique()
                    .HasFilter("([ParentId] IS NOT NULL AND [Code] IS NOT NULL AND [Deleted]=(0))");

                entity.HasIndex(e => new { e.ParentId, e.Code }, "UI_Nomenclature_Code")
                    .IsUnique()
                    .HasFilter("([ParentId] IS NULL AND [Code] IS NOT NULL AND [Deleted]=(0))");

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.Text).HasMaxLength(256);

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.NomenclatureCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_Nomenclatures_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.NomenclatureDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_Nomenclatures_DeletedBy");

                entity.HasOne(d => d.Parent)
                    .WithMany(p => p.InverseParent)
                    .HasForeignKey(d => d.ParentId)
                    .HasConstraintName("FK_Nomenclatures_Parent");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.NomenclatureUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_Nomenclatures_UpdatedBy");
            });

            modelBuilder.Entity<NomenclatureCode>(entity =>
            {
                entity.HasKey(e => e.Code);

                entity.ToTable("NomenclatureCode", "N");

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.Text).HasMaxLength(256);
            });

            modelBuilder.Entity<NomenclatureValue>(entity =>
            {
                entity.HasIndex(e => new { e.EntityId, e.EntityType, e.EntityIsDraft, e.NomenclatureId, e.NomenclatureCode, e.ValueId, e.ValueCode }, "UI_NomenclatureValue_Entity")
                    .IsUnique()
                    .HasFilter("([Deleted]=(0))");

                entity.Property(e => e.EntityType).HasMaxLength(50);

                entity.Property(e => e.NomenclatureCode).HasMaxLength(50);

                entity.Property(e => e.ValueCode).HasMaxLength(50);

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.NomenclatureValueCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_NomenclatureValues_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.NomenclatureValueDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_NomenclatureValues_DeletedBy");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.NomenclatureValueUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_NomenclatureValues_UpdatedBy");
            });

            modelBuilder.Entity<Notification>(entity =>
            {
                entity.ToTable("Notification", "Notification");

                entity.Property(e => e.Subject).HasMaxLength(450);

                entity.HasOne(d => d.Event)
                    .WithMany(p => p.Notifications)
                    .HasForeignKey(d => d.EventId)
                    .HasConstraintName("FK_Notification_Event");

                entity.HasOne(d => d.NotificationTemplate)
                    .WithMany(p => p.Notifications)
                    .HasForeignKey(d => d.NotificationTemplateId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Notification_Template");

                entity.HasOne(d => d.ToUser)
                    .WithMany(p => p.Notifications)
                    .HasForeignKey(d => d.ToUserId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Notification_ToUser");
            });

            modelBuilder.Entity<NotificationEvent>(entity =>
            {
                entity.ToTable("NotificationEvent", "Notification");

                entity.Property(e => e.NotificationTypeCode).HasMaxLength(50);

                entity.HasOne(d => d.AssignedToRole)
                    .WithMany(p => p.NotificationEvents)
                    .HasForeignKey(d => d.AssignedToRoleId)
                    .HasConstraintName("FK_NotificationEvent_AssignedToRole");

                entity.HasOne(d => d.AssignedToUser)
                    .WithMany(p => p.NotificationEvents)
                    .HasForeignKey(d => d.AssignedToUserId)
                    .HasConstraintName("FK_NotificationEvent_AssignedToUser");

                entity.HasOne(d => d.NotificationTypeCodeNavigation)
                    .WithMany(p => p.NotificationEvents)
                    .HasForeignKey(d => d.NotificationTypeCode)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_NotificationEvent_NotificationType");
            });

            modelBuilder.Entity<NotificationTemplate>(entity =>
            {
                entity.ToTable("NotificationTemplate", "Notification");

                entity.Property(e => e.NotificationTypeCode).HasMaxLength(50);

                entity.Property(e => e.Subject).HasMaxLength(450);

                entity.HasOne(d => d.NotificationTypeCodeNavigation)
                    .WithMany(p => p.NotificationTemplates)
                    .HasForeignKey(d => d.NotificationTypeCode)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_NotificationTemplate_NotificationType");
            });

            modelBuilder.Entity<NotificationType>(entity =>
            {
                entity.HasKey(e => e.Code)
                    .HasName("PK_N.NotificationType");

                entity.ToTable("NotificationType", "N");

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.Text).HasMaxLength(256);
            });

            modelBuilder.Entity<Package>(entity =>
            {
                entity.Property(e => e.Type).HasMaxLength(1);

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.PackageCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_Packages_AspNetUsers");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.PackageDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_Packages_AspNetUsers2");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.PackageUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_Packages_AspNetUsers1");
            });

            modelBuilder.Entity<PackageAdocsTemplate>(entity =>
            {
                entity.ToTable("PackageADocsTemplates");

                entity.Property(e => e.Static)
                    .IsRequired()
                    .HasDefaultValueSql("((1))");

                entity.Property(e => e.Title).HasMaxLength(500);

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.PackageAdocsTemplateCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_PackageADocsTemplates_AspNetUsers");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.PackageAdocsTemplateDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_PackageADocsTemplates_AspNetUsers1");

                entity.HasOne(d => d.Document)
                    .WithMany(p => p.PackageAdocsTemplates)
                    .HasForeignKey(d => d.DocumentId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_PackageADocsTemplates_Files");

                entity.HasOne(d => d.Procedure)
                    .WithMany(p => p.PackageAdocsTemplates)
                    .HasForeignKey(d => d.ProcedureId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_PackageADocsTemplates_Procedures");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.PackageAdocsTemplateUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_PackageADocsTemplates_UpdatedBy");
            });

            modelBuilder.Entity<PackageDocument>(entity =>
            {
                entity.ToTable("PackageDocument");

                entity.Property(e => e.AntivirusCheckInfo).HasMaxLength(2000);

                entity.Property(e => e.ErrorMessage).HasMaxLength(2000);

                entity.Property(e => e.FileId).HasMaxLength(450);

                entity.Property(e => e.FileInfo).HasMaxLength(2000);

                entity.Property(e => e.FileName).HasMaxLength(500);

                entity.Property(e => e.FilePath).HasMaxLength(450);

                entity.Property(e => e.FileType).HasMaxLength(10);

                entity.Property(e => e.HashCode).HasMaxLength(100);

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.PackageDocumentCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_PackageDocument_AspNetUsers");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.PackageDocumentDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_PackageDocument_AspNetUsers2");

                entity.HasOne(d => d.DocType)
                    .WithMany(p => p.PackageDocuments)
                    .HasForeignKey(d => d.DocTypeId)
                    .HasConstraintName("FK_PackageDocument_ProcDocType");

                entity.HasOne(d => d.Package)
                    .WithMany(p => p.PackageDocuments)
                    .HasForeignKey(d => d.PackageId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_PackageDocument_Packages");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.PackageDocumentUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_PackageDocument_AspNetUsers1");
            });

            modelBuilder.Entity<Process>(entity =>
            {
                entity.ToTable("Process");

                entity.HasOne(d => d.ArchivalEntity)
                    .WithMany(p => p.Processes)
                    .HasForeignKey(d => d.ArchivalEntityId)
                    .HasConstraintName("FK_Process_ArchivalEntity");

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.Processes)
                    .HasForeignKey(d => d.ArchiveId)
                    .HasConstraintName("FK_Process_Archive");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.ProcessCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_Process_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.ProcessDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_Process_DeletedBy");

                entity.HasOne(d => d.Document)
                    .WithMany(p => p.Processes)
                    .HasForeignKey(d => d.DocumentId)
                    .HasConstraintName("FK_Process_Document");

                entity.HasOne(d => d.Fund)
                    .WithMany(p => p.Processes)
                    .HasForeignKey(d => d.FundId)
                    .HasConstraintName("FK_Process_Fund");

                entity.HasOne(d => d.Inventory)
                    .WithMany(p => p.Processes)
                    .HasForeignKey(d => d.InventoryId)
                    .HasConstraintName("FK_Process_Inventory");

                entity.HasOne(d => d.ProcessType)
                    .WithMany(p => p.Processes)
                    .HasForeignKey(d => d.ProcessTypeId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Process_ProcessType");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.ProcessUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_Process_UpdatedBy");
            });

            modelBuilder.Entity<ProcessRelatedStep>(entity =>
            {
                entity.HasKey(e => new { e.ProcessTypeId, e.StepId });

                entity.Property(e => e.AsigneeGoups).HasMaxLength(150);

                entity.HasOne(d => d.NextStep)
                    .WithMany(p => p.ProcessRelatedStepNextSteps)
                    .HasForeignKey(d => d.NextStepId)
                    .HasConstraintName("FK_ProcessRelatedSteps_ProcessSteps1");

                entity.HasOne(d => d.PrevStep)
                    .WithMany(p => p.ProcessRelatedStepPrevSteps)
                    .HasForeignKey(d => d.PrevStepId)
                    .HasConstraintName("FK_ProcessRelatedSteps_ProcessSteps2");

                entity.HasOne(d => d.ProcessType)
                    .WithMany(p => p.ProcessRelatedSteps)
                    .HasForeignKey(d => d.ProcessTypeId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_ProcessRelatedSteps_ProcessTypes");

                entity.HasOne(d => d.Step)
                    .WithMany(p => p.ProcessRelatedStepSteps)
                    .HasForeignKey(d => d.StepId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_ProcessRelatedSteps_ProcessSteps");
            });

            modelBuilder.Entity<ProcessStep>(entity =>
            {
                entity.ToTable("ProcessSteps", "N");

                entity.Property(e => e.Id).ValueGeneratedNever();

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.Text).HasMaxLength(250);

                entity.HasOne(d => d.ProcessType)
                    .WithMany(p => p.ProcessSteps)
                    .HasForeignKey(d => d.ProcessTypeId)
                    .HasConstraintName("FK_ProcessStep_ProcessType");
            });

            modelBuilder.Entity<ProcessTimeline>(entity =>
            {
                entity.ToTable("ProcessTimeline");

                entity.Property(e => e.Comment).HasMaxLength(1000);

                entity.HasOne(d => d.AssignedToRole)
                    .WithMany(p => p.ProcessTimelines)
                    .HasForeignKey(d => d.AssignedToRoleId)
                    .HasConstraintName("FK_ProcessTimeline_AssignedToRole");

                entity.HasOne(d => d.AssignedToUser)
                    .WithMany(p => p.ProcessTimelineAssignedToUsers)
                    .HasForeignKey(d => d.AssignedToUserId)
                    .HasConstraintName("FK_ProcessTimeline_AssignedTo");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.ProcessTimelineCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_ProcessTimeline_CreatedBy");

                entity.HasOne(d => d.Process)
                    .WithMany(p => p.ProcessTimelines)
                    .HasForeignKey(d => d.ProcessId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_ProcessTimeline_Process");

                entity.HasOne(d => d.StepType)
                    .WithMany(p => p.ProcessTimelines)
                    .HasForeignKey(d => d.StepTypeId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_ProcessTimeline_StepType");
            });

            modelBuilder.Entity<ProcessType>(entity =>
            {
                entity.ToTable("ProcessTypes", "N");

                entity.Property(e => e.Id).ValueGeneratedNever();

                entity.Property(e => e.Code).HasMaxLength(100);

                entity.Property(e => e.Type).HasMaxLength(50);
            });

            modelBuilder.Entity<ProcessTypeLevel>(entity =>
            {
                entity.HasKey(e => new { e.ProcessTypeId, e.EntityType });

                entity.Property(e => e.EntityType).HasMaxLength(50);

                entity.HasOne(d => d.ProcessType)
                    .WithMany(p => p.ProcessTypeLevels)
                    .HasForeignKey(d => d.ProcessTypeId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_ProcessTypeLevels_ProcessType");
            });

            modelBuilder.Entity<ReportResultType>(entity =>
            {
                entity.HasKey(e => e.Code);

                entity.ToTable("ReportResultType", "N");

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.Text).HasMaxLength(256);
            });

            modelBuilder.Entity<Schema>(entity =>
            {
                entity.HasKey(e => e.Version)
                    .HasName("PK_HangFire_Schema");

                entity.ToTable("Schema", "HangFire");

                entity.Property(e => e.Version).ValueGeneratedNever();
            });

            modelBuilder.Entity<Server>(entity =>
            {
                entity.ToTable("Server", "HangFire");

                entity.HasIndex(e => e.LastHeartbeat, "IX_HangFire_Server_LastHeartbeat");

                entity.Property(e => e.Id).HasMaxLength(200);

                entity.Property(e => e.LastHeartbeat).HasColumnType("datetime");
            });

            modelBuilder.Entity<Session>(entity =>
            {
                entity.Property(e => e.SessionType).HasMaxLength(100);

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.Sessions)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Sessions_Archive");

                entity.HasOne(d => d.Chairman)
                    .WithMany(p => p.SessionChairmen)
                    .HasForeignKey(d => d.ChairmanId)
                    .HasConstraintName("FK_Sessions_Chairman");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.SessionCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_Session_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.SessionDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_Session_DeletedBy");

                entity.HasOne(d => d.MinutesOfMeeting)
                    .WithMany(p => p.Sessions)
                    .HasForeignKey(d => d.MinutesOfMeetingId)
                    .HasConstraintName("FK_Session_MinutesOfMeeting");

                entity.HasOne(d => d.Secretary)
                    .WithMany(p => p.SessionSecretaries)
                    .HasForeignKey(d => d.SecretaryId)
                    .HasConstraintName("FK_Sessions_Secretary");

                entity.HasOne(d => d.SessionTypeNavigation)
                    .WithMany(p => p.Sessions)
                    .HasForeignKey(d => d.SessionType)
                    .HasConstraintName("FK_Sessions_SessionType");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.SessionUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_Session_UpdatedBy");
            });

            modelBuilder.Entity<SessionAgendaStandpoint>(entity =>
            {
                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.SessionAgendaStandpointCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_SessionAgendaStandpoint_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.SessionAgendaStandpointDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_SessionAgendaStandpoint_DeletedBy");

                entity.HasOne(d => d.Report)
                    .WithMany(p => p.SessionAgendaStandpoints)
                    .HasForeignKey(d => d.ReportId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_SessionAgendaStandpoint_CommissionReport");

                entity.HasOne(d => d.SessionAgendaItem)
                    .WithMany(p => p.SessionAgendaStandpoints)
                    .HasForeignKey(d => d.SessionAgendaItemId)
                    .HasConstraintName("FK_SessionAgendaStandpoint_SessionAgenda");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.SessionAgendaStandpointUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_SessionAgendaStandpoint_UpdatedBy");
            });

            modelBuilder.Entity<SessionAgendum>(entity =>
            {
                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.SessionAgendumCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_SessionAgenda_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.SessionAgendumDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_SessionAgenda_DeletedBy");

                entity.HasOne(d => d.Process)
                    .WithMany(p => p.SessionAgenda)
                    .HasForeignKey(d => d.ProcessId)
                    .HasConstraintName("FK_SessionAgenda_Process");

                entity.HasOne(d => d.Report)
                    .WithMany(p => p.SessionAgenda)
                    .HasForeignKey(d => d.ReportId)
                    .HasConstraintName("FK_SessionAgenda_Report");

                entity.HasOne(d => d.Session)
                    .WithMany(p => p.SessionAgenda)
                    .HasForeignKey(d => d.SessionId)
                    .HasConstraintName("FK_SessionAgenda_Session");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.SessionAgendumUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_SessionAgenda_UpdatedBy");
            });

            modelBuilder.Entity<SessionDecision>(entity =>
            {
                entity.Property(e => e.IsDraft)
                    .IsRequired()
                    .HasDefaultValueSql("((1))");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.SessionDecisionCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_SessionDecisions_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.SessionDecisionDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_SessionDecisions_DeletedBy");

                entity.HasOne(d => d.SessionAgenda)
                    .WithMany(p => p.SessionDecisions)
                    .HasForeignKey(d => d.SessionAgendaId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_SessionDecisions_SessionAgenda");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.SessionDecisionUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_SessionDecisions_UpdatedBy");
            });

            modelBuilder.Entity<SessionMinutesOfMeeting>(entity =>
            {
                entity.ToTable("SessionMinutesOfMeeting");

                entity.Property(e => e.IsDraft)
                    .IsRequired()
                    .HasDefaultValueSql("((1))");

                entity.Property(e => e.Number).HasMaxLength(50);

                entity.Property(e => e.Status).HasMaxLength(50);

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.SessionMinutesOfMeetingCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_SessionMinOfMeeting_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.SessionMinutesOfMeetingDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_SessionMinOfMeeting_DeletedBy");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.SessionMinutesOfMeetingUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_SessionMinOfMeeting_UpdatedBy");
            });

            modelBuilder.Entity<SessionType>(entity =>
            {
                entity.HasKey(e => e.Code)
                    .HasName("PK__SessionT__A25C5AA6697C70E6");

                entity.ToTable("SessionTypes", "N");

                entity.Property(e => e.Code).HasMaxLength(100);

                entity.Property(e => e.Text).HasMaxLength(250);
            });

            modelBuilder.Entity<Set>(entity =>
            {
                entity.HasKey(e => new { e.Key, e.Value })
                    .HasName("PK_HangFire_Set");

                entity.ToTable("Set", "HangFire");

                entity.HasIndex(e => e.ExpireAt, "IX_HangFire_Set_ExpireAt")
                    .HasFilter("([ExpireAt] IS NOT NULL)");

                entity.HasIndex(e => new { e.Key, e.Score }, "IX_HangFire_Set_Score");

                entity.Property(e => e.Key).HasMaxLength(100);

                entity.Property(e => e.Value).HasMaxLength(256);

                entity.Property(e => e.ExpireAt).HasColumnType("datetime");
            });

            modelBuilder.Entity<SignatureRequest>(entity =>
            {
                entity.HasOne(d => d.Application)
                    .WithMany(p => p.SignatureRequests)
                    .HasForeignKey(d => d.ApplicationId)
                    .HasConstraintName("FK_SignatureRequests_Application");

                entity.HasOne(d => d.Archive)
                    .WithMany(p => p.SignatureRequests)
                    .HasForeignKey(d => d.ArchiveId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_SignatureRequests_Archive");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.SignatureRequestCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_SignatureRequests_CreatedBy");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.SignatureRequestDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_SignatureRequests_DeletedBy");

                entity.HasOne(d => d.PackageDocument)
                    .WithMany(p => p.SignatureRequests)
                    .HasForeignKey(d => d.PackageDocumentId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_SignatureRequests_PackageDocument");

                entity.HasOne(d => d.Package)
                    .WithMany(p => p.SignatureRequests)
                    .HasForeignKey(d => d.PackageId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_SignatureRequests_Package");

                entity.HasOne(d => d.Process)
                    .WithMany(p => p.SignatureRequests)
                    .HasForeignKey(d => d.ProcessId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_SignatureRequests_Process");

                entity.HasOne(d => d.ProcessStep)
                    .WithMany(p => p.SignatureRequests)
                    .HasForeignKey(d => d.ProcessStepId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_SignatureRequests_ProcessTimeline");

                entity.HasOne(d => d.SigningUser)
                    .WithMany(p => p.SignatureRequestSigningUsers)
                    .HasForeignKey(d => d.SigningUserId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_SignatureRequests_SigningUser");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.SignatureRequestUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_SignatureRequests_UpdatedBy");
            });

            modelBuilder.Entity<State>(entity =>
            {
                entity.HasKey(e => new { e.JobId, e.Id })
                    .HasName("PK_HangFire_State");

                entity.ToTable("State", "HangFire");

                entity.Property(e => e.Id).ValueGeneratedOnAdd();

                entity.Property(e => e.CreatedAt).HasColumnType("datetime");

                entity.Property(e => e.Name).HasMaxLength(20);

                entity.Property(e => e.Reason).HasMaxLength(100);

                entity.HasOne(d => d.Job)
                    .WithMany(p => p.States)
                    .HasForeignKey(d => d.JobId)
                    .HasConstraintName("FK_HangFire_State_Job");
            });

            modelBuilder.Entity<Status>(entity =>
            {
                entity.HasKey(e => e.Code)
                    .HasName("PK_N.Status");

                entity.ToTable("Status", "N");

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.Text).HasMaxLength(256);
            });

            modelBuilder.Entity<Task>(entity =>
            {
                entity.Property(e => e.NotificationType).HasMaxLength(50);

                entity.Property(e => e.RelatedEntityType).HasMaxLength(50);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.Title).HasMaxLength(255);

                entity.HasOne(d => d.AssignedToRole)
                    .WithMany(p => p.Tasks)
                    .HasForeignKey(d => d.AssignedToRoleId)
                    .HasConstraintName("FK_Tasks_AssignedToRoleId");

                entity.HasOne(d => d.AssignedToUser)
                    .WithMany(p => p.TaskAssignedToUsers)
                    .HasForeignKey(d => d.AssignedToUserId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Tasks_AssignedToUser");

                entity.HasOne(d => d.CreatedByNavigation)
                    .WithMany(p => p.TaskCreatedByNavigations)
                    .HasForeignKey(d => d.CreatedBy)
                    .HasConstraintName("FK_Tasks_CreatedByUser");

                entity.HasOne(d => d.DeletedByNavigation)
                    .WithMany(p => p.TaskDeletedByNavigations)
                    .HasForeignKey(d => d.DeletedBy)
                    .HasConstraintName("FK_Tasks_DeletedByUser");

                entity.HasOne(d => d.NotificationTypeNavigation)
                    .WithMany(p => p.Tasks)
                    .HasForeignKey(d => d.NotificationType)
                    .HasConstraintName("FK_Tasks_NotificationType");

                entity.HasOne(d => d.Process)
                    .WithMany(p => p.Tasks)
                    .HasForeignKey(d => d.ProcessId)
                    .HasConstraintName("FK_Tasks_Process");

                entity.HasOne(d => d.StatusCodeNavigation)
                    .WithMany(p => p.Tasks)
                    .HasForeignKey(d => d.StatusCode)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Task_Status");

                entity.HasOne(d => d.Step)
                    .WithMany(p => p.Tasks)
                    .HasForeignKey(d => d.StepId)
                    .HasConstraintName("FK_Tasks_TimelineStep");

                entity.HasOne(d => d.UpdatedByNavigation)
                    .WithMany(p => p.TaskUpdatedByNavigations)
                    .HasForeignKey(d => d.UpdatedBy)
                    .HasConstraintName("FK_Tasks_UpdatedByUser");
            });

            modelBuilder.Entity<TaskStatus>(entity =>
            {
                entity.HasKey(e => e.Code);

                entity.ToTable("TaskStatus", "N");

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.Text).HasMaxLength(255);
            });

            modelBuilder.Entity<TaskTemplate>(entity =>
            {
                entity.Property(e => e.NotificationType).HasMaxLength(50);

                entity.Property(e => e.RelatedContentUrl).HasMaxLength(255);

                entity.Property(e => e.Title).HasMaxLength(255);

                entity.HasOne(d => d.NotificationTypeNavigation)
                    .WithMany(p => p.TaskTemplates)
                    .HasForeignKey(d => d.NotificationType)
                    .HasConstraintName("FK_TaskTemplates_NotificationType");

                entity.HasOne(d => d.ProcessStepType)
                    .WithMany(p => p.TaskTemplates)
                    .HasForeignKey(d => d.ProcessStepTypeId)
                    .HasConstraintName("FK_TaskTemplate_StepType");

                entity.HasMany(d => d.ProcessSteps)
                    .WithMany(p => p.TaskTemplatesNavigation)
                    .UsingEntity<Dictionary<string, object>>(
                        "TaskTemplatesStep",
                        l => l.HasOne<ProcessStep>().WithMany().HasForeignKey("ProcessStepId").OnDelete(DeleteBehavior.ClientSetNull).HasConstraintName("FK__TaskTempl__Proce__561FABFB"),
                        r => r.HasOne<TaskTemplate>().WithMany().HasForeignKey("TaskTemplateId").OnDelete(DeleteBehavior.ClientSetNull).HasConstraintName("FK__TaskTempl__TaskT__552B87C2"),
                        j =>
                        {
                            j.HasKey("TaskTemplateId", "ProcessStepId").HasName("PK__TaskTemp__9DB6AE06648922C9");

                            j.ToTable("TaskTemplatesSteps");

                            j.IndexerProperty<int>("TaskTemplateId").HasColumnName("TaskTemplate_Id");

                            j.IndexerProperty<int>("ProcessStepId").HasColumnName("ProcessStep_Id");
                        });
            });

            modelBuilder.Entity<UserReview>(entity =>
            {
                entity.HasIndex(e => e.SystemIdentifier, "UI_UserReviewsSystemIdentifier")
                    .IsUnique();

                entity.HasOne(d => d.User)
                    .WithMany(p => p.UserReviews)
                    .HasForeignKey(d => d.UserId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__UserRevie__UserI__6073E893");
            });

            modelBuilder.Entity<VApiPublicDigitalObject>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_ApiPublicDigitalObjects");

                entity.Property(e => e.ApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.ArchivalEntityNumber).HasMaxLength(50);

                entity.Property(e => e.ArchiveName).HasMaxLength(255);

                entity.Property(e => e.CreatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.DocumentNumber).HasMaxLength(50);

                entity.Property(e => e.FileType).HasMaxLength(50);

                entity.Property(e => e.FundNumber).HasMaxLength(50);

                entity.Property(e => e.InventoryNumber).HasMaxLength(50);
            });

            modelBuilder.Entity<VArchivalEntity>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_ArchivalEntities");

                entity.Property(e => e.ApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.ArchiveName).HasMaxLength(255);

                entity.Property(e => e.AvailabilityStatusText).HasMaxLength(256);

                entity.Property(e => e.ClassificationSchemeIndex).HasMaxLength(250);

                entity.Property(e => e.CreatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.CreatedByUserName).HasMaxLength(256);

                entity.Property(e => e.DeletedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.DeletedByUserName).HasMaxLength(256);

                entity.Property(e => e.DescriptionAuthor).HasMaxLength(250);

                entity.Property(e => e.DescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.DescriptionLevelText).HasMaxLength(256);

                entity.Property(e => e.FundNumber).HasMaxLength(50);

                entity.Property(e => e.FundNumberArray).HasMaxLength(50);

                entity.Property(e => e.InventoryNumber).HasMaxLength(50);

                entity.Property(e => e.InventoryNumberArray).HasMaxLength(50);

                entity.Property(e => e.Number).HasMaxLength(50);

                entity.Property(e => e.NumberArray).HasMaxLength(250);

                entity.Property(e => e.OtherMetrics).HasMaxLength(256);

                entity.Property(e => e.Scaling).HasMaxLength(256);

                entity.Property(e => e.SizeCm).HasMaxLength(256);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.StatusText).HasMaxLength(256);

                entity.Property(e => e.UpdatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.UpdatedByUserName).HasMaxLength(256);
            });

            modelBuilder.Entity<VArchivalEntitySizeInfo>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_ArchivalEntitySizeInfo");
            });

            modelBuilder.Entity<VAuditLog>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_AuditLogs", "A");

                entity.Property(e => e.ClientIp).HasMaxLength(40);

                entity.Property(e => e.CorrelationId).HasMaxLength(36);

                entity.Property(e => e.CreatedByUsername).HasMaxLength(256);

                entity.Property(e => e.EntityName).HasMaxLength(255);

                entity.Property(e => e.StateName).HasMaxLength(255);
            });

            modelBuilder.Entity<VAuditLogsWithDetail>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_AuditLogsWithDetails", "A");

                entity.Property(e => e.ClientIp).HasMaxLength(40);

                entity.Property(e => e.CorrelationId).HasMaxLength(36);

                entity.Property(e => e.CreatedByUsername).HasMaxLength(256);

                entity.Property(e => e.EntityName).HasMaxLength(255);

                entity.Property(e => e.StateName).HasMaxLength(255);
            });

            modelBuilder.Entity<VDigitalObject>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_DigitalObjects");

                entity.Property(e => e.ArchivalEntityNumber).HasMaxLength(50);

                entity.Property(e => e.ArchiveName).HasMaxLength(255);

                entity.Property(e => e.AvailabilityStatusText).HasMaxLength(256);

                entity.Property(e => e.CreatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.CreatedByUserName).HasMaxLength(256);

                entity.Property(e => e.DeletedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.DeletedByUserName).HasMaxLength(256);

                entity.Property(e => e.DocumentNumber).HasMaxLength(50);

                entity.Property(e => e.FileType).HasMaxLength(50);

                entity.Property(e => e.FundNumber).HasMaxLength(50);

                entity.Property(e => e.HashCode).HasMaxLength(100);

                entity.Property(e => e.InventoryNumber).HasMaxLength(50);

                entity.Property(e => e.Name).HasMaxLength(255);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.UpdatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.UpdatedByUserName).HasMaxLength(256);
            });

            modelBuilder.Entity<VDigitalObjectSizeInfo>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_DigitalObjectSizeInfo");

                entity.Property(e => e.DosystemIdentifier).HasColumnName("DOSystemIdentifier");

                entity.Property(e => e.FileType).HasMaxLength(50);
            });

            modelBuilder.Entity<VDocument>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_Documents");

                entity.Property(e => e.ApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.ArchivalEntityDescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.ArchivalEntityNumber).HasMaxLength(50);

                entity.Property(e => e.ArchivalEntityNumberArray).HasMaxLength(250);

                entity.Property(e => e.ArchivalEntityStatusCode).HasMaxLength(50);

                entity.Property(e => e.ArchiveName).HasMaxLength(255);

                entity.Property(e => e.AvailabilityStatusText).HasMaxLength(256);

                entity.Property(e => e.CreatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.CreatedByUserName).HasMaxLength(256);

                entity.Property(e => e.DeletedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.DeletedByUserName).HasMaxLength(256);

                entity.Property(e => e.DescriptionAuthor).HasMaxLength(250);

                entity.Property(e => e.DescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.DescriptionLevelText).HasMaxLength(256);

                entity.Property(e => e.FileFormatCode).HasMaxLength(50);

                entity.Property(e => e.FundDescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.FundNumber).HasMaxLength(50);

                entity.Property(e => e.FundNumberArray).HasMaxLength(50);

                entity.Property(e => e.FundStatusCode).HasMaxLength(50);

                entity.Property(e => e.InventoryDescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.InventoryNumber).HasMaxLength(50);

                entity.Property(e => e.InventoryNumberArray).HasMaxLength(50);

                entity.Property(e => e.InventoryStatusCode).HasMaxLength(50);

                entity.Property(e => e.Number).HasMaxLength(50);

                entity.Property(e => e.OtherMetrics).HasMaxLength(256);

                entity.Property(e => e.Scaling).HasMaxLength(256);

                entity.Property(e => e.SizeCm).HasMaxLength(256);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.StatusText).HasMaxLength(256);

                entity.Property(e => e.UpdatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.UpdatedByUserName).HasMaxLength(256);
            });

            modelBuilder.Entity<VDocumentSizeInfo>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_DocumentSizeInfo");
            });

            modelBuilder.Entity<VFilm>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_Films");

                entity.Property(e => e.ArchiveName).HasMaxLength(255);

                entity.Property(e => e.CountryCode).HasMaxLength(50);

                entity.Property(e => e.CountryName).HasMaxLength(256);

                entity.Property(e => e.CreatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.CreatedByUserName).HasMaxLength(256);

                entity.Property(e => e.DeletedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.DeletedByUserName).HasMaxLength(256);

                entity.Property(e => e.DigitalCopy).HasMaxLength(250);

                entity.Property(e => e.PackageAid).HasColumnName("PackageAId");

                entity.Property(e => e.PackageBid).HasColumnName("PackageBId");

                entity.Property(e => e.PhotoCopy).HasMaxLength(250);

                entity.Property(e => e.Size).HasMaxLength(250);

                entity.Property(e => e.Source).HasMaxLength(250);

                entity.Property(e => e.UpdatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.UpdatedByUserName).HasMaxLength(256);
            });

            modelBuilder.Entity<VFilmCard>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_FilmCards");

                entity.Property(e => e.AproximateDate).HasMaxLength(250);

                entity.Property(e => e.ArchiveName).HasMaxLength(255);

                entity.Property(e => e.ArchiveOriginals).HasMaxLength(2000);

                entity.Property(e => e.City).HasMaxLength(250);

                entity.Property(e => e.CountryCode).HasMaxLength(50);

                entity.Property(e => e.CountryName).HasMaxLength(256);

                entity.Property(e => e.CreatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.CreatedByUserName).HasMaxLength(256);

                entity.Property(e => e.DeletedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.DeletedByUserName).HasMaxLength(256);

                entity.Property(e => e.DigitalCopy).HasMaxLength(250);

                entity.Property(e => e.DocumentsCypher).HasMaxLength(2000);

                entity.Property(e => e.DocumentsFormat).HasMaxLength(250);

                entity.Property(e => e.FilmingExtentName).HasMaxLength(256);

                entity.Property(e => e.InventoryNumber).HasMaxLength(50);

                entity.Property(e => e.PhotoCopy).HasMaxLength(250);

                entity.Property(e => e.Size).HasMaxLength(250);

                entity.Property(e => e.Source).HasMaxLength(250);

                entity.Property(e => e.Title).HasMaxLength(500);

                entity.Property(e => e.UpdatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.UpdatedByUserName).HasMaxLength(256);
            });

            modelBuilder.Entity<VFilmDocument>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_FilmDocuments");

                entity.Property(e => e.ArchiveName).HasMaxLength(255);

                entity.Property(e => e.DocumentTypeCode).HasMaxLength(50);

                entity.Property(e => e.DocumentTypeText).HasMaxLength(250);

                entity.Property(e => e.FileId).HasMaxLength(450);

                entity.Property(e => e.FileName).HasMaxLength(500);

                entity.Property(e => e.FilePath).HasMaxLength(450);

                entity.Property(e => e.FileType).HasMaxLength(10);

                entity.Property(e => e.HashCode).HasMaxLength(100);

                entity.Property(e => e.PackageAid).HasColumnName("PackageAId");

                entity.Property(e => e.PackageBid).HasColumnName("PackageBId");

                entity.Property(e => e.PackageType).HasMaxLength(1);
            });

            modelBuilder.Entity<VFilmReview>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_FilmReviews");

                entity.Property(e => e.CreatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.CreatedByUserName).HasMaxLength(256);

                entity.Property(e => e.DeletedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.DeletedByUserName).HasMaxLength(256);

                entity.Property(e => e.FilmNumber).HasMaxLength(256);

                entity.Property(e => e.ReaderName).HasMaxLength(256);

                entity.Property(e => e.UpdatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.UpdatedByUserName).HasMaxLength(256);

                entity.Property(e => e.Username).HasMaxLength(256);
            });

            modelBuilder.Entity<VFund>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_Funds");

                entity.Property(e => e.AcquisitionMethodCode).HasMaxLength(50);

                entity.Property(e => e.AcquisitionMethodText).HasMaxLength(256);

                entity.Property(e => e.ApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.ArchiveName).HasMaxLength(255);

                entity.Property(e => e.CreatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.CreatedByUserName).HasMaxLength(256);

                entity.Property(e => e.DeletedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.DeletedByUserName).HasMaxLength(256);

                entity.Property(e => e.DescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.DescriptionLevelText).HasMaxLength(256);

                entity.Property(e => e.Number).HasMaxLength(50);

                entity.Property(e => e.NumberArray).HasMaxLength(50);

                entity.Property(e => e.OtherMetrics).HasMaxLength(256);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.StatusText).HasMaxLength(256);

                entity.Property(e => e.TypeCode).HasMaxLength(50);

                entity.Property(e => e.TypeText).HasMaxLength(256);

                entity.Property(e => e.UpdatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.UpdatedByUserName).HasMaxLength(256);
            });

            modelBuilder.Entity<VFundReconstruction>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_FundReconstructions");

                entity.Property(e => e.ArchiveName).HasMaxLength(255);

                entity.Property(e => e.AvailabilityStatusText).HasMaxLength(256);

                entity.Property(e => e.CreatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.CreatedByUserName).HasMaxLength(256);

                entity.Property(e => e.DeletedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.DeletedByUserName).HasMaxLength(256);

                entity.Property(e => e.FundNumber).HasMaxLength(50);

                entity.Property(e => e.SourceArchivalEntityApproximateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.SourceArchivalEntityAvailabilityStatusText).HasMaxLength(256);

                entity.Property(e => e.SourceArchivalEntityDescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.SourceArchivalEntityDescriptionLevelText).HasMaxLength(256);

                entity.Property(e => e.SourceArchivalEntityNumber).HasMaxLength(50);

                entity.Property(e => e.SourceDocumentApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.SourceDocumentAvailabilityStatusText).HasMaxLength(256);

                entity.Property(e => e.SourceDocumentDescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.SourceDocumentDescriptionLevelText).HasMaxLength(256);

                entity.Property(e => e.SourceInventoryApproximateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.SourceInventoryAvailabilityStatusText).HasMaxLength(256);

                entity.Property(e => e.SourceInventoryDescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.SourceInventoryDescriptionLevelText).HasMaxLength(256);

                entity.Property(e => e.SourceInventoryNumber).HasMaxLength(50);

                entity.Property(e => e.TargetArchivalEntityApproximateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.TargetArchivalEntityAvailabilityStatusText).HasMaxLength(256);

                entity.Property(e => e.TargetArchivalEntityDescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.TargetArchivalEntityDescriptionLevelText).HasMaxLength(256);

                entity.Property(e => e.TargetArchivalEntityNumber).HasMaxLength(50);

                entity.Property(e => e.TargetDocumentApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.TargetDocumentAvailabilityStatusText).HasMaxLength(256);

                entity.Property(e => e.TargetDocumentDescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.TargetDocumentDescriptionLevelText).HasMaxLength(256);

                entity.Property(e => e.TargetInventoryApproximateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.TargetInventoryAvailabilityStatusText).HasMaxLength(256);

                entity.Property(e => e.TargetInventoryDescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.TargetInventoryDescriptionLevelText).HasMaxLength(256);

                entity.Property(e => e.TargetInventoryNumber).HasMaxLength(50);

                entity.Property(e => e.UpdatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.UpdatedByUserName).HasMaxLength(256);
            });

            modelBuilder.Entity<VFundSizeInfo>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_FundSizeInfo");
            });

            modelBuilder.Entity<VInventory>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_Inventories");

                entity.Property(e => e.AcquisitionMethodCode).HasMaxLength(50);

                entity.Property(e => e.AcquisitionMethodText).HasMaxLength(256);

                entity.Property(e => e.ApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.ArchiveName).HasMaxLength(255);

                entity.Property(e => e.AvailabilityStatusText).HasMaxLength(256);

                entity.Property(e => e.CreatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.CreatedByUserName).HasMaxLength(256);

                entity.Property(e => e.DeletedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.DeletedByUserName).HasMaxLength(256);

                entity.Property(e => e.DescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.DescriptionLevelText).HasMaxLength(256);

                entity.Property(e => e.FundNumber).HasMaxLength(50);

                entity.Property(e => e.Number).HasMaxLength(50);

                entity.Property(e => e.NumberArray).HasMaxLength(50);

                entity.Property(e => e.OtherLanguage).HasMaxLength(250);

                entity.Property(e => e.OtherMetrics).HasMaxLength(256);

                entity.Property(e => e.PackageAid).HasColumnName("PackageAId");

                entity.Property(e => e.PackageBid).HasColumnName("PackageBId");

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.StatusText).HasMaxLength(256);

                entity.Property(e => e.UpdatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.UpdatedByUserName).HasMaxLength(256);
            });

            modelBuilder.Entity<VInventorySizeInfo>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_InventorySizeInfo");
            });

            modelBuilder.Entity<VPublicArchivalEntity>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_PublicArchivalEntities");

                entity.Property(e => e.ApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.ArchiveName).HasMaxLength(255);

                entity.Property(e => e.AvailabilityStatusText).HasMaxLength(256);

                entity.Property(e => e.CreatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.CreatedByUserName).HasMaxLength(256);

                entity.Property(e => e.DeletedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.DeletedByUserName).HasMaxLength(256);

                entity.Property(e => e.DescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.DescriptionLevelText).HasMaxLength(256);

                entity.Property(e => e.FundNumber).HasMaxLength(50);

                entity.Property(e => e.InventoryNumber).HasMaxLength(50);

                entity.Property(e => e.Number).HasMaxLength(50);

                entity.Property(e => e.NumberArray).HasMaxLength(250);

                entity.Property(e => e.OtherMetrics).HasMaxLength(256);

                entity.Property(e => e.Scaling).HasMaxLength(256);

                entity.Property(e => e.SizeCm).HasMaxLength(256);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.StatusText).HasMaxLength(256);

                entity.Property(e => e.UpdatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.UpdatedByUserName).HasMaxLength(256);
            });

            modelBuilder.Entity<VPublicDigitalObject>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_PublicDigitalObjects");

                entity.Property(e => e.ArchivalEntityNumber).HasMaxLength(50);

                entity.Property(e => e.ArchiveName).HasMaxLength(255);

                entity.Property(e => e.AvailabilityStatusText).HasMaxLength(256);

                entity.Property(e => e.CreatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.CreatedByUserName).HasMaxLength(256);

                entity.Property(e => e.DeletedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.DeletedByUserName).HasMaxLength(256);

                entity.Property(e => e.DocumentNumber).HasMaxLength(50);

                entity.Property(e => e.FileType).HasMaxLength(50);

                entity.Property(e => e.FundNumber).HasMaxLength(50);

                entity.Property(e => e.HashCode).HasMaxLength(100);

                entity.Property(e => e.InventoryNumber).HasMaxLength(50);

                entity.Property(e => e.Name).HasMaxLength(255);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.UpdatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.UpdatedByUserName).HasMaxLength(256);
            });

            modelBuilder.Entity<VPublicDocument>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_PublicDocuments");

                entity.Property(e => e.ApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.ArchivalEntityDescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.ArchivalEntityNumber).HasMaxLength(50);

                entity.Property(e => e.ArchivalEntityNumberArray).HasMaxLength(250);

                entity.Property(e => e.ArchivalEntityStatusCode).HasMaxLength(50);

                entity.Property(e => e.ArchiveName).HasMaxLength(255);

                entity.Property(e => e.AvailabilityStatusText).HasMaxLength(256);

                entity.Property(e => e.CreatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.CreatedByUserName).HasMaxLength(256);

                entity.Property(e => e.DeletedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.DeletedByUserName).HasMaxLength(256);

                entity.Property(e => e.DescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.DescriptionLevelText).HasMaxLength(256);

                entity.Property(e => e.FileFormatCode).HasMaxLength(50);

                entity.Property(e => e.FundDescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.FundNumber).HasMaxLength(50);

                entity.Property(e => e.FundNumberArray).HasMaxLength(50);

                entity.Property(e => e.FundStatusCode).HasMaxLength(50);

                entity.Property(e => e.InventoryDescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.InventoryNumber).HasMaxLength(50);

                entity.Property(e => e.InventoryNumberArray).HasMaxLength(50);

                entity.Property(e => e.InventoryStatusCode).HasMaxLength(50);

                entity.Property(e => e.Number).HasMaxLength(50);

                entity.Property(e => e.OtherMetrics).HasMaxLength(256);

                entity.Property(e => e.Scaling).HasMaxLength(256);

                entity.Property(e => e.SizeCm).HasMaxLength(256);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.StatusText).HasMaxLength(256);

                entity.Property(e => e.UpdatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.UpdatedByUserName).HasMaxLength(256);
            });

            modelBuilder.Entity<VPublicFilm>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_PublicFilms");

                entity.Property(e => e.ArchiveName).HasMaxLength(255);

                entity.Property(e => e.CountryCode).HasMaxLength(50);
            });

            modelBuilder.Entity<VPublicFilmCard>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_PublicFilmCards");

                entity.Property(e => e.ArchiveName).HasMaxLength(255);

                entity.Property(e => e.CountryCode).HasMaxLength(50);

                entity.Property(e => e.InventoryNumber).HasMaxLength(50);

                entity.Property(e => e.Title).HasMaxLength(500);
            });

            modelBuilder.Entity<VPublicFund>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_PublicFunds");

                entity.Property(e => e.ApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.ArchiveName).HasMaxLength(255);

                entity.Property(e => e.CreatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.CreatedByUserName).HasMaxLength(256);

                entity.Property(e => e.DeletedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.DeletedByUserName).HasMaxLength(256);

                entity.Property(e => e.DescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.DescriptionLevelText).HasMaxLength(256);

                entity.Property(e => e.Number).HasMaxLength(50);

                entity.Property(e => e.NumberArray).HasMaxLength(50);

                entity.Property(e => e.OtherMetrics).HasMaxLength(256);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.StatusText).HasMaxLength(256);

                entity.Property(e => e.TypeCode).HasMaxLength(50);

                entity.Property(e => e.TypeText).HasMaxLength(256);

                entity.Property(e => e.UpdatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.UpdatedByUserName).HasMaxLength(256);
            });

            modelBuilder.Entity<VPublicInventory>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_PublicInventories");

                entity.Property(e => e.ApproxmateChronologicalScope).HasMaxLength(256);

                entity.Property(e => e.ArchiveName).HasMaxLength(255);

                entity.Property(e => e.AvailabilityStatusText).HasMaxLength(256);

                entity.Property(e => e.CreatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.CreatedByUserName).HasMaxLength(256);

                entity.Property(e => e.DeletedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.DeletedByUserName).HasMaxLength(256);

                entity.Property(e => e.DescriptionLevelCode).HasMaxLength(50);

                entity.Property(e => e.DescriptionLevelText).HasMaxLength(256);

                entity.Property(e => e.FundNumber).HasMaxLength(50);

                entity.Property(e => e.Number).HasMaxLength(50);

                entity.Property(e => e.NumberArray).HasMaxLength(50);

                entity.Property(e => e.OtherMetrics).HasMaxLength(256);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.StatusText).HasMaxLength(256);

                entity.Property(e => e.UpdatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.UpdatedByUserName).HasMaxLength(256);
            });

            modelBuilder.Entity<VTask>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("v_Tasks");

                entity.Property(e => e.AssignedToDisplayName).HasMaxLength(770);

                entity.Property(e => e.AssignedToRoleName).HasMaxLength(256);

                entity.Property(e => e.AssignedToUserName).HasMaxLength(256);

                entity.Property(e => e.CreatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.CreatedByUserName).HasMaxLength(256);

                entity.Property(e => e.DeletedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.DeletedByUserName).HasMaxLength(256);

                entity.Property(e => e.NotificationType).HasMaxLength(50);

                entity.Property(e => e.NotificationTypeName).HasMaxLength(256);

                entity.Property(e => e.RelatedEntityType).HasMaxLength(50);

                entity.Property(e => e.StatusCode).HasMaxLength(50);

                entity.Property(e => e.StatusName).HasMaxLength(255);

                entity.Property(e => e.StepTypeName).HasMaxLength(250);

                entity.Property(e => e.Title).HasMaxLength(255);

                entity.Property(e => e.UpdatedByDisplayName).HasMaxLength(770);

                entity.Property(e => e.UpdatedByUserName).HasMaxLength(256);
            });

            modelBuilder.Entity<Version>(entity =>
            {
                entity.HasKey(e => e.Code)
                    .HasName("PK_Version");

                entity.ToTable("_Version");

                entity.Property(e => e.Code).HasMaxLength(50);

                entity.Property(e => e.Value).HasMaxLength(50);
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
