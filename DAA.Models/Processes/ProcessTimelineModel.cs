
namespace DAA.Models.Processes
{
    public class ProcessTimelineModel
    {
        public int Id { get; set; }
        public int ProcessId { get; set; }
        public int StepTypeId { get; set; }
        public string? StepTypeName { get; set; }
        public bool Completed { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public string? Comment { get; set; }
        public string? CreatedByUserName { get; set; }
        public string? CreatedByDisplayName { get; set; }
        public string? AssignedToUserId { get; set; }
        public string? AssignedToUserName { get; set; }
        public string? AssignedToUserDisplayName { get; set; }
        public string? AssignedToRoleName { get; set; }
        public DateTime? EndDate { get; set; }
    }
}
