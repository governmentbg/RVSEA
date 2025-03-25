using DAA.Models.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.FileUploadApp
{
    public class AuthorizeResultModel : OperationResultModel
    {
        public bool CanQueueKmf { get; set; }
        public bool CanQueueFund { get; set; }
        public FileUploaderAppSettings AppSettings { get; set; } = null!;
    }
}
