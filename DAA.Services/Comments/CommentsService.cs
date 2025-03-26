using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Models.Comments;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;

namespace DAA.Services.Comments
{
    public class CommentsService : BaseService, ICommentsService
    {
        private readonly IUserInfo _userInfo;

        public CommentsService(
            ArchivingContext context,
            IUserInfo userInfo,
            IStringLocalizer<SharedResources> localizer) 
            : base(context, localizer)
        {
            _userInfo = userInfo;
        }
        
        public async Task<OperationResult> CreateAsync(CommentModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            { 
                //Comment comment = new()
                //{
                //    CreatedBy = _userInfo.CurrentUserId,
                //    Text = model.Text,
                //    CreatedOn = DateTime.UtcNow,
                //    ProcessId = model.ProcessId,
                //    ProcessStepId = model.ProcessStepId,
                //    IsDraft = model.IsDraft,
                //    UserName = model.UserName,
                //};

                var comment = new Comment()
                {
                    ProcessId = model.ProcessId,
                    ProcessStepId = model.ProcessStepId,
                    SessionAgendaStandpointId = model.SessionAgendaStandpointId,
                    Text = model.Text,
                    IsDraft = model.IsDraft,
                };

                _context.Comments.Add(comment);
                await _context.SaveAsync("Comment created");

                return OperationResult.Succeed(model);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }
        
        public async Task<OperationResult> UpdateCommentDraftStatusAsync(int commentId)
        {
            try
            {
                var comment = _context.Comments.Where(c => c.Id == commentId).FirstOrDefault();

                if (comment == null)
                {
                    return OperationResult.Failed();
                }

                comment.IsDraft = false;

                _context.Comments.Update(comment);
                await _context.SaveAsync("Comment updated");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }
        
        public async Task<OperationResult> UpdateAsync(CommentModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {
                var comment = await _context.Comments.FindAsync(model.Id);
                if (comment == null)
                {
                    return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                comment.ProcessId = model.ProcessId;
                comment.ProcessStepId = model.ProcessStepId;
                comment.SessionAgendaStandpointId = model.SessionAgendaStandpointId;
                comment.Text = model.Text;
                comment.IsDraft = model.IsDraft;
                
                _context.Update(comment);
                await _context.SaveAsync("Comment updated");

                return OperationResult.Succeed(comment.Id);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }
        
        public IQueryable<CommentDisplayModel> GetAll(int processId, int processStepId)
        {
            var userId = _userInfo.CurrentUserId;

            return _context.Comments
                .Where(c => c.ProcessId == processId && c.ProcessStepId == processStepId && !c.Deleted)
                .Select(c => new CommentDisplayModel()
                {
                    Id = c.Id,
                    ProcessId = c.ProcessId,
                    ProcessStepId = c.ProcessStepId,
                    SessionAgendaStandpointId = c.SessionAgendaStandpointId,
                    IsDraft = c.IsDraft,
                    Text = c.Text,
                    CreatedBy = c.CreatedBy,
                    CreatedByDisplayName = c.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == c.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = c.CreatedByNavigation!.UserName,
                    CreatedOn = c.CreatedOn.UtcToLocalTime(),
                    Deleted = c.Deleted,
                    DeletedBy = c.DeletedBy,
                    DeletedByDisplayName = c.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == c.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = c.DeletedByNavigation!.UserName,
                    DeletedOn = c.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = c.UpdatedBy,
                    UpdatedByDisplayName = c.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == c.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = c.UpdatedByNavigation!.UserName,
                    UpdatedOn = c.UpdatedOn.UtcToLocalTime(),   
                });
        }
        
        public IQueryable<CommentDisplayModel> GetBySessionAgendaStandpointId(int standpointId)
        {
            return _context.Comments
                .Where(c => c.SessionAgendaStandpointId == standpointId && !c.Deleted)
                .Select(c => new CommentDisplayModel()
                {
                    Id = c.Id,
                    ProcessId = c.ProcessId,
                    ProcessStepId = c.ProcessStepId,
                    SessionAgendaStandpointId = c.SessionAgendaStandpointId,
                    IsDraft = c.IsDraft,
                    Text = c.Text,
                    CreatedBy = c.CreatedBy,
                    CreatedByDisplayName = c.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == c.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = c.CreatedByNavigation!.UserName,
                    CreatedOn = c.CreatedOn.UtcToLocalTime(),
                    Deleted = c.Deleted,
                    DeletedBy = c.DeletedBy,
                    DeletedByDisplayName = c.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == c.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = c.DeletedByNavigation!.UserName,
                    DeletedOn = c.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = c.UpdatedBy,
                    UpdatedByDisplayName = c.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == c.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = c.UpdatedByNavigation!.UserName,
                    UpdatedOn = c.UpdatedOn.UtcToLocalTime(),
                });
        }
        
        public async Task<CommentDisplayModel?> GetCommentAsync(int id)
        {
            var comment = await _context.Comments
                            .Where(comm => comm.Id == id && !comm.Deleted)
                            .Select(comm => new CommentDisplayModel()
                            {
                                Id = comm.Id,
                                IsDraft = comm.IsDraft,
                                ProcessId = comm.ProcessId,
                                ProcessStepId = comm.ProcessStepId,
                                SessionAgendaStandpointId = comm.SessionAgendaStandpointId,
                                Text = comm.Text,
                                CreatedBy = comm.CreatedBy,
                                CreatedByDisplayName = comm.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == comm.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                CreatedByUserName = comm.CreatedByNavigation.UserName,
                                CreatedOn = comm.CreatedOn.UtcToLocalTime(),
                                UpdatedBy = comm.UpdatedBy,
                                UpdatedByDisplayName = comm.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == comm.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                UpdatedByUserName = comm.UpdatedByNavigation.UserName,
                                UpdatedOn = comm.UpdatedOn.UtcToLocalTime(),
                            })
                            .SingleOrDefaultAsync();
            return comment;
        }

        public async Task<OperationResult> DeleteAsync(int commentId)
        {
            var comment = await _context.Comments.FindAsync(commentId);

            if (comment == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            comment.Deleted = true;
            comment.DeletedOn = DateTime.UtcNow;
            comment.DeletedBy = _userInfo.CurrentUserId;

            _context.Update(comment);
            await _context.SaveAsync("Comment deleted");

            return OperationResult.Succeed(comment);
        }
    }
}
