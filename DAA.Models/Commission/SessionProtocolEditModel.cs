
namespace DAA.Models.Commission
{
    public class SessionProtocolEditModel
    {
        public int? Id { get; set; }
        public bool? IsDraft { get; set; }
        public string? Content { get; set; }
        public string? Status { get; set; }
        public string? RejectReason { get; set; }
        public int[]? StandPointIds { get; set; }
    }
}
