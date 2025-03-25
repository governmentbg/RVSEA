using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class FilmCard
    {
        public int Id { get; set; }
        public Guid SystemIdentifier { get; set; }
        public int? FilmId { get; set; }
        public Guid FilmSystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public DateTime? ExternalSourceUpdatedOn { get; set; }
        public int ArchiveId { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
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
        public string InventoryNumber { get; set; } = null!;
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

        public virtual Archive Archive { get; set; } = null!;
        public virtual Nomenclature? Country { get; set; }
        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual Film FilmSystemIdentifierNavigation { get; set; } = null!;
        public virtual Nomenclature? FilmingExtent { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
    }
}
