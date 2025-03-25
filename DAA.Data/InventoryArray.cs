using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class InventoryArray
    {
        public InventoryArray()
        {
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
        public string? ExternalSourceCode { get; set; }
        public bool UsedInImport { get; set; }

        public virtual ICollection<Inventory> Inventories { get; set; }
        public virtual ICollection<InventoryDraft> InventoryDrafts { get; set; }
    }
}
