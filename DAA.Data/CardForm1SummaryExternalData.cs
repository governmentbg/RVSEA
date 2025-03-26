using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class CardForm1SummaryExternalData : CardForm1Summary
    {
        public double? LinearMeters { get; set; }
        public long? Size { get; set; }
    }
}