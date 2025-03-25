using DAA.Extensions.DynamicLinq;
using DAA.Models;
using DAA.Models.Inventories;
using DAA.Shared;

namespace DAA.Services.Inventories
{
    public interface IInventoryServiceBase
    {
        protected internal Task<Guid> CreateDraftInternalAsync(InventoryDraftModel model, bool checkRelatedProcess = true);
        protected internal Task<Guid> CreateInventoryInternalAsync(InventoryModel model, Guid? createdBy = null, DateTime? createdOn = null);
        protected internal Task<Guid> CreateOrUpdateInventoryFromDraftInternalAsync(Guid sysId, bool overwriteCreatedFromDraft = true, bool overwriteModifiedFromDraft = true);
        protected internal Task<Guid> UpdateDraftInternalAsync(InventoryDraftModel model);
        protected internal Task<Guid> UpdateInventoryInternalAsync(InventoryModel model, Guid? updatedBy = null, DateTime? updatedOn = null);
        protected internal Task DeleteDraftInternalAsync(int id);
        protected internal Task DeleteInventoryInternalAsync(Guid sysId);
        protected internal Task SetRelatedProcessStepInternalAsync(Guid fundIdentifier);
    }
    public interface IInventoryService : IInventoryServiceBase
    {
        DataSourceResponseModel<InventoryDisplayModel> GetAll(DataSourceRequestModel model, bool includeDeleted = false);
        DataSourceResponseModel<InventoryDisplayModel> GetAll(DataSourceRequestModel model, bool includeDrafts, bool includeDeleted = false);
        DataSourceResponseModel<InventoryDisplayModel> GetByAvailabilityStatus(
            DataSourceRequestModel model,
            int availabilityStatus,
            Guid fundSystemIdentifier,
            bool includeDeleted = false);
        Task<DataSourceResponseModel<InventoryDisplayModel>> GetByFundIdentifier(
            DataSourceRequestModel model, 
            Guid? sysId, 
            bool fundHasExternalSource = false, 
            int? fundExternalIdentifier = null, 
            bool includeDeleted = false);
        Task<bool> AnyUnnumberedDraftsByFundIdentifier(Guid fundSysId);
        Task<InventoryDisplayModel?> GetInventoryByIdAsync(int id);
        Task<InventoryDisplayModel?> GetInventoryBySystemIdentifierAsync(Guid sysId);
        Task<InventoryDisplayModel?> GetInventoryBySystemIdentifierAsync(Guid sysId, bool includeDrafts);
        Task<InventoryDisplayModel?> GetCurrentDraftAsync(Guid sysId);
        Task<bool> HasCurrentDraftAsync(Guid sysId);
        Task<bool> IsCurrentDraftAsync(InventoryDraftModel model);
        Task<bool> IsReadOnlyDraftAsync(InventoryDraftModel model);
        Task<OperationResult> CreateDraftAsync(InventoryDraftCreateModel model);
        Task<OperationResult> CreateInventoryAsync(InventoryModel model);
        Task<OperationResult> CreateOrUpdateInventoryFromDraftAsync(Guid sysId);
        Task<OperationResult> UpdateDraftAsync(InventoryDraftModel model);
        Task<OperationResult> UpdateInventoryAsync(InventoryModel model);
        Task<OperationResult> DeleteDraftAsync(int id);
        Task<OperationResult> DeleteInventoryAsync(Guid sysId);
        Task<InventoryDisplayModel?> GetFromExternalSourceAsync(
            int externalIdentifier,
            Guid? systemIdentifier = null,
            Guid? fundSystemIdentifier = null);
        Task<IEnumerable<SearchedInventoryShortDisplayModel>> GetShortByFundId(int fundId);
        //Task<IEnumerable<SearchedInventoryShortDisplayModel>?> GetShortBySearchText(SearchedInventoryRequestModel model);
        Task<int?> GetIdByExternalIdentifier(int externalIdentifier);
        Task<Guid?> GetSystemIdentifierByExternalIdentifierAsync(int externalIdentifier);
        Task<int?> GetArchiveIdAsync(Guid sysId);
        Task<int?> GetArchiveIdByProcessIdAsync(int processId);
        Task<int?> GetDescriptionLevelAsync(Guid sysId);
        Task<DataSourceResponseModel<PublicUserReviewDisplayModel>> GetInventoryPublicUsersReviewsAsync(Guid? systemIdentifier);
        Task<OperationResult?> CreateInventoryReviewAsync(Guid? inventorySystemIdentifier, int? inventoryExternalIdentifier);
    }
}
