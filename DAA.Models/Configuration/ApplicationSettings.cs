using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Configuration
{
    public class ApplicationSettings
    {
        public const string Name = "Application";
        public string? Version { get; set; }
        public string? Uri { get; set; }
        public string? UriInternal { get; set; }
        public string? UriExternal { get; set; }
    }
}
