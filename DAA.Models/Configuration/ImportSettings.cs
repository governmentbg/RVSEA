
namespace DAA.Models.Configuration
{
    public class ImportSettings
    {
        public const string Name = "ImportSettings";
        public string? InventorySheetName { get; set; }
        public string? ArchivalEntitiesSheetName { get; set; }
        public string? DocumentsSheetName { get; set; }
        public string? PackageBSheetName { get; set; }
    }
}
