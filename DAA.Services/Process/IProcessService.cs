using DAA.Models.Processes;
using DAA.Shared;

namespace DAA.Services.Process
{
    public interface IProcessService
    {
        Task<List<ProcessTimelineModel>> GetTimelineAsync(int processId);
        Task<OperationResult> StartProcessAsync(ProcessModel model);
        Task<OperationResult> SetActiveProcessStepAsync(int processId, int stepTypeId);
        Task<OperationResult> SetActiveProcessStepAsync(ProcessStepModel model);
        Task<OperationResult> CompleteProcessAsync(int id);
        Task<ProcessDisplayModel?> GetProcessAsync(int processId);
        Task<ProcessStepModel?> GetProcessStepAsync(int stepId);
        Task<ProcessStepModel?> GetProcessStepAsync(int processId, ProcessStepType stepType);
        Task<ProcessDisplayModel?> GetCurrentActiveProcess(string entityType, Guid? entitySysId, bool? includeParent = null, int? externalIdentifier = null);
        Task<Data.Process> CreateProcessAsync(ProcessModel model);
        Task<Data.ProcessTimeline> AddStepAsync(int processId, int stepType);
        Task<bool> HasCurrentActiveProcess(string entityType, Guid entitySysId);
        OperationResult ValidateProcess(ProcessModel? process, Shared.ProcessType processType);
        OperationResult ValidateProcess(ProcessModel? process, params Shared.ProcessType[] processTypes);
        OperationResult ValidateProcessStep(ProcessModel? process, ProcessStepModel? processStep, ProcessStepType stepType);
        OperationResult ValidateProcessStep(ProcessModel? process, ProcessStepModel? processStep, params ProcessStepType[] stepTypes);
        Task<bool> IsCurrentUserInProcessAsync(int processId);
        Task<bool> IsCurrentUserInProcessStepAsync(int processId, int stepId);
        Task<OperationResult> HasEntitiesInCEA(ProcessModel model);
        Task<OperationResult> MoveToNextStep(ProcessStepModel model);
        string GetEntityType(ProcessModel process);
        Guid GetEntitySystemIdentifier(ProcessModel process);
        Task<int> GetLastProcessType(Guid entitySysId);
    }
}
