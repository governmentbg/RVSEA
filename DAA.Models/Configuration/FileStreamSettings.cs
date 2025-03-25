using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Configuration
{
    public class FileStreamSettings
    {
        public const string Name = "FileStreamConfig";
        
        public FileStreamConfiguration? Files { get; set; }
        public FileStreamConfiguration? AdjunctFiles { get; set; }
        public FileStreamConfiguration? BufferFiles { get; set; }
        public FileStreamConfiguration? MasterFiles { get; set; }  
    }
    public class FileStreamConfiguration
    {
        public string? DbName { get; set; }
        public string? UncPath { get; set; }
        public FileStreamCredential? Reader { get; set; }
        public FileStreamCredential? Writer { get; set; }
    }

    public class FileStreamCredential
    {
        public string? Domain { get; set; }
        public string? Username { get; set; }
        public string? Password { get; set; }
    }

}
