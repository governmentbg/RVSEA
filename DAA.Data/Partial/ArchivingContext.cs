using DAA.Shared.Data;
using DAA.Shared.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using System.Linq;
using Z.EntityFramework.Plus;

namespace DAA.Data
{
    public partial class ArchivingContext
    {
        private readonly IUserInfo _userInfo;
        private string? _auditEntryDescription;

        public IUserInfo UserInfo => this._userInfo;

        static ArchivingContext()
        {
            ConfigureAuditManager();
        }

        public ArchivingContext(DbContextOptions<ArchivingContext> options,
            IUserInfo userInfo)
            : base(options)
        {
            _userInfo = userInfo;
        }

        public virtual async Task<int> SaveAsync(string? description, bool overwriteCreated = false, bool overwriteModified = false, CancellationToken cancellationToken = default)
        {
            _auditEntryDescription = description;
            
            DateTime utcNow = DateTime.UtcNow;

            if (!overwriteCreated)
            { 
                foreach (EntityEntry<ICreatable> entry in ChangeTracker.Entries<ICreatable>())
                {
                    if (entry.State == EntityState.Added)
                    {
                        if (_userInfo != null && _userInfo.CurrentUserId != Guid.Empty)
                        {
                            entry.Entity.CreatedBy = _userInfo.CurrentUserId;
                        }
                        entry.Entity.CreatedOn = utcNow;
                    }
                }
            }

            if (!overwriteModified)
            { 
                foreach (EntityEntry<IEditable> entry in ChangeTracker.Entries<IEditable>())
                {
                    if (entry.State == EntityState.Modified)
                    {
                        if (_userInfo != null && _userInfo.CurrentUserId != Guid.Empty)
                        { 
                            entry.Entity.UpdatedBy = _userInfo.CurrentUserId;
                        }
                        entry.Entity.UpdatedOn = utcNow;
                    }
                }
            }

            foreach (EntityEntry<IDeletable> entry in ChangeTracker.Entries<IDeletable>())
            {
                if (entry.State == EntityState.Deleted || entry.Entity.Deleted)
                {
                    if (_userInfo != null && _userInfo.CurrentUserId != Guid.Empty)
                    {
                        entry.Entity.DeletedBy = _userInfo.CurrentUserId;
                    }
                        
                    entry.Entity.DeletedOn = utcNow;
                }
            }

            var audit = new Z.EntityFramework.Plus.Audit();
            audit.PreSaveChanges(this);
            int rowAffecteds = await base.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            audit.PostSaveChanges();

            if (audit.Configuration.AutoSavePreAction != null)
            {
                audit.Configuration.AutoSavePreAction(this, audit);
                await base.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            }

            return rowAffecteds;
        }

        public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            return SaveAsync(null, false, false, cancellationToken);
        }

        public override int SaveChanges()
        {
            DateTime utcNow = DateTime.UtcNow;

            foreach (EntityEntry<ICreatable> entry in ChangeTracker.Entries<ICreatable>())
            {
                if (entry.State == EntityState.Added)
                {
                    if (_userInfo != null && _userInfo.CurrentUserId != Guid.Empty)
                    {
                        entry.Entity.CreatedBy = _userInfo.CurrentUserId;
                    }
                    entry.Entity.CreatedOn = utcNow;
                }
            }

            foreach (EntityEntry<IEditable> entry in ChangeTracker.Entries<IEditable>())
            {
                if (entry.State == EntityState.Modified)
                {
                    if (_userInfo != null && _userInfo.CurrentUserId != Guid.Empty)
                    {
                        entry.Entity.UpdatedBy = _userInfo.CurrentUserId;
                    }
                    entry.Entity.UpdatedOn = utcNow;
                }
            }

            foreach (EntityEntry<IDeletable> entry in ChangeTracker.Entries<IDeletable>())
            {
                if (entry.State == EntityState.Deleted || entry.Entity.Deleted)
                {
                    if (_userInfo != null && _userInfo.CurrentUserId != Guid.Empty)
                    {
                        entry.Entity.DeletedBy = _userInfo.CurrentUserId;
                    }

                    entry.Entity.DeletedOn = utcNow;
                }
            }

            var audit = new Z.EntityFramework.Plus.Audit();
            audit.PreSaveChanges(this);
            int rowAffecteds = base.SaveChanges();
            audit.PostSaveChanges();

            if (audit.Configuration.AutoSavePreAction != null)
            {
                audit.Configuration.AutoSavePreAction(this, audit);
                base.SaveChanges();
            }

            return rowAffecteds;
        }

        public static void ConfigureAuditManager()
        {
            // You can choose to ignore or not property unchanged with IgnorePropertyUnchanged.
            // By default, properties unchanged are ignored unless it's part of the primary key.
            //AuditManager.DefaultConfiguration.IgnorePropertyUnchanged = true;

            AuditManager.DefaultConfiguration.Exclude(x => true); // Exclude ALL
            AuditManager.DefaultConfiguration.Include<IAuditable>();

            AuditManager.DefaultConfiguration.ExcludeProperty<ICreatable>(x => new { x.CreatedBy, x.CreatedOn });
            AuditManager.DefaultConfiguration.ExcludeProperty<IDeletable>(x => new { x.DeletedBy, x.DeletedOn });
            AuditManager.DefaultConfiguration.ExcludeProperty<IEditable>(x => new { x.UpdatedBy, x.UpdatedOn });


            // If an action for the property AutoSavePreAction is set,
            // audit entries will automatically be saved in the database when SaveChanges or SaveChangesAsync methods are called.
            //AuditManager.DefaultConfiguration.AutoSavePreAction = (context, audit) =>
            //{
            //    // ADD "Where(x => x.AuditEntryID == 0)" to allow multiple SaveChanges with same Audit
            //    IEnumerable<AuditEntry> customAuditEntries = audit.Entries.Select(x => AuditEntry.From(x, (context as ArchivingContext)!._userInfo, context.ContextId, (context as ArchivingContext)!._auditEntryDescription!));
            //    (context as ArchivingContext)!.AuditEntries.AddRange(customAuditEntries);
            //};

            AuditManager.DefaultConfiguration.AutoSavePreAction = (context, audit) =>
            {
                IEnumerable<AuditEntry> customAudits = audit.Entries.Select(x => AuditEntry.From(x, context, (context as ArchivingContext)!._auditEntryDescription));
                (context as ArchivingContext)!.AuditEntries.AddRange(customAudits);
            };
        }

        public virtual DbSet<FundPublicReport> FundPublicReports { get; set; } = null!;
        public virtual DbSet<FundInternalReport> FundInternalReports { get; set; } = null!;
        public virtual DbSet<FundsReportSummary> FundsReportSummaries { get; set; } = null!;
        public virtual DbSet<FundAvailabilityReport> FundAvailabilityReports { get; set; } = null!;
        public virtual DbSet<FundsReportSummary> FundAvailabilityReportSummaries { get; set; } = null!;
        public virtual DbSet<FundDataPublicReport> FundDataPublicReports { get; set; } = null!;
        public virtual DbSet<FundDataInternalReport> FundDataInternalReports { get; set; } = null!;
        public virtual DbSet<FundDataReportSummary> FundDataReportSummaries { get; set; } = null!;
        public virtual DbSet<FundMemoryPublicReport> FundMemoryPublicReports { get; set; } = null!;
        public virtual DbSet<FundMemoryReportSummary> FundMemoryReportSummaries { get; set; } = null!;
        public virtual DbSet<RegisterOfDigitalObjectsPublicReport> RegisterPublicReports { get; set; } = null!;
        public virtual DbSet<RegisterOfDigitalObjectsReportSummary> RegisterReportSummaries { get; set; } = null!;
        public virtual DbSet<PartialReceiptsPublicReport> PartialReceiptsPublicReports { get; set; } = null!;
        public virtual DbSet<FundReportSummary1> FundReportSummaries1 { get; set; } = null!;
        public virtual DbSet<FundsListReport> FundsListInternalReports { get; set; } = null!;
        public virtual DbSet<FundsListPublicReport> FundsListPublicReports { get; set; } = null!;
        public virtual DbSet<TotalRowsSummary> TotalRows { get; set; } = null!;
        public virtual DbSet<FundMemoriesListInternalReport> FundMemoriesListInternalReports { get; set; } = null!;
        public virtual DbSet<FundMemoriesListInternalReportSummary> FundMemoriesListInternalReportSummaries { get; set; } = null!;
        public virtual DbSet<FundMemoriesListReport> FundMemoriesListReports { get; set; } = null!;
        public virtual DbSet<FundReportSummary2> FundReportsSummaries2 { get; set; } = null!;
        public virtual DbSet<PartialReceiptsListReport> PartialReceiptsListReports { get; set; } = null!;
        public virtual DbSet<ReceiptsListReport> ReceiptsListReports { get; set; } = null!;
        public virtual DbSet<WorkListForPriorityRestorationReport> WorkListForPriorityRestorationReports { get; set; } = null!;
        //public virtual DbSet<SearchedFundShortModel> SearchedFundsShort { get; set; } = null!;
        public virtual DbSet<FundShortDisplayModel> FundsBasicData { get; set; } = null!;
        //public virtual DbSet<SearchedInventoryShortModel> SearchedInventoriesShort { get; set; } = null!;
        public virtual DbSet<InventoryShortDisplayModel> InventoriesBasicData { get; set; } = null!;
        public virtual DbSet<SearchedArchiveEntityShortModel> SearchedArchiveEntitiesShort { get; set; } = null!;
        public virtual DbSet<RemoteDBEntities.FundDisplayModel> RemoteFunds { get; set; } = null!;
        public virtual DbSet<RemoteDBEntities.InventoryDisplayModel> RemoteInventories { get; set; } = null!;
        public virtual DbSet<RemoteDBEntities.ArchiveEntityDisplayModel> RemoteArchiveEntities { get; set; } = null!;
        public virtual DbSet<RemoteDBEntities.DocumentDisplayModel> RemoteDocuments { get; set; } = null!;
        public virtual DbSet<RemoteDBEntities.DigitalObjectDisplayModel> RemoteDigitalObjects { get; set; } = null!;
        public virtual DbSet<RemoteDBEntities.Nomenclature> RemoteNomenclatures { get; set; } = null!;
        public virtual DbSet<RemoteDBEntities.User> RemoteUsers { get; set; } = null!;
        public virtual DbSet<RemoteDBEntities.FilmDisplayModel> RemoteFilms { get; set; } = null!;
        public virtual DbSet<RemoteDBEntities.FilmCardDisplayModel> RemoteFilmCards { get; set; } = null!;
        //public virtual DbSet<RemoteDBEntities.DocumentAncestorsData> DocumentAncestorsData { get; set; } = null!;
        public virtual DbSet<InventoryBook> InventoryBooks { get; set; } = null!;
        public virtual DbSet<AccountAndDescriptionOfFilmDocumentsBook> AccountAndDescriptionOfFilmDocumentsBooks { get; set; } = null!;
        public virtual DbSet<InsuranceFundOfCopiesOfForeignArchives> InsuranceFundsOfCopiesOfForeignArchives { get; set; } = null!;
        public virtual DbSet<InventoryBookOfCopiesFromForeignArchives> InventoryBookOfCopiesFromForeignArchives { get; set; } = null!;
        public virtual DbSet<CompilationAndNTOOfEDocumentsReport> CompilationAndNTOOfEDocumentsReport { get; set; } = null!;
        public virtual DbSet<CompilationAndNTOOfEDocumentsCombined> CompilationAndNTOOfEDocumentsCombined { get; set; } = null!;
        public virtual DbSet<CompilationAndNTOOfEDocumentsSummary> CompilationAndNTOOfEDocumentsSummary { get; set; } = null!;
        public virtual DbSet<RegisterOfDigitizedDocumentsReport> RegisterOfDigitizedDocumentsReport { get; set; } = null!;
        public virtual DbSet<RegisterOfDigitizedDocumentsCombined> RegisterOfDigitizedDocumentsCombined { get; set; } = null!;
        public virtual DbSet<RegisterOfDigitizedDocumentsSummary> RegisterOfDigitizedDocumentsSummary { get; set; } = null!;
        public virtual DbSet<CountOfUsedCopiesOfDocumentsFromForeignArchivesReport> CountOfUsedCopiesOfDocumentsFromForeignArchivesReport { get; set; } = null!;
        public virtual DbSet<CountOfUsedCopiesOfDocumentsFromForeignArchivesSummary> CountOfUsedCopiesOfDocumentsFromForeignArchivesSummary { get; set; } = null!;
        public virtual DbSet<CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined> CountOfUsedCopiesOfDocumentsFromForeignArchivesCombined { get; set; } = null!;
        public virtual DbSet<QualityControlReport> QualityControlReport { get; set; } = null!;
        public virtual DbSet<QualityControlSummary> QualityControlSummary { get; set; } = null!;
        public virtual DbSet<QualityControlCombined> QualityControlCombined { get; set; } = null!;
        public virtual DbSet<DigitalObjectsPreparationReport> DigitalObjectsPreparationReport { get; set; } = null!;
        public virtual DbSet<DigitalObjectsPreparationCombined> DigitalObjectsPreparationCombined { get; set; } = null!;
        public virtual DbSet<DigitalObjectsPreparationSummary> DigitalObjectsPreparationSummary { get; set; } = null!;
        public virtual DbSet<SpecialRegistrationListReport> SpecialRegistrationLists { get; set; } = null!;

        public virtual DbSet<NumberOfArchiveEntitiesOrderedByReaderReport> NumberOfArchiveEntitiesOrderedByReaderReport { get; set; } = null!;
        public virtual DbSet<NumberOfArchiveEntitiesOrderedByReaderSummary> NumberOfArchiveEntitiesOrderedByReaderSummary { get; set; } = null!;
        public virtual DbSet<NumberOfArchiveEntitiesOrderedByReaderCombined> NumberOfArchiveEntitiesOrderedByReaderCombined { get; set; } = null!;
        public virtual DbSet<NumberOfArchiveEntitiesOrderedByEmployeeReport> NumberOfArchiveEntitiesOrderedByEmployeeReport { get; set; } = null!;
        public virtual DbSet<NumberOfArchiveEntitiesOrderedByEmployeeSummary> NumberOfArchiveEntitiesOrderedByEmployeeSummary { get; set; } = null!;
        public virtual DbSet<NumberOfArchiveEntitiesOrderedByEmployeeCombined> NumberOfArchiveEntitiesOrderedByEmployeeCombined { get; set; } = null!;
        public virtual DbSet<LibraryCard> LibraryCards { get; set; } = null!;
        public virtual DbSet<SearchResult> SearchResults { get; set; } = null!;
        //public virtual DbSet<Number> LastNumbers { get; set; } = null!;
        public virtual DbSet<Result> CheckIfNewNumberIsValid { get; set; } = null!;
        public virtual DbSet<MostUsedRequestEntitiesReport> MostUsedRequestEntitiesReport { get; set; } = null!;
        public virtual DbSet<UsageCountTotalSummary> UsageCountTotalSummary { get; set; } = null!;
        public virtual DbSet<ActiveProcessesReport> ActiveProcessesReport { get; set; } = null!;
        public virtual DbSet<TotalSummary> ActiveProcessesReportTotal { get; set; } = null!;
        public virtual DbSet<NumberOfDocumentsOrderedByReaderReport> NumberOfDocumentsOrderedByReaderReport { get; set; } = null!;
        public virtual DbSet<NumberOfDocumentsOrderedByReaderReportCombined> NumberOfDocumentsOrderedByReaderReportCombined { get; set; } = null!;
        public virtual DbSet<NumberOfDocumentsOrderedByReaderReportSummary> NumberOfDocumentsOrderedByReaderReportSummary { get; set; } = null!;
        public virtual DbSet<NumberOfDocumentsOrderedByEmployeeReport> NumberOfDocumentsOrderedByEmployeeReport { get; set; } = null!;
        public virtual DbSet<NumberOfDocumentsOrderedByEmployeeReportCombined> NumberOfDocumentsOrderedByEmployeeReportCombined { get; set; } = null!;
        public virtual DbSet<NumberOfDocumentsOrderedByEmployeeReportSummary> NumberOfDocumentsOrderedByEmployeeReportSummary { get; set; } = null!;
        public virtual DbSet<InventoryReport> InventoryReport { get; set; } = null!;
        public virtual DbSet<InventoryReportCombined> InventoryReportCombined { get; set; } = null!;
        public virtual DbSet<InventoryReportSummary> InventoryReportSummary { get; set; } = null!;
        public virtual DbSet<ListOfRoughDocumentsReport> ListOfRoughDocumentsReport { get; set; } = null!;
        public virtual DbSet<ListOfRoughDocumentsReportCombined> ListOfRoughDocumentsReportCombined { get; set; } = null!;
        public virtual DbSet<TotalRowsSummary> ListOfRoughDocumentsReportSummary { get; set; } = null!;


        public virtual DbSet<DigitalDocumentsUsageReportSummary> DigitalDocumentsUsageReportSummary { get; set; } = null!;
        public virtual DbSet<DigitalDocumentsUsageReport> DigitalDocumentsUsageReport { get; set; } = null!;

        public virtual DbSet<ListOfPartialReceiptsInArchiveReport> ListOfPartialReceiptsInArchiveReport { get; set; } = null!;
        public virtual DbSet<ListOfPartialReceiptsInArchiveReportCombined> ListOfPartialReceiptsInArchiveReportCombined { get; set; } = null!;
        public virtual DbSet<ListOfPartialReceiptsInArchiveReportSummary> ListOfPartialReceiptsInArchiveReportSummary { get; set; } = null!;
        public virtual DbSet<UserActionsJournalReport> UserActionsJournalReport { get; set; } = null!;
        public virtual DbSet<UserActionsJournalReportSummary> UserActionsJournalReportSummary { get; set; } = null!;
        public virtual DbSet<CardForm1SummaryInternalData> CardForm1SummaryInternalData { get; set; } = null!;      
        public virtual DbSet<CardForm1Data> CardForm1ExternalData { get; set; } = null!;
        public virtual DbSet<CardForm1SummaryExternalData> CardForm1SummaryExternalData { get; set; } = null!;
        public virtual DbSet<AllDescriptionLevelsInOrder> AllDescriptionLevelsInOrder { get; set; } = null!;
        public virtual DbSet<WorkDoneOnDigitalObjectsReport> WorkDoneOnDigitalObjectsReport { get; set; } = null!;
    }
}
