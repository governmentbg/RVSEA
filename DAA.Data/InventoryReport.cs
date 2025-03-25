using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class InventoryReport
    {
        public string? Archive { get; set; }
        public string? FundDescriptionLevel { get; set; }
        public string? FundNumber { get; set; }
        public string? FundTitle { get; set; }
        public string? InventoryNumber { get; set; }
        public string? InventoryDescriptionLevel { get; set; }
        public string? Status { get; set; }
        public int? AeCount { get; set; }
        public int? AeWithCharCount { get; set; }
        public int? EDocumentsCount { get; set; }
        public decimal? LinearMeters { get; set; }
        public string? FileFormat { get; set; }
        public int? Duration { get; set; }
        public long? Bytes { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}
