using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class FundMemoryReportSummary
    {
        public long TotalRows { get; set; }
        public double? TotalLinearMeters { get; set; }
    }
}
