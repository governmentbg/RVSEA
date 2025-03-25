using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Shared.Certificates
{
    public class ParseResult
    {
        public ParseResult()
        {
            Errors = new List<string>();
            Success = false;
        }

        public bool Success { get; set; }
        public string HolderName { get; set; }
        public string HolderEGN { get; set; }
        public string HolderEIK { get; set; }
        public string HolderEmail { get; set; }
        public string IssuerName { get; set; }
        public List<string> Errors { get; set; }
    }
}
