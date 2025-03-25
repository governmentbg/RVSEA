using DAA.Shared.Data;
using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Identity
{
    public class ApplicationRole : IdentityRole<Guid>
    {
        //public ApplicationRole()
        //{
        //    Id = Guid.NewGuid();
        //}
        public int? ArchiveId { get; set; }
        public string Abbreviation { get; set; }

        public virtual ICollection<ApplicationUserRole> UserRoles { get; set; } = new List<ApplicationUserRole>();
        public virtual ICollection<ApplicationRoleClaim> RoleClaims { get; set; } = new HashSet<ApplicationRoleClaim>();
        
    }
}
