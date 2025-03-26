using DAA.Extensions.DynamicLinq;
using DAA.Models.File;
using DAA.Models.Films;

namespace DAA.Services.Films
{
    public interface IFilmDocumentPublicService
    {
        DataSourceResponseModel<FilmPackageDocumentPublicShortModel> GetAll(DataSourceRequestModel model, int packageId);
        Task<FileModel?> GetFile(int docId);
    }
}
