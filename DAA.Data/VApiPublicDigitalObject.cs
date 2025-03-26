using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class VApiPublicDigitalObject
    {
        public int Id { get; set; }
        public Guid SystemIdentifier { get; set; }
        public int ArchiveId { get; set; }
        public int ArchiveCode { get; set; }
        public string ArchiveName { get; set; } = null!;
        public Guid FundSystemIdentifier { get; set; }
        public string? FundNumber { get; set; }
        public Guid InventorySystemIdentifier { get; set; }
        public string? InventoryNumber { get; set; }
        public Guid ArchivalEntitySystemIdentifier { get; set; }
        public string? ArchivalEntityNumber { get; set; }
        public Guid DocumentSystemIdentifier { get; set; }
        public string? DocumentNumber { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public string? CreatedByDisplayName { get; set; }
        public string? Title { get; set; }
        public string? ApproxmateChronologicalScope { get; set; }
        public string? Location { get; set; }
        public string? Description { get; set; }
        public string SourceName { get; set; } = null!;
        public string FileType { get; set; } = null!;
        public long FileSize { get; set; }
    }
}
