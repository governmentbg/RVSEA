using DAA.Models.File;
using DAA.Shared;

namespace DAA.Services.Files
{
    public interface IFileService
    {
        Task<FileModel?> GetFileAsync(string uncFilePath, FileStreamLocation location, bool getContent = true);
        Task<Stream> GetFileStreamAsync(string uncFilePath, FileStreamLocation location);
        Task<string> GetFileBase64StringAsync(string uncFilePath, FileStreamLocation location);
        Task<OperationResult> CreateFileAsync(FileModel model, FileStreamLocation location);
        Task<OperationResult> CopyFileAsync(string sourceSystemName, string sourceUncPath, string sourceName, FileStreamLocation location);
        Task<OperationResult> CopyFileAsync(string sourceSystemName, string sourceUncPath, string sourceName, FileStreamLocation sourceLocation, FileStreamLocation targetLocation);
        Task<OperationResult> UpdateFileAsync(FileModel model, FileStreamLocation location);
        Task<OperationResult> UploadFileAsync(string fileName, Stream data, long offset);
        OperationResult DeleteFile(string filePath, FileStreamLocation location);
        Task<OperationResult> ExecuteFileAction(FileStreamLocation location, Func<Task<OperationResult>> action);
        string GetMasterDbUncFileName(string uncFileName);
        Task<OperationResult> TryCreateFileAsPdfAsync(FileModel model, FileStreamLocation location);
        Task<double?> TryGetFileDurationAsync(string uncPath, FileStreamLocation location);
        Task<Stream> TryConvertFileToImageAsync(string uncPath, FileStreamLocation location);
    }
}
