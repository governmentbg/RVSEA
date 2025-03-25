using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class ProcessStep
    {
        public ProcessStep()
        {
            Comments = new HashSet<Comment>();
            ProcessRelatedStepNextSteps = new HashSet<ProcessRelatedStep>();
            ProcessRelatedStepPrevSteps = new HashSet<ProcessRelatedStep>();
            ProcessRelatedStepSteps = new HashSet<ProcessRelatedStep>();
            ProcessTimelines = new HashSet<ProcessTimeline>();
            TaskTemplates = new HashSet<TaskTemplate>();
            TaskTemplatesNavigation = new HashSet<TaskTemplate>();
        }

        public int Id { get; set; }
        public int? ProcessTypeId { get; set; }
        public string Code { get; set; } = null!;
        public string Text { get; set; } = null!;
        public bool AllowTaskTemplate { get; set; }

        public virtual ProcessType? ProcessType { get; set; }
        public virtual ICollection<Comment> Comments { get; set; }
        public virtual ICollection<ProcessRelatedStep> ProcessRelatedStepNextSteps { get; set; }
        public virtual ICollection<ProcessRelatedStep> ProcessRelatedStepPrevSteps { get; set; }
        public virtual ICollection<ProcessRelatedStep> ProcessRelatedStepSteps { get; set; }
        public virtual ICollection<ProcessTimeline> ProcessTimelines { get; set; }
        public virtual ICollection<TaskTemplate> TaskTemplates { get; set; }

        public virtual ICollection<TaskTemplate> TaskTemplatesNavigation { get; set; }
    }
}
