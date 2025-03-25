using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class TotalSummary
    {
        public int? Total { get; set; }
    }
}
