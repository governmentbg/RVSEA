using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Applications;
using DAA.Models.DocsCollectionProcedure;
using DAA.Models.File;
using DAA.Shared;

namespace DAA.Services.Applications
{
    public interface IApplicationServiceBase
    {
        protected internal Task<EdocsCollectingApplication?> GetByProcessInternalAsync(int processId);
    }
    public interface IApplicationsService : IApplicationServiceBase
    {
        System.Threading.Tasks.Task CreateApplication(ApplicationCreateModel model);
        DataSourceResponseModel<ApplicationGridModel> List(DataSourceRequestModel model);
        DataSourceResponseModel<ApplicationGridModel> ListNew(DataSourceRequestModel model);
        ApplicationDisplayModel Display(int id);
        Task<ApplicationDisplayModel?> GetByProcessAsync(int processId);
        FileModel GetApplicationFile(int applicationId);
        Task<OperationResult> Approve(ApproveModel model);
        System.Threading.Tasks.Task Reject(RejectModel model);
        Task<int> GetStatusAsync(int applicationId);
        System.Threading.Tasks.Task UpdateStatus(int applicationId, ApplicationStatus status, bool applySave = true);
        public DocsCollectingGridModel? ApplicationRelatedProcess(int applicationId);
        Task<int?> GetActiveProcessIdByApplicationAsync(int applicationId);
        Guid GetApplicationInventoryIdentifier(int applicationId);
        Task<bool> HasAnyPackagesAsync(int applicationId);
        Task<OperationResult> Delete(int id);
        Task<EdocsCollectingApplication?> GetApplicationFromInventoryDraft(Guid? fundSystemIdentifier, Guid? inventorySystemIdentifier);
        Task<OperationResult> RedirectAsync(EdocsCollectingApplication application, int newArchiveId);
        Task<OperationResult> CreateSystemApplicationAsync(InventoryDraft invDraft, string? docOriginType);
        Task<Guid?> GetInventoryDraftSysId(int applicationId);
    }
}
