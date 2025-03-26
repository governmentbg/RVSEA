using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Nomenclatures;
using DAA.Shared;

namespace DAA.Services.Nomenclatures
{
    public interface INomenclatureService
    {
        Task<OperationResult> CreateNomenclatureAsync(NomenclatureModel model);
        Task<OperationResult> CreateNomenclatureValueAsync(NomenclatureValueModel model);
        DataSourceResponseModel<NomenclatureDisplayModel> GetNomenclatures(DataSourceRequestModel model, bool includeInactive = true);
        DataSourceResponseModel<NomenclatureValueDisplayModel> GetNomenclatureValues(DataSourceRequestModel model, int parentId, bool includeInactive = true);
        IQueryable<Nomenclature> GetNomenclatureValues(string parentCode, bool includeInactive = true);
        Task<NomenclatureDisplayModel?> GetNomenclatureByIdAsync(int id);
        Task<NomenclatureValueDisplayModel?> GetNomenclatureValueByIdAsync(int id, int parentId);
        Task<OperationResult> UpdateNomenclatureAsync(NomenclatureModel model);
        Task<OperationResult> UpdateNomenclatureValueAsync(NomenclatureValueModel model);
        Task<OperationResult> DeleteNomenclatureAsync(int id);
        Task<OperationResult> DeleteNomenclatureValueAsync(int id);



        IEnumerable<string>? GetEntityNomenclatureCodes(int entityId, string objectType, bool isDraft, string nomenclatureCode);
        string? GetEntityNomenclatureText(int entityId, string objectType, bool isDraft, string nomenclatureCode);
        IEnumerable<NomenclatureValue>? GetEntityNomenclatureValues(int entityId, string objectType, bool isDraft, string? nomenclatureCode);
        IEnumerable<NomenclatureValue>? GetEntityNomenclatureValues(List<int> entityIds, string objectType, bool isDraft, string? nomenclatureCode);
        IEnumerable<NomenclatureValue>? GetEntityNomenclatureValuesToAdd(
            IEnumerable<string>? selectedValues, IEnumerable<NomenclatureValue>? existingValues, string nomenclatureCode, 
            int entityId, string objectType, bool isDraft,
            bool overwriteCreated = false, Guid? createdBy = null, DateTime? createdOn = null);
        IEnumerable<NomenclatureValue>? GetEntityNomenclatureValuesToDelete(IEnumerable<string>? selectedValues, IEnumerable<NomenclatureValue>? existingValues, string nomenclatureCode);

    }
}
