using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class NotificationTemplate
    {
        public NotificationTemplate()
        {
            Notifications = new HashSet<Notification>();
        }

        public int Id { get; set; }
        public string NotificationTypeCode { get; set; } = null!;
        public string? Subject { get; set; }
        public string? Body { get; set; }

        public virtual NotificationType NotificationTypeCodeNavigation { get; set; } = null!;
        public virtual ICollection<Notification> Notifications { get; set; }
    }
}
