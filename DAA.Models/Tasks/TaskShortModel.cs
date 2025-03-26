using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Tasks
{
    public class TaskShortModel
    {
        public int Id { get; set; }
        public string? Title { get; set; }
        public DateTime? EndDate { get; set; }
        public string? StatusCode { get; set; }
        public string? StatusName { get; set; }
        public string? RelatedContentUrl { get; set; }
        public DateTime? CreatedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public string? CreatedByDisplayName { get; set; }
        public string? UpdatedByDisplayName { get; set; }
        public string? AssignedToDisplayName { get; set; }
        public string? AssignedToRoleName { get; set; }
        public string? ProcessTypeName { get; set; }
        public string? StepTypeName { get; set; }
        public string? NotificationTypeName { get; set; }
    }
}
