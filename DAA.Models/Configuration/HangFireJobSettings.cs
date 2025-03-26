using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Configuration
{
    public class HangFireJobSettings
    {
        public const string Name = "HangFireJobSettings";
        public int? TaskNotificationJobMinutesInterval { get; set; }
        public int? PureNotificationJobMinutesInterval { get; set; }
    }
}
