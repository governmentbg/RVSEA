using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class Notification
    {
        public int Id { get; set; }
        public int NotificationTemplateId { get; set; }
        public Guid ToUserId { get; set; }
        public string To { get; set; } = null!;
        public string? Subject { get; set; }
        public string? Body { get; set; }
        public DateTime CreatedOn { get; set; }
        public DateTime? SentOn { get; set; }
        public bool IsSeen { get; set; }
        public bool IsSent { get; set; }
        public int? EventId { get; set; }

        public virtual NotificationEvent? Event { get; set; }
        public virtual NotificationTemplate NotificationTemplate { get; set; } = null!;
        public virtual AspNetUser ToUser { get; set; } = null!;
    }
}
