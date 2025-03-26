using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class ArchivalEntityDescriptionLevel
    {
        public ArchivalEntityDescriptionLevel()
        {
            ArchivalEntities = new HashSet<ArchivalEntity>();
            ArchivalEntityDrafts = new HashSet<ArchivalEntityDraft>();
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
    }
}
