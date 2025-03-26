using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class VTask
    {
        public int Id { get; set; }
        public int? ProcessId { get; set; }
        public bool? ProcessCompleted { get; set; }
        public string? ProcessTypeName { get; set; }
        public int? StepId { get; set; }
        public string? StepTypeName { get; set; }
        public string? Title { get; set; }
        public string? Description { get; set; }
        public Guid AssignedToUserId { get; set; }
        public string? AssignedToDisplayName { get; set; }
        public string? AssignedToUserName { get; set; }
        public DateTime? EndDate { get; set; }
        public int? RelatedEntityId { get; set; }
        public Guid? RelatedEntitySystemIdentifier { get; set; }
        public string RelatedEntityType { get; set; } = null!;
        public string? RelatedContentUrl { get; set; }
        public string StatusCode { get; set; } = null!;
        public string StatusName { get; set; } = null!;
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public string? CreatedByDisplayName { get; set; }
        public string? CreatedByUserName { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public string? UpdatedByDisplayName { get; set; }
        public string? UpdatedByUserName { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public string? DeletedByDisplayName { get; set; }
        public string? DeletedByUserName { get; set; }
        public string? NotificationType { get; set; }
        public string? NotificationTypeName { get; set; }
        public Guid? AssignedToRoleId { get; set; }
        public string? AssignedToRoleName { get; set; }
    }
}
