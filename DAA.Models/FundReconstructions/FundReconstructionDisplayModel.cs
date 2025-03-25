namespace DAA.Models.FundReconstructions
{
    public class FundReconstructionDisplayModel : FundReconstructionModel
    {
        public string? AvailabilityStatusText { get; set; }
        public string? FundNumber { get; set; }
        public string? SourceInventoryNumber { get; set; }
        public string? SourceArchivalEntityNumber { get; set; }
        public string? SourceDocumentTitle { get; set; }
        public string? TargetInventoryNumber { get; set; }
        public string? TargetArchivalEntityNumber { get; set; }
        public string? TargetDocumentTitle { get; set; }
        public DateTime? CreatedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public DateTime? DeletedOn { get; set; }
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
    }
}
