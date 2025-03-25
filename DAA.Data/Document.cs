using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class Document
    {
        public Document()
        {
            DigitalObjects = new HashSet<DigitalObject>();
            Processes = new HashSet<Process>();
        }

        public int Id { get; set; }
        public int ArchiveId { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public DateTime? ExternalSourceUpdatedOn { get; set; }
        public string? Number { get; set; }
        public string? Title { get; set; }
        public string? FileFormatCode { get; set; }
        public string DescriptionLevelCode { get; set; } = null!;
        public string StatusCode { get; set; } = null!;
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
        public Guid SystemIdentifier { get; set; }
        public Guid FundSystemIdentifier { get; set; }
        public Guid InventorySystemIdentifier { get; set; }
        public Guid ArchivalEntitySystemIdentifier { get; set; }
        public bool IsSuspended { get; set; }
        public int? AvailabilityStatusCode { get; set; }
        public bool IsImported { get; set; }
        public string? DescriptionAuthor { get; set; }
        public string? Cypher { get; set; }
        public int? TextDocsCount { get; set; }
        public int? GraphicalDocsCount { get; set; }
        public string? Phase { get; set; }
        public string? Part { get; set; }
        public string? Stage { get; set; }
        public string? OtherLanguage { get; set; }

        public virtual ArchivalEntity ArchivalEntitySystemIdentifierNavigation { get; set; } = null!;
        public virtual Archive Archive { get; set; } = null!;
        public virtual AvailabilityStatus? AvailabilityStatusCodeNavigation { get; set; }
        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual DocumentDescriptionLevel DescriptionLevelCodeNavigation { get; set; } = null!;
        public virtual Fund FundSystemIdentifierNavigation { get; set; } = null!;
        public virtual Inventory InventorySystemIdentifierNavigation { get; set; } = null!;
        public virtual Status StatusCodeNavigation { get; set; } = null!;
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<DigitalObject> DigitalObjects { get; set; }
        public virtual ICollection<Process> Processes { get; set; }
    }
}
