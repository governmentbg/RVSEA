using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class FundReportSummary2
    {
        public long TotalRows { get; set; }
        public decimal? TotalLinearMeters { get; set; }
        public long? TotalSize { get; set; }
    }
}
