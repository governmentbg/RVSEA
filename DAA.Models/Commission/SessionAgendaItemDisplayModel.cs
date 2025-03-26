using DAA.Shared.Data;

namespace DAA.Models.Commission
{
    public class SessionAgendaItemDisplayModel : SessionAgendaItemModel, IDisplayable
    {
        public DateTime? SessionDate { get; set; }
        public int? ReportNumber { get; set; }
        public Guid? ReportCreatedBy { get; set; }
        public string? ReportCreatedByUserName { get; set; }
        public string? ReportCreatedByDisplayName { get; set; }
        public string? ProcessTypeTitle { get; set; }
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
