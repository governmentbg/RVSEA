using System.Security.Claims;

namespace DAA.Shared.Identity
{
    public interface IUserInfo
    {
        ClaimsPrincipal CurrentUser { get; }
        Guid? CurrentUserId { get; }
        string? CurrentUserEmail { get; }
        string? CurrentUserUsername { get; }
        //int? CurrentUserArchiveId { get; }
        bool? CurrentUserIsAdmin { get; }
    }
}
