using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class VArchivalEntitySizeInfo
    {
        public Guid ArchivalEntitySystemIdentifier { get; set; }
        public Guid InventorySystemIdentifier { get; set; }
        public Guid FundSystemIdentifier { get; set; }
        public int ArchivalEntityAvailabilityStatusCode { get; set; }
        public int EnrolledArchivalEntity { get; set; }
        public int DeductedArchivalEntity { get; set; }
        public int EnrolledDocumentCount { get; set; }
        public int DeductedDocumentCount { get; set; }
        public long EnrolledBytes { get; set; }
        public long DeductedBytes { get; set; }
        public int EnrolledDuration { get; set; }
        public int DeductedDuration { get; set; }
        public string? FileTypes { get; set; }
        public int IsDraft { get; set; }
        public int TextDocsCount { get; set; }
        public int GraphicalDocsCount { get; set; }
    }
}
