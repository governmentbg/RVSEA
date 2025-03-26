namespace DAA.Models.ArchiveEntities
{
    public partial class ArchiveEntityUpdateModel
    {
        public int Id { get; set; }
        public int ArchiveId { get; set; }
        public int FundId { get; set; }
        public int? InventoryId { get; set; }
        public int? InventoryExternalIdentifier { get; set; }
        public string? NumberPrefix { get; set; }
        public string? Number { get; set; }
        public string? Title { get; set; }
        public string DescriptionLevelCode { get; set; } = null!;
        public string? TypeCode { get; set; }
        public string StatusCode { get; set; } = null!;
        public bool HasNoChronologicalScope { get; set; }
        public int? StartDateYear { get; set; }
        public int? StartDateMonth { get; set; }
        public int? StartDateDay { get; set; }
        public int? EndDateYear { get; set; }
        public int? EndDateMonth { get; set; }
        public int? EndDateDay { get; set; }
        public string? ApproximateChronologicalScope { get; set; }
        //public string? Author { get; set; }
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
        public string? Author { get; set; }
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

        public IEnumerable<string>? OriginalityCodes { get; set; }
        public IEnumerable<string>? CreationMethodCodes { get; set; }
        public IEnumerable<string>? LanguageCodes { get; set; }
    }
}
