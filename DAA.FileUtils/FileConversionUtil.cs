using DAA.Extensions.Exceptions;
using System.Diagnostics;

namespace DAA.FileUtils
{
    public static class FileConversionUtil
    {
        public static async Task<byte[]> ConvertFileToPdf_LibreOfficeAsync(byte[] fileContent, string sourceFileName, string libreOfficeExePath, CancellationToken cancellationToken = default)
        {
            string sourceFileType = Path.GetExtension(sourceFileName).Replace(".", "");
            string[] wordFileTypes = new string[3] { "docx", "doc", "rtf" };
            string[] excelFileTypes = new string[3] { "xlsx", "xls", "xlsm" };
            string[] powerPointFileTypes = new string[2] { "pptx", "ppt" };

            if (!wordFileTypes.Contains(sourceFileType) && !excelFileTypes.Contains(sourceFileType) && !powerPointFileTypes.Contains(sourceFileType))
            {
                throw new FileTypeNotSupportedException($"File type {sourceFileType} not supported");
            }

            var contentTmpFilePath = Path.GetTempFileName();

            await File.WriteAllBytesAsync(contentTmpFilePath, fileContent ?? throw new ArgumentNullException(nameof(fileContent)), cancellationToken);

            string fileName = Path.GetFileName(contentTmpFilePath);
            string baseDir = Path.GetTempPath();
                        
            Process process = new();
            ProcessStartInfo processStartInfo = new()
            {
                WindowStyle = ProcessWindowStyle.Hidden,
                FileName = "cmd.exe"
            };

            // https://stackoverflow.com/questions/30349542/command-libreoffice-headless-convert-to-pdf-test-docx-outdir-pdf-is-not
            string converter = 
                wordFileTypes.Contains(sourceFileType)
                ? "pdf:writer_pdf_Export"
                : excelFileTypes.Contains(sourceFileType)
                ? "pdf:calc_pdf_Export"
                : powerPointFileTypes.Contains(sourceFileType)
                ? "pdf:impress_pdf_Export"
                : String.Empty;

            // You MUST manually set a different environment/profile folder as the default one
            // will be some folder LibreOffice auto-decides is right for the IIS AppPool user
            // which of course the IIS AppPool user won’t have write access to.
            // Otherwise, LibreOffice will hang. This was devilishly difficult to figure out and only was revealed via web research.
            // При IIS е изключително важно върху тази папка dа се дадат пълни права на IIS_IUSRS!!!
            // https://stackoverflow.com/questions/51901973/using-libreofficesoffice-exe-as-process-start-from-code-behind-not-working-o
            string userProfilePath = "-env:UserInstallation=file:///C:/tmp/LibreOffice_Conversion";

            // command must start with /C so that it executes
            // all the arguments must be enclosed in "" - otherwise the cmd.exe will split them by intervals in the path name, e.g C:\Program Files\
            string outputDir = baseDir.EndsWith("\\") ? baseDir.Substring(0, baseDir.Length - 1) : baseDir;
            string command = $@"/C """"{libreOfficeExePath}"" --headless ""{userProfilePath}"" --convert-to {converter} --outdir ""{outputDir}"" ""{contentTmpFilePath}""""";

            processStartInfo.Arguments = command;
            process.StartInfo = processStartInfo;
            process.Start();
            process.WaitForExit();

            string pdfPath = $"{baseDir}{fileName.Replace(".tmp", ".pdf")}";

            byte[] newFileBytes = await File.ReadAllBytesAsync(pdfPath, cancellationToken);

            File.Delete(pdfPath);
            File.Delete(contentTmpFilePath);

            return newFileBytes;
        }


        public static async Task<byte[]> ConvertFileToPdf_LibreOfficeAsync(string sourceFilePath, string libreOfficeExePath, CancellationToken cancellationToken = default)
        {
            string sourceFileType = Path.GetExtension(sourceFilePath).Replace(".", "");
            string[] wordFileTypes = new string[3] { "docx", "doc", "rtf" };
            string[] excelFileTypes = new string[3] { "xlsx", "xls", "xlsm" };
            string[] powerPointFileTypes = new string[2] { "pptx", "ppt" };

            if (!wordFileTypes.Contains(sourceFileType) && !excelFileTypes.Contains(sourceFileType) && !powerPointFileTypes.Contains(sourceFileType))
            {
                throw new FileTypeNotSupportedException($"File type {sourceFileType} not supported");
            }

            //var contentTmpFilePath = Path.GetTempFileName();

            //await File.WriteAllBytesAsync(contentTmpFilePath, fileContent ?? throw new ArgumentNullException(nameof(fileContent)), cancellationToken);

            //string fileName = Path.GetFileName(contentTmpFilePath);
            string fileName = Path.GetFileName(sourceFilePath);
            string baseDir = Path.GetTempPath();

            Process process = new();
            ProcessStartInfo processStartInfo = new()
            {
                WindowStyle = ProcessWindowStyle.Hidden,
                FileName = "cmd.exe"
            };

            // https://stackoverflow.com/questions/30349542/command-libreoffice-headless-convert-to-pdf-test-docx-outdir-pdf-is-not
            string converter =
                wordFileTypes.Contains(sourceFileType)
                ? "pdf:writer_pdf_Export"
                : excelFileTypes.Contains(sourceFileType)
                ? "pdf:calc_pdf_Export"
                : powerPointFileTypes.Contains(sourceFileType)
                ? "pdf:impress_pdf_Export"
                : String.Empty;

            // You MUST manually set a different environment/profile folder as the default one
            // will be some folder LibreOffice auto-decides is right for the IIS AppPool user
            // which of course the IIS AppPool user won’t have write access to.
            // Otherwise, LibreOffice will hang. This was devilishly difficult to figure out and only was revealed via web research.
            // При IIS е изключително важно върху тази папка dа се дадат пълни права на IIS_IUSRS!!!
            // https://stackoverflow.com/questions/51901973/using-libreofficesoffice-exe-as-process-start-from-code-behind-not-working-o
            string userProfilePath = "-env:UserInstallation=file:///C:/tmp/LibreOffice_Conversion";

            // command must start with /C so that it executes
            // all the arguments must be enclosed in "" - otherwise the cmd.exe will split them by intervals in the path name, e.g C:\Program Files\
            string outputDir = baseDir.EndsWith("\\") ? baseDir.Substring(0, baseDir.Length - 1) : baseDir;
            string command = $@"/C """"{libreOfficeExePath}"" --headless ""{userProfilePath}"" --convert-to {converter} --outdir ""{outputDir}"" ""{sourceFilePath}""""";

            processStartInfo.Arguments = command;
            process.StartInfo = processStartInfo;
            process.Start();
            process.WaitForExit();

            string pdfPath = $"{baseDir}{fileName.Replace(".tmp", ".pdf")}";

            byte[] newFileBytes = await File.ReadAllBytesAsync(pdfPath, cancellationToken);

            File.Delete(pdfPath);
            

            return newFileBytes;
        }

    }
}
