using DAA.Data;
using DAA.Extensions.Exceptions;
using DAA.Models.Configuration;
using DAA.Models.DigitalObjects;
using DAA.Models.File;
using DAA.Models.FileUploadApp;
using DAA.Services.Files;
using DAA.Services.Nomenclatures;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using DAA.Shared.Security;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using System.Drawing.Imaging;
using static TagLib.File;

namespace DAA.Services.FileUploadApp
{
    public class FileUploadAppService : BaseService, IFileUploadAppService
    {
        private readonly IFileService _fileService;
        //private readonly IDigitalObjectService _digitalObjectsService;
        private readonly Authorization.IAuthorizationService _authorizationService;
        private readonly INomenclatureService _nomenclatureService;
        private readonly FileUploaderAppSettings _fileUploaderAppSettings;

        //private readonly ILogger<FileUploadAppService> _logger;


        private readonly Guid _userId;
        public FileUploadAppService(IFileService fileService,
            //IDigitalObjectService digitalObjectsService,
            Authorization.IAuthorizationService authorizationService,
            INomenclatureService nomenclatureService,
            ArchivingContext context, IStringLocalizer<SharedResources> localizer,
            IOptions<FileUploaderAppSettings> fileUploaderAppSettings, IUserInfo userInfo,
            ILogger<FileUploadAppService> logger)
            : base(context, localizer, logger)
        {
            _fileService = fileService;
            //_digitalObjectsService = digitalObjectsService;
            _authorizationService = authorizationService;
            _nomenclatureService = nomenclatureService;
            _fileUploaderAppSettings = fileUploaderAppSettings.Value;

            Guid userId = userInfo?.CurrentUserId ?? throw new Exception("User not logged in!");
            _userId = userId;
            //_userId = userId != Guid.Empty ? userId : new Guid("15c64d58-c8af-4f93-f4ef-08dab0325c30"); // ако нямам User, пиша kontrax\ttest
            //_logger = logger;
        }

        public async Task<AuthorizeResultModel> Authorize()
        {
            return await ServiceAction(async () =>
            {
                string[] roles = await _authorizationService.GetRoles(_userId);

                return new AuthorizeResultModel
                {
                    Success = true,
                    CanQueueKmf = roles.Contains(ApplicationRoleType.GroupI),
                    CanQueueFund = roles.Contains(ApplicationRoleType.GroupZ),
                    AppSettings = _fileUploaderAppSettings,
                };
            });
        }

        public async Task<ListQueueResultModel> List(string computerName)
        {
            return await ServiceAction(async () =>
                new ListQueueResultModel
                {
                    Success = true,
                    Items = (await _context.FileUploadQueues.Where(q => q.ComputerName == computerName && q.UserId == _userId).OrderBy(q => q.Id).ToArrayAsync()).
                        Select(q => LoadFrom(q)).ToArray()
                }
            );
        }

        public async Task<GetExtensionsResultModel> GetExtensions()
        {
            return new GetExtensionsResultModel
            {
                Success = true,
                Items = await _nomenclatureService.GetNomenclatureValues(Shared.NomenclatureCode.FileType).Select(n => n.Text).ToArrayAsync(),
            };
        }



        public async Task<AddToQueueResultModel> Add(QueueItemModel model)
        {
            return await ServiceAction(async () =>
            {
                FileUploadQueue entity = new();
                _context.FileUploadQueues.Add(entity);
                model.DbFileName = GetDbFilenameFromUploadedFileName(model.LocalFileName, null);
                SaveTo(model, entity);
                await _context.SaveAsync("Added to upload queue.");

                return new AddToQueueResultModel
                {
                    Success = true,
                    Id = entity.Id,
                    DbFileName = model.DbFileName,
                };
            });
        }

        public async Task<AddToQueueResultModel> Update(QueueItemModel model)
        {
            return await ServiceAction(async () =>
            {
                FileUploadQueue entity = await GetQueueItem(model.Id);
                model.DbFileName = GetDbFilenameFromUploadedFileName(model.LocalFileName, model.DbFileName);
                SaveTo(model, entity);
                await _context.SaveAsync($"Updated upload queue id {model.Id}.");

                return new AddToQueueResultModel
                {
                    Success = true,
                    Id = entity.Id,
                    DbFileName = model.DbFileName,
                };
            });
        }

        public async Task<OperationResultModel> Delete(int? id)
        {
            return await ServiceAction(async () =>
            {
                _ = id ?? throw new ArgumentNullException(nameof(id));
                FileUploadQueue entity = await GetQueueItem(id.Value);
                if (!entity.Finished && entity.Position > 0 && entity.UncFileName != null)
                {
                    entity.Position = 0;
                    await _context.SaveAsync($"Upload queue item id {id}: upload position reset before file delete.");

                    OperationResult deleteFileResult = _fileService.DeleteFile(entity.UncFileName, FileStreamLocation.Buffer);
                    if (!deleteFileResult.Succeeded)
                    {
                        throw new Exception("Грешка при изтриване на частично каченият файл: " + string.Join("; ", deleteFileResult.Errors));
                    }
                }

                _context.FileUploadQueues.Remove(entity);
                await _context.SaveAsync($"Deleted upload queue id {id}.");
                return OperationResultModel.SuccessResult();
            }, $"Deleting queueId {id}");
        }

        public async Task<DocumentExistsResultModel> DocumentExists(ProcessKind processKind, Guid documentId)
        {
            //string[] guids = await GetFundViewQuery().Select(f => f.SystemIdentifier.ToString()).ToArrayAsync();
            return await ServiceAction(async () =>
            {
                bool result =
                    processKind == ProcessKind.Kmf ? await GetKmfViewQuery().AnyAsync(f => f.SystemIdentifier == documentId) :
                    processKind == ProcessKind.Fund ? await GetFundViewQuery().AnyAsync(d => d.SystemIdentifier == documentId) :
                    processKind == ProcessKind.Ed ? await GetFundViewQuery().AnyAsync(d => d.SystemIdentifier == documentId) :
                    processKind == ProcessKind.Raw ? await GetRawListViewQuery().AnyAsync(d => d.SystemIdentifier == documentId) :
                    throw new ArgumentException($"Unsupported process kind: {processKind}.");
                return new DocumentExistsResultModel
                {
                    Exists = result,
                    Success = true,
                };
            });
        }
        public async Task<DocumentExistsResultModel> FileExists(ProcessKind processKind, FileKind? fileKind, Guid documentId, int? currentQueueId, string fileName)
        {
            fileName = Path.GetFileName(fileName);

            return await ServiceAction(async () =>
            {
                bool fileIsInQueue = await _context.FileUploadQueues.AnyAsync(i =>
                    i.DocumentId == documentId &&
                    i.FileName == fileName &&
                    (!currentQueueId.HasValue || i.Id != currentQueueId) &&
                    i.ProcessKindCode == processKind.ToString() &&
                    (i.ProcessKindCode == ProcessKind.Kmf.ToString() ||
                    i.ProcessKindCode != ProcessKind.Kmf.ToString() && i.FileKindCode == fileKind.ToString())
                );

                bool fileIsInFileTables = await FileExistsInFileTables(processKind, documentId, fileName);

                return new DocumentExistsResultModel
                {
                    Exists = fileIsInQueue || fileIsInFileTables,
                    Success = true,
                };
            });
        }

        public async Task<bool> FileExistsInFileTables(ProcessKind processKind, Guid documentId, string fileName)
        {
            return
                processKind == ProcessKind.Kmf ? await GetKmfFilesViewQuery().AnyAsync(f => f.FilmSystemIdentifier == documentId && f.FileName == fileName) :
                processKind == ProcessKind.Fund ? await GetFundFilesViewQuery().AnyAsync(f => f.DocumentSystemIdentifier == documentId && f.Name == fileName && f.IsDigitized == true) :
                processKind == ProcessKind.Ed ? await GetFundFilesViewQuery().AnyAsync(f => f.DocumentSystemIdentifier == documentId && f.Name == fileName && f.IsDigitized == false) :
                processKind == ProcessKind.Raw ? await FileNameExistsInRawList(documentId, fileName) :
                throw new ArgumentException($"Unsupported process kind: {processKind}.");
        }

        public async Task<MastersForDocumentResultModel> MastersForDocument(Guid documentId)
        {
            return await ServiceAction(async () =>
            {
                CodeNameModel[] finishedItems =
                    await GetFundFilesViewQuery().Where(f => f.DocumentSystemIdentifier == documentId && f.TypeCode == (int)DigitalObjectType.MasterFile).
                        OrderBy(f => f.Name).Select(f => new CodeNameModel(f.SystemIdentifier, f.SourceName)).ToArrayAsync();

                CodeNameModel[] queueItems =
                    await _context.FileUploadQueues.Where(q => 
                        (q.ProcessKindCode == ProcessKind.Fund.ToString() || q.ProcessKindCode == ProcessKind.Ed.ToString()) &&
                        q.FileKindCode == FileKind.Master.ToString() &&
                        q.DocumentId == documentId
                    ).Select(q => new CodeNameModel(q.FinishedGuid ?? q.CreatedGuid, Path.GetFileName(q.LocalFileName))).ToArrayAsync();

                CodeNameModel[] items = finishedItems.Concat(queueItems).DistinctBy(i => i.Code).ToArray();

                return new MastersForDocumentResultModel
                {
                    Items = items,
                    Success = true,
                };
            });
        }
        public async Task<Guid> FindMasterId(Guid masterDocumentId)
        {
            // ако masterDocumentIdе бил на вече качен файл
            if (await GetFundFilesViewQuery().Where(f => f.SystemIdentifier == masterDocumentId).AnyAsync())
            {
                return masterDocumentId;
            }
            // ако мастър файлът все още не е бил качен при добавянето на производния в опашката,
            // то тогава masterDocumentId е бил CreatedGuid на мастъра, но то ебило сменено при приключване на качването на мастъра и взимам го от FinishedGuid
            // ако все още мастърът не е бил качен, връщам null -> грешка, трябва да се чака да се качи мастърът
            else
            {
                FileUploadQueue? entity = await _context.FileUploadQueues.Where(q => q.CreatedGuid == masterDocumentId).FirstOrDefaultAsync();
                if (entity == null)
                {
                    throw new Exception("Не е намерен Master файлът, който е бил избран за прикачване на файла. Променете мастър файла или изтрийте файла от опашката.");
                }
                else if (entity.FinishedGuid == null)
                {
                    throw new Exception("Мастър файлът все още не е бил качен, качете първо него преди да приключите с качването на файла.");
                }
                else
                {
                    return entity.FinishedGuid.Value;
                }
            }
        }

        public async Task<QueueItemResultModel> ValidateAndFinish(int id)
        {
            QueueItemResultModel result = new();
            try
            {
                FileUploadQueue entity = await _context.FileUploadQueues.Where(i => i.Id == id).FirstAsync();
                QueueItemModel model = LoadFrom(entity);
                result.QueueItemModel = model;

                OperationResultModel operationResult;
                OperationResultModel? checksumResult = null;
                AntivirusResultModel? antivirusResult = null;
                OperationResultModel? validateResult = null;

                try
                {
                    await ExecuteFileAction(FileStreamLocation.Buffer, async () =>
                    {
                        string fileName = entity.UncFileName!;

                        if (_fileUploaderAppSettings.VerifyChecksum)
                        {
                            checksumResult = await FileUtils.ChecksumUtil.Verify1(fileName, model.Checksum);
                        }
                        if (_fileUploaderAppSettings.ScanWithAntivirus)
                        {
                            antivirusResult = FileUtils.AntivirusUtil.Scan(fileName);
                        }
                        if (_fileUploaderAppSettings.ValidateFile)
                        {
                            try
                            {
                                await FileUtils.ValidateUtil.ValidateFile(fileName, _fileUploaderAppSettings);
                                validateResult = OperationResultModel.SuccessResult();
                            }
                            catch (Exception e)
                            {
                                validateResult = new OperationResultModel(false, e.Message);
                            }
                        }

                        return OperationResult.Success;
                    });
                    operationResult = OperationResultModel.SuccessResult();
                }
                catch (Exception e)
                {
                    operationResult = new OperationResultModel(false, e.Message);
                }


                if (AcceptValidationResults(model, operationResult, checksumResult, antivirusResult, validateResult))
                {
                    model.Finished = true;
                }

                // deriv/demo файловете може да са закачени към мастър ид (CreatedGuid) от опашката, а не към SystemIdentifier -
                // в случаите, когато мастърът все още не е бил качен при слагането им в опашката.
                // затова, преди приключване на качването, търся ид-то на мастър файла. Ако той все още не е бил качен или е бил прмахнат,
                // процесът не може да приключи.
                if ((model.ProcessKind == ProcessKind.Fund || model.ProcessKind == ProcessKind.Ed) && 
                    (model.FileKind == FileKind.Derivative || model.FileKind == FileKind.Demo))
                {
                    model.MasterDocumentId = await FindMasterId(model.MasterDocumentId!.Value);
                }

                if (model.Finished)
                {
                    Guid? addMetadataResult = await AddMetadata(entity);
                    // получава стойност само ако файлът е тим Fund/Ed - тогава има master/deriv/demo
                    // и е важно под какъв идентификатор е записан мастърът, за да се напише същия и на свързаните deriv/demo файлове
                    if ((model.ProcessKind == ProcessKind.Fund || model.ProcessKind == ProcessKind.Ed) && model.FileKind == FileKind.Master)
                    {
                        model.FinishedGuid = addMetadataResult;
                    }
                }

                SaveTo(model, entity);

                await _context.SaveAsync(
                    model.Finished ?
                    $"Finished uploading queue id {entity.Id}." :
                    $"Error in ValidateAndFinish for queue id {entity.Id}."
                );

                result.Success = true;
            }
            catch (Exception e)
            {
                result.Success = false;
                result.Message = e.Message;
            }
            return result;
        }

        private async Task<FileCheckResultModel> doValidateFile(string filePath, string checksum, bool skipFileFormatValidation)
        {
            FileCheckResultModel resultModel = new();
            try
            {
                OperationResultModel operationResult;
                OperationResultModel? checksumResult = null;
                AntivirusResultModel? antivirusResult = null;
                OperationResultModel? validateResult = null;

                try
                {
                    await ExecuteFileAction(FileStreamLocation.Buffer, async () =>
                    {
                        if (_fileUploaderAppSettings.VerifyChecksum)
                        {
                            checksumResult = await FileUtils.ChecksumUtil.Verify1(filePath, checksum);
                        }

                        if (_fileUploaderAppSettings.ScanWithAntivirus)
                        {
                            antivirusResult = FileUtils.AntivirusUtil.Scan(filePath);
                        }

                        if (_fileUploaderAppSettings.ValidateFile && !skipFileFormatValidation)
                        {
                            try
                            {
                                await FileUtils.ValidateUtil.ValidateFile(filePath, _fileUploaderAppSettings);
                                validateResult = OperationResultModel.SuccessResult();
                            }
                            catch (Exception e)
                            {
                                validateResult = new OperationResultModel(false, e.Message);
                            }
                        }

                        return OperationResult.Success;
                    });
                    operationResult = OperationResultModel.SuccessResult();
                }
                catch (Exception e)
                {
                    operationResult = new OperationResultModel(false, e.Message);
                }

                QueueItemModel model = new QueueItemModel();
                AcceptValidationResults(model, operationResult, checksumResult, antivirusResult, validateResult);

                resultModel.ErrorMessage = model.ErrorMessage;
                resultModel.FileInfo = model.FileInfo;
                resultModel.ChecksumCheckResult = model.ChecksumCheckResult;
                resultModel.AntivirusCheckResult = model.AntivirusCheckResult;
                resultModel.FileFormatCheckResult = model.FileFormatCheckResult;
                resultModel.AntivirusCheckInfo = model.AntivirusCheckInfo;

            }
            catch (Exception e)
            {
                resultModel.ErrorMessage = e.Message;
            }

            return resultModel;
        }

        private bool AcceptValidationResults(QueueItemModel model, OperationResultModel operationResult, OperationResultModel? checksumResult,
            AntivirusResultModel? antivirusResult, OperationResultModel? validateResult)
        {
            bool result = true;
            model.ErrorMessage = "";
            model.FileInfo = null;
            model.ChecksumCheckResult = null;
            model.AntivirusCheckResult = null;
            model.FileFormatCheckResult = null;
            model.AntivirusCheckInfo = JsonConvert.SerializeObject(antivirusResult);

            if (!operationResult.Success)
            {
                model.ErrorMessage += operationResult.Message + Environment.NewLine;
                result = false;
            }

            if (_fileUploaderAppSettings.VerifyChecksum)
            {
                if (checksumResult == null)
                {
                    result = false;
                }
                else if (!checksumResult.Success)
                {
                    model.ChecksumCheckResult = false;
                    model.ErrorMessage += checksumResult.Message + Environment.NewLine;
                    result = false;
                }
                else
                {
                    model.ChecksumCheckResult = true;
                }
            }

            if (_fileUploaderAppSettings.ScanWithAntivirus)
            {
                if (antivirusResult == null)
                {
                    result = false;
                }
                else if (!antivirusResult.Success || antivirusResult.Checked == false)
                {
                    result = false;
                    model.ErrorMessage += antivirusResult.Message;
                }
                else if (antivirusResult != null && antivirusResult.Success && antivirusResult.Checked == true && antivirusResult.IsVirus.HasValue)
                {
                    if (antivirusResult.IsVirus == true)
                    {
                        model.AntivirusCheckResult = false;
                        model.ErrorMessage += antivirusResult.Message + Environment.NewLine;
                        result = false;
                    }
                    else
                    {
                        model.AntivirusCheckResult = true;
                    }
                }
                else
                {
                    throw new Exception($"Невалиден резултат от проверката за вируси: {antivirusResult?.Success}:{antivirusResult?.Checked}:{antivirusResult?.IsVirus}");
                }
            }

            if (_fileUploaderAppSettings.ValidateFile)
            {
                if (validateResult == null)
                {
                    result = false;
                }
                else if (!validateResult.Success)
                {
                    model.FileFormatCheckResult = false;
                    model.ErrorMessage += validateResult.Message + Environment.NewLine;
                    result = false;
                }
                else
                {
                    model.FileFormatCheckResult = true;
                }
            }

            if (model.ErrorMessage == "")
            {
                model.ErrorMessage = null;
            }
            return result;
        }


        public async System.Threading.Tasks.Task ValidateFile(string filePath, string checksum, FilmPackageDocument doc, bool skipFileFormatValidation)
        {
            FileCheckResultModel checkResultModel = await doCommonValidation(filePath, checksum, doc.FileName!, skipFileFormatValidation);

            doc.ChecksumCheckResult = checkResultModel.ChecksumCheckResult;
            doc.FileFormatCheckResult = checkResultModel.FileFormatCheckResult;
            doc.AntivirusCheckResult = checkResultModel.AntivirusCheckResult;
            doc.AntivirusCheckInfo = checkResultModel.AntivirusCheckInfo;
            doc.FileInfo = checkResultModel.FileInfo;
            doc.ErrorMessage = checkResultModel.ErrorMessage;

            _context.FilmPackageDocuments.Update(doc);
            await _context.SaveAsync("Film package document file validated");
        }

        public async System.Threading.Tasks.Task ValidateFile(string filePath, string checksum, DigitalObjectDraft digitalObject, bool skipFileFormatValidation)
        {
            FileCheckResultModel checkResultModel = await doCommonValidation(filePath, checksum, digitalObject.SourceName, skipFileFormatValidation);

            digitalObject.ChecksumCheckResult = checkResultModel.ChecksumCheckResult;
            digitalObject.FileFormatCheckResult = checkResultModel.FileFormatCheckResult;
            digitalObject.AntivirusCheckResult = checkResultModel.AntivirusCheckResult;
            digitalObject.AntivirusCheckInfo = checkResultModel.AntivirusCheckInfo;
            digitalObject.FileInfo = checkResultModel.FileInfo;
            digitalObject.ErrorMessage = checkResultModel.ErrorMessage;

            _context.DigitalObjectDrafts.Update(digitalObject);
            await _context.SaveAsync("Digital object file validated");
        }

        public async System.Threading.Tasks.Task ValidateFile(string filePath, string checksum, PackageDocument packageDoc, bool skipFileFormatValidation)
        {
            FileCheckResultModel checkResultModel = await doCommonValidation(filePath, checksum, packageDoc.FileName!, skipFileFormatValidation);

            packageDoc.ChecksumCheckResult = checkResultModel.ChecksumCheckResult;
            packageDoc.FileFormatCheckResult = checkResultModel.FileFormatCheckResult;
            packageDoc.AntivirusCheckResult = checkResultModel.AntivirusCheckResult;
            packageDoc.AntivirusCheckInfo = checkResultModel.AntivirusCheckInfo;
            packageDoc.FileInfo = checkResultModel.FileInfo;
            packageDoc.ErrorMessage = checkResultModel.ErrorMessage;

            _context.PackageDocuments.Update(packageDoc);
            await _context.SaveAsync("Package file validated");
        }

        private async Task<FileCheckResultModel> doCommonValidation(string filePath, string checksum, string originalFileName, bool skipFileFormatValidation)
        {
            FileCheckResultModel checkResultModel = await doValidateFile(filePath, checksum, skipFileFormatValidation);

            if (checkResultModel.AntivirusCheckResult.HasValue && checkResultModel.AntivirusCheckResult.Value == false)
            {
                throw new CustomException(_localizer.GetString("Error_AntivirusCheckResult", checkResultModel.ErrorMessage!).ToString());
            }

            if (checkResultModel.ChecksumCheckResult.HasValue && checkResultModel.ChecksumCheckResult.Value == false)
            {
                throw new CustomException(_localizer.GetString("Error_ChecksumCheckResult", checkResultModel.ErrorMessage!).ToString());
            }

            if (checkResultModel.FileFormatCheckResult.HasValue && checkResultModel.FileFormatCheckResult.Value == false)
            {
                throw new CustomException(_localizer.GetString("Error_FileFormatCheckResult", originalFileName, checkResultModel.ErrorMessage!).ToString());
            }

            return checkResultModel;
        }

        private async System.Threading.Tasks.Task<Guid?> AddMetadata(FileUploadQueue queueItem)
        {
            string extensionWDot = Path.GetExtension(queueItem.LocalFileName);
            string extensionWoDot = extensionWDot.Substring(1).ToLower();
            double? audioVideoFileDuration = null;
            ProcessKind processKind = queueItem.ProcessKindCode.ToEnum<ProcessKind>();
            Guid? result = null;

            if (processKind == ProcessKind.Kmf)
            {
                VFilm filmEntity = await GetKmfViewQuery().Where(f => f.SystemIdentifier == queueItem.DocumentId).FirstAsync();
                FilmPackageDocument? entity = await _context.FilmPackageDocuments.Where(f => f.FileId == queueItem.DbFileName.ToString()).FirstOrDefaultAsync();

                if (entity == null)
                {
                    entity = new FilmPackageDocument
                    {
                        FileId = queueItem.DbFileName.ToString()
                    };
                    _context.FilmPackageDocuments.Add(entity);
                }

                entity.PackageId = filmEntity.PackageBid!.Value;
                entity.DocumentTypeId = (int)Shared.FilmDocumentType.FilmFile;
                entity.Description = queueItem.Notes;
                entity.FilePath = queueItem.UncFileName;
                entity.FileName = Path.GetFileName(queueItem.LocalFileName);
                entity.HashCode = queueItem.Checksum;
                entity.FileType = extensionWoDot;
                entity.ContentType = "application/octet-stream"; // TODO
                entity.FileSizeInBytes = queueItem.Size;
                entity.FileLocation = (int)FileStreamLocation.Buffer;
                entity.CreatedBy = queueItem.UserId;
                entity.CreatedOn = DateTime.UtcNow;

                entity.AntivirusCheckResult = queueItem.AntivirusCheckResult;
                entity.AntivirusCheckInfo = queueItem.AntivirusCheckInfo;
                entity.ChecksumCheckResult = queueItem.ChecksumCheckResult;
                entity.FileFormatCheckResult = queueItem.FileFormatCheckResult;
                entity.FileInfo = queueItem.FileInfo;
                entity.ErrorMessage = queueItem.ErrorMessage;
            }
            else if (processKind == ProcessKind.Fund || processKind == ProcessKind.Ed)
            {
                Data.VDocument documentEntity = await GetFundViewQuery().Where(d => d.SystemIdentifier == queueItem.DocumentId).FirstAsync();
                DigitalObjectDraft? entity = await _context.DigitalObjectDrafts.Where(d => d.Name == queueItem.DbFileName.ToString()).FirstOrDefaultAsync();
                if (entity == null)
                {
                    entity = new()
                    {
                        SystemIdentifier = Guid.NewGuid(),
                        //Name = queueItem.DbFileName.ToString()
                    };
                    _context.DigitalObjectDrafts.Add(entity);
                }
                result = entity.SystemIdentifier;

                //entity.ParentId = // TODO
                entity.ParentSystemIdentifier = queueItem.MasterDocumentId;
                entity.ArchiveId = documentEntity.ArchiveId;
                entity.FundDraftId = documentEntity.FundDraftId;
                entity.FundSystemIdentifier = documentEntity.FundSystemIdentifier;
                entity.InventoryDraftId = documentEntity.InventoryDraftId;
                entity.InventorySystemIdentifier = documentEntity.InventorySystemIdentifier;
                entity.ArchivalEntityDraftId = documentEntity.ArchivalEntityDraftId;
                entity.ArchivalEntitySystemIdentifier = documentEntity.ArchivalEntitySystemIdentifier;
                entity.DocumentDraftId = documentEntity.IsDraft == true ? documentEntity.Id : null;
                entity.DocumentSystemIdentifier = queueItem.DocumentId;
                entity.IsCurrent = true;
                entity.ReadOnly = false;
                entity.CreatedOn = DateTime.UtcNow;
                entity.CreatedBy = queueItem.UserId;
                entity.Deleted = false;
                entity.ExternalIdentifier = null;
                entity.HasExternalSource = false;
                //entity.Name = Path.GetFileName(queueItem.LocalFileName);
                entity.Name = queueItem.DbFileName;
                entity.SourceName = Path.GetFileName(queueItem.LocalFileName);
                entity.HashCode = queueItem.Checksum;
                entity.UncPath = queueItem.UncFileName ?? throw new Exception("queueItem.UncFileName  missing!");
                entity.FileType = extensionWoDot;
                entity.FileSize = queueItem.Size;
                entity.StatusCode = Shared.Status.New;
                entity.ContentType = "application/octet-stream"; // TODO
                entity.IsDigitized = processKind == ProcessKind.Fund ? true : false;
                FileKind? fileKind = queueItem.FileKindCode.ToEnumNullable<FileKind>();

                if (fileKind == FileKind.Master)
                {
                    await _fileService.ExecuteFileAction(FileStreamLocation.Buffer, async () =>
                    {
#pragma warning disable CA1416 // Validate platform compatibility
                        var file = Create(entity.UncPath);

                        audioVideoFileDuration = file.Properties.Duration.TotalSeconds;
#pragma warning restore CA1416 // Validate platform compatibility
                        return await System.Threading.Tasks.Task.FromResult(OperationResult.Success);
                    });
                }

                if (fileKind == FileKind.Derivative && DAA.FileUtils.Consts.IsImageExtension(extensionWDot))
                {
                    using System.IO.MemoryStream stream = new();
                    await _fileService.ExecuteFileAction(FileStreamLocation.Buffer, async () =>
                    {
#pragma warning disable CA1416 // Validate platform compatibility
                        DAA.FileUtils.WatermarkUtil.AddWatermark(entity.UncPath, stream, ImageFormat.Png);
#pragma warning restore CA1416 // Validate platform compatibility
                        return await System.Threading.Tasks.Task.FromResult(OperationResult.Success);
                    });

                    string watermarkFileName = Path.GetFileNameWithoutExtension(queueItem.LocalFileName) + ".wm.png";
                    string dbFileName = GetDbFilenameFromUploadedFileName(watermarkFileName, null);

                    stream.Position = 0;
                    string watermarkUncFileName = (string)(await _fileService.UploadFileAsync(dbFileName, stream, 0)).Data!;

                    entity.WatermarkName = watermarkFileName;
                    entity.WatermarkUncPath = watermarkUncFileName;
                }

                entity.TypeCode =
                    (int)
                    (fileKind == FileKind.Master ? DigitalObjectType.MasterFile :
                    fileKind == FileKind.Derivative ? DigitalObjectType.DerivativeFile :
                    fileKind == FileKind.Demo ? DigitalObjectType.DemoFile :
                    throw new Exception($"Invalid File kind {fileKind}"));

                entity.Duration = audioVideoFileDuration.HasValue && audioVideoFileDuration.Value > 0 ? (int)audioVideoFileDuration : null;
                entity.AntivirusCheckResult = queueItem.AntivirusCheckResult;
                entity.AntivirusCheckInfo = queueItem.AntivirusCheckInfo;
                entity.ChecksumCheckResult = queueItem.ChecksumCheckResult;
                entity.FileFormatCheckResult = queueItem.FileFormatCheckResult;
                entity.FileInfo = queueItem.FileInfo;
                entity.ErrorMessage = queueItem.ErrorMessage;

                if (queueItem.AutoGenerateDerivative == true)
                {
                    await CreateDerivative(entity);
                }
            }
            else if (processKind == ProcessKind.Raw)
            {
                InventoryDraft draftEntity = await GetRawListViewQuery().Where(f => f.SystemIdentifier == queueItem.DocumentId).FirstAsync();
                PackageDocument entity = new()
                { 
                    
                    PackageId = draftEntity.PackageBid ?? throw new ArgumentNullException(nameof(draftEntity.PackageBid)),
                    Description = queueItem.Notes,
                    CreatedOn = DateTime.Now,
                    CreatedBy = queueItem.UserId,
                    UpdatedOn = DateTime.Now,
                    UpdatedBy = queueItem.UserId,
                    Deleted = false,
                    FileId = queueItem.DbFileName,
                    FilePath = queueItem.UncFileName,
                    FileName = queueItem.FileName,
                    FileType = extensionWoDot,
                    ContentType = "application/octet-stream", // TODO
                    FileSizeInBytes = queueItem.Size,
                    FileLocation = (int)FileStreamLocation.Buffer,
                    HashCode = queueItem.Checksum,
                    ChecksumCheckResult = queueItem.ChecksumCheckResult,
                    FileFormatCheckResult = queueItem.FileFormatCheckResult,
                    AntivirusCheckResult = queueItem.AntivirusCheckResult,
                    AntivirusCheckInfo = queueItem.AntivirusCheckInfo,
                    IsInvaluable = false
                };
                _context.PackageDocuments.Add(entity);
            }
            else
            {
                throw new Exception($"Unsupported process kind: {processKind}");
            }
            await _context.SaveAsync($"Added metadata for queue id {queueItem.Id}.");
            return result;
        }

        private async Task<Guid?> CreateDerivative(DigitalObjectDraft entity)
        {
            DigitalObjectDraftModel derivativeDigitalObjectDraft = new DigitalObjectDraftModel()
            {
                ArchiveId = entity.ArchiveId,
                FundDraftId = entity.FundDraftId,
                FundSystemIdentifier = entity.FundSystemIdentifier,
                InventoryDraftId = entity.InventoryDraftId,
                InventorySystemIdentifier = entity.InventorySystemIdentifier,
                ArchivalEntityDraftId = entity.ArchivalEntityDraftId,
                ArchivalEntitySystemIdentifier = entity.ArchivalEntitySystemIdentifier,
                DocumentDraftId = entity.DocumentDraftId,
                DocumentSystemIdentifier = entity.DocumentSystemIdentifier,
                ParentId = entity.Id,
                ParentSystemIdentifier = entity.SystemIdentifier,
                IsCurrent = true,
                ReadOnly = false,
                IsDigitized = entity.IsDigitized,
                IsImported = entity.IsImported,
                TypeCode = (int)DigitalObjectType.DerivativeFile,
                StatusCode = entity.StatusCode,
                SourceName = entity.SourceName,
            };

            return await CreateDerivativeDraftAsync(entity.UncPath, FileStreamLocation.Buffer, FileStreamLocation.Buffer, derivativeDigitalObjectDraft);
        }

        public async Task<Guid?> CreateDerivativeDraftAsync(string sourceUncPath, FileStreamLocation sourceLocation, FileStreamLocation targetLocation, DigitalObjectDraftModel model)
        {
            Guid? pdfSystemIdentifier = null;
            try
            {
                FileModel? sourceFile = await _fileService.GetFileAsync(sourceUncPath, sourceLocation);
                if (sourceFile == null)
                {
                    throw new ItemNotFoundException("File does not exists", sourceUncPath);
                }

                var pdfConversionResult = await _fileService.TryCreateFileAsPdfAsync(sourceFile, targetLocation);
                if (!pdfConversionResult.Succeeded)
                {
                    throw new Exception(pdfConversionResult.ToString());
                }

                var pdfUncPath = pdfConversionResult.Data?.ToString();
                if (string.IsNullOrWhiteSpace(pdfUncPath))
                {
                    throw new Exception("Empty PDF UNC path");
                }

                var pdfFileInfo = await _fileService.GetFileAsync(pdfUncPath, targetLocation, false);
                if (pdfFileInfo == null)
                {
                    throw new ItemNotFoundException("File does not exists", pdfUncPath);
                }

                var pdfSourceName =
                    string.IsNullOrWhiteSpace(model.SourceName)
                    ? pdfFileInfo.Name
                    : $"{Path.GetFileNameWithoutExtension(model.SourceName)}{Path.GetExtension(pdfFileInfo.Name)}";

                DigitalObjectDraft pdfDigitalObjectDraft = new DigitalObjectDraft()
                {
                    SystemIdentifier = Guid.NewGuid(),
                    ArchiveId = model.ArchiveId!.Value,
                    FundDraftId = model.FundDraftId,
                    FundSystemIdentifier = model.FundSystemIdentifier!.Value,
                    InventoryDraftId = model.InventoryDraftId,
                    InventorySystemIdentifier = model.InventorySystemIdentifier!.Value,
                    ArchivalEntityDraftId = model.ArchivalEntityDraftId,
                    ArchivalEntitySystemIdentifier = model.ArchivalEntitySystemIdentifier!.Value,
                    DocumentDraftId = model.DocumentDraftId,
                    DocumentSystemIdentifier = model.DocumentSystemIdentifier!.Value,
                    ParentId = model.ParentId,
                    ParentSystemIdentifier = model.ParentSystemIdentifier,
                    AvailabilityStatusCode = (int)Shared.AvailabilityStatus.Enrollment,
                    IsCurrent = model.IsCurrent,
                    ReadOnly = model.ReadOnly,
                    IsDigitized = model.IsDigitized,
                    IsImported = model.IsImported,
                    TypeCode = model.TypeCode!.Value,
                    StatusCode = model.StatusCode!,
                    ContentType = "application/pdf",
                    FileSize = pdfFileInfo.Size,
                    FileType = pdfFileInfo.Type,
                    Name = pdfFileInfo.SystemName,
                    SourceName = pdfSourceName,
                    UncPath = pdfUncPath,
                };

                _context.DigitalObjectDrafts.Add(pdfDigitalObjectDraft);
                await _context.SaveAsync("Digital object draft created");

                pdfSystemIdentifier = pdfDigitalObjectDraft.SystemIdentifier;
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error creating derivative PDF digital object");
            }

            return pdfSystemIdentifier;
        }

        public async Task<OperationResultModel> UploadFileAsync(string fileName, Stream data, int queueItemId, long offset)
        {
            return await ServiceAction(async () =>
            {
                OperationResult operationResult = await _fileService.UploadFileAsync(fileName, data, offset);
                if (offset == 0 && operationResult.Data != null)
                {
                    string uncFileName = (string)operationResult.Data;
                    FileUploadQueue queueItem = await GetQueueItem(queueItemId);
                    queueItem.UncFileName = uncFileName;
                    await _context.SaveAsync($"Updated uncFileName to queue id {queueItemId}.");
                }

                return OperationResultModel.SuccessResult();
            });
        }

        public async Task<ChecksumsVerifyResultModel> VerifyChecksums(ProcessKind? processKind)
        {
            try
            {
                List<ChecksumVerifyProcessModel> processes = new();

                if (!processKind.HasValue || processKind == ProcessKind.Kmf)
                {
                    processes.Add(await VerifyChecksumsForProcess(ProcessKind.Kmf));
                }
                if (!processKind.HasValue || processKind == ProcessKind.Fund)
                {
                    processes.Add(await VerifyChecksumsForProcess(ProcessKind.Fund));
                }

                return new ChecksumsVerifyResultModel
                {
                    Processes = processes.ToArray()
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task<ChecksumVerifyProcessModel> VerifyChecksumsForProcess(ProcessKind processKind)
        {
            ChecksumVerifyItemModel[] itemsToVerify =
                processKind == ProcessKind.Kmf ? await (
                from f in _context.Films
                join d in _context.FilmPackageDocuments
                on f.PackageBid equals d.PackageId
                where !f.Deleted && !f.HasExternalSource && !d.Deleted && d.FilePath != null
                select new ChecksumVerifyItemModel
                {
                    DocumentIdentifier = f.SystemIdentifier.ToString(),
                    Identifier = d.Id.ToString(),
                    UncFileName = d.FilePath!,
                    FileName = d.FileName!,
                    IsMaster = true,
                    ChecksumDb = d.HashCode,
                }).ToArrayAsync()
                :
                processKind == ProcessKind.Fund ? await (
                     from f in _context.DigitalObjects
                     where !f.Deleted && !f.HasExternalSource
                     select new ChecksumVerifyItemModel
                     {
                         DocumentIdentifier = $"A:{f.ArchivalEntitySystemIdentifier} Ф:{f.FundSystemIdentifier} Д:{f.DocumentSystemIdentifier}",
                         Identifier = $"{f.SystemIdentifier}",
                         UncFileName = f.UncPath,
                         FileName = f.Name,
                         IsMaster = f.TypeCode == (int)DigitalObjectType.MasterFile,
                         ChecksumDb = f.HashCode,
                     }).ToArrayAsync()
                :
                throw new Exception($"VerifyChecksumsForProcess: process not supported: {processKind}");

            ChecksumVerifyFileModel[] workDbFiles = itemsToVerify.
                Select(f => new ChecksumVerifyFileModel(FileStreamLocation.File, f.Identifier, _fileService.GetMasterDbUncFileName(f.UncFileName), f.ChecksumDb)).ToArray();
            ChecksumVerifyFileModel[] masterDbFiles = itemsToVerify.Where(f => f.IsMaster).
                Select(f => new ChecksumVerifyFileModel(FileStreamLocation.Master, f.Identifier, _fileService.GetMasterDbUncFileName(f.UncFileName), f.ChecksumDb)).ToArray();

            await VerifyFiles(FileStreamLocation.File, workDbFiles);
            await VerifyFiles(FileStreamLocation.Master, masterDbFiles);

            ChecksumVerifyFileModel[] results = workDbFiles.Concat(masterDbFiles).ToArray();
            foreach (ChecksumVerifyItemModel item in itemsToVerify)
            {
                IEnumerable<ChecksumVerifyFileModel> resultsForItem = results.Where(r => r.Identifier == item.Identifier).AsEnumerable();
                item.Success = resultsForItem.Any(r => r.Success == false) ? false :
                    resultsForItem.Any(r => !r.Success.HasValue) ? null
                    : true;
                item.Message =
                    item.Success == true ? null :
                    string.Join("; ", resultsForItem);
            }


            return new ChecksumVerifyProcessModel
            {
                ProcessKind = processKind,
                ProcessName = processKind == ProcessKind.Kmf ? "КМФ" : "Фонд",
                Items = itemsToVerify,
                Summary = $"Общо файлове: {itemsToVerify.Length}, проверени: {itemsToVerify.Count(f => f.Success.HasValue)}, грешки: {itemsToVerify.Count(f => f.Success == false)}",
            };
        }

        private async System.Threading.Tasks.Task VerifyFiles(FileStreamLocation location, ChecksumVerifyFileModel[] files)
        {
            if (files.Any())
            {
                await ExecuteFileAction(location, async () =>
                {
                    foreach (ChecksumVerifyFileModel file in files)
                    {
                        try
                        {
                            if (file.ChecksumDb != null)
                            {
                                string checksum = await FileUtils.ChecksumUtil.Calculate(file.UncFileName);
                                file.ChecksumCalc = checksum;
                                file.Success = file.ChecksumCalc == file.ChecksumDb;
                            }
                        }
                        catch (Exception e)
                        {
                            file.Success = false;
                            file.Message = e.Message;
                        }
                    }
                    return OperationResult.Success;
                });
            }
        }


        private string GetDbFilenameFromUploadedFileName(string clientFileName, string? currentDbFileName)
        {
            string clientExtension = Path.GetExtension(clientFileName).ToLower();

            // ако потребителят коригира файла - избере нов, различен тип от стария, трябва да сменим и името на файла в базата - за да е с вярното разширение
            if (string.IsNullOrEmpty(currentDbFileName))
            {
                return $"{Guid.NewGuid()}{clientExtension}";
            }
            else
            {
                string currentExtension = Path.GetExtension(currentDbFileName).ToLower();

                if (clientExtension != currentExtension)
                {
                    // reuse-вам guid-a - за да може по-лесно? да се намери изоставено парче файл и да се изтрие
                    return $"{Path.GetFileName(currentDbFileName)}{clientExtension}";
                }
                else
                {
                    return currentDbFileName;
                }
            }
        }

        private QueueItemModel LoadFrom(FileUploadQueue entity)
        {
            return new()
            {
                Id = entity.Id,
                CreatedGuid = entity.CreatedGuid,
                FinishedGuid = entity.FinishedGuid,
                DocumentId = entity.DocumentId,
                LocalFileName = entity.LocalFileName,
                Checksum = entity.Checksum,
                ProcessKind = entity.ProcessKindCode.ToEnum<ProcessKind>(),
                FileKind = entity.FileKindCode.ToEnumNullable<FileKind>(),
                Notes = entity.Notes,
                ComputerName = entity.ComputerName,
                Position = entity.Position,
                Size = entity.Size,
                Finished = entity.Finished,
                MasterDocumentId = entity.MasterDocumentId,
                DbFileName = entity.DbFileName,
                AutoGenerateDerivative = entity.AutoGenerateDerivative,

                ChecksumCheckResult = entity.ChecksumCheckResult,
                AntivirusCheckResult = entity.AntivirusCheckResult,
                FileFormatCheckResult = entity.FileFormatCheckResult,
                AntivirusCheckInfo = entity.AntivirusCheckInfo,
                FileInfo = entity.FileInfo,
                ErrorMessage = entity.ErrorMessage,
            };
        }

        private void SaveTo(QueueItemModel model, FileUploadQueue entity)
        {
            entity.CreatedGuid = model.CreatedGuid;
            entity.FinishedGuid = model.FinishedGuid;
            entity.DocumentId = model.DocumentId;
            entity.LocalFileName = model.LocalFileName ?? throw new ArgumentNullException(nameof(model.LocalFileName));
            entity.Checksum = model.Checksum ?? throw new ArgumentNullException(nameof(model.Checksum));
            entity.FileName = Path.GetFileName(entity.LocalFileName);
            entity.ProcessKindCode = model.ProcessKind.ToString();
            entity.FileKindCode = model.FileKind.ToString();
            entity.Notes = model.Notes;
            entity.ComputerName = model.ComputerName ?? throw new ArgumentNullException(nameof(model.ComputerName));
            entity.UserId = _userId;
            entity.Position = model.Position;
            entity.Size = model.Size;
            entity.Finished = model.Finished;
            entity.MasterDocumentId = model.MasterDocumentId;
            entity.AutoGenerateDerivative = model.AutoGenerateDerivative;

            entity.ChecksumCheckResult = model.ChecksumCheckResult;
            entity.AntivirusCheckResult = model.AntivirusCheckResult;
            entity.AntivirusCheckInfo = model.AntivirusCheckInfo;
            entity.FileFormatCheckResult = model.FileFormatCheckResult;
            entity.FileInfo = model.FileInfo;
            entity.ErrorMessage = model.ErrorMessage;

            entity.DbFileName = model.DbFileName ?? throw new ArgumentNullException(nameof(model.DbFileName));
        }


        private async Task<TResult> ServiceAction<TResult>(Func<Task<TResult>> action, string? message = null)
            where TResult : OperationResultModel, new()
        {
            try
            {
                return await action();
            }
            catch (Exception e)
            {
                return new TResult()
                {
                    Success = false,
                    Message = (string.IsNullOrEmpty(message) ? $"{message}: " : "") + GetExceptionMessage(e)
                };
            }
        }

        private async System.Threading.Tasks.Task ExecuteFileAction(FileStreamLocation location, Func<Task<OperationResult>> action)
        {
            OperationResult result = await _fileService.ExecuteFileAction(location, action);
            if (!result.Succeeded)
            {
                throw new Exception(string.Join(Environment.NewLine, result.Errors));
            }
        }

        public async Task<bool> IsFileExtensionValid(string fileName)
        {
            bool result = false;
            if (String.IsNullOrEmpty(fileName))
            {
                return result;
            }

            string extension = Path.GetExtension(fileName).Replace(".", "").ToLower();

            var fileTypes = await _context.Nomenclatures
                .Where(x => x.Parent != null && x.Parent.Code == Shared.NomenclatureCode.FileType)
                .Select(x => x.Text.ToLower().Trim())
                .ToListAsync();

            if (fileTypes != null && fileTypes.Any())
            {
                result = fileTypes.Contains(extension);
            }

            return result;
        }

        #region Db Queries
        private async Task<FileUploadQueue> GetQueueItem(int id)
        {
            return await _context.FileUploadQueues.Where(q => q.Id == id).FirstOrDefaultAsync() ??
                throw new Exception($"Не е намерен запис в опашката с Id {id}");
        }

        private IQueryable<VDocument> GetFundViewQuery(Guid? identifier = null)
        {
            IQueryable<VDocument> query = _context.VDocuments.Where(d => !d.Deleted && !(d.HasExternalSource == true));
            if (identifier != null)
            {
                query = query.Where(d => d.SystemIdentifier == identifier);
            }
            return query;
        }
        private IQueryable<VDigitalObject> GetFundFilesViewQuery()
        {
            return _context.VDigitalObjects.Where(f => !f.Deleted && !(f.HasExternalSource == true));
        }

        private IQueryable<VFilm> GetKmfViewQuery(Guid? identifier = null)
        {
            IQueryable<VFilm> query = _context.VFilms.Where(f => !f.Deleted && !(f.HasExternalSource == true));
            if (identifier.HasValue)
            {
                query = query.Where(f => f.SystemIdentifier == identifier);
            }
            return query;
        }
        private IQueryable<VFilmDocument> GetKmfFilesViewQuery()
        {
            return _context.VFilmDocuments.Where(f => !f.DocumentIsDeleted && !f.PackageIsDeleted && !f.FilmIsDeleted &&
                !(f.HasExternalSource == true) && f.PackageType == "B");
        }

        private IQueryable<InventoryDraft> GetRawListViewQuery(Guid? identifier = null)
        {
            IQueryable<InventoryDraft> query = _context.InventoryDrafts.Where(d => 
                d.IsCurrent 
                && !d.Deleted
                && d.PackageBid.HasValue
                && d.DescriptionLevelCode == "6" // Груб опис; TODO: няма ли някакъв enum за тая стойност??
                && d.StatusCode == "1" // Нов; TODO: няма ли някакъв enum за тая стойност??
                && d.AvailabilityStatusCode == 1 // Зачисляване; TODO: няма ли някакъв enum за тая стойност??
            );

            if (identifier.HasValue)
            {
                query = query.Where(d => d.SystemIdentifier == identifier);
            }
            return query;
        }

        private async Task<bool> FileNameExistsInRawList(Guid rawListId, string fileName)
        {
            return await _context.PackageDocuments.AnyAsync(p => !p.Deleted && p.FileName == fileName && p.Package.InventoryDraftPackageBs.Any(d => d.SystemIdentifier == rawListId));
        }
        #endregion



        public static string GetExceptionMessage(Exception ex)
        {
            return ex.InnerException != null ? ex.Message + Environment.NewLine + GetExceptionMessage(ex.InnerException) : ex.Message;
        }

    }
}
