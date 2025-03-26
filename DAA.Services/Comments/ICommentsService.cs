using DAA.Models.Comments;
using DAA.Shared;

namespace DAA.Services.Comments
{
    public interface ICommentsService
    {
        Task<OperationResult> CreateAsync(CommentModel model);
        IQueryable<CommentDisplayModel> GetAll(int processId, int processStepId);
        IQueryable<CommentDisplayModel> GetBySessionAgendaStandpointId(int standpointId);
        Task<CommentDisplayModel?> GetCommentAsync(int id);
        Task<OperationResult> DeleteAsync(int commentId);
        Task<OperationResult> UpdateAsync(CommentModel model);
        Task<OperationResult> UpdateCommentDraftStatusAsync(int commentId);
    }
}
