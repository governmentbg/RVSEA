using Codeuctivity;
using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Models.Commission;
using DAA.Services.Process;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using System.Text;

namespace DAA.Services.CommissionSessions
{
    public class SessionAgendaService :BaseService, ISessionAgendaService
    {
        private readonly IUserInfo _userInfo;
        private readonly IProcessService _processService;

        public SessionAgendaService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IUserInfo userInfo,
            IProcessService processService)
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _processService = processService;
        }

        public IQueryable<SessionAgendaItemDisplayModel> GetSessionAgenda(int sessionId)
        {
            return _context.SessionAgenda
                    .Where(item => item.SessionId == sessionId && !item.Deleted)
                    .Select(item => new SessionAgendaItemDisplayModel()
                    {
                        Id = item.Id,
                        ProcessId = item.ProcessId!.Value,
                        ReportId = item.ReportId!.Value,
                        SessionId = item.SessionId!.Value,
                        CreatedBy = item.CreatedBy,
                        CreatedByDisplayName = item.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == item.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                        CreatedByUserName = item.CreatedByNavigation!.UserName,
                        CreatedOn = item.CreatedOn.UtcToLocalTime(),
                        Deleted = item.Deleted,
                        DeletedBy = item.DeletedBy,
                        DeletedByDisplayName = item.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == item.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                        DeletedByUserName = item.DeletedByNavigation!.UserName,
                        DeletedOn = item.DeletedOn.UtcToLocalTime(),
                        ProcessTypeTitle = item.Process!.ProcessType.Name,
                        ReportNumber = item.Report!.Number,
                        ReportCreatedBy = item.Report.CreatedBy,
                        ReportCreatedByDisplayName = item.Report.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == item.Report.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                        ReportCreatedByUserName = item.Report.CreatedByNavigation!.UserName,
                        SessionDate = item.Session!.SessionDate.UtcToLocalTime(),
                        UpdatedBy = item.UpdatedBy,
                        UpdatedByDisplayName = item.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == item.Report.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                        UpdatedByUserName = item.UpdatedByNavigation!.UserName,
                        UpdatedOn = item.UpdatedOn.UtcToLocalTime(),
                    });
        }

        public async Task<SessionAgendaItemDisplayModel?> GetSessionAgendaItemAsync(int id)
        {
            var sessionAgendaItem = await _context.SessionAgenda
                .Where(item => item.Id == id && !item.Deleted)
                .Select(item => new SessionAgendaItemDisplayModel()
                { 
                    Id = item.Id,
                    SessionId = item.SessionId!.Value,
                    ProcessId = item.ProcessId!.Value,
                    ReportId = item.ReportId!.Value,
                    SessionDate = item.Session!.SessionDate.UtcToLocalTime(),
                    ProcessTypeTitle = item.Process!.ProcessType.Name,
                    ReportNumber = item.Report!.Number,
                    CreatedBy = item.CreatedBy,
                    CreatedByDisplayName = item.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == item.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = item.CreatedByNavigation.UserName,
                    CreatedOn = item.CreatedOn.UtcToLocalTime(),
                    UpdatedBy = item.UpdatedBy,
                    UpdatedByDisplayName = item.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == item.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = item.UpdatedByNavigation.UserName,
                    UpdatedOn = item.UpdatedOn.UtcToLocalTime(),
                })
                .SingleOrDefaultAsync();

            return sessionAgendaItem;
        }

        public async Task<SessionAgendaItemDisplayModel?> GetSessionAgendaItemByProcessAsync(int processId)
        {
            var sessionAgendaItem = await _context.SessionAgenda
                .Where(item => item.ProcessId == processId && !item.Deleted)
                .Select(item => new SessionAgendaItemDisplayModel()
                {
                    Id = item.Id,
                    SessionId = item.SessionId!.Value,
                    ProcessId = item.ProcessId!.Value,
                    ReportId = item.ReportId!.Value,
                    SessionDate = item.Session!.SessionDate.UtcToLocalTime(),
                    ProcessTypeTitle = item.Process!.ProcessType.Name,
                    ReportNumber = item.Report!.Number,
                    CreatedBy = item.CreatedBy,
                    CreatedByDisplayName = item.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == item.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = item.CreatedByNavigation.UserName,
                    CreatedOn = item.CreatedOn.UtcToLocalTime(),
                    UpdatedBy = item.UpdatedBy,
                    UpdatedByDisplayName = item.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == item.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = item.UpdatedByNavigation.UserName,
                    UpdatedOn = item.UpdatedOn.UtcToLocalTime(),
                })
                .SingleOrDefaultAsync();

            return sessionAgendaItem;
        }

        public async Task<SessionAgendaItemStandpointDisplayModel?> GetSessionAgendaItemStandpointAsync(int id)
        {
            var sessionAgendaItemStandpoint = await _context.SessionAgendaStandpoints
                .Where(item => item.Id == id && !item.Deleted)
                .Select(item => new SessionAgendaItemStandpointDisplayModel()
                {
                    Id = item.Id,
                    IsDraft = item.IsDraft,
                    ReportId = item.ReportId,
                    ProcessId = item.Report.ProcessId,
                    Content = item.Content,
                    StatusCode= item.Status,
                    CreatedBy = item.CreatedBy,
                    CreatedByDisplayName = item.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == item.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = item.CreatedByNavigation.UserName,
                    CreatedOn = item.CreatedOn.UtcToLocalTime(),
                    UpdatedBy = item.UpdatedBy,
                    UpdatedByDisplayName = item.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == item.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = item.UpdatedByNavigation.UserName,
                    UpdatedOn = item.UpdatedOn.UtcToLocalTime(),
                    Deleted = item.Deleted,
                    DeletedBy = item.DeletedBy,
                    DeletedByDisplayName = item.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == item.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = item.DeletedByNavigation.UserName,
                    DeletedOn = item.DeletedOn.UtcToLocalTime(),    
                })
                .SingleOrDefaultAsync();

            return sessionAgendaItemStandpoint;
        }

        public async Task<SessionAgendaItemStandpointDisplayModel?> GetSessionAgendaItemStandpointByItemAsync(int itemId, Guid userId)
        {
            var sessionAgendaItemStandpoint = await _context.SessionAgendaStandpoints
                .Where(item => item.CreatedBy == userId && item.SessionAgendaItemId == itemId && !item.Deleted)
                .Select(item => new SessionAgendaItemStandpointDisplayModel()
                {
                    Id = item.Id,
                    IsDraft = item.IsDraft,
                    ProcessId = item.Report.ProcessId,
                    ReportId = item.ReportId,
                    Content = item.Content,
                    StatusCode = item.Status,
                    CreatedBy = item.CreatedBy,
                    CreatedByDisplayName = item.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == item.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = item.CreatedByNavigation.UserName,
                    CreatedOn = item.CreatedOn.UtcToLocalTime(),
                    UpdatedBy = item.UpdatedBy,
                    UpdatedByDisplayName = item.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == item.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = item.UpdatedByNavigation.UserName,
                    UpdatedOn = item.UpdatedOn.UtcToLocalTime(),
                })
                .SingleOrDefaultAsync();

            return sessionAgendaItemStandpoint;
        }

        public async Task<SessionAgendaItemStandpointDisplayModel?> GetSessionAgendaItemStandpointByProcessAsync(int processId, Guid userId)
        {
            var sessionAgendaItemStandpoint = await _context.SessionAgendaStandpoints
                .Where(item => item.CreatedBy == userId && item.Report.ProcessId == processId && !item.Deleted)
                .Select(item => new SessionAgendaItemStandpointDisplayModel()
                {
                    Id = item.Id,
                    IsDraft = item.IsDraft,
                    ReportId = item.ReportId,
                    ProcessId = item.Report.ProcessId,
                    Content = item.Content,
                    StatusCode = item.Status,
                    CreatedBy = item.CreatedBy,
                    CreatedByDisplayName = item.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == item.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = item.CreatedByNavigation.UserName,
                    CreatedOn = item.CreatedOn.UtcToLocalTime(),
                    UpdatedBy = item.UpdatedBy,
                    UpdatedByDisplayName = item.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == item.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = item.UpdatedByNavigation.UserName,
                    UpdatedOn = item.UpdatedOn.UtcToLocalTime(),
                })
                .SingleOrDefaultAsync();

            return sessionAgendaItemStandpoint;
        }

        public DataSourceResponseModel<SessionAgendaItemStandpointDisplayModel> GetAllSessionAgendaItemStandpoints(DataSourceRequestModel model, int itemId, bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.SessionAgendaStandpoints
                .Where(sp => sp.SessionAgendaItemId == itemId && !sp.IsDraft)
                .Select(sp => new SessionAgendaItemStandpointDisplayModel()
                {
                    Id = sp.Id,
                    IsDraft = sp.IsDraft,
                    ReportId = sp.ReportId,
                    ProcessId = sp.Report.ProcessId,
                    Content = sp.Content,
                    StatusCode = sp.Status,
                    CreatedBy = sp.CreatedBy,
                    CreatedByDisplayName= sp.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sp.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName= sp.CreatedByNavigation.UserName,
                    CreatedOn = sp.CreatedOn.UtcToLocalTime(),
                    UpdatedBy = sp.UpdatedBy,
                    UpdatedByDisplayName = sp.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sp.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = sp.UpdatedByNavigation!.UserName,
                    UpdatedOn = sp.UpdatedOn.UtcToLocalTime(),
                    Deleted = sp.Deleted,
                    DeletedBy = sp.DeletedBy,
                    DeletedByDisplayName= sp.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sp.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName= sp.DeletedByNavigation.UserName,
                    DeletedOn = sp.DeletedOn.UtcToLocalTime(),
                });

            if (!includeDeleted)
            {
                query = query.Where(f => !f.Deleted);
            }

            QueryResponseModel<SessionAgendaItemStandpointDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<SessionAgendaItemStandpointDisplayModel> result = new DataSourceResponseModel<SessionAgendaItemStandpointDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => x)
            };

            return result;
        }

        public IQueryable<SessionAgendaItemStandpointDisplayModel> GetAllSessionAgendaItemStandpoints(int itemId, bool includeDeleted = false)
        {
            var query =
                _context.SessionAgendaStandpoints
                .Where(sp => sp.SessionAgendaItemId == itemId && !sp.IsDraft)
                .Select(sp => new SessionAgendaItemStandpointDisplayModel()
                {
                    Id = sp.Id,
                    IsDraft = sp.IsDraft,
                    ReportId = sp.ReportId,
                    ProcessId = sp.Report.ProcessId,
                    Content = sp.Content,
                    StatusCode = sp.Status,
                    CreatedBy = sp.CreatedBy,
                    CreatedByDisplayName = sp.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sp.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = sp.CreatedByNavigation.UserName,
                    CreatedOn = sp.CreatedOn.UtcToLocalTime(),
                    UpdatedBy = sp.UpdatedBy,
                    UpdatedByDisplayName = sp.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sp.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = sp.UpdatedByNavigation!.UserName,
                    UpdatedOn = sp.UpdatedOn.UtcToLocalTime(),
                    Deleted = sp.Deleted,
                    DeletedBy = sp.DeletedBy,
                    DeletedByDisplayName = sp.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sp.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = sp.DeletedByNavigation.UserName,
                    DeletedOn = sp.DeletedOn.UtcToLocalTime(),
                });

            if (!includeDeleted)
            {
                query = query.Where(f => !f.Deleted);
            }

            return query;
        }

        public IQueryable<SessionAgendaItemStandpointDisplayModel> GetAllSessionAgendaItemStandpointsByProcess(int processId, bool includeDeleted = false)
        {
            var query =
                _context.SessionAgendaStandpoints
                .Where(sp => sp.Report.ProcessId == processId && !sp.IsDraft)
                .Select(sp => new SessionAgendaItemStandpointDisplayModel()
                {
                    Id = sp.Id,
                    IsDraft = sp.IsDraft,
                    ReportId = sp.ReportId,
                    ProcessId = sp.Report.ProcessId,
                    Content = sp.Content,
                    StatusCode = sp.Status,
                    CreatedBy = sp.CreatedBy,
                    CreatedByDisplayName = sp.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sp.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = sp.CreatedByNavigation.UserName,
                    CreatedOn = sp.CreatedOn.UtcToLocalTime(),
                    UpdatedBy = sp.UpdatedBy,
                    UpdatedByDisplayName = sp.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sp.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = sp.UpdatedByNavigation!.UserName,
                    UpdatedOn = sp.UpdatedOn.UtcToLocalTime(),
                    Deleted = sp.Deleted,
                    DeletedBy = sp.DeletedBy,
                    DeletedByDisplayName = sp.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sp.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = sp.DeletedByNavigation.UserName,
                    DeletedOn = sp.DeletedOn.UtcToLocalTime(),
                });

            if (!includeDeleted)
            {
                query = query.Where(f => !f.Deleted);
            }

            return query;
        }

        async Task<int> ISessionAgendaServiceBase.CreateSessionAgendaItemInternalAsync(SessionAgendaItemModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            
            var sessionAgendaItem = new SessionAgendum()
            {
                SessionId = model.SessionId,
                ReportId = model.ReportId,
                ProcessId = model.ProcessId,
            };

            _context.SessionAgenda.Add(sessionAgendaItem);
            await _context.SaveAsync("Session agenda item crated");

            if (model.Standpoints != null && model.Standpoints.Count() > 0)
            {
                foreach (var standpoint in model.Standpoints)
                {
                    var sessionAgendaItemStandpoint = new SessionAgendaStandpoint()
                    {
                        SessionAgendaItemId = sessionAgendaItem.Id,
                        Content = standpoint.Content!,
                    };

                    _context.SessionAgendaStandpoints.Add(sessionAgendaItemStandpoint);
                }
                await _context.SaveAsync("Session agenda item standpoind crated");
            }

            return sessionAgendaItem.Id;
           
        }

        public async Task<OperationResult> CreateSessionAgendaItemAsync(SessionAgendaItemModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var sessionAgendaItemId = await ((ISessionAgendaServiceBase)this).CreateSessionAgendaItemInternalAsync(model);

                transaction.Commit();
                return OperationResult.Succeed(sessionAgendaItemId);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> CreateSessionAgendaItemStandpointAsync(SessionAgendaItemStandpointModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {
                var sessionAgendaItemStandpoint = new SessionAgendaStandpoint()
                {
                    ReportId = model.ReportId,
                    SessionAgendaItemId = model.SessionAgendaItemId,
                    Content = model.Content!,
                    IsDraft = true,
                };

                _context.SessionAgendaStandpoints.Add(sessionAgendaItemStandpoint);
                   
                await _context.SaveAsync("Session agenda item standpoint crated");
              

                return OperationResult.Succeed(sessionAgendaItemStandpoint.Id);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        async Task<int> ISessionAgendaServiceBase.UpdateSessionAgendaItemInternalAsync(SessionAgendaItemModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var sessionAgendaItem = await _context.SessionAgenda.FindAsync(model.Id);
            if (sessionAgendaItem == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), model.Id!.Value.ToString());
            }

            sessionAgendaItem.SessionId = model.SessionId;
            sessionAgendaItem.ReportId = model.ReportId;
            sessionAgendaItem.ProcessId = model.ProcessId;

            _context.Update(sessionAgendaItem);
            await _context.SaveAsync("Session agenda item updated");

            if (model.Standpoints != null && model.Standpoints.Count() > 0)
            { 
                foreach(var standpoint in model.Standpoints)
                {
                    var sessionAgendaItemStandpoint = await _context.SessionAgendaStandpoints.FindAsync(standpoint.Id);
                    if (sessionAgendaItemStandpoint == null)
                    {
                        throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), standpoint.Id!.ToString()!);
                    }

                    sessionAgendaItemStandpoint.Content = standpoint.Content!;

                    _context.Update(sessionAgendaItemStandpoint);
                }

                await _context.SaveAsync("Session agenda item standpoint updated");
            }

            return sessionAgendaItem.Id;
        }

        public async Task<OperationResult> UpdateSessionAgendaItemAsync(SessionAgendaItemModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var sessionAgendaItemId = await ((ISessionAgendaServiceBase)this).UpdateSessionAgendaItemInternalAsync(model);

                transaction.Commit();
                return OperationResult.Succeed(sessionAgendaItemId);
            }
            catch(ItemNotFoundException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
            catch(Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> UpdateSessionAgendaItemStandpointAsync(SessionAgendaItemStandpointModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {
                var sessionAgendaItemStandpoint = await _context.SessionAgendaStandpoints.FindAsync(model.Id!.Value);
                if (sessionAgendaItemStandpoint == null)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                sessionAgendaItemStandpoint.ReportId = model.ReportId;
                sessionAgendaItemStandpoint.SessionAgendaItemId = model.SessionAgendaItemId;
                sessionAgendaItemStandpoint.Content = model.Content!;
                sessionAgendaItemStandpoint.IsDraft = model.IsDraft;
                sessionAgendaItemStandpoint.Status = model.StatusCode;
                
                _context.Update(sessionAgendaItemStandpoint);

                await _context.SaveAsync("Session agenda item standpoint updated");


                return OperationResult.Succeed(sessionAgendaItemStandpoint.Id);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> DeleteSessionAgendaItemAsync (int id)
        {
            try
            {
                var sessionAgendaItem = await _context.SessionAgenda.Where(a => a.Id == id && !a.Deleted).SingleOrDefaultAsync();
                if (sessionAgendaItem == null)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                sessionAgendaItem.Deleted = true;
                sessionAgendaItem.DeletedBy = _userInfo.CurrentUserId;
                sessionAgendaItem.DeletedOn = DateTime.UtcNow;

                _context.Update(sessionAgendaItem);
                await _context.SaveAsync("Session agenda item deleted");

                return OperationResult.Success;
            }
            catch (Exception exc) 
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<int> GetSessionAgendaItemCountAsync(int sessionId)
        {
            var agendaItemCount = await _context.SessionAgenda
                                    .Where(a => a.SessionId == sessionId && !a.Deleted)
                                    .CountAsync();
            return agendaItemCount;
        }

        //public async Task<bool> SessionAgendaItemHasDecision(int itemId)
        //{
        //    var hasDecision = await _context.SessionDecisions
        //                            .Where(dec => dec.SessionAgendaId == itemId && !dec.Deleted)
        //                            .AnyAsync();
        //    return hasDecision;
        //}

        //public async Task<bool> AllSessionAgendaItemsHaveDecisions(int sessionId)
        //{
        //    var hasDecision = await _context.SessionAgenda
        //                            .Where(a => a.SessionId == sessionId && !a.Deleted)
        //                            .AllAsync(a => a.SessionDecisions.Any());
        //    return hasDecision;
        //}
    }
}
