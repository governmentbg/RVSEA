namespace DAA.Models.Funds
{
    public class FundPublicDisplayModel
    {
        public Guid? SystemIdentifier { get; set; }
        public string? ArchiveName { get; set; }
        public string? Number { get; set; }
        public string? StatusText { get; set; }
        public string? DescriptionLevelText { get; set; }
        public string? Title { get; set; }
        public bool? HasNoChronologicalScope { get; set; }
        public int? StartDateYear { get; set; }
        public int? StartDateMonth { get; set; }
        public int? StartDateDay { get; set; }
        public int? EndDateYear { get; set; }
        public int? EndDateMonth { get; set; }
        public int? EndDateDay { get; set; }
        public string? ApproxmateChronologicalScope { get; set; }
        public int? InventoryCount { get; set; }
        public int? ArchivalEntityCount { get; set; }
        public string? OtherMetrics { get; set; }
        public string? FundCreatorTitleHistory { get; set; }
        public string? FundCreatorBiographicalHistory { get; set; }
        public string? History { get; set; }
        public string? DocumentsDescription { get; set; }
        public string? DocumentsAccessDescription { get; set; }
        public string? RelatedFunds { get; set; }
        public string? Notes { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public string? IndustryTypeText { get; set; }
        public string? LanguageText { get; set; }
        public string? FileTypeText { get; set; }
        public double? LinearMeters { get; set; }
        public int? DocumentCount { get; set; }
        public string? ResultMessage { get; set; }
        public long? Bytes { get; set; }
    }
}
