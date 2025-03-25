using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class CardForm1Data
    {
        public int? Id { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? LGid { get; set; }
        public string? YearCreatedAndInventoryNumber { get; set; }
        public string? EndDates { get; set; }
        public string? InventorizedCount { get; set; }
        public string? UninventorizedCount { get; set; }
        public string? DeductedCount { get; set; }
        public string? AvailableArchivalEntitiesCountAndSize { get; set; }
        public int? MicrofilmedArchivalOfEntityCount { get; set; }
        public int? NegativeFramesCount { get; set; }
        public int? PositiveFramesCount { get; set; }
        public int? PhonoDocumentsCount { get; set; }
        public int? PhotoDocumentsCount { get; set; }
        public int? VideoDocumentsCount { get; set; }
        public int? DigitalDocumentCount { get; set; }
        public int? IntNumber { get; set; }
        public string? Number { get; set; }
        public int? DocumentsCount { get; set; }
    }
}