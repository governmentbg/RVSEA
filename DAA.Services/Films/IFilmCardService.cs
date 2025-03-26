using DAA.Extensions.DynamicLinq;
using DAA.Models.Films;
using DAA.Shared;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Services.Films
{
    public interface IFilmCardService
    {
        DataSourceResponseModel<FilmCardShortModel> GetAll(DataSourceRequestModel model, Guid? filmSysId, bool includeDeleted = false);
        Task<DataSourceResponseModel<FilmCardShortModel>> GetAllFromExternalSourceAsync(DataSourceRequestModel model, int? externalIdentifier);
        Task<FilmDisplayModel> GetParentData(Guid filmSysId);
        Task<OperationResult> CreateDraftAsync(FilmCardModel model);
        Task<OperationResult> CreateOrUpdateFilmCardsFromDraftAsync(Guid filmSysId);
        Task<FilmCardDisplayModel?> GetBySystemIdentifierAsync(Guid sysId);
        Task<FilmCardDisplayModel?> GetFromExternalSourceAsync(int externalIdentifier, Guid? systemIdentifier = null);
        Task<OperationResult> UpdateDraftAsync(FilmCardDraftModel model);
        Task<OperationResult> DeleteDraftAsync(int id);
        Task<OperationResult> DeleteDraftInternalAsync(int id);
        Task<OperationResult> DeleteCardInternalAsync(int id);
        Task<OperationResult> DeleteFilmCardAsync(Guid id);
        Task<OperationResult> DeleteAllDraftsAsync(Guid filmSysId);
        Task<int?> GetFilmCardDraftArchiveAsync(int draftId);
        Task<int?> GetFilmCardArchiveAsync(Guid sysId);
        Task<OperationResult> PrepareDraftsAsync(Guid filmSysId, int filmDraftId, int packageBId);
        Task<FilmCardPrintedModel?> GetPrintedBySystemIdentifierAsync(Guid sysId);
    }

}
