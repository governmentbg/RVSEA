using DAA.Shared;

namespace DAA.Models.Reports
{
    public class ReportGridRequestModel<T> where T : new()
    {
        public int Page { get; set; }
        public int ItemsPerPage { get; set; }
        public T Filters { get; set; } = new();
        
        public ReportGridRequestModel(T filters)
        {
            Page = 1;
            ItemsPerPage = Constants.MaxRowsOfReportViaGrid; // нужно ли е?
            Filters = filters;
        }
    }
}
