using Microsoft.EntityFrameworkCore;

namespace DAA.Data.RemoteDBEntities
{
    [Keyless]
    public class Document
    {
        public int? Id { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public string? Number { get; set; }
        public string Title { get; set; } = null!;       
        public bool Deleted { get; set; }
        public int? StartSheetNumber { get; set; }
        public int? EndSheetNumber { get; set; }
        public string? DescriptionLevel { get; set; }
        public string? ApproximateChronologicalScope { get; set; }
    }
}
