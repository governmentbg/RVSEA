using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class InventoryNumber
    {
        public int Id { get; set; }
        public int ArchiveId { get; set; }
        public DateTime CreatedOn { get; set; }
        public Guid CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public int Number { get; set; }
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

        public virtual Archive Archive { get; set; } = null!;
        public virtual AspNetUser CreatedByNavigation { get; set; } = null!;
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
    }
}
