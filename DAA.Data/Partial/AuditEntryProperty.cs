using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Data
{
    public partial class AuditEntryProperty
    {
        public static AuditEntryProperty From(Z.EntityFramework.Plus.AuditEntryProperty property)
        {
            return new AuditEntryProperty
            {
                RelationName = property.RelationName,
                PropertyName = property.PropertyName,
                OldValue = property.OldValueFormatted,
                NewValue = property.NewValueFormatted,
                IsKey = property.IsKey
            };
        }
    }
}
