using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Reports
{
    public class NumberOfDocumentsOrderedByEmployeeReportInputModel
    {
        public IList<string> ArchiveCodes { get; set; } = new List<string>();
        public string? FundNumber { get; set; }
        public IList<string>? FundLevelOfdescriptionCodes { get; set; }
        public string? InventoryNumber { get; set; }
        public string? Employee { get; set; }
        public string? DateFrom { get; set; }
        public string? DateTo { get; set; }
        public bool StatisticDataOnly { get; set; }
    }
}
