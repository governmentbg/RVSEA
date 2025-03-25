using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Configuration
{
    public class EmailTokenSettings
    {
        public const string Name = "EmailTokenConfig";
        public int ExpirationHours { get; set; }
    }
}
