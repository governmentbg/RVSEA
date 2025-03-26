namespace DAA.Models.Commission
{
    public class CommissionReportModel
    {
        public int? Id { get; set; }
        public DateTime? CreatedOn { get; set; }
        public int? Number { get; set; }
        public Guid? CreatedBy { get; set; }
        public string? CreatedByDisplayName { get; set; }
        //public string? CreatedByJobTitle { get; set; }
        public string? Title { get; set; }
        public string? Content { get; set; }
        //public string? EntityLink { get; set; }
        //public string? LinkTitle { get; set; }
        public int? ProcessId { get; set; }
        public string? ProcessTypeTitle { get; set; }
        public bool? IsDraft { get; set; }
    }

    public class CommissionReportSubmitModel : CommissionReportModel
    {
        public string? AssignToUserId { get; set; }
        public string? AssignToRoleId { get; set; }
    }
}
