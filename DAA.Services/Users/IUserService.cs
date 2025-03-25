using DAA.Extensions.DynamicLinq;
using DAA.Models.Authentication;
using DAA.Models.Identity;
using DAA.Models.Users;
using DAA.Shared;

namespace DAA.Services.Users
{
    public interface IUserService
    {
        DataSourceResponseModel<UserDisplayModel> GetAll(DataSourceRequestModel model, bool includeDeleted = false);
        DataSourceResponseModel<UserDisplayModel> GetByType(DataSourceRequestModel model, string userType, bool includeDeleted = false);
        IQueryable<UserDisplayModel> GetBySearchText(string searchText);
        Task<UserDisplayModel?> GetById(Guid id);
        Task<bool> UserExistsAsync(string username);
        Task<OperationResult> CreateAsync(UserCreateModel model);
        Task<OperationResult> UpdateAsync(UserEditModel model);
        Task<OperationResult> DeleteAsync(Guid id);
        Task<string> ResetPasswordToken(Guid id);
        Task<List<Guid>> GetUsersInRole(Guid roleId);
        DataSourceResponseModel<UserDisplayModel> GetByProfileType(DataSourceRequestModel model, string pofileType, bool includeDeleted = false);
        Task<string> ChangePassword(ApplicationUser user, string newPassword);
    }
}
