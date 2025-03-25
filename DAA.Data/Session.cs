using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class Session
    {
        public Session()
        {
            SessionAgenda = new HashSet<SessionAgendum>();
        }

        public int Id { get; set; }
        public DateTime SessionDate { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public DateTime? DeletedOn { get; set; }
        public bool Deleted { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public int? MinutesOfMeetingId { get; set; }
        public int ArchiveId { get; set; }
        public string? SessionType { get; set; }
        public Guid? ChairmanId { get; set; }
        public Guid? SecretaryId { get; set; }

        public virtual Archive Archive { get; set; } = null!;
        public virtual AspNetUser? Chairman { get; set; }
        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual SessionMinutesOfMeeting? MinutesOfMeeting { get; set; }
        public virtual AspNetUser? Secretary { get; set; }
        public virtual SessionType? SessionTypeNavigation { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<SessionAgendum> SessionAgenda { get; set; }
    }
}
