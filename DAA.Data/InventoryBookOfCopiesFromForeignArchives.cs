using Microsoft.EntityFrameworkCore;


namespace DAA.Data
{
    [Keyless]
    public class InventoryBookOfCopiesFromForeignArchives
    {
        //KMFNumber
        //InventoryNumber
        //ReceivedOn
        //CountryOfOrigin
        //FramesCount
        //MicrofilmNegativeRollsCount
        //MicrofilmNegativeFramesCount
        //MicrofilmPositiveRollsCount
        //MicrofilmPositiveFramesCount
        //XroxCopy
        //DigitalCopy
        //ElDocumentsCount
        //ElDocumentsMB
        //Other
        //HasInventory
        //InventoryShortDescroption
        //CreationAuthor

        public string? KmfNumber { get; set; }
        public string? InventoryNumber { get; set; }
        public string? ReceivedOn { get; set; }
        public string? CountryOfOrigin { get; set; }
        public int? FramesCount { get; set; }
        public int? MicrofilmNegativeRollsCount { get; set; }
        public int? MicrofilmNegativeFramesCount { get; set; }
        public int? MicrofilmPositiveRollsCount { get; set; }
        public int? MicrofilmPositiveFramesCount { get; set; }
        public string? XeroxCopy { get; set; }
        public string? DigitalCopy { get; set; }
        public int? ElectronicDocumentsCount { get; set; }
        public long? ElectronicDocumentsSize { get; set; }
        public string? Other { get; set; }
        public bool? HasInventory { get; set; }
        public string? InventoryShortDescription { get; set; }
        public string? CreationAuthor { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}
