using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class DigitalObjectDraft
    {
        public int Id { get; set; }
        public Guid SystemIdentifier { get; set; }
        public int? ParentId { get; set; }
        public Guid? ParentSystemIdentifier { get; set; }
        public int ArchiveId { get; set; }
        public int? FundDraftId { get; set; }
        public Guid FundSystemIdentifier { get; set; }
        public int? InventoryDraftId { get; set; }
        public Guid InventorySystemIdentifier { get; set; }
        public int? ArchivalEntityDraftId { get; set; }
        public Guid ArchivalEntitySystemIdentifier { get; set; }
        public int? DocumentDraftId { get; set; }
        public Guid DocumentSystemIdentifier { get; set; }
        public bool IsCurrent { get; set; }
        public bool ReadOnly { get; set; }
        public string? WorkflowTypeCode { get; set; }
        public int? WorkflowId { get; set; }
        public string? WorkflowStepTypeCode { get; set; }
        public int? WorkflowStepId { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool? HasExternalSource { get; set; }
        public DateTime? ExternalSourceUpdatedOn { get; set; }
        public string? Name { get; set; }
        public string SourceName { get; set; } = null!;
        public string UncPath { get; set; } = null!;
        public string FileType { get; set; } = null!;
        public string StatusCode { get; set; } = null!;
        public string? ContentType { get; set; }
        public int TypeCode { get; set; }
        public int? AvailabilityStatusCode { get; set; }
        public string? WatermarkName { get; set; }
        public string? WatermarkUncPath { get; set; }
        public string? HashCode { get; set; }
        public int? PackageDocumentId { get; set; }
        public bool? ChecksumCheckResult { get; set; }
        public bool? FileFormatCheckResult { get; set; }
        public bool? AntivirusCheckResult { get; set; }
        public string? AntivirusCheckInfo { get; set; }
        public string? FileInfo { get; set; }
        public string? ErrorMessage { get; set; }
        public long FileSize { get; set; }
        public bool IsImported { get; set; }
        public int? Duration { get; set; }
        public bool IsDigitized { get; set; }

        public virtual ArchivalEntityDraft? ArchivalEntityDraft { get; set; }
        public virtual Archive Archive { get; set; } = null!;
        public virtual AvailabilityStatus? AvailabilityStatusCodeNavigation { get; set; }
        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual DocumentDraft? DocumentDraft { get; set; }
        public virtual FundDraft? FundDraft { get; set; }
        public virtual InventoryDraft? InventoryDraft { get; set; }
        public virtual PackageDocument? PackageDocument { get; set; }
        public virtual Status StatusCodeNavigation { get; set; } = null!;
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
    }
}
