using System;
using System.Collections.Generic;
using System.Text;

namespace DAA.Models.Users
{
    public class UserDisplayModel : UserBaseModel
    {
        public string? CertificateThumbprint { get; set; }
        public string? FirstName { get; set; }
        public string? Surname { get; set; }
        public string? LastName { get; set; }
        public string? Organization { get; set; }
        public string? Department { get; set; }
        public string? JobTitle { get; set; }
        public string? Address { get; set; }
        public string? LibraryCardNumber { get; set; }
        public DateTime? CreatedOn { get; set; }
        public DateTime? DeletedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public Guid? DeletedBy { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool EmailConfirmed { get; set; }
        public bool Deleted { get; set; }
        public string? CreatedByUserName { get; set; }
        public string? CreatedByDisplayName { get; set; }
        public string? UpdatedByUserName { get; set; }
        public string? UpdatedByDisplayName { get; set; }
        public string? DeletedByUserName { get; set; }
        public string? DeletedByDisplayName { get; set; }
    }
}
