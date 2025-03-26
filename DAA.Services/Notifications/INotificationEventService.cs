using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Models;
using DAA.Models.Notifications;
using DAA.Shared.Hubs;
using DAA.Shared;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DAA.Data;

namespace DAA.Services.Notifications
{

    public interface INotificationEventService
    {
        Task<int> AddNotificationEvent(int objectId, string notificationType, Guid? assignedToRoleId, Guid? assignedToUserId);
        Task<List<NotificationEvent>> GetUncheckedNotifications(string notificationType);
        void MarkEventsAsChecked(List<NotificationEvent> events);
    }
}
