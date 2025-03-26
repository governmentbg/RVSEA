
namespace DAA.Models.Reports
{
    public class RegisterOfDigitizedDocumentsReportInputModel
    {
        public int? ReportResultType { get; set; }
        public IList<string>? ArchiveGids { get; set; }
        public IList<string>? ArchiveCodesInternal { get; set; }
        public DateTime? RegisteredFrom { get; set; }
        public DateTime? RegisteredTo { get; set; }
    }
}
