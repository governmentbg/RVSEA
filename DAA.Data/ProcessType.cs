using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class ProcessType
    {
        public ProcessType()
        {
            PackageAdocsTemplates = new HashSet<PackageAdocsTemplate>();
            ProcessRelatedSteps = new HashSet<ProcessRelatedStep>();
            ProcessSteps = new HashSet<ProcessStep>();
            ProcessTypeLevels = new HashSet<ProcessTypeLevel>();
            Processes = new HashSet<Process>();
        }

        public int Id { get; set; }
        public string? Type { get; set; }
        public string Name { get; set; } = null!;
        public string Code { get; set; } = null!;
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }

        public virtual ICollection<PackageAdocsTemplate> PackageAdocsTemplates { get; set; }
        public virtual ICollection<ProcessRelatedStep> ProcessRelatedSteps { get; set; }
        public virtual ICollection<ProcessStep> ProcessSteps { get; set; }
        public virtual ICollection<ProcessTypeLevel> ProcessTypeLevels { get; set; }
        public virtual ICollection<Process> Processes { get; set; }
    }
}
