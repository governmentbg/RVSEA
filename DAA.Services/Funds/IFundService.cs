using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Models;
using DAA.Models.Funds;
using DAA.Shared;
using Task = System.Threading.Tasks.Task;

namespace DAA.Services.Funds
{
    public interface IFundServiceBase
    {
        protected internal Task<Guid> CreateDraftInternalAsync(FundDraftModel model, bool startProcess = false);
        protected internal Task<Guid> CreateFundInternalAsync(FundModel model, Guid? createdBy = null, DateTime? createdOn = null);
        protected internal Task<Guid> CreateOrUpdateFundFromDraftInternalAsync(Guid sysId, bool overwriteCreatedFromDraft = true, bool overwriteModifiedFromDraft = true);
        protected internal Task<Guid> UpdateDraftInternalAsync(FundDraftModel model);
        protected internal Task<Guid> UpdateFundInternalAsync(FundModel model, Guid? updatedBy = null, DateTime? updatedOn = null);
        protected internal Task DeleteDraftInternalAsync(int id);
        protected internal Task DeleteFundInternalAsync(Guid sysId);
        protected internal Task<FundDraftModel?> GetFundAsDraftModelBySystemIdentifierInternalAsync(Guid sysId);
        //protected internal Task CalculateDocFieldsInternalAsync(Guid? inventorySysId);
    }

    public interface IFundService : IFundServiceBase
    {
        DataSourceResponseModel<FundDisplayModel> GetAll(DataSourceRequestModel model, bool includeDeleted = false);
        Task<FundDisplayModel?> GetFundById(int id);
        Task<FundDisplayModel?> GetFundBySystemIdentifierAsync(Guid sysId);
        Task<FundDisplayModel?> GetCurrentDraftAsync(Guid sysId);
        Task<bool> HasCurrentDraftAsync(Guid sysId);
        Task<bool> IsCurrentDraftAsync(FundDraftModel model);
        Task<bool> IsReadOnlyDraftAsync(FundDraftModel model);
        Task<OperationResult> CreateDraftAsync(FundDraftModel model, bool isCreate = false);
        //Task<OperationResult> CreateDraftFromIdentifierAsync(Guid systemIdentifier);
        Task<OperationResult> CreateFundAsync(FundModel model);
        Task<OperationResult> CreateOrUpdateFundFromDraftAsync(Guid sysId);
        Task<OperationResult> UpdateDraftAsync(FundDraftModel model);
        Task<OperationResult> UpdateFundAsync(FundModel model);
        Task<OperationResult> DeleteDraftAsync(int id);
        Task<OperationResult> DeleteFundAsync(Guid sysId);
        Task<FundDisplayModel?> GetFromExternalSourceAsync(int externalIdentifier, Guid? systemIdentifier = null);
        Task<int?> GetIdByExternalIdentifierAsync(int externalIdentifier);
        Task<Guid?> GetSystemIdentifierByExternalIdentifierAsync(int externalIdentifier);
        Task<int?> GetArchiveIdAsync(Guid sysId);
        Task<int?> GetArchiveIdByProcessIdAsync(int processId);
        Task<int?> GetDescriptionLevelAsync(Guid sysId);
        Task<List<VInventory>> GetFundUnprocessedRawInventoriesAsync(Guid sysId);
        Task<DataSourceResponseModel<PublicUserReviewDisplayModel>> GetFundPublicUsersReviewsAsync(Guid? systemIdentifier);
        Task<OperationResult?> CreateFundReviewAsync(Guid? fundSystemIdentifier, int? fundExternalIdentifier);
    }
}
