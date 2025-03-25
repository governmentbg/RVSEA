using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Films
{
    public class FilmCardModel
    {
        public int Id { get; set; }
        public Guid SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        
        public int FilmId { get; set; }
        [Required]
        public Guid FilmSystemIdentifier { get; set; }
        [Required]
        public int ArchiveId { get; set; }
        public int? CountryId { get; set; }
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
        [Required]
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
