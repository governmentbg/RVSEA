
using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class SearchResult
    {
        //public int? Id { get; set; }
        public string? EntityType { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public string? ArchiveName { get; set; }
        public string? FundNumber { get; set; }
        public string? InventoryNumber { get; set; }
        public string? ArchivalEntityNumber { get; set; }
        public string? KMFNumber { get; set; }
        public string? Title { get; set; }
        public string? TypeText { get; set; }
        public string? StatusText { get; set; }
        public string? FundDescriptionLevelText { get; set; }
        public string? InventoryDescriptionLevelText { get; set; }
        public string? ArchivalEntityDescriptionLevelText { get; set; }
        public bool? HasExternalSource { get; set; }
        public int? ExternalIdentifier { get; set; }
        public string? FundApproximateChronologicalScope { get; set; }
        public string? InventoryApproximateChronologicalScope { get; set; }
        public string? ArchivalEntityApproximateChronologicalScope { get; set; }
        public Guid? FilmSystemIdentifier { get; set; }
        public int? FundGid { get; set; }
        public int TotalRows { get; set; }
        public bool? HasDigitizedDigitalObjects { get; set; }
        public string? DocumentNumber { get; set; }
        //public string? TypeText { get; set; }
    }
}
