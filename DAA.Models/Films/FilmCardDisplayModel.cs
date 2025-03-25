using DAA.Shared.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Films
{
    public  class FilmCardDisplayModel : FilmCardModel, IDisplayable
    {
        public bool IsCurrent { get; set; }
        public bool IsDraft { get; set; }
        public string? ArchiveName { get; set; }
        public string? CountryName { get; set; }
        public string? CountryCode { get; set; }
        public string? FilmingExtentName { get; set; }
        public string? LanguageText { get; set; }

        public DateTime? CreatedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public Guid? UpdatedBy { get; set; }
        public Guid? DeletedBy { get; set; }
        public bool Deleted { get; set; }
        public string? CreatedByUserName { get; set; }
        public string? CreatedByDisplayName { get; set; }
        public string? UpdatedByUserName { get; set; }
        public string? UpdatedByDisplayName { get; set; }
        public string? DeletedByUserName { get; set; }
        public string? DeletedByDisplayName { get; set; }
    }
}
