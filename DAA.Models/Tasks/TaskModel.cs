using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Tasks
{
    public class TaskModel
    {
        public int Id { get; set; }
        public int? ProcessId { get; set; }
        public int? StepId { get; set; }
        public string? NotificationType { get; set; }
        public string? Title { get; set; }
        public string? Description { get; set; }
        [Required]
        public Guid AssignedToUserId { get; set; }
        public Guid? AssignedToRoleId { get; set; }
        public DateTime? EndDate { get; set; }
        public int? RelatedEntityId { get; set; }
        public Guid? RelatedEntitySystemIdentifier { get; set; }
        public string RelatedEntityType { get; set; } = null!;
        [Required]
        public string? RelatedContentUrl { get; set; }
        public string? StatusCode { get; set; }
    }
}
