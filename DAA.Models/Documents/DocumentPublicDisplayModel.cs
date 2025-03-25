
namespace DAA.Models.Documents
{
    public class DocumentPublicDisplayModel
    {
        public Guid? SystemIdentifier { get; set; }
        public Guid? InventorySystemIdentifier { get; set; }
        public bool? InventoryHasExternalSource { get; set; }
        public int? InventoryExternalIdentifier { get; set; }
        public Guid? ArchivalEntitySystemIdentifier { get; set; }
        public bool? ArchivalEntityHasExternalSource { get; set; }
        public int? ArchivalEntityExternalIdentifier { get; set; }
        public Guid? FundSystemIdentifier { get; set; }
        public int? FundExternalIdentifier { get; set; }
        public bool? FundHasExternalSource { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool? HasExternalSource { get; set; }
        public string? ArchiveName { get; set; }
        public string? FundNumber { get; set; }
        public string? InventoryNumber { get; set; }
        public string? ArchivalEntityNumber { get; set; }
        public string? Number { get; set; }
        public string? DescriptionLevelText { get; set; }
        public string? FileTypeText { get; set; }
        public int? StartSheetNumber { get; set; }
        public int? EndSheetNumber { get; set; }
        public string? Title { get; set; }
        public bool HasNoChronologicalScope { get; set; }
        public int? StartDateYear { get; set; }
        public int? StartDateMonth { get; set; }
        public int? StartDateDay { get; set; }
        public int? EndDateYear { get; set; }
        public int? EndDateMonth { get; set; }
        public int? EndDateDay { get; set; }
        public string? ApproximateChronologicalScope { get; set; }
        public string? Location { get; set; }
        public int? SheetCount { get; set; }
        public string? DigitalDevice { get; set; }
        public string? Author { get; set; }
        public string? SizeCm { get; set; }
        public string? Scaling { get; set; }
        public int? Duration { get; set; }
        public long? Bytes { get; set; }
        public string? Description { get; set; }
        public string? OriginalityText { get; set; }
        public string? CreationMethodText { get; set; }
        public string? LanguageText { get; set; }
        public string? DocumentsAccessDescription { get; set; }
        public string? Features { get; set; }
        public int? MicrofilmedCopyCount { get; set; }
        public int? DigitizedCopyCount { get; set; }
        public int? PaperCopyCount { get; set; }
        public int? NegativeFrameCount { get; set; }
        public int? PositiveFrameCount { get; set; }
        public string? OtherCopyCount { get; set; }
        public string? Notes { get; set; }
        public bool Deleted { get; set; }
        public string? ResultMessage { get; set; }
        public string? StatusText { get; set; }
        public bool? HasDigitizedDigitalObjects { get; set; }

    }
}
