using DAA.Data;
using DAA.Models.Configuration;
using DAA.Extensions.Exceptions;
using DAA.Shared.Localization;
using DocFlow.Models.File;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;
using Microsoft.AspNetCore.Http;
using DAA.Models.File;
using Microsoft.Extensions.Logging;
using DAA.Services.DocsCreatingProc;
using System.Diagnostics;

namespace DAA.Services.Settings
{
    public class SettingsService : BaseService, ISettingsService
    {
        private readonly FileUploaderAppSettings _fileUploaderAppSettings;
        private readonly BusinessSettings _businessSettings;

        public SettingsService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IOptions<FileUploaderAppSettings> fileUploaderAppSettings,
            ILogger<DocsCreatingProcedureService> logger,
            IOptions<BusinessSettings> businessSettings)
            : base(context, localizer, logger)
        {
            _fileUploaderAppSettings = fileUploaderAppSettings.Value;
            _businessSettings = businessSettings.Value;
        }

        public async Task<FileDownloadModel?> GetFileUploaderApp(int version)
        {
            string fileName = version == 64 ? _fileUploaderAppSettings.FileName! : _fileUploaderAppSettings.FileName32bit!;
            string appPath = _fileUploaderAppSettings.FolderPath! + fileName;
            if (String.IsNullOrWhiteSpace(fileName) || String.IsNullOrWhiteSpace(appPath))
            {
                throw new CustomException(_localizer.GetString("Error_MissingFileUploaderPathOrFileName").ToString());
            }

            if (!System.IO.File.Exists(appPath))
            {
                throw new CustomException(_localizer.GetString("Error_MissingFileUploaderFile").ToString());
            }

            string mimeType = "application/x-msdownload";
            byte[] content = null!;

            using (var stream = new FileStream(appPath, FileMode.Open, FileAccess.Read))
            {
                content = new byte[stream.Length];
                await stream.ReadAsync(content, 0, (int)stream.Length);
            }

            FileDownloadModel file = new()
            {
                Mimetype = mimeType,
                Filename = fileName,
                Data = content != null ? Convert.ToBase64String(content) : ""
            };

            return file;
        }


        public async Task<FileDownloadModel?> ConvertToPdf(IFormFile uploadedFile)
        {
            _logger.LogInformation("Start converting to pdf");
            string[] wordFileTypes = new string[3] { "docx", "doc", "rtf" };
            string[] excelFileTypes = new string[3] { "xlsx", "xls", "xlsm" };
            string[] powerPointFileTypes = new string[2] { "pptx", "ppt" };

            FileModel originalFile = await ParseAttachmentAsync(uploadedFile);
            _logger.LogInformation($"File: {originalFile.Name}");

            var tmpFile = Path.GetTempFileName();
            _logger.LogInformation($"Temp file: {tmpFile}");

            System.IO.File.WriteAllBytes(tmpFile, originalFile.Content!);
            _logger.LogInformation("Wrote bytes to temp file");

            string fileName = Path.GetFileName(tmpFile);

            try
            {
                string baseDir = Path.GetTempPath();
                string path = tmpFile;
                string pdfName = $"{originalFile.Name.Replace("." + originalFile.Type, "")}.pdf";
                string pdfSourceName = pdfName;
                string pdfPath = $"{baseDir}{pdfName}";

                _logger.LogInformation($"Process {originalFile.Type} file");

                if (wordFileTypes.Contains(originalFile.Type) || excelFileTypes.Contains(originalFile.Type) || powerPointFileTypes.Contains(originalFile.Type)) {
                    _logger.LogInformation($"Starting process ...");

                    System.Diagnostics.Process process = new System.Diagnostics.Process();
                    ProcessStartInfo processStartInfo = new ProcessStartInfo();
                    processStartInfo.WindowStyle = ProcessWindowStyle.Hidden;
                    processStartInfo.FileName = "cmd.exe";

                    // https://stackoverflow.com/questions/30349542/command-libreoffice-headless-convert-to-pdf-test-docx-outdir-pdf-is-not
                    string converter = wordFileTypes.Contains(originalFile.Type)
                        ? "pdf:writer_pdf_Export"
                        : excelFileTypes.Contains(originalFile.Type)
                        ? "pdf:calc_pdf_Export"
                        : powerPointFileTypes.Contains(originalFile.Type)
                        ? "pdf:impress_pdf_Export"
                        : String.Empty;
                    string userProfilePath = "-env:UserInstallation=file:///C:/tmp/LibreOffice_Conversion";
                    string libreOfficeExe = _businessSettings.LibreOfficeExePath; 

                    // command must start with /C so that it executes
                    // all the arguments must be enclosed in "" - otherwise the cmd.exe will split them by intervals in the path name, e.g C:\Program Files\
                    string outputDir = baseDir.EndsWith("\\") ? baseDir.Substring(0, baseDir.Length - 1) : baseDir;
                    string command = $@"/C """"{libreOfficeExe}"" --headless ""{userProfilePath}"" --convert-to {converter} --outdir ""{outputDir}"" ""{path}""""";

                    _logger.LogInformation($"{command}");

                    processStartInfo.Arguments = command;
                    process.StartInfo = processStartInfo;
                    process.Start();
                    process.WaitForExit();

                    pdfPath = $"{baseDir}{fileName.Replace(".tmp", ".pdf")}";  
                    _logger.LogInformation($"New pdf path: {pdfPath}");
                    _logger.LogInformation($"Process saved {fileName} as pdf");
                }
                else
                {
                    _logger.LogInformation($"Unsupported file type {originalFile.Type}");
                }


                byte[] newFileBytes = System.IO.File.ReadAllBytes(pdfPath);

                string mimeType = "application/x-msdownload";
                FileDownloadModel file = new()
                {
                    Mimetype = mimeType,
                    Filename = pdfName,
                    Data = newFileBytes != null ? Convert.ToBase64String(newFileBytes) : ""
                };

                System.IO.File.Delete(pdfPath);
                System.IO.File.Delete(tmpFile);

                return file;
            }
            catch (Exception ex)
            {
                string msg = "Error on converting file to pdf";
                _logger.LogError(ex, msg);
                throw new CustomException(msg);
            }
        }
    }
}
