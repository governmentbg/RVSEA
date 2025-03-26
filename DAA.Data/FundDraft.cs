using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class FundDraft
    {
        public FundDraft()
        {
            ArchivalEntityDrafts = new HashSet<ArchivalEntityDraft>();
            DigitalObjectDrafts = new HashSet<DigitalObjectDraft>();
            DocumentDrafts = new HashSet<DocumentDraft>();
            InventoryDrafts = new HashSet<InventoryDraft>();
        }

        public int Id { get; set; }
        public int ArchiveId { get; set; }
        public Guid SystemIdentifier { get; set; }
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
        public string? NumberArray { get; set; }
        public string? Number { get; set; }
        public string Title { get; set; } = null!;
        public string? DescriptionLevelCode { get; set; }
        public string? TypeCode { get; set; }
        public string? StatusCode { get; set; }
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
        public int? ApplicationId { get; set; }
        public int? NumberNumeric { get; set; }
        public int? AcquisitionMethodId { get; set; }

        public virtual Nomenclature? AcquisitionMethod { get; set; }
        public virtual EdocsCollectingApplication? Application { get; set; }
        public virtual Archive Archive { get; set; } = null!;
        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual FundDescriptionLevel? DescriptionLevelCodeNavigation { get; set; }
        public virtual FundArray? NumberArrayNavigation { get; set; }
        public virtual Status? StatusCodeNavigation { get; set; }
        public virtual FundType? TypeCodeNavigation { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<ArchivalEntityDraft> ArchivalEntityDrafts { get; set; }
        public virtual ICollection<DigitalObjectDraft> DigitalObjectDrafts { get; set; }
        public virtual ICollection<DocumentDraft> DocumentDrafts { get; set; }
        public virtual ICollection<InventoryDraft> InventoryDrafts { get; set; }
    }
}
