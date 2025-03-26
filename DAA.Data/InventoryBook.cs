using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class InventoryBook
    {
        public string? Number { get; set; }
        public string? ReceivedOn { get; set; }
        public string? CountryOfOrigin { get; set; }
        public string? Negatives { get; set; }
        public string? Positives { get; set; }
        public string? CopyXerox { get; set; }
        public string? CopyDigital { get; set; }
        //public xxx DigitalImages { get; set; }
        public bool? HasInventory { get; set; } // nullable е за улеснение на sql-a; може да бъде true или null
        public string? ShortDescription { get; set; }
        public string? CreationAuthor { get; set; }
        public string? Note { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}