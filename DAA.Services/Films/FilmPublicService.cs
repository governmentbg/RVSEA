using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Models;
using DAA.Models.Configuration;
using DAA.Models.Films;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;

namespace DAA.Services.Films
{
    public class FilmPublicService : BaseService, IFilmPublicService
    {
        private readonly IsdaEServicesLink _isdaEServicesLink;
        private readonly IUserInfo _userInfo;


        public FilmPublicService(
            ArchivingContext context,
            IOptions<IsdaEServicesLink> link,
            IUserInfo userInfo,
            IStringLocalizer<SharedResources> localizer = null)
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _isdaEServicesLink = link.Value;
        }

        public DataSourceResponseModel<FilmReaderDisplayModel> GetAllForReader(DataSourceRequestModel model, bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }
            var userId = _userInfo.CurrentUserId;

            var query =
                _context.VFilms
                .Where(f => _context.VFilmReviews
                                    .Any(fv => fv.FilmSystemIdentifier == f.SystemIdentifier && fv.AccessAllowed == true && fv.UserId == userId))
                .Select(f => new FilmReaderDisplayModel()
                {
                    Id = f.Id,
                    SystemIdentifier = f.SystemIdentifier,
                    Title = _context.FilmCards
                                    .Where(c => c.FilmSystemIdentifier == f.SystemIdentifier)
                                    .Select(c => c.Title)
                                    .FirstOrDefault(),
                    ArchiveId = f.ArchiveId,
                    ArchiveName = f.ArchiveName,
                    InventoryNumber = f.InventoryNumber,
                    CountryName = f.CountryName,
                    FramesCount = f.FramesCount,
                    MicrofilmNegativeRollsCount = f.MicrofilmNegativeRollsCount,
                    MicrofilmNegativeFramesCount = f.MicrofilmNegativeFramesCount,
                    MicrofilmPositiveRollsCount = f.MicrofilmPositiveRollsCount,
                    MicrofilmPositiveFramesCount = f.MicrofilmPositiveFramesCount,
                    PhotoCopy = f.PhotoCopy,
                    DigitalCopy = f.DigitalCopy,
                    Size = f.Size,
                    Other = f.Other,
                    Deleted = f.Deleted
                });

            if (!includeDeleted)
            {
                query = query.Where(f => !f.Deleted);
            }

            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }

            QueryResponseModel<FilmReaderDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<FilmReaderDisplayModel> result = new DataSourceResponseModel<FilmReaderDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => x)
            };

            return result;
        }

        public async Task<OperationResult?> GetBySystemIdentifierAsync(Guid sysId)
        {
            var entity =
                await _context.Films
                .Include(x => x.Archive)
                .Include(x => x.Country)
                .Where(x => x.SystemIdentifier == sysId && !x.Deleted)
                .Where(x => x.SystemIdentifier == sysId && !x.Deleted)
                .Select(x => new FilmPublicDisplayModel
                {
                    SystemIdentifier = x.SystemIdentifier,
                    ArchiveName = x.Archive.Name,
                    InventoryNumber = x.InventoryNumber,
                    CountryName = x.Country.Text,
                    Content = x.Content,
                    FramesCount = x.FramesCount,
                    MicrofilmNegativeRollsCount = x.MicrofilmNegativeRollsCount,
                    MicrofilmNegativeFramesCount = x.MicrofilmNegativeFramesCount,
                    MicrofilmPositiveRollsCount = x.MicrofilmPositiveRollsCount,
                    MicrofilmPositiveFramesCount = x.MicrofilmPositiveFramesCount,
                    PhotoCopy = x.PhotoCopy,
                    DigitalCopy = x.DigitalCopy,
                    Size = x.Size,
                    Other = x.Other,
                    AcceptedOnDay = x.AcceptedOnDay,
                    AcceptedOnMonth = x.AcceptedOnMonth,
                    AcceptedOnYear = x.AcceptedOnYear,
                    Source = x.Source,
                    Notes = x.Notes,
                    PackageAId = x.PackageAid,
                    PackageBId = x.PackageBid,
                }).FirstOrDefaultAsync();
            if (entity == null)
            {
                return OperationResult.Failed("");
            }
            return OperationResult.Succeed(entity);
        }

        public Task<FilmPublicDisplayModel?> GetFromExternalSourceAsync(int externalIdentifier, Guid? systemIdentifier = null)
        {
            throw new NotImplementedException();
        }

        public OperationResult GetIsdaEServicesLink()
        {
            string link = _isdaEServicesLink.Link;

            if (link == null)
            {
                return OperationResult.Failed("");
            }

            return OperationResult.Succeed(link);
        }
    }
}
