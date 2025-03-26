using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class SessionMinutesOfMeeting
    {
        public SessionMinutesOfMeeting()
        {
            Sessions = new HashSet<Session>();
        }

        public int Id { get; set; }
        public string Number { get; set; } = null!;
        public int NumberNumeric { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public string Content { get; set; } = null!;
        public bool? IsDraft { get; set; }
        public string? UncPath { get; set; }
        public string? Status { get; set; }
        public string? RejectReason { get; set; }
        public string? SourceName { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<Session> Sessions { get; set; }
    }
}
