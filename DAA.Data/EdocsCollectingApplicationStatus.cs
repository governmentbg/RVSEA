using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class EdocsCollectingApplicationStatus
    {
        public EdocsCollectingApplicationStatus()
        {
            EdocsCollectingApplications = new HashSet<EdocsCollectingApplication>();
        }

        public int Id { get; set; }
        public string Text { get; set; } = null!;
        public string? TextEn { get; set; }

        public virtual ICollection<EdocsCollectingApplication> EdocsCollectingApplications { get; set; }
    }
}
