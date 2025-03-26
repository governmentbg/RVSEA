using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class PartialReceiptsPublicReportSummary
    {
        public long TotalFunds { get; set; }
        public long? TotalInventories { get; set; }
        public long? TotalArchiveEntities { get; set; }
        public double? TotalLinearMeters { get; set; }
    }
}