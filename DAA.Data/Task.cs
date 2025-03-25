using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class Task
    {
        public int Id { get; set; }
        public int? ProcessId { get; set; }
        public int? StepId { get; set; }
        public string? Title { get; set; }
        public string? Description { get; set; }
        public Guid AssignedToUserId { get; set; }
        public DateTime? EndDate { get; set; }
        public int? RelatedEntityId { get; set; }
        public Guid? RelatedEntitySystemIdentifier { get; set; }
        public string RelatedEntityType { get; set; } = null!;
        public string? RelatedContentUrl { get; set; }
        public string StatusCode { get; set; } = null!;
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public string? NotificationType { get; set; }
        public Guid? AssignedToRoleId { get; set; }

        public virtual AspNetRole? AssignedToRole { get; set; }
        public virtual AspNetUser AssignedToUser { get; set; } = null!;
        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual NotificationType? NotificationTypeNavigation { get; set; }
        public virtual Process? Process { get; set; }
        public virtual TaskStatus StatusCodeNavigation { get; set; } = null!;
        public virtual ProcessTimeline? Step { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
    }
}
