using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class VDocumentSizeInfo
    {
        public Guid DocumentSystemIdentifier { get; set; }
        public Guid ArchivalEntitySystemIdentifier { get; set; }
        public Guid InventorySystemIdentifier { get; set; }
        public Guid FundSystemIdentifier { get; set; }
        public int DocAvailabilityStatusCode { get; set; }
        public int EnrolledDocument { get; set; }
        public int DeductedDocument { get; set; }
        public int EnrolledDigitalObjectsCount { get; set; }
        public int DeductedDigitalObjectsCount { get; set; }
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
