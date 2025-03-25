using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.FileUploadApp
{
    public class MastersForDocumentResultModel : OperationResultModel
    {
        public CodeNameModel[] Items { get; set; } = null!;
    }
}
