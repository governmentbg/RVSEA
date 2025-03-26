using DAA.Data;
using DAA.Models.Authentication;
using DAA.Models.Configuration;
using DAA.Models.Users;
using DAA.Services.LibraryCardService;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Services.Users
{
    public class UserProfileService : BaseService, IUserProfileService
    {
        private readonly IUserInfo _userInfo;
        private readonly LinkedServerSettings _linkedServerSettings;
        public UserProfileService(
            ArchivingContext context,
            IOptions<LinkedServerSettings> linkedServerConfig,
            IStringLocalizer<SharedResources> localizer,
            IUserInfo userInfo)
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _linkedServerSettings = linkedServerConfig.Value;
        }

        public async Task<UserProfileModel?> GetProfileAsync(Guid userId)
        {
            if (userId == Guid.Empty)
            {
                throw new ArgumentNullException(nameof(userId));
            }

            var profile = await _context.AspNetUserProfiles
                .Where(p => p.UserId == userId)
                .Include(p => p.User)
                .Select(p => new UserProfileModel()
                {
                    Id = p.Id,
                    UserId = p.UserId,
                    EntityType = p.EntityType,
                    Email = p.User.Email,
                    ProfileType = p.ProfileType!,
                    Address = p.Address,
                    Department = p.Department,
                    FirstName = p.FirstName,
                    LastName = p.LastName,
                    JobTitle = p.JobTitle,
                    Organization = p.Organization,
                    Surname = p.Surname,
                    LibraryCardNumber = p.LibraryCardNumber,
                    Eik = p.Eik,
                    Phone = p.PhoneNumber,
                    DisplayName = p.DisplayName,
                    UserName = p.User.UserName
                })
                .FirstOrDefaultAsync();

            if (profile!.LibraryCardNumber != null && profile.ProfileType == Shared.Security.ApplicationUserProfileType.CardHolder)
            {
                var libaryCards = await _context.LibraryCards.FromSqlRaw("EXECUTE dbo.GetLibraryCard {0},{1}",
                                  _linkedServerSettings.LinkedServer!,
                                  int.Parse(profile.LibraryCardNumber)).ToListAsync();

                if (libaryCards.Count > 0)
                {
                    profile.LibraryCardValidTo = libaryCards[0].ValidTo;
                }
              
                return profile;
            }
            return profile;
        }
        public async Task<OperationResult> CreateProfileAsync(UserProfileModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {
                var profile = new AspNetUserProfile()
                {
                    UserId = model.UserId,
                    ProfileType = model.ProfileType,
                    EntityType = model.EntityType,
                    Address = model.Address,
                    FirstName = model.FirstName,
                    Surname = model.Surname,
                    LastName = model.LastName,
                    Department = model.Department,
                    JobTitle = model.JobTitle,
                    Organization = model.Organization,
                    LibraryCardNumber = model.LibraryCardNumber,
                    Eik = model.Eik,
                    PhoneNumber = model.Phone
                };

                _context.AspNetUserProfiles.Add(profile);
                await _context.SaveAsync(_localizer.GetString("UserProfileCreated").ToString());
            }
            catch (Exception ex)
            {
                return OperationResult.Failed(ex.ToString());
            }
            return OperationResult.Success;
        }
        public async Task<OperationResult> UpdateProfileAsync(UserProfileModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {
                var profile = await _context.AspNetUserProfiles.FindAsync(model.Id);
                if (profile == null)
                {
                    return OperationResult.Failed(_localizer.GetString("Error_UserProfileDoesNotExists").ToString());
                }

                profile.ProfileType = model.ProfileType;
                profile.EntityType = model.EntityType;
                profile.Address = model.Address;
                profile.FirstName = model.FirstName;
                profile.Surname = model.Surname;
                profile.LastName = model.LastName;
                profile.Department = model.Department;
                profile.JobTitle = model.JobTitle;
                profile.Organization = model.Organization;
                profile.LibraryCardNumber = model.LibraryCardNumber;
                profile.PhoneNumber = model.Phone;
                profile.Eik = model.Eik;
              
                _context.AspNetUserProfiles.Update(profile);

                await _context.SaveAsync("Profile updated");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }
        public async Task<OperationResult> DeleteProfileAsync(Guid userId)
        {
            try
            {
                var profile =
                    await _context.AspNetUserProfiles
                        .Where(p => p.UserId == userId && !p.Deleted)
                        .FirstOrDefaultAsync();
                //if (profile == null)
                //{
                //    return OperationResult.Failed(_localizer.GetString("Error_UserProfileDoesNotExists").ToString());
                //}
                if (profile != null)
                {
                    profile.Deleted = true;
                    profile.DeletedBy = _userInfo.CurrentUserId;
                    profile.DeletedOn = DateTime.UtcNow;

                    _context.AspNetUserProfiles.Update(profile);

                    await _context.SaveAsync("Profile deleted");
                }
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<InternalUserProfileModel?> GetProfileAndProfileRoles(Guid userId)
        {
            var roles = _context.AspNetUsers.Where(u => u.Id == userId).Select(u => u.Roles).FirstOrDefault();

            return await _context.AspNetUserProfiles
              .Where(p => p.UserId == userId)
              .Select(p => new InternalUserProfileModel()
              {
                  Id = p.Id,
                  UserId = p.UserId,
                  EntityType = p.EntityType,
                  Email = p.User.Email,
                  ProfileType = p.ProfileType!,
                  Address = p.Address,
                  Department = p.Department,
                  FirstName = p.FirstName,
                  LastName = p.LastName,
                  JobTitle = p.JobTitle,
                  Organization = p.Organization,
                  Surname = p.Surname,
                  LibraryCardNumber = p.LibraryCardNumber,
                  Archives = _context.AspNetUserArchives.Where(a => a.UserId == p.UserId).Select(a => a.ArchiveId).ToList(),
                  Roles = roles.Select(r => r.Id).ToList(),
              }).FirstOrDefaultAsync();
        }
    }
}
