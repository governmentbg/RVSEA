using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class ArchivesSpecificOrder
    {
        public int Id { get; set; }
        public int ArchiveId { get; set; }
        public int? SortOrder { get; set; }

        public virtual Archive Archive { get; set; } = null!;
    }
}
