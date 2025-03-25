using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class FundMemoryPublicReport
    {
        public string? Archive { get; set; }
        public string? Number { get; set; }
        public string? CreationDate { get; set; }
        public string? ImmediateSourceOfAcquisitionPlusMethodOfAcquisition { get; set; }
        public string? Title { get; set; }
        public string? CreatingType { get; set; }
        public double? LinearMeters { get; set; }
        public long? DigitalSize { get; set; }
        public long? Duration { get; set; }
        public string? Note { get; set; }
        public int? IntNumber { get; set; }
        public int? SortOrder { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public string? FileTypes { get; set; }
    }
}