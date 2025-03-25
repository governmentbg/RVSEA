using DAA.Shared.Data;

namespace DAA.Models.Documents
{
    public class DocumentDisplayModel : DocumentModel, IDisplayable
    {
        public bool IsDraft { get; set; }
        public bool IsSuspended { get; set; }
        public int? ArchiveCode { get; set; }
        public string? ArchiveName { get; set; }
        public string? FundNumber { get; set; }
        public string? InventoryNumberArray { get; set; }
        public int? InventoryNumberNumeric { get; set; }
        public string? InventoryNumber { get; set; }
        public string? ArchivalEntityNumber { get; set; }
        public string? DescriptionLevelText { get; set; }
        public string? StatusText { get; set; }
        public bool? IsInProcess { get; set; }
        public string? AvailabilityStatusText { get; set; }
        public string? FileFormatText { get; set; }
        public string? CreationMethodText { get; set; }
        public string? OriginalityText { get; set; }
        public string? FileTypeText { get; set; }
        public string? LanguageText { get; set; }
        public DateTime? CreatedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public DateTime? DeletedOn { get; set; }
        public DateTime? ExternalSourceUpdatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public Guid? UpdatedBy { get; set; }
        public Guid? DeletedBy { get; set; }
        public bool Deleted { get; set; }
        public string? CreatedByUserName { get; set; }
        public string? CreatedByDisplayName { get; set; }
        public string? UpdatedByUserName { get; set; }
        public string? UpdatedByDisplayName { get; set; }
        public string? DeletedByUserName { get; set; }
        public string? DeletedByDisplayName { get; set; }
        public string? ResultMessage { get; set; }
        public bool? HasDigitizedDigitalObjects { get; set; }
        public int? SheetCount { get; set; }
    }
}
