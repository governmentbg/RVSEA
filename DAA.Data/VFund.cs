using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class VFund
    {
        public int Id { get; set; }
        public Guid SystemIdentifier { get; set; }
        public bool? IsDraft { get; set; }
        public bool? IsSuspended { get; set; }
        public int ArchiveId { get; set; }
        public int ArchiveCode { get; set; }
        public string ArchiveName { get; set; } = null!;
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
        public string? NumberArray { get; set; }
        public int? NumberNumeric { get; set; }
        public string? Number { get; set; }
        public string Title { get; set; } = null!;
        public string? DescriptionLevelCode { get; set; }
        public string? DescriptionLevelText { get; set; }
        public string? TypeCode { get; set; }
        public string? TypeText { get; set; }
        public string? StatusCode { get; set; }
        public string? StatusText { get; set; }
        public int? AcquisitionMethodId { get; set; }
        public string? AcquisitionMethodCode { get; set; }
        public string? AcquisitionMethodText { get; set; }
        public bool HasNoChronologicalScope { get; set; }
        public int? StartDateYear { get; set; }
        public int? StartDateMonth { get; set; }
        public int? StartDateDay { get; set; }
        public int? EndDateYear { get; set; }
        public int? EndDateMonth { get; set; }
        public int? EndDateDay { get; set; }
        public string? ApproxmateChronologicalScope { get; set; }
        public long? Bytes { get; set; }
        public double? LinearMeters { get; set; }
        public string? OtherMetrics { get; set; }
        public int? InventoryCount { get; set; }
        public int? ArchivalEntityCount { get; set; }
        public int? DocumentCount { get; set; }
        public string? FundCreatorTitleHistory { get; set; }
        public string? FundCreatorActivityHistory { get; set; }
        public string? FundCreatorBiographicalHistory { get; set; }
        public string? DocumentsProvider { get; set; }
        public string? DocumentsDescription { get; set; }
        public string? ValuableDocumentsInventoryCount { get; set; }
        public string? InvaluableDocumentsInventoryCount { get; set; }
        public string? DocumentsAccessDescription { get; set; }
        public string? History { get; set; }
        public string? RelatedFunds { get; set; }
        public string? Notes { get; set; }
        public long? EnrolledBytes { get; set; }
        public long? EnrolledInventoryCount { get; set; }
        public long? DeductedBytes { get; set; }
        public long? DeductedInventoryCount { get; set; }
    }
}
