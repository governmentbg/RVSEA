using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Extensions.Exceptions
{
    [Serializable]
    public class SystemIdentifierNullException : Exception
    {
        
        public SystemIdentifierNullException()
        {
        }

        public SystemIdentifierNullException(string message)
            : base(message)
        {
        }

        public SystemIdentifierNullException(string message, Exception inner)
            : base(message, inner)
        {
        }
    }
}
