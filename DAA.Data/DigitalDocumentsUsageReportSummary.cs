using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class DigitalDocumentsUsageReportSummary
    {
        public string? RowTitle { get; set; } = string.Empty;
        public int? RowValue { get; set; }
    }
}
