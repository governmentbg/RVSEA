using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class ProcDocType
    {
        public ProcDocType()
        {
            PackageDocuments = new HashSet<PackageDocument>();
        }

        public int Id { get; set; }
        public string Type { get; set; } = null!;
        public bool Required { get; set; }
        public int ProcType { get; set; }

        public virtual ICollection<PackageDocument> PackageDocuments { get; set; }
    }
}
