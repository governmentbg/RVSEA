using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class FilmDraft
    {
        public FilmDraft()
        {
            FilmCardDrafts = new HashSet<FilmCardDraft>();
        }

        public int Id { get; set; }
        public int ArchiveId { get; set; }
        public Guid SystemIdentifier { get; set; }
        public bool IsCurrent { get; set; }
        public bool ReadOnly { get; set; }
        public string? WorkflowTypeCode { get; set; }
        public int? WorkflowId { get; set; }
        public string? WorkflowStepTypeCode { get; set; }
        public int? WorkflowStepId { get; set; }
        public bool HasExternalSource { get; set; }
        public int? ExternalIdentifier { get; set; }
        public DateTime? ExternalSourceUpdatedOn { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public int InventoryNumber { get; set; }
        public int? CountryId { get; set; }
        public int? FramesCount { get; set; }
        public int? MicrofilmNegativeRollsCount { get; set; }
        public int? MicrofilmNegativeFramesCount { get; set; }
        public int? MicrofilmPositiveRollsCount { get; set; }
        public int? MicrofilmPositiveFramesCount { get; set; }
        public string? PhotoCopy { get; set; }
        public string? DigitalCopy { get; set; }
        public string? Size { get; set; }
        public string? Other { get; set; }
        public int? AcceptedOnDay { get; set; }
        public int? AcceptedOnMonth { get; set; }
        public int? AcceptedOnYear { get; set; }
        public string? Source { get; set; }
        public string? Content { get; set; }
        public string? Notes { get; set; }
        public int? PackageAid { get; set; }
        public int? PackageBid { get; set; }

        public virtual Archive Archive { get; set; } = null!;
        public virtual Nomenclature? Country { get; set; }
        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual FilmPackage? PackageA { get; set; }
        public virtual FilmPackage? PackageB { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<FilmCardDraft> FilmCardDrafts { get; set; }
    }
}
