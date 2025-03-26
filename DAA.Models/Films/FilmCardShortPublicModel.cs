
namespace DAA.Models.Films
{
    public class FilmCardShortPublicModel
    {
        public Guid? SystemIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public int? ExternalIdentifier { get; set; }
        public Guid? FilmSystemIdentifier { get; set; }
        public int? FilmExternalIdentifier { get; set; }
        public string? CountryName { get; set; }
        public string? InventoryNumber { get; set; }
        public string? Title { get; set; }
    }
}
