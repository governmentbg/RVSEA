using DAA.Shared.Data;

namespace DAA.Models.Films
{
    public class FilmDisplayModel : FilmModel, IDisplayable
    {
        public bool IsCurrent { get; set; }
        public bool ReadOnly { get; set; }

        public string? ArchiveName { get; set; }
        public string? CountryName { get; set; }
        public string? CountryCode { get; set; }
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

        public string? CurrentProcessTypeName { get; set; }
        public string? CurrentStepTypeName { get; set; }
        public string? Comment { get; set; }
        public bool HasCompletedCardsProcess { get; set; }
    }
}
