using DAA.Data;
using DAA.Identity;
using DAA.Models.Identity;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.Extensions.Localization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Services.Roles
{
    public class RoleService : BaseService, IRoleService
    {
        private readonly ApplicationRoleManager _roleManager;
        private readonly IUserInfo _userInfo;

        public RoleService(
            ArchivingContext context, 
            IStringLocalizer<SharedResources> localizer,
            IUserInfo userInfo,
            ApplicationRoleManager roleManager) 
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _roleManager = roleManager;
        }

        public async Task<OperationResult> CreateGlobalRolesAsync()
        {
            try
            {
                var roleG1Name = _localizer.GetString("Role_G1");
                var roleD1Name = _localizer.GetString("Role_D1");
                var roleD2Name = _localizer.GetString("Role_D2");
                var roleD3Name = _localizer.GetString("Role_D3");

                var roleG1 = await _roleManager.FindByNameAsync(roleG1Name);
                if (roleG1 == null)
                {
                    roleG1 = new ApplicationRole() { Name = roleG1Name };
                    await _roleManager.CreateAsync(roleG1);
                }
                var roleD1 = await _roleManager.FindByNameAsync(roleD1Name);
                if (roleD1 == null)
                {
                    roleD1 = new ApplicationRole() { Name = roleD1Name };
                    await _roleManager.CreateAsync(roleD1);
                }
                var roleD2 = await _roleManager.FindByNameAsync(roleD2Name);
                if (roleD2 == null)
                {
                    roleD2 = new ApplicationRole() { Name = roleD2Name };
                    await _roleManager.CreateAsync(roleD2);
                }
                var roleD3 = await _roleManager.FindByNameAsync(roleD3Name);
                if (roleD3 == null)
                {
                    roleD3 = new ApplicationRole() { Name = roleD3Name };
                    await _roleManager.CreateAsync(roleD3);
                }

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> CreateRolesForArchiveAsync(int archiveId)
        {
            try
            {
                var rolеAName = _localizer.GetString("Role_A");
                var rolеBName = _localizer.GetString("Role_B");
                var rolеB1Name = _localizer.GetString("Role_B1");
                var rolеEName = _localizer.GetString("Role_E");
                var rolеGName = _localizer.GetString("Role_G");
                var rolеG2Name = _localizer.GetString("Role_G2");
                var rolеIName = _localizer.GetString("Role_I");
                var rolеI1Name = _localizer.GetString("Role_I1");
                var rolеJName = _localizer.GetString("Role_J");
                var rolеV1Name = _localizer.GetString("Role_V1");
                var rolеV2Name = _localizer.GetString("Role_V2");
                var rolеV3Name = _localizer.GetString("Role_V3");
                var rolеV4Name = _localizer.GetString("Role_V4");
                var rolеV5Name = _localizer.GetString("Role_V5");
                var rolеV6Name = _localizer.GetString("Role_V6");
                var rolеZName = _localizer.GetString("Role_Z");

                var rolеA = await _roleManager.FindByNameAsync(rolеAName, archiveId);
                if (rolеA == null)
                {
                    rolеA = new ApplicationRole() { Name = rolеAName, ArchiveId = archiveId, Abbreviation = "A" };
                    var result = await _roleManager.CreateAsync(rolеA);
                    if (!result.Succeeded)
                    {
                        return OperationResult.Failed(false, result.Errors.Select(e => e.Description).ToArray());
                    }
                }
                var rolеB = await _roleManager.FindByNameAsync(rolеBName, archiveId);
                if (rolеB == null)
                {
                    rolеB = new ApplicationRole() { Name = rolеBName, ArchiveId = archiveId, Abbreviation = "B" };
                    var result = await _roleManager.CreateAsync(rolеB);
                    if (!result.Succeeded)
                    {
                        return OperationResult.Failed(false, result.Errors.Select(e => e.Description).ToArray());
                    }
                }
                var rolеB1 = await _roleManager.FindByNameAsync(rolеB1Name, archiveId);
                if (rolеB1 == null)
                {
                    rolеB1 = new ApplicationRole() { Name = rolеB1Name, ArchiveId = archiveId, Abbreviation = "B1" };
                    var result = await _roleManager.CreateAsync(rolеB1);
                    if (!result.Succeeded)
                    {
                        return OperationResult.Failed(false, result.Errors.Select(e => e.Description).ToArray());
                    }
                }
                var rolеE = await _roleManager.FindByNameAsync(rolеEName, archiveId);
                if (rolеE == null)
                {
                    rolеE = new ApplicationRole() { Name = rolеEName, ArchiveId = archiveId, Abbreviation = "E" };
                    var result = await _roleManager.CreateAsync(rolеE);
                    if (!result.Succeeded)
                    {
                        return OperationResult.Failed(false, result.Errors.Select(e => e.Description).ToArray());
                    }
                }
                var rolеG = await _roleManager.FindByNameAsync(rolеGName, archiveId);
                if (rolеG == null)
                {
                    rolеG = new ApplicationRole() { Name = rolеGName, ArchiveId = archiveId, Abbreviation = "G"};
                    var result = await _roleManager.CreateAsync(rolеG);
                    if (!result.Succeeded)
                    {
                        return OperationResult.Failed(false, result.Errors.Select(e => e.Description).ToArray());
                    }
                }
                var rolеG2 = await _roleManager.FindByNameAsync(rolеG2Name, archiveId);
                if (rolеG2 == null)
                {
                    rolеG2 = new ApplicationRole() { Name = rolеG2Name, ArchiveId = archiveId, Abbreviation = "G2" };
                    var result = await _roleManager.CreateAsync(rolеG2);
                    if (!result.Succeeded)
                    {
                        return OperationResult.Failed(false, result.Errors.Select(e => e.Description).ToArray());
                    }
                }
                var rolеI = await _roleManager.FindByNameAsync(rolеIName, archiveId);
                if (rolеI == null)
                {
                    rolеI = new ApplicationRole() { Name = rolеIName, ArchiveId = archiveId, Abbreviation = "I" };
                    var result = await _roleManager.CreateAsync(rolеI);
                    if (!result.Succeeded)
                    {
                        return OperationResult.Failed(false, result.Errors.Select(e => e.Description).ToArray());
                    }
                }
                var rolеI1 = await _roleManager.FindByNameAsync(rolеI1Name, archiveId);
                if (rolеI1 == null)
                {
                    rolеI1 = new ApplicationRole() { Name = rolеI1Name, ArchiveId = archiveId, Abbreviation = "I1" };
                    var result = await _roleManager.CreateAsync(rolеI1);
                    if (!result.Succeeded)
                    {
                        return OperationResult.Failed(false, result.Errors.Select(e => e.Description).ToArray());
                    }
                }
                var rolеJ = await _roleManager.FindByNameAsync(rolеJName, archiveId);
                if (rolеJ == null)
                {
                    rolеJ = new ApplicationRole() { Name = rolеJName, ArchiveId = archiveId, Abbreviation = "J" };
                    var result = await _roleManager.CreateAsync(rolеJ);
                    if (!result.Succeeded)
                    {
                        return OperationResult.Failed(false, result.Errors.Select(e => e.Description).ToArray());
                    }
                }
                var rolеV1 = await _roleManager.FindByNameAsync(rolеV1Name, archiveId);
                if (rolеV1 == null)
                {
                    rolеV1 = new ApplicationRole() { Name = rolеV1Name, ArchiveId = archiveId, Abbreviation = "V1" };
                    var result = await _roleManager.CreateAsync(rolеV1);
                    if (!result.Succeeded)
                    {
                        return OperationResult.Failed(false, result.Errors.Select(e => e.Description).ToArray());
                    }
                }
                var rolеV2 = await _roleManager.FindByNameAsync(rolеV2Name, archiveId);
                if (rolеV2 == null)
                {
                    rolеV2 = new ApplicationRole() { Name = rolеV2Name, ArchiveId = archiveId, Abbreviation = "V2" };
                    var result = await _roleManager.CreateAsync(rolеV2);
                    if (!result.Succeeded)
                    {
                        return OperationResult.Failed(false, result.Errors.Select(e => e.Description).ToArray());
                    }
                }
                var rolеV3 = await _roleManager.FindByNameAsync(rolеV3Name, archiveId);
                if (rolеV3 == null)
                {
                    rolеV3 = new ApplicationRole() { Name = rolеV3Name, ArchiveId = archiveId, Abbreviation = "V3" };
                    var result = await _roleManager.CreateAsync(rolеV3);
                    if (!result.Succeeded)
                    {
                        return OperationResult.Failed(false, result.Errors.Select(e => e.Description).ToArray());
                    }
                }
                var rolеV4 = await _roleManager.FindByNameAsync(rolеV4Name, archiveId);
                if (rolеV4 == null)
                {
                    rolеV4 = new ApplicationRole() { Name = rolеV4Name, ArchiveId = archiveId, Abbreviation = "V4" };
                    var result = await _roleManager.CreateAsync(rolеV4);
                    if (!result.Succeeded)
                    {
                        return OperationResult.Failed(false, result.Errors.Select(e => e.Description).ToArray());
                    }
                }
                var rolеV5 = await _roleManager.FindByNameAsync(rolеV5Name, archiveId);
                if (rolеV5 == null)
                {
                    rolеV5 = new ApplicationRole() { Name = rolеV5Name, ArchiveId = archiveId, Abbreviation = "V5" };
                    var result = await _roleManager.CreateAsync(rolеV5);
                    if (!result.Succeeded)
                    {
                        return OperationResult.Failed(false, result.Errors.Select(e => e.Description).ToArray());
                    }
                }
                var rolеV6 = await _roleManager.FindByNameAsync(rolеV6Name, archiveId);
                if (rolеV6 == null)
                {
                    rolеV6 = new ApplicationRole() { Name = rolеV6Name, ArchiveId = archiveId, Abbreviation = "V6" };
                    var result = await _roleManager.CreateAsync(rolеV6);
                }
                var rolеZ = await _roleManager.FindByNameAsync(rolеZName, archiveId);
                if (rolеZ == null)
                {
                    rolеZ = new ApplicationRole() { Name = rolеZName, ArchiveId = archiveId, Abbreviation = "Z" };
                    var result = await _roleManager.CreateAsync(rolеZ);
                }

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }
    }
}
