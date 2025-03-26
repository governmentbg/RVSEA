using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class RegisterOfDigitalObjectsPublicReport
    {
        public string? SystemId { get; set; } // Document id
        public bool? HasExternalSource { get; set; }
        public string? LevelOfDescription { get; set; }
        //public string DocumentLink { get; set; } = string.Empty;
        public string ArchiveName { get; set; } = string.Empty;
        public int ArchiveCode { get; set; }
        public string? FundNumber { get; set; }
        public string? InventoryNumber { get; set; }
        public string? ArchiveEntityNumber { get; set; }
        public string? ListNumbers { get; set; }
        public string? DocumentTitle { get; set; }
        public string? ChronologicalScope { get; set; }
        //public string? DocStatus { get; set; } // отпада по искане на ДАА
        public string? DigitalObjectCreationDate { get; set; }
        public long? ImageCount { get; set; }
        public long? BytesCount { get; set; }
        public string? Duration { get; set; }
        //public string? DigitalObjectStatus { get; set; } // отпада по искане на ДАА
        //public string? ModifiedOn { get; set; } // отпада по искане на ДАА
    }
}
