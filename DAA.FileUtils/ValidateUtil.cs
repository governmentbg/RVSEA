using Codeuctivity;
using DAA.Models.Configuration;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Validation;
using System.Text;
using System.Xml.Linq;

namespace DAA.FileUtils
{
    public static class ValidateUtil
    {
        public static async Task ValidateFile(string fileName, FileUploaderAppSettings settings)
        {
            string extension = Path.GetExtension(fileName);
            string searchStr = "*" + extension + ";";

            if (settings.ValidateXml && Consts.SupportedFileExtensions[FileType.DocumentXml].Contains(searchStr))
            {
                ValidateXml(fileName);
            }
            else if (settings.ValidateHtml && Consts.SupportedFileExtensions[FileType.DocumentHtml].Contains(searchStr))
            {
                ValidateHtml(fileName);
            }
            else if (settings.ValidatePdf && Consts.SupportedFileExtensions[FileType.DocumentPdf].Contains(searchStr))
            {
                await ValidatePdf(fileName);
            }
            else if (settings.ValidateMsX && Consts.SupportedFileExtensions[FileType.DocumentMsX].Contains(searchStr))
            {
                ValidateOpenXml(fileName, searchStr);
            }
            else if (settings.ValidateImage && Consts.SupportedFileExtensions[FileType.Image].Contains(searchStr))
            {
                ValidateMedia(fileName, true);
                //ValidateImage(fileName);
            }
            else if (settings.ValidateVideo && Consts.SupportedFileExtensions[FileType.Video].Contains(searchStr))
            {
                ValidateMedia(fileName, false);
            }
            else if (settings.ValidateAudio && Consts.SupportedFileExtensions[FileType.Audio].Contains(searchStr))
            {
                ValidateMedia(fileName, false);
            }
        }

        private static void ValidateXml(string fileName)
        {
            try
            {
                XDocument xml = XDocument.Load(fileName);
            }
            catch (Exception e)
            {
                throw new Exception("Файлът е тип xml, но не може да бъде отворен: " + e.Message);
            }
        }

        private static void ValidateHtml(string fileName)
        {
            try
            {
                Sgml.SgmlReader reader = new();
                reader.Href = fileName;
                reader.DocType = "HTML";

                Encoding encoding = reader.GetEncoding();
                using MemoryStream stream = new MemoryStream();
                using System.Xml.XmlTextWriter textWriter = new(stream, encoding);

                reader.Read();
                while (!reader.EOF)
                {
                    textWriter.WriteNode(reader, true);
                }
                textWriter.Flush();
                textWriter.Close();
            }
            catch (Exception e)
            {
                throw new Exception("Файлът е тип sgml(*.htm, *.html), но не може да бъде валидиран: " + e.Message);
            }
        }

        private static async Task ValidatePdf(string fileName)
        {
            try
            {
                using PdfAValidator pdfAValidator = new PdfAValidator();

                // извикването на валидацията е външно приложение, което използва и Java отгоре на всичко
                // не сработва с механизма RunImpersonated - вероятно процеъст на Javata не работи в същия контекст
                // затова копирам файла във временна папка и правя проверката там - с надеждата pdf файловете да не са твърде големи
                // за оптимизация, ако ползвам валидацията от клиентското приложение, работя с файла директно (без копиране)

                string? assemblyName = System.Reflection.Assembly.GetEntryAssembly().FullName;
                bool useTempFile = assemblyName == null || !assemblyName.Contains("App.FileUpload");
                string tempFileName = "";
                if (useTempFile)
                {
                    tempFileName =  Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString() + Path.GetExtension(fileName));
                    File.Copy(fileName, tempFileName);
                }

                Report report = await pdfAValidator.ValidateWithDetailedReportAsync(useTempFile ? tempFileName : fileName);

                if (useTempFile && File.Exists(tempFileName))
                {
                    File.Delete(tempFileName);
                }

                // пробвах с 2 файла - и двата не бяха Compliant
                //if (!await pdfAValidator.ValidateAsync(fileName))
                // затова ще работя с подробния репорт и ще проверявам само дали са се парснали (FailedToParse == 0)
                if (report.BatchSummary.FailedToParse != "0")
                {
                    throw new Exception("Грешка при валидацията (FailedToParse).");
                }
            }
            catch (Exception e)
            {
                throw new Exception("Файлът е тип Portable Document Format(*.pdf), но не може да бъде валидиран: " + e.Message);
            }
        }

        private static void ValidateOpenXml(string fileName, string extension)
        {
            try
            {
                OpenXmlValidator validator = new OpenXmlValidator();
                using (OpenXmlPackage package =
                    extension.Contains("docx") ? WordprocessingDocument.Open(fileName, false) :
                    extension.Contains("xlsx") ? SpreadsheetDocument.Open(fileName, false) :
                    extension.Contains("pptx") ? PresentationDocument.Open(fileName, false) :
                    throw new Exception("OpenXmlValidateUtil: unsupported file type: " + extension))
                {
                    IEnumerable<ValidationErrorInfo> errors = validator.Validate(package);

                    if (errors.Any())
                    {
                        throw new Exception("Грешки при валидиране на документа: " + string.Join(Environment.NewLine, errors.Select(e => e.Description)));
                    }
                }
            }
            catch (Exception e)
            {
                throw new Exception($"Файлът е тип Microsoft Open XML ({extension}), но не може да бъде валидиран: {e.Message}");
            }
        }

        private static void ValidateImage(string fileName)
        {
            try
            {
#pragma warning disable CA1416 // Validate platform compatibility
                using System.Drawing.Image image = System.Drawing.Image.FromFile(fileName);
#pragma warning restore CA1416 // Validate platform compatibility
            }
            catch (Exception e)
            {
                throw new Exception($"Файлът е тип изображение, но не може да бъде отворен: {e.Message}");
            }
        }
        private static void ValidateMedia(string fileName, bool isImage)
        {
            try
            {
                string metadata = MetadataUtil.GetFileMetadata(fileName);
                if (string.IsNullOrEmpty(metadata))
                {
                    throw new Exception("Липсват метаданни.");
                }
#pragma warning disable CA1416 // Validate platform compatibility
                if (isImage)
                {
                    using System.Drawing.Image image = System.Drawing.Image.FromFile(fileName);
                }
#pragma warning restore CA1416 // Validate platform compatibility
            }
            catch (Exception e)
            {
                throw new Exception($"Файлът е тип (аудио/видео/изображение), грешка при валидация: {e.Message}");
            }
        }

        private static void ValidateAudio(string fileName)
        {

        }

        private static void ValidateVideo(string fileName)
        {

        }

        //public static bool IsFileExtensionValid(string fileName)
        //{
        //    string extension = Path.GetExtension(fileName);
        //    string searchStr = "*" + extension + ";";

        //    if (Consts.SupportedFileExtensions[FileType.DocumentXml].Contains(searchStr) ||
        //        Consts.SupportedFileExtensions[FileType.DocumentHtml].Contains(searchStr) ||
        //        Consts.SupportedFileExtensions[FileType.DocumentPdf].Contains(searchStr) ||
        //        Consts.SupportedFileExtensions[FileType.DocumentMs].Contains(searchStr) ||
        //        Consts.SupportedFileExtensions[FileType.DocumentMsX].Contains(searchStr) ||
        //        Consts.SupportedFileExtensions[FileType.Image].Contains(searchStr) ||
        //        Consts.SupportedFileExtensions[FileType.Video].Contains(searchStr) ||
        //        Consts.SupportedFileExtensions[FileType.Audio].Contains(searchStr) ||
        //        Consts.SupportedFileExtensions[FileType.Other].Contains(searchStr))
        //    {
        //        return true;   
        //    }

        //    return false;
        //}
    }
}
