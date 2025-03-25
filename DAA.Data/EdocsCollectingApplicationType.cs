using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class EdocsCollectingApplicationType
    {
        public EdocsCollectingApplicationType()
        {
            EdocsCollectingApplications = new HashSet<EdocsCollectingApplication>();
        }

        public string Code { get; set; } = null!;
        public string Text { get; set; } = null!;
        public string TextEn { get; set; } = null!;

        public virtual ICollection<EdocsCollectingApplication> EdocsCollectingApplications { get; set; }
    }
}
