using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class FundDataInternalReport
    {
        public string SystemId { get; set; } = string.Empty;
        public string? CreationAuthor { get; set; }
        public string? ModificationDate { get; set; }
        public string? ModificationAuthor { get; set; }
        public double? LinearMeters { get; set; }
        public int? InventoryCount { get; set; } // на InventoryCount
        public int? BoxesCount { get; set; }
        public int? StorageTubesCount { get; set; } // рулонни тубуси
        public int? AECount { get; set; } // ArchiveEntityCount
        public string? ExtentOther { get; set; }
        public long? Size { get; set; }
        public int? Duration { get; set; }
        public int? EDocumentsCount { get; set; }
        public string? FileFormats { get; set; }
        public string? FundFormerNameChange { get; set; }
        public string? FundFormerFunction { get; set; }
        public string? FundFormerHistory { get; set; }
        public string? ArchivalHistory { get; set; }
        public string? ImmediateSourceOfAcquisition { get; set; }
        public string Archive { get; set; } = string.Empty;
        public string? DocumentProperties { get; set; }
        public string? Originality { get; set; }
        public string? CreatingType { get; set; }
        public string? Language { get; set; }
        public string? AccessConditions { get; set; }
        public string? FindingAids { get; set; }
        public string? RelatedUnits { get; set; }
        public string? Number { get; set; } // FundNumber
        public string? FundType { get; set; }
        public string? IndustryIndex { get; set; }
        public string? MethodOfAcquisition { get; set; }
        public string? TextDate { get; set; }
        public string? StartDate { get; set; }
        public string? EndDate { get; set; }
        public string? CreationDate { get; set; }
        public string? Title { get; set; }
        public string? Note { get; set; }
        public string? FundStatus { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}
