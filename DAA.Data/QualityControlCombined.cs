using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class QualityControlCombined
    {
        public DateTime? PeriodFrom { get; set; }
        public DateTime? PeriodTo { get; set; }
        public int? CheckedDocuments { get; set; }
        public int? CheckedDo { get; set; }
        public int? AcceptedDocuments { get; set; }
        public int? AcceptedDo { get; set; }
        public int? ReturnedDocuments { get; set; }
        public int? ReturnedDo { get; set; }
    }
}
