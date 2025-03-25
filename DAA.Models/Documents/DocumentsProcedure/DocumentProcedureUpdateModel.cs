using DAA.Models.Comments;
using Microsoft.AspNetCore.Http;

namespace DAA.Models.Documents.DocumentsProcedure
{
    public class DocumentProcedureUpdateModel
    {
        public int Id { get; set; }
        public int DocumentId { get; set; }
        public int ArchiveId { get; set; }
        public int ProcedureStepTypeId { get; set; }
        public string? ProcedureStepName { get; set; }
        public int? ProcedureType { get; set; }
        public int? ArchiveEntityId { get; set; }
        public int? ArchiveEntityExternalIdentifier { get; set; }
        public bool? Completed { get; set; }
        public string? DocumentSystemIdentifier { get; set; }
        public string? AssignToUserId { get; set; }
        public string? AssignToRoleId { get; set; }
        public List<CommentModel>? Comments { get; set; }
        public IFormFile[]? Files { get; set; }
        public IFormFile[]? MasterFiles { get; set; }
        public IFormFile[]? DerivativesFiles { get; set; }
        public bool? SkipMasterValidation { get; set; }
        public bool? SkipDerivativeValidation { get; set; }
        public bool? SkipDemoValidation { get; set; }

    }
}
