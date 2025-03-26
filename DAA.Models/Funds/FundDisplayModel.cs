using DAA.Shared.Data;

namespace DAA.Models.Funds
{
    public class FundDisplayModel : FundModel, IDisplayable
    {
        public bool IsDraft { get; set; }
        public bool IsSuspended { get; set; }
        public int? ArchiveCode { get; set; }
        public string? ArchiveName { get; set; }
        public string? DescriptionLevelText { get; set; }
        public string? TypeText { get; set; }
        public string? StatusText { get; set; }
        public string? AcquisitionMethodText { get; set; }
        public string? IndustryTypeText { get; set; }
        public string? FileTypeText { get; set; }
        public string? LanguageText { get; set; }
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
    }
}
