using DAA.Extensions.DynamicLinq;
using DAA.Models.Commission;
using DAA.Models.File;
using DAA.Shared;

namespace DAA.Services.CommissionSessions
{
    public interface ICommissionSessionService
    {
        Task<OperationResult> CreateSessionAsync(CommissionSessionModel model);
        Task<OperationResult> EditSessionAsync(CommissionSessionModel model);
        Task<CommissionSessionDisplayModel?> GetSessionByIdAsync(int id);
        Task<OperationResult> DeleteSessionAsync(int meetingId);
        DataSourceResponseModel<CommissionSessionDisplayModel> GetAllSessions(DataSourceRequestModel model);
        DataSourceResponseModel<CommissionSessionDisplayModel> GetUpcomingSessions(DataSourceRequestModel model);
        DataSourceResponseModel<CommissionSessionDisplayModel> GetPastSessions(DataSourceRequestModel model);
        Task<OperationResult> GenerateProtocol(SessionGenerateProtocolModel model);
        Task<OperationResult> GetProtocolData(SessionProtocolEditModel model);
        Task<OperationResult> GetSessionProtocol(int id);
        Task<OperationResult> EditSessionProtocolContent(SessionProtocolEditModel model);
        Task<OperationResult> SendProtocolForApproval(int sessionsId);
        Task<OperationResult> ApprovalProtocol(int sessionsId);
        Task<OperationResult> RejectProtocol(int sessionsId, string rejectReason);
        Task<OperationResult> UploadProtocolFile(CommissionSessionUploadProtocolModel model);
        Task<FileModel?> GetFile(int sessionId);
        Task<OperationResult> EditSessionAgendaList(SessionReportEditListModel model);
    }
}
