using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class Status
    {
        public Status()
        {
            ArchivalEntities = new HashSet<ArchivalEntity>();
            ArchivalEntityDrafts = new HashSet<ArchivalEntityDraft>();
            DigitalObjectDrafts = new HashSet<DigitalObjectDraft>();
            DigitalObjects = new HashSet<DigitalObject>();
            DocumentDrafts = new HashSet<DocumentDraft>();
            Documents = new HashSet<Document>();
            FundDrafts = new HashSet<FundDraft>();
            Funds = new HashSet<Fund>();
            Inventories = new HashSet<Inventory>();
            InventoryDrafts = new HashSet<InventoryDraft>();
        }

        public string Code { get; set; } = null!;
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
        public virtual ICollection<FundDraft> FundDrafts { get; set; }
        public virtual ICollection<Fund> Funds { get; set; }
        public virtual ICollection<Inventory> Inventories { get; set; }
        public virtual ICollection<InventoryDraft> InventoryDrafts { get; set; }
    }
}
