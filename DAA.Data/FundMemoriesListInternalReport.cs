using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class FundMemoriesListInternalReport
    {
        public string Archive { get; set; } = string.Empty;
        public string? Number { get; set; } // FundNumber
        public string? CreationDate { get; set; }
        public string? Title { get; set; }
        public string? ImmediateSourceOfAcquisition { get; set; }
        public string? AccessConditions { get; set; }
        public string? FundType { get; set; }
        public string? Note { get; set; }
        public string? FundStatus { get; set; }
        public string? CreationMethod { get; set; }
        public double? LinearMeters { get; set; }
        public long? Size { get; set; }
        public int? Duration { get; set; }
        public string? FileFormats { get; set; }
        public bool HasExternalSource { get; set; }
        public string? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
    }
}
