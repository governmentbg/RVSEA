using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Films
{
    public class FilmShortModel 
    {
        public int Id { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool? IsDraft { get; set; }
        public int ArchiveId { get; set; }
        public string? ArchiveName { get; set; }
        public string? InventoryNumber { get; set; }
        public int? CountryId { get; set; }
        public string? CountryName { get; set; }
        public string? CountryCode { get; set; }
        public DateTime? CreatedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public string? CreatedByDisplayName { get; set; }
        public string? UpdatedByDisplayName { get; set; }


    }
}
