using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class VAuditLog
    {
        public string? EntityName { get; set; }
        public string? StateName { get; set; }
        public string? ClientIp { get; set; }
        public Guid? CreatedBy { get; set; }
        public string? CreatedByUsername { get; set; }
        public DateTime? CreatedOn { get; set; }
        public string? Description { get; set; }
        public string? CorrelationId { get; set; }
        public int? Lease { get; set; }
    }
}
