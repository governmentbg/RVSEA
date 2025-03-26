using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class ProcessTypeLevel
    {
        public int ProcessTypeId { get; set; }
        public string EntityType { get; set; } = null!;
        public bool Inactive { get; set; }

        public virtual ProcessType ProcessType { get; set; } = null!;
    }
}
