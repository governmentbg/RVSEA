using Microsoft.AspNetCore.Identity;

namespace DAA.Models.Identity
{
    public class ApplicationRoleClaim : IdentityRoleClaim<Guid>
    {
        public virtual ApplicationRole Role { get; set; } = null!;
    }
}
