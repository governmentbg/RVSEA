using DAA.Models.Identity;
using Microsoft.AspNetCore.Identity;

namespace DAA.Services.Identity
{
    public interface IApplicationRoleStore : IRoleStore<ApplicationRole>
    {
        Task<ApplicationRole> FindByIdAsync(Guid id, CancellationToken cancellationToken);
        Task<ApplicationRole> FindByIdAsync(Guid roleId, int archiveId, CancellationToken cancellationToken);
        Task<ApplicationRole> FindByNameAsync(string normalizedRoleName, int archiveId, CancellationToken cancellationToken);
        Task<Guid> GetRoleIdAsync(ApplicationRole role, int archiveId, CancellationToken cancellationToken);
        Task<Guid> GetRoleRawIdAsync(ApplicationRole role, CancellationToken cancellationToken);
    }
}
