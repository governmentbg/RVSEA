

namespace DAA.Models.Documents.DocumentsProcedure
{
    public abstract class CommentBaseModel
    {
        public string? Text { get; set; }
        public int? ProcessId { get; set; }
        public int? ProcessStepId { get; set; }
        public string? UserName { get; set; }
        public bool? IsDraft { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? Date { get; set; }
    }
}
