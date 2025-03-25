using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Films
{
    public class FilmCardShortModel
    {
        public int Id { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool? IsDraft { get; set; }
        public Guid? FilmSystemIdentifier { get; set; }
        public int? FilmExternalIdentifier { get; set; }
        public int? CountryId { get; set; }
        public string? CountryCode { get; set; }
        public string? CountryName { get; set; }
        public string? InventoryNumber { get; set; }
        public string? Title { get; set; }
        public bool Deleted { get; set; }
    }
}
