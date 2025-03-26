using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class ActiveProcessesReport
    {
        public string Archive { get; set; } = string.Empty;
        public string? DescriptionLevel { get; set; }
        public string? FundNumber { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? DocumentId { get; set; }
        public string? DocumentNumber { get; set; }
        public string? ProcessName { get; set; }
        public string? ProcessStartDate { get; set; }
        public string? Initiator { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}
