using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class FundsListReport
    {
        public string? Number { get; set; }
        public string? CreationDate { get; set; }
        public string? Title { get; set; }
        public string? Note { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}
