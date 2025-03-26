using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class SearchedArchiveEntityShortModel
    {
        public bool HasExternalSource { get; set; }
        public int? Id { get; set; }
        public int? ExternalIdentifier { get; set; }
        public string? Number { get; set; }
        public string? Title { get; set; }
    }
}