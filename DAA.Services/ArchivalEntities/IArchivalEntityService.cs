using DAA.Extensions.DynamicLinq;
using DAA.Models;
using DAA.Models.ArchiveEntities;
using DAA.Shared;

namespace DAA.Services.ArchivalEntities
{
    public interface IArchivalEntityServiceBase
    {
        protected internal Task<Guid> CreateDraftInternalAsync(ArchivalEntityDraftModel model);
        protected internal Task<Guid> CreateArchivalEntityInternalAsync(ArchivalEntityModel model, Guid? createdBy = null, DateTime? createdOn = null);
        protected internal Task<Guid> CreateOrUpdateArchivalEntityFromDraftInternalAsync(Guid sysId, bool overwriteCreatedFromDraft = true, bool overwriteModifiedFromDraft = true);
        protected internal Task<Guid> UpdateDraftInternalAsync(ArchivalEntityDraftModel model);
        protected internal Task<Guid> UpdateArchivalEntityInternalAsync(ArchivalEntityModel model, Guid? updatedBy = null, DateTime? updatedOn = null);
        protected internal Task DeleteDraftInternalAsync(int id);
        protected internal Task DeleteArchivalEntityInternalAsync(Guid sysId);
    }

    public interface IArchivalEntityService : IArchivalEntityServiceBase
    {
        DataSourceResponseModel<ArchivalEntityDisplayModel> GetAll(DataSourceRequestModel model, bool includeDeleted = false);
        Task<ArchivalEntityDisplayModel?> GetArchivalEntityBySystemIdentifierAsync(Guid sysId);
        Task<DataSourceResponseModel<ArchivalEntityDisplayModel>> GetByInventoryIdentifierAsync(
            DataSourceRequestModel model, 
            Guid? inventorySysId, 
            bool inventoryHasExternalSource = false, 
            int? inventoryExternalIdentifier = null,
            string? searchInventoryNumberString = null,
            bool includeDeleted = false);
        DataSourceResponseModel<ArchivalEntityDisplayModel> GetByAvailabilityStatus(
            DataSourceRequestModel model,
            int availabilityStatus,
            Guid fundSystemIdentifier,
            string? searchInventoryNumberString,
            bool includeDeleted = false);
        Task<bool> AnyUnnumberedDraftsByFundIdentifier(Guid fundSysId);
        Task<bool> AnyUnnumberedDraftsByInventoryIdentifier(Guid inventorySysId);
        Task<ArchivalEntityDisplayModel?> GetCurrentDraftAsync(Guid sysId);
        Task<bool> HasCurrentDraftAsync(Guid sysId);
        Task<bool> IsCurrentDraftAsync(ArchivalEntityDraftModel model);
        Task<bool> IsReadOnlyDraftAsync(ArchivalEntityDraftModel model);
        Task<OperationResult> CreateDraftAsync(ArchivalEntityDraftModel model);
        Task<OperationResult> CreateArchivalEntityAsync(ArchivalEntityModel model);
        Task<OperationResult> CreateOrUpdateArchivalEntityFromDraftAsync(Guid sysId);
        Task<OperationResult> UpdateDraftAsync(ArchivalEntityDraftModel model);
        Task<OperationResult> UpdateArchivalEntityAsync(ArchivalEntityModel model);
        Task<OperationResult> DeleteDraftAsync(int id);
        Task<OperationResult> DeleteArchivalEntityAsync(Guid sysId);
        Task<int?> GetIdByExternalIdentifierAsync(int externalIdentifier);
        Task<Guid?> GetSystemIdentifierByExternalIdentifierAsync(int externalIdentifier);
        Task<ArchivalEntityDisplayModel?> GetFromExternalSourceAsync(
            int externalIdentifier,
            Guid? systemIdentifier = null,
            Guid? inventorySystemIdentifier = null,
            Guid? fundSystemIdentifier = null);
        Task<int?> GetArchiveIdAsync(Guid sysId);
        Task<int?> GetArchiveIdByProcessIdAsync(int processId);
        Task<int?> GetDescriptionLevelAsync(Guid sysId);
        Task<IEnumerable<SearchedArchiveEntityShortDisplayModel>?> GetShortBySearchText(SearchedArchiveEntityRequestModel model);
        Task<DataSourceResponseModel<PublicUserReviewDisplayModel>> GetArchivalEntityPublicUsersReviewsAsync(Guid? systemIdentifier);
        Task<OperationResult?> CreateArchivalEntityReviewAsync(Guid? archivalEntitySystemIdentifier, int? archivalEntityExternalIdentifier);
    }
}

