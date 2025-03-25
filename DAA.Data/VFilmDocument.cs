using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class VFilmDocument
    {
        public int DocumentId { get; set; }
        public int PackageId { get; set; }
        public string PackageType { get; set; } = null!;
        public bool PackageIsDeleted { get; set; }
        public string DocumentTypeCode { get; set; } = null!;
        public string DocumentTypeText { get; set; } = null!;
        public string? Description { get; set; }
        public string? FileId { get; set; }
        public string? FilePath { get; set; }
        public string? FileName { get; set; }
        public string? FileType { get; set; }
        public string? ContentType { get; set; }
        public long? FileSizeInBytes { get; set; }
        public int? FileLocation { get; set; }
        public bool DocumentIsDeleted { get; set; }
        public string? HashCode { get; set; }
        public int FilmId { get; set; }
        public Guid FilmSystemIdentifier { get; set; }
        public bool? IsDraft { get; set; }
        public int ArchiveId { get; set; }
        public int ArchiveCode { get; set; }
        public string ArchiveName { get; set; } = null!;
        public bool FilmIsDeleted { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public DateTime? ExternalSourceUpdatedOn { get; set; }
        public int InventoryNumber { get; set; }
        public int? PackageAid { get; set; }
        public int? PackageBid { get; set; }
    }
}
