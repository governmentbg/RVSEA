using DAA.Extensions.DynamicLinq;
using DAA.Models.Archives;
using DAA.Shared;

namespace DAA.Services
{
    public interface IArchiveService
    {
        DataSourceResponseModel<ArchiveDisplayModel> GetAll(DataSourceRequestModel model, bool includeDeleted = false);
        IQueryable<ArchiveDisplayModel> GetBySearchText(string searchText);
        Task<ArchiveDisplayModel?> GetById(int id);
        Task<OperationResult> GetDiroctorNameByArchiveId(int id);
        Task<IEnumerable<ArchiveDisplayModel>?> GetFromExternalSourceBySearchTextAsync(string searchText);
        Task<OperationResult> CreateAsync(ArchiveModel model);
        Task<OperationResult> UpdateAsync(ArchiveModel model);
        Task<OperationResult> DeleteAsync(int id);
        Task<int> GetArchiveIdByCodeAsync(int code);
        Task<int?> GetExternalIdentifierAsync(int code);
    }
}
