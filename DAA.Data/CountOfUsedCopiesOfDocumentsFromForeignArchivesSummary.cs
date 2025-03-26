using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class CountOfUsedCopiesOfDocumentsFromForeignArchivesSummary
    {
        public long TotalRows { get; set; }
    }
}
