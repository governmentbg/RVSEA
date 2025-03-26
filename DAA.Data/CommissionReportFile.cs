using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class CommissionReportFile
    {
        public int Id { get; set; }
        public int ReportId { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public string Name { get; set; } = null!;
        public string SourceName { get; set; } = null!;
        public string UncPath { get; set; } = null!;
        public string FileType { get; set; } = null!;
        public string? ContentType { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual Epkreport Report { get; set; } = null!;
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
    }
}
