
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Extensions.Exceptions
{
    [Serializable]
    public class ItemDraftNotCurrentException : Exception
    {
        public string? Identifier { get; }

        public ItemDraftNotCurrentException()
        {
        }

        public ItemDraftNotCurrentException(string message)
            : base(message)
        {
        }

        public ItemDraftNotCurrentException(string message, Exception inner)
            : base(message, inner)
        {
        }

        public ItemDraftNotCurrentException(string message, string identifier)
            : this(message)
        {
            Identifier = identifier;
        }
    }
}
