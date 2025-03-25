namespace DAA.Models.Commission
{
    public class CommissionSessionModel
    {
        public int? Id { get; set; } = null;       
        public DateTime SessionDate { get; set; }
        public string? SessionTypeCode { get; set; }
        public int? ArchiveId { get; set; }
        public int? MinutesOfMeetingId { get; set; }
        public Guid? SecretaryId { get; set; }
        public Guid? ChairmanId { get; set; }

    }
}
