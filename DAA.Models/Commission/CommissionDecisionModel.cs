namespace DAA.Models.Commission
{
    public class CommissionDecisionModel
    {
        public int? Id { get; set; }
        public int SessionAgendaId { get; set; }
        public string? DecisionText { get; set; }
        public DateTime? DeadlineForApproval { get; set; }
        public bool IsDraft { get; set; }
        
    }
}
