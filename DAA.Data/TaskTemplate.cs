using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class TaskTemplate
    {
        public TaskTemplate()
        {
            ProcessSteps = new HashSet<ProcessStep>();
        }

        public int Id { get; set; }
        public int? ProcessStepTypeId { get; set; }
        public string Title { get; set; } = null!;
        public string Description { get; set; } = null!;
        public string RelatedContentUrl { get; set; } = null!;
        public string? NotificationType { get; set; }

        public virtual NotificationType? NotificationTypeNavigation { get; set; }
        public virtual ProcessStep? ProcessStepType { get; set; }

        public virtual ICollection<ProcessStep> ProcessSteps { get; set; }
    }
}
