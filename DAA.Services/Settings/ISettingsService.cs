using DocFlow.Models.File;
using Microsoft.AspNetCore.Http;

namespace DAA.Services.Settings
{
    public interface ISettingsService
    {
        Task<FileDownloadModel?> GetFileUploaderApp(int version);
        Task<FileDownloadModel?> ConvertToPdf(IFormFile uploadedFile);
    }
}
