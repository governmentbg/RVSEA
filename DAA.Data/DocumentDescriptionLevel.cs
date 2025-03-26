using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class DocumentDescriptionLevel
    {
        public DocumentDescriptionLevel()
        {
            DocumentDrafts = new HashSet<DocumentDraft>();
            Documents = new HashSet<Document>();
        }

        public string Code { get; set; } = null!;
        public string Text { get; set; } = null!;
        public string? Description { get; set; }
        public int? SortOrder { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public DateTime? ExternalSourceUpdatedOn { get; set; }

        public virtual ICollection<DocumentDraft> DocumentDrafts { get; set; }
        public virtual ICollection<Document> Documents { get; set; }
    }
}
