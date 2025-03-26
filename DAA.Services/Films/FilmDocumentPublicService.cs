using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Models;
using DAA.Models.File;
using DAA.Models.Films;
using DAA.Services.Files;
using DAA.Services.Nomenclatures;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Services.Films
{
    public class FilmDocumentPublicService : BaseService, IFilmDocumentPublicService
    {
        private readonly IUserInfo _userInfo;
        private readonly IFileService _fileService;

        public FilmDocumentPublicService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IUserInfo userInfo,
            IFileService fileService)
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _fileService = fileService;
        }

        public DataSourceResponseModel<FilmPackageDocumentPublicShortModel> GetAll(DataSourceRequestModel model, int packageId)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.FilmPackageDocuments
                .Include(x => x.DocumentType)
                .Include(x => x.CreatedByNavigation)
                .Include(x => x.UpdatedByNavigation)
                .Where(x => x.PackageId == packageId && !x.Deleted && x.FileLocation == 0)
                .OrderBy(x => x.DocumentTypeId).ThenBy(x => x.Id)
                .AsQueryable();

            QueryResponseModel<FilmPackageDocument> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<FilmPackageDocumentPublicShortModel> result = new ()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => x.ToShortPublicModel())
            };

            return result;
        }
        public async Task<FileModel?> GetFile(int docId)
        {
            var doc = await _context.FilmPackageDocuments.FindAsync(docId);
            if (doc == null || String.IsNullOrWhiteSpace(doc.FilePath))
            {
                return null;
            }

            if (doc.FileLocation == null)
            {
                return null;
            }

            var file = await _fileService.GetFileAsync(doc.FilePath, (FileStreamLocation)doc.FileLocation);
            file!.ContentType = doc.ContentType;
            file!.Name = doc.FileName;
            return file;
        }
    }
}
