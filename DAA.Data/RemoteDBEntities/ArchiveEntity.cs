using Microsoft.EntityFrameworkCore;

namespace DAA.Data.RemoteDBEntities
{
    [Keyless]
    public class ArchiveEntity
    {
        public int? Id { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public string Number { get; set; } = string.Empty;
        public string Title { get; set; } = null!;       
        public bool Deleted { get; set; }
        public string? Status { get; set; }
        public string? DescriptionLevel { get; set; }
        public string? ApproximateChronologicalScope { get; set; }
    }
}
