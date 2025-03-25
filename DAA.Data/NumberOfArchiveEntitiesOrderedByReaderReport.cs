using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class NumberOfArchiveEntitiesOrderedByReaderReport
    {
        public string? Reader { get; set; }
        public string? Archive { get; set; }
        public string? LevelOfDescription { get; set; }
        public string? Fund { get; set; }
        public string? Inventory { get; set; }
        public string? ArchiveEntity { get; set; }
        public string? Document { get; set; }
        public string? ApplicationDate { get; set; }
        public string? AccessDate { get; set; }
    }
}
