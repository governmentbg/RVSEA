using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class TaskStatus
    {
        public TaskStatus()
        {
            Tasks = new HashSet<Task>();
        }

        public string Code { get; set; } = null!;
        public string Text { get; set; } = null!;
        public string? Description { get; set; }
        public int? SortOrder { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }

        public virtual ICollection<Task> Tasks { get; set; }
    }
}
