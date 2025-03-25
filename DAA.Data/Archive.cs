using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class Archive
    {
        public Archive()
        {
            ArchivalEntities = new HashSet<ArchivalEntity>();
            ArchivalEntityDrafts = new HashSet<ArchivalEntityDraft>();
            ArchivesSpecificOrders = new HashSet<ArchivesSpecificOrder>();
            AspNetRoles = new HashSet<AspNetRole>();
            AspNetUserArchives = new HashSet<AspNetUserArchive>();
            DigitalObjectDrafts = new HashSet<DigitalObjectDraft>();
            DigitalObjects = new HashSet<DigitalObject>();
            DocumentDrafts = new HashSet<DocumentDraft>();
            Documents = new HashSet<Document>();
            EdocsCollectingApplications = new HashSet<EdocsCollectingApplication>();
            FilmCardDrafts = new HashSet<FilmCardDraft>();
            FilmCards = new HashSet<FilmCard>();
            FilmDrafts = new HashSet<FilmDraft>();
            Films = new HashSet<Film>();
            FundDrafts = new HashSet<FundDraft>();
            FundReconstructions = new HashSet<FundReconstruction>();
            Funds = new HashSet<Fund>();
            Inventories = new HashSet<Inventory>();
            InventoryDrafts = new HashSet<InventoryDraft>();
            InventoryRawToNormals = new HashSet<InventoryRawToNormal>();
            Processes = new HashSet<Process>();
            Sessions = new HashSet<Session>();
            SignatureRequests = new HashSet<SignatureRequest>();
        }

        public int Id { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public string Name { get; set; } = null!;
        public int Code { get; set; }
        public int? SortOrder { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<ArchivalEntity> ArchivalEntities { get; set; }
        public virtual ICollection<ArchivalEntityDraft> ArchivalEntityDrafts { get; set; }
        public virtual ICollection<ArchivesSpecificOrder> ArchivesSpecificOrders { get; set; }
        public virtual ICollection<AspNetRole> AspNetRoles { get; set; }
        public virtual ICollection<AspNetUserArchive> AspNetUserArchives { get; set; }
        public virtual ICollection<DigitalObjectDraft> DigitalObjectDrafts { get; set; }
        public virtual ICollection<DigitalObject> DigitalObjects { get; set; }
        public virtual ICollection<DocumentDraft> DocumentDrafts { get; set; }
        public virtual ICollection<Document> Documents { get; set; }
        public virtual ICollection<EdocsCollectingApplication> EdocsCollectingApplications { get; set; }
        public virtual ICollection<FilmCardDraft> FilmCardDrafts { get; set; }
        public virtual ICollection<FilmCard> FilmCards { get; set; }
        public virtual ICollection<FilmDraft> FilmDrafts { get; set; }
        public virtual ICollection<Film> Films { get; set; }
        public virtual ICollection<FundDraft> FundDrafts { get; set; }
        public virtual ICollection<FundReconstruction> FundReconstructions { get; set; }
        public virtual ICollection<Fund> Funds { get; set; }
        public virtual ICollection<Inventory> Inventories { get; set; }
        public virtual ICollection<InventoryDraft> InventoryDrafts { get; set; }
        public virtual ICollection<InventoryRawToNormal> InventoryRawToNormals { get; set; }
        public virtual ICollection<Process> Processes { get; set; }
        public virtual ICollection<Session> Sessions { get; set; }
        public virtual ICollection<SignatureRequest> SignatureRequests { get; set; }
    }
}
