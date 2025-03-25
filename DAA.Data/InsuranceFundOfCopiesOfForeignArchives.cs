using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class InsuranceFundOfCopiesOfForeignArchives
    {
        public string? KmfNumber { get; set; }
        public string? Number { get; set; }
        public int? CopyNegativeRolls { get; set; }
        public int? CopyNegativeFrames { get; set; }
        public int? CopyPositiveRolls { get; set; }
        public int? CopyPositiveFrames { get; set; }
        public string? CopyXerox { get; set; }
        public string? CopyDigital { get; set; }
        public int? ElectronicDocumentsCount { get; set; }
        public long? ElectronicDocumentsSize { get; set; }
        public string? Other { get; set; }
        public int? DoublesNegativeCount { get; set; }
        public string? DoublesNegativeLocation { get; set; } 
        public int? DoublesPositiveCount { get; set; }
        public string? DoublesPositiveLocation { get; set; }
        public string? PhotolabDeliveryDate { get; set; }
        public string? Note { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}