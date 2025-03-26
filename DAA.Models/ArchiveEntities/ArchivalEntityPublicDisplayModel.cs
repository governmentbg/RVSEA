namespace DAA.Models.ArchiveEntities
{
    public class ArchivalEntityPublicDisplayModel
    {
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public string? ArchiveName { get; set; }
        public string? FundNumberArray { get; set; }
        public int? FundNumberNumeric { get; set; }
        public string? FundNumber { get; set; }
        public Guid? FundSystemIdentifier { get; set; }
        public Guid? InventorySystemIdentifier { get; set; }
        public bool? FundHasExternalSource { get; set; }
        public int? FundExternalIdentifier { get; set; }
        public bool? InventoryHasExternalSource { get; set; }
        public int? InventoryExternalIdentifier { get; set; }
        public string? InventoryNumberArray { get; set; }
        public int? InventoryNumberNumeric { get; set; }
        public string? InventoryNumber { get; set; }
        public string? Number { get; set; }
        public string? DescriptionLevelText { get; set; }
        public string? Title { get; set; }
        public bool HasNoChronologicalScope { get; set; }
        public int? StartDateYear { get; set; }
        public int? StartDateMonth { get; set; }
        public int? StartDateDay { get; set; }
        public int? EndDateYear { get; set; }
        public int? EndDateMonth { get; set; }
        public int? EndDateDay { get; set; }
        public string? ApproxmateChronologicalScope { get; set; }
        public string? Location { get; set; }
        public long? Bytes { get; set; }
        public int? SheetCount { get; set; }
        public int? TapeCount { get; set; }
        public int? MicrofilmCount { get; set; }
        public int? FrameCount { get; set; }
        public int? VideoTapeCount { get; set; }
        public int? DigitalDeviceCount { get; set; }
        public string? OtherMetrics { get; set; }
        public string? SizeCm { get; set; }
        public string? Scaling { get; set; }
        public string? Description { get; set; }
        public string? CreationMethodText { get; set; }
        public string? OriginalityText { get; set; }
        public string? LanguageText { get; set; }
        public string? Features { get; set; }
        public int? MicrofilmedCopyCount { get; set; }
        public int? DigitizedCopyCount { get; set; }
        public int? PaperCopyCount { get; set; }
        public int? NegativeFrameCount { get; set; }
        public int? PositiveFrameCount { get; set; }
        public double? EnrolledLinearMeters { get; set; }
        public int? EnrolledDocumentCount { get; set; }
        public double? DeductedLinearMeters { get; set; }
        public int? DeductedDocumentCount { get; set; }
        public long? DeductedBytes { get; set; }
        public string? FileTypeText { get; set; }
        public int? DocumentCount { get; set; }
        public string? StatusText { get; set; } 
        public string? ResultMessage { get; set; } //TODO Да се махне това безумно пропърти 
        public bool IsExternalSourceSnapshot { get; set; }
        public bool? HasDigitizedDigitalObjects { get; set; }
    }
}
