using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class EdocsCollectingApplication
    {
        public EdocsCollectingApplication()
        {
            FundDrafts = new HashSet<FundDraft>();
            Funds = new HashSet<Fund>();
            Inventories = new HashSet<Inventory>();
            InventoryDrafts = new HashSet<InventoryDraft>();
            InverseRedirectApplication = new HashSet<EdocsCollectingApplication>();
            SignatureRequests = new HashSet<SignatureRequest>();
        }

        public int Id { get; set; }
        public int ArchiveId { get; set; }
        public int Number { get; set; }
        public string Type { get; set; } = null!;
        public Guid ApplicantId { get; set; }
        public int? FileId { get; set; }
        public string? DocumentsOwner { get; set; }
        public int? DocumentsSize { get; set; }
        public string? DocumentsPeriod { get; set; }
        public string? DocumentsOriginType { get; set; }
        public string? ApplicantPhone { get; set; }
        public string? OrganizationEik { get; set; }
        public int StatusId { get; set; }
        public Guid? AssignToUserId { get; set; }
        public string? RejectReason { get; set; }
        public int? PackageAid { get; set; }
        public int? PackageBid { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public string? Organization { get; set; }
        public string? ApplicantAddress { get; set; }
        public string? ApplicantFullName { get; set; }
        public string? ApplicantEmail { get; set; }
        public string? OrganizationRepresentative { get; set; }
        public bool? IsFromRedirect { get; set; }
        public int? RedirectApplicationId { get; set; }
        public bool? IsSystem { get; set; }
        public string? ModificationReason { get; set; }

        public virtual AspNetUser Applicant { get; set; } = null!;
        public virtual Archive Archive { get; set; } = null!;
        public virtual AspNetUser? AssignToUser { get; set; }
        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual EdocsCollectingDocumentsOriginType? DocumentsOriginTypeNavigation { get; set; }
        public virtual File? File { get; set; }
        public virtual Package? PackageA { get; set; }
        public virtual Package? PackageB { get; set; }
        public virtual EdocsCollectingApplication? RedirectApplication { get; set; }
        public virtual EdocsCollectingApplicationStatus Status { get; set; } = null!;
        public virtual EdocsCollectingApplicationType TypeNavigation { get; set; } = null!;
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<FundDraft> FundDrafts { get; set; }
        public virtual ICollection<Fund> Funds { get; set; }
        public virtual ICollection<Inventory> Inventories { get; set; }
        public virtual ICollection<InventoryDraft> InventoryDrafts { get; set; }
        public virtual ICollection<EdocsCollectingApplication> InverseRedirectApplication { get; set; }
        public virtual ICollection<SignatureRequest> SignatureRequests { get; set; }
    }
}
