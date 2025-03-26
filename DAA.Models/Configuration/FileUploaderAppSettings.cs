using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Configuration
{
    public class FileUploaderAppSettings
    {
        public const string Name = "FileUploaderApp";
        public string? FolderPath { get; set; }
        public string? FileName { get; set; }
        public string? FileName32bit { get; set; }
        public bool VerifyChecksum { get; set; }
        public bool ScanWithAntivirus { get; set; } = false;
        public bool ScanWithAntivirusClientApp { get; set; } = false;


        public bool ValidateFile { get; set; } = false;

        public bool ValidateXml { get; set; } = false;
        public bool ValidateHtml { get; set; } = false;
        public bool ValidatePdf { get; set; } = false;
        public bool ValidateMsX { get; set; } = false;
        public bool ValidateImage { get; set; } = false;
        public bool ValidateVideo { get; set; } = false;
        public bool ValidateAudio { get; set; } = false;
    }
}
