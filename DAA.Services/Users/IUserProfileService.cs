using DAA.Models.Users;
using DAA.Shared;

namespace DAA.Services.Users
{
    public interface IUserProfileService
    {
        Task<UserProfileModel?> GetProfileAsync(Guid userId);
        Task<InternalUserProfileModel?> GetProfileAndProfileRoles(Guid userId);
        Task<OperationResult> CreateProfileAsync(UserProfileModel model);
        Task<OperationResult> UpdateProfileAsync(UserProfileModel model);
        Task<OperationResult> DeleteProfileAsync(Guid userId);
    }
}
