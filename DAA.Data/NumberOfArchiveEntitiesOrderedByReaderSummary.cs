using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class NumberOfArchiveEntitiesOrderedByReaderSummary
    {
        public long TotalRows { get; set; }
    }
}
