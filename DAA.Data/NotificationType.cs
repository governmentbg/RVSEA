using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class NotificationType
    {
        public NotificationType()
        {
            NotificationEvents = new HashSet<NotificationEvent>();
            NotificationTemplates = new HashSet<NotificationTemplate>();
            TaskTemplates = new HashSet<TaskTemplate>();
            Tasks = new HashSet<Task>();
        }

        public string Code { get; set; } = null!;
        public string Text { get; set; } = null!;

        public virtual ICollection<NotificationEvent> NotificationEvents { get; set; }
        public virtual ICollection<NotificationTemplate> NotificationTemplates { get; set; }
        public virtual ICollection<TaskTemplate> TaskTemplates { get; set; }
        public virtual ICollection<Task> Tasks { get; set; }
    }
}
