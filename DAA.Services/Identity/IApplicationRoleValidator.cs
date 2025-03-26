using DAA.Models.Identity;
using Microsoft.AspNetCore.Identity;

namespace DAA.Services.Identity
{
    public interface IApplicationRoleValidator : IRoleValidator<ApplicationRole>
    {
    }
}
