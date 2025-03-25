using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Models.Notifications;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Extensions.Models
{
    public static class NotificationExtensions
    {
        public static NotificationViewModel ToViewModel(this Notification entity)
        {
            if (entity == null)
            {
                return null;
            }

            NotificationViewModel model = new NotificationViewModel
            {
                Id = entity.Id,
                ToUserId = entity.ToUserId,
                To = entity.To,
                Subject = entity.Subject,
                Body = entity.Body,
                CreatedOn = entity.CreatedOn.UtcToLocalTime(),
                SentOn = entity.SentOn.HasValue ? entity.SentOn.UtcToLocalTime() : null,
                IsSeen = entity.IsSeen,
                IsSent = entity.IsSent,
            };

            return model;
        }


    }
}
