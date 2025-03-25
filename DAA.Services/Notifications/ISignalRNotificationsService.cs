using DAA.Data;

namespace DAA.Services.Notifications
{
    public interface ISignalRNotificationsService
    {
        System.Threading.Tasks.Task Send(IList<Notification> notifications);
    }
}
