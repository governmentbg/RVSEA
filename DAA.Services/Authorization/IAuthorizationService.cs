using System.Security.Claims;

namespace DAA.Services.Authorization
{
    public interface IAuthorizationService
    {
        Task<bool> IsAdmin(ClaimsPrincipal principal, string adminType);
        Task<bool> HasRole(ClaimsPrincipal principal, IEnumerable<string> roles, int? archiveId = null);
        //Task<IEnumerable<string>> GetRoles(ClaimsPrincipal principal);
        Task<string[]?> GetRoles(ClaimsPrincipal principal);
        Task<string[]> GetRoles(Guid userId);
    }
}
