using DAA.Data;
using DAA.Extensions.Exceptions;
using DAA.FileUtils;
using DAA.Models.ArchiveEntities;
using DAA.Models.DigitalObjects;
using DAA.Models.Documents;
using DAA.Models.File;
using DAA.Models.FileUploadApp;
using DAA.Services.Files;
using DAA.Services.Interfaces;
using DAA.Services.Nomenclatures;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System.Text;

namespace DAA.Services
{
    public class UtilityService : BaseService, IUtilityService
    {
        private readonly IUserInfo _userInfo;
        private readonly INomenclatureService _nomenclatureService;
        private readonly IFileService _fileService;

        public UtilityService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            ILogger<IUtilityService> logger,
            IUserInfo userInfo,
            INomenclatureService nomenclatureService,
            IFileService fileService)
            : base(context, localizer, logger)
        {
            _userInfo = userInfo;
            _nomenclatureService = nomenclatureService;
            _fileService = fileService;
        }

        public OperationResult GetUsedFileFormats(List<string> formats)
        {
            var fileTypes = _nomenclatureService.GetNomenclatureValues(Shared.NomenclatureCode.FileType);
            List<Nomenclature> usedFiles = new List<Nomenclature>();

            foreach (var format in formats)
            {
                var usedFile = fileTypes.Where(nv => nv.Text.ToLower() == format.ToLower()).FirstOrDefault();
                if (usedFile == null)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_MissingFileType", format).ToString());
                }

                usedFiles.Add(usedFile);
            }

            return OperationResult.Succeed(usedFiles);
        }


        public async Task<Guid> CreateDODraftFromPackageDocumentInternalAsync(PackageDocument packageDocument, DigitalObjectDraftModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            if (packageDocument == null)
            {
                throw new ArgumentNullException(nameof(packageDocument));
            }

            if (!model.DocumentDraftId.HasValue)
            {
                // TODO no need to use documentService just to read several fields!
                //var documentDraft = await _documentService.GetCurrentDraftAsync(model.DocumentSystemIdentifier!.Value);
                var documentDraft = await _context.VDocuments
                    .Where(x => x.SystemIdentifier == model.DocumentSystemIdentifier!.Value && x.IsDraft.HasValue && x.IsDraft.Value == true && !x.Deleted)
                    .FirstOrDefaultAsync();
                if (documentDraft != null)
                {
                    model.FundDraftId = documentDraft.FundDraftId;
                    model.InventoryDraftId = documentDraft.InventoryDraftId;
                    model.ArchivalEntityDraftId = documentDraft.ArchivalEntityDraftId;
                    model.DocumentDraftId = documentDraft.Id;
                }
            }
            double? audioVideoFileDuration = null;
            FileStreamLocation location = packageDocument.FileLocation.HasValue ? (FileStreamLocation)packageDocument.FileLocation.Value : FileStreamLocation.Buffer;
            FileModel? packageDocumentFile = await _fileService.GetFileAsync(packageDocument.FilePath!, location);
            if (packageDocumentFile == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), packageDocument.Id.ToString());
            }

            packageDocumentFile.SystemName = $"{Guid.NewGuid().ToString("D")}.{packageDocumentFile.Type}";

            //Create the digital object file
            var digitalObjFileResult = await _fileService.CreateFileAsync(packageDocumentFile, FileStreamLocation.Buffer);
            if (!digitalObjFileResult.Succeeded)
            {
                throw new Exception(digitalObjFileResult.ToString());
            }

            string? uncFilePath = digitalObjFileResult.Data?.ToString();
            //model.SystemIdentifier = Guid.NewGuid();
            string hashCode = ChecksumUtil.Calculate(packageDocumentFile.Content!);

            if (model.TypeCode!.Value == (int)DigitalObjectType.MasterFile)
            {
                //try
                //{
                //    var file = Create(uncFilePath);

                //    audioVideoFileDuration = file.Properties.Duration.TotalSeconds;
                //}
                //catch (CorruptFileException exc)
                //{
                //    _logger.LogInformation($"CorruptFileException occured for file {packageDocumentFile.Name} exception:{exc}");

                //}
                //catch (UnsupportedFormatException exc)
                //{
                //    _logger.LogInformation($"UnsupportedFormatException occured for file {packageDocumentFile.Name} exception: {exc}");
                //}
                audioVideoFileDuration = await _fileService.TryGetFileDurationAsync(uncFilePath!, FileStreamLocation.Buffer);
            }

            var digitalObjectDraft = new DigitalObjectDraft()
            {
                IsCurrent = true,
                ReadOnly = false,
                HasExternalSource = false,
                //SystemIdentifier = model.SystemIdentifier!.Value,
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
                TypeCode = model.TypeCode!.Value,
                StatusCode = model.StatusCode!,
                ParentSystemIdentifier = model.ParentSystemIdentifier,
                ContentType = model.ContentType,
                FileType = packageDocumentFile.Type,
                FileSize = packageDocumentFile.Size,
                Name = packageDocumentFile.SystemName,
                SourceName = model.SourceName!,
                UncPath = uncFilePath!,
                HashCode = hashCode,
                PackageDocumentId = model.PackageDocumentId,
                IsImported = model.IsImported,
                IsDigitized = model.IsDigitized,

                WorkflowId = model.WorkflowId,
                WorkflowTypeCode = model.WorkflowTypeCode,
                WorkflowStepId = model.WorkflowStepId,
                WorkflowStepTypeCode = model.WorkflowStepTypeCode
            };


            _context.DigitalObjectDrafts.Add(digitalObjectDraft);
            await _context.SaveAsync("Digital object draft created");

            //Try to create derivative PDF file
            //If there is exception the operation should continue
            if (model.TypeCode == (int)DigitalObjectType.MasterFile)
            {
                try
                {
                    var derivativeDigitalObjectDraft = new DigitalObjectDraftModel()
                    {
                        ArchiveId = digitalObjectDraft.ArchiveId,
                        FundDraftId = digitalObjectDraft.FundDraftId,
                        FundSystemIdentifier = digitalObjectDraft.FundSystemIdentifier,
                        InventoryDraftId = digitalObjectDraft.InventoryDraftId,
                        InventorySystemIdentifier = digitalObjectDraft.InventorySystemIdentifier,
                        ArchivalEntityDraftId = digitalObjectDraft.ArchivalEntityDraftId,
                        ArchivalEntitySystemIdentifier = digitalObjectDraft.ArchivalEntitySystemIdentifier,
                        DocumentDraftId = digitalObjectDraft.DocumentDraftId,
                        DocumentSystemIdentifier = digitalObjectDraft.DocumentSystemIdentifier,
                        ParentId = digitalObjectDraft.Id,
                        ParentSystemIdentifier = digitalObjectDraft.SystemIdentifier,
                        SourceName = digitalObjectDraft.SourceName,
                        IsCurrent = true,
                        ReadOnly = false,
                        IsDigitized = digitalObjectDraft.IsDigitized,
                        IsImported = digitalObjectDraft.IsImported,
                        TypeCode = (int)DigitalObjectType.DerivativeFile,
                        StatusCode = digitalObjectDraft.StatusCode,
                    };

                    await CreatePdfDigitalObjectDraftInternalAsync(packageDocumentFile, FileStreamLocation.Buffer, derivativeDigitalObjectDraft);
                }
                catch(Exception exc)
                {
                    _logger.LogError(exc, "Error creating derivative PDF digital object");
                }
            }

            return digitalObjectDraft.SystemIdentifier;
        }

        private async Task<Guid?> CreatePdfDigitalObjectDraftInternalAsync(FileModel sourceFile, FileStreamLocation targetLocation, DigitalObjectDraftModel model)
        {
            var pdfConversionResult = await _fileService.TryCreateFileAsPdfAsync(sourceFile, targetLocation);
            if (!pdfConversionResult.Succeeded)
            {
                throw new Exception(pdfConversionResult.ToString());
            }
            
            var pdfUncPath = pdfConversionResult.Data?.ToString();
            if (string.IsNullOrWhiteSpace(pdfUncPath))
            {
                return null;
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

            DigitalObjectDraft digitalObjectDraft = new DigitalObjectDraft()
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

            _context.DigitalObjectDrafts.Add(digitalObjectDraft);
            await _context.SaveAsync("Digital object draft created");

            return digitalObjectDraft.SystemIdentifier;
        }

        public async System.Threading.Tasks.Task DeleteDODraftInternalAsync(int id)
        {
            var digitalObjectDraft = await _context.DigitalObjectDrafts.FindAsync(id);
            if (digitalObjectDraft == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), id.ToString());
            }
            if (!digitalObjectDraft.IsCurrent)
            {
                throw new ItemDraftNotCurrentException(_localizer.GetString("Error_DraftNotCurrent").ToString(), digitalObjectDraft.Id.ToString());
            }

            // Delete file
            OperationResult result = _fileService.DeleteFile(digitalObjectDraft.UncPath, FileStreamLocation.Buffer);
            if (!result.Succeeded)
            {
                throw new Exception(String.Join("; ", result.Errors));
            }
            //todo if fileType = 2 cha in delete ;
            digitalObjectDraft.IsCurrent = false;
            digitalObjectDraft.ReadOnly = true;
            digitalObjectDraft.Deleted = true;
            digitalObjectDraft.DeletedOn = DateTime.UtcNow;
            digitalObjectDraft.DeletedBy = _userInfo.CurrentUserId;

            _context.Update(digitalObjectDraft);

            //Ако се изтрие мастера автоматично да се изтр и производните
            //if (digitalObjectDraft.TypeCode == (int)DigitalObjectType.MasterFile)
            //{
            //    var derivativeFiles = _context.DigitalObjectDrafts.Where(d => d.ParentSystemIdentifier == digitalObjectDraft.SystemIdentifier && !d.Deleted);

            //    foreach (var item in derivativeFiles)
            //    {
            //        item.IsCurrent = false;
            //        item.ReadOnly = true;
            //        item.Deleted = true;
            //        item.DeletedOn = DateTime.UtcNow;
            //        item.DeletedBy = _userInfo.CurrentUserId;

            //        _context.Update(item);
            //    }
            //}

            await _context.SaveAsync("Digital object draft deleted");
        }



        public async Task<Guid> CreateDocDraftInternalAsync(DocumentDraftModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            //If there is new archival entity draft on edit
            if (!model.ArchivalEntityDraftId.HasValue)
            {
                // TODO no need to use documentService just to read several fields!
                //var archivalEntityDraft = await _archivalEntityService.GetCurrentDraftAsync(model.ArchivalEntitySystemIdentifier!.Value);
                var archivalEntityDraft = await _context.VArchivalEntities
                    .Where(x => x.SystemIdentifier == model.ArchivalEntitySystemIdentifier!.Value && x.IsDraft.HasValue && x.IsDraft.Value == true && !x.Deleted)
                    .FirstOrDefaultAsync();
                if (archivalEntityDraft != null)
                {
                    model.FundDraftId = archivalEntityDraft.FundDraftId;
                    model.InventoryDraftId = archivalEntityDraft.InventoryDraftId;
                    model.ArchivalEntityDraftId = archivalEntityDraft.Id;
                }
            }

            if (!model.SystemIdentifier.HasValue)
            {
                model.SystemIdentifier = Guid.NewGuid();
            }
            else
            {
                var currentDraft =
                    await _context.DocumentDrafts
                    .Where(d => d.SystemIdentifier == model.SystemIdentifier && d.IsCurrent)
                    .SingleOrDefaultAsync();
                if (currentDraft != null)
                {
                    currentDraft.IsCurrent = false;
                    currentDraft.ReadOnly = true;
                    _context.Update(currentDraft);
                }
            }

            var documentDraft = new DocumentDraft()
            {
                IsCurrent = true,
                ReadOnly = false,
                SystemIdentifier = model.SystemIdentifier!.Value,
                WorkflowId = model.WorkflowId,
                WorkflowStepId = model.WorkflowStepId,
                WorkflowStepTypeCode = model.WorkflowStepTypeCode,
                WorkflowTypeCode = model.WorkflowTypeCode,
                ArchiveId = model.ArchiveId!.Value,
                FundDraftId = model.FundDraftId,
                FundSystemIdentifier = model.FundSystemIdentifier!.Value,
                InventoryDraftId = model.InventoryDraftId,
                InventorySystemIdentifier = model.InventorySystemIdentifier!.Value,
                ArchivalEntityDraftId = model.ArchivalEntityDraftId,
                ArchivalEntitySystemIdentifier = model.ArchivalEntitySystemIdentifier!.Value,
                DescriptionLevelCode = model.DescriptionLevelCode,
                StatusCode = model.StatusCode,
                AvailabilityStatusCode = model.AvailabilityStatusCode,
                Number = model.Number,
                Title = model.Title,
                Author = model.Author,
                DigitalDevice = model.DigitalDevice,
                Duration = model.Duration,
                StartSheetNumber = model.StartSheetNumber,
                EndSheetNumber = model.EndSheetNumber,
                HasNoChronologicalScope = model.HasNoChronologicalScope,
                Transcription = model.Transcription,
                Location = model.Location,
                Bytes = model.Bytes,
                SheetCount = model.SheetCount,
                OtherMetrics = model.OtherMetrics,
                SizeCm = model.SizeCm,
                Scaling = model.Scaling,
                Description = model.Description,
                DocumentsAccessDescription = model.DocumentsAccessDescription,
                Features = model.Features,
                MicrofilmedCopyCount = model.MicrofilmedCopyCount,
                DigitizedCopyCount = model.DigitizedCopyCount,
                PaperCopyCount = model.PaperCopyCount,
                NegativeFrameCount = model.NegativeFrameCount,
                PositiveFrameCount = model.PositiveFrameCount,
                OtherCopyCount = model.OtherCopyCount,
                Notes = model.Notes,
                ApproxmateChronologicalScope = model.ApproximateChronologicalScope,
                StartDateYear = model.StartDateYear,
                StartDateMonth = model.StartDateMonth,
                StartDateDay = model.StartDateDay,
                EndDateYear = model.EndDateYear,
                EndDateMonth = model.EndDateMonth,
                EndDateDay = model.EndDateDay,
                HasExternalSource = model.HasExternalSource,
                ExternalIdentifier = model.ExternalIdentifier,
                IsImported = model.IsImported,
                DescriptionAuthor = model.DescriptionAuthor,

                Cypher = model.Cypher,
                TextDocsCount = model.TextDocsCount,
                GraphicalDocsCount = model.GraphicalDocsCount,
                Phase = model.Phase,
                Part = model.Part,
                Stage = model.Stage,
                OtherLanguage = model.OtherLanguage,
            };

            if (!model.AvailabilityStatusCode.HasValue)
            {
                documentDraft.AvailabilityStatusCode = (int)Shared.AvailabilityStatus.Enrollment;
            }

            if (model.HasExternalSource.HasValue && model.HasExternalSource.Value)
                documentDraft.ExternalSourceUpdatedOn = DateTime.UtcNow;

            _context.DocumentDrafts.Add(documentDraft);
            await _context.SaveAsync("Document draft created");

            if (model.OriginalityCodes?.Count() > 0)
            {
                var originalityValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.OriginalityCodes, null, Shared.NomenclatureCode.Originality,
                    documentDraft.Id, BusinessObjectType.Document, true);

                if (originalityValues != null)
                {
                    _context.NomenclatureValues.AddRange(originalityValues!);
                }
            }
            if (model.CreationMethodCodes?.Count() > 0)
            {
                var creationMethodValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.CreationMethodCodes, null, Shared.NomenclatureCode.CreationMethod,
                    documentDraft.Id, BusinessObjectType.Document, true);

                if (creationMethodValues != null)
                {
                    _context.NomenclatureValues.AddRange(creationMethodValues!);
                }
            }
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, null, Shared.NomenclatureCode.Language,
                    documentDraft.Id, BusinessObjectType.Document, true);

                if (languageValues != null)
                {
                    _context.NomenclatureValues.AddRange(languageValues!);
                }
            }
            if (model.FileTypeCodes?.Count() > 0)
            {
                var fileTypeValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.FileTypeCodes, null, Shared.NomenclatureCode.FileType,
                    documentDraft.Id, BusinessObjectType.Document, true);

                if (fileTypeValues != null)
                {
                    _context.NomenclatureValues.AddRange(fileTypeValues!);
                }
            }
            await _context.SaveAsync("Document draft created");

            return documentDraft.SystemIdentifier;
        }

        public async System.Threading.Tasks.Task DeleteDocDraftInternalAsync(int id)
        {
            var documentDraft = await _context.DocumentDrafts.FindAsync(id);
            if (documentDraft == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), id.ToString());
            }
            if (!documentDraft.IsCurrent)
            {
                throw new ItemDraftNotCurrentException(_localizer.GetString("Error_DraftNotCurrent").ToString(), id.ToString());
            }

            documentDraft.IsCurrent = false;
            documentDraft.ReadOnly = true;
            documentDraft.Deleted = true;
            documentDraft.DeletedOn = DateTime.UtcNow;
            documentDraft.DeletedBy = _userInfo.CurrentUserId;
            _context.Update(documentDraft);

            var draftNomValues = _nomenclatureService.GetEntityNomenclatureValues(documentDraft.Id, BusinessObjectType.Document, true, null);
            if (draftNomValues != null && draftNomValues.Count() > 0)
            {
                draftNomValues.ToList().ForEach(nv =>
                {
                    nv.Deleted = true;
                    nv.DeletedBy = _userInfo.CurrentUserId;
                    nv.DeletedOn = DateTime.UtcNow;
                });

                _context.NomenclatureValues.UpdateRange(draftNomValues);
            }

            await _context.SaveAsync("Document draft deleted");
        }



        public async Task<Guid> CreateAEDraftInternalAsync(ArchivalEntityDraftModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            //If there is new inventory draft on edit
            if (!model.InventoryDraftId.HasValue)
            {
                // TODO no need to use documentService just to read several fields!
                //var inventoryDraft = await _inventoryService.GetCurrentDraftAsync(model.InventorySystemIdentifier!.Value);
                var inventoryDraft = await _context.VInventories
                    .Where(x => x.SystemIdentifier == model.InventorySystemIdentifier!.Value && x.IsDraft.HasValue && x.IsDraft.Value == true && !x.Deleted)
                    .FirstOrDefaultAsync();
                if (inventoryDraft != null)
                {
                    model.FundDraftId = inventoryDraft.FundDraftId;
                    model.InventoryDraftId = inventoryDraft.Id;
                }
            }

            if (!model.SystemIdentifier.HasValue)
            {
                model.SystemIdentifier = Guid.NewGuid();
            }
            else
            {
                var currentDraft =
                    await _context.ArchivalEntityDrafts
                    .Where(inv => inv.SystemIdentifier == model.SystemIdentifier && inv.IsCurrent)
                    .SingleOrDefaultAsync();
                if (currentDraft != null)
                {
                    currentDraft.IsCurrent = false;
                    currentDraft.ReadOnly = true;
                    _context.Update(currentDraft);
                }
            }

            var archivalEntityDraft = new ArchivalEntityDraft()
            {
                IsCurrent = true,
                ReadOnly = false,
                SystemIdentifier = model.SystemIdentifier!.Value,
                ArchiveId = model.ArchiveId!.Value,
                FundDraftId = model.FundDraftId,
                FundSystemIdentifier = model.FundSystemIdentifier!.Value,
                InventoryDraftId = model.InventoryDraftId,
                InventorySystemIdentifier = model.InventorySystemIdentifier!.Value,
                Number = model.Number,
                NumberNumeric = model.NumberNumeric,
                DescriptionLevelCode = model.DescriptionLevelCode,
                Title = model.Title,
                ApproxmateChronologicalScope = model.ApproximateChronologicalScope,
                Location = model.Location,
                Bytes = model.Bytes,
                SheetCount = model.SheetCount,
                TapeCount = model.TapeCount,
                MicrofilmCount = model.MicrofilmCount,
                FrameCount = model.FrameCount,
                VideoTapeCount = model.VideoTapeCount,
                DigitalDeviceCount = model.DigitalDeviceCount,
                OtherMetrics = model.OtherMetrics,
                SizeCm = model.SizeCm,
                Scaling = model.Scaling,
                Description = model.Description,
                DocumentsAccessDescription = model.DocumentsAccessDescription,
                Features = model.Features,
                Condition = model.Condition,
                MicrofilmedCopyCount = model.MicrofilmedCopyCount,
                DigitizedCopyCount = model.DigitizedCopyCount,
                PaperCopyCount = model.PaperCopyCount,
                NegativeFrameCount = model.NegativeFrameCount,
                PositiveFrameCount = model.PositiveFrameCount,
                OtherCopyCount = model.OtherCopyCount,
                Notes = model.Notes,
                EnrolledLinearMeters = model.EnrolledLinearMeters,
                EnrolledDocumentCount = model.EnrolledDocumentCount,
                DeductedDocumentCount = model.DeductedDocumentCount,
                DeductedLinearMeters = model.DeductedLinearMeters,
                DeductedBytes = model.DeductedBytes,
                StartDateYear = model.StartDateYear,
                StartDateMonth = model.StartDateMonth,
                StartDateDay = model.StartDateDay,
                EndDateYear = model.EndDateYear,
                EndDateMonth = model.EndDateMonth,
                EndDateDay = model.EndDateDay,
                StatusCode = model.StatusCode,
                AvailabilityStatusCode = model.AvailabilityStatusCode,
                HasExternalSource = model.HasExternalSource,
                ExternalIdentifier = model.ExternalIdentifier,
                IsImported = model.IsImported,
                NumberArray = model.NumberArray,
                DescriptionAuthor = model.DescriptionAuthor,
                Author = model.Author,

                Cypher = model.Cypher,
                TextDocsCount = model.TextDocsCount,
                GraphicalDocsCount = model.GraphicalDocsCount,
                Phase = model.Phase,
                Part = model.Part,
                Stage = model.Stage,
                OtherLanguage = model.OtherLanguage,
                ClassificationSchemeIndex = model.ClassificationSchemeIndex,
            };

            if (!model.AvailabilityStatusCode.HasValue)
            {
                archivalEntityDraft.AvailabilityStatusCode = (int)Shared.AvailabilityStatus.Enrollment;
            }

            if (model.HasExternalSource)
                archivalEntityDraft.ExternalSourceUpdatedOn = DateTime.UtcNow;

            _context.ArchivalEntityDrafts.Add(archivalEntityDraft);
            await _context.SaveAsync("Archival entity draft created");

            if (model.OriginalityCodes?.Count() > 0)
            {
                var originalityValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.OriginalityCodes, null, Shared.NomenclatureCode.Originality,
                    archivalEntityDraft.Id, BusinessObjectType.ArchivalEntity, true);

                if (originalityValues != null)
                {
                    _context.NomenclatureValues.AddRange(originalityValues!);
                }
            }
            if (model.CreationMethodCodes?.Count() > 0)
            {
                var creationMethodValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.CreationMethodCodes, null, Shared.NomenclatureCode.CreationMethod,
                    archivalEntityDraft.Id, BusinessObjectType.ArchivalEntity, true);

                if (creationMethodValues != null)
                {
                    _context.NomenclatureValues.AddRange(creationMethodValues!);
                }
            }
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValues = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, null, Shared.NomenclatureCode.Language,
                    archivalEntityDraft.Id, BusinessObjectType.ArchivalEntity, true);

                if (languageValues != null)
                {
                    _context.NomenclatureValues.AddRange(languageValues!);
                }
            }
            await _context.SaveAsync("Archival entity draft created");

            return archivalEntityDraft.SystemIdentifier;
        }

        public async System.Threading.Tasks.Task DeleteAEDraftInternalAsync(int id)
        {
            var archivalEntityDraft = await _context.ArchivalEntityDrafts.FindAsync(id);
            if (archivalEntityDraft == null)
            {
                throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), id.ToString());
            }
            if (!archivalEntityDraft.IsCurrent)
            {
                throw new ItemDraftNotCurrentException(_localizer.GetString("Error_DraftNotCurrent").ToString(), id.ToString());
            }

            archivalEntityDraft.IsCurrent = false;
            archivalEntityDraft.ReadOnly = true;
            archivalEntityDraft.Deleted = true;
            archivalEntityDraft.DeletedOn = DateTime.UtcNow;
            archivalEntityDraft.DeletedBy = _userInfo.CurrentUserId;

            _context.Update(archivalEntityDraft);

            var draftNomValues = _nomenclatureService.GetEntityNomenclatureValues(archivalEntityDraft.Id, BusinessObjectType.ArchivalEntity, true, null);
            if (draftNomValues != null && draftNomValues.Count() > 0)
            {
                draftNomValues.ToList().ForEach(nv =>
                {
                    nv.Deleted = true;
                    nv.DeletedBy = _userInfo.CurrentUserId;
                    nv.DeletedOn = DateTime.UtcNow;
                });

                _context.NomenclatureValues.UpdateRange(draftNomValues);
            }

            await _context.SaveAsync("Archival entity draft deleted");
        }


        public async System.Threading.Tasks.Task DeletePackageDocument(PackageDocument doc)
        {
            // Delete file
            OperationResult result = _fileService.DeleteFile(doc.FilePath!, (FileStreamLocation)doc.FileLocation!);
            if (!result.Succeeded)
            {
                throw new Exception(result.ToString());
            }

            doc.Deleted = true;
            doc.DeletedBy = _userInfo.CurrentUserId;
            doc.DeletedOn = DateTime.UtcNow;

            _context.Update(doc);

            await _context.SaveAsync("Package document deleted");
        }



        public async Task<OperationResult> DeductRedirectedData(Guid? fundSystemIdentifier, Guid? inventorySystemIdentifier)
        {
            try
            {
                Guid identifier = Guid.Empty;

                if (fundSystemIdentifier != null && fundSystemIdentifier != Guid.Empty)
                {
                    identifier = fundSystemIdentifier.Value;
                    var fund = _context.FundDrafts
                      .Where(d => d.SystemIdentifier == fundSystemIdentifier)
                      .FirstOrDefault();

                    if (fund != null)
                    {
                        fund!.StatusCode = Shared.Status.Deducted;

                        _context.FundDrafts.Update(fund);

                        await _context.SaveAsync($"Fund draft id {fund.Id} changed status");

                        await DeductInventoryDrafts(fund.SystemIdentifier);
                    }
                }
                else if (inventorySystemIdentifier != null && inventorySystemIdentifier != Guid.Empty)
                {
                    identifier = inventorySystemIdentifier.Value;
                    var inventory = _context.InventoryDrafts
                      .Where(d => d.SystemIdentifier == inventorySystemIdentifier)
                      .FirstOrDefault();

                    if (inventory != null)
                    {
                        inventory!.StatusCode = Shared.Status.Deducted;
                        inventory.AvailabilityStatusCode = (int)Shared.AvailabilityStatus.DisposalDeduction;
                        // detach package B files from inventory, they are moved to the new redirect application
                        inventory.PackageBid = null;

                        _context.InventoryDrafts.Update(inventory);

                        await _context.SaveAsync($"Inventory draft id {inventory.Id} changed status");

                        await DeductArchivalEntityDrafts(inventory.SystemIdentifier);
                    }
                }

                return OperationResult.Succeed(identifier);
            }
            catch (Exception ex)
            {
                return OperationResult.Failed(ex.ToString());
            }
        }

        private async Task<OperationResult> DeductInventoryDrafts(Guid fundSys)
        {
            var inventories = _context.InventoryDrafts
                .Where(i => i.FundSystemIdentifier == fundSys);

            foreach (var inv in inventories)
            {
                inv.StatusCode = Shared.Status.Deducted;

                _context.InventoryDrafts.Update(inv);
                await _context.SaveAsync($"Inventory draft id {inv.Id} changed status");

                await DeductArchivalEntityDrafts(inv.SystemIdentifier);
            }

            return OperationResult.Succeed(inventories);
        }

        private async Task<OperationResult> DeductArchivalEntityDrafts(Guid inventorySys)
        {
            var archivalEntities = _context.ArchivalEntityDrafts
                .Where(a => a.InventorySystemIdentifier == inventorySys);

            foreach (var ae in archivalEntities)
            {
                ae.StatusCode = Shared.Status.Deducted;

                _context.ArchivalEntityDrafts.Update(ae);
                await _context.SaveAsync($"ArchivalEntity draft id {ae.Id} changed status");

                await DeductDocumentDrafts(ae.SystemIdentifier);
            }

            return OperationResult.Succeed(archivalEntities);
        }

        private async Task<OperationResult> DeductDocumentDrafts(Guid aeSys)
        {
            var documents = _context.DocumentDrafts
                .Where(i => i.ArchivalEntitySystemIdentifier == aeSys);

            foreach (var docs in documents)
            {
                docs.StatusCode = Shared.Status.Deducted;

                _context.DocumentDrafts.Update(docs);
                await _context.SaveAsync($"Document draft id {docs.Id} changed status");

                await DeductDigitalObjectDrafts(docs.SystemIdentifier);
            }

            return OperationResult.Succeed(documents);
        }

        private async Task<OperationResult> DeductDigitalObjectDrafts(Guid docSys)
        {
            var digitalObjects = _context.DigitalObjectDrafts
                .Where(i => i.DocumentSystemIdentifier == docSys);

            foreach (var digitObj in digitalObjects)
            {
                digitObj.StatusCode = Shared.Status.Deducted;
                digitObj.AvailabilityStatusCode = (int)Shared.AvailabilityStatus.DisposalDeduction;

                _context.DigitalObjectDrafts.Update(digitObj);
                await _context.SaveAsync($"DigitalObjectDraft id {digitObj.Id} changed status");
            }

            return OperationResult.Succeed(digitalObjects);
        }




        public async Task<OperationResult> ModifyDataAccessAsync(Guid? fundSystemIdentifier, Guid? inventorySystemIdentifier, bool suspendAccess)
        {
            try
            {
                List<Inventory> inventories = new List<Inventory>();
                if (fundSystemIdentifier.HasValue && fundSystemIdentifier != Guid.Empty)
                {
                    var fund = await _context.Funds
                                .Where(f => f.SystemIdentifier == fundSystemIdentifier && !f.Deleted)
                                .SingleOrDefaultAsync();

                    if (fund == null)
                    {
                        return OperationResult.Failed($"Fund {fundSystemIdentifier} does not exists");
                    }

                    fund.IsSuspended = suspendAccess;
                    _context.Update(fund);


                    inventories = await _context.Inventories
                    .Where(inv => inv.FundSystemIdentifier == fundSystemIdentifier!.Value && !inv.Deleted)
                    .ToListAsync();

                }
                else if (inventorySystemIdentifier.HasValue && inventorySystemIdentifier != Guid.Empty)
                {
                    inventories = await _context.Inventories
                    .Where(inv => inv.SystemIdentifier == inventorySystemIdentifier && !inv.Deleted)
                    .ToListAsync();
                }

                var inventorySysIds = inventories.Select(x => x.SystemIdentifier).ToList();

                inventories.ForEach(inv => { inv.IsSuspended = suspendAccess; });
                _context.UpdateRange(inventories);

                await _context.ArchivalEntities
                    .Where(ae => inventorySysIds.Contains(ae.InventorySystemIdentifier) && !ae.Deleted)
                    .Select(ae => ae)
                    .ForEachAsync(ae => { ae.IsSuspended = suspendAccess; });

                await _context.Documents
                    .Where(doc => inventorySysIds.Contains(doc.InventorySystemIdentifier) && !doc.Deleted)
                    .Select(doc => doc)
                    .ForEachAsync(doc => { doc.IsSuspended = suspendAccess; });

                await _context.DigitalObjects
                    .Where(dig => inventorySysIds.Contains(dig.InventorySystemIdentifier) && !dig.Deleted)
                    .Select(dig => dig)
                    .ForEachAsync(dig => { dig.IsSuspended = suspendAccess; });

                await _context.SaveAsync("Fund/inventory public access suspended");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }


        public async Task<InventoryDraft> GetProcessInventoryDraftAsync(Guid? fundSystemIdentifier, Guid? inventorySystemIdentifier)
        {
            InventoryDraft invDraft = await _context.InventoryDrafts
                    .Include(x => x.CreatedByNavigation)
                    .Include(x => x.Archive)
                .Where(inv =>
                    ((fundSystemIdentifier.HasValue && fundSystemIdentifier != Guid.Empty && inv.FundSystemIdentifier == fundSystemIdentifier!.Value) ||
                    (inventorySystemIdentifier.HasValue && inventorySystemIdentifier != Guid.Empty && inv.SystemIdentifier == inventorySystemIdentifier)) &&
                    !inv.Deleted && inv.IsCurrent)
                .FirstAsync();

            return invDraft;
        }

        public async Task<Shared.FundType?> GetFundTypeAsync(Guid fundSystemIdentifier)
        {
            var fund = await _context.VFunds
                .Where(f => f.SystemIdentifier == fundSystemIdentifier && !f.Deleted)
                            .SingleOrDefaultAsync();

            Shared.FundType? fundType = fund != null && fund.TypeCode != null ? fund.TypeCode.ToEnumNullable<Shared.FundType>() : null;

            return fundType;
        }

    }
}
