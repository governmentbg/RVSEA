using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class VDigitalObjectsRawSizeInfo
    {
        public Guid FundSystemIdentifier { get; set; }
        public string? FundStatusCode { get; set; }
        public Guid InventorySystemIdentifier { get; set; }
        public string? InvStatusCode { get; set; }
        public Guid ArchivalEntitySystemIdentifier { get; set; }
        public string? AestatusCode { get; set; }
        public Guid DocumentSystemIdentifier { get; set; }
        public string? DocStatusCode { get; set; }
        public Guid SystemIdentifier { get; set; }
        public string FileType { get; set; } = null!;
        public long FileSize { get; set; }
        public int IsDraft { get; set; }
    }
}
