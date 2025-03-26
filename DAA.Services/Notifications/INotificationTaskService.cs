
namespace DAA.Services.Notifications
{
    public interface INotificationTaskService
    {
        Task NotifyEventsAsync(string notificationType);
    }
}
