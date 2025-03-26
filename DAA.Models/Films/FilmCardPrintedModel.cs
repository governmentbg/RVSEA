using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Films
{
    public class FilmCardPrintedModel
    {
        public string? Country { get; set; }
        public string? CountryCode { get; set; }
        public string? City { get; set; }
        public string? ArchiveOriginals { get; set; }
        public string Archive { get; set; } = string.Empty;
        public string? DocumentsCipher { get; set; }
        public string Number { get; set; } = string.Empty;
        public string? Title { get; set; }
        public int? CopyType { get; set; }
        public int? StartDateDay { get; set; }
        public int? StartDateMonth { get; set; }
        public int? StartDateYear { get; set; }
        public int? EndDateDay { get; set; }
        public int? EndDateMonth { get; set; }
        public int? EndDateYear { get; set; }
        public string? DocumentsFormat { get; set; }
        public IEnumerable<string>? DocumentsLanguage { get; set; }
        public string? FilmingExtent { get; set; }
        public int? AcceptedOnDay { get; set; }
        public int? AcceptedOnMonth { get; set; }
        public int? AcceptedOnYear { get; set; }
        //public int? FramesCount { get; set; }
        //public int? MicrofilmNegativeCount { get; set; }
        //public int? MicrofilmPositiveCount { get; set; }
        //public string? PhotoCopy { get; set; }
        //public string? DigitalCopy { get; set; }
        public string? CopyVolume { get; set; }
        public string? Source { get; set; }
        public string? Notes { get; set; }
        public string? DocumentsCharacteristics { get; set; }
        public string CreatedByDisplayName { get; set; } = string.Empty;
        public DateTime CreatedOn { get; set; }
    }
}
