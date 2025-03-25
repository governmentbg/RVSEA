using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Packages
{
    public class PackageBImportModel
    {
        [Required]
        public Guid InventoryIdentifier { get; set; }
        [Required]
        public IEnumerable<PackageDocumentBaseModel> PackageB { get; set; }
    }

    public class PackageBDisplayModel
    {
        public Guid InventoryIdentifier { get; set; }
        public IEnumerable<PackageDocumentDisplayModel> PackageB { get; set; }
    }
}
