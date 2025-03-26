using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class InventoryRawToNormal
    {
        public int ArchiveId { get; set; }
        public Guid FundSystemIdentifier { get; set; }
        public Guid RawInventorySystemIdentifier { get; set; }
        public Guid? NormalInventorySystemIdentifier { get; set; }
        public int? ProcessId { get; set; }
        public bool IsRejected { get; set; }
        public int Id { get; set; }

        public virtual Archive Archive { get; set; } = null!;
        public virtual Process? Process { get; set; }
    }
}
