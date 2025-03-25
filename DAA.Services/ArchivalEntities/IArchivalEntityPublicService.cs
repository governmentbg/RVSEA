using DAA.Extensions.DynamicLinq;
using DAA.Models.ArchiveEntities;
using DAA.Shared;

namespace DAA.Services.ArchivalEntities
{
    public interface IArchivalEntityPublicService
    {
        Task<ArchivalEntityPublicDisplayModel?> GetArchivalEntityBySystemIdentifierAsync(Guid sysId);
        Task<ArchivalEntityPublicDisplayModel?> GetFromExternalSourceAsync(int externalIdentifier,Guid? systemIdentifier = null,Guid? inventorySystemIdentifier = null,Guid? fundSystemIdentifier = null);

       Task<DataSourceResponseModel<ArchivalEntityPublicDisplayModel>> 
           GetByInventoryIdentifierAsync(
           DataSourceRequestModel model,
           Guid? inventorySysId,
           bool inventoryHasExternalSource = false,
           int? inventoryExternalIdentifier = null,
           string? searchInventoryNumberString = null,
           bool includeDeleted = false);
        Task<OperationResult?> CreateArchivalEntityReviewAsync(Guid? archivalEntitySystemIdentifier, int? archivalEntityExternalIdentifier);

        Task<ArchivalEntityPublicImportModel?> GetArchivalEntityDraftBySysIdAsync(Guid sysId);
        Task<OperationResult> UpdateDraftAsync(ArchivalEntityPublicImportModel model, Guid? userId);
    }
}
