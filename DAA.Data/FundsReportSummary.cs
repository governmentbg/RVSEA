using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class FundsReportSummary
    {
        public int? TotalFunds { get; set; }
        public int? TotalInventories { get; set; }
        public int? TotalArchiveEntities { get; set; }
        public long? TotalSize { get; set; }
        public long? TotalDuration { get; set; }
        public double? TotalLinearMeters { get; set; }
    }
}
