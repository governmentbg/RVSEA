using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class FundDataReportSummary
    {
        public int Funds { get; set; }
        public int? Inventories { get; set; }
        public int? ArchiveEntities { get; set; }
        public decimal? LinearMeters { get; set; }
        public long? Size { get; set; }
        public long? Duration { get; set; }
        public int? EDocumentsCount { get; set; }
    }
}
