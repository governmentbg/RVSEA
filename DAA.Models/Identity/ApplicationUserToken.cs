using Microsoft.AspNetCore.Identity;

namespace DAA.Models.Identity
{
    public class ApplicationUserToken : IdentityUserToken<Guid>
    {
        public virtual ApplicationUser User { get; set; } = null!;
    }
}
