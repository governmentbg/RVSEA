using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Models;
using DAA.Models.Notifications;
using DAA.Services.Interfaces;
using DAA.Shared;
using DAA.Shared.Hubs;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Task = System.Threading.Tasks.Task;

namespace DAA.Services.Notifications
{
    public class NotificationService : BaseService, INotificationService
    {
        private readonly IEmailService _emailService;
        protected readonly ILogger<NotificationService> _logger;

        public NotificationService(ArchivingContext context,
            IEmailService emailService,
            IStringLocalizer<SharedResources> localizer,
            ILogger<NotificationService> logger)
            : base(context, localizer)
        {
            _emailService = emailService;
            _logger = logger;
        }

        public NotificationDataSourceResponseModel<NotificationViewModel> GetAllForUser(DataSourceRequestModel model, Guid? userId)
        {
            var query = _context.Notifications
                .Where(x => x.ToUserId == userId)
                .OrderByDescending(x => x.Id)
                .AsNoTracking()
                .AsQueryable();

            QueryResponseModel<Notification> queryResponse = query.SortAndFilter(model);
            NotificationDataSourceResponseModel<NotificationViewModel> result = new NotificationDataSourceResponseModel<NotificationViewModel>
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => x.ToViewModel()).ToList()
            };

            result.TotalUnseen = query.Where(x => x.IsSeen == false).Count();

            return result;
        }

        public async Task<OperationResult> MarkAsSeen(int id)
        {
            try
            {
                var notification = await _context.Notifications
                .SingleAsync(n => n.Id == id);

                notification.IsSeen = true;
                await _context.SaveChangesAsync();
                return OperationResult.Succeed(id);
            }
            catch (Exception ex)
            {
                return OperationResult.Failed(ex.ToString());
            }            
        }

        public async Task<List<UINotificationModel>> GetUnseenNotifications(Guid? userId)
        {
            var result = await _context.Notifications
                .Where(x => x.ToUserId == userId && !x.IsSeen)
                .Select(x => new UINotificationModel
                {
                    Id = x.Id,
                    UserId = userId
                })
                .ToListAsync();

            return result;
        }

        public Notification CreateNotification(NotificationTemplate template, AspNetUser user, int? eventId)
        {
            Notification notification = new Notification();
            notification.NotificationTemplateId = template.Id;
            notification.ToUserId = user.Id;
            notification.To = user.Email!;
            notification.Subject = template.Subject;
            notification.Body = template.Body;
            notification.CreatedOn = DateTime.UtcNow;
            notification.EventId = eventId;

            return notification;
        }


        public async Task SendNotificationsAsync(string notificationType)
        {
            var notifications = await _context.Notifications
                .Where(n => !n.IsSent && n.EventId != null && n.Event.NotificationTypeCode == notificationType)
                .ToListAsync();

            if (!notifications.Any())
            {
                return;
            }

            _logger.LogInformation($"sending {notifications.Count} {notificationType} notifications");

            try
            {
                foreach (var msg in notifications)
                {
                    _emailService.SendEmail(msg.To, null!, null!, msg.Subject!, msg.Body!);
                    msg.IsSent = true;
                    msg.SentOn = DateTime.UtcNow;
                    await _context.SaveChangesAsync();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"ERROR sending notifications");
                throw;
            }
        }
    }
}
