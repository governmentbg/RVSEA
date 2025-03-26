
namespace DAA.Models.Inventories
{
    public class InventoryPublicDisplayModel
    {
        public Guid? SystemIdentifier { get; set; }
        public string? ArchiveName { get; set; }
        public string? FundNumber { get; set; }
        public string? Number { get; set; }
        public string? DescriptionLevelText { get; set; }
        public string? AcquisitionMethodText { get; set; }
        public bool HasNoChronologicalScope { get; set; }
        public int? StartDateYear { get; set; }
        public int? StartDateMonth { get; set; }
        public int? StartDateDay { get; set; }
        public int? EndDateYear { get; set; }
        public int? EndDateMonth { get; set; }
        public int? EndDateDay { get; set; }
        public string? ApproxmateChronologicalScope { get; set; }
        public long? Bytes { get; set; }
        public double? LinearMeters { get; set; }
        public int? BoxCount { get; set; }
        public int? RollCount { get; set; }
        public int? AudioDocumentArchivalEntityCount { get; set; }
        public int? PhotoDocumentArchivalEntityCount { get; set; }
        public int? VideoDocumentArchivalEntityCount { get; set; }
        public int? DigitalDocumentArchivalEntityCount { get; set; }
        public string? FileTypeText { get; set; }
        public string? OtherMetrics { get; set; }
        public string? FundCreatorTitleHistory { get; set; }
        public string? FundCreatorBiographicalHistory { get; set; }
        public string? History { get; set; }
        public string? DocumentsProvider { get; set; }
        public string? DocumentsDescription { get; set; }
        public string? OriginalityText { get; set; }
        public string? CreationMethodText { get; set; }
        public string? LanguageText { get; set; }
        public string? DocumentsAccessDescription { get; set; }
        public int? MicrofilmedArchivalEntityCount { get; set; }
        public int? DigitizedArchivalEntityCount { get; set; }
        public int? NegativeFrameCount { get; set; }
        public int? PositiveFrameCount { get; set; }
        public string? Notes { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public int? FundExternalIdentifier { get; set; }
        public bool? FundHasExternalSource { get; set; }
        public int? ArchivalEntityCount { get; set; }
        public int? DocumentCount { get; set; }
        public Guid? FundSystemIdentifier { get; set; }
        public string? ResultMessage { get; set; }
    }
}
