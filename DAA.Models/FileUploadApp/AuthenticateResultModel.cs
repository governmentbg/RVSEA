using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.FileUploadApp
{
    public class AuthenticateResultModel : OperationResultModel
    {
        public AuthenticateResultDataModel? Data { get; set; }
    }
    public class AuthenticateResultDataModel
    {
        public string? Token { get; set; }
        public DateTime TokenExpiration { get; set; }
        public string? Name { get; set; }
        public bool IsAdmin { get; set; }
        public string? ProfileType { get; set; }
    }
}
