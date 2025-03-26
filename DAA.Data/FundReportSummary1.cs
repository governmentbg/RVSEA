using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class FundReportSummary1
    {
        public long TotalRows { get; set; }
        public long? TotalInventories { get; set; }
        public long? TotalArchiveEntities { get; set; }
        public decimal? TotalLinearMeters { get; set; }
        public long? TotalSize { get; set; }
    }
}
