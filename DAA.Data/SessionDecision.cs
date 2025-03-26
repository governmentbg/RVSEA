using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class SessionDecision
    {
        public int Id { get; set; }
        public DateTime? ProtocolDate { get; set; }
        public int? ProtocolNumber { get; set; }
        public DateTime? DeadlineForApproval { get; set; }
        public int SessionAgendaId { get; set; }
        public string? DecisionText { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public bool? IsDraft { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual SessionAgendum SessionAgenda { get; set; } = null!;
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
    }
}
