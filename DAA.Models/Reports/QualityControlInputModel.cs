using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Reports
{
    public class QualityControlInputModel
    {
        public IList<string>? ArchiveIds { get; set; }
        public IList<string>? Statuses { get; set; }
        public string? Employee { get; set; }
        public string? DateFrom { get; set; }
        public string? DateTo { get; set; }
    }
}
