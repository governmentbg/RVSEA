using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class AuditEntry
    {
        public AuditEntry()
        {
            AuditEntryProperties = new HashSet<AuditEntryProperty>();
        }

        public int AuditEntryId { get; set; }
        public string? EntitySetName { get; set; }
        public string? EntityTypeName { get; set; }
        public int State { get; set; }
        public string? StateName { get; set; }
        public string? Ip { get; set; }
        public string? UserAgent { get; set; }
        public Guid CreatedBy { get; set; }
        public DateTime CreatedOn { get; set; }
        public string CreatedByUsername { get; set; } = null!;
        public string? CorrelationId { get; set; }
        public int? Lease { get; set; }
        public string? Description { get; set; }

        public virtual AspNetUser CreatedByNavigation { get; set; } = null!;
        public virtual ICollection<AuditEntryProperty> AuditEntryProperties { get; set; }
    }
}
