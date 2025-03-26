using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class VFundSizeInfo
    {
        public Guid FundSystemIdentifier { get; set; }
        public int EnrolledInventoryCount { get; set; }
        public int DeductedInventoryCount { get; set; }
        public int EnrolledArchivalEntityCount { get; set; }
        public int DeductedArchivalEntityCount { get; set; }
        public int EnrolledDocumentCount { get; set; }
        public int DeductedDocumentCount { get; set; }
        public long EnrolledBytes { get; set; }
        public long DeductedBytes { get; set; }
        public string? FileTypes { get; set; }
        public int IsDraft { get; set; }
    }
}
