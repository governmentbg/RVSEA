using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class SessionAgendaStandpoint
    {
        public SessionAgendaStandpoint()
        {
            Comments = new HashSet<Comment>();
        }

        public int Id { get; set; }
        public int? SessionAgendaItemId { get; set; }
        public string Content { get; set; } = null!;
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public bool IsDraft { get; set; }
        public int ReportId { get; set; }
        public int? Status { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual Epkreport Report { get; set; } = null!;
        public virtual SessionAgendum? SessionAgendaItem { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<Comment> Comments { get; set; }
    }
}
