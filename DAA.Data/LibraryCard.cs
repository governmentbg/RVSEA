using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public partial class LibraryCard
    {
        public DateTime ValidFrom { get; set; }
        public DateTime ValidTo { get; set; }
    }
}
