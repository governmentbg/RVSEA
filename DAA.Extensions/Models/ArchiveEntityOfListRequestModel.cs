using DAA.Extensions.DynamicLinq;

namespace DAA.Extensions.Models
{
    public class ArchiveEntityOfListRequestModel
    {
        public bool HasInventoryExternalSource { get; set; }
        public int? InventoryExternalIdentifier { get; set; }
        public int? InventoryInternalIdentifier { get; set; }
        public int? SearchNumber { get; set; }
        public DataSourceRequestModel? DataSourceRequestModel { get; set; }
    }
}
