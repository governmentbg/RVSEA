using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Shared.Hubs
{
    public interface INotificationsHub
    {
        Task SendNotifications(List<UINotificationModel> notifications);
    }
}
