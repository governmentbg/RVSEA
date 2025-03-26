using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class InventoryDraft
    {
        public InventoryDraft()
        {
            ArchivalEntityDrafts = new HashSet<ArchivalEntityDraft>();
            DigitalObjectDrafts = new HashSet<DigitalObjectDraft>();
            DocumentDrafts = new HashSet<DocumentDraft>();
        }

        public int Id { get; set; }
        public Guid SystemIdentifier { get; set; }
        public int ArchiveId { get; set; }
        public int? FundDraftId { get; set; }
        public Guid FundSystemIdentifier { get; set; }
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
        public string? DescriptionLevelCode { get; set; }
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
        public int? ArchivalEntityCount { get; set; }
        public int? DocumentCount { get; set; }
        public int? BoxCount { get; set; }
        public int? RollCount { get; set; }
        public int? AudioDocumentArchivalEntityCount { get; set; }
        public int? PhotoDocumentArchivalEntityCount { get; set; }
        public int? VideoDocumentArchivalEntityCount { get; set; }
        public int? DigitalDocumentArchivalEntityCount { get; set; }
        public string? FundCreatorTitleHistory { get; set; }
        public string? FundCreatorBiographicalHistory { get; set; }
        public string? History { get; set; }
        public string? DocumentsProvider { get; set; }
        public string? DocumentsDescription { get; set; }
        public string? DocumentsAccessDescription { get; set; }
        public string? ClassificationScheme { get; set; }
        public string? AbbreviationList { get; set; }
        public int? MicrofilmedArchivalEntityCount { get; set; }
        public int? DigitizedArchivalEntityCount { get; set; }
        public int? NegativeFrameCount { get; set; }
        public int? PositiveFrameCount { get; set; }
        public string? Notes { get; set; }
        public int? ApplicationId { get; set; }
        public int? PackageAid { get; set; }
        public int? PackageBid { get; set; }
        public int? AvailabilityStatusCode { get; set; }
        public int? NumberNumeric { get; set; }
        public int? AcquisitionMethodId { get; set; }
        public string? OtherLanguage { get; set; }

        public virtual Nomenclature? AcquisitionMethod { get; set; }
        public virtual EdocsCollectingApplication? Application { get; set; }
        public virtual Archive Archive { get; set; } = null!;
        public virtual AvailabilityStatus? AvailabilityStatusCodeNavigation { get; set; }
        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual InventoryDescriptionLevel? DescriptionLevelCodeNavigation { get; set; }
        public virtual FundDraft? FundDraft { get; set; }
        public virtual InventoryArray? NumberArrayNavigation { get; set; }
        public virtual Package? PackageA { get; set; }
        public virtual Package? PackageB { get; set; }
        public virtual Status? StatusCodeNavigation { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<ArchivalEntityDraft> ArchivalEntityDrafts { get; set; }
        public virtual ICollection<DigitalObjectDraft> DigitalObjectDrafts { get; set; }
        public virtual ICollection<DocumentDraft> DocumentDrafts { get; set; }
    }
}
