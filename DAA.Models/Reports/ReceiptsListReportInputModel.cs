namespace DAA.Models.Reports
{
    public class ReceiptsListReportInputModel : ListReportInputModel
    {
        public DateTime? RegisteredFrom { get; set; }
        public DateTime? RegisteredTo { get; set; }
    }
}
