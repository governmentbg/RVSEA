using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.FileUploadApp
{
    public class AddToQueueResultModel : OperationResultModel
    {
        public int Id { get; set; }
        public string DbFileName { get; set; } = null!;
    }
}
