using DAA.Extensions.DynamicLinq;
using DAA.Models.Inventories;
using DAA.Shared;

namespace DAA.Services.Inventories
{
    public interface IInventoryPublicService
    {
        Task<InventoryPublicDisplayModel?> GetInventoryBySystemIdentifierAsync(Guid sysId);
        Task<DataSourceResponseModel<InventoryPublicDisplayModel>> GetByFundIdentifier(DataSourceRequestModel model, Guid? sysId, bool fundHasExternalSource = false, int? fundExternalIdentifier = null);
        Task<InventoryPublicDisplayModel?> GetFromExternalSourceAsync(
           int externalIdentifier,
           Guid? systemIdentifier = null,
           Guid? fundSystemIdentifier = null);
        Task<OperationResult?> CreateInventoryReviewAsync(Guid? inventorySystemIdentifier, int? inventoryExternalIdentifier);

        Task<InventoryPublicImportModel?> GetInventoryDraftBySysIdAsync(Guid sysId);
        Task<OperationResult> UpdateDraftAsync(InventoryPublicImportModel model, Guid? userId);
    }
}
