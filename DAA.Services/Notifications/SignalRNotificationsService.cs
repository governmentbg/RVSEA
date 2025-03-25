using DAA.Data;
using DAA.Models.Notifications;
using DAA.Shared.Hubs;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Localization;
using Newtonsoft.Json;
using Serilog;
using UINotificationModel = DAA.Shared.Hubs.UINotificationModel;

namespace DAA.Services.Notifications
{
    public class SignalRNotificationsService : BaseService, ISignalRNotificationsService
    {
        private readonly IHubContext<NotificationsHub, INotificationsHub> _hubContext;

        public SignalRNotificationsService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IHubContext<NotificationsHub, INotificationsHub> hubContext)
            : base(context, localizer)
        {
            _hubContext = hubContext;
        }

        public async System.Threading.Tasks.Task Send(IList<Notification> newNotifications)
        {
            List<UINotificationModel> notifications = newNotifications
                .Select(x => new UINotificationModel
                {
                    Id = x.Id,
                    UserId = x.ToUserId
                })
                .ToList();

            List<string> userIds = notifications
                .Select(x => x.UserId.Value.ToString())
                .Distinct()
                .ToList();

            Log.Information("Send UI notifications: ");
            notifications.ForEach(x =>
            {
                var data = JsonConvert.SerializeObject(x);
                Log.Information(data);
            });


            await _hubContext
                .Clients
                .Users(userIds)
                .SendNotifications(notifications);

            Log.Information("UI notifications are sent");
        }
    }
}
