using DAA.Data;
using DAA.Models.Identity;
using DAA.Models.Users;
using DAA.Identity;
using DAA.Shared;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using System.Text;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Models;
using DAA.Extensions.DateTime;
using DAA.Shared.Identity;
using Microsoft.AspNetCore.Identity;

namespace DAA.Services.Users
{
    public class UserService : BaseService, IUserService
    {
        private readonly ApplicationUserManager _userManager;
        private readonly ApplicationRoleManager _roleManager;
        private readonly IUserProfileService _userProfileService;
        private readonly IUserInfo _userInfo;

        public UserService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IUserInfo userInfo,
            ApplicationUserManager userManager,
            ApplicationRoleManager roleManager,
            IUserProfileService userProfileService)
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _userManager = userManager;
            _roleManager = roleManager;
            _userProfileService = userProfileService;
        }

        private async Task<OperationResult> CleanupUserAsync(ApplicationUser user)
        {
            var result = await _userManager.DeleteAsync(user);
            if (!result.Succeeded)
            {
                return OperationResult.Failed(result.ToString());
            }

            return OperationResult.Success;
        }

        public DataSourceResponseModel<UserDisplayModel> GetAll(DataSourceRequestModel model, bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query = 
                _context.AspNetUsers
                .Select(u => new UserDisplayModel() 
                { 
                    Id = u.Id,
                    AuthenticationType = u.AuthenticationType,
                    CertificateThumbprint = u.CertificateThumbprint,
                    CreatedBy = u.CreatedBy,
                    CreatedByDisplayName = u.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == u.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = u.CreatedByNavigation.UserName,
                    CreatedOn = u.CreatedOn,
                    Deleted = u.Deleted,
                    DeletedBy = u.DeletedBy,
                    DeletedByDisplayName = u.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == u.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = u.DeletedByNavigation.UserName,
                    DeletedOn = u.DeletedOn,
                    DisplayName = u.AspNetUserProfileUsers.Where(up => up.UserId == u.Id && !up.Deleted).FirstOrDefault().DisplayName!,
                    Email = u.Email!,
                    UpdatedBy = u.UpdatedBy,
                    UpdatedByDisplayName = u.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == u.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = u.UpdatedByNavigation.UserName,
                    UpdatedOn = u.UpdatedOn,
                    UserName = u.UserName!,
                    EmailConfirmed = u.EmailConfirmed,
                    UserProfileType = u.AspNetUserProfileUsers.Where(up => up.UserId == u.Id && !up.Deleted).FirstOrDefault().ProfileType,
                    UserType = u.UserType,
                });
            if (!includeDeleted)
            {
                query = query.Where(u => !u.Deleted);
            }

            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }
            query = query.OrderBy(u => u.Deleted).ThenBy(u => u.UserName).ThenBy(u => u.DisplayName);

            QueryResponseModel<UserDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<UserDisplayModel> result = new DataSourceResponseModel<UserDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => new UserDisplayModel()
                {
                    Id = x.Id,
                    AuthenticationType = x.AuthenticationType,
                    CertificateThumbprint = x.CertificateThumbprint,
                    CreatedBy = x.CreatedBy,
                    CreatedByDisplayName = x.CreatedByDisplayName,
                    CreatedByUserName = x.CreatedByUserName,
                    CreatedOn = x.CreatedOn.UtcToLocalTime(),
                    Deleted = x.Deleted,
                    DeletedBy = x.DeletedBy,
                    DeletedByDisplayName = x.DeletedByDisplayName,
                    DeletedByUserName = x.DeletedByUserName,
                    DeletedOn = x.DeletedOn.UtcToLocalTime(),
                    DisplayName = x.DisplayName!,
                    Email = x.Email!,
                    UpdatedBy = x.UpdatedBy,
                    UpdatedByDisplayName = x.UpdatedByDisplayName,
                    UpdatedByUserName = x.UpdatedByUserName,
                    UpdatedOn = x.UpdatedOn.UtcToLocalTime(),
                    UserName = x.UserName!,
                    EmailConfirmed = x.EmailConfirmed,
                    UserProfileType = x.UserProfileType,
                    UserType = x.UserType,
                })
            };

            return result;
        }

        public DataSourceResponseModel<UserDisplayModel> GetByType(DataSourceRequestModel model, string userType, bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.AspNetUsers
                .Where(u => u.UserType == userType)
                .Select(u => new UserDisplayModel()
                {
                    Id = u.Id,
                    AuthenticationType = u.AuthenticationType,
                    CertificateThumbprint = u.CertificateThumbprint,
                    CreatedBy = u.CreatedBy,
                    CreatedByDisplayName = u.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == u.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = u.CreatedByNavigation.UserName,
                    CreatedOn = u.CreatedOn,
                    Deleted = u.Deleted,
                    DeletedBy = u.DeletedBy,
                    DeletedByDisplayName = u.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == u.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = u.DeletedByNavigation.UserName,
                    DeletedOn = u.DeletedOn,
                    DisplayName = u.AspNetUserProfileUsers.Where(up => up.UserId == u.Id && !up.Deleted).FirstOrDefault().DisplayName!,
                    Email = u.Email!,
                    UpdatedBy = u.UpdatedBy,
                    UpdatedByDisplayName = u.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == u.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = u.UpdatedByNavigation.UserName,
                    UpdatedOn = u.UpdatedOn,
                    UserName = u.UserName!,
                    EmailConfirmed = u.EmailConfirmed,
                    UserProfileType = u.AspNetUserProfileUsers.Where(up => up.UserId == u.Id && !up.Deleted).FirstOrDefault().ProfileType,
                    UserType = u.UserType,
                });
            if (!includeDeleted)
            {
                query = query.Where(u => !u.Deleted);
            }

            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }
            query = query.OrderBy(u => u.Deleted).ThenBy(u => u.UserName).ThenBy(u => u.DisplayName);

            QueryResponseModel<UserDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<UserDisplayModel> result = new DataSourceResponseModel<UserDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => new UserDisplayModel()
                {
                    Id = x.Id,
                    AuthenticationType = x.AuthenticationType,
                    CertificateThumbprint = x.CertificateThumbprint,
                    CreatedBy = x.CreatedBy,
                    CreatedByDisplayName = x.CreatedByDisplayName,
                    CreatedByUserName = x.CreatedByUserName,
                    CreatedOn = x.CreatedOn.UtcToLocalTime(),
                    Deleted = x.Deleted,
                    DeletedBy = x.DeletedBy,
                    DeletedByDisplayName = x.DeletedByDisplayName,
                    DeletedByUserName = x.DeletedByUserName,
                    DeletedOn = x.DeletedOn.UtcToLocalTime(),
                    DisplayName = x.DisplayName!,
                    Email = x.Email!,
                    UpdatedBy = x.UpdatedBy,
                    UpdatedByDisplayName = x.UpdatedByDisplayName,
                    UpdatedByUserName = x.UpdatedByUserName,
                    UpdatedOn = x.UpdatedOn.UtcToLocalTime(),
                    UserName = x.UserName!,
                    EmailConfirmed = x.EmailConfirmed,
                    UserProfileType = x.UserProfileType,
                    UserType = x.UserType,
                })
            };

            return result;
        }

        public IQueryable<UserDisplayModel> GetBySearchText(string searchText)
        {
            var query = _context.AspNetUsers.Where(u => !u.Deleted);
            if (!string.IsNullOrEmpty(searchText) && !string.IsNullOrWhiteSpace(searchText))
            {
                query = query.Where(u => u.UserName.Contains(searchText) || u.AspNetUserProfileUsers.Where(up => up.UserId == u.Id && !up.Deleted).FirstOrDefault().DisplayName.Contains(searchText));
            }
            query = query.OrderBy(u => u.AspNetUserProfileUsers.Where(up => up.UserId == u.Id && !up.Deleted).FirstOrDefault().DisplayName);

            var users = query.Select(u => new UserDisplayModel()
            {
                Id = u.Id,
                AuthenticationType = u.AuthenticationType,
                CertificateThumbprint = u.CertificateThumbprint,
                CreatedBy = u.CreatedBy,
                CreatedByDisplayName = u.CreatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == u.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                CreatedByUserName = u.CreatedByNavigation.UserName,
                CreatedOn = u.CreatedOn.UtcToLocalTime(),
                Deleted = u.Deleted,
                DeletedBy = u.DeletedBy,
                DeletedByDisplayName = u.DeletedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == u.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                DeletedByUserName = u.DeletedByNavigation.UserName,
                DeletedOn = u.DeletedOn.UtcToLocalTime(),
                DisplayName = u.AspNetUserProfileUsers.Where(up => up.UserId == u.Id && !up.Deleted).FirstOrDefault().DisplayName!,
                Email = u.Email!,
                UpdatedBy = u.UpdatedBy,
                UpdatedByDisplayName = u.UpdatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == u.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                UpdatedByUserName = u.UpdatedByNavigation.UserName,
                UpdatedOn = u.UpdatedOn.UtcToLocalTime(),
                UserName = u.UserName!,
                EmailConfirmed = u.EmailConfirmed,
                UserProfileType = u.AspNetUserProfileUsers.Where(up => up.UserId == u.Id && !up.Deleted).FirstOrDefault().ProfileType,
                UserType = u.UserType,
            });
            return users;
        }

        //public DataSourceResponseModel<UserDisplayModel> GetAllAdmins(DataSourceRequestModel model, bool includeDeleted = true)
        //{
        //    if (model == null)
        //    {
        //        throw new ArgumentNullException(nameof(model));
        //    }

        //    var query = from user in _context.VUsers
        //                join claim in _context.AspNetUserClaims on user.Id equals claim.UserId
        //                where claim.ClaimType == DocFlowClaimTypes.Permission && claim.ClaimValue == Permissions.FullControl
        //                select user;
        //    if (!includeDeleted)
        //    {
        //        query.Where(u => !u.Deleted);
        //    }

        //    if (!String.IsNullOrWhiteSpace(model.SearchString))
        //    {
        //        query = query.FilterByFilterString(model.SearchString);
        //    }
        //    query = query.OrderBy(u => u.Deleted).ThenBy(u => u.ClientName).ThenBy(u => u.UserName);

        //    QueryResponseModel<VUser> queryResponse = query.SortAndFilter(model);
        //    DataSourceResponseModel<UserDisplayModel> result = new DataSourceResponseModel<UserDisplayModel>()
        //    {
        //        TotalCount = queryResponse.TotalCount,
        //        Errors = queryResponse.Errors,
        //        Items = queryResponse.Query.Select(x => x.ToViewModel())
        //    };

        //    return result;
        //}

        //public Task<IQueryable<UserDisplayModel>> GetByRoleIdAsync(string roleId, int? unitId = null)
        //{
        //    if (string.IsNullOrEmpty(roleId))
        //    {
        //        throw new ArgumentNullException(nameof(roleId));
        //    }

        //    var query = _context.AspNetUsers.Where(x => x.Roles.Any(r => r.Id == roleId && !r.Deleted) && !x.Deleted);

        //    return Task.FromResult(query
        //        .Select(user => new UserDisplayModel()
        //        {
        //            Id = user.Id,
        //            ClientId = user.ClientId.Value,
        //            AuthType = user.AuthType,
        //            DisplayName = user.DisplayName,
        //            UserName = user.UserName,
        //            Email = user.Email,
        //            CertificateThumbprint = user.CertificateThumbprint,
        //        }));
        //}

        //public IQueryable<UserDisplayModel> GetByRoleId(string roleId, int? unitId = null)
        //{
        //    if (string.IsNullOrEmpty(roleId))
        //    {
        //        throw new ArgumentNullException(nameof(roleId));
        //    }

        //    var query = _context.AspNetUsers.Where(x => x.Roles.Any(r => r.Id == roleId && !r.Deleted) && !x.Deleted);

        //    return query
        //        .Select(user => new UserDisplayModel()
        //        {
        //            Id = user.Id,
        //            ClientId = user.ClientId.Value,
        //            AuthType = user.AuthType,
        //            DisplayName = user.DisplayName,
        //            UserName = user.UserName,
        //            Email = user.Email,
        //            CertificateThumbprint = user.CertificateThumbprint,
        //        });
        //}

        //public async Task<IEnumerable<UserDisplayModel>> GetByRole(string roleName, int unitId)
        //{
        //    var users = await _userManager.GetUsersInRoleAsync(roleName, unitId);
        //    return users
        //            .Where(appUser => !appUser.Deleted)
        //            .Select(appUser => new UserDisplayModel()
        //            {
        //                Id = appUser.Id,
        //                ClientId = appUser.ClientId.Value,
        //                AuthType = appUser.AuthType,
        //                DisplayName = appUser.DisplayName,
        //                UserName = appUser.UserName,
        //                Email = appUser.Email,
        //                CertificateThumbprint = appUser.CertificateThumbprint,
        //            });

        //}

        public async Task<UserDisplayModel?> GetById(Guid id)
        {
            var user =
                await _context.AspNetUsers
                .Where(u => u.Id == id)
                .Select(u => new UserDisplayModel()
                {
                    Id = u.Id,
                    AuthenticationType = u.AuthenticationType,
                    UserProfileType = u.AspNetUserProfileUsers.Where(up => up.UserId == u.Id && !up.Deleted).FirstOrDefault().ProfileType,
                    UserType = u.UserType,
                    UserName = u.UserName!,
                    DisplayName = u.AspNetUserProfileUsers.Where(up => up.UserId == u.Id && !up.Deleted).FirstOrDefault().DisplayName!,
                    Email = u.Email!,
                    CertificateThumbprint = u.CertificateThumbprint,
                    EmailConfirmed = u.EmailConfirmed,
                    Roles = u.Roles.Select(r => r.Id),
                    Archives = u.AspNetUserArchives.Select(a => a.ArchiveId),
                    CreatedBy = u.CreatedBy,
                    CreatedByDisplayName = u.CreatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == u.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = u.CreatedByNavigation.UserName,
                    CreatedOn = u.CreatedOn.UtcToLocalTime(),
                    Deleted = u.Deleted,
                    DeletedBy = u.DeletedBy,
                    DeletedByDisplayName = u.DeletedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == u.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = u.DeletedByNavigation.UserName,
                    DeletedOn = u.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = u.UpdatedBy,
                    UpdatedByDisplayName = u.UpdatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == u.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = u.UpdatedByNavigation.UserName,
                    UpdatedOn = u.UpdatedOn.UtcToLocalTime(),
                })
                .SingleOrDefaultAsync();
            
            if (user == null)
            {
                return null;
            }
            
            var profile = await _userProfileService.GetProfileAsync(id);
            if (profile != null)
            {
                user.FirstName = profile.FirstName;
                user.Surname = profile.Surname;
                user.LastName = profile.LastName;
                user.Organization = profile.Organization;
                user.Department = profile.Department;
                user.JobTitle = profile.JobTitle;
                user.Address = profile.Address;
                user.LibraryCardNumber = profile.LibraryCardNumber;
            }
            return user;
        }

        public Task<bool> UserExistsAsync(string username)
        {
            var normalizedUsername = _userManager.NormalizeName(username);
            return _userManager.Users.AnyAsync(user => user.NormalizedUserName == normalizedUsername);
        }

        public async Task<OperationResult> CreateAsync(UserCreateModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            var user = new ApplicationUser
            {
                //DisplayName = string.Join(" ", model.FirstName.Trim(), model.Surname?.Trim(), model.LastName.Trim()),
                UserName = model.UserName,
                Email = model.Email,
                UserType = model.UserType,
                //UserProfileType = model.UserProfileType,
                AuthenticationType = model.AuthenticationType,
                EmailConfirmed = true,
                CreatedBy = _userInfo.CurrentUserId,
                CreatedOn = DateTime.UtcNow,
            };

            var userResult = await _userManager.CreateAsync(user);
            if (!userResult.Succeeded)
            {
                return OperationResult.Failed(userResult.ToString());
            }

            var addArchivesResult = await AddToArchivesAsync(user.Id, model.Archives);
            if (!addArchivesResult.Succeeded)
            {
                var errors = addArchivesResult.Errors.ToList();
                var cleanupResult = await CleanupUserAsync(user);
                if (!cleanupResult.Succeeded)
                {
                    errors.AddRange(cleanupResult.Errors);
                }
                return OperationResult.Failed(errors.ToArray());
            }

            var addRolesResult = await AddToRolesAsync(user, model.Roles);
            if (!addRolesResult.Succeeded)
            {
                var errors = addRolesResult.Errors.ToList();
                var cleanupResult = await CleanupUserAsync(user);
                if (!cleanupResult.Succeeded)
                {
                    errors.AddRange(cleanupResult.Errors);
                }
                return OperationResult.Failed(errors.ToArray());
            }

            var profile = new UserProfileModel()
            {
                UserId = user.Id,
                ProfileType = model.UserProfileType!,
                FirstName = model.FirstName,
                Surname = model.Surname,
                LastName = model.LastName,
                Organization = model.Organization,
                Department = model.Department,
                JobTitle = model.JobTitle,
            };
            var profileResult = await _userProfileService.CreateProfileAsync(profile);
            if (!profileResult.Succeeded)
            {
                var errors = profileResult.Errors.ToList();
                var cleanupResult = await CleanupUserAsync(user);
                if (!cleanupResult.Succeeded)
                {
                    errors.AddRange(cleanupResult.Errors);
                }
                return OperationResult.Failed(errors.ToArray());
            }

            return OperationResult.Success;
        }

        public async Task<OperationResult> UpdateAsync(UserEditModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var appUser = await _userManager.FindByIdAsync(model.Id.ToString());

            string normalizedName = _userManager.NormalizeName(model.UserName);
            if (!appUser.NormalizedUserName.Equals(normalizedName))
            {
                var userExists = await _userManager.Users.AnyAsync(user => user.NormalizedUserName == normalizedName);
                if (userExists)
                {
                    return OperationResult.Failed(false,String.Format(_localizer.GetString("Error_UserExists").ToString(), model.UserName));
                }
            }

            var profile = await _userProfileService.GetProfileAsync(appUser.Id);
            if (profile != null)
            {
                profile.FirstName = model.FirstName;
                profile.Surname = model.Surname;
                profile.LastName = model.LastName;
                profile.Organization = model.Organization;
                profile.Department = model.Department;
                profile.JobTitle = model.JobTitle;

                var profileResult = await _userProfileService.UpdateProfileAsync(profile);
                if (!profileResult.Succeeded)
                {
                    return OperationResult.Failed(profileResult.ToString());
                }
            }

            appUser.UserName = model.UserName;
            //appUser.DisplayName = $"{model.FirstName} {model.Surname} {model.LastName}";
            appUser.Email = model.Email;
            appUser.UpdatedOn = DateTime.UtcNow;
            appUser.UpdatedBy = _userInfo.CurrentUserId;
            appUser.SecurityStamp = Guid.NewGuid().ToString();

            var userUpdateResult = await _userManager.UpdateAsync(appUser);
            if (!userUpdateResult.Succeeded)
            {
                return OperationResult.Failed(userUpdateResult.ToString());
            }

            var removeRolesResult = await RemoveUserRolesAsync(appUser);
            if (!removeRolesResult.Succeeded)
            {
                return OperationResult.Failed(removeRolesResult.ToString());
            }

            var removeArchivesResult = await RemoveUserArchivesAsync(appUser.Id);
            if (!removeArchivesResult.Succeeded)
            {
                return OperationResult.Failed(removeArchivesResult.ToString());
            }

            var addArchivesResult = await AddToArchivesAsync(model.Id, model.Archives);
            if (!addArchivesResult.Succeeded)
            {
                return OperationResult.Failed(addArchivesResult.ToString());
            }

            var addRolesResult = await AddToRolesAsync(appUser, model.Roles);
            if (!addRolesResult.Succeeded)
            {
                return OperationResult.Failed(addRolesResult.ToString());
            }

            return OperationResult.Success;
        }

        public async Task<OperationResult> DeleteAsync(Guid id)
        {
            var appUser = await _userManager.FindByIdAsync(id.ToString());
            if (appUser == null)
            {
                return OperationResult.Failed(String.Format(_localizer.GetString("Error_UserDoesNotExists"), id));
            }

            var profileResult = await _userProfileService.DeleteProfileAsync(id);
            if (!profileResult.Succeeded)
            {
                return OperationResult.Failed(profileResult.ToString());
            }

            appUser.UserName = $"{appUser.UserName}_deleted_{appUser.Id}";
            appUser.Email = $"{appUser.Email}_deleted_{appUser.Id}";
            appUser.Deleted = true;
            appUser.DeletedOn = DateTime.UtcNow;
            appUser.DeletedBy = _userInfo.CurrentUserId;

            var result = await _userManager.UpdateAsync(appUser);
            if (!result.Succeeded)
            {
                return OperationResult.Failed(result.ToString());
            }

            return OperationResult.Success;
        }

        public async Task<string> ResetPasswordToken(Guid id)
        {
            string code = String.Empty;
            var user = await _userManager.FindByIdAsync(id.ToString());
            if (user == null)
            {
                throw new Exception(String.Format(_localizer.GetString("Error_UserDoesNotExists"), id));
            }
            code = await _userManager.GeneratePasswordResetTokenAsync(user);

            return code;
        }

        public async Task<OperationResult> AddToArchivesAsync(Guid id, IEnumerable<int> archiveIds)
        {
            try
            {
                var archives = archiveIds.Select(aid => new AspNetUserArchive() { ArchiveId = aid, UserId = id });
                _context.AspNetUserArchives.AddRange(archives);

                await _context.SaveAsync("User archives added");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> RemoveUserArchivesAsync(Guid id)
        {
            try
            {
                var userArchives = _context.AspNetUserArchives.Where(ua => ua.UserId == id);
                _context.AspNetUserArchives.RemoveRange(userArchives);

                await _context.SaveAsync("User archives removed");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> AddToRoleAsync(Guid id, Guid roleId)
        {
            var user = await _userManager.FindByIdAsync(id.ToString("D"));
            if (user == null)
            {
                return OperationResult.Failed(String.Format(_localizer.GetString("Error_UserDoesNotExists"), id));
            }

            if (!await _userManager.IsInRoleAsync(user, roleId))
            {
                var result = await _userManager.AddToRoleAsync(user, roleId);
                if (!result.Succeeded)
                {
                    return OperationResult.Failed(result.ToString());
                }
            }
            return OperationResult.Success;
        }

        public async Task<OperationResult> AddToRolesAsync(Guid id, IEnumerable<Guid> roleIds)
        {
            if (roleIds == null)
            {
                throw new ArgumentNullException(nameof(roleIds));
            }

            var user = await _userManager.FindByIdAsync(id.ToString("D"));
            if (user == null)
            {
                return OperationResult.Failed(String.Format(_localizer.GetString("Error_UserDoesNotExists"), id));
            }

            var result = await AddToRolesAsync(user, roleIds);
            if (!result.Succeeded)
            {
                return OperationResult.Failed(result.ToString());
            }

            return OperationResult.Success;
        }

        private async Task<OperationResult> AddToRolesAsync(ApplicationUser user, IEnumerable<Guid> roleIds)
        {
            if (user == null)
            {
                throw new ArgumentNullException(nameof(user));
            }
            if (roleIds == null)
            {
                throw new ArgumentNullException(nameof(roleIds));
            }

            var result = await _userManager.AddToRolesAsync(user, roleIds);

            if (!result.Succeeded)
            {
                return OperationResult.Failed(result.ToString());
            }

            return OperationResult.Success;
        }

        public async Task<OperationResult> RemoveFromRoleAsync(Guid id, Guid roleId)
        {
            var user = await _userManager.FindByIdAsync(id.ToString("D"));
            if (user == null)
            {
                return OperationResult.Failed(String.Format(_localizer.GetString("Error_UserDoesNotExists"), id));
            }

            if (await _userManager.IsInRoleAsync(user, roleId))
            {
                var result = await _userManager.RemoveFromRoleAsync(user, roleId);
                if (!result.Succeeded)
                {
                    return OperationResult.Failed(result.ToString());
                }
            }
            return OperationResult.Success;
        }

        public async Task<OperationResult> RemoveFromRolesAsync(Guid id, IEnumerable<Guid> roleIds)
        {
            if (roleIds == null)
            {
                throw new ArgumentNullException(nameof(roleIds));
            }

            var user = await _userManager.FindByIdAsync(id.ToString("D"));
            if (user == null)
            {
                return OperationResult.Failed(String.Format(_localizer.GetString("Error_UserDoesNotExists"), id));
            }

            var result = await _userManager.RemoveFromRolesAsync(user, roleIds);
            if (!result.Succeeded)
            {
                return OperationResult.Failed(result.ToString());
            }

            return OperationResult.Success;
        }

        public async Task<OperationResult> RemoveUserRolesAsync(Guid id)
        {
            var user = await _userManager.FindByIdAsync(id.ToString("D"));
            var removeRolesResult = await RemoveUserRolesAsync(user);
            if (!removeRolesResult.Succeeded)
            {
                return OperationResult.Failed(removeRolesResult.ToString());
            }

            return OperationResult.Success;
        }

        private async Task<OperationResult> RemoveUserRolesAsync(ApplicationUser user)
        {
            var userRoles = await _userManager.GetRolesIdentifiersAsync(user);
            var removeRolesResult = await _userManager.RemoveFromRolesAsync(user, userRoles);
            if (!removeRolesResult.Succeeded)
            {
                return OperationResult.Failed(removeRolesResult.ToString());
            }

            return OperationResult.Success;
        }

        public async Task<List<Guid>> GetUsersInRole(Guid roleId)
        {
            var users = await _context.AspNetUsers
                .Where(x => !x.Deleted && x.Roles.Where(r => r.Id == roleId).Count() > 0)
                .Select(u => u.Id)
                .ToListAsync();

            return users;
        }

        public DataSourceResponseModel<UserDisplayModel> GetByProfileType(DataSourceRequestModel model, string pofileType, bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.AspNetUsers
                .Where(u => u.AspNetUserProfileUsers.Where(up => up.UserId == u.Id && !up.Deleted).FirstOrDefault().ProfileType == pofileType)
                .Select(u => new UserDisplayModel()
                {
                    Id = u.Id,
                    AuthenticationType = u.AuthenticationType,
                    CertificateThumbprint = u.CertificateThumbprint,
                    CreatedBy = u.CreatedBy,
                    CreatedByDisplayName = u.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == u.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = u.CreatedByNavigation.UserName,
                    CreatedOn = u.CreatedOn,
                    Deleted = u.Deleted,
                    DeletedBy = u.DeletedBy,
                    DeletedByDisplayName = u.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == u.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = u.DeletedByNavigation.UserName,
                    DeletedOn = u.DeletedOn,
                    DisplayName = u.AspNetUserProfileUsers.Where(up => up.UserId == u.Id && !up.Deleted).FirstOrDefault().DisplayName!,
                    Email = u.Email!,
                    UpdatedBy = u.UpdatedBy,
                    UpdatedByDisplayName = u.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == u.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = u.UpdatedByNavigation.UserName,
                    UpdatedOn = u.UpdatedOn,
                    UserName = u.UserName!,
                    EmailConfirmed = u.EmailConfirmed,
                    UserProfileType = u.AspNetUserProfileUsers.Where(up => up.UserId == u.Id && !up.Deleted).FirstOrDefault().ProfileType,
                    UserType = u.UserType,
                });
            if (!includeDeleted)
            {
                query = query.Where(u => !u.Deleted);
            }

            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }
            query = query.OrderBy(u => u.Deleted).ThenBy(u => u.UserName).ThenBy(u => u.DisplayName);

            QueryResponseModel<UserDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<UserDisplayModel> result = new DataSourceResponseModel<UserDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => new UserDisplayModel()
                {
                    Id = x.Id,
                    AuthenticationType = x.AuthenticationType,
                    CertificateThumbprint = x.CertificateThumbprint,
                    CreatedBy = x.CreatedBy,
                    CreatedByDisplayName = x.CreatedByDisplayName,
                    CreatedByUserName = x.CreatedByUserName,
                    CreatedOn = x.CreatedOn.UtcToLocalTime(),
                    Deleted = x.Deleted,
                    DeletedBy = x.DeletedBy,
                    DeletedByDisplayName = x.DeletedByDisplayName,
                    DeletedByUserName = x.DeletedByUserName,
                    DeletedOn = x.DeletedOn.UtcToLocalTime(),
                    DisplayName = x.DisplayName!,
                    Email = x.Email!,
                    UpdatedBy = x.UpdatedBy,
                    UpdatedByDisplayName = x.UpdatedByDisplayName,
                    UpdatedByUserName = x.UpdatedByUserName,
                    UpdatedOn = x.UpdatedOn.UtcToLocalTime(),
                    UserName = x.UserName!,
                    EmailConfirmed = x.EmailConfirmed,
                    UserProfileType = x.UserProfileType,
                    UserType = x.UserType,
                })
            };

            return result;
        }

        public async Task<string> ChangePassword(ApplicationUser user, string newPassword)
        {
            try
            {
                PasswordHasher<ApplicationUser> passwordHasher = new PasswordHasher<ApplicationUser>();

                AspNetUser aspNetUser = _context.AspNetUsers.Where(u => user.Id == u.Id).FirstOrDefault();
                aspNetUser.PasswordHash = passwordHasher.HashPassword(user, newPassword);
                _context.Update(aspNetUser);
                await _context.SaveChangesAsync();

                return "Success";
            }
            catch (Exception ex)
            {
                return "Failed";
            }
        }

        //public async Task<OperationResult> AddClaimAsync(string id, string claimType, string claimValue)
        //{
        //    var user = await _userManager.FindByIdAsync(id);
        //    if (user == null)
        //    {
        //        return OperationResult.Failed(_localizer.GetString("Error_UserDoesNotExists").ToString());
        //    }
        //    var claims = await _userManager.GetClaimsAsync(user);
        //    if (claims.FirstOrDefault(claim => claim.Type == claimType && claim.Value == claimValue) == null)
        //    {
        //        var addClaimResult = await _userManager.AddClaimAsync(user, new Claim(claimType, claimValue));
        //        if (!addClaimResult.Succeeded)
        //        {
        //            return OperationResult.Failed(addClaimResult.Errors.Select(err => err.Description).ToArray());
        //        }
        //    }
        //    return OperationResult.Success;
        //}

        //public async Task<OperationResult> RemoveClaimAsync(string id, string claimType, string claimValue)
        //{
        //    var user = await _userManager.FindByIdAsync(id);
        //    if (user == null)
        //    {
        //        return OperationResult.Failed(_localizer.GetString("Error_UserDoesNotExists").ToString());
        //    }
        //    var claims = await _userManager.GetClaimsAsync(user);
        //    var claimToRemove = claims.FirstOrDefault(claim => claim.Type == claimType && claim.Value == claimValue);
        //    if (claimToRemove != null)
        //    {
        //        var removeClaimResult = await _userManager.RemoveClaimAsync(user, claimToRemove);
        //        if (!removeClaimResult.Succeeded)
        //        {
        //            return OperationResult.Failed(removeClaimResult.Errors.Select(err => err.Description).ToArray());
        //        }
        //    }
        //    return OperationResult.Success;
        //}
    }
}
