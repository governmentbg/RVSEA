using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class VDocument
    {
        public int Id { get; set; }
        public Guid SystemIdentifier { get; set; }
        public bool? IsDraft { get; set; }
        public bool? IsSuspended { get; set; }
        public int ArchiveId { get; set; }
        public int ArchiveCode { get; set; }
        public string ArchiveName { get; set; } = null!;
        public int? FundDraftId { get; set; }
        public Guid FundSystemIdentifier { get; set; }
        public string? FundNumber { get; set; }
        public int? FundNumberNumeric { get; set; }
        public string? FundNumberArray { get; set; }
        public bool? FundHasExternalSource { get; set; }
        public int? FundExternalIdentifier { get; set; }
        public string? FundDescriptionLevelCode { get; set; }
        public string? FundStatusCode { get; set; }
        public int? InventoryDraftId { get; set; }
        public Guid InventorySystemIdentifier { get; set; }
        public string? InventoryNumber { get; set; }
        public int? InventoryNumberNumeric { get; set; }
        public string? InventoryNumberArray { get; set; }
        public bool? InventoryHasExternalSource { get; set; }
        public int? InventoryExternalIdentifier { get; set; }
        public int? InventoryAvailabilityStatusCode { get; set; }
        public string? InventoryDescriptionLevelCode { get; set; }
        public string? InventoryStatusCode { get; set; }
        public int? ArchivalEntityDraftId { get; set; }
        public Guid ArchivalEntitySystemIdentifier { get; set; }
        public string? ArchivalEntityNumber { get; set; }
        public int? ArchivalEntityNumberNumeric { get; set; }
        public string? ArchivalEntityNumberArray { get; set; }
        public bool? ArchivalEntityHasExternalSource { get; set; }
        public int? ArchivalEntityExternalIdentifier { get; set; }
        public int? ArchivalEntityAvailabilityStatusCode { get; set; }
        public string? ArchivalEntityDescriptionLevelCode { get; set; }
        public string? ArchivalEntityStatusCode { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public string? CreatedByDisplayName { get; set; }
        public string? CreatedByUserName { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public string? UpdatedByDisplayName { get; set; }
        public string? UpdatedByUserName { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public string? DeletedByDisplayName { get; set; }
        public string? DeletedByUserName { get; set; }
        public bool? HasExternalSource { get; set; }
        public int? ExternalIdentifier { get; set; }
        public DateTime? ExternalSourceUpdatedOn { get; set; }
        public string? Number { get; set; }
        public string? Title { get; set; }
        public string DescriptionLevelCode { get; set; } = null!;
        public string? DescriptionLevelText { get; set; }
        public int? AvailabilityStatusCode { get; set; }
        public string? AvailabilityStatusText { get; set; }
        public string StatusCode { get; set; } = null!;
        public string? StatusText { get; set; }
        public string? FileFormatCode { get; set; }
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
        public int? StartSheetNumber { get; set; }
        public int? EndSheetNumber { get; set; }
        public string? DigitalDevice { get; set; }
        public string? OtherMetrics { get; set; }
        public string? SizeCm { get; set; }
        public string? Scaling { get; set; }
        public int? Duration { get; set; }
        public string? Description { get; set; }
        public string? DocumentsAccessDescription { get; set; }
        public string? Features { get; set; }
        public int? MicrofilmedCopyCount { get; set; }
        public int? DigitizedCopyCount { get; set; }
        public int? PaperCopyCount { get; set; }
        public int? NegativeFrameCount { get; set; }
        public int? PositiveFrameCount { get; set; }
        public string? OtherCopyCount { get; set; }
        public string? Transcription { get; set; }
        public string? Notes { get; set; }
        public bool IsImported { get; set; }
        public string? DescriptionAuthor { get; set; }
        public string? Cypher { get; set; }
        public int? TextDocsCount { get; set; }
        public int? GraphicalDocsCount { get; set; }
        public string? Phase { get; set; }
        public string? Part { get; set; }
        public string? Stage { get; set; }
        public string? OtherLanguage { get; set; }
        public bool? HasDigitizedDigitalObjects { get; set; }
    }
}
