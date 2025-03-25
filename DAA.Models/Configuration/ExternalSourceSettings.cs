using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Configuration
{
    public class ExternalSourceSettings
    {
        public const string Name = "ExternalSourceSettings";
        public string? FileDownloadBaseUrl { get; set; }
        public string? ImageGalleryBaseUrl { get; set; }
        public string? ImageGalleryServiceBaseUrl { get; set; }
    }
}
