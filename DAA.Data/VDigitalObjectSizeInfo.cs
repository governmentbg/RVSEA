using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class VDigitalObjectSizeInfo
    {
        public Guid DosystemIdentifier { get; set; }
        public Guid DocumentSystemIdentifier { get; set; }
        public Guid ArchivalEntitySystemIdentifier { get; set; }
        public Guid InventorySystemIdentifier { get; set; }
        public Guid FundSystemIdentifier { get; set; }
        public int TypeCode { get; set; }
        public string FileType { get; set; } = null!;
        public int IsDraft { get; set; }
    }
}
