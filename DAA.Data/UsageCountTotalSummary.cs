using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class UsageCountTotalSummary
    {
        public long? UsageCountTotal { get; set; }
    }
}
