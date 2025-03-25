using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class ProcessTimeline
    {
        public ProcessTimeline()
        {
            SignatureRequests = new HashSet<SignatureRequest>();
            Tasks = new HashSet<Task>();
        }

        public int Id { get; set; }
        public int ProcessId { get; set; }
        public int StepTypeId { get; set; }
        public bool Completed { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public string? Comment { get; set; }
        public Guid? AssignedToUserId { get; set; }
        public Guid? AssignedToRoleId { get; set; }
        public DateTime? EndDate { get; set; }

        public virtual AspNetRole? AssignedToRole { get; set; }
        public virtual AspNetUser? AssignedToUser { get; set; }
        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual Process Process { get; set; } = null!;
        public virtual ProcessStep StepType { get; set; } = null!;
        public virtual ICollection<SignatureRequest> SignatureRequests { get; set; }
        public virtual ICollection<Task> Tasks { get; set; }
    }
}
