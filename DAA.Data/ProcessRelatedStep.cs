using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class ProcessRelatedStep
    {
        public int ProcessTypeId { get; set; }
        public int StepId { get; set; }
        public int? NextStepId { get; set; }
        public int? PrevStepId { get; set; }
        public string? AsigneeGoups { get; set; }

        public virtual ProcessStep? NextStep { get; set; }
        public virtual ProcessStep? PrevStep { get; set; }
        public virtual ProcessType ProcessType { get; set; } = null!;
        public virtual ProcessStep Step { get; set; } = null!;
    }
}
