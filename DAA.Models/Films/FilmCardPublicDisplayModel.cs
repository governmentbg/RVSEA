

namespace DAA.Models.Films
{
    public class FilmCardPublicDisplayModel
    {
        public string? ArchiveName { get; set; }
        public string? CountryName { get; set; }
        public string? FilmingExtentName { get; set; }
        public string? LanguageText { get; set; }
        public Guid SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public Guid FilmSystemIdentifier { get; set; }     
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
        public int? FilmingExtentId { get; set; }
        public string? Source { get; set; }
        public string InventoryNumber { get; set; } = String.Empty;
        public int? FramesCount { get; set; }
        public int? MicrofilmNegativeCount { get; set; }
        public int? MicrofilmPositiveCount { get; set; }
        public string? PhotoCopy { get; set; }
        public string? DigitalCopy { get; set; }
        public string? Size { get; set; }
        public string? Other { get; set; }
        public string? Notes { get; set; }
        public string? DocumentsFormat { get; set; }
        public string? DocumentsCharacteristics { get; set; }

        public IEnumerable<string>? LanguageCodes { get; set; }
        public IEnumerable<int>? DocumentIds { get; set; }

    }
}
