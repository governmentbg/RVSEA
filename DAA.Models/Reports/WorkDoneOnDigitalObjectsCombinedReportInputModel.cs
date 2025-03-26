using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Reports
{
    public class WorkDoneOnDigitalObjectsCombinedReportInputModel
    {
        [Required]
        public IList<string> ArchiveCodes { get; set; } = new List<string>();
        [Required]
        public IList<string> Employees { get; set; } = new List<string>();
        [Required]
        public IList<string> Statuses { get; set; } = new List<string>();
        public DateTime? DateFrom { get; set; }
        public DateTime? DateTo { get; set; }
    }
}
