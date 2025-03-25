using Microsoft.EntityFrameworkCore;

namespace DAA.Data.RemoteDBEntities
{
    [Keyless]
    public class FundAsLocalEntity
    {
        public int ArchiveId { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public string? NumberPrefix { get; set; }
        public string? Number { get; set; }
        public string Title { get; set; } = null!;
        public bool HasNoChronologicalScope { get; set; }
        public int? StartDateYear { get; set; }
        public int? StartDateMonth { get; set; }
        public int? StartDateDay { get; set; }
        public int? EndDateYear { get; set; }
        public int? EndDateMonth { get; set; }
        public int? EndDateDay { get; set; }
        public string? ApproxmateChronologicalScope { get; set; }
        public int? Bytes { get; set; }
        public double? LinearMeters { get; set; }
        public string? OtherMetrics { get; set; }
        public int? InventoryCount { get; set; }
        public int? ArchivalEntityCount { get; set; }
        public int? DocumentCount { get; set; }
        public string? FundCreatorTitleHistory { get; set; }
        public string? FundCreatorActivityHistory { get; set; }
        public string? FundCreatorBiographicalHistory { get; set; }
        public string? DocumentsProvider { get; set; }
        public string? DocumentsDescription { get; set; }
        public string? ValuableDocumentsInventoryCount { get; set; }
        public string? InvaluableDocumentsInventoryCount { get; set; }
        public string? DocumentsAccessDescription { get; set; }
        public string? History { get; set; }
        public string? RelatedFunds { get; set; }
        public string? Notes { get; set; }
        public int? EnrolledBytes { get; set; }
        public int? EnrolledInventoryCount { get; set; }
        public int? DeductedBytes { get; set; }
        public int? DeductedInventoryCount { get; set; }
    }
}
