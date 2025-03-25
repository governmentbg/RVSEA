using DAA.Models.Identity;
using Microsoft.AspNetCore.Identity;

namespace DAA.Identity
{
    public interface IApplicationRoleValidator : IRoleValidator<ApplicationRole>
    {
    }
}
