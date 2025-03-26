using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class Process
    {
        public Process()
        {
            Comments = new HashSet<Comment>();
            Epkreports = new HashSet<Epkreport>();
            FundReconstructions = new HashSet<FundReconstruction>();
            Funds = new HashSet<Fund>();
            Inventories = new HashSet<Inventory>();
            InventoryRawToNormals = new HashSet<InventoryRawToNormal>();
            ProcessTimelines = new HashSet<ProcessTimeline>();
            SessionAgenda = new HashSet<SessionAgendum>();
            SignatureRequests = new HashSet<SignatureRequest>();
            Tasks = new HashSet<Task>();
        }

        public int Id { get; set; }
        public int ProcessTypeId { get; set; }
        public int? ArchiveId { get; set; }
        public int? DocumentId { get; set; }
        public int? InventoryId { get; set; }
        public bool Completed { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public int? FundId { get; set; }
        public int? ArchivalEntityId { get; set; }
        public Guid? FilmSystemIdentifier { get; set; }
        public Guid? FundSystemIdentifier { get; set; }
        public Guid? InventorySystemIdentifier { get; set; }
        public Guid? ArchivalEntitySystemIdentifier { get; set; }
        public Guid? DocumentSystemIdentifier { get; set; }

        public virtual ArchivalEntity? ArchivalEntity { get; set; }
        public virtual Archive? Archive { get; set; }
        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual Document? Document { get; set; }
        public virtual Fund? Fund { get; set; }
        public virtual Inventory? Inventory { get; set; }
        public virtual ProcessType ProcessType { get; set; } = null!;
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<Comment> Comments { get; set; }
        public virtual ICollection<Epkreport> Epkreports { get; set; }
        public virtual ICollection<FundReconstruction> FundReconstructions { get; set; }
        public virtual ICollection<Fund> Funds { get; set; }
        public virtual ICollection<Inventory> Inventories { get; set; }
        public virtual ICollection<InventoryRawToNormal> InventoryRawToNormals { get; set; }
        public virtual ICollection<ProcessTimeline> ProcessTimelines { get; set; }
        public virtual ICollection<SessionAgendum> SessionAgenda { get; set; }
        public virtual ICollection<SignatureRequest> SignatureRequests { get; set; }
        public virtual ICollection<Task> Tasks { get; set; }
    }
}
