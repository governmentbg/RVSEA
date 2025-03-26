using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class VFilmReview
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
        public string? Username { get; set; }
        public string ReaderName { get; set; } = null!;
        public Guid FilmSystemIdentifier { get; set; }
        public bool AccessAllowed { get; set; }
        public string? CreatedByDisplayName { get; set; }
        public string? CreatedByUserName { get; set; }
        public string? UpdatedByDisplayName { get; set; }
        public string? UpdatedByUserName { get; set; }
        public string? DeletedByDisplayName { get; set; }
        public string? DeletedByUserName { get; set; }
        public int? FilmInventoryNumber { get; set; }
        public string? FilmNumber { get; set; }
    }
}
