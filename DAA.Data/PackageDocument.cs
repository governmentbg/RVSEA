using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class PackageDocument
    {
        public PackageDocument()
        {
            DigitalObjectDrafts = new HashSet<DigitalObjectDraft>();
            SignatureRequests = new HashSet<SignatureRequest>();
        }

        public int Id { get; set; }
        public int PackageId { get; set; }
        public string? Description { get; set; }
        public int? DocTypeId { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public string? FileId { get; set; }
        public string? FilePath { get; set; }
        public string? FileName { get; set; }
        public string? FileType { get; set; }
        public string? ContentType { get; set; }
        public long? FileSizeInBytes { get; set; }
        public int? FileLocation { get; set; }
        public string? HashCode { get; set; }
        public bool? ChecksumCheckResult { get; set; }
        public bool? FileFormatCheckResult { get; set; }
        public bool? AntivirusCheckResult { get; set; }
        public string? AntivirusCheckInfo { get; set; }
        public string? FileInfo { get; set; }
        public string? ErrorMessage { get; set; }
        public bool IsInvaluable { get; set; }
        public int? ParentId { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual PackageAdocsTemplate? DocType { get; set; }
        public virtual Package Package { get; set; } = null!;
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<DigitalObjectDraft> DigitalObjectDrafts { get; set; }
        public virtual ICollection<SignatureRequest> SignatureRequests { get; set; }
    }
}
