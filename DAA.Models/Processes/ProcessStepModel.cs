using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Processes
{
    public class ProcessStepModel
    {
        public int? Id { get; set; }
        public int ProcessId { get; set; }
        public int StepTypeId { get; set; }
        public string? Comment { get; set; }
        public Guid? AssignedToUserId { get; set; }
        public Guid? AssignedToRoleId { get; set; }
        public DateTime? EndDate { get; set; }
    }
}
