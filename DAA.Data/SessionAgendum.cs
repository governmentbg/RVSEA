using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class SessionAgendum
    {
        public SessionAgendum()
        {
            SessionAgendaStandpoints = new HashSet<SessionAgendaStandpoint>();
            SessionDecisions = new HashSet<SessionDecision>();
        }

        public int Id { get; set; }
        public int? ProcessId { get; set; }
        public int? SessionId { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? CreatedOn { get; set; }
        public int? ReportId { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual Process? Process { get; set; }
        public virtual Epkreport? Report { get; set; }
        public virtual Session? Session { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<SessionAgendaStandpoint> SessionAgendaStandpoints { get; set; }
        public virtual ICollection<SessionDecision> SessionDecisions { get; set; }
    }
}
