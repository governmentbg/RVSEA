using DAA.Data;
using DAA.Models.DigitalObjects;
using DAA.Models.File;
using DAA.Models.FileUploadApp;
using DAA.Shared;

namespace DAA.Services.FileUploadApp
{
    public interface IFileUploadAppService
    {
        public Task<AuthorizeResultModel> Authorize();
        public Task<GetExtensionsResultModel> GetExtensions();

        public Task<ListQueueResultModel> List(string computerName);
        public Task<AddToQueueResultModel> Add(QueueItemModel model);
        public Task<AddToQueueResultModel> Update(QueueItemModel model);
        public Task<OperationResultModel> Delete(int? id);

        public Task<DocumentExistsResultModel> DocumentExists(ProcessKind processKind, Guid documentId);
        public Task<DocumentExistsResultModel> FileExists(ProcessKind processKind, FileKind? fileKind, Guid documentId, int? currentQueueId, string fileName);
        public Task<bool> FileExistsInFileTables(ProcessKind processKind, Guid documentId, string fileName);

        public Task<MastersForDocumentResultModel> MastersForDocument(Guid documentId);

        public Task<OperationResultModel> UploadFileAsync(string fileName, Stream data, int id, long offset);
        public Task<QueueItemResultModel> ValidateAndFinish(int id);
        public System.Threading.Tasks.Task ValidateFile(string filePath, string checksum, FilmPackageDocument doc, bool skipFileFormatValidation = false);
        public System.Threading.Tasks.Task ValidateFile(string filePath, string checksum, DigitalObjectDraft digitalObject, bool skipFileFormatValidation = false);
        public System.Threading.Tasks.Task ValidateFile(string filePath, string checksum, PackageDocument packageDoc, bool skipFileFormatValidation = false);

        public Task<ChecksumsVerifyResultModel> VerifyChecksums(ProcessKind? processKind);
        public Task<bool> IsFileExtensionValid(string fileName);

        public Task<Guid?> CreateDerivativeDraftAsync(string sourceUncPath, FileStreamLocation sourceLocation, FileStreamLocation targetLocation, DigitalObjectDraftModel model);
    }
}
