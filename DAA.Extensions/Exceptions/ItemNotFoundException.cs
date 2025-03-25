using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Extensions.Exceptions
{
    [Serializable]
    public class ItemNotFoundException :Exception
    {
        public string? Identifier { get; }

        public ItemNotFoundException()
        {
        }

        public ItemNotFoundException(string message)
            : base(message)
        {
        }

        public ItemNotFoundException(string message, Exception inner)
            : base(message, inner)
        {
        }

        public ItemNotFoundException(string message, string identifier)
            : this(message)
        {
            Identifier = identifier;
        }
    }
}
