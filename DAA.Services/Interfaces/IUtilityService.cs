using DAA.Data;
using DAA.Models.ArchiveEntities;
using DAA.Models.DigitalObjects;
using DAA.Models.Documents;
using DAA.Shared;

namespace DAA.Services.Interfaces
{
    public interface IUtilityService
    {
        OperationResult GetUsedFileFormats(List<string> formats);
        

        Task<Guid> CreateDODraftFromPackageDocumentInternalAsync(PackageDocument doc, DigitalObjectDraftModel model);
        System.Threading.Tasks.Task DeleteDODraftInternalAsync(int id);

        Task<Guid> CreateDocDraftInternalAsync(DocumentDraftModel model);
        System.Threading.Tasks.Task DeleteDocDraftInternalAsync(int id);

        Task<Guid> CreateAEDraftInternalAsync(ArchivalEntityDraftModel model);
        System.Threading.Tasks.Task DeleteAEDraftInternalAsync(int id);

        System.Threading.Tasks.Task DeletePackageDocument(PackageDocument doc);

        Task<OperationResult> DeductRedirectedData(Guid? fundSystemIdentifier, Guid? inventorySystemIdentifier);
        Task<OperationResult> ModifyDataAccessAsync(Guid? fundSystemIdentifier, Guid? inventorySystemIdentifier, bool suspendAccess);
        Task<InventoryDraft> GetProcessInventoryDraftAsync(Guid? fundSystemIdentifier, Guid? inventorySystemIdentifier);
        Task<Shared.FundType?> GetFundTypeAsync(Guid fundSystemIdentifier);
    }
}
