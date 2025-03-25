using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class SignatureRequest
    {
        public int Id { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public bool Deleted { get; set; }
        public Guid? DeletedBy { get; set; }
        public DateTime? DeletedOn { get; set; }
        public int ArchiveId { get; set; }
        public int ProcessId { get; set; }
        public int ProcessStepId { get; set; }
        public int? ApplicationId { get; set; }
        public int PackageId { get; set; }
        public int PackageDocumentId { get; set; }
        public Guid SigningUserId { get; set; }
        public bool Completed { get; set; }

        public virtual EdocsCollectingApplication? Application { get; set; }
        public virtual Archive Archive { get; set; } = null!;
        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual Package Package { get; set; } = null!;
        public virtual PackageDocument PackageDocument { get; set; } = null!;
        public virtual Process Process { get; set; } = null!;
        public virtual ProcessTimeline ProcessStep { get; set; } = null!;
        public virtual AspNetUser SigningUser { get; set; } = null!;
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
    }
}
