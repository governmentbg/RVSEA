using DAA.Shared.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Inventories
{
    public class InventoryDisplayModel : InventoryModel, IDisplayable
    {
        public bool IsDraft { get; set; }
        public bool IsSuspended { get; set; }
        public int? ArchiveCode { get; set; }
        public string? ArchiveName { get; set; }
        public string? FundNumber { get; set; }
        public string? DescriptionLevelText { get; set; }
        public string? AvailabilityStatusText { get; set; }
        public string? StatusText { get; set; }
        public string? AcquisitionMethodText { get; set; }
        public string? CreationMethodText { get; set; }
        public string? OriginalityText { get; set; }
        public string? FileTypeText { get; set; }
        public string? LanguageText { get; set; }
        public int? TextDocsCount { get; set; }
        public int? GraphicalDocsCount { get; set; }
        public bool? IsInPersonalFund { get; set; }
        public bool? IsInProcess { get; set; }
        public bool? HasSystemApplication { get; set; }

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
        //proba
        public double? EnrolledLinearMeters { get; set; }
        public double? DeductedLinearMeters { get; set; }
        public int? EnrolledAECount { get; set; }
        public int? DeductedAECount { get; set; }
        public long? EnrolledBytes { get; set; }
        public long? DeductedBytes { get; set; }
    }
}
