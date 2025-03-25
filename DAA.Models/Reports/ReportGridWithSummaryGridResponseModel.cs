namespace DAA.Models.Reports
{
    public class ReportGridWithSummaryGridResponseModel<T1, T2> : ReportGridResponseModel<T2>
    {
        public T1? Summary { get; set; }
 }
}