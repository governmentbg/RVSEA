using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class AspNetUserArchive
    {
        public Guid UserId { get; set; }
        public int ArchiveId { get; set; }
        public bool? Inactive { get; set; }

        public virtual Archive Archive { get; set; } = null!;
        public virtual AspNetUser User { get; set; } = null!;
    }
}
