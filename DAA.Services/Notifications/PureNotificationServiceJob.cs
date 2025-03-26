using DAA.Data;
using DAA.Shared.Localization;
using Hangfire;
using Microsoft.Extensions.Localization;

namespace DAA.Services.Notifications
{
    public class PureNotificationServiceJob : BaseService, IPureNotificationServiceJob
    {
        private readonly INotificationPureService _service;
        public PureNotificationServiceJob(ArchivingContext context,
            INotificationPureService service,
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
            await _service.NotifyEventsAsync(Shared.NotificationType.RejectedApplication);
            await _service.NotifyEventsAsync(Shared.NotificationType.ApprovedApplication);
            await _service.NotifyEventsAsync(Shared.NotificationType.AddApplicationPackages);
            await _service.NotifyEventsAsync(Shared.NotificationType.ApprovedApplicationPackages);
            await _service.NotifyEventsAsync(Shared.NotificationType.RejectedApplicationPackages);
            await _service.NotifyEventsAsync(Shared.NotificationType.ModifyApplicationPackages);
            await _service.NotifyEventsAsync(Shared.NotificationType.RequestModification);
            await _service.NotifyEventsAsync(Shared.NotificationType.ModificationApplied);
            await _service.NotifyEventsAsync(Shared.NotificationType.RequestSignature);
            await _service.NotifyEventsAsync(Shared.NotificationType.SignedDocuments);
            await _service.NotifyEventsAsync(Shared.NotificationType.RedirectedApplication);
        }
    }
}
