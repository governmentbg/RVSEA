namespace DAA.Models.Reports
{
    public class ReportGridWithSummaryGridResponseModel1<T1, T2> : ReportGridResponseModel<T2>
    {
        public IList<T1>? Summary { get; set; }
    }
}