using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.FileUploadApp
{
    public class ListQueueResultModel : OperationResultModel
    {
        public QueueItemModel[] Items { get; set; } = null!;
    }
}
