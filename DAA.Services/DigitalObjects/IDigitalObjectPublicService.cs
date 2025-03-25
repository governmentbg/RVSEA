
using DAA.Extensions.DynamicLinq;
using DAA.Models.DigitalObjects;
using DAA.Shared;

namespace DAA.Services.DigitalObjects
{
    public interface IDigitalObjectPublicService
    {
        Task<DataSourceResponseModel<DigitalObjectPublicDisplayModel>> GetByDocumentIdentifierAsync(
            DataSourceRequestModel model,
            Guid? documentSysId,
            bool documentHasExternalSource = false,
            int? documentExternalIdentifier = null,
            bool includeDeleted = false);
        Task<DigitalObjectPublicDisplayModel?> GetDigitalObjectBySystemIdentifierAsync(Guid sysId);
        Task<DigitalObjectPublicDisplayModel?> GetDigitalObjectDraftBySystemIdentifierAsync(Guid sysId);
        Task<Tuple<string,string>> GetUncPathAndWatermarkUncPathAsync(Guid sysId);
        Task<OperationResult> ManageDigitalObjectReviewAsync(DigitalObjectPublicDisplayModel digitalObject, Guid? userId);
    }
}
