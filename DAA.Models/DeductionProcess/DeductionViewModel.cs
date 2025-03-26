using DAA.Models.Comments;
using DAA.Models.Documents.DocumentsProcedure;
using DAA.Models.Commission;

namespace DAA.Models.DeductionProcess
{
    public class DeductionViewModel
    {
        public int? Id { get; set; }
        public int? ProcedureStepId { get; set; }
        public int? ProcedureType { get; set; }
        public string? FundSystemIdentifier { get; set; }
        public string? AssignToUserId { get; set; }
        public string? AssignToRoleId { get; set; }
        public string? EntityType { get; set; }
        public string? CreatedBy { get; set; }
        public int? ArchiveId { get; set; }
        public string? InventorySystemIdentifier { get; set; }
        public string? ArchivalEntitySystemIdentifier { get; set; }
        public string? DocumentSystemIdentifier { get; set; }
        public int? FundExternalIdentifier { get; set; }
        public int? InventoryExternalIdentifier { get; set; }
        public int? ArchivalEntityExternalIdentifier { get; set; }
        public int? DocumentEntityExternalIdentifier { get; set; }
        public string? ProcedureStepName { get; set; }
        public int? SessionAgendaId  {get;set; }
        public int? SessionId { get; set; }
        public DateTime? EndDate { get; set; }
        public int? DecisionModelId { get; set; }
        public string? SecretarOpinion { get; set; }
        public List<CommentDisplayModel>? Comments { get; set; }
        public CommissionReportModel? EpkReportModel { get; set; }

    }
}
