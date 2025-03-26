
using DAA.Models.DeductionProcess;
using DAA.Models.Documents.DocumentsProcedure;
using DAA.Shared;

namespace DAA.Services.DeductionProcess
{
    public interface IDeductionProcessService
    {
        Task<OperationResult> Start(DeductionCreateModel model);
        Task<OperationResult> UpdateStep(DeductionViewModel model);
        Task<OperationResult> SaveChanges(DeductionViewModel model);
        Task<OperationResult> ТerminateProcess(DeductionViewModel model, bool undoChanges);
        Task<OperationResult> StepBack(DeductionViewModel model);
        Task<OperationResult> Get(Guid entitySystemIdentifier, string entityType);
    }
}
