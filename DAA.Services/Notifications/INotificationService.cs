
using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Models;
using DAA.Models.Notifications;
using DAA.Shared;
using DAA.Shared.Hubs;
using Task = System.Threading.Tasks.Task;

namespace DAA.Services.Notifications
{
    public interface INotificationService
    {
        NotificationDataSourceResponseModel<NotificationViewModel> GetAllForUser(DataSourceRequestModel model, Guid? userId);
        Task<OperationResult> MarkAsSeen(int id);
        Task<List<UINotificationModel>> GetUnseenNotifications(Guid? userId);
        Notification CreateNotification(NotificationTemplate template, AspNetUser user, int? eventId);
        Task SendNotificationsAsync(string notificationType);
    }
}
