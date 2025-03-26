namespace DAA.Models.ArchiveEntities
{
    public class SearchedArchiveEntityRequestModel
    {
        public string SearchText { get; set; } = string.Empty;
        public bool HasInventoryExternalSource { get; set; }
        public int? InventoryInternalIdentifier { get; set; }
        public int? InventoryExternalIdentifier { get; set; }
    }
}
