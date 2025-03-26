using DAA.Shared.Data;

namespace DAA.Models.DigitalObjects
{
    public class DigitalObjectDisplayModel : DigitalObjectModel, IDisplayable
    {
        public bool IsDraft { get; set; }
        public bool IsSuspended { get; set; }
        public int? ArchiveCode { get; set; }
        public string? ArchiveName { get; set; }
        public string? FundNumber { get; set; }
        public string? InventoryNumber { get; set; }
        public string? ArchivalEntityNumber { get; set; }
        public string? DocumentNumber { get; set; }
        public string? DigitalObjectTypeText { get; set; }
        public string? StatusText { get; set; }
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
        public bool IsExternalSourceSnapshot { get; set; }
        public bool IsImported { get; set; }
    }
}
