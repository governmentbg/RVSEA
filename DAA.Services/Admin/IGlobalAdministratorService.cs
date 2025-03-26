using DAA.Models.Authentication;
using DAA.Models.Identity;
using DAA.Shared;
using System.Security.Claims;

namespace DAA.Services.Admin
{
    public interface IGlobalAdministratorService
    {
        Task<OperationResult> CreateAnonymousUser();
        Task<OperationResult> CreateAdmin();
        ApplicationUser GetUser(ClaimsPrincipal principal);
        bool GetUserIsAdmin(ClaimsPrincipal principal);
        ApplicationUser CheckLogin(LoginModel model);
    }
}
