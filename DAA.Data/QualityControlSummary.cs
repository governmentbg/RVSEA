using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class QualityControlSummary
    {
        public long TotalRows { get; set; }
    }
}
