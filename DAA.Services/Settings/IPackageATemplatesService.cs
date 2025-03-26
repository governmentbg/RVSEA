using DAA.Models.Settings;

namespace DAA.Services.Settings
{
    public interface IPackageATemplatesService
    {
        Task<int> AddTemplate(PackageATemplateCreateModel model);
        Task RemoveTemplate(int id);
        Task UpdateTemplate(PackageATemplateUpdateModel model);
        IQueryable<PackageATemplateModel> GetTemplates(int procedureId);
        IQueryable<PackageATemplateModel> GetTemplatesForSignatureRequest(int packageId, int processId);
        Task<Data.File> GetFile(int templateId);
        PackageATemplateModel GetTemplateById(int id);
        Task<IQueryable<PackageATemplateModel>> GetTemplatesForApplication(int applicationId);
        Task<IQueryable<PackageATemplateModel>> GetEmptyPackageTemplatesByInventoryId(int packageId, int processId);
    }
}
