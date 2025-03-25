using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Services.Notifications
{
    public interface INotificationPureService
    {
        Task NotifyEventsAsync(string notificationType);
    }
}
