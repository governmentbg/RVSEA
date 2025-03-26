using DAA.Extensions.DynamicLinq;
using DAA.Models;
using DAA.Models.Documents;
using DAA.Shared;

namespace DAA.Services.Documents
{
    public interface IDocumentServiceBase
    {
        protected internal Task<Guid> CreateDraftInternalAsync(DocumentDraftModel model);
        protected internal Task<Guid> CreateDocumentInternalAsync(DocumentModel model, Guid? createdBy = null, DateTime? createdOn = null);
        protected internal Task<Guid> UpdateDraftInternalAsync(DocumentDraftModel model);
        protected internal Task<Guid> UpdateDocumentInternalAsync(DocumentModel model, Guid? updatedBy = null, DateTime? updatedOn = null);
        protected internal Task DeleteDraftInternalAsync(int id);
        protected internal Task DeleteDocumentInternalAsync(Guid sysId);
        protected internal Task<Guid> CreateOrUpdateDocumentFromDraftInternalAsync(Guid sysId, bool overwriteCreatedFromDraft = true, bool overwriteModifiedFromDraft = true);
    }

    public interface IDocumentService : IDocumentServiceBase
    {
        DataSourceResponseModel<DocumentDisplayModel> GetAll(DataSourceRequestModel model, bool includeDeleted = false);
        Task<DataSourceResponseModel<DocumentDisplayModel>> GetByArchivalEntityIdentifierAsync(
            DataSourceRequestModel model,
            Guid? archivalEntitySysId,
            bool archivalEntityHasExternalSource = false,
            int? archivalEntityExternalIdentifier = null,
            string? searchArchivalEntityNumber = null,
            int? searchArchivalEntityStartSheet = null,
            int? searchArchivalEntityEndSheet = null,
            bool includeDeleted = false);
        DataSourceResponseModel<DocumentDisplayModel> GetByAvailabilityStatus(
            DataSourceRequestModel model,
            int availabilityStatus,
            Guid fundSystemIdentifier,
            string? searchArchivalEntityNumber = null,
            int? searchArchivalEntityStartSheet = null,
            int? searchArchivalEntityEndSheet = null,
            bool includeDeleted = false);
        Task<DocumentDisplayModel?> GetById(int id);
        Task<DocumentDisplayModel?> GetDocumentBySystemIdentifierAsync(Guid sysId);
        Task<DocumentDisplayModel?> GetCurrentDraftAsync(Guid sysId);
        Task<bool> HasCurrentDraftAsync(Guid sysId);
        Task<bool> IsCurrentDraftAsync(DocumentDraftModel model);
        Task<bool> IsReadOnlyDraftAsync(DocumentDraftModel model);
        Task<DocumentDisplayModel?> GetFromExternalSourceAsync(
            int externalIdentifier,
            Guid? systemIdentifier = null,
            Guid? archivalEntitySystemIdentifier = null,
            Guid? inventorySystemIdentifier = null,
            Guid? fundSystemIdentifier = null);
        Task<OperationResult> CreateDraftAsync(DocumentDraftModel model);
        Task<OperationResult> CreateDocumentAsync(DocumentModel model);
        Task<OperationResult> CreateOrUpdateDocumentFromDraftAsync(Guid sysId);
        Task<OperationResult> UpdateDraftAsync(DocumentDraftModel model);
        Task<OperationResult> UpdateDocumentAsync(DocumentModel model);
        Task<OperationResult> DeleteDraftAsync(int id);
        Task<OperationResult> DeleteDocumentAsync(Guid sysId);
        Task<Guid?> GetSystemIdentifierByExternalIdentifierAsync(int externalIdentifier);
        Task<int?> GetArchiveIdAsync(Guid sysId);
        Task<int?> GetArchiveIdByProcessIdAsync(int processId);
        Task<int?> GetDescriptionLevelAsync(Guid sysId);
        Task<DataSourceResponseModel<PublicUserReviewDisplayModel>> GetDocumentPublicUsersReviewsAsync(Guid? systemIdentifier);
        Task<OperationResult?> CreateDocumentReviewAsync(Guid? documentSystemIdentifier, int? documentExternalIdentifier);
        Task<bool> AnyUnnumberedByArchivalEntityIdentifier(Guid aeSysId);
        Task<bool> AnyUnnumberedDraftsByArchivalEntityIdentifier(Guid aeSysId);
        Task<bool> AnyUnnumberedByInventoryIdentifier(Guid inventorySysId);
        Task<bool> AnyUnnumberedDraftsByInventoryIdentifier(Guid inventorySysId);
        Task<bool> AnyUnnumberedByFundIdentifier(Guid fundSysId);
        Task<bool> AnyUnnumberedDraftsByFundIdentifier(Guid fundSysId);    }
}
