using DAA.Models.Comments;

namespace DAA.Models.Documents.DocumentsProcedure
{
    public class DocumentProcedureCreateModel
    {
        public string DocumentSys { get; set; }
        public int ProcedureStepTypeId { get; set; }
        public int? ProcedureType { get; set; }
        public int? ArchiveId { get; set; }
        public string? AssignToUserId { get; set; }
        public string? AssignToRoleId { get; set; }
        public bool? ReadyForImport { get; set; }
        public bool? Completed { get; set; }
        public int? ArchiveEntityExternalIdentifier { get; set; }
        public List<CommentModel>? Comments { get; set; }
    }
}