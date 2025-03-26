using DAA.Data;
using DAA.Models.Configuration;
using DAA.Services.Interfaces;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Task = System.Threading.Tasks.Task;

namespace DAA.Services.Notifications
{
    public class NotificationTaskService : BaseService, INotificationTaskService
    {
        private readonly ApplicationSettings _appSettings;
        private readonly IEmailService _emailService;
        private readonly ISignalRNotificationsService _signalRNotificationsService;
        private readonly INotificationService _notificationService;
        private readonly INotificationEventService _notificationEventService;
        protected readonly ILogger<NotificationTaskService> _logger;

        public NotificationTaskService(ArchivingContext context,
            IEmailService emailService,
            ISignalRNotificationsService signalRNotificationsService,
            INotificationService notificationService,
            INotificationEventService notificationEventService,
            IOptions<ApplicationSettings> appSettings,
            IStringLocalizer<SharedResources> localizer,
            ILogger<NotificationTaskService> logger)
            : base(context, localizer)
        {
            _appSettings = appSettings.Value;
            _emailService = emailService;
            _signalRNotificationsService = signalRNotificationsService;
            _notificationService = notificationService;
            _notificationEventService = notificationEventService;
            _logger = logger;
        }

        public async Task NotifyEventsAsync(string notificationType)
        {
            try
            {
                _logger.LogInformation($"Generating {notificationType} notifications started ..");
                await GenerateNotificationsAsync(notificationType);
                _logger.LogInformation($"Generating {notificationType} notifications finished");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"ERROR in generating {notificationType} notifications");
            }


            // separate try-catch so that error in generating notifications does not prevent sending notifications
            try
            {
                _logger.LogInformation($"Sending {notificationType} notifications started ..");
                await _notificationService.SendNotificationsAsync(notificationType);
                _logger.LogInformation($"Sending {notificationType} notifications finished");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"ERROR in sending {notificationType} notifications");
            }
        }

        private async Task GenerateNotificationsAsync(string notificationType)
        {
            List<NotificationEvent> events = await _notificationEventService.GetUncheckedNotifications(notificationType);

            if (!events.Any())
            {
                _logger.LogInformation($"No events for {notificationType}");
                return;
            }

            var template = await _context.NotificationTemplates
                .Where(x => x.NotificationTypeCode == notificationType)
                .FirstOrDefaultAsync();

            if (template == null)
            {
                _logger.LogInformation($"No template found for {notificationType}");
                _notificationEventService.MarkEventsAsChecked(events);
                return;
            }

            List<int> objectIds = events.Select(x => x.ObjectId).ToList();
            List<Data.Task> tasks = await _context.Tasks
                .Where(x => objectIds.Contains(x.Id) && !x.Deleted)
                .ToListAsync();

            if (!tasks.Any())
            {
                _logger.LogInformation($"No tasks found!");
                _notificationEventService.MarkEventsAsChecked(events);
                return;
            }

            List<Guid> userIds = tasks.Select(x => x.AssignedToUserId).ToList();
            userIds.AddRange(tasks.Where(x => x.CreatedBy.HasValue).Select(x => x.CreatedBy.Value).ToList());
            List<AspNetUser> users = new List<AspNetUser>();
            users = await _context.AspNetUsers
                .Where(x => userIds.Contains(x.Id) && !x.Deleted)
                .ToListAsync();

            if (!users.Any())
            {
                _logger.LogInformation($"No users found!");
                _notificationEventService.MarkEventsAsChecked(events);
                return;
            }

            List<Notification> notifications = new List<Notification>();
            using (var tran = _context.Database.BeginTransaction())
            {
                try
                {
                    foreach (var ev in events)
                    {
                        Data.Task task = tasks.Where(x => x.Id == ev.ObjectId).First();
                        AspNetUser user = users.Where(x => x.Id == task.AssignedToUserId).First();
                        if (ev.NotificationTypeCode == Shared.NotificationType.CompletedTask)
                        {
                            user = users.Where(x => x.Id == task.CreatedBy!.Value).First();
                        }

                        Notification notif = CreateNotification(ev, template, task, user);
                        notifications.Add(notif);
                    }

                    _context.Notifications.AddRange(notifications);
                    _context.SaveChanges();
                    _notificationEventService.MarkEventsAsChecked(events);

                    await tran.CommitAsync();
                }
                catch (Exception ex)
                {
                    await tran.RollbackAsync();
                    _logger.LogError(ex, $"ERROR creating {notificationType} notifications");
                    throw;
                }
            }


            try
            {
                if (notifications.Count > 0)
                {
                    await _signalRNotificationsService.Send(notifications);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"ERROR signalling for created notifications");
            }
        }

        
        private Notification CreateNotification(NotificationEvent ev, NotificationTemplate template, Data.Task task, AspNetUser user)
        {
            Notification notification = _notificationService.CreateNotification(template, user, ev.Id);

            string baseUrl = _appSettings.Uri!;
            string line = $"<p><a href='{baseUrl}/tasks/display/{task.Id}' target='_blank'>{task.Title}</a></p>";

            notification.Body = notification.Body!.Replace("#taskUrl#", line);

            return notification;
        }

    }
}
