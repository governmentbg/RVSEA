using DAA.Models.Processes;
using DAA.Shared;

namespace DAA.Services.EditFundDataProcess
{
    public interface IEditFundDataProcessService
    {
        Task<OperationResult> StartProcessAsync(ProcessModel model);
        Task<OperationResult> CompleteProcessAsync(int processId);
        Task<OperationResult> UndoProcessChangesAsync(int processId);
        Task<OperationResult> StartApplyingChangesAsync(ProcessStepModel model);
        Task<OperationResult> CreateReportAsync(ProcessStepModel model);
        Task<OperationResult> SendReportAsync(ProcessStepModel model);
        //Task<OperationResult> AddReportToSessionAgendaAsync(ProcessStepModel model);
        Task<OperationResult> SendToAddStandpointAsync(ProcessStepModel model);
        Task<OperationResult> SendSessionAgendaStandpointAsync(ProcessStepModel model);
        Task<OperationResult> SendReportApprovalResultAsync(ProcessStepModel model);
        Task<OperationResult> SendToAddCommentAsync(ProcessStepModel model);
        Task<OperationResult> AddCommentToSessionAgendaStandpointAsync(ProcessStepModel model);
        Task<OperationResult> SendCommentAsync(ProcessStepModel model);
        Task<OperationResult> SetSessionAgendaItemAsync(ProcessStepModel model);
        Task<OperationResult> ApplyReportModificationsAsync(ProcessStepModel model);
        Task<OperationResult> SendForModificationsRevisionAsync(ProcessStepModel model);
        Task<OperationResult> ModificationsRevisionAsync(ProcessStepModel model);
        Task<OperationResult> SendForModificationAffirmationAsync(ProcessStepModel model);
        Task<OperationResult> SendModificationsAffirmationResultAsync(ProcessStepModel model);
    }
}
