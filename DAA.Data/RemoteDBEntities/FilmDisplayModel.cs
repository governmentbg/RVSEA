using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Data.RemoteDBEntities
{
    [Keyless]
    public class FilmDisplayModel
    {
        public int? Id { get; set; }
        public bool HasExternalSource { get; set; }
        public int? ExternalIdentifier { get; set; }
        public int? ArchiveCode { get; set; }
        public string? ArchiveName { get; set; }        
        public string? InventoryNumber { get; set; }        
        public string? Notes { get; set; }
        public string? Source { get; set; }
        public string? CountryCode { get; set; }
        public string? CountryName { get; set; }
        public int? MicrofilmNegativeFramesCount { get; set; }
        public int? MicrofilmPositiveFramesCount { get; set; }
        public int? PhotoCopy { get; set; }
        public int? DigitalCopy { get; set; }
        public string? Other { get; set; }
        public string? Content { get; set; }
        public int? FramesCount { get; set; }
        public int? AcceptedOnDay { get; set; }
        public int? AcceptedOnMonth { get; set; }
        public int? AcceptedOnYear { get; set; }
        public int? MicrofilmNegativeRollsCount { get; set; }
        public int? MicrofilmPositiveRollsCount { get; set; }

    }
}
