using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class PackageAdocsTemplate
    {
        public PackageAdocsTemplate()
        {
            PackageDocuments = new HashSet<PackageDocument>();
        }

        public int Id { get; set; }
        public int ProcedureId { get; set; }
        public int DocumentId { get; set; }
        public bool Required { get; set; }
        public int Sort { get; set; }
        public string Title { get; set; } = null!;
        public string? Description { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public bool? Static { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual File Document { get; set; } = null!;
        public virtual ProcessType Procedure { get; set; } = null!;
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<PackageDocument> PackageDocuments { get; set; }
    }
}
