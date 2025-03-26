using DAA.Shared;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Services.Roles
{
    public interface IRoleService
    {
        Task<OperationResult> CreateGlobalRolesAsync();
        Task<OperationResult> CreateRolesForArchiveAsync(int archiveId);
    }
}
