using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class Package
    {
        public Package()
        {
            EdocsCollectingApplicationPackageAs = new HashSet<EdocsCollectingApplication>();
            EdocsCollectingApplicationPackageBs = new HashSet<EdocsCollectingApplication>();
            InventoryDraftPackageAs = new HashSet<InventoryDraft>();
            InventoryDraftPackageBs = new HashSet<InventoryDraft>();
            InventoryPackageAs = new HashSet<Inventory>();
            InventoryPackageBs = new HashSet<Inventory>();
            InventoryPackageCs = new HashSet<Inventory>();
            PackageDocuments = new HashSet<PackageDocument>();
            SignatureRequests = new HashSet<SignatureRequest>();
        }

        public int Id { get; set; }
        public string Type { get; set; } = null!;
        public Guid? InventoryIdentifier { get; set; }
        public int? ApplicationId { get; set; }
        public bool? Approved { get; set; }
        public Guid? ApprovedBy { get; set; }
        public DateTime? ApprovedOn { get; set; }
        public string? RejectReason { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<EdocsCollectingApplication> EdocsCollectingApplicationPackageAs { get; set; }
        public virtual ICollection<EdocsCollectingApplication> EdocsCollectingApplicationPackageBs { get; set; }
        public virtual ICollection<InventoryDraft> InventoryDraftPackageAs { get; set; }
        public virtual ICollection<InventoryDraft> InventoryDraftPackageBs { get; set; }
        public virtual ICollection<Inventory> InventoryPackageAs { get; set; }
        public virtual ICollection<Inventory> InventoryPackageBs { get; set; }
        public virtual ICollection<Inventory> InventoryPackageCs { get; set; }
        public virtual ICollection<PackageDocument> PackageDocuments { get; set; }
        public virtual ICollection<SignatureRequest> SignatureRequests { get; set; }
    }
}
