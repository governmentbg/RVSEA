using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class AuditEntryProperty
    {
        public int AuditEntryPropertyId { get; set; }
        public int AuditEntryId { get; set; }
        public string? RelationName { get; set; }
        public string? PropertyName { get; set; }
        public string? OldValue { get; set; }
        public string? NewValue { get; set; }
        public bool IsKey { get; set; }

        public virtual AuditEntry AuditEntry { get; set; } = null!;
    }
}
