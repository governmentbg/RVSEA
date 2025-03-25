using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Reports
{
    public class UserActionsJournalReportInputModel
    {
        public IList<string>? EmployeeNames { get; set; }
        public IList<string>? ArchiveCodes { get; set; }
        public string? FundNumber { get; set; }
        public string? InventoryNumber { get; set; }
        public string? ArchiveEntityNumber { get; set; }
        public string? DateFrom { get; set; }
        public string? DateTo { get; set; }
        public IList<string>? Process { get; set; }
        public string? KmfNumber { get; set; }
        public IList<string>? DescriptionLevel { get; set; }
    }
}
