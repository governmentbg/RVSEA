using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class TotalRowsSummary
    {
        public long TotalRows { get; set; }
    }
}
