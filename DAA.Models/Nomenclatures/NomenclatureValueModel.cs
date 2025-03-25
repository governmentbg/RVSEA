
namespace DAA.Models.Nomenclatures
{
    public class NomenclatureValueModel : NomenclatureModel
    {
        public int? ParentId { get; set; }
        public int? ExternalIdentifier { get; set; }
    }
}
