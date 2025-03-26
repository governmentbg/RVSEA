using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.FileUploadApp
{
    public class UploadProgressModel
    {
        public int Id { get; set; }
        public long Position { get; set; }
        public JobStatus Status { get; set; }
    }
}
