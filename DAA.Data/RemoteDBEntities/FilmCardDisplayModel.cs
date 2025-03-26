using Microsoft.EntityFrameworkCore;

namespace DAA.Data.RemoteDBEntities
{
    [Keyless]
    public class FilmCardDisplayModel
    {
        public int Id { get; set; }
        public bool HasExternalSource { get; set; }
        public int? ExternalIdentifier { get; set; }
        public int? FilmExternalIdentifier { get; set; }
        public string? ArchiveName { get; set; }
        public int? ArchiveCode { get; set; }
        public string? InventoryNumber { get; set; }
        public string? CountryName { get; set; }
        public string? CountryCode { get; set; }
        public string? City { get; set; }
        public string? DocumentsCypher { get; set; }
        public string? Title { get; set; }
        public string? ArchiveOriginals { get; set; }
        public int? StartDateDay { get; set; }
        public int? StartDateMonth { get; set; }
        public int? StartDateYear { get; set; }
        public int? EndDateDay { get; set; }
        public int? EndDateMonth { get; set; }
        public int? EndDateYear { get; set; }
        public string? AproximateDate { get; set; }
        public string? FilmingExtentName { get; set; }
        public int? FramesCount { get; set; }
        public int? MicrofilmNegativeCount { get; set; }
        public int? MicrofilmPositiveCount { get; set; }
        public int? PhotoCopy { get; set; }
        public int? DigitalCopy { get; set; }
        public string? Other { get; set; }
        public string? Notes { get; set; }
        public string? DocumentsFormat { get; set; }
        public string? DocumentsCharacteristics { get; set; }
        public string? Source { get; set; }
        public string? Languages { get; set; }
    }
}
