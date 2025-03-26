using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class RegisterOfDigitalObjectsReportSummary
    {
        public int TotalRows { get; set; }
        //public long TotalDOs { get; set; }
        public long? TotalImageCount { get; set; }
        public long? TotalBytesCount { get; set; }
        public long? TotalDuration { get; set; }
    }
}
