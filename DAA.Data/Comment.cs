using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class Comment
    {
        public int Id { get; set; }
        public string? Text { get; set; }
        public string? UserName { get; set; }
        public int? ProcessId { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public DateTime? DeletedOn { get; set; }
        public bool Deleted { get; set; }
        public int? ProcessStepId { get; set; }
        public bool? IsDraft { get; set; }
        public int? SessionAgendaStandpointId { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual Process? Process { get; set; }
        public virtual ProcessStep? ProcessStep { get; set; }
        public virtual SessionAgendaStandpoint? SessionAgendaStandpoint { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
    }
}
