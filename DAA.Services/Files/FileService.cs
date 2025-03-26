using DAA.Data.Files;
using DAA.Extensions.Exceptions;
using DAA.FileUtils;
using DAA.Models.Configuration;
using DAA.Models.File;
using DAA.Shared;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.Win32.SafeHandles;
using SimpleImpersonation;
using System.Drawing.Imaging;
using System.Drawing;
using System.Security.Principal;
using static TagLib.File;

namespace DAA.Services.Files
{
    public class FileService : BaseFileService, IFileService
    {
        private readonly BusinessSettings _conversionSettings;

        public FileService(
            FileContext fileContext,
            BufferFileContext bufferFileContext,
            AdjunctFileContext adjunctFileContext,
            MasterFileContext masterFileContext,
            IOptions<FileStreamSettings> options,
            IOptions<BusinessSettings> conversionSettings,
            IStringLocalizer<SharedResources> localizer,
            ILogger<IFileService> logger)
            : base(
                  fileContext,
                  bufferFileContext,
                  adjunctFileContext,
                  masterFileContext,
                  options,
                  localizer,
                  logger)
        {
            _conversionSettings = conversionSettings.Value;
        }

        private FileStreamCredential? GetCredential(FileStreamLocation location, bool isReader = false)
        {

            FileStreamCredential? credential = new FileStreamCredential();

            switch (location)
            {
                case FileStreamLocation.File:
                    credential = isReader ? _settings.Files?.Reader ?? _settings.Files?.Writer : _settings.Files?.Writer;
                    break;
                case FileStreamLocation.Buffer:
                    credential = isReader ? _settings.BufferFiles?.Reader ?? _settings.BufferFiles?.Writer : _settings.BufferFiles?.Writer;
                    break;
                case FileStreamLocation.Adjunct:
                    credential = isReader ? _settings.AdjunctFiles?.Reader ?? _settings.AdjunctFiles?.Writer : _settings.AdjunctFiles?.Writer;
                    break;
                case FileStreamLocation.Master:
                    credential = isReader ? _settings.MasterFiles?.Reader ?? _settings.MasterFiles?.Writer : _settings.MasterFiles?.Writer;
                    break;
            }
            return credential;
        }

        private string GetUncPath(FileStreamLocation location)
        {
            string uncPath = string.Empty;

            switch (location)
            {
                case FileStreamLocation.File:
                    uncPath = _settings.Files?.UncPath!;
                    break;
                case FileStreamLocation.Buffer:
                    uncPath = _settings.BufferFiles?.UncPath!;
                    break;
                case FileStreamLocation.Adjunct:
                    uncPath = _settings.AdjunctFiles?.UncPath!;
                    break;
                case FileStreamLocation.Master:
                    uncPath = _settings.MasterFiles?.UncPath!;
                    break;
            }

            return uncPath;
        }

        private async Task<string> CreateFileAsync(FileModel model, FileMode fileMode, string uncPath, string username, string password, string domain)
        {
            var uncFilePath = Path.Combine(uncPath, model.SystemName);

#pragma warning disable CA1416 // Validate platform compatibility
            UserCredentials credentials = new UserCredentials(domain, username, password);
            using (SafeAccessTokenHandle userHandle = credentials.LogonUser(LogonType.NewCredentials))
            {
                await WindowsIdentity.RunImpersonatedAsync(userHandle, async () =>
                {
                    using (var stream = new FileStream(uncFilePath, fileMode, FileAccess.Write))
                    {
                        await stream.WriteAsync(model.Content);
                    }
                });
            }
#pragma warning restore CA1416 // Validate platform compatibility
            return uncFilePath;
        }

        private async Task<string> TryCreateFileAsPdfAsync(FileModel source, FileMode fileMode, string uncPath, string username, string password, string domain)
        {
            if (source == null)
            {
                throw new ArgumentNullException(nameof(source));
            }
            if (source.Content == null)
            {
                throw new ArgumentNullException(nameof (source.Content));
            }

            var targetSystemName = $"{Guid.NewGuid().ToString("D")}.pdf";
            var targetUncFilePath = Path.Combine(uncPath, targetSystemName);

            var pdfContent = await FileConversionUtil.ConvertFileToPdf_LibreOfficeAsync(source.Content, source.SystemName, _conversionSettings.LibreOfficeExePath);

#pragma warning disable CA1416 // Validate platform compatibility
            UserCredentials credentials = new UserCredentials(domain, username, password);
            using (SafeAccessTokenHandle userHandle = credentials.LogonUser(LogonType.NewCredentials))
            {
                await WindowsIdentity.RunImpersonatedAsync(userHandle, async () =>
                {
                    using (var stream = new FileStream(targetUncFilePath, fileMode, FileAccess.Write))
                    {
                        await stream.WriteAsync(pdfContent);
                    }
                });
            }
#pragma warning restore CA1416 // Validate platform compatibility
            return targetUncFilePath;
        }

        private async Task<double?> TryGetFileDurationAsync(string uncPath, string username, string password, string domain)
        {
            var fileType = Path.GetExtension(uncPath);
            var fileName = Path.GetFileName(uncPath);
            double? duration = null;
            try
            {
#pragma warning disable CA1416 // Validate platform compatibility
                UserCredentials credentials = new UserCredentials(domain, username, password);
                using (SafeAccessTokenHandle userHandle = credentials.LogonUser(LogonType.NewCredentials))
                {
                    duration = await WindowsIdentity.RunImpersonatedAsync(userHandle, async () =>
                    {
                        var file = Create(uncPath);

                        return await Task.FromResult(file.Properties.Duration.TotalSeconds);
                    });
                }
#pragma warning restore CA1416 // Validate platform compatibility
            }
            catch (TagLib.UnsupportedFormatException exc)
            {
                _logger.LogWarning(exc, $"Cannot get duration for file format {fileType}");
            }
            //TODO Throw the exception up?
            catch (TagLib.CorruptFileException exc)
            {
                _logger.LogError(exc, $"Corrupt file {fileName}");
            }

            return duration;
        }

        private async Task<string> CopyFileAsync(string sourceSystemName, string sourceUncPath, FileMode fileMode, string targetUncPath, string username, string password, string domain)
        {
            var uncFilePath = Path.Combine(targetUncPath, sourceSystemName);

#pragma warning disable CA1416 // Validate platform compatibility
            UserCredentials credentials = new UserCredentials(domain, username, password);
            using (SafeAccessTokenHandle userHandle = credentials.LogonUser(LogonType.NewCredentials))
            {
                await WindowsIdentity.RunImpersonatedAsync(userHandle, async () =>
                {
                    using (var stream = new FileStream(uncFilePath, fileMode, FileAccess.Write))
                    {
                        using (var sourceStream = new FileStream(sourceUncPath, FileMode.Open, FileAccess.Read))
                        {
                            await sourceStream.CopyToAsync(stream);
                        }
                    }
                });
            }
#pragma warning restore CA1416 // Validate platform compatibility
            return uncFilePath;
        }

        private async Task<string> CopyFileAsync(
            string sourceSystemName, 
            string sourceUncPath, 
            FileMode fileMode, 
            string targetUncPath, 
            string sourceUsername, 
            string sourcePassword, 
            string sourceDomain, 
            string targetUsername, 
            string targetPassword, 
            string targetDomain)
        {
            var uncFilePath = Path.Combine(targetUncPath, sourceSystemName);

#pragma warning disable CA1416 // Validate platform compatibility
            UserCredentials targetCredentials = new UserCredentials(targetDomain, targetUsername, targetPassword);
            using (SafeAccessTokenHandle targetUserHandle = targetCredentials.LogonUser(LogonType.NewCredentials))
            {
                await WindowsIdentity.RunImpersonatedAsync(targetUserHandle, async () =>
                {
                    using (var stream = new FileStream(uncFilePath, fileMode, FileAccess.Write))
                    {
                        UserCredentials sourceCredentials = new UserCredentials(sourceDomain, sourceUsername, sourcePassword);
                        using (SafeAccessTokenHandle sourceUserHandle = sourceCredentials.LogonUser(LogonType.NewCredentials))
                        {
                            await WindowsIdentity.RunImpersonatedAsync(sourceUserHandle, async () =>
                            {
                                using (var sourceStream = new FileStream(sourceUncPath, FileMode.Open, FileAccess.Read))
                                {
                                    await sourceStream.CopyToAsync(stream);
                                }
                            });
                        }
                    }
                });
            }
#pragma warning restore CA1416 // Validate platform compatibility
            return uncFilePath;
        }

        private async Task<byte[]?> GetFileAsync(string uncFilePath, string username, string password, string domain)
        {
            byte[]? content = null;
#pragma warning disable CA1416 // Validate platform compatibility
            UserCredentials credentials = new UserCredentials(domain, username, password);
            using (SafeAccessTokenHandle userHandle = credentials.LogonUser(LogonType.NewCredentials))
            {
                await WindowsIdentity.RunImpersonatedAsync(userHandle, async () =>
                {
                    using (var stream = new FileStream(uncFilePath, FileMode.Open, FileAccess.Read))
                    {
                        content = new byte[stream.Length];
                        await stream.ReadAsync(content, 0, (int)stream.Length);
                    }
                });
            }
#pragma warning restore CA1416 // Validate platform compatibility
            return content;
        }

        //public FileStreamLocation? GetLocationFromUncPath(string uncFilePath)
        //{
        //    if (!Path.IsPathFullyQualified(uncFilePath))
        //    {
        //        throw new InvalidDataException("Not an UNC path");
        //    }
        //    FileStreamLocation? location = null;

        //    return location;
        //}

        private Stream GetFileStream(string uncFilePath, string username, string password, string domain)
        {
            Stream stream = Stream.Null;
#pragma warning disable CA1416 // Validate platform compatibility
            UserCredentials credentials = new UserCredentials(domain, username, password);
            using (SafeAccessTokenHandle userHandle = credentials.LogonUser(LogonType.NewCredentials))
            
            stream = WindowsIdentity.RunImpersonated(userHandle, () =>
                new FileStream(uncFilePath, FileMode.Open, FileAccess.Read)   
            );
#pragma warning restore CA1416 // Validate platform compatibility
            return stream;
        }

        public async Task<bool> FileExistsAsync(string uncFilePath, FileStreamLocation location)
        {
            string filename = Path.GetFileName(uncFilePath);
            bool fileExists = false;

            switch (location)
            {
                case FileStreamLocation.File:
                    fileExists =
                        await _fileContext.VFileContents
                        .Where(f => f.Name == filename && !f.IsDirectory)
                        .AnyAsync();

                    break;
                case FileStreamLocation.Buffer:
                    fileExists =
                        await _bufferFileContext.VFileContents
                        .Where(f => f.Name == filename && !f.IsDirectory)
                        .AnyAsync();

                    break;
                case FileStreamLocation.Adjunct:
                    fileExists =
                        await _adjunctFileContext.VFileContents
                        .Where(f => f.Name == filename && !f.IsDirectory)
                        .AnyAsync();
                    break;
                case FileStreamLocation.Master:
                    fileExists =
                        await _masterFileContext.VFileContents
                        .Where(f => f.Name == filename && !f.IsDirectory)
                        .AnyAsync();
                    break;
            }

            return fileExists;
        }

        public async Task<FileModel?> GetFileAsync(string uncFilePath, FileStreamLocation location, bool getContent = true)
        {

            string filename = Path.GetFileName(uncFilePath);

            FileModel? file = null;
            FileStreamCredential? credential = GetCredential(location, true);

            switch (location)
            {
                case FileStreamLocation.File:
                    file =
                        await _fileContext.VFileContents
                        .Where(f => f.Name == filename && !f.IsDirectory)
                        .Select(f => new FileModel()
                        {
                            Name = f.Name,
                            SystemName = f.Name,
                            Type = f.FileType!,
                            Size = f.CachedFileSize ?? 0
                        })
                        .SingleOrDefaultAsync();

                    break;
                case FileStreamLocation.Buffer:
                    file =
                        await _bufferFileContext.VFileContents
                        .Where(f => f.Name == filename && !f.IsDirectory)
                        .Select(f => new FileModel()
                        {
                            Name = f.Name,
                            SystemName = f.Name,
                            Type = f.FileType!,
                            Size = f.CachedFileSize ?? 0
                        })
                        .SingleOrDefaultAsync();

                    break;
                case FileStreamLocation.Adjunct:
                    file =
                        await _adjunctFileContext.VFileContents
                        .Where(f => f.Name == filename && !f.IsDirectory)
                        .Select(f => new FileModel()
                        {
                            Name = f.Name,
                            SystemName = f.Name,
                            Type = f.FileType!,
                            Size = f.CachedFileSize ?? 0
                        })
                        .SingleOrDefaultAsync();
                    break;
                case FileStreamLocation.Master:
                    file =
                        await _masterFileContext.VFileContents
                        .Where(f => f.Name == filename && !f.IsDirectory)
                        .Select(f => new FileModel()
                        {
                            Name = f.Name,
                            SystemName = f.Name,
                            Type = f.FileType!,
                            Size = f.CachedFileSize ?? 0
                        })
                        .SingleOrDefaultAsync();
                    break;
            }

            if (file != null && getContent == true)
            {
                file.Content = await GetFileAsync(uncFilePath, credential?.Username!, credential?.Password!, credential?.Domain!);
            }

            return file;
        }

        public async Task<Stream> GetFileStreamAsync(string uncFilePath, FileStreamLocation location)
        {
            if (!await FileExistsAsync(uncFilePath, location))
            {
                throw new FileNotFoundException();
            }
            FileStreamCredential? credential = GetCredential(location, true);
            return GetFileStream(uncFilePath, credential?.Username!, credential?.Password!, credential?.Domain!);
        }

        public async Task<string> GetFileBase64StringAsync(string uncFilePath, FileStreamLocation location)
        {
            if (!await FileExistsAsync(uncFilePath, location))
            {
                throw new FileNotFoundException();
            }
            FileStreamCredential? credential = GetCredential(location, true);

            return Convert.ToBase64String(await GetFileAsync(uncFilePath, credential?.Username!, credential?.Password!, credential?.Domain!));
        }

        public async Task<OperationResult> CreateFileAsync(FileModel model, FileStreamLocation location)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {
                string uncPath = GetUncPath(location);
                FileStreamCredential? credential = GetCredential(location);

                var uncFilePath = await CreateFileAsync(model, FileMode.CreateNew, uncPath, credential?.Username!, credential?.Password!, credential?.Domain!);

                return OperationResult.Succeed(uncFilePath);
            }
            catch(IOException exc)
            {
                _logger.LogError(exc, $"Error creating file {model.SystemName} ({model.Name}) at {location}");

                //ERROR_FILE_EXISTS 80
                //ERROR_ALREADY_EXISTS 183
                if (exc.HResult == 80 || exc.HResult == 183)
                {
                    return OperationResult.Failed(false, exc.HResult, _localizer.GetString("Error_FileAlreadyExists", $"{model.Name} ({model.SystemName})"));
                }
                return OperationResult.Failed(exc.ToString());
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating file {model.SystemName} ({model.Name}) at {location}");
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> TryCreateFileAsPdfAsync(FileModel model, FileStreamLocation location)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {
                string uncPath = GetUncPath(location);
                FileStreamCredential? credential = GetCredential(location);

                var uncFilePath = await TryCreateFileAsPdfAsync(model, FileMode.CreateNew, uncPath, credential?.Username!, credential?.Password!, credential?.Domain!);

                return OperationResult.Succeed(uncFilePath);
            }
            catch (FileTypeNotSupportedException exc)
            {
                _logger.LogWarning(exc, "File type not supported for conversion to PDF");

                return OperationResult.Success;
            }
            catch (IOException exc)
            {
                _logger.LogError(exc, $"Error creating file as PDF {model.SystemName} ({model.Name}) at {location}");

                //ERROR_FILE_EXISTS 80
                //ERROR_ALREADY_EXISTS 183
                if (exc.HResult == 80 || exc.HResult == 183)
                {
                    return OperationResult.Failed(false, exc.HResult, _localizer.GetString("Error_FileAlreadyExists", $"{model.Name} ({model.SystemName})"));
                }
                return OperationResult.Failed(exc.ToString());
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating file as PDF {model.SystemName} ({model.Name}) at {location}");
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<double?> TryGetFileDurationAsync(string uncPath, FileStreamLocation location)
        {
            FileStreamCredential? credential = GetCredential(location);
            return await TryGetFileDurationAsync(uncPath, credential?.Username!, credential?.Password!,credential?.Domain!);
        }

        //private static byte[] ImageToByteArray(Bitmap img)
        //{
        //    using (var stream = new MemoryStream())
        //    {
        //        img.Save(stream, System.Drawing.Imaging.ImageFormat.Png);
        //        return stream.ToArray();
        //    }
        //}

        public async Task<Stream> TryConvertFileToImageAsync(string uncPath, FileStreamLocation location)
        {
            using var stream = await GetFileStreamAsync(uncPath, location);
            
#pragma warning disable CA1416 // Validate platform compatibility
            var bitmap = Bitmap.FromStream(stream);
#pragma warning restore CA1416 // Validate platform compatibility

            var jpgStream = new MemoryStream();

#pragma warning disable CA1416 // Validate platform compatibility
            bitmap.Save(jpgStream, ImageFormat.Jpeg);
#pragma warning restore CA1416 // Validate platform compatibility
            jpgStream.Position = 0;

            return jpgStream;

            //byte[] bytes;

            //using Stream contentStream = new MemoryStream(content);
            //contentStream.Position = 0;

            //Bitmap bm = (Bitmap)Bitmap.FromStream(contentStream);
            //bm.Save("photo.jpg", ImageFormat.Jpeg);

            //bytes = ImageToByteArray(bm);

            //return bytes;
        }

        public async Task<OperationResult> CopyFileAsync(string sourceSystemName, string sourceUncPath, string sourceName, FileStreamLocation location)
        {
            if (string.IsNullOrWhiteSpace(sourceSystemName))
            {
                throw new ArgumentNullException(nameof(sourceSystemName));
            }

            if (string.IsNullOrWhiteSpace(sourceUncPath))
            {
                throw new ArgumentNullException(nameof(sourceUncPath));
            }

            try
            {
                string uncPath = GetUncPath(location);
                FileStreamCredential? credential = GetCredential(location);

                var uncFilePath = await CopyFileAsync(sourceSystemName, sourceUncPath, FileMode.Create, uncPath, credential?.Username!, credential?.Password!, credential?.Domain!);

                return OperationResult.Succeed(uncFilePath);
            }
            catch (IOException exc)
            {
                _logger.LogError(exc, $"Error copying file {sourceSystemName} ({sourceName}) to {location}");
                return OperationResult.Failed(exc.ToString());
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error copying file {sourceSystemName} ({sourceName}) to {location}");
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> CopyFileAsync(
            string sourceSystemName, 
            string sourceUncPath, 
            string sourceName, 
            FileStreamLocation sourceLocation, 
            FileStreamLocation targetLocation)
        {
            if (string.IsNullOrWhiteSpace(sourceSystemName))
            {
                throw new ArgumentNullException(nameof(sourceSystemName));
            }

            if (string.IsNullOrWhiteSpace(sourceUncPath))
            {
                throw new ArgumentNullException(nameof(sourceUncPath));
            }

            try
            {
                string uncPath = GetUncPath(targetLocation);
                FileStreamCredential? sourceCredential = GetCredential(sourceLocation);
                FileStreamCredential? targetCredential = GetCredential(targetLocation);

                var uncFilePath = 
                    await CopyFileAsync(
                        sourceSystemName, 
                        sourceUncPath, 
                        FileMode.Create, 
                        uncPath, 
                        sourceCredential?.Username!, 
                        sourceCredential?.Password!, 
                        sourceCredential?.Domain!, 
                        targetCredential?.Username!, 
                        targetCredential?.Password!, 
                        targetCredential?.Domain!);

                return OperationResult.Succeed(uncFilePath);
            }
            catch (IOException exc)
            {
                _logger.LogError(exc, $"Error copying file {sourceSystemName} ({sourceName}) from {sourceLocation} to {targetLocation}");
                return OperationResult.Failed(exc.ToString());
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error copying file {sourceSystemName} ({sourceName}) from {sourceLocation} to {targetLocation}");
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> UpdateFileAsync(FileModel model, FileStreamLocation location)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {
                string uncPath = GetUncPath(location);
                FileStreamCredential? credential = GetCredential(location);

                var uncFilePath = await CreateFileAsync(model, FileMode.Create, uncPath, credential?.Username!, credential?.Password!, credential?.Domain!);

                return OperationResult.Succeed(uncFilePath);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> UploadFileAsync(string fileName, Stream data, long offset)
        {
            FileStreamLocation location = FileStreamLocation.Buffer;
            try
            {
                string uncPath = GetUncPath(location);
                FileStreamCredential? credential = GetCredential(location);
                string uncFilePath = Path.Combine(uncPath, fileName);


                UserCredentials credentials = new UserCredentials(credential?.Domain, credential?.Username, credential?.Password);
                using (SafeAccessTokenHandle userHandle = credentials.LogonUser(LogonType.NewCredentials))
                {
#pragma warning disable CA1416 // Validate platform compatibility
                    await WindowsIdentity.RunImpersonatedAsync(userHandle, async () =>
                    {
                        using (var stream = new FileStream(uncFilePath, offset == 0 ? FileMode.Create : FileMode.Append, FileAccess.Write))
                        {
                            await data.CopyToAsync(stream);
                            stream.Flush();
                            stream.Close();
                        }
                    });
#pragma warning restore CA1416 // Validate platform compatibility
                }
                return OperationResult.Succeed(uncFilePath);
            }
            catch (Exception e)
            {
                return OperationResult.Failed(e.ToString());
            }
        }

        public OperationResult DeleteFile(string filePath, FileStreamLocation location)
        {
            if (String.IsNullOrWhiteSpace(filePath))
            {
                throw new ArgumentNullException(nameof(filePath));
            }

            try
            {
                FileStreamCredential? credential = GetCredential(location);
                OperationResult result = DeleteFile(filePath, credential?.Username!, credential?.Password!, credential?.Domain!);
                return result;
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error on deleting file");
                return OperationResult.Failed(exc.ToString());
            }
        }

        private OperationResult DeleteFile(string filePath, string username, string password, string domain)
        {

#pragma warning disable CA1416 // Validate platform compatibility
            UserCredentials credentials = new UserCredentials(domain, username, password);
            using (SafeAccessTokenHandle userHandle = credentials.LogonUser(LogonType.NewCredentials))
            {
                WindowsIdentity.RunImpersonated(userHandle, () =>
                {
                    if (System.IO.File.Exists(filePath))
                    {
                        System.IO.File.Delete(filePath);
                    }
                });
            }
#pragma warning restore CA1416 // Validate platform compatibility
            return OperationResult.Success;
        }

        public async Task<OperationResult> ExecuteFileAction(FileStreamLocation location, Func<Task<OperationResult>> action)
        {
            OperationResult result = OperationResult.Failed(new string[] { });
            try
            {
                FileStreamCredential? credential = GetCredential(location);

                UserCredentials credentials = new UserCredentials(credential?.Domain!, credential?.Username!, credential?.Password!);
                using (SafeAccessTokenHandle userHandle = credentials.LogonUser(LogonType.NewCredentials))
                {
#pragma warning disable CA1416 // Validate platform compatibility
                    await WindowsIdentity.RunImpersonatedAsync(userHandle, async () =>
                    {
                        result = await action();
                    });
#pragma warning restore CA1416 // Validate platform compatibility
                }
            }
            catch (Exception e)
            {
                result = OperationResult.Failed(new string [] { e.Message });
            }

            return result;
        }

        public string GetMasterDbUncFileName(string uncFileName)
        {
            return Path.Combine(GetUncPath(FileStreamLocation.Master), Path.GetFileName(uncFileName));
        }

        
    }
}
