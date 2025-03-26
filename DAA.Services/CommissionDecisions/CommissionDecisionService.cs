using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Models.Commission;
using DAA.Models.File;
using DAA.Services.Files;
using DAA.Shared;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;

namespace DAA.Services.CommissionDecisions
{
    public class CommissionDecisionService : BaseService, ICommissionDecisionService
    {
        private readonly IFileService _fileService;
        public CommissionDecisionService(
            ArchivingContext context,
            IFileService fileService,
            IStringLocalizer<SharedResources> localizer)
            : base(context, localizer)
        {
            _fileService = fileService;
        }

        public async Task<CommissionDecisionDisplayModel?> GetByIdAsync(int id)
        {
            var decision = await _context.SessionDecisions
                .Where(dec => dec.Id == id && !dec.Deleted)
                .Select(dec => new CommissionDecisionDisplayModel()
                {
                    Id = dec.Id,
                    SessionAgendaId = dec.SessionAgendaId,
                    DeadlineForApproval = dec.DeadlineForApproval,
                    DecisionText = dec.DecisionText,
                    MinutesOfMeetingDate = dec.SessionAgenda.Session!.MinutesOfMeeting!.CreatedOn.UtcToLocalTime(),
                    MinutesOfMeetingNumber = dec.SessionAgenda.Session.MinutesOfMeeting.Number,
                    CreatedBy = dec.CreatedBy,
                    CreatedByDisplayName = dec.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == dec.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = dec.CreatedByNavigation.UserName,
                    CreatedOn = dec.CreatedOn.UtcToLocalTime(),
                    UpdatedBy = dec.UpdatedBy,
                    MinutesOfMeetingHasFile = dec.SessionAgenda.Session.MinutesOfMeeting.UncPath != null ? true : false,
                    UpdatedByDisplayName = dec.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == dec.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = dec.UpdatedByNavigation.UserName,
                    UpdatedOn = dec.UpdatedOn.UtcToLocalTime(),
                }).SingleOrDefaultAsync();

            return decision;
        }
        public async Task<CommissionDecisionDisplayModel?> GetBySessionAgendaIdAsync(int sessionAgendaId)
        {
            var decision = await _context.SessionDecisions
                .Where(dec => dec.SessionAgendaId == sessionAgendaId && !dec.Deleted)
                .Select(dec => new CommissionDecisionDisplayModel()
                {
                    Id = dec.Id,
                    SessionAgendaId = dec.SessionAgendaId,
                    DeadlineForApproval = dec.DeadlineForApproval,
                    DecisionText = dec.DecisionText,
                    MinutesOfMeetingDate = dec.SessionAgenda.Session!.MinutesOfMeeting!.CreatedOn.UtcToLocalTime(),
                    MinutesOfMeetingNumber = dec.SessionAgenda.Session.MinutesOfMeeting.Number,
                    CreatedBy = dec.CreatedBy,
                    CreatedByDisplayName = dec.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == dec.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = dec.CreatedByNavigation.UserName,
                    CreatedOn = dec.CreatedOn.UtcToLocalTime(),
                    UpdatedBy = dec.UpdatedBy,
                    MinutesOfMeetingHasFile = dec.SessionAgenda.Session.MinutesOfMeeting.UncPath != null ? true : false,
                    UpdatedByDisplayName = dec.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == dec.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = dec.UpdatedByNavigation.UserName,
                    UpdatedOn = dec.UpdatedOn.UtcToLocalTime(),
                }).SingleOrDefaultAsync();

            return decision;
        }
        public async Task<CommissionDecisionDisplayModel?> GetByProcessIdAsync(int processId)
        {
           
            var decision = await _context.SessionDecisions
                .Where(dec => dec.SessionAgenda.ProcessId == processId && !dec.Deleted)
                .Select(dec => new CommissionDecisionDisplayModel()
                {
                    Id = dec.Id,
                    SessionAgendaId = dec.SessionAgendaId,
                    DeadlineForApproval = dec.DeadlineForApproval,
                    DecisionText = dec.DecisionText,
                    MinutesOfMeetingDate = dec.SessionAgenda.Session!.MinutesOfMeeting!.CreatedOn.UtcToLocalTime(),
                    MinutesOfMeetingNumber = dec.SessionAgenda.Session.MinutesOfMeeting.Number,
                    CreatedBy = dec.CreatedBy,
                    MinutesOfMeetingHasFile = dec.SessionAgenda.Session.MinutesOfMeeting.UncPath!= null ? true : false,
                    CreatedByDisplayName = dec.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == dec.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = dec.CreatedByNavigation.UserName,
                    CreatedOn = dec.CreatedOn.UtcToLocalTime(),
                    UpdatedBy = dec.UpdatedBy,
                    IsDraft = dec.IsDraft.Value,
                    UpdatedByDisplayName = dec.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == dec.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = dec.UpdatedByNavigation.UserName,
                    UpdatedOn = dec.UpdatedOn.UtcToLocalTime(),
                }).SingleOrDefaultAsync();

         

            return decision;
        }
        public IQueryable<CommissionDecisionDisplayModel> GetBySessionId(int sessionId)
        {
            var decisions = _context.SessionDecisions
                .Where(dec => dec.SessionAgenda.SessionId == sessionId && !dec.Deleted)
                .Select(dec => new CommissionDecisionDisplayModel()
                {
                    Id = dec.Id,
                    SessionAgendaId = dec.SessionAgendaId,
                    DecisionText = dec.DecisionText,
                    DeadlineForApproval = dec.DeadlineForApproval,
                    MinutesOfMeetingDate = dec.SessionAgenda.Session!.MinutesOfMeeting!.CreatedOn.UtcToLocalTime(),
                    MinutesOfMeetingNumber = dec.SessionAgenda.Session.MinutesOfMeeting.Number,
                    CreatedBy = dec.CreatedBy,
                    CreatedByDisplayName = dec.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == dec.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = dec.CreatedByNavigation.UserName,
                    CreatedOn = dec.CreatedOn.UtcToLocalTime(),
                    UpdatedBy = dec.UpdatedBy,
                    MinutesOfMeetingHasFile = dec.SessionAgenda.Session.MinutesOfMeeting.UncPath != null ? true : false,
                    UpdatedByDisplayName = dec.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == dec.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = dec.UpdatedByNavigation.UserName,
                    UpdatedOn = dec.UpdatedOn.UtcToLocalTime(),
                });

            return decisions;
        }
        public async Task<OperationResult> CreateDecisionAsync(CommissionDecisionModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {   
                var decision = new SessionDecision()
                {
                    SessionAgendaId = model.SessionAgendaId,
                    DecisionText = model.DecisionText,
                    DeadlineForApproval = model.DeadlineForApproval,
                };

                _context.SessionDecisions.Add(decision);
                await _context.SaveAsync("Commission decision created");

                return OperationResult.Succeed(decision.Id);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }
        public async Task<OperationResult> UpdateDecisionAsync(CommissionDecisionModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {
                var decision = await _context.SessionDecisions.FindAsync(model.Id);
                if (decision == null)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                decision.DecisionText = model.DecisionText;
                decision.DeadlineForApproval = model.DeadlineForApproval;
                
                _context.Update(decision);
                await _context.SaveAsync("Commission decision updated");

                return OperationResult.Succeed(decision.Id);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }
        public async Task<OperationResult> CreateOrUpdate(CommissionDecisionModel model)
        {
            if (model.Id != null)
            {
                var currentDecision = _context.SessionDecisions.Where(d => d.Id == model.Id).FirstOrDefault();

                currentDecision.DecisionText = model.DecisionText;
                //currentDecision.ProtocolNumber = model.ProtocolNumber;
                currentDecision.DeadlineForApproval = model.DeadlineForApproval;
                //currentDecision.ProtocolDate = model.ProtocolDate;

                _context.SessionDecisions.Update(currentDecision);
               await _context.SaveAsync("Sucesfully updated epk decision");

                return OperationResult.Succeed(currentDecision.Id);
            }
            else
            {
                SessionDecision decision = new()
                {
                    //ProtocolDate = model.ProtocolDate,
                    DeadlineForApproval = model.DeadlineForApproval,
                    DecisionText = model.DecisionText,
                    //ProtocolNumber = model.ProtocolNumber,
                    SessionAgendaId = model.SessionAgendaId,
                };

                _context.SessionDecisions.Add(decision);
                await _context.SaveAsync("Sucesfully added new epk decision");

                return OperationResult.Succeed(decision.Id);
            }
        }
        public async Task<OperationResult?> GetById(int id)
        {
            var model = await _context.SessionDecisions
                .Where(d => d.Id == id)
                .Select(d => new CommissionDecisionDisplayModel()
                {
                    Id = d.Id,
                    DeadlineForApproval = d.DeadlineForApproval,
                    DecisionText = d.DecisionText,
                    MinutesOfMeetingDate = d.SessionAgenda.Session!.MinutesOfMeeting!.CreatedOn.UtcToLocalTime(),
                    MinutesOfMeetingNumber = d.SessionAgenda.Session.MinutesOfMeeting.Number,
                    MinutesOfMeetingHasFile = d.SessionAgenda.Session.MinutesOfMeeting.UncPath != null ? true : false,
                }).FirstOrDefaultAsync();
            if (model == null)
            {
                return OperationResult.Failed($"Occured error with get session decision id:{id}");
            }

            return OperationResult.Succeed(model);
        }
        public async Task<FileModel?> GetFile(int agendaId)
        {
            var attachedFilePath = _context.SessionAgenda
                                    .Where(s => s.Id == agendaId)
                                    .Select(s => s.Session.MinutesOfMeeting.UncPath)
                                    .FirstOrDefault();

            if (String.IsNullOrWhiteSpace(attachedFilePath))
            {
                return null;
            }

            var file = await _fileService.GetFileAsync(attachedFilePath, FileStreamLocation.Adjunct);

            return file;

        }

        public async Task<int> GetCommissionSessionDecisionCountAsync(int sessionId)
        {
            var decisionCount = await _context.SessionDecisions
                                    .Where(dec => dec.SessionAgenda.SessionId == sessionId && !dec.Deleted)
                                    .CountAsync();
            return decisionCount;
        }
    }
}
