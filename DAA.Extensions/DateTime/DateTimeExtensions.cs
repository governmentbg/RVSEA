using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Extensions.DateTime
{
    public static class DateTimeExtensions
    {
        public static System.DateTime UtcToLocalTime(this System.DateTime dateTime)
        {
            return System.DateTime.SpecifyKind(dateTime, DateTimeKind.Utc);
        }

        public static System.DateTime? UtcToLocalTime(this System.DateTime? dateTime)
        {
            return dateTime.HasValue ? System.DateTime.SpecifyKind(dateTime.Value, DateTimeKind.Utc) : default(System.DateTime?);
        }
    }
}
