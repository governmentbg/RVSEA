using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class AvailabilityStatus
    {
        public AvailabilityStatus()
        {
            ArchivalEntities = new HashSet<ArchivalEntity>();
            ArchivalEntityDrafts = new HashSet<ArchivalEntityDraft>();
            DigitalObjectDrafts = new HashSet<DigitalObjectDraft>();
            DigitalObjects = new HashSet<DigitalObject>();
            DocumentDrafts = new HashSet<DocumentDraft>();
            Documents = new HashSet<Document>();
            FundReconstructions = new HashSet<FundReconstruction>();
            Inventories = new HashSet<Inventory>();
            InventoryDrafts = new HashSet<InventoryDraft>();
        }

        public int Code { get; set; }
        public string Text { get; set; } = null!;
        public string? Description { get; set; }
        public int? SortOrder { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public DateTime? ExternalSourceUpdatedOn { get; set; }

        public virtual ICollection<ArchivalEntity> ArchivalEntities { get; set; }
        public virtual ICollection<ArchivalEntityDraft> ArchivalEntityDrafts { get; set; }
        public virtual ICollection<DigitalObjectDraft> DigitalObjectDrafts { get; set; }
        public virtual ICollection<DigitalObject> DigitalObjects { get; set; }
        public virtual ICollection<DocumentDraft> DocumentDrafts { get; set; }
        public virtual ICollection<Document> Documents { get; set; }
        public virtual ICollection<FundReconstruction> FundReconstructions { get; set; }
        public virtual ICollection<Inventory> Inventories { get; set; }
        public virtual ICollection<InventoryDraft> InventoryDrafts { get; set; }
    }
}
