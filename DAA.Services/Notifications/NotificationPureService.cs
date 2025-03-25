using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Models.Configuration;
using DAA.Shared;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Task = System.Threading.Tasks.Task;

namespace DAA.Services.Notifications
{
    public class NotificationPureService : BaseService, INotificationPureService
    {
        private readonly ApplicationSettings _appSettings;
        private readonly INotificationService _notificationService;
        private readonly INotificationEventService _notificationEventService;
        //protected readonly ILogger<NotificationTaskService> _logger;

        public NotificationPureService(ArchivingContext context,
            INotificationService notificationService,
            INotificationEventService notificationEventService,
            IOptions<ApplicationSettings> appSettings,
            IStringLocalizer<SharedResources> localizer,
            ILogger<NotificationTaskService> logger)
            : base(context, localizer, logger)
        {
            _appSettings = appSettings.Value;
            _notificationService = notificationService;
            _notificationEventService = notificationEventService;
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

            string[] allowedTypes = new string[]
            {
                Shared.NotificationType.NewApplication,
                Shared.NotificationType.RejectedApplication,
                Shared.NotificationType.ApprovedApplication,
                Shared.NotificationType.AssignedApplication,
                Shared.NotificationType.AddApplicationPackages,
                Shared.NotificationType.ApprovedApplicationPackages,
                Shared.NotificationType.RejectedApplicationPackages,
                Shared.NotificationType.ModifyApplicationPackages,
                Shared.NotificationType.RequestModification,
                Shared.NotificationType.ModificationApplied,
                Shared.NotificationType.RequestSignature,
                Shared.NotificationType.SignedDocuments,
                Shared.NotificationType.RedirectedApplication,
            };


            if (!allowedTypes.Contains(notificationType))
            {
                _logger.LogInformation($"Notification type {notificationType} is not supported!");
                _notificationEventService.MarkEventsAsChecked(events);
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

            List<EdocsCollectingApplication> applications = new List<EdocsCollectingApplication>();
            if (allowedTypes.Contains(notificationType))
            {
                applications = await _context.EdocsCollectingApplications
                    .Include(x => x.TypeNavigation)
                    .Include(x => x.DocumentsOriginTypeNavigation)
                    .Include(x => x.PackageA)
                    .Include(x => x.PackageB)
                    .Include(x => x.RedirectApplication).ThenInclude(a => a.Archive)
                    .Where(x => objectIds.Contains(x.Id) && !x.Deleted)
                    .ToListAsync();
            }

            if (!applications.Any())
            {
                _logger.LogInformation($"No applications found!");
                _notificationEventService.MarkEventsAsChecked(events);
                return;
            }

            List<Guid> userIds = events
                .Where(x => x.AssignedToRoleId != null && x.AssignedToRole!.Users.Any())
                .SelectMany(x => x.AssignedToRole!.Users)
                .Select(x => x.Id)
                .Distinct()
                .ToList();

            var assignedUsers = events
                .Where(x => x.AssignedToUserId != null)
                .Select(x => x.AssignedToUserId!.Value)
                .Distinct()
                .ToList();
            
            if (assignedUsers.Any())
            {
                userIds.AddRange(assignedUsers);
            }

            List<AspNetUser> users = await _context.AspNetUsers
                .Include(x => x.Roles)
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
                        EdocsCollectingApplication app = applications
                                .Where(x => x.Id == ev.ObjectId)
                                .First();
                        List<AspNetUser> usersForApp = new List<AspNetUser>();
                        if (ev.AssignedToRoleId != null)
                        {
                            usersForApp.AddRange(users
                                .Where(x => x.Roles.Where(r => r.Id == ev.AssignedToRoleId).Any())
                                .ToList());
                        }
                        if (ev.AssignedToUserId != null && !usersForApp.Select(x => x.Id == ev.AssignedToUserId).Any())
                        {
                            usersForApp.Add(users
                                .Where(x => x.Id == ev.AssignedToUserId)
                                .First());
                        }

                        foreach (var userToNotify in usersForApp)
                        {
                            Notification notif = CreateNotification(ev, template, app, userToNotify);
                            notifications.Add(notif);
                        }
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
        }



        private Notification CreateNotification(NotificationEvent ev, NotificationTemplate template, EdocsCollectingApplication application, AspNetUser user)
        {
            Notification notification = _notificationService.CreateNotification(template, user, ev.Id);

            //string baseUrl = _appSettings.Uri!;
            //string line = $"<p><a href='{baseUrl}/edocscollection/applications/display/{application.Id}' target='_blank'>{application.TypeNavigation.Text}</a></p>";

            notification.Body = notification.Body!.Replace(TemplateKeyphrase.ApplicationType, application.TypeNavigation.Text);
            notification.Body = notification.Body.Replace(TemplateKeyphrase.DocumentsOrigin, application.DocumentsOriginTypeNavigation != null ? application.DocumentsOriginTypeNavigation.Text : String.Empty);
            notification.Body = notification.Body.Replace(TemplateKeyphrase.DocumentsOwner, application.DocumentsOwner ?? String.Empty);
            notification.Body = notification.Body.Replace(TemplateKeyphrase.ApplicantFullName, application.ApplicantFullName);
            notification.Body = notification.Body.Replace(TemplateKeyphrase.ApplicantEmail, application.ApplicantEmail);

            notification.Body = notification.Body.Replace(TemplateKeyphrase.ApplicationNumber, application.Number.ToString());
            notification.Body = notification.Body.Replace(TemplateKeyphrase.ApplicationDate, application.CreatedOn != null ? application.CreatedOn.Value.UtcToLocalTime().ToString("dd.MM.yyyy г.") : String.Empty);
            notification.Body = notification.Body.Replace(TemplateKeyphrase.ApplicationRejectReason, application.RejectReason);
            //string packagesRejectReason = String.Join("; ", new[] { application.PackageA!.RejectReason, application.PackageB!.RejectReason });
            notification.Body = notification.Body.Replace(TemplateKeyphrase.ApplicationPackageRejectReason, application.PackageB != null ? application.PackageB.RejectReason : String.Empty);
            notification.Body = notification.Body.Replace(TemplateKeyphrase.RedirectArchiveName, application.RedirectApplication != null ? application.RedirectApplication.Archive.Name : String.Empty);

            notification.Body = notification.Body.Replace(TemplateKeyphrase.Comment, application.ModificationReason);

            return notification;
        }

    }
}
