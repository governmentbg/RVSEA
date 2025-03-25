using DAA.Data;
using DAA.Services.Process;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Transactions;

namespace DAA.Services.CommissionSessions
{
    public class SessionMinutesOfMeetingService : BaseService, ISessionMinutesOfMeetingService
    {
        private readonly IUserInfo _userInfo;
        private readonly IProcessService _processService;

        public SessionMinutesOfMeetingService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IUserInfo userInfo,
            IProcessService processService)
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _processService = processService;
        }


        public async Task<OperationResult> SetMinutesOfMeetingAsync(int sessionId)
        {
            var transaction = _context.Database.BeginTransaction();
            try
            {
                var minutesOfMeeting = await _context.Sessions
                                        .Where(sess => sess.Id == sessionId && !sess.Deleted)
                                        .Select(sess => sess.MinutesOfMeeting)
                                        .SingleOrDefaultAsync();
                if (minutesOfMeeting == null)
                {
                    transaction.Rollback();
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                minutesOfMeeting.IsDraft = false;
                _context.Update(minutesOfMeeting);

                await _context.SessionDecisions
                    .Where(dec => dec.SessionAgenda.Session!.Id == sessionId && !dec.Deleted)
                    .Select(dec => dec)
                    .ForEachAsync(dec => { dec.IsDraft = false; });

                await _context.SaveAsync("Minutes of meeting updated");

                transaction.Commit();
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> SendForApprovalAsync(int sessionId)
        {
            try
            {
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }
    }
}
