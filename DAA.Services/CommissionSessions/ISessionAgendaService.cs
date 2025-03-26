using DAA.Extensions.DynamicLinq;
using DAA.Models.Commission;
using DAA.Shared;

namespace DAA.Services.CommissionSessions
{
    public interface ISessionAgendaServiceBase
    {
        protected internal Task<int> CreateSessionAgendaItemInternalAsync(SessionAgendaItemModel model);
        protected internal Task<int> UpdateSessionAgendaItemInternalAsync(SessionAgendaItemModel model);
    }
    public interface ISessionAgendaService : ISessionAgendaServiceBase
    {
        IQueryable<SessionAgendaItemDisplayModel> GetSessionAgenda(int sessionId);
        Task<SessionAgendaItemDisplayModel?> GetSessionAgendaItemAsync(int id);
        Task<SessionAgendaItemDisplayModel?> GetSessionAgendaItemByProcessAsync(int processId);
        Task<SessionAgendaItemStandpointDisplayModel?> GetSessionAgendaItemStandpointAsync(int id);
        Task<SessionAgendaItemStandpointDisplayModel?> GetSessionAgendaItemStandpointByItemAsync(int itemId, Guid userId);
        Task<SessionAgendaItemStandpointDisplayModel?> GetSessionAgendaItemStandpointByProcessAsync(int processId, Guid userId);
        DataSourceResponseModel<SessionAgendaItemStandpointDisplayModel> GetAllSessionAgendaItemStandpoints(DataSourceRequestModel model, int itemId, bool includeDeleted = false);
        IQueryable<SessionAgendaItemStandpointDisplayModel> GetAllSessionAgendaItemStandpoints(int itemId, bool includeDeleted = false);
        IQueryable<SessionAgendaItemStandpointDisplayModel> GetAllSessionAgendaItemStandpointsByProcess(int processId, bool includeDeleted = false);
        Task<OperationResult> CreateSessionAgendaItemAsync(SessionAgendaItemModel model);
        Task<OperationResult> UpdateSessionAgendaItemAsync(SessionAgendaItemModel model);
        Task<OperationResult> CreateSessionAgendaItemStandpointAsync(SessionAgendaItemStandpointModel model);
        Task<OperationResult> UpdateSessionAgendaItemStandpointAsync(SessionAgendaItemStandpointModel model);
        Task<OperationResult> DeleteSessionAgendaItemAsync(int id);
        Task<int> GetSessionAgendaItemCountAsync(int sessionId);
    }
}
