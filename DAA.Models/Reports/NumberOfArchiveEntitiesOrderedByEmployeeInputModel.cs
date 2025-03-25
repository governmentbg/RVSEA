using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Reports
{
    public class NumberOfArchiveEntitiesOrderedByEmployeeInputModel
    {
        public int? ReportResultType { get; set; }
        public IList<string>? EmployeeNamesGids { get; set; }
        public IList<string>? EmployeeNamesInternal { get; set; }
        public IList<string>? FundTypeGids { get; set; }
        public IList<string>? FundTypesInternal { get; set; }
        public IList<string>? ArchiveGids { get; set; }
        public IList<string>? ArchiveCodesInternal { get; set; }
        public IList<string>? InventoryGids { get; set; }
        public IList<string>? InventoryInternal { get; set; }
        public string? DateFrom { get; set; }
        public IList<string>? AchiveEntitiesDescriptionLevelsGids { get; set; }
        public IList<string>? AchiveEntitiesDescriptionLevelsInternal { get; set; }
        public string? DateTo { get; set; }
        public bool StatisticDataOnly { get; set; }
    }
}
