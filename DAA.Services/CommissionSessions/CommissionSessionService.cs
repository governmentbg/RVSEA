using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Commission;
using DAA.Models.File;
using DAA.Models.Processes;
using DAA.Models.Tasks;
using DAA.Services.CommissionDecisions;
using DAA.Services.Files;
using DAA.Services.Process;
using DAA.Services.Tasks;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using DocumentFormat.OpenXml.Spreadsheet;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using System.Linq.Dynamic.Core;
using System.Text;

namespace DAA.Services.CommissionSessions
{
    public class CommissionSessionService : BaseService, ICommissionSessionService
    {
        private readonly IUserInfo _userInfo;
        private readonly IProcessService _processService;
        private readonly ITaskService _taskService;
        private readonly IFileService _fileService;
        private readonly ISessionAgendaService _sessionAgendaService;
        private readonly ICommissionDecisionService _commissionDecisionService;

        public CommissionSessionService
            (ArchivingContext context,
            IUserInfo userInfo,
            ITaskService taskService,
            IProcessService processService,
            IFileService fileService,
            ISessionAgendaService sessionAgendaService,
            ICommissionDecisionService commissionDecisionService,
            IStringLocalizer<SharedResources> localizer)
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _processService = processService;
            _taskService = taskService;
            _fileService = fileService;
            _sessionAgendaService = sessionAgendaService;
            _commissionDecisionService = commissionDecisionService;
        }

        public async Task<OperationResult> CreateSessionAsync(CommissionSessionModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {
                var session = new Session()
                {
                    SessionDate = model.SessionDate,
                    ArchiveId = model.ArchiveId!.Value,
                    SessionType = model.SessionTypeCode,
                    ChairmanId = model.ChairmanId,
                    SecretaryId = model.SecretaryId,
                };
                _context.Sessions.Add(session);

                await _context.SaveAsync("Commission Session created");

                return OperationResult.Succeed(session.Id);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }
        public async Task<OperationResult> EditSessionAsync(CommissionSessionModel model)
        {
            if (model.Id == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {
                var session = _context.Sessions.Where(s => s.Id == model.Id).FirstOrDefault();

                session!.SessionDate = model.SessionDate;
                session!.ChairmanId = model.ChairmanId;
                session!.SecretaryId = model.SecretaryId;

                _context.Sessions.Update(session);

                await _context.SaveAsync("Commission Session updated");

                return OperationResult.Succeed(session.Id);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }
        public async Task<CommissionSessionDisplayModel?> GetSessionByIdAsync(int id)
        {
            var result =
                await _context.Sessions
                .Include(x => x.SessionTypeNavigation)
                .Where(sess => sess.Id == id && !sess.Deleted)
                .Select(sess => new CommissionSessionDisplayModel()
                {
                    Id = sess.Id,
                    SessionDate = sess.SessionDate.UtcToLocalTime(),
                    CreatedBy = sess.CreatedBy,
                    CreatedByDisplayName = sess.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sess.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = sess.CreatedByNavigation.UserName,
                    CreatedOn = sess.CreatedOn.UtcToLocalTime(),
                    Deleted = sess.Deleted,
                    ArchiveId = sess.ArchiveId,
                    ArchiveName = sess.Archive.Name,
                    DeletedBy = sess.DeletedBy,
                    SessionTypeCode = sess.SessionTypeNavigation!.Code,
                    MinutesOfMeetingId = sess.MinutesOfMeetingId,
                    MinutesOfMeetingNumber = sess.MinutesOfMeeting!.Number,
                    MinutesOfMeetingDate = sess.MinutesOfMeeting.CreatedOn.UtcToLocalTime(),
                    MinutesOfMeetingHasFile = sess.MinutesOfMeeting.UncPath != null ? true : false,
                    MinutesOfMeetingStatus = sess.MinutesOfMeeting.Status,
                    MinutesOfMeetingRejectReason = sess.MinutesOfMeeting.RejectReason,
                    DeletedByDisplayName = sess.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sess.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = sess.DeletedByNavigation!.UserName,
                    DeletedOn = sess.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = sess.UpdatedBy,
                    UpdatedByDisplayName = sess.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sess.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = sess.UpdatedByNavigation!.UserName,
                    UpdatedOn = sess.UpdatedOn.UtcToLocalTime(),
                    ChairmanDisplayName = sess.Chairman!.AspNetUserProfileUsers.Where(up => up.UserId == sess.ChairmanId && !up.Deleted).FirstOrDefault().DisplayName,
                    SecretaryDisplayName = sess.Secretary!.AspNetUserProfileUsers.Where(up => up.UserId == sess.SecretaryId && !up.Deleted).FirstOrDefault().DisplayName,
                })
                .SingleOrDefaultAsync();

            return result;
        }
        public async Task<OperationResult> DeleteSessionAsync(int sessionId)
        {
            try
            {
                var session = await _context.Sessions.FindAsync(sessionId);
                if (session == null || session.MinutesOfMeetingId != null)
                {
                    return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                var sessionAgendas = _context.SessionAgenda.Where(a => a.SessionId == sessionId);

                if (sessionAgendas != null)
                {
                    foreach (var item in sessionAgendas)
                    {
                        item.Deleted = true;
                        item.DeletedOn = DateTime.UtcNow;
                        item.DeletedBy = _userInfo.CurrentUserId;

                        _context.Update(item);
                    }
                }

                session.Deleted = true;
                session.DeletedOn = DateTime.UtcNow;
                session.DeletedBy = _userInfo.CurrentUserId;

                _context.Update(session);

                await _context.SaveAsync("Commission session deleted");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }
        public DataSourceResponseModel<CommissionSessionDisplayModel> GetAllSessions(DataSourceRequestModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query = _context.Sessions
                        .Where(sess => !sess.Deleted)
                        .OrderByDescending(sess => sess.SessionDate)
                        .Select(sess => new CommissionSessionDisplayModel()
                        {
                            Id = sess.Id,
                            ArchiveId = sess.ArchiveId,
                            ChairmanId = sess.ChairmanId,
                            SecretaryId = sess.SecretaryId,
                            SessionDate = sess.SessionDate,
                            SessionTypeCode = sess.SessionType,
                            ArchiveName = sess.Archive.Name,
                            ChairmanDisplayName = sess.Chairman!.AspNetUserProfileUsers.Where(up => up.UserId == sess.ChairmanId && !up.Deleted).FirstOrDefault().DisplayName,
                            SecretaryDisplayName = sess.Secretary!.AspNetUserProfileUsers.Where(up => up.UserId == sess.SecretaryId && !up.Deleted).FirstOrDefault().DisplayName,
                            SessionTypeName = sess.SessionTypeNavigation!.Text,
                            MinutesOfMeetingId = sess.MinutesOfMeetingId,
                            MinutesOfMeetingDate = sess.MinutesOfMeeting!.CreatedOn,
                            MinutesOfMeetingNumber = sess.MinutesOfMeeting.Number,
                            MinutesOfMeetingStatus = sess.MinutesOfMeeting.Status,
                            CreatedBy = sess.CreatedBy,
                            CreatedByDisplayName = sess.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sess.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            CreatedByUserName = sess.CreatedByNavigation.UserName,
                            CreatedOn = sess.CreatedOn,
                            Deleted = sess.Deleted,
                            DeletedBy = sess.DeletedBy,
                            DeletedByDisplayName = sess.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sess.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            DeletedByUserName = sess.DeletedByNavigation!.UserName,
                            DeletedOn = sess.DeletedOn,
                            UpdatedBy = sess.UpdatedBy,
                            UpdatedByDisplayName = sess.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sess.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            UpdatedByUserName = sess.UpdatedByNavigation!.UserName,
                            UpdatedOn = sess.UpdatedOn,

                        }); ;

            QueryResponseModel<CommissionSessionDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<CommissionSessionDisplayModel> result = new DataSourceResponseModel<CommissionSessionDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => new CommissionSessionDisplayModel()
                {
                    Id = x.Id,
                    ArchiveId = x.ArchiveId,
                    ChairmanId = x.ChairmanId,
                    SecretaryId = x.SecretaryId,
                    SessionDate = x.SessionDate.UtcToLocalTime(),
                    SessionTypeCode = x.SessionTypeCode,
                    ArchiveName = x.ArchiveName,
                    ChairmanDisplayName = x.ChairmanDisplayName,
                    SecretaryDisplayName = x.SecretaryDisplayName,
                    SessionTypeName = x.SessionTypeName,
                    MinutesOfMeetingId = x.MinutesOfMeetingId,
                    MinutesOfMeetingDate = x.MinutesOfMeetingDate.UtcToLocalTime(),
                    MinutesOfMeetingNumber = x.MinutesOfMeetingNumber,
                    MinutesOfMeetingStatus = x.MinutesOfMeetingStatus,
                    CreatedBy = x.CreatedBy,
                    CreatedByDisplayName = x.CreatedByDisplayName,
                    CreatedByUserName = x.CreatedByUserName,
                    CreatedOn = x.CreatedOn.UtcToLocalTime(),
                    Deleted = x.Deleted,
                    DeletedBy = x.DeletedBy,
                    DeletedByDisplayName = x.DeletedByDisplayName,
                    DeletedByUserName = x.DeletedByUserName,
                    DeletedOn = x.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = x.UpdatedBy,
                    UpdatedByDisplayName = x.UpdatedByDisplayName,
                    UpdatedByUserName = x.UpdatedByUserName,
                    UpdatedOn = x.UpdatedOn.UtcToLocalTime(),
                })
            };

            return result;
        }
        public DataSourceResponseModel<CommissionSessionDisplayModel> GetUpcomingSessions(DataSourceRequestModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query = _context.Sessions

                        .Where(sess => sess.SessionDate >= DateTime.UtcNow.Date && !sess.Deleted)
                        .OrderByDescending(sess => sess.SessionDate)
                        .Select(sess => new CommissionSessionDisplayModel()
                        {
                            Id = sess.Id,
                            ArchiveId = sess.ArchiveId,
                            ChairmanId = sess.ChairmanId,
                            SecretaryId = sess.SecretaryId,
                            SessionDate = sess.SessionDate,
                            SessionTypeCode = sess.SessionType,
                            ArchiveName = sess.Archive.Name,
                            ChairmanDisplayName = sess.Chairman!.AspNetUserProfileUsers.Where(up => up.UserId == sess.ChairmanId && !up.Deleted).FirstOrDefault().DisplayName,
                            SecretaryDisplayName = sess.Secretary!.AspNetUserProfileUsers.Where(up => up.UserId == sess.SecretaryId && !up.Deleted).FirstOrDefault().DisplayName,
                            SessionTypeName = sess.SessionTypeNavigation!.Text,
                            MinutesOfMeetingId = sess.MinutesOfMeetingId,
                            MinutesOfMeetingDate = sess.MinutesOfMeeting!.CreatedOn,
                            MinutesOfMeetingNumber = sess.MinutesOfMeeting.Number,
                            MinutesOfMeetingStatus = sess.MinutesOfMeeting.Status,
                            CreatedBy = sess.CreatedBy,
                            CreatedByDisplayName = sess.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sess.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            CreatedByUserName = sess.CreatedByNavigation.UserName,
                            CreatedOn = sess.CreatedOn,
                            Deleted = sess.Deleted,
                            DeletedBy = sess.DeletedBy,
                            DeletedByDisplayName = sess.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sess.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            DeletedByUserName = sess.DeletedByNavigation!.UserName,
                            DeletedOn = sess.DeletedOn,
                            UpdatedBy = sess.UpdatedBy,
                            UpdatedByDisplayName = sess.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sess.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            UpdatedByUserName = sess.UpdatedByNavigation!.UserName,
                            UpdatedOn = sess.UpdatedOn,
                        });

            QueryResponseModel<CommissionSessionDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<CommissionSessionDisplayModel> result = new DataSourceResponseModel<CommissionSessionDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => new CommissionSessionDisplayModel()
                {
                    Id = x.Id,
                    ArchiveId = x.ArchiveId,
                    ChairmanId = x.ChairmanId,
                    SecretaryId = x.SecretaryId,
                    SessionDate = x.SessionDate.UtcToLocalTime(),
                    SessionTypeCode = x.SessionTypeCode,
                    ArchiveName = x.ArchiveName,
                    ChairmanDisplayName = x.ChairmanDisplayName,
                    SecretaryDisplayName = x.SecretaryDisplayName,
                    SessionTypeName = x.SessionTypeName,
                    MinutesOfMeetingId = x.MinutesOfMeetingId,
                    MinutesOfMeetingDate = x.MinutesOfMeetingDate.UtcToLocalTime(),
                    MinutesOfMeetingNumber = x.MinutesOfMeetingNumber,
                    MinutesOfMeetingStatus = x.MinutesOfMeetingStatus,
                    CreatedBy = x.CreatedBy,
                    CreatedByDisplayName = x.CreatedByDisplayName,
                    CreatedByUserName = x.CreatedByUserName,
                    CreatedOn = x.CreatedOn.UtcToLocalTime(),
                    Deleted = x.Deleted,
                    DeletedBy = x.DeletedBy,
                    DeletedByDisplayName = x.DeletedByDisplayName,
                    DeletedByUserName = x.DeletedByUserName,
                    DeletedOn = x.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = x.UpdatedBy,
                    UpdatedByDisplayName = x.UpdatedByDisplayName,
                    UpdatedByUserName = x.UpdatedByUserName,
                    UpdatedOn = x.UpdatedOn.UtcToLocalTime(),
                })
            };

            return result;
        }
        public DataSourceResponseModel<CommissionSessionDisplayModel> GetPastSessions(DataSourceRequestModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query = _context.Sessions
                        .Where(sess => sess.SessionDate < DateTime.UtcNow.Date && !sess.Deleted)
                        .OrderByDescending(sess => sess.SessionDate)
                        .Select(sess => new CommissionSessionDisplayModel()
                        {
                            Id = sess.Id,
                            ArchiveId = sess.ArchiveId,
                            ChairmanId = sess.ChairmanId,
                            SecretaryId = sess.SecretaryId,
                            SessionDate = sess.SessionDate,
                            SessionTypeCode = sess.SessionType,
                            ArchiveName = sess.Archive.Name,
                            ChairmanDisplayName = sess.Chairman!.AspNetUserProfileUsers.Where(up => up.UserId == sess.ChairmanId && !up.Deleted).FirstOrDefault().DisplayName,
                            SecretaryDisplayName = sess.Secretary!.AspNetUserProfileUsers.Where(up => up.UserId == sess.SecretaryId && !up.Deleted).FirstOrDefault().DisplayName,
                            SessionTypeName = sess.SessionTypeNavigation!.Text,
                            MinutesOfMeetingId = sess.MinutesOfMeetingId,
                            MinutesOfMeetingDate = sess.MinutesOfMeeting!.CreatedOn,
                            MinutesOfMeetingNumber = sess.MinutesOfMeeting.Number,
                            MinutesOfMeetingStatus = sess.MinutesOfMeeting.Status,
                            CreatedBy = sess.CreatedBy,
                            CreatedByDisplayName = sess.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sess.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            CreatedByUserName = sess.CreatedByNavigation.UserName,
                            CreatedOn = sess.CreatedOn,
                            Deleted = sess.Deleted,
                            DeletedBy = sess.DeletedBy,
                            DeletedByDisplayName = sess.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sess.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            DeletedByUserName = sess.DeletedByNavigation!.UserName,
                            DeletedOn = sess.DeletedOn,
                            UpdatedBy = sess.UpdatedBy,
                            UpdatedByDisplayName = sess.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == sess.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            UpdatedByUserName = sess.UpdatedByNavigation!.UserName,
                            UpdatedOn = sess.UpdatedOn,
                        });

            QueryResponseModel<CommissionSessionDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<CommissionSessionDisplayModel> result = new DataSourceResponseModel<CommissionSessionDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => new CommissionSessionDisplayModel()
                {
                    Id = x.Id,
                    ArchiveId = x.ArchiveId,
                    ChairmanId = x.ChairmanId,
                    SecretaryId = x.SecretaryId,
                    SessionDate = x.SessionDate.UtcToLocalTime(),
                    SessionTypeCode = x.SessionTypeCode,
                    ArchiveName = x.ArchiveName,
                    ChairmanDisplayName = x.ChairmanDisplayName,
                    SecretaryDisplayName = x.SecretaryDisplayName,
                    SessionTypeName = x.SessionTypeName,
                    MinutesOfMeetingId = x.MinutesOfMeetingId,
                    MinutesOfMeetingDate = x.MinutesOfMeetingDate.UtcToLocalTime(),
                    MinutesOfMeetingNumber = x.MinutesOfMeetingNumber,
                    MinutesOfMeetingStatus = x.MinutesOfMeetingStatus,
                    CreatedBy = x.CreatedBy,
                    CreatedByDisplayName = x.CreatedByDisplayName,
                    CreatedByUserName = x.CreatedByUserName,
                    CreatedOn = x.CreatedOn.UtcToLocalTime(),
                    Deleted = x.Deleted,
                    DeletedBy = x.DeletedBy,
                    DeletedByDisplayName = x.DeletedByDisplayName,
                    DeletedByUserName = x.DeletedByUserName,
                    DeletedOn = x.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = x.UpdatedBy,
                    UpdatedByDisplayName = x.UpdatedByDisplayName,
                    UpdatedByUserName = x.UpdatedByUserName,
                    UpdatedOn = x.UpdatedOn.UtcToLocalTime(),
                })
            };

            return result;
        }
        public async Task<OperationResult> GenerateProtocol(SessionGenerateProtocolModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }


            try
            {
                int sessionAgendaItemCount = await _sessionAgendaService.GetSessionAgendaItemCountAsync(model.SessionId!.Value);
                int sessionDecisionCount = await _commissionDecisionService.GetCommissionSessionDecisionCountAsync(model.SessionId!.Value);

                if (sessionAgendaItemCount <= 0 || sessionAgendaItemCount <= 0 || sessionDecisionCount != sessionAgendaItemCount)
                {
                    return OperationResult.Failed(false, _localizer.GetString("NoSessionAgendaItemDecisions").ToString());
                }

                var session = _context.Sessions.Include(x => x.MinutesOfMeeting).Where(s => s.Id == model.SessionId).FirstOrDefault();

                if (session != null && session.MinutesOfMeetingId.HasValue)
                {
                    session.MinutesOfMeeting!.Content = model.Content!;

                    _context.Update(session.MinutesOfMeeting);
                    await _context.SaveAsync("");
                }
                else
                {
                    SessionMinutesOfMeeting sess = new()
                    {
                        Content = model.Content!,
                        Number = model.ProtocolNumber.ToString() ?? "",
                        IsDraft = true,
                        NumberNumeric = model.ProtocolNumber!.Value,
                        Status = MinutesOfMeetingStatus.New
                    };

                    var protocol = await CreateProtocol(sess);

                    if (!protocol.Succeeded)
                    {
                        return OperationResult.Failed($"Occured error creating protocol {model}");
                    }
                    if (protocol.Data != null)
                    {
                        session!.MinutesOfMeetingId = (int?)protocol.Data;

                        _context.Update(session);
                        await _context.SaveAsync("");
                    }
                }

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.Message);
            }
        }
        private async Task<OperationResult> CreateProtocol(SessionMinutesOfMeeting model)
        {
            try
            {
                _context.Add(model);

                await _context.SaveAsync("");

                return OperationResult.Succeed(model.Id);
            }
            catch (Exception ex)
            {
                return OperationResult.Failed(ex.Message);
            }
        }
        public async Task<OperationResult> GetSessionProtocol(int id)
        {
            var content = await _context.SessionMinutesOfMeetings
                .Where(s => s.Id == id)
                .Select(s => new SessionProtocolEditModel()
                {
                    Content = s.Content,
                    Status = s.Status,
                    Id = id,
                    IsDraft = s.IsDraft,
                }).FirstOrDefaultAsync();

            return OperationResult.Succeed(content);
        }
        public async Task<OperationResult> EditSessionProtocolContent(SessionProtocolEditModel model)
        {
            if (model == null)
            {
                return OperationResult.Failed("");
            }

            var result = _context.SessionMinutesOfMeetings.Where(m => m.Id == model.Id).FirstOrDefault();

            if (result == null)
            {
                return OperationResult.Failed("");
            }

            result.Content = model.Content;

            _context.Update(result);
            await _context.SaveAsync($"Succ edit protocol Id:{model.Id}");

            return OperationResult.Success;
        }
        public async Task<OperationResult> SendProtocolForApproval(int sessionsId)
        {
            var tran = await _context.Database.BeginTransactionAsync();
            try
            {
                var minutesOfMeeting = await _context.Sessions
                                        .Where(s => s.Id == sessionsId && !s.Deleted)
                                        .Select(s => s.MinutesOfMeeting)
                                        .SingleOrDefaultAsync();

                if (minutesOfMeeting == null)
                {
                    await tran.RollbackAsync();
                    return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                minutesOfMeeting.IsDraft = false;
                minutesOfMeeting.Status = MinutesOfMeetingStatus.SubmittedForApproval;

                _context.Update(minutesOfMeeting);


                await _context.SessionDecisions
                    .Where(dec => dec.SessionAgenda.SessionId == sessionsId && (!dec.IsDraft.HasValue || dec.IsDraft.Value) && !dec.Deleted)
                    .ForEachAsync(dec => { dec.IsDraft = false; });


                var agendaProcesses = _context.SessionAgenda
                                        .Where(a => a.SessionId == sessionsId && !a.Deleted && !a.Session!.Deleted)
                                        .Select(a => a.Process);

                foreach (var agendaProcess in agendaProcesses)
                {
                    var processStepResult = await UpdateProcesStep(agendaProcess!.ProcessTypeId, agendaProcess.Id, 1, String.Empty);
                    if (!processStepResult.Succeeded)
                    {
                        await tran.RollbackAsync();
                        return processStepResult;
                    }

                    var completePrevTaskResult = await CompletePreviousTask(agendaProcess.Id, 1, agendaProcess!.ProcessTypeId);
                    if (!completePrevTaskResult.Succeeded)
                    {
                        await tran.RollbackAsync();
                        return completePrevTaskResult;
                    }
                }

                //foreach (var agenda in sessionAgendas)
                //{
                //var sessionDecisionIsDraft = _context.SessionDecisions.Where(d => d.SessionAgendaId == agenda!.Id).FirstOrDefault();

                //if (sessionDecisionIsDraft != null)
                //{
                //    sessionDecisionIsDraft.IsDraft = false;

                //    _context.Update(sessionDecisionIsDraft);
                //}

                //if (minutesOfMeeting.Status == MinutesOfMeetingStatus.New)
                //{
                //    var processTypeId = agenda.Process!.ProcessTypeId;

                //    var processId = agenda.Process!.Id;

                //    var res = await UpdateProcesStep(processTypeId, processId, 1);

                //    if (!res.Succeeded)
                //    {
                //        return res;
                //    }
                //}

                //}



                //FIX Защо се взима само един потребител от групата, след като в UI не се дава възможност да се посочи към кого отива за утвърждаване?
                //var sessionArchiveId = await _context.Sessions
                //                        .Where(s => s.Id == sessionsId && !s.Deleted)
                //                        .Select(a => a.ArchiveId)
                //                        .SingleOrDefaultAsync();

                //var archiveDirector = _context.AspNetUsers.Where(m => m.Roles.ToList().Any(r => r.Abbreviation.Contains("G") && r.ArchiveId == sessionArchiveId)).Select(u => u.Id).FirstOrDefault();

                //if (archiveDirector.ToString() != null)
                //{
                //    TaskCreateModel taskModel = new()
                //    {
                //        NotificationType = Shared.NotificationType.SendProtocolForApproval,
                //        EntityType = EntityType.session,
                //        EntityId = sessionsId,
                //        AssignedToUserId = archiveDirector.ToString(),
                //    };

                //    var taskResult = await _taskService.CreateAsync(taskModel);
                //    if (!taskResult.Succeeded)
                //    {
                //        throw new Exception(String.Join("; ", taskResult.Errors));
                //    }
                //}

                var archiveRole = await _context.Sessions
                                    .Where(s => s.Id == sessionsId && !s.Deleted)
                                    .Select(s => s.Archive.AspNetRoles.Where(role => role.Name == ApplicationRoleType.GroupG).SingleOrDefault())
                                    .SingleOrDefaultAsync();
                if (archiveRole == null)
                {
                    await tran.RollbackAsync();
                    return OperationResult.Failed($"{ApplicationRoleType.GroupG} missing for archive in session {sessionsId}");
                }

                TaskCreateModel taskModel = new()
                {
                    NotificationType = Shared.NotificationType.SendProtocolForApproval,
                    EntityType = EntityType.session,
                    EntityId = sessionsId,
                    AssignedToRoleId = archiveRole.Id.ToString("D"),
                };

                var taskResult = await _taskService.CreateAsync(taskModel);
                if (!taskResult.Succeeded)
                {
                    await tran.RollbackAsync();
                    return taskResult;
                }

                await _context.SaveAsync("Minutes of meeting sent for approval");

                await tran.CommitAsync();
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                await tran.RollbackAsync();
                return OperationResult.Failed(exc.ToString());
            }
        }
        private async Task<OperationResult> UpdateProcesStep(int processTypeId, int processId, int stage, string secretarRole, int? archiveId = null, Guid? assignedToUserId = null, Guid? assignedToRoleId = null)
        {
            try
            {
                if (stage == 1)
                {
                    switch (processTypeId)
                    {
                        case (int)Shared.ProcessType.AddInventory:
                        case (int)Shared.ProcessType.AddRawInventory:
                        case (int)Shared.ProcessType.AddRawInventoryToRawFund:
                        case (int)Shared.ProcessType.AddFundAndInventory:
                        case (int)Shared.ProcessType.AddRawFundAndRawInventory:
                        case (int)Shared.ProcessType.AddSystemInventory:
                            await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.ConfirmationProtocolSent);
                            break;
                        case (int)Shared.ProcessType.DeductData:
                            await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.DeductData_ConfirmationProtocolSent);
                            break;
                        case (int)Shared.ProcessType.RefineData:
                            await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.RefineData_SessionMinutesOfMeetingForApproval);
                            break;
                        case (int)Shared.ProcessType.EditFundData:
                            await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.EditFundData_SessionMinutesOfMeetingForApproval);
                            break;
                        case (int)Shared.ProcessType.ReconstructFundData:
                            await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.ReconstructFundData_SessionMinutesOfMeetingForApproval);
                            break;
                        case (int)Shared.ProcessType.ProcessRawFundWithRawInventory:
                            await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.ProcessRawFundWithRawInventory_ConfirmationProtocolSent);
                            break;
                        case (int)Shared.ProcessType.ProcessFundWithRawInventory:
                            await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.ProcessFundWithRawInventory_ConfirmationProtocolSent);
                            break;
                        default:
                            return OperationResult.Failed($"Cannot put step Confirmation-Protocol-Sent on process with id {processId}");
                    }
                }
                else
                {
                    switch (processTypeId)
                    {
                        case (int)Shared.ProcessType.AddInventory:
                        case (int)Shared.ProcessType.AddRawInventory:
                        case (int)Shared.ProcessType.AddRawInventoryToRawFund:
                        case (int)Shared.ProcessType.AddFundAndInventory:
                        case (int)Shared.ProcessType.AddRawFundAndRawInventory:
                        case (int)Shared.ProcessType.AddSystemInventory:
                            //await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.ConfirmedProtocol);
                            await _processService.SetActiveProcessStepAsync(new ProcessStepModel()
                            {
                                ProcessId = processId,
                                StepTypeId = (int)ProcessStepType.ConfirmedProtocol,
                                AssignedToUserId = assignedToUserId,
                                AssignedToRoleId = assignedToRoleId,
                            });
                            break;
                        case (int)Shared.ProcessType.DeductData:
                            await _processService.SetActiveProcessStepAsync(new ProcessStepModel()
                            {
                                ProcessId = processId,
                                StepTypeId = (int)ProcessStepType.DeductData_ConfirmedProtocol,
                                AssignedToRoleId = await _context.AspNetRoles.Where(r => r.ArchiveId == archiveId
                                                         && r.Abbreviation != null && r.Abbreviation.Equals(secretarRole)).Select(r => r.Id).FirstOrDefaultAsync()
                            });
                            break;
                        case (int)Shared.ProcessType.RefineData:
                            await _processService.SetActiveProcessStepAsync(new ProcessStepModel()
                            {
                                ProcessId = processId,
                                StepTypeId = (int)ProcessStepType.RefineData_SessionMinutesOfMeeting,
                                AssignedToUserId = assignedToUserId,
                                AssignedToRoleId = assignedToRoleId,
                            });
                            break;
                        case (int)Shared.ProcessType.EditFundData:
                            await _processService.SetActiveProcessStepAsync(new ProcessStepModel()
                            {
                                ProcessId = processId,
                                StepTypeId = (int)ProcessStepType.EditFundData_SessionMinutesOfMeeting,
                                AssignedToUserId = assignedToUserId,
                                AssignedToRoleId = assignedToRoleId,
                            });
                            break;
                        case (int)Shared.ProcessType.ReconstructFundData:
                            await _processService.SetActiveProcessStepAsync(new ProcessStepModel()
                            {
                                ProcessId = processId,
                                StepTypeId = (int)ProcessStepType.ReconstructFundData_SessionMinutesOfMeeting,
                                AssignedToUserId = assignedToUserId,
                                AssignedToRoleId = assignedToRoleId,
                            });
                            break;
                        case (int)Shared.ProcessType.ProcessRawFundWithRawInventory:
                            // await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.ProcessRawFundWithRawInventory_ConfirmedProtocol);
                            await _processService.SetActiveProcessStepAsync(new ProcessStepModel()
                            {
                                ProcessId = processId,
                                StepTypeId = (int)ProcessStepType.ProcessRawFundWithRawInventory_ConfirmedProtocol,
                                AssignedToUserId = assignedToUserId,
                                AssignedToRoleId = assignedToRoleId,
                            });
                            break;
                        case (int)Shared.ProcessType.ProcessFundWithRawInventory:
                            //await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.ProcessFundWithRawInventory_ConfirmedProtocol);
                            await _processService.SetActiveProcessStepAsync(new ProcessStepModel()
                            {
                                ProcessId = processId,
                                StepTypeId = (int)ProcessStepType.ProcessFundWithRawInventory_ConfirmedProtocol,
                                AssignedToUserId = assignedToUserId,
                                AssignedToRoleId = assignedToRoleId,
                            });
                            break;
                        default:
                            return OperationResult.Failed($"Cannot put step Confirmed-Protocol  on process with id {processId}");
                    }
                }

                return OperationResult.Success;
            }
            catch (Exception ex)
            {
                return OperationResult.Failed(ex.Message);
            }

        }
        public async Task<OperationResult> ApprovalProtocol(int sessionsId)
        {
            var tran = await _context.Database.BeginTransactionAsync();

            try
            {
                string secretarRole = string.Empty;
                var session = _context.Sessions.Include(s => s.MinutesOfMeeting).Where(s => s.Id == sessionsId && !s.Deleted).FirstOrDefault();
                if (session == null)
                {
                    await tran.RollbackAsync();
                    return OperationResult.Failed($"Session {session} does not exists");
                }


                if (session.MinutesOfMeeting == null)
                {
                    await tran.RollbackAsync();
                    return OperationResult.Failed($"Session {sessionsId} minutes of meeting does not exists");
                }
                session.MinutesOfMeeting.Status = MinutesOfMeetingStatus.Approved;

                _context.Update(session.MinutesOfMeeting);
                await _context.SaveAsync("Minutes of meeting approved");

                switch (session!.SessionType)
                {
                    case "1":
                        secretarRole = "V1";
                        break;
                    case "2":
                        secretarRole = "V2";
                        break;
                    case "3":
                        secretarRole = "V3";
                        break;
                    default:
                        break;
                }

                var sessionAgendaProceses =
                    _context.SessionAgenda
                    .Where(a => a.SessionId == sessionsId)
                    .Select(s => s.Process);

                foreach (var process in sessionAgendaProceses)
                {
                    string entityType = string.Empty;
                    Guid entitySystemIden = Guid.Empty;

                    if (process.FundSystemIdentifier.HasValue)
                    {
                        entityType = EntityType.fund;
                        entitySystemIden = process.FundSystemIdentifier.Value;
                    }
                    else if (process.InventorySystemIdentifier.HasValue)
                    {
                        entityType = EntityType.inventory;
                        entitySystemIden = process.InventorySystemIdentifier.Value;
                    }
                    else if (process.ArchivalEntitySystemIdentifier.HasValue)
                    {
                        entityType = EntityType.archivalEntity;
                        entitySystemIden = process.ArchivalEntitySystemIdentifier.Value;
                    }
                    else if (process.DocumentSystemIdentifier.HasValue)
                    {
                        entityType = EntityType.document;
                        entitySystemIden = process.DocumentSystemIdentifier.Value;
                    }

                    //TODO Може би по някакъв начин трябва да се подаде и председателя
                    var processStepResult = await UpdateProcesStep(process!.ProcessTypeId, process.Id, 2, secretarRole, process.ArchiveId, session.SecretaryId!.Value);
                    if (!processStepResult.Succeeded)
                    {
                        await tran.RollbackAsync();
                        return processStepResult;
                    }
                    //FIX Защо няма проверка дали обекта не е null и тогава да се прави задача.
                    var step = _context.ProcessTimelines.Where(t => t.ProcessId == process.Id && !t.Completed).FirstOrDefault();


                    TaskCreateModel taskModelForChairman = new()
                    {
                        StepType = (ProcessStepType)step.StepTypeId,
                        ProcessId = process.Id,
                        TimelineId = step.Id,
                        AssignedToUserId = session.ChairmanId!.Value.ToString("D"),
                        EntityType = entityType,
                        EntitySystemIdentifier = entitySystemIden,
                        StatusCode = Shared.TaskStatus.Pending,
                    };

                    var chairmanTaskResult = await _taskService.CreateAsync(taskModelForChairman);
                    if (!chairmanTaskResult.Succeeded)
                    {
                        await tran.RollbackAsync();
                        return chairmanTaskResult;
                    }

                    TaskCreateModel taskModelForSecretary = new()
                    {
                        StepType = (ProcessStepType)step.StepTypeId,
                        ProcessId = process.Id,
                        TimelineId = step.Id,
                        AssignedToUserId = session.SecretaryId!.Value.ToString("D"),
                        EntityType = entityType,
                        EntitySystemIdentifier = entitySystemIden,
                        StatusCode = Shared.TaskStatus.Pending,
                    };

                    var createTaskModelForChairman = await _taskService.CreateAsync(taskModelForChairman);

                    if (!createTaskModelForChairman.Succeeded)
                    {
                        await tran.RollbackAsync();
                        return createTaskModelForChairman;
                    }

                    TaskCreateModel taskModelForReportCreator = new()
                    {
                        StepType = (ProcessStepType)step.StepTypeId,
                        ProcessId = process.Id,
                        TimelineId = step.Id,
                        AssignedToUserId = process.CreatedBy.ToString(),
                        EntityType = entityType,
                        EntitySystemIdentifier = entitySystemIden,
                        StatusCode = Shared.TaskStatus.Pending,
                    };

                    var createTask = await _taskService.CreateAsync(taskModelForReportCreator);

                    if (!createTask.Succeeded)
                    {
                        await tran.RollbackAsync();
                        return createTask;
                    }


                    var completePrevTaskResult = await _taskService.CompletePreviousTask(ProcessStepType.NoStep, process.Id, Shared.NotificationType.SendProtocolForApproval, sessionsId); 
                    if (!completePrevTaskResult.Succeeded)
                    {
                        await tran.RollbackAsync();
                        return completePrevTaskResult;
                    }
                }

                await tran.CommitAsync();

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                await tran.RollbackAsync();
                return OperationResult.Failed(exc.Message);
            }
        }
        public async Task<OperationResult> UploadProtocolFile(CommissionSessionUploadProtocolModel model)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                if (model == null)
                {
                    throw new ArgumentException(nameof(model));
                }

                if (model.Files != null)
                {
                    FileModel fileModel = await ParseAttachmentAsync(model.Files[0]);

                    var result = await _fileService.CreateFileAsync(fileModel, FileStreamLocation.Adjunct);

                    if (!result.Succeeded)
                    {
                        throw new Exception(result.ToString());
                    }

                    string? filePath = result.Data?.ToString();

                    var sessionMeetingMinutes = await _context.Sessions
                        .Where(s => s.Id == model.SessionId)
                        .Select(x => x.MinutesOfMeeting)
                        .SingleOrDefaultAsync();

                    if (sessionMeetingMinutes == null)
                    {
                        return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                    }

                    if (sessionMeetingMinutes.UncPath != null)
                    {
                        _fileService.DeleteFile(sessionMeetingMinutes.UncPath, FileStreamLocation.Adjunct);

                    }

                    sessionMeetingMinutes.UncPath = filePath;
                    sessionMeetingMinutes.SourceName = model.Files[0].FileName;

                    _context.Update(sessionMeetingMinutes);

                    await _context.SaveAsync($"Minutes of meeting file uploaded");
                }
                await transaction.CommitAsync();

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                await transaction.RollbackAsync();
                return OperationResult.Failed(exc.ToString());
            }
        }
        public async Task<FileModel?> GetFile(int sessionId)
        {
            var minutesOfMeeting = _context.Sessions
                                    .Where(s => s.Id == sessionId)
                                    .Select(s => s.MinutesOfMeeting)
                                    .FirstOrDefault();

            if (String.IsNullOrWhiteSpace(minutesOfMeeting?.UncPath))
            {
                return null;
            }

            var file = await _fileService.GetFileAsync(minutesOfMeeting.UncPath, FileStreamLocation.Adjunct);

            if (file != null)
            {
                file.Name = minutesOfMeeting.SourceName ?? file.Name;
            }

            return file;

        }
        public async Task<OperationResult> RejectProtocol(int sessionsId, string rejectReason)
        {
            var tran = await _context.Database.BeginTransactionAsync();
            try
            {
                var minutesOfMeeting = await _context.Sessions.Where(s => s.Id == sessionsId).Select(s => s.MinutesOfMeeting).FirstOrDefaultAsync();

                var sessionArchiveId = _context.Sessions.Where(s => s.Id == sessionsId).Select(a => a.ArchiveId).FirstOrDefault();

                if (minutesOfMeeting == null)
                {
                    return OperationResult.Failed("");
                }

                if (minutesOfMeeting.Status == MinutesOfMeetingStatus.SubmittedForApproval)
                {
                    minutesOfMeeting.IsDraft = true;
                    minutesOfMeeting.Status = MinutesOfMeetingStatus.Rejected;
                    minutesOfMeeting.RejectReason = rejectReason;

                    _context.Update(minutesOfMeeting);

                    var sessionAgendas = _context.SessionAgenda.Where(a => a.SessionId == sessionsId);

                    foreach (var agenda in sessionAgendas)
                    {
                        var sessionDecisionIsDraft = _context.SessionDecisions.Where(d => d.SessionAgendaId == agenda!.Id).FirstOrDefault();
                        if (sessionDecisionIsDraft != null)
                        {
                            sessionDecisionIsDraft.IsDraft = true;

                            _context.Update(sessionDecisionIsDraft);
                        }
                    }

                    /*   TaskCreateModel taskModel = new()
                       {
                           StepType = Shared.ProcessStepType.DeductData_ConfirmationProtocolSent,
                           EntityType = Shared.EntityType.session,
                           EntityId = sessionsId,
                           AssignedToUserId = "E149E081-8EFB-4DC7-E1FD-08DA7F9ABA00"
                           //sessionAgendas.Select(s => s.Session.AssignedToChairmanId).ToString(),
                       };

                       await _taskService.CreateAsync(taskModel);*/

                    await _context.SaveAsync("");
                }

                await tran.CommitAsync();

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                await tran.RollbackAsync();
                return OperationResult.Failed(exc.Message);
            }
        }
        public async Task<OperationResult> GetProtocolData(SessionProtocolEditModel incumModel)
        {
            try
            {
                SessionProtocolDataModel model = new();

                model.Members = new List<string>();
                model.StandPointsData = new List<StandPoint>();
                model.StandPointsDecision = new List<StandPointDecision>();
                model.ProtocolNumber = 1;
                model.CurrentDate = DateTime.Now;
                int index = 1;
                string sessionDecision = string.Empty;
                string directorName = string.Empty;
                string assignedToChairmanName = string.Empty;
                string assignedToSecretarName = string.Empty;
                string deadLineDate = string.Empty;

                Dictionary<string, string> points_Titles = new();
                Dictionary<string, string> points_ReporterInfo = new();
                Dictionary<string, string> points_Decisions = new();
                Dictionary<string, string> points_DeadLine = new();


                var session = _context.Sessions.Include(x => x.SessionTypeNavigation).Where(s => s.Id == incumModel.Id).FirstOrDefault();

                var maxNumber = _context.Sessions
                    .Where(t =>
                    t.SessionDate.Year == session!.SessionDate!.Year
                    && t.ArchiveId == session!.ArchiveId
                    && !t.Deleted
                    && t.SessionType == session.SessionType)
                    .Select(x => x.MinutesOfMeeting.NumberNumeric).DefaultIfEmpty().Max();


                var archiveDirector = _context.AspNetUsers.Include(u => u.AspNetUserProfileUsers).Where(m => m.Roles.Any(r => r.Abbreviation.Contains("G") && r.ArchiveId == session.ArchiveId)).FirstOrDefault();
                model.ArchiveName = _context.Archives.Where(a => a.Id == session!.ArchiveId).Select(a => a.Name).FirstOrDefault() ?? "";
                model.SessionTypeName = session?.SessionTypeNavigation?.Text ?? "";

                if (archiveDirector != null)
                {
                    model.DirectorName = archiveDirector.AspNetUserProfileUsers.Where(up => up.UserId == archiveDirector.Id && !up.Deleted).FirstOrDefault().DisplayName ?? "";
                }

                model.ProtocolNumber = maxNumber + 1;

                if (session != null)
                {
                    if (session.MinutesOfMeetingId != null)
                    {
                        model.ProtocolNumber = _context.SessionMinutesOfMeetings.Where(m => m.Id == session.MinutesOfMeetingId).Select(m => m.NumberNumeric).FirstOrDefault();
                    }
                    model.AssignedToChairmanName = _context.AspNetUserProfiles.Where(u => u.UserId == session.ChairmanId).Select(u => u.DisplayName).FirstOrDefault() ?? "";
                    model.AssignedToSecretarName = _context.AspNetUserProfiles.Where(u => u.UserId == session.SecretaryId).Select(u => u.DisplayName).FirstOrDefault() ?? "";
                }
                if (session!.SessionType == "1")
                {
                    var members = _context.AspNetUsers.Where(m => m.Roles.ToList().Any(r => r.Abbreviation.Contains("V4"))).Select(m => m.AspNetUserProfileUsers);

                    foreach (var item in members)
                    {
                        string displayName = item.Select(t => t.DisplayName).FirstOrDefault() ?? "";
                        string jobTitle = item.Select(t => t.JobTitle).FirstOrDefault() ?? "";
                        string department = item.Select(t => t.Department).FirstOrDefault() ?? "";

                        if (item.Select(i => i.Id).FirstOrDefault() > 0)
                        {
                            if (String.IsNullOrEmpty(department) && String.IsNullOrEmpty(jobTitle))
                            {
                                model.Members.Add($"{displayName}");
                            }
                            else if (!String.IsNullOrEmpty(jobTitle))
                            {
                                model.Members.Add($"{displayName} {jobTitle}");
                            }
                            else if (!String.IsNullOrEmpty(department))
                            {
                                model.Members.Add($"{displayName} {department}");
                            }
                            else
                            {
                                model.Members.Add($"{displayName} {jobTitle} {department}");
                            }
                        }
                    }
                }
                else if (session.SessionType == "2")
                {
                    var members = _context.AspNetUsers.Where(m => m.Roles.ToList().Any(r => r.Abbreviation.Contains("V5"))).Select(m => m.AspNetUserProfileUsers);

                    foreach (var item in members)
                    {
                        string displayName = item.Select(t => t.DisplayName).FirstOrDefault() ?? "";
                        string jobTitle = item.Select(t => t.JobTitle).FirstOrDefault() ?? "";
                        string department = item.Select(t => t.Department).FirstOrDefault() ?? "";

                        if (item.Select(i => i.Id).FirstOrDefault() > 0)
                        {
                            model.Members.Add($"{displayName} {jobTitle} {department}");
                        }
                    }
                }
                else if (session.SessionType == "3")
                {
                    var members = _context.AspNetUsers.Where(m => m.Roles.ToList().Any(r => r.Abbreviation.Contains("V6"))).Select(m => m.AspNetUserProfileUsers);

                    foreach (var item in members)
                    {
                        string displayName = item.Select(t => t.DisplayName).FirstOrDefault() ?? "";
                        string jobTitle = item.Select(t => t.JobTitle).FirstOrDefault() ?? "";
                        string department = item.Select(t => t.Department).FirstOrDefault() ?? "";

                        if (item.Select(i => i.Id).FirstOrDefault() > 0)
                        {
                            model.Members.Add($"{displayName} {jobTitle} {department}");
                        }

                    }
                }

                var procesesInSession = _context.SessionAgenda.Where(s => s.SessionId == incumModel.Id && !s.Deleted).Select(s => s.Process);

                if (incumModel.StandPointIds!.Length > 0)
                {
                    var processes = _context.SessionAgenda.Where(s => incumModel.StandPointIds.Contains(s.Id)).Select(s => s.Process);

                    procesesInSession = processes;
                }

                foreach (var item in procesesInSession)
                {
                    string fundNumber = string.Empty;
                    string inventoryNumber = string.Empty;
                    string fundTitle = string.Empty;
                    string approxmateChronologicalScope = string.Empty;
                    string displayName = string.Empty;
                    string jobTitle = string.Empty;
                    string department = string.Empty;

                    if (item.FundSystemIdentifier != null)
                    {
                        var fund = _context.VFunds.Where(f => f.SystemIdentifier == item.FundSystemIdentifier).FirstOrDefault();
                        fundNumber = fund.Number ?? "";
                        fundTitle = fund.Title ?? "";
                        approxmateChronologicalScope = fund.ApproxmateChronologicalScope ?? "";
                    }
                    else if (item.InventorySystemIdentifier != null)
                    {
                        var inventory = _context.VInventories.Where(i => i.SystemIdentifier == item.InventorySystemIdentifier).FirstOrDefault();
                        if (inventory != null)
                        {
                            inventoryNumber = inventory.Number ?? "";
                            fundNumber = inventory.FundNumber ?? "";
                            var res = _context.VFunds.Where(f => f.SystemIdentifier == inventory.FundSystemIdentifier).FirstOrDefault();
                            fundTitle = res.Title ?? "";
                            approxmateChronologicalScope = res.ApproxmateChronologicalScope ?? "";
                        }
                    }
                    else if (item.ArchivalEntitySystemIdentifier != null)
                    {
                        var arch = _context.VArchivalEntities.Where(i => i.SystemIdentifier == item.ArchivalEntitySystemIdentifier).FirstOrDefault();
                        if (arch != null)
                        {
                            inventoryNumber = arch.InventoryNumber ?? "";
                            fundNumber = arch.FundNumber ?? "";
                            var res = _context.VFunds.Where(f => f.SystemIdentifier == arch.FundSystemIdentifier).FirstOrDefault();
                            fundTitle = res.Title ?? "";
                            approxmateChronologicalScope = res.ApproxmateChronologicalScope ?? "";
                        }
                    }
                    else if (item.DocumentSystemIdentifier != null)
                    {
                        var doc = _context.VDocuments.Where(i => i.SystemIdentifier == item.DocumentSystemIdentifier).FirstOrDefault();
                        if (doc != null)
                        {
                            inventoryNumber = doc.InventoryNumber ?? "";
                            fundNumber = doc.FundNumber ?? "";
                            var res = _context.VFunds.Where(f => f.SystemIdentifier == doc.FundSystemIdentifier).FirstOrDefault();
                            fundTitle = res.Title ?? "";
                            approxmateChronologicalScope = res.ApproxmateChronologicalScope ?? "";
                        }
                    }

                    var report = _context.Epkreports.Where(e => e.ProcessId == item.Id).FirstOrDefault();

                    var reportStandPoints = _context.SessionAgendaStandpoints
                        .Include(c => c.CreatedByNavigation)
                        .Include(l => l.Comments)
                        .Where(l => l.ReportId == report!.Id);

                    List<ReportStandpoint> reportStandPointsList = new List<ReportStandpoint>();

                    if (reportStandPoints != null)
                    {
                        foreach (var r in reportStandPoints)
                        {

                            ReportStandpoint list = new()
                            {
                                Index = $"{index}" ?? null,
                            };
                            if (r.Comments.Any())
                            {
                                string a = r.Comments.FirstOrDefault()?.Text ?? "";

                                if (a != null)
                                {
                                    list.CommentText = a;
                                }
                            }
                            else
                            {
                                list.CommentText = "";
                            }

                            if (r.Comments.FirstOrDefault()?.CreatedByNavigation != null)
                            {
                                list.ReportCreatorDisplayName = r.Comments.FirstOrDefault()?.CreatedByNavigation?.AspNetUserProfileUsers.Where(up => up.UserId == r.Comments.FirstOrDefault().CreatedBy && !up.Deleted).FirstOrDefault().DisplayName ?? "";
                            }
                            else
                            {
                                list.ReportCreatorDisplayName = report?.CreatedByNavigation?.AspNetUserProfileUsers.Where(up => up.UserId == report.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName ?? string.Empty;
                            }

                            if (r.Content != null)
                            {
                                list.StandpointText = r.Content ?? "";
                            }
                            if (r.CreatedByNavigation != null)
                            {
                                list.StandPointTextCreatorDisplayName = r.CreatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == r.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName ?? "";
                            }

                            reportStandPointsList.Add(list);
                        }
                    }

                    var currUser = _context.AspNetUserProfiles.Where(u => u.UserId == report!.CreatedBy).FirstOrDefault() ?? null;

                    if (currUser == null)
                    {
                        var user = _context.AspNetUsers.Where(u => u.Id == report!.CreatedBy).FirstOrDefault();

                        displayName = "";
                        jobTitle = "";
                        department = "";
                    }

                    if (currUser != null)
                    {
                        displayName = currUser.DisplayName ?? "";
                        jobTitle = currUser.JobTitle ?? "";
                        department = currUser.Department ?? "";
                    }

                    model.StandPointsData.Add(new StandPoint()
                    {
                        Department = department,
                        DisplayName = displayName,
                        JobTitle = jobTitle,
                        FundNumber = fundNumber,
                        FundTitle = fundTitle,
                        Index = index,
                        InventoryNumber = inventoryNumber,
                        ReportStandpoint = reportStandPointsList,
                    });

                    int agendaId = _context.SessionAgenda.Where(d => d.ProcessId == item.Id && d.SessionId == incumModel.Id && !d.Deleted).Select(d => d.Id).FirstOrDefault();

                    var decision = await _context.SessionDecisions.Where(d => d.SessionAgendaId == agendaId).FirstOrDefaultAsync();

                    if (decision != null && decision.DecisionText != null)
                    {
                        sessionDecision = decision.DecisionText;
                    }
                    if (decision != null && decision.DeadlineForApproval != null)
                    {
                        deadLineDate = DateOnly.FromDateTime(decision.DeadlineForApproval.Value).ToString();
                    }


                    points_Titles.Add($"{index}", $"Ф.№ {fundNumber}, инв. оп.№ {inventoryNumber} {fundTitle}");
                    points_Decisions.Add($"{index}", sessionDecision);
                    points_ReporterInfo.Add($"{index}", $"Докладва: {displayName} {jobTitle} {department}");
                    points_DeadLine.Add($"{index}", deadLineDate);

                    index++;
                }

                foreach (var item in points_Titles)
                {
                    model.StandPointsDecision.Add(new StandPointDecision()
                    {
                        Index = item.Key ?? "",
                        Title = item.Value ?? "",
                        Decision = points_Decisions.Where(d => d.Key.Equals(item.Key)).First().Value ?? "",
                        ReporterInfo = points_ReporterInfo.Where(d => d.Key.Equals(item.Key)).First().Value ?? "",
                        DeadLine = points_DeadLine.Where(d => d.Key.Equals(item.Key)).First().Value ?? "",
                    });
                }
                return OperationResult.Succeed(model);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.Message);
            }
        }
        public async Task<OperationResult> EditSessionAgendaList(SessionReportEditListModel model)
        {
            if (model.ProcessIdsForRemove != null)
            {
                foreach (var processId in model.ProcessIdsForRemove)
                {
                    var agendaForRemove = _context.SessionAgenda.Where(s => s.ProcessId == processId).FirstOrDefault();

                    if (agendaForRemove != null)
                    {
                        _context.SessionAgenda.Remove(agendaForRemove);
                        await _context.SaveAsync("Session agenda item removed");
                    }
                }
            }

            if (model.ProcessIdsForAppending != null)
            {
                foreach (var processId in model.ProcessIdsForAppending)
                {
                    var report = _context.Epkreports.Where(p => p.ProcessId == processId).FirstOrDefault();

                    if (report != null)
                    {
                        SessionAgendaItemModel agenda = new()
                        {
                            SessionId = model.SessionId!.Value,
                            ProcessId = processId,
                            ReportId = report.Id,
                        };

                        await _sessionAgendaService.CreateSessionAgendaItemInternalAsync(agenda);
                    }
                    else return OperationResult.Failed();

                }
            }
            return OperationResult.Success;
        }


        private async Task<OperationResult> CompletePreviousTask(int processId, int stage, int processTypeId)
        {
            try
            {
                ProcessStepType prevStep = ProcessStepType.NoStep;

                if (stage == 1) // изпратен за утвърждаване протокол 
                {
                    switch (processTypeId)
                    {
                        case (int)Shared.ProcessType.AddInventory:
                        case (int)Shared.ProcessType.AddRawInventory:
                        case (int)Shared.ProcessType.AddRawInventoryToRawFund:
                        case (int)Shared.ProcessType.AddFundAndInventory:
                        case (int)Shared.ProcessType.AddRawFundAndRawInventory:
                        case (int)Shared.ProcessType.AddSystemInventory:
                            prevStep = ProcessStepType.CommissionOpinions;
                            break;
                        //case (int)Shared.ProcessType.DeductData:
                        //    break;
                        case (int)Shared.ProcessType.RefineData:
                            prevStep = ProcessStepType.RefineData_CommissionSession;
                            break;
                        case (int)Shared.ProcessType.EditFundData:
                            prevStep = ProcessStepType.EditFundData_CommissionSession;
                            break;
                        case (int)Shared.ProcessType.ReconstructFundData:
                            prevStep = ProcessStepType.ReconstructFundData_CommissionSession;
                            break;
                        //case (int)Shared.ProcessType.ProcessRawFundWithRawInventory:
                        //    break;
                        //case (int)Shared.ProcessType.ProcessFundWithRawInventory:
                        //    break;
                        default:
                            prevStep = ProcessStepType.NoStep;
                            break;
                    }
                }

                OperationResult completeTaskResult = await _taskService.CompletePreviousTask(prevStep, processId, null, null);
                return completeTaskResult;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }
    }
}
