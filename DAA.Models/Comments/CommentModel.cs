using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Comments
{
    public class CommentModel
    {
        public int? Id { get; set; }
        public int? ProcessId { get; set; }
        public int? ProcessStepId { get; set; }
        public int? SessionAgendaStandpointId { get; set; }
        public string? Text { get; set; }
        public bool? IsDraft { get; set; }
        
    }
}
