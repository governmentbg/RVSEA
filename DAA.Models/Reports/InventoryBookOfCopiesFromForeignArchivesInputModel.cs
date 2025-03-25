
namespace DAA.Models.Reports
{
    public class InventoryBookOfCopiesFromForeignArchivesInputModel
    {
        public int ReportResultType { get; set; }
        public List<string> ArchiveGids { get; set; }
    }
}
