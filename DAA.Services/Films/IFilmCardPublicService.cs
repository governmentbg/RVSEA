
using DAA.Extensions.DynamicLinq;
using DAA.Models.Films;

namespace DAA.Services.Films
{
    public interface IFilmCardPublicService
    {
        DataSourceResponseModel<FilmCardShortPublicModel> GetAll(DataSourceRequestModel model, Guid? filmSysId, bool includeDeleted = false);
        Task<FilmCardPublicDisplayModel?> GetBySystemIdentifierAsync(Guid sysId);
        Task<FilmCardPublicDisplayModel?> GetFromExternalSourceAsync(int externalIdentifier, Guid? systemIdentifier = null);
    }
}
