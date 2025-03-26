using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class DigitalDocumentsUsageReport
    {
        public string? ArchiveName { get; set; }
        public Guid? DocumentSystemIdentifier { get; set; }
        public string? DocumentTitle { get; set; }
        public int? EmpCount { get; set; }
        public int? CdhCount { get; set; }
        public int? OtherCount { get; set; }
    }
}
