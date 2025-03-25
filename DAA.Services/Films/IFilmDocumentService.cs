using DAA.Extensions.DynamicLinq;
using DAA.Models.File;
using DAA.Models.Films;
using DAA.Shared;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Services.Films
{
    public interface IFilmDocumentService
    {
        DataSourceResponseModel<FilmPackageDocumentShortModel> GetAll(DataSourceRequestModel model, int packageId);
        Task<OperationResult> CreateAsync(FilmPackageDocumentCreateModel model);
        Task<FilmPackageDocumentDisplayModel?> GetById(int id);
        Task<OperationResult> UpdateAsync(FilmPackageDocumentUpdateModel model);
        Task<OperationResult> DeleteAsync(int id);
        Task<OperationResult> DeletePackageAsync(int packageId);
        Task<FileModel?> GetFile(int docId);
        Task<OperationResult> CopyPackageAsync(int sourcePackageId, int destinationPackageId, FileStreamLocation locationToCopyTo, bool setCopyId);
        Task<OperationResult> UpdatePackageAsync(int sourcePackageId, int destinationPackageId, FileStreamLocation locationToCopyTo);
    }
}
