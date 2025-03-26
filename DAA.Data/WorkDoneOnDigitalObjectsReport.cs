using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class WorkDoneOnDigitalObjectsReport
    {
        public int TotalCount { get; set; }
        public int? DigitalObjectsCount { get; set; }
        public string? UserName { get; set; }
        public string? Archive { get; set; }
    }
}
