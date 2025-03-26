using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class PartialReceiptsPublicReport
    {
        public double? LinearMeters { get; set; }
        public long? InventoryCount { get; set; } // на InventoryCount
        public long? AECount { get; set; } // ArchiveEntityCount
        public string? ImmediateSourceOfAcquisition { get; set; }
        public string Archive { get; set; } = string.Empty;
        public string? Number { get; set; } // FundNumber
        public string? FundType { get; set; }
        public string? DocumentProperties { get; set; }
        public string? MethodOfAcquisition { get; set; }
        public string? TextDate { get; set; }
        public string? StartDate { get; set; }
        public string? EndDate { get; set; }
        public string? CreationDate { get; set; }
        public string? Title { get; set; }
        public string? Note { get; set; }
        public string? FundStatus { get; set; }
        public double? Size { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public Guid? SystemIdentifier { get; set; }
    }
}
