using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class MostUsedRequestEntitiesReport
    {
        public string Archive { get; set; } = string.Empty;
        public string? DescriptionLevel { get; set; }
        public string? FundNumber { get; set; }
        public string? InventoryNumber { get; set; }
        public string? ArchiveEntityNumber { get; set; }
        public string? DocumentNumber { get; set; }
        public long UsageCount { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}
