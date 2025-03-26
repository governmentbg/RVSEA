using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Extensions.Exceptions
{
    public class FileTypeNotSupportedException : Exception
    {
        public string? FileType { get; }
        public FileTypeNotSupportedException()
        {
        }

        public FileTypeNotSupportedException(string message)
            : base(message)
        {
        }

        public FileTypeNotSupportedException(string message, Exception inner)
            : base(message, inner)
        {
        }

        public FileTypeNotSupportedException(string message, string fileType)
            : this(message)
        {
            FileType = fileType;
        }
    }
}
