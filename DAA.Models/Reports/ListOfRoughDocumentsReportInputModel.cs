namespace DAA.Models.Reports
{
    public class ListOfRoughDocumentsReportInputModel
    {
        public int? ReportResultType { get; set; }
        public IList<string>? Archives { get; set; }
        public IList<string>? FundTypeGids { get; set; }
        public IList<string>? FundTypesInternal { get; set; }
        public IList<string>? IndustryIndexGids { get; set; }
        public IList<string>? IndustryIndexesInternal { get; set; }
        public IList<string>? MethodOfAcquisitionGids { get; set; }
        public IList<string>? MethodsOfAcquisitionInternal { get; set; }
        public IList<string>? Statuses { get; set; }
        public DateTime? RegisteredFrom { get; set; }
        public DateTime? RegisteredTo { get; set; }
        public string? ChronologicalScope { get; set; }
        public string? ChronologicalScopeStartDate { get; set; }
        public string? ChronologicalScopeEndDate { get; set; }
    }
}
