using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class AspNetRole
    {
        public AspNetRole()
        {
            AspNetRoleClaims = new HashSet<AspNetRoleClaim>();
            NotificationEvents = new HashSet<NotificationEvent>();
            ProcessTimelines = new HashSet<ProcessTimeline>();
            Tasks = new HashSet<Task>();
            Users = new HashSet<AspNetUser>();
        }

        public Guid Id { get; set; }
        public int? ArchiveId { get; set; }
        public string? Name { get; set; }
        public string? NormalizedName { get; set; }
        public string? ConcurrencyStamp { get; set; }
        public string? Abbreviation { get; set; }

        public virtual Archive? Archive { get; set; }
        public virtual ICollection<AspNetRoleClaim> AspNetRoleClaims { get; set; }
        public virtual ICollection<NotificationEvent> NotificationEvents { get; set; }
        public virtual ICollection<ProcessTimeline> ProcessTimelines { get; set; }
        public virtual ICollection<Task> Tasks { get; set; }

        public virtual ICollection<AspNetUser> Users { get; set; }
    }
}
