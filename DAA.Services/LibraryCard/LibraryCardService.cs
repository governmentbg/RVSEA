
using DAA.Data;
using DAA.Models.Configuration;
using DAA.Shared.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace DAA.Services.LibraryCardService
{
    public class LibraryCardService : BaseService, ILibraryCardService

    {
        private readonly IUserInfo _userInfo;
        private readonly LinkedServerSettings _linkedServerSettings;

        public const string CannotValidateLibraryCardBecauseOfISDAConnectionMissingMessageKey = "cannotValidateLibraryCardBecauseOfISDAConnectionMissing";

        public LibraryCardService(
           ArchivingContext context,
           IOptions<LinkedServerSettings> linkedServerConfig,
           IUserInfo userInfo) : base(context)
        {
            _userInfo = userInfo;
            _linkedServerSettings = linkedServerConfig.Value;
        }

        public async Task<bool> IsValid(string number)
        {
            return await IsValidInner(number);
        }

        public async Task<bool> IsValidCardOfCurrentUser(Guid? userId = null)
        {
            var profile = await _context.AspNetUserProfiles
                .SingleOrDefaultAsync(x => x.UserId == (userId ?? _userInfo.CurrentUserId) && x.LibraryCardNumber != null);

            if (profile == null || profile.LibraryCardNumber == null)
            {
                return false; // при регистрация потребител с роля Читател трябва да въведе номер на карта
            }

            return await IsValidInner(profile.LibraryCardNumber);
        }

        public async Task<bool> IsExpiringInAWeekCurrentUser(Guid? userId = null)
        {
            var profile = await _context.AspNetUserProfiles
                .SingleOrDefaultAsync(x => x.UserId == (userId ?? _userInfo.CurrentUserId) && x.LibraryCardNumber != null);

            if (profile == null || profile.LibraryCardNumber == null)
            {
                return false; // при регистрация потребител с роля Читател трябва да въведе номер на карта
            }
            // при exec тр да се подаде Int!!!
            int numberAfterParse = int.Parse(profile.LibraryCardNumber);

            var records = await _context.LibraryCards.FromSqlRaw("EXECUTE dbo.GetLibraryCard {0},{1}",
                _linkedServerSettings.LinkedServer!,
               numberAfterParse
            ).ToListAsync();

            bool isExpiring = records.Count == 1 && records[0].ValidFrom < DateTime.UtcNow && records[0].ValidTo <= DateTime.UtcNow.AddDays(7);
            return isExpiring;
        }

        private async Task<bool> IsValidInner(string number)
        {
            // при exec тр да се подаде Int!!!
            int numberAfterParse = int.Parse(number);

            var records = await _context.LibraryCards.FromSqlRaw("EXECUTE dbo.GetLibraryCard {0},{1}",
                _linkedServerSettings.LinkedServer!,
               numberAfterParse
            ).ToListAsync();

            var isValid = records.Count == 1 && records[0].ValidFrom < DateTime.UtcNow && records[0].ValidTo > DateTime.UtcNow;

            return isValid;
        }
    }
}
