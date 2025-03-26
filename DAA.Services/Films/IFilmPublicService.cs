using DAA.Extensions.DynamicLinq;
using DAA.Models.Films;
using DAA.Shared;

namespace DAA.Services.Films
{
    public interface IFilmPublicService
    {
        Task<OperationResult> GetBySystemIdentifierAsync(Guid sysId);
        Task<FilmPublicDisplayModel?> GetFromExternalSourceAsync(int externalIdentifier, Guid? systemIdentifier = null);
        OperationResult GetIsdaEServicesLink();
        DataSourceResponseModel<FilmReaderDisplayModel> GetAllForReader(DataSourceRequestModel model, bool includeDeleted = false);
    }
}
