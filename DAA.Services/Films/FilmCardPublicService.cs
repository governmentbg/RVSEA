using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Models;
using DAA.Models.Configuration;
using DAA.Models.Films;
using DAA.Services.Nomenclatures;
using DAA.Services.Process;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;
using System.Data.SqlClient;

namespace DAA.Services.Films
{
    public class FilmCardPublicService : BaseService, IFilmCardPublicService
    {
        private readonly IUserInfo _userInfo;
        private readonly INomenclatureService _nomenclatureService;
        private readonly LinkedServerSettings _linkedServerSettings;
        private readonly IArchiveService _archiveService;
  

        public FilmCardPublicService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IOptions<LinkedServerSettings> settings,
            IUserInfo userInfo,
            INomenclatureService nomenclatureService,
            IArchiveService archiveService,
            IProcessService processService)
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _nomenclatureService = nomenclatureService;
            _linkedServerSettings = settings.Value;
            _archiveService = archiveService;
          
        }

        public DataSourceResponseModel<FilmCardShortPublicModel> GetAll(DataSourceRequestModel model, Guid? filmSysId, bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.VFilmCards
                .Where(x => x.FilmSystemIdentifier == filmSysId)
                .OrderBy(x => x.InventoryNumber)
                .AsQueryable();

            if (!includeDeleted)
            {
                query = query.Where(f => !f.Deleted);
            }

            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }

            QueryResponseModel<VFilmCard> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<FilmCardShortPublicModel> result = new DataSourceResponseModel<FilmCardShortPublicModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => x.ToShortPublicModel())
            };

            return result;
        }


        public async Task<FilmCardPublicDisplayModel?> GetBySystemIdentifierAsync(Guid sysId)
        {
 
            var entity =
                await _context.VFilmCards
                .Where(x => x.SystemIdentifier == sysId && (!x.IsDraft.HasValue || x.IsDraft.Value == false) && !x.Deleted)
                .SingleOrDefaultAsync();

            if (entity != null)
            {
                var model = entity.ToPublicDisplayModel();

                model.LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(entity.Id, BusinessObjectType.FilmCard, false, Shared.NomenclatureCode.Language);
                model.LanguageText = _nomenclatureService.GetEntityNomenclatureText(entity.Id, BusinessObjectType.FilmCard, false, Shared.NomenclatureCode.Language);

                model.DocumentIds = _context.FilmCardDocuments
                    .Include(x => x.PackageDocument)
                    .ThenInclude(d => d.Package)
                    .ThenInclude(p => p.FilmPackageBs)
                    .Where(x => x.CardId == entity.Id && !x.IsDraft &&
                    x.PackageDocument.Package.FilmPackageBs.Where(b => b.SystemIdentifier == model.FilmSystemIdentifier).Any())
                    .Select(d => d.PackageDocumentId).AsEnumerable();

                return model;
            }

            return null;
        }

        public async Task<FilmCardPublicDisplayModel?> GetFromExternalSourceAsync(int externalIdentifier, Guid? systemIdentifier = null)
        {
            string query = "exec sp_GetFilmCards @LinkedServer, @PageSize, @PageNumber, @FundGid, @ArchiveEntityGid";
            List<SqlParameter> queryParams = new()
                {
                    new SqlParameter("LinkedServer", _linkedServerSettings.LinkedServer),
                    new SqlParameter("PageSize", 10),
                    new SqlParameter("PageNumber", 1),
                    new SqlParameter("FundGid", DBNull.Value),
                    new SqlParameter("ArchiveEntityGid", externalIdentifier),
                };

            var result =
                (await _context.RemoteFilmCards
                        .FromSqlRaw(query, queryParams.ToArray())
                        .AsNoTracking()
                        .ToListAsync())
                    .SingleOrDefault();

            if (result == null)
            {
                return null;
            }

            return new FilmCardPublicDisplayModel()
            {
                SystemIdentifier = systemIdentifier.HasValue ? systemIdentifier.Value : default(Guid),
                HasExternalSource = result.HasExternalSource,
                ExternalIdentifier = result.ExternalIdentifier,
                ArchiveName = String.Format("{0} - {1}", result.ArchiveName, result.ArchiveCode),
                CountryName = result.CountryName,
                City = result.City,
                DocumentsCypher = result.DocumentsCypher,
                Title = result.Title,
                ArchiveOriginals = result.ArchiveOriginals,
                StartDateDay = result.StartDateDay,
                StartDateMonth = result.StartDateMonth,
                StartDateYear = result.StartDateYear,
                EndDateDay = result.EndDateDay,
                EndDateMonth = result.EndDateMonth,
                EndDateYear = result.EndDateYear,
                AproximateDate = result.AproximateDate,
                FilmingExtentName = result.FilmingExtentName,
                Source = result.Source,
                InventoryNumber = result.InventoryNumber ?? "",
                FramesCount = result.FramesCount,
                MicrofilmNegativeCount = result.MicrofilmNegativeCount,
                MicrofilmPositiveCount = result.MicrofilmPositiveCount,
                PhotoCopy = result.PhotoCopy.HasValue ? result.PhotoCopy.Value.ToString() : null,
                DigitalCopy = result.DigitalCopy.HasValue ? result.DigitalCopy.Value.ToString() : null,
                Other = result.Other,
                Notes = result.Notes,
                DocumentsFormat = result.DocumentsFormat,
                DocumentsCharacteristics = result.DocumentsCharacteristics,
                LanguageText = result.Languages
            };
        }
    }
}
