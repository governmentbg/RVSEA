using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Models;
using DAA.Models.Notifications;
using DAA.Shared.Hubs;
using DAA.Shared.Localization;
using DAA.Shared;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Services.Notifications
{
    public class NotificationEventService : BaseService, INotificationEventService
    {
        public NotificationEventService(ArchivingContext context,
            IStringLocalizer<SharedResources> localizer)
            : base(context, localizer)
        {
        }

        public async Task<int> AddNotificationEvent(int objectId, string notificationType, Guid? assignedToRoleId, Guid? assignedToUserId)
        {
            NotificationEvent entity = new NotificationEvent
            {
                ObjectId = objectId,
                NotificationTypeCode = notificationType,
                AssignedToRoleId = assignedToRoleId,
                AssignedToUserId = assignedToUserId,

            };
            await _context.NotificationEvents.AddAsync(entity);
            await _context.SaveChangesAsync();
            return entity.Id;
        }

        public async Task<List<NotificationEvent>> GetUncheckedNotifications(string notificationType)
        {
            List<NotificationEvent> events = await _context.NotificationEvents
                .Include(x => x.AssignedToRole).ThenInclude(a => a.Users)
                .Where(x => x.NotificationTypeCode == notificationType && !x.IsChecked)
                .ToListAsync();

            return events;
        }

        public void MarkEventsAsChecked(List<NotificationEvent> events)
        {
            events.ForEach(x => x.IsChecked = true);
            events.ForEach(x => x.CheckedOn = DateTime.UtcNow);
            _context.NotificationEvents.UpdateRange(events);
            _context.SaveChanges();
        }

    }
}
