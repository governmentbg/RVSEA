using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Extensions.Models;
using DAA.Models.File;
using DAA.Models.Films;
using DAA.Services.Files;
using DAA.Services.FileUploadApp;
using DAA.Services.Process;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System.Text;

namespace DAA.Services.Films
{
    public class FilmDocumentService : BaseService, IFilmDocumentService
    {
        private readonly IUserInfo _userInfo;
        private readonly IFileService _fileService;
        private readonly IProcessService _processService;
        private readonly IFileUploadAppService _fileUploadAppService;

        public FilmDocumentService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IUserInfo userInfo,
            IFileService fileService,
            IProcessService processService,
            IFileUploadAppService fileUploadAppService,
            ILogger<FilmDocumentService> logger)
            : base(context, localizer, logger)
        {
            _userInfo = userInfo;
            _fileService = fileService;
            _processService = processService;
            _fileUploadAppService = fileUploadAppService;
        }

        public DataSourceResponseModel<FilmPackageDocumentShortModel> GetAll(DataSourceRequestModel model, int packageId)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.FilmPackageDocuments
                .Include(x => x.DocumentType)
                .Where(x => x.PackageId == packageId && !x.Deleted)
                .OrderBy(x => x.DocumentTypeId).ThenBy(x => x.Id)
                .AsQueryable();


            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }

            QueryResponseModel<FilmPackageDocument> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<FilmPackageDocumentShortModel> result = new DataSourceResponseModel<FilmPackageDocumentShortModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => x.ToShortModel())
            };

            return result;
        }

        private async Task<OperationResult> CanManipulateDocument(string entityType, Guid entitySystemIdentifier)
        {
            if (entityType != BusinessObjectType.Film)
            {
                return OperationResult.Failed(_localizer.GetString("Error_InvalidEntityType").ToString());
            }

            var activeProcess = await _processService.GetCurrentActiveProcess(entityType, entitySystemIdentifier);
            if (activeProcess == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_NoActiveProcess").ToString());
            }

            if (activeProcess.ActiveProcessStepTypeId != (int)ProcessStepType.Film_CreatePackages &&
                activeProcess.ActiveProcessStepTypeId != (int)ProcessStepType.Film_EditAllData &&
                activeProcess.ActiveProcessStepTypeId != (int)ProcessStepType.Film_ReturnAllForEdit)
            {
                return OperationResult.Failed(_localizer.GetString("Error_NoEditStep").ToString());
            }

            return OperationResult.Success;
        }

        public async Task<OperationResult> CreateAsync(FilmPackageDocumentCreateModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            OperationResult manipulateResult = await CanManipulateDocument(model.EntityType, model.EntitySystemIdentifier);
            if (!manipulateResult.Succeeded)
            {
                return manipulateResult;
            }

            string? filePath = string.Empty;
            string? fileName = string.Empty;

            using var transaction = _context.Database.BeginTransaction();

            try
            {
                var doc = new FilmPackageDocument
                {
                    PackageId = model.PackageId,
                    DocumentTypeId = model.DocumentTypeId,
                    Description = model.Description,                    
                };

                if (model.File != null)
                {
                    FileModel fileModel = await ParseAttachmentAsync(model.File);

                    var existing = await _context.FilmPackageDocuments
                        .Where(x => x.PackageId == model.PackageId && !x.Deleted && String.Equals(x.FileName, fileModel.Name))
                        .FirstOrDefaultAsync();

                    if (existing != null)
                    {
                        throw new CustomException(_localizer.GetString("Error_FileNameExists").ToString());
                    }

                    bool isValidExtension = await _fileUploadAppService.IsFileExtensionValid(fileModel.Name);
                    if (!isValidExtension)
                    {
                        throw new FileTypeNotSupportedException(_localizer.GetString("Error_UnsupportedFileType", fileModel.Type).ToString());
                    }

                    if (fileModel.Content?.Length == 0)
                    {
                        throw new CustomException(_localizer.GetString("Error_MissingOrEmptyFile").ToString());
                    }

                    var result = await _fileService.CreateFileAsync(fileModel, FileStreamLocation.Buffer);
                    if (!result.Succeeded)
                    {
                        throw new Exception(result.ToString());
                    }
                    filePath = result.Data?.ToString();
                    fileName = fileModel.Name;

                    doc.FileId = fileModel.SystemName;
                    doc.FilePath = filePath;
                    doc.FileName = fileModel.Name;
                    doc.FileType = fileModel.Type;
                    doc.ContentType = fileModel.ContentType;
                    doc.FileSizeInBytes = fileModel.Content?.Length;
                    doc.FileLocation = (int)FileStreamLocation.Buffer;
                    doc.HashCode = FileUtils.ChecksumUtil.Calculate(fileModel.Content!);
                }
                else
                {
                    throw new CustomException(_localizer.GetString("Error_MissingOrEmptyFile").ToString());
                }

                _context.FilmPackageDocuments.Add(doc);
                await _context.SaveAsync("Film package document created");
                await UpdateFilmSize(doc.PackageId);

                if (!model.SkipValidation)
                {
                    await _fileUploadAppService.ValidateFile(doc.FilePath!, doc.HashCode!, doc);
                }
                else
                {
                    _logger.LogInformation($"Skip validation for file {filePath} ({doc.FileName})");
                    await _fileUploadAppService.ValidateFile(doc.FilePath!, doc.HashCode!, doc, true);
                }

                transaction.Commit();
                return OperationResult.Succeed(doc.Id);
            }
            //catch(CustomException ex)
            //{
            //    transaction.Rollback();
            //    return OperationResult.Failed(ex.Message);
            //}
            catch (Exception exc)
            {
                var errors = new List<string>() { _localizer.GetString("Error_InvalidFile", fileName) };

                if (!String.IsNullOrWhiteSpace(filePath))
                {
                    var deleteFileResult = _fileService.DeleteFile(filePath!, FileStreamLocation.Buffer);
                    if (!deleteFileResult.Succeeded)
                    {
                        errors.Add(deleteFileResult.ToString());
                    }
                }
                transaction.Rollback();
                return OperationResult.Failed(errors.ToArray());
            }
        }


        public async Task<FilmPackageDocumentDisplayModel?> GetById(int id)
        {
            var doc =
                await _context.FilmPackageDocuments
                .Include(x => x.DocumentType)
                .Where(f => f.Id == id && !f.Deleted)
                .Select(f => f.ToDisplayModel())
                .SingleOrDefaultAsync();

            return doc;
        }

        public async Task<OperationResult> UpdateAsync(FilmPackageDocumentUpdateModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            OperationResult manipulateResult = await CanManipulateDocument(model.EntityType, model.EntitySystemIdentifier);
            if (!manipulateResult.Succeeded)
            {
                return manipulateResult;
            }

            string? filePath = string.Empty;
            string? fileName = string.Empty;

            using var transaction = _context.Database.BeginTransaction();

            try
            {
                var doc = await _context.FilmPackageDocuments.FindAsync(model.Id);
                if (doc == null)
                {
                    throw new CustomException(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                doc.DocumentTypeId = model.DocumentTypeId;
                doc.Description = model.Description;

                if (model.File != null)
                {
                    FileModel fileModel = await ParseAttachmentAsync(model.File);

                    var existing = await _context.FilmPackageDocuments
                        .Where(x => x.Id != model.Id && !x.Deleted && x.PackageId == model.PackageId && String.Equals(x.FileName, fileModel.Name))
                        .FirstOrDefaultAsync();

                    if (existing != null)
                    {
                        throw new CustomException(_localizer.GetString("Error_FileNameExists").ToString());
                    }

                    bool isValidExtension = await _fileUploadAppService.IsFileExtensionValid(fileModel.Name);
                    if (!isValidExtension)
                    {
                        throw new FileTypeNotSupportedException(_localizer.GetString("Error_UnsupportedFileType", fileModel.Type).ToString());
                    }

                    if (fileModel.Content?.Length > 0)
                    {
                        fileModel.SystemName = $"{doc.FileId!.Split('.')[0]}.{fileModel.Type}";

                        var result = await _fileService.UpdateFileAsync(fileModel, FileStreamLocation.Buffer);
                        if (!result.Succeeded)
                        {
                            throw new Exception(result.ToString());
                        }
                        filePath = result.Data?.ToString();
                        fileName = fileModel.Name;

                        doc.FileId = fileModel.SystemName;
                        doc.FilePath = filePath;
                        doc.FileName = fileModel.Name;
                        doc.FileType = fileModel.Type;
                        doc.ContentType = fileModel.ContentType;
                        doc.FileSizeInBytes = fileModel.Content.Length;
                        doc.FileLocation = (int)FileStreamLocation.Buffer;
                        doc.HashCode = FileUtils.ChecksumUtil.Calculate(fileModel.Content!);
                    }
                    else
                    {
                        throw new CustomException(_localizer.GetString("Error_MissingOrEmptyFile").ToString());
                    }
                }
                else
                {
                    throw new CustomException(_localizer.GetString("Error_MissingOrEmptyFile").ToString());
                }

                _context.Update(doc);
                await _context.SaveAsync("Film document updated");

                await UpdateFilmSize(doc.PackageId);

                if (!model.SkipValidation)
                {
                    await _fileUploadAppService.ValidateFile(doc.FilePath!, doc.HashCode!, doc);
                }
                else
                {
                    _logger.LogInformation($"Skip validation for file {doc.FilePath} ({doc.FileName})");
                    await _fileUploadAppService.ValidateFile(doc.FilePath!, doc.HashCode!, doc, true);
                }

                transaction.Commit();
                return OperationResult.Success;
            }
            catch (CustomException ex)
            {
                var errors = new List<string>() { _localizer.GetString("Error_InvalidFile", fileName) };

                if (!String.IsNullOrWhiteSpace(filePath))
                {
                    var deleteFileResult = _fileService.DeleteFile(filePath!, FileStreamLocation.Buffer);
                    if (!deleteFileResult.Succeeded)
                    {
                        errors.Add(deleteFileResult.ToString());
                    }
                }
                transaction.Rollback();
                return OperationResult.Failed(errors.ToArray());
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        public async Task<OperationResult> DeleteAsync(int id)
        {
            var doc = await _context.FilmPackageDocuments
                .Where(x => x.Id == id && !x.Deleted)
                .FirstOrDefaultAsync();

            if (doc == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            var film = await _context.FilmDrafts
                .Where(x => !x.Deleted && x.IsCurrent && (x.PackageAid == doc.PackageId || x.PackageBid == doc.PackageId))
                .FirstOrDefaultAsync();

            if(film == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_InvalidEntityType").ToString());
            }

            OperationResult manipulateResult = await CanManipulateDocument(BusinessObjectType.Film, film.SystemIdentifier);
            if (!manipulateResult.Succeeded)
            {
                return manipulateResult;
            }

            using var transaction = _context.Database.BeginTransaction();

            try
            {
                if (await IsUsedInCards(id))
                {
                    throw new Exception(_localizer.GetString("Error_DocumentUsedInCard").ToString());
                }


                doc.Deleted = true;
                doc.DeletedOn = DateTime.UtcNow;
                doc.DeletedBy = _userInfo.CurrentUserId;

                _context.Update(doc);
                await _context.SaveAsync("Film document deleted");

                //var deleteFileResult = _fileService.DeleteFile(doc.FilePath!, (FileStreamLocation)doc.FileLocation!.Value);
                //if (!deleteFileResult.Succeeded)
                //{
                //    throw new Exception(String.Join("; ", deleteFileResult.Errors));
                //}

                await UpdateFilmSize(doc.PackageId);

                transaction.Commit();
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        private async Task<bool> IsUsedInCards(int docId)
        {
            var cardIds = await _context.FilmCardDocuments
                .Where(x => x.PackageDocumentId == docId)
                .Select(x => x.CardId)
                .ToListAsync();

            var activeCards = await _context.FilmCards
                .Where(x => cardIds.Contains(x.Id) && !x.Deleted)
                .ToListAsync();

            var activeDraftCards = await _context.FilmCardDrafts
                .Where(x => cardIds.Contains(x.Id) && !x.Deleted && x.IsCurrent)
                .ToListAsync();

            return (activeCards != null && activeCards.Count > 0) || (activeDraftCards != null && activeDraftCards.Count > 0);
        }

        public async Task<OperationResult> DeletePackageAsync(int packageId)
        {
            try
            {
                var package = await _context.FilmPackages.FindAsync(packageId);
                if (package == null)
                {
                    return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                package.Deleted = true;
                package.DeletedOn = DateTime.UtcNow;
                package.DeletedBy = _userInfo.CurrentUserId;

                _context.Update(package);

                var docs = _context.FilmPackageDocuments.Where(x => x.PackageId == packageId && !x.Deleted).Select(x => x);

                await docs.ForEachAsync(x =>
                {
                    x.Deleted = true;
                    x.DeletedBy = _userInfo.CurrentUserId;
                    x.DeletedOn = DateTime.UtcNow;
                });

                await _context.SaveAsync("Film package deleted");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<FileModel?> GetFile(int docId)
        {
            var doc = await _context.FilmPackageDocuments.FindAsync(docId);
            if(doc == null || String.IsNullOrWhiteSpace(doc.FilePath))
            {
                return null;
            }

            FileStreamLocation location = doc.FileLocation != null ? (FileStreamLocation)doc.FileLocation : FileStreamLocation.Buffer;
            var file = await _fileService.GetFileAsync(doc.FilePath, location);
            file!.ContentType = doc.ContentType!;
            file!.Name = doc.FileName!;
            return file;
        }

        public async Task<OperationResult> CopyPackageAsync(int sourcePackageId, int destinationPackageId, FileStreamLocation locationToCopyTo, bool setCopyId)
        {
            var docs = await _context.FilmPackageDocuments
                .Where(x => x.PackageId == sourcePackageId && !x.Deleted)
                .ToListAsync();

            foreach (var doc in docs)
            {
                await doCreateDoc(doc, destinationPackageId, locationToCopyTo, setCopyId);
            }

            await _context.SaveAsync("Film package copied");

            return OperationResult.Succeed(destinationPackageId);
        }


        public async Task<OperationResult> UpdatePackageAsync(int sourcePackageId, int destinationPackageId, FileStreamLocation locationToCopyTo)
        {
            var sourceDocs = await _context.FilmPackageDocuments
                .Where(x => x.PackageId == sourcePackageId && !x.Deleted)
                .ToListAsync();

            var destDocs = await _context.FilmPackageDocuments
                .Where(x => x.PackageId == destinationPackageId && !x.Deleted)
                .ToListAsync();

            List<int> updatedDocIds = new List<int>();
            foreach (var doc in sourceDocs)
            {
                var existing = destDocs
                    //.Where(x => x.DocumentTypeId == doc.DocumentTypeId && !x.Deleted && x.FileName == doc.FileName)
                    .Where(x => doc.CopiedFromId.HasValue && x.Id == doc.CopiedFromId.Value)
                    .FirstOrDefault();

                if(existing == null)
                {
                    var newDoc = await doCreateDoc(doc, destinationPackageId, locationToCopyTo, false);
                    await _context.SaveAsync("Film package created");
                    doc.CopiedFromId = newDoc.Id;
                    _context.FilmPackageDocuments.Update(doc);
                }
                else
                {
                    await doUpdateDoc(doc, existing, locationToCopyTo);
                    updatedDocIds.Add(existing.Id);
                }                
            }

            var docsToDelete = destDocs.Where(x => !updatedDocIds.Contains(x.Id)).ToList();
            docsToDelete.ForEach(x =>
            {
                x.Deleted = true;
                x.DeletedOn = DateTime.UtcNow;
                x.DeletedBy = _userInfo.CurrentUserId;
            });

            _context.UpdateRange(docsToDelete);

            await _context.SaveAsync("Film package updated");

            return OperationResult.Succeed(destinationPackageId);
        }

        private async Task<FilmPackageDocument> doCreateDoc(FilmPackageDocument doc, int destinationPackageId, FileStreamLocation locationToCopyTo, bool setCopyId)
        {
            var newDoc = new FilmPackageDocument
            {
                PackageId = destinationPackageId,
                DocumentTypeId = doc.DocumentTypeId,
                Description = doc.Description,
                FileName = doc.FileName,
                FileType = doc.FileType,
                ContentType = doc.ContentType,
                FileSizeInBytes = doc.FileSizeInBytes,
                FileLocation = (int)locationToCopyTo,
                CopiedFromId = setCopyId ? doc.Id : null,
                ChecksumCheckResult = doc.ChecksumCheckResult,
                FileFormatCheckResult = doc.FileFormatCheckResult,
                AntivirusCheckResult = doc.AntivirusCheckResult,
                AntivirusCheckInfo = doc.AntivirusCheckInfo,
                FileInfo = doc.FileInfo,
                ErrorMessage = doc.ErrorMessage,
        };

            var fileModel = await GetFile(doc.Id);
            if (fileModel != null)
            {
                fileModel.SystemName = $"{Guid.NewGuid()}.{fileModel.Type}";
                newDoc.FileId = fileModel.SystemName;

                var result = await _fileService.CreateFileAsync(fileModel, locationToCopyTo);
                if (!result.Succeeded)
                {
                    throw new Exception(result.ToString());
                }
                newDoc.FilePath = result.Data?.ToString();
                newDoc.HashCode = String.IsNullOrWhiteSpace(doc.HashCode) ? FileUtils.ChecksumUtil.Calculate(fileModel.Content!) : doc.HashCode!;
            }

            _context.FilmPackageDocuments.Add(newDoc);

            return newDoc;
        }


        private async System.Threading.Tasks.Task doUpdateDoc(FilmPackageDocument doc, FilmPackageDocument existing, FileStreamLocation locationToCopyTo)
        {
            existing.DocumentTypeId = doc.DocumentTypeId;
            existing.Description = doc.Description;
            existing.FileName = doc.FileName;
            existing.FileType = doc.FileType;
            existing.ContentType = doc.ContentType;
            existing.FileSizeInBytes = doc.FileSizeInBytes;
            existing.FileLocation = (int)locationToCopyTo;
            existing.ChecksumCheckResult = doc.ChecksumCheckResult;
            existing.FileFormatCheckResult = doc.FileFormatCheckResult;
            existing.AntivirusCheckResult = doc.AntivirusCheckResult;
            existing.AntivirusCheckInfo = doc.AntivirusCheckInfo;
            existing.FileInfo = doc.FileInfo;
            existing.ErrorMessage = doc.ErrorMessage;

            var fileModel = await GetFile(doc.Id);
            if (fileModel != null)
            {
                fileModel.SystemName = $"{Guid.NewGuid()}.{fileModel.Type}";
                existing.FileId = fileModel.SystemName;

                var result = await _fileService.CreateFileAsync(fileModel, locationToCopyTo);
                if (!result.Succeeded)
                {
                    throw new Exception(result.ToString());
                }
                existing.FilePath = result.Data?.ToString();
                existing.HashCode = String.IsNullOrWhiteSpace(doc.HashCode) ? FileUtils.ChecksumUtil.Calculate(fileModel.Content!) : doc.HashCode!;
            }

            _context.FilmPackageDocuments.Update(existing);
        }

        private async System.Threading.Tasks.Task UpdateFilmSize(int packageId)
        {
            var film = await _context.FilmDrafts
                .Where(x => x.PackageBid == packageId)
                .FirstOrDefaultAsync();

            if(film == null)
            {
                return;
            }

            var docsSize = await _context.FilmPackageDocuments
                .Where(x => x.PackageId == packageId && !x.Deleted)
                .Select(x => x.FileSizeInBytes)
                .ToListAsync();

            long? size = 0;
            if(docsSize != null && docsSize.Count > 0)
            {
                size = docsSize.Sum();
            }

            film.Size = size.HasValue && size.Value > 0 ? size.Value.ToString() : "0";
            _context.FilmDrafts.Update(film);
            await _context.SaveAsync("Calculated film size");
        }
                
    }
}
