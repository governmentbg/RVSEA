using DAA.Shared.Data;
using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations.Schema;

namespace DAA.Models.Identity
{
    public class ApplicationUser : IdentityUser<Guid>, ICreatable, IEditable, IDeletable, IAuditable
    {
        //public ApplicationUser()
        //{
        //    Id = Guid.NewGuid();
        //    SecurityStamp = Guid.NewGuid().ToString();
        //}

        public string AuthenticationType { get; set; } = null!;
        public string UserType { get; set; } = null!;
        public byte[]? Certificate { get; set; }
        public string? CertificateThumbprint { get; set; }
        public string? CertificateName { get; set; }
        public string? CertificateUniqueIdentifier { get; set; }
        [NotMapped]
        public string AdminType { get; set; } = null!;
        [NotMapped]
        public bool IsAdmin { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }

        public virtual ICollection<ApplicationUserClaim> Claims { get; set; } = new HashSet<ApplicationUserClaim>();
        public virtual ICollection<ApplicationUserLogin> Logins { get; set; } = new List<ApplicationUserLogin>();
        public virtual ICollection<ApplicationUserToken> Tokens { get; set; } = new List<ApplicationUserToken>();
        public virtual ICollection<ApplicationUserRole> UserRoles { get; set; } = new List<ApplicationUserRole>();
    }
}
