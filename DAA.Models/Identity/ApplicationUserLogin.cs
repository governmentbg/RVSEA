using Microsoft.AspNetCore.Identity;

namespace DAA.Models.Identity
{
    public class ApplicationUserLogin : IdentityUserLogin<Guid>
    {
        public virtual ApplicationUser User { get; set; } = null!;
    }
}
