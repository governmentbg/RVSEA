using DAA.Models.Commission;
using DAA.Models.File;
using DAA.Shared;

namespace DAA.Services.CommissionDecisions
{
    public interface ICommissionDecisionService
    {
        Task<CommissionDecisionDisplayModel?> GetByIdAsync(int id);
        Task<CommissionDecisionDisplayModel?> GetBySessionAgendaIdAsync(int id);
        Task<CommissionDecisionDisplayModel?> GetByProcessIdAsync(int processId);
        IQueryable<CommissionDecisionDisplayModel> GetBySessionId(int sessionId);
        Task<OperationResult> CreateDecisionAsync(CommissionDecisionModel model);
        Task<OperationResult> UpdateDecisionAsync(CommissionDecisionModel model);
        Task<OperationResult?> GetById(int id);
        Task<OperationResult> CreateOrUpdate(CommissionDecisionModel model);
        Task<FileModel?> GetFile(int sessionId);
        Task<int> GetCommissionSessionDecisionCountAsync(int sessionId);
    }
}
