using DAA.Extensions.DynamicLinq;
using DAA.Models.Tasks;
using DAA.Shared;

namespace DAA.Services.Tasks
{
    public interface ITaskService
    {
        Task<OperationResult> CreateAsync(TaskCreateModel model);
        Task<OperationResult> ChangeTaskStatus(int taskId, string newStatus);
        DataSourceResponseModel<TaskShortModel> GetMyTasks(DataSourceRequestModel model, bool includeDeleted = false);
        DataSourceResponseModel<TaskShortModel> GetAssignedByMe(DataSourceRequestModel model, bool includeDeleted = false);
        Task<TaskDisplayModel?> GetById(int id);
        Task<int> GetMyNewTasksCount();
        Task<OperationResult> CompletePreviousTask(ProcessStepType prevStep, int? processId, string notificationType, int? entityId);
    }
}
