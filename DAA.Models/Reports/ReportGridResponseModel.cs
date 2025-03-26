namespace DAA.Models.Reports
{
    public class ReportGridResponseModel<T>
    {
        public long TotalCount { get; set; }
        public IEnumerable<T>? Items { get; set; }
        public string? Message { get; set; }
    }
}
