using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class VDigitalObject
    {
        public int Id { get; set; }
        public Guid SystemIdentifier { get; set; }
        public bool? IsDraft { get; set; }
        public bool? IsSuspended { get; set; }
        public int? ParentId { get; set; }
        public Guid? ParentSystemIdentifier { get; set; }
        public int ArchiveId { get; set; }
        public int ArchiveCode { get; set; }
        public string ArchiveName { get; set; } = null!;
        public int? FundDraftId { get; set; }
        public Guid FundSystemIdentifier { get; set; }
        public string? FundNumber { get; set; }
        public bool? FundHasExternalSource { get; set; }
        public int? FundExternalIdentifier { get; set; }
        public int? InventoryDraftId { get; set; }
        public Guid InventorySystemIdentifier { get; set; }
        public string? InventoryNumber { get; set; }
        public bool? InventoryHasExternalSource { get; set; }
        public int? InventoryExternalIdentifier { get; set; }
        public int? ArchivalEntityDraftId { get; set; }
        public Guid ArchivalEntitySystemIdentifier { get; set; }
        public string? ArchivalEntityNumber { get; set; }
        public bool? ArchivalEntityHasExternalSource { get; set; }
        public int? ArchivalEntityExternalIdentifier { get; set; }
        public int? DocumentDraftId { get; set; }
        public Guid DocumentSystemIdentifier { get; set; }
        public string? DocumentNumber { get; set; }
        public bool? DocumentHasExternalSource { get; set; }
        public int? DocumentExternalIdentifier { get; set; }
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
        public int? ExternalIdentifier { get; set; }
        public bool? HasExternalSource { get; set; }
        public DateTime? ExternalSourceUpdatedOn { get; set; }
        public int TypeCode { get; set; }
        public string? Name { get; set; }
        public string SourceName { get; set; } = null!;
        public string UncPath { get; set; } = null!;
        public string FileType { get; set; } = null!;
        public long FileSize { get; set; }
        public string StatusCode { get; set; } = null!;
        public string? ContentType { get; set; }
        public int? AvailabilityStatusCode { get; set; }
        public string? AvailabilityStatusText { get; set; }
        public string? WatermarkName { get; set; }
        public string? WatermarkUncPath { get; set; }
        public string? HashCode { get; set; }
        public int? Duration { get; set; }
        public bool IsImported { get; set; }
        public bool IsDigitized { get; set; }
    }
}
