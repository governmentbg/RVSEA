using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Tasks
{
    public class TaskCreateModel
    {
        public Shared.ProcessStepType StepType { get; set; } = Shared.ProcessStepType.NoStep;
        public string NotificationType { get; set; } = Shared.NotificationType.None;
        public int? ProcessId { get; set; }
        public int? TimelineId { get; set; }
        public string EntityType { get; set; } = string.Empty;
        public int? EntityId { get; set; }
        public Guid? EntitySystemIdentifier { get; set; }
        public string? AssignedToUserId { get; set; }
        public string? AssignedToRoleId { get; set; }
        public DateTime? EndDate { get; set; }
        public string? StatusCode { get; set; }
    }
}
