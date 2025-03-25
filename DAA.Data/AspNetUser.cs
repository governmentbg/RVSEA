using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class AspNetUser
    {
        public AspNetUser()
        {
            ArchivalEntityCreatedByNavigations = new HashSet<ArchivalEntity>();
            ArchivalEntityDeletedByNavigations = new HashSet<ArchivalEntity>();
            ArchivalEntityDraftCreatedByNavigations = new HashSet<ArchivalEntityDraft>();
            ArchivalEntityDraftDeletedByNavigations = new HashSet<ArchivalEntityDraft>();
            ArchivalEntityDraftUpdatedByNavigations = new HashSet<ArchivalEntityDraft>();
            ArchivalEntityUpdatedByNavigations = new HashSet<ArchivalEntity>();
            ArchiveCreatedByNavigations = new HashSet<Archive>();
            ArchiveDeletedByNavigations = new HashSet<Archive>();
            ArchiveUpdatedByNavigations = new HashSet<Archive>();
            AspNetUserArchives = new HashSet<AspNetUserArchive>();
            AspNetUserClaims = new HashSet<AspNetUserClaim>();
            AspNetUserLogins = new HashSet<AspNetUserLogin>();
            AspNetUserProfileCreatedByNavigations = new HashSet<AspNetUserProfile>();
            AspNetUserProfileDeletedByNavigations = new HashSet<AspNetUserProfile>();
            AspNetUserProfileUpdatedByNavigations = new HashSet<AspNetUserProfile>();
            AspNetUserProfileUsers = new HashSet<AspNetUserProfile>();
            AspNetUserTokens = new HashSet<AspNetUserToken>();
            AuditEntries = new HashSet<AuditEntry>();
            CommentCreatedByNavigations = new HashSet<Comment>();
            CommentDeletedByNavigations = new HashSet<Comment>();
            CommentUpdatedByNavigations = new HashSet<Comment>();
            CommissionReportFileCreatedByNavigations = new HashSet<CommissionReportFile>();
            CommissionReportFileDeletedByNavigations = new HashSet<CommissionReportFile>();
            CommissionReportFileUpdatedByNavigations = new HashSet<CommissionReportFile>();
            DigitalObjectCreatedByNavigations = new HashSet<DigitalObject>();
            DigitalObjectDeletedByNavigations = new HashSet<DigitalObject>();
            DigitalObjectDraftCreatedByNavigations = new HashSet<DigitalObjectDraft>();
            DigitalObjectDraftDeletedByNavigations = new HashSet<DigitalObjectDraft>();
            DigitalObjectDraftUpdatedByNavigations = new HashSet<DigitalObjectDraft>();
            DigitalObjectReviews = new HashSet<DigitalObjectReview>();
            DigitalObjectUpdatedByNavigations = new HashSet<DigitalObject>();
            DocumentCreatedByNavigations = new HashSet<Document>();
            DocumentDeletedByNavigations = new HashSet<Document>();
            DocumentDraftCreatedByNavigations = new HashSet<DocumentDraft>();
            DocumentDraftDeletedByNavigations = new HashSet<DocumentDraft>();
            DocumentDraftUpdatedByNavigations = new HashSet<DocumentDraft>();
            DocumentUpdatedByNavigations = new HashSet<Document>();
            EdocsCollectingApplicationApplicants = new HashSet<EdocsCollectingApplication>();
            EdocsCollectingApplicationAssignToUsers = new HashSet<EdocsCollectingApplication>();
            EdocsCollectingApplicationCreatedByNavigations = new HashSet<EdocsCollectingApplication>();
            EdocsCollectingApplicationDeletedByNavigations = new HashSet<EdocsCollectingApplication>();
            EdocsCollectingApplicationUpdatedByNavigations = new HashSet<EdocsCollectingApplication>();
            EpkreportCreatedByNavigations = new HashSet<Epkreport>();
            EpkreportDeletedByNavigations = new HashSet<Epkreport>();
            EpkreportUpdatedByNavigations = new HashSet<Epkreport>();
            FileCreatedByNavigations = new HashSet<File>();
            FileDeletedByNavigations = new HashSet<File>();
            FilmCardCreatedByNavigations = new HashSet<FilmCard>();
            FilmCardDeletedByNavigations = new HashSet<FilmCard>();
            FilmCardDraftCreatedByNavigations = new HashSet<FilmCardDraft>();
            FilmCardDraftDeletedByNavigations = new HashSet<FilmCardDraft>();
            FilmCardDraftUpdatedByNavigations = new HashSet<FilmCardDraft>();
            FilmCardUpdatedByNavigations = new HashSet<FilmCard>();
            FilmCreatedByNavigations = new HashSet<Film>();
            FilmDeletedByNavigations = new HashSet<Film>();
            FilmDraftCreatedByNavigations = new HashSet<FilmDraft>();
            FilmDraftDeletedByNavigations = new HashSet<FilmDraft>();
            FilmDraftUpdatedByNavigations = new HashSet<FilmDraft>();
            FilmPackageCreatedByNavigations = new HashSet<FilmPackage>();
            FilmPackageDeletedByNavigations = new HashSet<FilmPackage>();
            FilmPackageDocumentCreatedByNavigations = new HashSet<FilmPackageDocument>();
            FilmPackageDocumentDeletedByNavigations = new HashSet<FilmPackageDocument>();
            FilmPackageDocumentUpdatedByNavigations = new HashSet<FilmPackageDocument>();
            FilmPackageUpdatedByNavigations = new HashSet<FilmPackage>();
            FilmReviewCreatedByNavigations = new HashSet<FilmReview>();
            FilmReviewDeletedByNavigations = new HashSet<FilmReview>();
            FilmReviewUpdatedByNavigations = new HashSet<FilmReview>();
            FilmReviewUsers = new HashSet<FilmReview>();
            FilmUpdatedByNavigations = new HashSet<Film>();
            FundCreatedByNavigations = new HashSet<Fund>();
            FundDeletedByNavigations = new HashSet<Fund>();
            FundDraftCreatedByNavigations = new HashSet<FundDraft>();
            FundDraftDeletedByNavigations = new HashSet<FundDraft>();
            FundDraftUpdatedByNavigations = new HashSet<FundDraft>();
            FundReconstructionCreatedByNavigations = new HashSet<FundReconstruction>();
            FundReconstructionDeletedByNavigations = new HashSet<FundReconstruction>();
            FundReconstructionUpdatedByNavigations = new HashSet<FundReconstruction>();
            FundUpdatedByNavigations = new HashSet<Fund>();
            InformationItemCreatedByNavigations = new HashSet<InformationItem>();
            InformationItemDeletedByNavigations = new HashSet<InformationItem>();
            InformationItemUpdatedByNavigations = new HashSet<InformationItem>();
            InventoryCreatedByNavigations = new HashSet<Inventory>();
            InventoryDeletedByNavigations = new HashSet<Inventory>();
            InventoryDraftCreatedByNavigations = new HashSet<InventoryDraft>();
            InventoryDraftDeletedByNavigations = new HashSet<InventoryDraft>();
            InventoryDraftUpdatedByNavigations = new HashSet<InventoryDraft>();
            InventoryUpdatedByNavigations = new HashSet<Inventory>();
            InverseCreatedByNavigation = new HashSet<AspNetUser>();
            InverseDeletedByNavigation = new HashSet<AspNetUser>();
            InverseUpdatedByNavigation = new HashSet<AspNetUser>();
            NomenclatureCreatedByNavigations = new HashSet<Nomenclature>();
            NomenclatureDeletedByNavigations = new HashSet<Nomenclature>();
            NomenclatureUpdatedByNavigations = new HashSet<Nomenclature>();
            NomenclatureValueCreatedByNavigations = new HashSet<NomenclatureValue>();
            NomenclatureValueDeletedByNavigations = new HashSet<NomenclatureValue>();
            NomenclatureValueUpdatedByNavigations = new HashSet<NomenclatureValue>();
            NotificationEvents = new HashSet<NotificationEvent>();
            Notifications = new HashSet<Notification>();
            PackageAdocsTemplateCreatedByNavigations = new HashSet<PackageAdocsTemplate>();
            PackageAdocsTemplateDeletedByNavigations = new HashSet<PackageAdocsTemplate>();
            PackageAdocsTemplateUpdatedByNavigations = new HashSet<PackageAdocsTemplate>();
            PackageCreatedByNavigations = new HashSet<Package>();
            PackageDeletedByNavigations = new HashSet<Package>();
            PackageDocumentCreatedByNavigations = new HashSet<PackageDocument>();
            PackageDocumentDeletedByNavigations = new HashSet<PackageDocument>();
            PackageDocumentUpdatedByNavigations = new HashSet<PackageDocument>();
            PackageUpdatedByNavigations = new HashSet<Package>();
            ProcessCreatedByNavigations = new HashSet<Process>();
            ProcessDeletedByNavigations = new HashSet<Process>();
            ProcessTimelineAssignedToUsers = new HashSet<ProcessTimeline>();
            ProcessTimelineCreatedByNavigations = new HashSet<ProcessTimeline>();
            ProcessUpdatedByNavigations = new HashSet<Process>();
            SessionAgendaStandpointCreatedByNavigations = new HashSet<SessionAgendaStandpoint>();
            SessionAgendaStandpointDeletedByNavigations = new HashSet<SessionAgendaStandpoint>();
            SessionAgendaStandpointUpdatedByNavigations = new HashSet<SessionAgendaStandpoint>();
            SessionAgendumCreatedByNavigations = new HashSet<SessionAgendum>();
            SessionAgendumDeletedByNavigations = new HashSet<SessionAgendum>();
            SessionAgendumUpdatedByNavigations = new HashSet<SessionAgendum>();
            SessionChairmen = new HashSet<Session>();
            SessionCreatedByNavigations = new HashSet<Session>();
            SessionDecisionCreatedByNavigations = new HashSet<SessionDecision>();
            SessionDecisionDeletedByNavigations = new HashSet<SessionDecision>();
            SessionDecisionUpdatedByNavigations = new HashSet<SessionDecision>();
            SessionDeletedByNavigations = new HashSet<Session>();
            SessionMinutesOfMeetingCreatedByNavigations = new HashSet<SessionMinutesOfMeeting>();
            SessionMinutesOfMeetingDeletedByNavigations = new HashSet<SessionMinutesOfMeeting>();
            SessionMinutesOfMeetingUpdatedByNavigations = new HashSet<SessionMinutesOfMeeting>();
            SessionSecretaries = new HashSet<Session>();
            SessionUpdatedByNavigations = new HashSet<Session>();
            SignatureRequestCreatedByNavigations = new HashSet<SignatureRequest>();
            SignatureRequestDeletedByNavigations = new HashSet<SignatureRequest>();
            SignatureRequestSigningUsers = new HashSet<SignatureRequest>();
            SignatureRequestUpdatedByNavigations = new HashSet<SignatureRequest>();
            TaskAssignedToUsers = new HashSet<Task>();
            TaskCreatedByNavigations = new HashSet<Task>();
            TaskDeletedByNavigations = new HashSet<Task>();
            TaskUpdatedByNavigations = new HashSet<Task>();
            UserReviews = new HashSet<UserReview>();
            Roles = new HashSet<AspNetRole>();
        }

        public Guid Id { get; set; }
        public string AuthenticationType { get; set; } = null!;
        public string UserType { get; set; } = null!;
        public string? UserName { get; set; }
        public string? NormalizedUserName { get; set; }
        public string? Email { get; set; }
        public string? NormalizedEmail { get; set; }
        public byte[]? Certificate { get; set; }
        public string? CertificateThumbprint { get; set; }
        public string? CertificateName { get; set; }
        public string? CertificateUniqueIdentifier { get; set; }
        public bool EmailConfirmed { get; set; }
        public string? PasswordHash { get; set; }
        public string? SecurityStamp { get; set; }
        public string? ConcurrencyStamp { get; set; }
        public string? PhoneNumber { get; set; }
        public bool PhoneNumberConfirmed { get; set; }
        public bool TwoFactorEnabled { get; set; }
        public DateTimeOffset? LockoutEnd { get; set; }
        public bool LockoutEnabled { get; set; }
        public int AccessFailedCount { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<ArchivalEntity> ArchivalEntityCreatedByNavigations { get; set; }
        public virtual ICollection<ArchivalEntity> ArchivalEntityDeletedByNavigations { get; set; }
        public virtual ICollection<ArchivalEntityDraft> ArchivalEntityDraftCreatedByNavigations { get; set; }
        public virtual ICollection<ArchivalEntityDraft> ArchivalEntityDraftDeletedByNavigations { get; set; }
        public virtual ICollection<ArchivalEntityDraft> ArchivalEntityDraftUpdatedByNavigations { get; set; }
        public virtual ICollection<ArchivalEntity> ArchivalEntityUpdatedByNavigations { get; set; }
        public virtual ICollection<Archive> ArchiveCreatedByNavigations { get; set; }
        public virtual ICollection<Archive> ArchiveDeletedByNavigations { get; set; }
        public virtual ICollection<Archive> ArchiveUpdatedByNavigations { get; set; }
        public virtual ICollection<AspNetUserArchive> AspNetUserArchives { get; set; }
        public virtual ICollection<AspNetUserClaim> AspNetUserClaims { get; set; }
        public virtual ICollection<AspNetUserLogin> AspNetUserLogins { get; set; }
        public virtual ICollection<AspNetUserProfile> AspNetUserProfileCreatedByNavigations { get; set; }
        public virtual ICollection<AspNetUserProfile> AspNetUserProfileDeletedByNavigations { get; set; }
        public virtual ICollection<AspNetUserProfile> AspNetUserProfileUpdatedByNavigations { get; set; }
        public virtual ICollection<AspNetUserProfile> AspNetUserProfileUsers { get; set; }
        public virtual ICollection<AspNetUserToken> AspNetUserTokens { get; set; }
        public virtual ICollection<AuditEntry> AuditEntries { get; set; }
        public virtual ICollection<Comment> CommentCreatedByNavigations { get; set; }
        public virtual ICollection<Comment> CommentDeletedByNavigations { get; set; }
        public virtual ICollection<Comment> CommentUpdatedByNavigations { get; set; }
        public virtual ICollection<CommissionReportFile> CommissionReportFileCreatedByNavigations { get; set; }
        public virtual ICollection<CommissionReportFile> CommissionReportFileDeletedByNavigations { get; set; }
        public virtual ICollection<CommissionReportFile> CommissionReportFileUpdatedByNavigations { get; set; }
        public virtual ICollection<DigitalObject> DigitalObjectCreatedByNavigations { get; set; }
        public virtual ICollection<DigitalObject> DigitalObjectDeletedByNavigations { get; set; }
        public virtual ICollection<DigitalObjectDraft> DigitalObjectDraftCreatedByNavigations { get; set; }
        public virtual ICollection<DigitalObjectDraft> DigitalObjectDraftDeletedByNavigations { get; set; }
        public virtual ICollection<DigitalObjectDraft> DigitalObjectDraftUpdatedByNavigations { get; set; }
        public virtual ICollection<DigitalObjectReview> DigitalObjectReviews { get; set; }
        public virtual ICollection<DigitalObject> DigitalObjectUpdatedByNavigations { get; set; }
        public virtual ICollection<Document> DocumentCreatedByNavigations { get; set; }
        public virtual ICollection<Document> DocumentDeletedByNavigations { get; set; }
        public virtual ICollection<DocumentDraft> DocumentDraftCreatedByNavigations { get; set; }
        public virtual ICollection<DocumentDraft> DocumentDraftDeletedByNavigations { get; set; }
        public virtual ICollection<DocumentDraft> DocumentDraftUpdatedByNavigations { get; set; }
        public virtual ICollection<Document> DocumentUpdatedByNavigations { get; set; }
        public virtual ICollection<EdocsCollectingApplication> EdocsCollectingApplicationApplicants { get; set; }
        public virtual ICollection<EdocsCollectingApplication> EdocsCollectingApplicationAssignToUsers { get; set; }
        public virtual ICollection<EdocsCollectingApplication> EdocsCollectingApplicationCreatedByNavigations { get; set; }
        public virtual ICollection<EdocsCollectingApplication> EdocsCollectingApplicationDeletedByNavigations { get; set; }
        public virtual ICollection<EdocsCollectingApplication> EdocsCollectingApplicationUpdatedByNavigations { get; set; }
        public virtual ICollection<Epkreport> EpkreportCreatedByNavigations { get; set; }
        public virtual ICollection<Epkreport> EpkreportDeletedByNavigations { get; set; }
        public virtual ICollection<Epkreport> EpkreportUpdatedByNavigations { get; set; }
        public virtual ICollection<File> FileCreatedByNavigations { get; set; }
        public virtual ICollection<File> FileDeletedByNavigations { get; set; }
        public virtual ICollection<FilmCard> FilmCardCreatedByNavigations { get; set; }
        public virtual ICollection<FilmCard> FilmCardDeletedByNavigations { get; set; }
        public virtual ICollection<FilmCardDraft> FilmCardDraftCreatedByNavigations { get; set; }
        public virtual ICollection<FilmCardDraft> FilmCardDraftDeletedByNavigations { get; set; }
        public virtual ICollection<FilmCardDraft> FilmCardDraftUpdatedByNavigations { get; set; }
        public virtual ICollection<FilmCard> FilmCardUpdatedByNavigations { get; set; }
        public virtual ICollection<Film> FilmCreatedByNavigations { get; set; }
        public virtual ICollection<Film> FilmDeletedByNavigations { get; set; }
        public virtual ICollection<FilmDraft> FilmDraftCreatedByNavigations { get; set; }
        public virtual ICollection<FilmDraft> FilmDraftDeletedByNavigations { get; set; }
        public virtual ICollection<FilmDraft> FilmDraftUpdatedByNavigations { get; set; }
        public virtual ICollection<FilmPackage> FilmPackageCreatedByNavigations { get; set; }
        public virtual ICollection<FilmPackage> FilmPackageDeletedByNavigations { get; set; }
        public virtual ICollection<FilmPackageDocument> FilmPackageDocumentCreatedByNavigations { get; set; }
        public virtual ICollection<FilmPackageDocument> FilmPackageDocumentDeletedByNavigations { get; set; }
        public virtual ICollection<FilmPackageDocument> FilmPackageDocumentUpdatedByNavigations { get; set; }
        public virtual ICollection<FilmPackage> FilmPackageUpdatedByNavigations { get; set; }
        public virtual ICollection<FilmReview> FilmReviewCreatedByNavigations { get; set; }
        public virtual ICollection<FilmReview> FilmReviewDeletedByNavigations { get; set; }
        public virtual ICollection<FilmReview> FilmReviewUpdatedByNavigations { get; set; }
        public virtual ICollection<FilmReview> FilmReviewUsers { get; set; }
        public virtual ICollection<Film> FilmUpdatedByNavigations { get; set; }
        public virtual ICollection<Fund> FundCreatedByNavigations { get; set; }
        public virtual ICollection<Fund> FundDeletedByNavigations { get; set; }
        public virtual ICollection<FundDraft> FundDraftCreatedByNavigations { get; set; }
        public virtual ICollection<FundDraft> FundDraftDeletedByNavigations { get; set; }
        public virtual ICollection<FundDraft> FundDraftUpdatedByNavigations { get; set; }
        public virtual ICollection<FundReconstruction> FundReconstructionCreatedByNavigations { get; set; }
        public virtual ICollection<FundReconstruction> FundReconstructionDeletedByNavigations { get; set; }
        public virtual ICollection<FundReconstruction> FundReconstructionUpdatedByNavigations { get; set; }
        public virtual ICollection<Fund> FundUpdatedByNavigations { get; set; }
        public virtual ICollection<InformationItem> InformationItemCreatedByNavigations { get; set; }
        public virtual ICollection<InformationItem> InformationItemDeletedByNavigations { get; set; }
        public virtual ICollection<InformationItem> InformationItemUpdatedByNavigations { get; set; }
        public virtual ICollection<Inventory> InventoryCreatedByNavigations { get; set; }
        public virtual ICollection<Inventory> InventoryDeletedByNavigations { get; set; }
        public virtual ICollection<InventoryDraft> InventoryDraftCreatedByNavigations { get; set; }
        public virtual ICollection<InventoryDraft> InventoryDraftDeletedByNavigations { get; set; }
        public virtual ICollection<InventoryDraft> InventoryDraftUpdatedByNavigations { get; set; }
        public virtual ICollection<Inventory> InventoryUpdatedByNavigations { get; set; }
        public virtual ICollection<AspNetUser> InverseCreatedByNavigation { get; set; }
        public virtual ICollection<AspNetUser> InverseDeletedByNavigation { get; set; }
        public virtual ICollection<AspNetUser> InverseUpdatedByNavigation { get; set; }
        public virtual ICollection<Nomenclature> NomenclatureCreatedByNavigations { get; set; }
        public virtual ICollection<Nomenclature> NomenclatureDeletedByNavigations { get; set; }
        public virtual ICollection<Nomenclature> NomenclatureUpdatedByNavigations { get; set; }
        public virtual ICollection<NomenclatureValue> NomenclatureValueCreatedByNavigations { get; set; }
        public virtual ICollection<NomenclatureValue> NomenclatureValueDeletedByNavigations { get; set; }
        public virtual ICollection<NomenclatureValue> NomenclatureValueUpdatedByNavigations { get; set; }
        public virtual ICollection<NotificationEvent> NotificationEvents { get; set; }
        public virtual ICollection<Notification> Notifications { get; set; }
        public virtual ICollection<PackageAdocsTemplate> PackageAdocsTemplateCreatedByNavigations { get; set; }
        public virtual ICollection<PackageAdocsTemplate> PackageAdocsTemplateDeletedByNavigations { get; set; }
        public virtual ICollection<PackageAdocsTemplate> PackageAdocsTemplateUpdatedByNavigations { get; set; }
        public virtual ICollection<Package> PackageCreatedByNavigations { get; set; }
        public virtual ICollection<Package> PackageDeletedByNavigations { get; set; }
        public virtual ICollection<PackageDocument> PackageDocumentCreatedByNavigations { get; set; }
        public virtual ICollection<PackageDocument> PackageDocumentDeletedByNavigations { get; set; }
        public virtual ICollection<PackageDocument> PackageDocumentUpdatedByNavigations { get; set; }
        public virtual ICollection<Package> PackageUpdatedByNavigations { get; set; }
        public virtual ICollection<Process> ProcessCreatedByNavigations { get; set; }
        public virtual ICollection<Process> ProcessDeletedByNavigations { get; set; }
        public virtual ICollection<ProcessTimeline> ProcessTimelineAssignedToUsers { get; set; }
        public virtual ICollection<ProcessTimeline> ProcessTimelineCreatedByNavigations { get; set; }
        public virtual ICollection<Process> ProcessUpdatedByNavigations { get; set; }
        public virtual ICollection<SessionAgendaStandpoint> SessionAgendaStandpointCreatedByNavigations { get; set; }
        public virtual ICollection<SessionAgendaStandpoint> SessionAgendaStandpointDeletedByNavigations { get; set; }
        public virtual ICollection<SessionAgendaStandpoint> SessionAgendaStandpointUpdatedByNavigations { get; set; }
        public virtual ICollection<SessionAgendum> SessionAgendumCreatedByNavigations { get; set; }
        public virtual ICollection<SessionAgendum> SessionAgendumDeletedByNavigations { get; set; }
        public virtual ICollection<SessionAgendum> SessionAgendumUpdatedByNavigations { get; set; }
        public virtual ICollection<Session> SessionChairmen { get; set; }
        public virtual ICollection<Session> SessionCreatedByNavigations { get; set; }
        public virtual ICollection<SessionDecision> SessionDecisionCreatedByNavigations { get; set; }
        public virtual ICollection<SessionDecision> SessionDecisionDeletedByNavigations { get; set; }
        public virtual ICollection<SessionDecision> SessionDecisionUpdatedByNavigations { get; set; }
        public virtual ICollection<Session> SessionDeletedByNavigations { get; set; }
        public virtual ICollection<SessionMinutesOfMeeting> SessionMinutesOfMeetingCreatedByNavigations { get; set; }
        public virtual ICollection<SessionMinutesOfMeeting> SessionMinutesOfMeetingDeletedByNavigations { get; set; }
        public virtual ICollection<SessionMinutesOfMeeting> SessionMinutesOfMeetingUpdatedByNavigations { get; set; }
        public virtual ICollection<Session> SessionSecretaries { get; set; }
        public virtual ICollection<Session> SessionUpdatedByNavigations { get; set; }
        public virtual ICollection<SignatureRequest> SignatureRequestCreatedByNavigations { get; set; }
        public virtual ICollection<SignatureRequest> SignatureRequestDeletedByNavigations { get; set; }
        public virtual ICollection<SignatureRequest> SignatureRequestSigningUsers { get; set; }
        public virtual ICollection<SignatureRequest> SignatureRequestUpdatedByNavigations { get; set; }
        public virtual ICollection<Task> TaskAssignedToUsers { get; set; }
        public virtual ICollection<Task> TaskCreatedByNavigations { get; set; }
        public virtual ICollection<Task> TaskDeletedByNavigations { get; set; }
        public virtual ICollection<Task> TaskUpdatedByNavigations { get; set; }
        public virtual ICollection<UserReview> UserReviews { get; set; }

        public virtual ICollection<AspNetRole> Roles { get; set; }
    }
}
