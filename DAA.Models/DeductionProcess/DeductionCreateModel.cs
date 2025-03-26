
namespace DAA.Models.DeductionProcess
{
    public class DeductionCreateModel
    {
        public int? ArchiveId { get; set; }
        public string? FundSystemIdentifier { get; set; }
        public string? InventorySystemIdentifier { get; set; }
        public string? ArchivalEntitySystemIdentifier { get; set; }
        public string? DocumentSystemIdentifier { get; set; }
        public int? ProcedureType { get; set; }
        public int? ProcedureStepId { get; set; }
        public int? FundExternalIdentifier { get; set; }
        public int? InventoryExternalIdentifier { get; set;}
        public int? ArchivalEntityExternalIdentifier { get; set; }
        public int? DocumentEntityExternalIdentifier { get; set; }
    }
}


