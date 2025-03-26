using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Films
{
    public class FilmReaderDisplayModel
    {
        public int Id { get; set; }
        public Guid SystemIdentifier { get; set; }
        public string Title { get; set; }
        public int ArchiveId { get; set; }
        public string? ArchiveName { get; set; }
        public int InventoryNumber { get; set; }
        public string? CountryName { get; set; }
        public int? FramesCount { get; set; }
        public int? MicrofilmNegativeRollsCount { get; set; }
        public int? MicrofilmNegativeFramesCount { get; set; }
        public int? MicrofilmPositiveRollsCount { get; set; }
        public int? MicrofilmPositiveFramesCount { get; set; }
        public string? PhotoCopy { get; set; }
        public string? DigitalCopy { get; set; }
        public string? Size { get; set; }
        public string? Other { get; set; }
        public bool Deleted { get; set; }
    }
}
