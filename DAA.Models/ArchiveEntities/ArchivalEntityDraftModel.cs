using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.ArchiveEntities
{
    public class ArchivalEntityDraftModel : ArchivalEntityModel
    {
        public bool IsCurrent { get; set; }
        public bool ReadOnly { get; set; }
        public string? WorkflowTypeCode { get; set; }
        public int? WorkflowId { get; set; }
        public string? WorkflowStepTypeCode { get; set; }
        public int? WorkflowStepId { get; set; }
    }
}
