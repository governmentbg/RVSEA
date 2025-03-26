using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Shared
{
    public class ResponseResult
    {
        public bool Success { get; set; }
        public int Code { get; set; }
        public string? Message { get; set; }
        public bool ShowMessage { get; set; } = false;
    }

    public class ResponseResult<T>
    {
        public bool Success { get; set; }
        public int Code { get; set; }
        public string? Message { get; set; }
        public bool ShowMessage { get; set; } = false;
        public T? Data { get; set; }
    }
}
