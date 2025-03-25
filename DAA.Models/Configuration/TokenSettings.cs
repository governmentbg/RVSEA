using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Configuration
{
    public class TokenSettings
    {
        public const string Name = "TokenConfig";
        public string? Secret { get; set; }
        public string? Issuer { get; set; }
        public string? Audience { get; set; }
        public int ExpirationHours { get; set; }
    }
}
