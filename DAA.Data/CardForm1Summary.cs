using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class CardForm1Summary
    {
        public string Archive { get; set; } = string.Empty;
        public int ArchiveCode { get; set; }
        public string? Number { get; set; }
        public string? Title { get; set; }
        public string? Type { get; set; }
        public string? CreationDate { get; set; }
        public string? IndustryIndex { get; set; }
        public int? InventoriesCount { get; set; }
        public int? ArchivalEntitiesCount { get; set; }
        public string? MethodOfAcquisition { get; set; }
    }
}