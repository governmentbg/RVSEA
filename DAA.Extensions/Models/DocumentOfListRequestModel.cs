
using DAA.Extensions.DynamicLinq;

namespace DAA.Extensions.Models
{
    public class DocumentOfListRequestModel
    {
        public bool HasArchiveEntityExternalSource { get; set; }
        public int? ArchiveEntityExternalIdentifier { get; set; }
        public int? ArchiveEntityInternalIdentifier { get; set; }
        public int? SearchNumber { get; set; }
        public int? PageFrom { get; set; }
        public int? PageTo { get; set; }
        public DataSourceRequestModel? DataSourceRequestModel { get; set; }
    }
}
