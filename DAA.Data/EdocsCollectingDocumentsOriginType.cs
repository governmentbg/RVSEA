using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class EdocsCollectingDocumentsOriginType
    {
        public EdocsCollectingDocumentsOriginType()
        {
            EdocsCollectingApplications = new HashSet<EdocsCollectingApplication>();
        }

        public string Code { get; set; } = null!;
        public string Text { get; set; } = null!;
        public bool IsRaw { get; set; }

        public virtual ICollection<EdocsCollectingApplication> EdocsCollectingApplications { get; set; }
    }
}
