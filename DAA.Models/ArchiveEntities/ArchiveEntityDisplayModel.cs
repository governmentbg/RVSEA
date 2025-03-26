namespace DAA.Models.Archives
{
    public class ArchiveEntityDisplayModel
    {
        public int Id { get; set; }
        public int ArchiveId { get; set; }
        public string ArchiveName { get; set; } = string.Empty;
        public bool HasFundExternalSource { get; set; }
        public int? FundExternalIdentifier { get; set; }
        public int FundId { get; set; }
        public string? FundNumber { get; set; }
        public int InventoryId { get; set; }
        public string? InventoryNumber { get; set; }
        public DateTime? CreatedOn { get; set; }
        public string? CreatedByDisplayName { get; set; }
        public string? CreatedByUserName { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public string? UpdatedByDisplayName { get; set; }
        public string? UpdatedByUserName { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public string? DeletedByDisplayName { get; set; }
        public string? DeletedByUserName { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public DateTime? ExternalSourceUpdatedOn { get; set; }
        public string? NumberPrefix { get; set; }
        public string? Number { get; set; }
        public string? Title { get; set; }
        public string? DescriptionLevel { get; set; }
        public string DescriptionLevelCode { get; set; } = null!;
        public string? ApproximateChronologicalScope { get; set; }
        public string? TypeCode { get; set; }
        public string Status { get; set; } = string.Empty;
        public bool HasNoChronologicalScope { get; set; }
        public int? StartDateYear { get; set; }
        public int? StartDateMonth { get; set; }
        public int? StartDateDay { get; set; }
        public int? EndDateYear { get; set; }
        public int? EndDateMonth { get; set; }
        public int? EndDateDay { get; set; }
        public string? ApproxmateChronologicalScope { get; set; }
        public string? Author { get; set; }
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
        public string? DocumentsAccessDescription { get; set; }
        public string? Features { get; set; }
        public string? Condition { get; set; }
        public int? MicrofilmedCopyCount { get; set; }
        public int? DigitizedCopyCount { get; set; }
        public int? PaperCopyCount { get; set; }
        public int? NegativeFrameCount { get; set; }
        public int? PositiveFrameCount { get; set; }
        public string? OtherCopyCount { get; set; }
        public string? Notes { get; set; }
        public long? EnrolledBytes { get; set; }
        public int? EnrolledDocumentCount { get; set; }
        public double? EnrolledLinearMeters { get; set; }
        public long? DeductedBytes { get; set; }
        public int? DeductedDocumentCount { get; set; }
        public double? DeductedLinearMeters { get; set; }
        public string? StatusCode { get; set; } = string.Empty;
        public IEnumerable<string>? OriginalityCodes { get; set; }
        public string? CreationMethodText { get; set; }
        public IEnumerable<string>? CreationMethodCodes { get; set; }
        public string? OriginalityText { get; set; }
        public IEnumerable<string>? LanguageCodes { get; set; }
        public string? LanguageText { get; set; }
    }
}
