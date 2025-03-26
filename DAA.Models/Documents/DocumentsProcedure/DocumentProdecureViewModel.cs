using DAA.Models.Comments;
using Microsoft.AspNetCore.Http;

namespace DAA.Models.Documents.DocumentsProcedure
{
    public class DocumentProdecureViewModel
    {
        public int Id { get; set; }
        public int DocumentId { get; set; }
        public int ProcedureStepTypeId { get; set; }
        public string? ProcedureStepName { get; set; }
        public int ProcedureStepId { get; set; }
        public int? ArchiveEntityId { get; set; }
        public int? ArchiveId { get; set; }
        public string? DocumentSystemIdentifier { get; set; }
        public int? ProcedureType { get; set; }
        public string? AssignedToUserId { get; set; }
        public string? AssignedToRoleId { get; set; }
        public bool? ReadyForImport { get; set; }
        public int? ArchiveEntityExternalIdentifier { get; set; }
        public bool? Completed { get; set; }
        public List<CommentDisplayModel>? Comments {get; set;}
        public IFormFile[] Files { get; set; }
        public IFormFile[]? DerivativesFiles { get; set; }
    }
}
