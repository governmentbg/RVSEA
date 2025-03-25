namespace DAA.Models.Commission
{
    public class SessionAgendaItemModel
    {
        public int? Id { get; set; }
        public int SessionId { get; set; }
        public int ReportId { get; set; }
        public int ProcessId { get; set; }
        
        public IEnumerable<SessionAgendaItemStandpointModel>? Standpoints { get; set; }
    }
}
