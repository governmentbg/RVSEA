using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class VFundReconstruction
    {
        public int Id { get; set; }
        public int ProcessId { get; set; }
        public int? AvailabilityStatusCode { get; set; }
        public string? AvailabilityStatusText { get; set; }
        public int ArchiveId { get; set; }
        public int ArchiveCode { get; set; }
        public string ArchiveName { get; set; } = null!;
        public Guid FundSystemIdentifier { get; set; }
        public string? FundNumber { get; set; }
        public bool? FundHasExternalSource { get; set; }
        public int? FundExternalIdentifier { get; set; }
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
        public Guid? SourceInventorySystemIdentifier { get; set; }
        public string? SourceInventoryNumber { get; set; }
        public string? SourceInventoryDescriptionLevelCode { get; set; }
        public string? SourceInventoryDescriptionLevelText { get; set; }
        public int? SourceInventoryAvailabilityStatusCode { get; set; }
        public string? SourceInventoryAvailabilityStatusText { get; set; }
        public string? SourceInventoryApproximateChronologicalScope { get; set; }
        public bool? SourceInventoryHasExternalSource { get; set; }
        public int? SourceInventoryExternalIdentifier { get; set; }
        public Guid? SourceArchivalEntitySystemIdentifier { get; set; }
        public string? SourceArchivalEntityNumber { get; set; }
        public string? SourceArchivalEntityTitle { get; set; }
        public string? SourceArchivalEntityDescriptionLevelCode { get; set; }
        public string? SourceArchivalEntityDescriptionLevelText { get; set; }
        public int? SourceArchivalEntityAvailabilityStatusCode { get; set; }
        public string? SourceArchivalEntityAvailabilityStatusText { get; set; }
        public string? SourceArchivalEntityApproximateChronologicalScope { get; set; }
        public bool? SourceArchivalEntityHasExternalSource { get; set; }
        public int? SourceArchivalEntityExternalIdentifier { get; set; }
        public Guid? SourceDocumentSystemIdentifier { get; set; }
        public string? SourceDocumentTitle { get; set; }
        public string? SourceDocumentDescriptionLevelCode { get; set; }
        public string? SourceDocumentDescriptionLevelText { get; set; }
        public int? SourceDocumentAvailabilityStatusCode { get; set; }
        public string? SourceDocumentAvailabilityStatusText { get; set; }
        public string? SourceDocumentApproxmateChronologicalScope { get; set; }
        public bool? SourceDocumentHasExternalSource { get; set; }
        public int? SourceDocumentExternalIdentifier { get; set; }
        public Guid? TargetInventorySystemIdentifier { get; set; }
        public string? TargetInventoryNumber { get; set; }
        public string? TargetInventoryDescriptionLevelCode { get; set; }
        public string? TargetInventoryDescriptionLevelText { get; set; }
        public int? TargetInventoryAvailabilityStatusCode { get; set; }
        public string? TargetInventoryAvailabilityStatusText { get; set; }
        public string? TargetInventoryApproximateChronologicalScope { get; set; }
        public Guid? TargetArchivalEntitySystemIdentifier { get; set; }
        public string? TargetArchivalEntityNumber { get; set; }
        public string? TargetArchivalEntityTitle { get; set; }
        public string? TargetArchivalEntityDescriptionLevelCode { get; set; }
        public string? TargetArchivalEntityDescriptionLevelText { get; set; }
        public int? TargetArchivalEntityAvailabilityStatusCode { get; set; }
        public string? TargetArchivalEntityAvailabilityStatusText { get; set; }
        public string? TargetArchivalEntityApproximateChronologicalScope { get; set; }
        public bool? TargetArchivalEntityHasExternalSource { get; set; }
        public int? TargetArchivalEntityExternalIdentifier { get; set; }
        public Guid? TargetDocumentSystemIdentifier { get; set; }
        public string? TargetDocumentTitle { get; set; }
        public string? TargetDocumentDescriptionLevelCode { get; set; }
        public string? TargetDocumentDescriptionLevelText { get; set; }
        public int? TargetDocumentAvailabilityStatusCode { get; set; }
        public string? TargetDocumentAvailabilityStatusText { get; set; }
        public string? TargetDocumentApproxmateChronologicalScope { get; set; }
        public bool? TargetDocumentHasExternalSource { get; set; }
        public int? TargetDocumentExternalIdentifier { get; set; }
    }
}
