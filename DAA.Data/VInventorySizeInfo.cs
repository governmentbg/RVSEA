using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class VInventorySizeInfo
    {
        public Guid InventorySystemIdentifier { get; set; }
        public Guid FundSystemIdentifier { get; set; }
        public int InventoryAvailabilityStatusCode { get; set; }
        public int EnrolledInventory { get; set; }
        public int DeductedInventory { get; set; }
        public int EnrolledArchivalEntityCount { get; set; }
        public int DeductedArchivalEntityCount { get; set; }
        public int EnrolledDocumentCount { get; set; }
        public int DeductedDocumentCount { get; set; }
        public long EnrolledBytes { get; set; }
        public long DeductedBytes { get; set; }
        public string? FileTypes { get; set; }
        public int IsDraft { get; set; }
        public int IsNormalInventory { get; set; }
        public int? TextDocsCount { get; set; }
        public int? GraphicalDocsCount { get; set; }
    }
}
