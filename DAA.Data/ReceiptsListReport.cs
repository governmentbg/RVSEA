using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class ReceiptsListReport
    {
        public long RowNumber { get; set; }
        public string? Number { get; set; }
        public string? CreationDate { get; set; }
        public string? ImmediateSourceOfAcquisitionPlusMethodOfAcquisition { get; set; }
        public string? Title { get; set; }
        public double? LinearMeters { get; set; }
        public long? DigitalSize { get; set; }
        public long? ArchiveEntitiesCount { get; set; }
        public string? TextDate { get; set; }
        public string? FundOwnership { get; set; }
        public string? Note { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}