using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class WorkListForPriorityRestorationReport
    {
        public string? FundNumber { get; set; }
        public string? InventoryNumber { get; set; }
        public string? ArchiveEntityNumber { get; set; }
        public string DocumentSystemId { get; set; }
        public int? PaperCount { get; set; }
        public string? PhysicalCondition { get; set; }
        public int? CopyDigital { get; set; }
        public int? CopyMicrofilm { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}