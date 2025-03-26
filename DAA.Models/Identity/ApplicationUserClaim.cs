using Microsoft.AspNetCore.Identity;

namespace DAA.Models.Identity
{
    public class ApplicationUserClaim : IdentityUserClaim<Guid>
    {
        public virtual ApplicationUser User { get; set; } = null!;
    }
}
