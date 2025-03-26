using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class FundReconstruction
    {
        public int Id { get; set; }
        public int ProcessId { get; set; }
        public int ArchiveId { get; set; }
        public Guid FundSystemIdentifier { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public Guid? SourceInventorySystemIdentifier { get; set; }
        public Guid? SourceArchivalEntitySystemIdentifier { get; set; }
        public Guid? SourceDocumentSystemIdentifier { get; set; }
        public Guid? TargetInventorySystemIdentifier { get; set; }
        public Guid? TargetArchivalEntitySystemIdentifier { get; set; }
        public Guid? TargetDocumentSystemIdentifier { get; set; }
        public int? AvailabilityStatusCode { get; set; }

        public virtual Archive Archive { get; set; } = null!;
        public virtual AvailabilityStatus? AvailabilityStatusCodeNavigation { get; set; }
        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual Fund FundSystemIdentifierNavigation { get; set; } = null!;
        public virtual Process Process { get; set; } = null!;
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
    }
}
