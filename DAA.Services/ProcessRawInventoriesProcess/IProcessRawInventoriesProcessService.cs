using DAA.Models.Commission;
using DAA.Models.Processes;
using DAA.Shared;

namespace DAA.Services.ProcessRawInventoriesProcess
{
    public interface IProcessRawInventoriesProcessService
    {
        Task<OperationResult> StartProcessAsync(ProcessModel model);
        Task<OperationResult> UndoProcessChangesAsync(int processId);
        Task<List<Guid>> GetSelectedRawInventoriesForFundAsync(Guid sysId);
        Task<OperationResult> SaveSelectedRawInventoriesAsync(Guid fundSystemIdentifier, int processId, string[] selectedRawInventories);
        Task<OperationResult> CreateNormalInventory(int processId);
        Task<OperationResult> CreateReportAsync(ProcessStepModel model);
        Task<OperationResult> SendReportAsync(CommissionReportSubmitModel model);
        Task<OperationResult> StartApplyingChangesAsync(ProcessStepModel model);
        Task<OperationResult> AddReportToSessionAgendaAsync(ProcessStepModel model);
        Task<OperationResult> SendToAddStandpointAsync(ProcessStepModel model);
        Task<OperationResult> SendSessionAgendaStandpointAsync(ProcessStepModel model);
        Task<OperationResult> SendToAddCommentAsync(ProcessStepModel model);
        Task<OperationResult> AddCommentToSessionAgendaStandpointAsync(ProcessStepModel model);
        Task<OperationResult> SendCommentAsync(ProcessStepModel model);
        Task<OperationResult> SetSessionAgendaItemAsync(ProcessStepModel model);
        Task<OperationResult> SendReportApprovalResultAsync(ProcessStepModel model);
        Task<OperationResult> ApplyReportModificationsAsync(ProcessStepModel model);
        Task<OperationResult> SendForModificationsRevisionAsync(ProcessStepModel model);
        Task<OperationResult> ModificationsRevisionAsync(ProcessStepModel model);
        Task<OperationResult> SendForModificationAffirmationAsync(ProcessStepModel model);
        Task<OperationResult> SendModificationsAffirmationResultAsync(ProcessStepModel model);
        Task<OperationResult> SendToRegistrarAsync(ProcessStepModel model);
        Task<OperationResult> CompleteProcessAsync(int processId);
        Task<OperationResult> CreateEmptyArchivalEntityDraftFromPackageFilesAsync(Guid inventorySysId, List<int> packageDocuments);
        Task<OperationResult> DeleteDocumentDraftAsync(int draftId);
        Task<OperationResult> DeleteArchivalEntityDraftAsync(int draftId);
        Task<OperationResult> MarkInvaluableFilesAsync(Guid inventorySysId);
        Task<bool> FundHasRawInventoriesInSEAAsync(Guid fundId);
    }
}
