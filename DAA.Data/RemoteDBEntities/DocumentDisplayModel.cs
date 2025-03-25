using Microsoft.EntityFrameworkCore;

namespace DAA.Data.RemoteDBEntities
{
    [Keyless]
    public class DocumentDisplayModel
    {
        public int? Id { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
		public int? ExternalIdentifier { get; set; }
        public int? ArchiveCode { get; set; }
		public string? ArchiveName { get; set; }
        public bool? FundHasExternalSource { get; set; }
		public int? FundExternalIdentifier { get; set; }
		public string? FundNumber { get; set; }
        public bool? InventoryHasExternalSource { get; set; }
		public int? InventoryExternalIdentifier { get; set; }
	    public string? InventoryNumber { get; set; }
        public bool? ArchivalEntityHasExternalSource { get; set; }
		public int? ArchivalEntityExternalIdentifier { get; set; }
		public string? ArchivalEntityNumber { get; set; }
        public string? Number { get; set; }
        public string? Title { get; set; }
        public string? DescriptionLevelCode { get; set; }
        public string? DescriptionLevelText { get; set; }
        public string? StatusCode { get; set; }
        public string? StatusText { get; set; }
        public int? AvailabilityStatusCode { get; set; }
        public string? AvailabilityStatusText { get; set; }
        public string? CreationMethodText { get; set; }
	    public string? OriginalityText { get; set; }
	    public string? LanguageText { get; set; }
        public bool? HasNoChronologicalScope { get; set; }
        public int? StartDateYear { get; set; }
        public int? StartDateMonth { get; set; }
        public int? StartDateDay { get; set; }
        public int? EndDateYear { get; set; }
        public int? EndDateMonth { get; set; }
        public int? EndDateDay { get; set; }
        public string? ApproximateChronologicalScope { get; set; }
        public string? Location { get; set; }
        public string? SizeCm { get; set; }
        public string? Description { get; set; }
        public string? DocumentsAccessDescription { get; set; }
        public string? Features { get; set; }
        public int? MicrofilmedCopyCount { get; set; }
        public int? DigitizedCopyCount { get; set; }
        public int? PaperCopyCount { get; set; }
        public int? NegativeFrameCount { get; set; }
        public int? PositiveFrameCount { get; set; }
        public string? OtherCopyCount { get; set; }
        public string? Notes { get; set; }
        public DateTime? CreatedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public string? CreatedByDisplayName { get; set; }
        public string? UpdatedByDisplayName { get; set; }
        public int? SheetCount { get; set; }
        public bool? HasDigitizedDigitalObjects { get; set; }
        public int? StartSheetNumber { get; set; }
        public int? EndSheetNumber { get; set; }
        // public string? ClassificationSchemeIndex { get; set; }
    }
}
