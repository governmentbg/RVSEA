using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class RegisterOfDigitizedDocumentsCombined
    {
        public string? PeriodFrom { get; set; }
        public string? PeriodTo { get; set; }
    }
}
