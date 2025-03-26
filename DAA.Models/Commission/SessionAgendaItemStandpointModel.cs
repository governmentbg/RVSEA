using DAA.Models.Comments;

namespace DAA.Models.Commission
{
    public class SessionAgendaItemStandpointModel
    {
        public int? Id { get; set; }
        public int? SessionAgendaItemId { get; set; }
        public int ReportId { get; set; }
        public string? Content { get; set; }
        public bool IsDraft { get; set; }
        public int? StatusCode { get; set; }
    }
}
