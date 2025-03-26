using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class NumberOfArchiveEntitiesOrderedByEmployeeSummary
    {
        public long TotalRows { get; set; }
    }
}
