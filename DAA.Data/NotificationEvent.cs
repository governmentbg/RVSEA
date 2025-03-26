using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class NotificationEvent
    {
        public NotificationEvent()
        {
            Notifications = new HashSet<Notification>();
        }

        public int Id { get; set; }
        public int ObjectId { get; set; }
        public string NotificationTypeCode { get; set; } = null!;
        public bool IsChecked { get; set; }
        public DateTime? CheckedOn { get; set; }
        public Guid? AssignedToRoleId { get; set; }
        public Guid? AssignedToUserId { get; set; }

        public virtual AspNetRole? AssignedToRole { get; set; }
        public virtual AspNetUser? AssignedToUser { get; set; }
        public virtual NotificationType NotificationTypeCodeNavigation { get; set; } = null!;
        public virtual ICollection<Notification> Notifications { get; set; }
    }
}
