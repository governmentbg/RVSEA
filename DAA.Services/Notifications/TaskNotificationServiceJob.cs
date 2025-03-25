using DAA.Data;
using DAA.Shared.Localization;
using Hangfire;
using Microsoft.Extensions.Localization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Services.Notifications
{
    public class TaskNotificationServiceJob : BaseService, ITaskNotificationServiceJob
    {
        private readonly INotificationTaskService _service;
        public TaskNotificationServiceJob(ArchivingContext context,
            INotificationTaskService service,
            IStringLocalizer<SharedResources> localizer = null)
            : base(context, localizer)
        {
            _service = service;
        }

        public async System.Threading.Tasks.Task Run(IJobCancellationToken token)
        {
            token.ThrowIfCancellationRequested();
            await RunAtTimeOf(DateTime.UtcNow);
        }

        public async System.Threading.Tasks.Task RunAtTimeOf(DateTime now)
        {
            await _service.NotifyEventsAsync(Shared.NotificationType.NewTask);
            //await _service.NotifyEventsAsync(Shared.NotificationType.CompletedTask);
            //await _service.NotifyEventsAsync(Shared.NotificationType.CancelledTask);
        }
    }
}
