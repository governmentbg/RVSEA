using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class FilmReview
    {
        public int Id { get; set; }
        public Guid SystemIdentifier { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public Guid UserId { get; set; }
        public string ReaderName { get; set; } = null!;
        public Guid FilmSystemIdentifier { get; set; }
        public bool? AccessAllowed { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual Film FilmSystemIdentifierNavigation { get; set; } = null!;
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual AspNetUser User { get; set; } = null!;
    }
}
