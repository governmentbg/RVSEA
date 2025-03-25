namespace DAA.Models.FundReconstructions
{
    public class FundReconstructionModel
    {
        public int? Id { get; set; }
        public int AvailabilityStatusCode { get; set; }
        public int ProcessId { get; set; }
        public int ArchiveId { get; set; }
        public Guid FundSystemIdentifier { get; set; }
        public Guid? SourceInventorySystemIdentifier { get; set; }
        public Guid? SourceArchivalEntitySystemIdentifier { get; set; }
        public Guid? SourceDocumentSystemIdentifier { get; set; }
        public Guid? TargetInventorySystemIdentifier { get; set; }
        public Guid? TargetArchivalEntitySystemIdentifier { get; set; }
        public Guid? TargetDocumentSystemIdentifier { get; set; }
        
    }
}
