using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class RegisterOfDigitizedDocumentsSummary
    {
        public long TotalRows { get; set; }
        public double TotalBytesCount { get; set; }
        public long TotalDuration { get; set; }
        public int MastersCount { get; set; }
        public int AllDOCount { get; set; }

    }
}
