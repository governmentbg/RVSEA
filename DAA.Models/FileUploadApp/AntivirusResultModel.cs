using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.FileUploadApp
{
    public class AntivirusResultModel : OperationResultModel
    {

        public bool? AntivirusEngineAvailable { get; set; }
        public string? EngineInfo { get; set; }

        public bool? Checked { get; set; }
        public bool? IsVirus { get; set; }
        public string? VirusInfo { get; set; }
    }
}
