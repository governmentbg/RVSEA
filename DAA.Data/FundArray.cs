using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class FundArray
    {
        public FundArray()
        {
            FundDrafts = new HashSet<FundDraft>();
            Funds = new HashSet<Fund>();
        }

        public string Code { get; set; } = null!;
        public string Text { get; set; } = null!;
        public string? Description { get; set; }
        public int? SortOrder { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public DateTime? ExternalSourceUpdatedOn { get; set; }

        public virtual ICollection<FundDraft> FundDrafts { get; set; }
        public virtual ICollection<Fund> Funds { get; set; }
    }
}
