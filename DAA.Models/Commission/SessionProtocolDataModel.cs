namespace DAA.Models.Commission
{
    public class SessionProtocolDataModel
    {
        public string? ArchiveName { get; set; }
        public string? DirectorName { get; set; }
        public DateTime? CurrentDate { get; set; }
        public int? ProtocolNumber { get; set; }
        public string? SessionTypeName { get; set; }
        public string? AssignedToChairmanName { get; set; }
        public string? AssignedToSecretarName { get; set; }
        public List<string>? Members { get; set; }
        public List<StandPoint>? StandPointsData { get; set; }
        public List<StandPointDecision>? StandPointsDecision { get; set; }
    }
    public class StandPoint
    {
        public int? Index { get; set; }
        public string? FundNumber { get; set; }
        public string? InventoryNumber { get; set; }
        public string? FundTitle { get; set; }
        public string? DisplayName { get; set; }
        public string? JobTitle { get; set; }
        public string? Department { get; set; }
        public List<ReportStandpoint>? ReportStandpoint { get; set; }
    }
    public class StandPointDecision
    {
        public string? Index { get; set; }
        public string? Title { get; set; }
        public string? ReporterInfo { get; set; }
        public string? Decision { get; set; }
        public string? DeadLine { get; set; }
      
    }
    public class ReportStandpoint
    {
        public string? Index { get; set; }
        public string? StandPointTextCreatorDisplayName { get; set; }
        public string? StandpointText { get; set; }
        public string? ReportCreatorDisplayName { get; set; }
        public string? CommentText { get; set; }
    }
}

