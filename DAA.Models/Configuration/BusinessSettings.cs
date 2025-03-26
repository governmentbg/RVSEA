using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Configuration
{
    public class BusinessSettings
    {
        public const string Name = "BusinessConfig";
        public int? CentralArchiveCode { get; set; }
        public string LibreOfficeExePath { get; set; } = @"C:\\Program Files\\LibreOffice\\program\\soffice.exe";
    }
}
