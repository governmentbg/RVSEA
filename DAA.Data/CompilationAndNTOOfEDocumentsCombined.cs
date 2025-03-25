using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class CompilationAndNTOOfEDocumentsCombined
    {
        public int? FundsCount { get; set; }
        public int? InventoriesCount { get; set; }
        public int? AesCount { get; set; }
        public long? Bytes { get; set; }
        public int? Duration { get; set; }
    }
}
