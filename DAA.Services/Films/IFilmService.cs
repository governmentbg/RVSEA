using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Films;
using DAA.Models.Processes;
using DAA.Shared;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Services.Films
{
    public interface IFilmService
    {
        DataSourceResponseModel<FilmShortModel> GetAll(DataSourceRequestModel model, bool includeDeleted = false);
        Task<DataSourceResponseModel<FilmShortModel>> GetAllFromExternalSourceAsync(DataSourceRequestModel model);
        DataSourceResponseModel<FilmReviewDisplayModel> GetAllFilmReviews(DataSourceRequestModel model, bool includeDeleted = false);
        Task<int?> GetFilmArchiveAsync(Guid filmSysId);
        Task<int?> GetFilmDraftArchiveAsync(int draftId);
        Task<OperationResult> CreateDraftAsync(FilmModel model);
        Task<int> GetNextInventoryNumber();
        Task<FilmDisplayModel?> GetBySystemIdentifierAsync(Guid sysId);
        Task<FilmDisplayModel?> GetFromExternalSourceAsync(int externalIdentifier, Guid? systemIdentifier = null);
        Task<OperationResult> UpdateDraftAsync(FilmDraftModel model);
        Task<OperationResult> DeleteFilmAsync(Guid id);
        Task<OperationResult> DeleteDraftAsync(int id);
        Task<OperationResult> ChangeStepAsync(FilmChangeStepModel model);
        Task<OperationResult> PrepareDraftAsync(Guid sysId);
        Task<OperationResult> StartProcessAsync(ProcessModel model);
        Task<OperationResult> CreateFilmReviewAsync(FilmReviewModel model);
        Task<OperationResult> UpdateFilmReviewAsync(FilmReviewModel model);

    }
}
