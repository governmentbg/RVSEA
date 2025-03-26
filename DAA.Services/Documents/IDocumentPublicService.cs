using DAA.Extensions.DynamicLinq;
using DAA.Models.Documents;
using DAA.Shared;

namespace DAA.Services.Documents
{
    public interface IDocumentPublicService
    {
        Task<DocumentPublicDisplayModel?> GetDocumentBySystemIdentifierAsync(Guid sysId);
        Task<DocumentPublicDisplayModel?> GetFromExternalSourceAsync(
          int externalIdentifier,
          Guid? systemIdentifier = null,
          Guid? archivalEntitySystemIdentifier = null,
          Guid? inventorySystemIdentifier = null,
          Guid? fundSystemIdentifier = null);
        Task<DataSourceResponseModel<DocumentPublicDisplayModel>> GetByArchivalEntityIdentifierAsync(
           DataSourceRequestModel model,
           Guid? archivalEntitySysId,
           bool archivalEntityHasExternalSource = false,
           int? archivalEntityExternalIdentifier = null,
           string? searchArchivalEntityNumber = null,
           int? searchArchivalEntityStartSheet = null,
           int? searchArchivalEntityEndSheet = null,
           bool includeDeleted = false);
        Task<OperationResult?> CreateDocumentReviewAsync(Guid? documentSystemIdentifier, int? documentExternalIdentifier);


        Task<DocumentPublicImportModel?> GetDocumentDraftBySysIdAsync(Guid sysId);
        Task<OperationResult> UpdateDraftAsync(DocumentPublicImportModel model, Guid? userId);
    }
}
