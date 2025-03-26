using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Tasks
{
    public class TaskDisplayModel : TaskShortModel
    {
        public int? ProcessId { get; set; }
        public int? StepId { get; set; }
        public string? NotificationType { get; set; }
        public string? Description { get; set; }
    }
}
