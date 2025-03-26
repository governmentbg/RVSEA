using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Models;
using DAA.Models.Archives;
using DAA.Models.Configuration;
using DAA.Services.Roles;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;
using System.Text;

namespace DAA.Services
{
    public class ArchiveService : BaseService, IArchiveService
    {
        private readonly LinkedServerSettings _settings;
        private readonly IUserInfo _userInfo;
        private readonly IRoleService _roleService;

        public ArchiveService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IOptions<LinkedServerSettings> settings,
            IUserInfo userInfo,
            IRoleService roleService)
            : base(context, localizer)
        {
            _settings = settings.Value;
            _userInfo = userInfo;
            _roleService = roleService;
        }

        public DataSourceResponseModel<ArchiveDisplayModel> GetAll(DataSourceRequestModel model, bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.Archives
                .Select(a => new ArchiveDisplayModel()
                {
                    Id = a.Id,
                    Name = a.Name,
                    Code = a.Code,
                    SortOrder = a.SortOrder,
                    HasExternalSource = a.HasExternalSource,
                    ExternalIdentifier = a.ExternalIdentifier,
                    CreatedBy = a.CreatedBy,
                    CreatedByDisplayName = a.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == a.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = a.CreatedByNavigation.UserName,
                    CreatedOn = a.CreatedOn,
                    Deleted = a.Deleted,
                    DeletedBy = a.DeletedBy,
                    DeletedByDisplayName = a.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == a.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = a.DeletedByNavigation.UserName,
                    DeletedOn = a.DeletedOn,
                    UpdatedBy = a.UpdatedBy,
                    UpdatedByDisplayName = a.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == a.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = a.UpdatedByNavigation.UserName,
                    UpdatedOn = a.UpdatedOn,

                });
            if (!includeDeleted)
            {
                query = query.Where(a => !a.Deleted);
            }

            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }
            query = query.OrderBy(a => a.Deleted).ThenBy(a => a.SortOrder);

            QueryResponseModel<ArchiveDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<ArchiveDisplayModel> result = new DataSourceResponseModel<ArchiveDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x =>  new ArchiveDisplayModel()
                {
                    Id = x.Id,
                    Name = x.Name,
                    Code = x.Code,
                    SortOrder = x.SortOrder,
                    HasExternalSource = x.HasExternalSource,
                    CreatedBy = x.CreatedBy,
                    CreatedByDisplayName = x.CreatedByDisplayName,
                    CreatedByUserName = x.CreatedByUserName,
                    CreatedOn = x.CreatedOn.UtcToLocalTime(),
                    Deleted = x.Deleted,
                    DeletedBy = x.DeletedBy,
                    DeletedByDisplayName = x.DeletedByDisplayName,
                    DeletedByUserName = x.DeletedByUserName,
                    DeletedOn = x.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = x.UpdatedBy,
                    UpdatedByDisplayName = x.UpdatedByDisplayName,
                    UpdatedByUserName = x.UpdatedByUserName,
                    UpdatedOn = x.UpdatedOn.UtcToLocalTime(),
                })
            };

            return result;
        }

        public IQueryable<ArchiveDisplayModel> GetBySearchText(string searchText)
        {
            var query = _context.Archives.Where(a => !a.Deleted);
            if (!string.IsNullOrEmpty(searchText) && !string.IsNullOrWhiteSpace(searchText))
            {
                query = query.Where(a => a.Name.Contains(searchText));
            }
            query = query.OrderBy(a => a.SortOrder);

            var archives = query.Select(a => new ArchiveDisplayModel()
            {
                Id = a.Id,
                Name = a.Name,
                Code = a.Code,
                SortOrder = a.SortOrder,
                HasExternalSource = a.HasExternalSource,
                ExternalIdentifier = a.ExternalIdentifier,
                CreatedBy = a.CreatedBy,
                CreatedByDisplayName = a.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == a.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                CreatedByUserName = a.CreatedByNavigation.UserName,
                CreatedOn = a.CreatedOn.UtcToLocalTime(),
                Deleted = a.Deleted,
                DeletedBy = a.DeletedBy,
                DeletedByDisplayName = a.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == a.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                DeletedByUserName = a.DeletedByNavigation.UserName,
                DeletedOn = a.DeletedOn.UtcToLocalTime(),
                UpdatedBy = a.UpdatedBy,
                UpdatedByDisplayName = a.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == a.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                UpdatedByUserName = a.UpdatedByNavigation.UserName,
                UpdatedOn = a.UpdatedOn.UtcToLocalTime(),

            });
            return archives;
        }

        public async Task<ArchiveDisplayModel?> GetById(int id)
        {
            var archive =
                await _context.Archives
                .Where(a => a.Id == id)
                .Select(a => new ArchiveDisplayModel()
                {
                    Id = a.Id,
                    Name = a.Name,
                    Code = a.Code,
                    SortOrder = a.SortOrder,
                    HasExternalSource = a.HasExternalSource,
                    ExternalIdentifier = a.ExternalIdentifier,
                    CreatedBy = a.CreatedBy,
                    CreatedByDisplayName = a.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == a.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = a.CreatedByNavigation.UserName,
                    CreatedOn = a.CreatedOn.UtcToLocalTime(),
                    Deleted = a.Deleted,
                    DeletedBy = a.DeletedBy,
                    DeletedByDisplayName = a.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == a.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = a.DeletedByNavigation.UserName,
                    DeletedOn = a.DeletedOn.UtcToLocalTime(),
                    UpdatedBy = a.UpdatedBy,
                    UpdatedByDisplayName = a.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == a.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = a.UpdatedByNavigation.UserName,
                    UpdatedOn = a.UpdatedOn.UtcToLocalTime(),

                })
                .SingleOrDefaultAsync();

            return archive;
        }

        public async Task<OperationResult> CreateAsync(ArchiveModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            try
            {
                var archive = new Archive
                {
                    Name = model.Name,
                    Code = model.Code,
                    SortOrder = model.SortOrder,
                    HasExternalSource = model.HasExternalSource,
                    ExternalIdentifier = model.ExternalIdentifier,
                };

                _context.Archives.Add(archive);
                await _context.SaveAsync("Archive created");

                var result = await _roleService.CreateRolesForArchiveAsync(archive.Id);
                if (!result.Succeeded)
                {
                    return OperationResult.Failed(result.RawErrors, result.Errors.ToArray());
                }

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> UpdateAsync(ArchiveModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            try
            {
                var archive = await _context.Archives.FindAsync(model.Id);
                if (archive == null)
                {
                    return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                archive.Name = model.Name;
                archive.Code = model.Code;
                archive.SortOrder = model.SortOrder;
                archive.HasExternalSource = model.HasExternalSource;
                archive.ExternalIdentifier = model.ExternalIdentifier;

                _context.Update(archive);
                await _context.SaveAsync("Archive updated");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> DeleteAsync(int id)
        {
            try
            {
                var archive = await _context.Archives.FindAsync(id);
                if (archive == null)
                {
                    return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                archive.Deleted = true;
                archive.DeletedOn = DateTime.UtcNow;
                archive.DeletedBy = _userInfo.CurrentUserId;

                _context.Update(archive);
                await _context.SaveAsync("Archive deleted");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<IEnumerable<ArchiveDisplayModel>?> GetFromExternalSourceBySearchTextAsync(string searchText)
        {
            if (string.IsNullOrEmpty(searchText.Trim()))
            {
                return null;
            }
            string query = "exec sp_GetArchives @LinkedServer, @SearchText";
            List<SqlParameter> queryParams = new List<SqlParameter>()
            {
                new SqlParameter("LinkedServer", _settings.LinkedServer),
                new SqlParameter("SearchText", searchText),
            };
            var result = await _context.Archives
                    .FromSqlRaw(query, queryParams.ToArray())
                    .AsNoTracking()
                    .ToListAsync();

            return result.Select(a => new ArchiveDisplayModel()
            {
                Code = a.Code,
                ExternalIdentifier = a.ExternalIdentifier,
                HasExternalSource = a.HasExternalSource,
                Name = a.Name,
                SortOrder = a.SortOrder,
            });
        }

        public async Task<int> GetArchiveIdByCodeAsync(int code)
        {
            return
                await _context.Archives
                .Where(a => a.Code == code)
                .Select(a => a.Id)
                .SingleOrDefaultAsync();
        }

        public async Task<int?> GetExternalIdentifierAsync(int code)
        {
            return
                await _context.Archives
                .Where(a => a.Code == code && !a.Deleted)
                .Select(a => a.ExternalIdentifier)
                .SingleOrDefaultAsync();
        }

        public async Task<OperationResult> GetDiroctorNameByArchiveId(int id)
        {
            try
            {
                string archiveDirectorName = await _context.AspNetUserProfiles
                    .Where(up => up.User.Roles.Any(r => r.Abbreviation.Contains("G") && r.ArchiveId == id)).Select(s => s.DisplayName)
                    .FirstOrDefaultAsync();

                if (!String.IsNullOrEmpty(archiveDirectorName))
                {
                    return OperationResult.Succeed(archiveDirectorName);
                }

                return OperationResult.Failed(archiveDirectorName);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }
    }
}
