using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class InventoryReportCombined
    {
        public long? InventoryCount { get; set; }
        public long? AeCount { get; set; }
        public long? EDocumentsCount { get; set; }
        public long? Duration { get; set; }
        public decimal? LinearMeters { get; set; }
        public long? Bytes { get; set; }
    }
}
