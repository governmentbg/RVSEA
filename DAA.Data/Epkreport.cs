using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class Epkreport
    {
        public Epkreport()
        {
            CommissionReportFiles = new HashSet<CommissionReportFile>();
            SessionAgenda = new HashSet<SessionAgendum>();
            SessionAgendaStandpoints = new HashSet<SessionAgendaStandpoint>();
        }

        public int Id { get; set; }
        public int Number { get; set; }
        public string Title { get; set; } = null!;
        public string Content { get; set; } = null!;
        public int? ProcessId { get; set; }
        public bool? IsDraft { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public DateTime? DeletedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual Process? Process { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<CommissionReportFile> CommissionReportFiles { get; set; }
        public virtual ICollection<SessionAgendum> SessionAgenda { get; set; }
        public virtual ICollection<SessionAgendaStandpoint> SessionAgendaStandpoints { get; set; }
    }
}
