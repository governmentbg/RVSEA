using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class ListOfPartialReceiptsInArchiveReportCombined
    {
        public long? FundCount { get; set; }
        public long? InventoryCount { get; set; }
        public long? AeCount { get; set; }
        public double? LinearMeters { get; set; }
        public long? Size { get; set; }
        public string? Duration { get; set; }
        public int? EDocumentsCount { get; set; }
    }
}
