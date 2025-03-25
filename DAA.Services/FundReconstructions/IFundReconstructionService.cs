using DAA.Extensions.DynamicLinq;
using DAA.Models.ArchiveEntities;
using DAA.Models.FundReconstructions;
using DAA.Models.Inventories;
using DAA.Shared;

namespace DAA.Services.FundReconstructions
{
    public interface IFundReconstructionServiceBase
    {
        protected internal Task<OperationResult> ApplyDeductFundReconstructionsInternalAsync(IEnumerable<FundReconstructionModel> reconstructions);
    }

    public interface IFundReconstructionService : IFundReconstructionServiceBase
    {
        IQueryable<ArchivalEntityShortDisplayModel> GetSourceArchivalEntities(Guid fundSystemIdentifier);
        IQueryable<ArchivalEntityShortDisplayModel> GetTargetArchivalEntities(Guid fundSystemIdentifier);
        IQueryable<InventoryShortDisplayModel> GetSourceInventories(Guid fundSystemIdentifier);
        IQueryable<InventoryShortDisplayModel> GetTargetInventories(Guid fundSystemIdentifier);
        DataSourceResponseModel<FundReconstructionDisplayModel> GetReconstructionsByProcess(DataSourceRequestModel model, int processId);
        IQueryable<FundReconstructionDisplayModel> GetReconstructionsByProcess(int processId);
        IQueryable<FundReconstructionDisplayModel> GetReconstructionsByAvailabilityStatus(int processId, int availabilityStatus);
        IQueryable<FundReconstructionDisplayModel> GetReconstructionsBySourceParent(int processId, int availabilityStatus, Guid? inventorySysId = null, Guid? archivalEntitySysId = null);
        IQueryable<FundReconstructionDisplayModel> GetReconstructionsByTargetParent(int processId, int availabilityStatus, Guid? inventorySysId = null, Guid? archivalEntitySysId = null);
        Task<FundReconstructionDisplayModel?> GetReconstructionByIdAsync(int id);
        Task<OperationResult> CreateReconstructionAsync(FundReconstructionModel model);
        Task<OperationResult> CreateReconstructionsAsync(IEnumerable<FundReconstructionModel> reconstructions);
        Task<OperationResult> CreateOrUpdateReconstructionsBySourceAsync(IEnumerable<FundReconstructionModel> reconstructions);
        Task<OperationResult> UpdateReconstructionAsync(FundReconstructionModel model);
        Task<OperationResult> UpdateFundReconstructionsAsync(IEnumerable<FundReconstructionModel> reconstructions);
        Task<OperationResult> UpdateMoveFundReconstructionsByTargetAsync(IEnumerable<FundReconstructionModel> reconstructions);
        
        Task<OperationResult> UpdateMergeFundReconstructionAsync(FundReconstructionModel reconstruction);
        Task<OperationResult> DeleteFundReconstructionAsync(int processId, int id);
        Task<OperationResult> DeleteFundReconstructionsAsync(int processId, int[] ids);
    }
}
