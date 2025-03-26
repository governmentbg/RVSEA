namespace DAA.Models.Reports
{
    public class InventoryReportInputModel
    {
        public int? ReportResultType { get; set; }
        public IList<string>? Archives { get; set; }
        public IList<string>? Statuses { get; set; }
        public string? FundNumber { get; set; }
        public DateTime? RegisteredFrom { get; set; }
        public DateTime? RegisteredTo { get; set; }
        public string? ChronologicalScope { get; set; }
        public string? ChronologicalScopeStartDate { get; set; }
        public string? ChronologicalScopeEndDate { get; set; }
    }
}
