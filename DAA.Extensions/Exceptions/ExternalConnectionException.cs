using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Extensions.Exceptions
{
    public class ExternalConnectionException : Exception
    {
        public ExternalConnectionException()
        {
        }

        public ExternalConnectionException(string message)
            : base(message)
        {
        }

        public ExternalConnectionException(string message, Exception inner)
            : base(message, inner)
        {
        }
    }
}
