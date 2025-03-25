using DAA.Models.Settings;
using DAA.Shared;

namespace DAA.Services.Settings
{
    public interface ITaskTemplatesService
    {
        IQueryable<TaskTemplateDisplayModel> GetTemplates(int processStepId);
        TaskTemplateModel GetTemplateById(int id);
        Task<OperationResult> AddTemplate(TaskTemplateCreateModel model);
        Task UpdateTemplate(TaskTemplateUpdateModel model);
    }
}
