using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class CardForm1SummaryInternalData : CardForm1Summary
    {
        public long? Size { get; set; }
    }
}