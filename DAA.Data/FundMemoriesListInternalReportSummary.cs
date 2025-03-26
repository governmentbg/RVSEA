using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class FundMemoriesListInternalReportSummary
    {
        public long TotalRows { get; set; }
        public decimal? TotalLinearMeters { get; set; }
        public long? TotalSize { get; set; }
        public int? TotalDuration { get; set; }
    }
}
