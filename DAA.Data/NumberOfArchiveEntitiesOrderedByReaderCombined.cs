using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class NumberOfArchiveEntitiesOrderedByReaderCombined
    {
        public long? TotalCount { get; set; }
        public long? TotalDocumentsCount { get; set; }
    }
}
