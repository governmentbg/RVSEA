using DAA.Extensions.DynamicLinq;
using DAA.Models.Applications;
using DAA.Models.Commission;
using DAA.Models.DocsCollectionProcedure;
using DAA.Models.Processes;
using DAA.Shared;

namespace DAA.Services.DocsCollectingProc
{
    public interface IDocsCollectingProcedureService
    {
        DataSourceResponseModel<DocsCollectingGridModel> List(DataSourceRequestModel model);
        Task<OperationResult> CommitComitteeReport(CommissionReportSubmitModel model);
        Task<OperationResult> SendForStandpoints(CommissionReportSubmitModel model);
        Task<OperationResult> ApplyCommissionDecision(ProcessDecisionModel model);
        Task<OperationResult> SendCommissionDecisionApprovalResultAsync(ProcessDecisionModel model);
        Task<OperationResult> SendModificationsAffirmationResultAsync(ProcessDecisionModel model);
        Task<OperationResult> RedirectToArchiveAsync(ProcessDecisionModel model);
        Task<OperationResult> CompleteProcess(int processId);
        Task<bool> IsExternalCollectingProcedure(int processId);
        Task<int?> GetApplicationStatusAsync(int processId);
        Task<OperationResult> SendForRegistration(ProcessStepModel model);
        Task<OperationResult> RejectReport(RejectModel model);
        Task ReturnCommissionChanges(ProcessStepModel model);
        Task<OperationResult> SendFundCreatorModificationRequestAsync(int processId, string comment);
        Task<OperationResult> SendFundCreatorSignatureRequest(int processId, int packageId, IEnumerable<int> packageDocumentIds);
        Task<OperationResult> MoveToNextStepAsync(ProcessStepModel model);
    }
}
