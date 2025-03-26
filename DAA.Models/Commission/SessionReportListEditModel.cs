namespace DAA.Models.Commission
{
    public class SessionReportEditListModel
    {
        public int? SessionId { get; set; }
        public int[]? ProcessIdsForAppending { get; set; }
        public int[]? ProcessIdsForRemove { get; set; }
    }
}
