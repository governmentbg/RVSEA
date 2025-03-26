using System;
using System.Collections.Generic;

namespace DAA.Data.Files
{
    public partial class File
    {
        public string FileId { get; set; } = null!;
        public string FileName { get; set; } = null!;
        public string FileType { get; set; } = null!;
        public string ContentType { get; set; } = null!;
        public byte[] Content { get; set; } = null!;
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
    }
}
