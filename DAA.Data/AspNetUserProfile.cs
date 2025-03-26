using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class AspNetUserProfile
    {
        public int Id { get; set; }
        public Guid UserId { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public string? ProfileType { get; set; }
        public string? EntityType { get; set; }
        public string FirstName { get; set; } = null!;
        public string? Surname { get; set; }
        public string LastName { get; set; } = null!;
        public string DisplayName { get; set; } = null!;
        public string? Organization { get; set; }
        public string? Department { get; set; }
        public string? JobTitle { get; set; }
        public string? Address { get; set; }
        public string? LibraryCardNumber { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Eik { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual AspNetUser User { get; set; } = null!;
    }
}
