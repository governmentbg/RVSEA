namespace DAA.Models.DocsCollectionProcedure
{
    public class DocsCollectingGridModel
    {
        public bool Completed { get; set; }
        public string ProcessTypeTitle { get; set; }
        public string ProcessStepTitle { get; set; }
        public int? ArchiveId { get; set; }
        public string ArchiveName { get; set; }
        public Guid? FundSystemId { get; set; }
        public string FundNumber { get; set; }
        public Guid? InventorySystemId { get; set; }
        public string InventoryNumber { get; set; }
        public DateTime? CreatedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public Guid? UpdatedBy { get; set; }
        public string? CreatedByUserName { get; set; }
        public string? CreatedByDisplayName { get; set; }
        public string? UpdatedByUserName { get; set; }
        public string? UpdatedByDisplayName { get; set; }
    }
}
