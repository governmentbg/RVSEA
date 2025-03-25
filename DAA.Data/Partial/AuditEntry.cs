using DAA.Shared.Identity;
using DAA.Shared.Security;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Data
{
    public partial class AuditEntry
    {
        public static AuditEntry From(Z.EntityFramework.Plus.AuditEntry entry, IUserInfo userInfo,
            DbContextId dbContextId, string description)
        {
            if (entry == null) throw new ArgumentNullException(nameof(entry), nameof(Z.EntityFramework.Plus.AuditEntry));

            AuditEntry customAuditEntry = new AuditEntry
            {
                EntitySetName = entry.EntitySetName,
                EntityTypeName = entry.EntityTypeName,
                State = (int)entry.State,
                StateName = entry.StateName,
                //Ip = userInfo?.ClientIp,
                CreatedBy = (!userInfo.CurrentUserId.HasValue || userInfo.CurrentUserId.Value == Guid.Empty) ? AnonymousSystemUser.Id : userInfo.CurrentUserId.Value,
                CreatedByUsername = userInfo?.CurrentUserUsername ?? AnonymousSystemUser.Username,
                CreatedOn = DateTime.UtcNow,
                CorrelationId = dbContextId.InstanceId.ToString(),
                Lease = dbContextId.Lease,
                Description = description,
            };

            customAuditEntry.AuditEntryProperties = entry.Properties
                .Select(x => AuditEntryProperty.From(x))
                .Where(x => x.OldValue != x.NewValue)
                .ToList();

            return customAuditEntry;
        }

        public static AuditEntry From(Z.EntityFramework.Plus.AuditEntry entry, DbContext context, string? description)
        {
            if (entry == null) throw new ArgumentNullException(nameof(entry), nameof(Z.EntityFramework.Plus.AuditEntry));

            AuditEntry customAuditEntry = new AuditEntry
            {
                EntitySetName = entry.EntitySetName,
                EntityTypeName = entry.EntityTypeName,
                State = (int)entry.State,
                StateName = entry.StateName,
                //Ip = userInfo?.ClientIp,
                CreatedBy = 
                    (!(context as ArchivingContext)!.UserInfo.CurrentUserId.HasValue 
                        || (context as ArchivingContext)!.UserInfo.CurrentUserId!.Value == Guid.Empty) 
                    ? AnonymousSystemUser.Id 
                    : (context as ArchivingContext)!.UserInfo.CurrentUserId!.Value,
                CreatedByUsername = (context as ArchivingContext)!.UserInfo.CurrentUserUsername ?? AnonymousSystemUser.Username,
                CreatedOn = DateTime.UtcNow,
                CorrelationId = context.ContextId.InstanceId.ToString(),
                Lease = context.ContextId.Lease,
                Description = description,
            };

            customAuditEntry.AuditEntryProperties = entry.Properties
                .Select(x => AuditEntryProperty.From(x))
                .Where(x => x.OldValue != x.NewValue)
                .ToList();

            return customAuditEntry;
        }
    }
}
