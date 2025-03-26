
using Microsoft.EntityFrameworkCore;

namespace DAA.Data.RemoteDBEntities
{
    [Keyless]
    public class DocumentAncestorsData
    {
        public string? ArchiveName { get; set; }
        public int? ArchiveCode { get; set; }
        public int? FundExternalIdentifier { get; set; }
        public string? FundNumber { get; set; }
        public int? InventoryExternalIdentifier { get; set; }
        public string? InventoryNumber { get; set; }
        public string? ArchiveEntityNumber { get; set; }
    }
}
