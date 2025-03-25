using DAA.Data;
using DAA.Models.ArchiveEntities;
using DAA.Models.Configuration;
using DAA.Models.DigitalObjects;
using DAA.Models.Documents;
using DAA.Models.File;
using DAA.Models.Import;
using DAA.Services.Interfaces;
using DAA.Shared;
using DAA.Shared.Excel;
using DAA.Shared.Localization;
using DocFlow.Models.File;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using OfficeOpenXml;
using System.Text;
using Task = System.Threading.Tasks.Task;

namespace DAA.Services.Import
{
    public class ImportService : BaseService, IImportService
    {
        private readonly IDropdownService _dropDownService;
        private readonly IModelValidationService _modelValidationService;
        private readonly IUtilityService _utilityService;
        private readonly ImportSettings _importSettings;

        public ImportService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IDropdownService dropDownService,
            IModelValidationService modelValidationService,
            IUtilityService utilityService,
            IOptions<ImportSettings> importSettings,
            ILogger<ImportService> logger)
            : base(context, localizer, logger)
        {
            _dropDownService = dropDownService;
            _modelValidationService = modelValidationService;
            _utilityService = utilityService;
            _importSettings = importSettings.Value;
        }

        public async Task<FileModel> ParseFile(IFormFile file)
        {
            FileModel fileModel = await ParseAttachmentAsync(file);
            return fileModel;
        }

        public async Task<FileDownloadModel> ExportFileTemplateToExcel()
        {
            IList<ExcelDDL> ddlLists = await GetDropDownListsCollection(
                    new ExcelDropDownListType[] {
                        ExcelDropDownListType.Language,
                        ExcelDropDownListType.AcquisitionMethod,
                        ExcelDropDownListType.InventoryNumberArray
                    });

            InventoryImportModel invModel = new InventoryImportModel();
            ArchivalEntityImportModel aeModel = new ArchivalEntityImportModel();
            DocumentImportModel docModel = new DocumentImportModel();
            PackageImportModel packageModel = new PackageImportModel();

            string invSheetName = _importSettings.InventorySheetName ?? "";
            string aeSheetName = _importSettings.ArchivalEntitiesSheetName ?? "";
            string docSheetName = _importSettings.DocumentsSheetName ?? "";
            string packageSheetName = _importSettings.PackageBSheetName ?? "";


            var stream = new MemoryStream();
            using (var package = new ExcelPackage(stream))
            {
                var invWorkSheet = package.Workbook.Worksheets.Add(invSheetName);
                ExcelHelper.AddModelDataToSheet(package.Workbook, invWorkSheet, new List<InventoryImportModel>() { invModel }, ddlLists, false, true);

                var aeWorkSheet = package.Workbook.Worksheets.Add(aeSheetName);
                ExcelHelper.AddModelDataToSheet(package.Workbook, aeWorkSheet, new List<ArchivalEntityImportModel>() { aeModel }, ddlLists, false, true);

                var docWorkSheet = package.Workbook.Worksheets.Add(docSheetName);
                ExcelHelper.AddModelDataToSheet(package.Workbook, docWorkSheet, new List<DocumentImportModel>() { docModel }, ddlLists, false, true);

                var packageWorkSheet = package.Workbook.Worksheets.Add(packageSheetName);
                ExcelHelper.AddModelDataToSheet(package.Workbook, packageWorkSheet, new List<PackageImportModel>() { packageModel }, ddlLists, false, true);

                package.Save();
            }
            stream.Position = 0;

            FileDownloadModel file = new FileDownloadModel()
            {
                Mimetype = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                Filename = "ImportFileTemplate.xlsx",
                Data = Convert.ToBase64String(stream.ToArray())
            };

            return file;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="model">Импортния файл</param>
        /// <param name="inventorySysId">Системен номер на опис, към който се импортират данни</param>
        /// <param name="readPackageSheet">1 - да се изчита и sheet Пакет Б, който съдържа връзката между документи, които ще се импортират и файлове в пакет Б, които вече съществуват към описа - случаят при процес Обработка на необработени</param>
        /// <param name="createEntities">1 - освен, че ще се изчетат данните от файла, ще се създадат реално арихвните единици и документите (и връзката с файлове от пакет Б при включен параметър readPackageSheet; и ще се запишат данните за описа при включен параметър readInventorySheet)</param>
        /// <param name="readInventorySheet">1 - да се изчита и sheet Опис</param>
        /// <returns></returns>
        public async Task<OperationResult> ImportArchivalEntitesFromExcelAsync(
            IFormFile model,
            Guid inventorySysId,
            bool readPackageSheet,
            bool createEntities,
            bool readInventorySheet)
        {
            try
            {
                _logger.LogInformation($"Start importing file {model.FileName} with parameters: inventorySysId=({inventorySysId}); readPackageSheet=({readPackageSheet}); createEntities=({createEntities}); readInventorySheet=({readInventorySheet})");

                string invSheetName = _importSettings.InventorySheetName ?? "";
                string aeSheetName = _importSettings.ArchivalEntitiesSheetName ?? "";
                string docSheetName = _importSettings.DocumentsSheetName ?? "";
                string packageSheetName = _importSettings.PackageBSheetName ?? "";

                string fileName = model.FileName;
                var xlsx = model;
                string error = "";
                StringBuilder errorsList = new StringBuilder();

                InventoryImportModel? invImportModel = null;
                List<ArchivalEntityImportModel> aeImportModels = new List<ArchivalEntityImportModel>();
                List<DocumentImportModel> docImportModels = new List<DocumentImportModel>();
                List<PackageImportModel> packageImportModels = new List<PackageImportModel>();

                IList<ExcelDDL> ddlLists = await GetDropDownListsCollection(
                    new ExcelDropDownListType[] {
                        ExcelDropDownListType.Language,
                        ExcelDropDownListType.AcquisitionMethod,
                        ExcelDropDownListType.InventoryNumberArray
                    });


                if (xlsx != null && xlsx.Length > 0)
                {
                    using (var stream = new MemoryStream())
                    {
                        await xlsx.CopyToAsync(stream);
                        using (var package = new ExcelPackage(stream))
                        {
                            if (readInventorySheet)
                            {
                                ExcelWorksheet invWorksheet = package.Workbook.Worksheets[invSheetName];
                                if (invWorksheet == null)
                                {
                                    error = String.Format(_localizer.GetString("ImportError_MissingSheet").Value, invSheetName);
                                    _logger.LogError(error);
                                    return OperationResult.Failed(error);
                                }

                                invImportModel = await ImportInventory(invSheetName, invWorksheet, ddlLists, error, errorsList, inventorySysId);
                                if (errorsList.Length > 0)
                                {
                                    _logger.LogError(errorsList.ToString());
                                    return OperationResult.Failed(errorsList.ToString());
                                }

                                if (invImportModel == null)
                                {
                                    error = _localizer.GetString("InventoryImportNotFound").Value;
                                    _logger.LogError(error);
                                    return OperationResult.Failed(error);
                                }
                            }


                            ExcelWorksheet aeWorksheet = package.Workbook.Worksheets[aeSheetName];
                            if (aeWorksheet == null)
                            {
                                error = String.Format(_localizer.GetString("ImportError_MissingSheet").Value, aeSheetName);
                                _logger.LogError(error);
                                return OperationResult.Failed(error);
                            }

                            ImportArchivalEntites(aeSheetName, aeWorksheet, ddlLists, error, errorsList, aeImportModels);
                            if (errorsList.Length > 0)
                            {
                                _logger.LogError(errorsList.ToString());
                                return OperationResult.Failed(errorsList.ToString());
                            }

                            if (aeImportModels.Count == 0)
                            {
                                error = _localizer.GetString("ArchivalEntitiesImportNoEntitiesFound").Value;
                                _logger.LogError(error);
                                return OperationResult.Failed(error);
                            }



                            ExcelWorksheet docWorksheet = package.Workbook.Worksheets[docSheetName];
                            if (docWorksheet == null)
                            {
                                error = String.Format(_localizer.GetString("ImportError_MissingSheet").Value, docSheetName);
                                _logger.LogError(error);
                                return OperationResult.Failed(error);
                            }

                            ImportDocuments(docSheetName, docWorksheet, ddlLists, error, errorsList, docImportModels, aeImportModels);

                            if (docImportModels.Count == 0)
                            {
                                if (errorsList.Length > 0)
                                {
                                    return OperationResult.Failed(errorsList.ToString());
                                }

                                error = _localizer.GetString("DocumentImportNoEntitiesFound").Value;
                                _logger.LogError(error);

                                return OperationResult.Failed(error);
                            }

                            if (readPackageSheet)
                            {
                                ExcelWorksheet packageWorksheet = package.Workbook.Worksheets[packageSheetName];
                                if (packageWorksheet == null)
                                {
                                    error = String.Format(_localizer.GetString("ImportError_MissingSheet").Value, packageSheetName);
                                    _logger.LogError(error);
                                    return OperationResult.Failed(error);
                                }

                                ImportPackageFiles(packageSheetName, packageWorksheet, ddlLists, error, errorsList, packageImportModels, docImportModels);
                            }
                        }

                        if (errorsList.Length > 0)
                        {
                            _logger.LogError(errorsList.ToString());
                            return OperationResult.Failed(errorsList.ToString());
                        }

                        if (createEntities)
                        {
                            OperationResult saveResult = await SaveImportedDataAsync(aeImportModels, inventorySysId, readPackageSheet, readInventorySheet, invImportModel);
                            if (!saveResult.Succeeded)
                            {
                                _logger.LogError(String.Join(";", saveResult.Errors));
                                return OperationResult.Failed(String.Join(";", saveResult.Errors));
                            }
                        }

                        _logger.LogInformation($"Import of file {model.FileName} succeeded");
                        return OperationResult.Succeed(aeImportModels);
                    }
                }
                else
                {
                    error = _localizer.GetString("ImportEmptyFile").Value;
                    _logger.LogError(error);
                    return OperationResult.Failed(error);
                }
            }
            catch
            {
                throw;
            }
        }

        private async Task<InventoryImportModel?> ImportInventory(string invSheetName, ExcelWorksheet invWorksheet, IList<ExcelDDL> ddlLists, string error, StringBuilder errorsList, Guid inventorySysId)
        {
            int invRowCnt = invWorksheet.Dimension != null ? invWorksheet.Dimension.Rows : 0;
            int invColCnt = invWorksheet.Dimension != null ? invWorksheet.Dimension.Columns : 0;

            if (invRowCnt > 2 && invColCnt > 0)
            {
                int row = 3;
                InventoryImportModel importModel = ExcelHelper.GetModelFromRow<InventoryImportModel>(invWorksheet, 1, invColCnt, row, 1, ddlLists);
                if (importModel == null)
                    return null;

                string validationErrors = _modelValidationService.ValidateToString(importModel);
                if (String.IsNullOrWhiteSpace(validationErrors))
                {
                    bool hasError = false;
                    string validateDDLError;
                    if (!ExportModelHelper.AreDropDownValuesValid(importModel, ddlLists, out validateDDLError))
                    {
                        error = String.Format(_localizer.GetString("InvalidImportInventoryDropDownValue").Value, invSheetName, validateDDLError);
                        errorsList.AppendLine(error);
                        hasError = true;
                    }

                    if (!importModel.IsStartDateValid)
                    {
                        error = String.Format(_localizer.GetString("InvalidImportStartDate").Value, invSheetName, row);
                        errorsList.AppendLine(error);
                        hasError = true;
                    }

                    if (!importModel.IsEndDateMoreThanStartDay)
                    {
                        error = String.Format(_localizer.GetString("InvalidEndDateMoreThanStartDay").Value, invSheetName, row);
                        errorsList.AppendLine(error);
                        hasError = true;
                    }

                    if (!importModel.IsEndDateValid)
                    {
                        error = String.Format(_localizer.GetString("InvalidImportEndDate").Value, invSheetName, row);
                        errorsList.AppendLine(error);
                        hasError = true;
                    }

                    var inventoryDraft = await _context.InventoryDrafts
                        .Where(x => !x.Deleted && x.IsCurrent && x.SystemIdentifier == inventorySysId)
                        .SingleOrDefaultAsync();

                    if (inventoryDraft == null)
                    {
                        error = String.Format(_localizer.GetString("Error_InventoryNotFound").Value, invSheetName, inventorySysId);
                        errorsList.AppendLine(error);
                        hasError = true;
                    }

                    if (!String.Equals(inventoryDraft?.NumberArray, importModel.NumberArray.Trim()))
                    {
                        error = String.Format(_localizer.GetString("Error_InventoryNumberArrayDoesNotMatch").Value, invSheetName, importModel.NumberArray, inventoryDraft?.NumberArray);
                        errorsList.AppendLine(error);
                        hasError = true;
                    }

                    if (!hasError)
                    {
                        return importModel;
                    }
                }
                else
                {
                    error = String.Format(_localizer.GetString("InvalidImportInventoryData").Value, invSheetName, validationErrors);
                    errorsList.AppendLine(error);
                }

            }
            return null;
        }

        private void ImportArchivalEntites(string aeSheetName, ExcelWorksheet aeWorksheet, IList<ExcelDDL> ddlLists, string error, StringBuilder errorsList, List<ArchivalEntityImportModel> aeImportModels)
        {
            int aeRowCnt = aeWorksheet.Dimension != null ? aeWorksheet.Dimension.Rows : 0;
            int aeColCnt = aeWorksheet.Dimension != null ? aeWorksheet.Dimension.Columns : 0;

            if (aeRowCnt > 2 && aeColCnt > 0)
            {
                for (int row = 3; row <= aeRowCnt; row++)
                {
                    ArchivalEntityImportModel aeImportModel = ExcelHelper.GetModelFromRow<ArchivalEntityImportModel>(aeWorksheet, 1, aeColCnt, row, 1, ddlLists);
                    if (aeImportModel == null)
                        break;

                    string validationErrors = _modelValidationService.ValidateToString(aeImportModel);
                    if (String.IsNullOrWhiteSpace(validationErrors))
                    {
                        bool hasError = false;
                        string validateDDLError;
                        if (!ExportModelHelper.AreDropDownValuesValid(aeImportModel, ddlLists, out validateDDLError))
                        {
                            error = String.Format(_localizer.GetString("InvalidImportArchivalEntityDropDownValue").Value, aeSheetName, validateDDLError, row);
                            errorsList.AppendLine(error);
                            hasError = true;
                        }

                        if (!aeImportModel.IsStartDateValid)
                        {
                            error = String.Format(_localizer.GetString("InvalidImportStartDate").Value, aeSheetName, row);
                            errorsList.AppendLine(error);
                            hasError = true;
                        }

                        if (!aeImportModel.IsEndDateValid)
                        {
                            error = String.Format(_localizer.GetString("InvalidImportEndDate").Value, aeSheetName, row);
                            errorsList.AppendLine(error);
                            hasError = true;
                        }

                        if (!aeImportModel.IsEndDateMoreThanStartDay)
                        {
                            error = String.Format(_localizer.GetString("InvalidEndDateMoreThanStartDay").Value, aeSheetName, row);
                            errorsList.AppendLine(error);
                            hasError = true;
                        }

                        if (aeImportModels.Where(x => String.Equals(x.Number, aeImportModel.Number)).Any())
                        {
                            error = String.Format(_localizer.GetString("DuplicatedAEImportNumber").Value, aeSheetName, aeImportModel.Number, row);
                            errorsList.AppendLine(error);
                            hasError = true;
                        }

                        if (!hasError)
                        {
                            aeImportModels.Add(aeImportModel);
                        }
                    }
                    else
                    {
                        error = String.Format(_localizer.GetString("InvalidImportArchivalEntityData").Value, aeSheetName, row, validationErrors);
                        errorsList.AppendLine(error);
                    }
                }
            }
        }

        private void ImportDocuments(string docSheetName, ExcelWorksheet docWorksheet, IList<ExcelDDL> ddlLists, string error, StringBuilder errorsList, List<DocumentImportModel> docImportModels, List<ArchivalEntityImportModel> aeImportModels)
        {
            int docRowCnt = docWorksheet.Dimension != null ? docWorksheet.Dimension.Rows : 0;
            int docColCnt = docWorksheet.Dimension != null ? docWorksheet.Dimension.Columns : 0;

            if (docRowCnt > 2 && docColCnt > 0)
            {
                for (int row = 3; row <= docRowCnt; row++)
                {
                    DocumentImportModel docImportModel = ExcelHelper.GetModelFromRow<DocumentImportModel>(docWorksheet, 1, docColCnt, row, 1, ddlLists);
                    if (docImportModel == null)
                        break;

                    string validationErrors = _modelValidationService.ValidateToString(docImportModel);
                    if (String.IsNullOrWhiteSpace(validationErrors))
                    {
                        bool hasError = false;
                        string validateDDLError;
                        if (!ExportModelHelper.AreDropDownValuesValid(docImportModel, ddlLists, out validateDDLError))
                        {
                            error = String.Format(_localizer.GetString("InvalidImportDocumentDropDownValue").Value, docSheetName, validateDDLError, row);
                            errorsList.AppendLine(error);
                            hasError = true;
                        }

                        if (!docImportModel.IsStartDateValid)
                        {
                            error = String.Format(_localizer.GetString("InvalidImportStartDate").Value, docSheetName, row);
                            errorsList.AppendLine(error);
                            hasError = true;
                        }

                        if (!docImportModel.IsEndDateValid)
                        {
                            error = String.Format(_localizer.GetString("InvalidImportEndDate").Value, docSheetName, row);
                            errorsList.AppendLine(error);
                            hasError = true;
                        }

                        if (!docImportModel.IsEndDateMoreThanStartDay)
                        {
                            error = String.Format(_localizer.GetString("InvalidEndDateMoreThanStartDay").Value, docSheetName, row);
                            errorsList.AppendLine(error);
                            hasError = true;
                        }

                        if (docImportModels.Where(x => String.Equals(x.ArchivalEntityNumber, docImportModel.ArchivalEntityNumber) && String.Equals(x.DocumentNumber, docImportModel.DocumentNumber)).Any())
                        {
                            error = String.Format(_localizer.GetString("DuplicatedDocImportNumberInAe").Value, docSheetName, docImportModel.DocumentNumber, docImportModel.ArchivalEntityNumber, row);
                            errorsList.AppendLine(error);
                            hasError = true;
                        }

                        if (!hasError)
                        {
                            docImportModels.Add(docImportModel);

                            var ae = aeImportModels.FirstOrDefault(x => String.Equals(x.Number, docImportModel.ArchivalEntityNumber!.Trim()));
                            if (ae != null)
                            {
                                ae.Documents = ae.Documents ?? new List<DocumentImportModel>();
                                List<DocumentImportModel> docsList = ae.Documents.ToList();
                                docsList.Add(docImportModel);
                                ae.Documents = docsList;
                            }
                            else
                            {
                                errorsList.AppendLine(String.Format(_localizer.GetString("ImportError_NoMatchingArchivalEntity").Value, docSheetName, docImportModel.ArchivalEntityNumber, row));
                            }
                        }
                    }
                    else
                    {
                        error = String.Format(_localizer.GetString("InvalidImportDocumentData").Value, docSheetName, row, validationErrors);
                        errorsList.AppendLine(error);
                    }
                }
            }
        }

        private void ImportPackageFiles(string packageSheetName, ExcelWorksheet packageWorksheet, IList<ExcelDDL> ddlLists, string error, StringBuilder errorsList, List<PackageImportModel> packageImportModels, List<DocumentImportModel> docImportModels)
        {
            int packageRowCnt = packageWorksheet.Dimension != null ? packageWorksheet.Dimension.Rows : 0;
            int packageColCnt = packageWorksheet.Dimension != null ? packageWorksheet.Dimension.Columns : 0;

            if (packageRowCnt > 2 && packageColCnt > 0)
            {
                for (int row = 3; row <= packageRowCnt; row++)
                {
                    PackageImportModel packageImportModel = ExcelHelper.GetModelFromRow<PackageImportModel>(packageWorksheet, 1, packageColCnt, row, 1, ddlLists);
                    if (packageImportModel == null)
                        break;

                    string validationErrors = _modelValidationService.ValidateToString(packageImportModel);
                    if (String.IsNullOrWhiteSpace(validationErrors))
                    {
                        packageImportModels.Add(packageImportModel);

                        var doc = docImportModels.FirstOrDefault(x => x.DocumentNumber == packageImportModel.DocumentNumber);
                        if (doc != null)
                        {
                            doc.PackageFiles = doc.PackageFiles ?? new List<PackageImportModel>();
                            List<PackageImportModel> filesList = doc.PackageFiles.ToList();
                            filesList.Add(packageImportModel);
                            doc.PackageFiles = filesList;
                        }
                        else
                        {
                            errorsList.AppendLine(String.Format(_localizer.GetString("ImportError_NoMatchingDocumentEntity").Value, packageSheetName, row));
                        }
                    }
                    else
                    {
                        error = String.Format(_localizer.GetString("InvalidImportPackageData").Value, packageSheetName, row, validationErrors);
                        errorsList.AppendLine(error);
                    }
                }
            }
        }

        private async Task<IList<ExcelDDL>> GetDropDownListsCollection(ExcelDropDownListType[] ddlTypes)
        {
            List<ExcelDDL> lists = new List<ExcelDDL>();

            foreach (ExcelDropDownListType typ in ddlTypes)
            {
                switch (typ)
                {
                    case ExcelDropDownListType.Language:
                        IList<ExcelDDLItem> languages = _dropDownService.GetNomenclatures("LANGUAGE")
                            .Select(c => new ExcelDDLItem { Value = c.Code, DisplayName = c.Label ?? "" })
                            .OrderBy(c => c.DisplayName)
                            .ToList();
                        if (languages.Count > 0)
                            lists.Add(new ExcelDDL { ListType = ExcelDropDownListType.Language, Collection = languages });
                        break;

                    case ExcelDropDownListType.InventoryNumberArray:
                        IList<ExcelDDLItem> invNumberArray = _dropDownService.GetInventoryArrays()
                            .Select(c => new ExcelDDLItem { Value = c.Code, DisplayName = c.Label ?? "" })
                            .OrderBy(c => c.DisplayName)
                            .ToList();
                        if (invNumberArray.Count > 0)
                            lists.Add(new ExcelDDL { ListType = ExcelDropDownListType.InventoryNumberArray, Collection = invNumberArray });
                        break;

                    case ExcelDropDownListType.AcquisitionMethod:
                        IList<ExcelDDLItem> acquisitionMethods = _dropDownService.GetNomenclatures("ACQUISITION_METHOD")
                            .Select(c => new ExcelDDLItem { Value = c.Id, DisplayName = c.Label ?? "" })
                            .OrderBy(c => c.DisplayName)
                            .ToList();
                        if (acquisitionMethods.Count > 0)
                            lists.Add(new ExcelDDL { ListType = ExcelDropDownListType.AcquisitionMethod, Collection = acquisitionMethods });
                        break;

                    default:
                        break;
                }
            }

            return lists;
        }


        private async Task<OperationResult> SaveImportedDataAsync(List<ArchivalEntityImportModel> aeImportModels, Guid inventorySysId, bool addPackageFiles, bool updateInventory, InventoryImportModel importModel)
        {
            if (updateInventory && importModel == null)
            {
                return OperationResult.Success;
            }

            if (aeImportModels == null || aeImportModels.Count() == 0)
            {
                return OperationResult.Success;
            }


            var inventoryDraft = await _context.InventoryDrafts
                .Where(x => !x.Deleted && x.IsCurrent && x.SystemIdentifier == inventorySysId)
                .SingleOrDefaultAsync();

            if (inventoryDraft == null)
            {
                return OperationResult.Failed(String.Format(_localizer.GetString("Error_InventoryNotFound").Value, inventorySysId));
            }


            using var transaction = _context.Database.BeginTransaction();
            try
            {
                // TODO: проверка стъпката от процеса?

                // ако изчитаме и записваме данни от sheet Пакет Б, значи става въпрос за необработени документи и НЕ трием файлове от пакет Б на описа!
                await DeleteInventoryRelatedImportData(inventorySysId, !addPackageFiles);


                FundDraft? fundDraft = null;
                List<PackageDocument> packageDocs = new List<PackageDocument>();
                if (addPackageFiles)
                {
                    fundDraft = await _context.FundDrafts
                            .Where(x => x.SystemIdentifier == inventoryDraft.FundSystemIdentifier && !x.Deleted && x.IsCurrent)
                            .FirstOrDefaultAsync();

                    if (fundDraft == null)
                    {
                        transaction.Rollback();
                        return OperationResult.Failed(false, String.Format(_localizer.GetString("ImportError_FundNotFound").Value, inventoryDraft.FundSystemIdentifier));
                    }

                    var docIds = aeImportModels.SelectMany(a => a.PackageFileIds).ToList();

                    packageDocs = await _context.PackageDocuments
                        .Where(x =>
                            !x.Deleted &&
                            docIds.Contains(x.Id) &&
                            (x.DigitalObjectDrafts == null ||
                            x.DigitalObjectDrafts.Where(d => !d.Deleted && d.IsCurrent).Count() == 0))
                        .ToListAsync();

                    var foundIds = packageDocs.Select(x => x.Id).ToList();
                    var notFound = docIds.Where(x => !foundIds.Contains(x)).ToList();
                    if (notFound.Any())
                    {
                        transaction.Rollback();
                        return OperationResult.Failed(String.Format(_localizer.GetString("Error_ImportPackageFilesNotFound").Value, String.Join(", ", notFound)));
                    }
                }


                if (updateInventory)
                {
                    await UpdateInventory(inventoryDraft, importModel);
                }


                foreach (var aeModel in aeImportModels)
                {
                    aeModel.SystemIdentifier = await CreateArchivalEntity(inventoryDraft, aeModel);

                    var archivalEntityDraft = await _context.ArchivalEntityDrafts
                        .Where(x => !x.Deleted && x.IsCurrent && x.SystemIdentifier == aeModel.SystemIdentifier)
                        .SingleOrDefaultAsync();

                    if (archivalEntityDraft == null)
                    {
                        transaction.Rollback();
                        return OperationResult.Failed(String.Format(_localizer.GetString("Error_ArchivalEntityNotFound").Value, aeModel.SystemIdentifier));
                    }

                    if (aeModel.Documents != null && aeModel.Documents.Count() > 0)
                    {
                        foreach (var docModel in aeModel.Documents)
                        {
                            docModel.SystemIdentifier = await CreateDocument(inventoryDraft, docModel, archivalEntityDraft.Id, aeModel.SystemIdentifier);


                            if (addPackageFiles && docModel.PackageFiles != null && docModel.PackageFiles.Count() > 0)
                            {
                                foreach (var fileModel in docModel.PackageFiles)
                                {
                                    PackageDocument packageDoc = packageDocs.Where(x => x.Id == fileModel.Number).First();

                                    DigitalObjectDraftModel digitalObject = new DigitalObjectDraftModel
                                    {
                                        ArchiveId = inventoryDraft.ArchiveId,
                                        FundSystemIdentifier = inventoryDraft.FundSystemIdentifier,
                                        InventorySystemIdentifier = inventoryDraft.SystemIdentifier,
                                        ArchivalEntitySystemIdentifier = aeModel.SystemIdentifier,
                                        DocumentSystemIdentifier = docModel.SystemIdentifier,
                                        TypeCode = (int)DigitalObjectType.MasterFile,
                                        StatusCode = Shared.Status.New,
                                        ContentType = packageDoc.ContentType,
                                        SourceName = packageDoc.FileName,
                                        PackageDocumentId = packageDoc.Id,
                                        FileSize = packageDoc.FileSizeInBytes ?? 0,
                                        IsImported = true,
                                    };

                                    var digObjectSysId = await _utilityService.CreateDODraftFromPackageDocumentInternalAsync(packageDoc, digitalObject);
                                    _logger.LogInformation($"Created draft for digital object {digObjectSysId}");
                                }
                            }
                        }
                    }
                }

                transaction.Commit();
                return OperationResult.Succeed(aeImportModels);
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        private async Task DeleteInventoryRelatedImportData(Guid inventorySysId, bool deletePackageFiles)
        {
            _logger.LogInformation($"Start deleting previous import data for inventory {inventorySysId} and deletePackageFiles={deletePackageFiles}");

            var digitalObjectDrafts = await _context.DigitalObjectDrafts
                .Where(dig =>
                    dig.InventorySystemIdentifier == inventorySysId
                    && dig.IsCurrent
                    && !dig.Deleted
                    && dig.IsImported)
                .ToListAsync();

            if (deletePackageFiles)
            {
                var packageDocumentIds = digitalObjectDrafts.Select(x => x.PackageDocumentId).ToList();
                var files = await _context.PackageDocuments
                    .Where(x => packageDocumentIds.Contains(x.Id))
                    .ToListAsync();

                foreach (PackageDocument doc in files)
                {
                    await _utilityService.DeletePackageDocument(doc);
                    _logger.LogInformation($"Deleted package file Id:{doc.Id} PackageId:{doc.PackageId}");
                }
            }

            var digitalObjectDraftIds = digitalObjectDrafts.Select(dig => dig.Id).ToList();
            //int aeWithPackageFilesCount = digitalObjectDrafts.Select(x => x.ArchivalEntitySystemIdentifier).Distinct().Count();
            foreach (int draftId in digitalObjectDraftIds)
            {
                await _utilityService.DeleteDODraftInternalAsync(draftId);
                _logger.LogInformation($"Deleted digital object draft Id:{draftId}");
            }

            var documentDraftIds = await _context.DocumentDrafts
            .Where(d =>
                    d.InventorySystemIdentifier == inventorySysId
                    && d.IsCurrent
                    && !d.Deleted
                    && d.IsImported)
                .Select(d => d.Id)
                .ToListAsync();
            foreach (int draftId in documentDraftIds)
            {
                await _utilityService.DeleteDocDraftInternalAsync(draftId);
                _logger.LogInformation($"Deleted document draft Id:{draftId}");
            }

            var archivalEntityDrafts = await _context.ArchivalEntityDrafts
                .Where(ae =>
                    ae.InventorySystemIdentifier == inventorySysId
                    && ae.IsCurrent
                    && !ae.Deleted
                    && ae.IsImported)
                .ToListAsync();
            var archivalEntityDraftIds = archivalEntityDrafts.Select(ae => ae.Id).ToList();
            foreach (int draftId in archivalEntityDraftIds)
            {
                await _utilityService.DeleteAEDraftInternalAsync(draftId);
                _logger.LogInformation($"Deleted archival entity draft Id:{draftId}");
            }
        }

        private async Task UpdateInventory(InventoryDraft inventoryDraft, InventoryImportModel importModel)
        {

            string approximateDateStr = CommonHelper.GetApproximateDateString(
                    importModel.StartDateDay, importModel.StartDateMonth, importModel.StartDateYear,
                    importModel.EndDateDay, importModel.EndDateMonth, importModel.EndDateYear);

            inventoryDraft.AcquisitionMethodId = importModel.AcquisitionMethod;
            inventoryDraft.StartDateYear = importModel.StartDateYear;
            inventoryDraft.StartDateMonth = importModel.StartDateMonth;
            inventoryDraft.StartDateDay = importModel.StartDateDay;
            inventoryDraft.EndDateYear = importModel.EndDateYear;
            inventoryDraft.EndDateMonth = importModel.EndDateMonth;
            inventoryDraft.EndDateDay = importModel.EndDateDay;
            inventoryDraft.ApproxmateChronologicalScope = approximateDateStr;
            inventoryDraft.OtherMetrics = importModel.OtherMetrics;
            inventoryDraft.FundCreatorTitleHistory = importModel.FundCreatorTitleHistory;
            inventoryDraft.FundCreatorBiographicalHistory = importModel.FundCreatorBiographicalHistory;
            inventoryDraft.History = importModel.History;
            inventoryDraft.DocumentsProvider = importModel.DocumentsProvider;
            inventoryDraft.DocumentsDescription = importModel.DocumentsDescription;
            inventoryDraft.DocumentsAccessDescription = importModel.DocumentsAccessDescription;
            inventoryDraft.ClassificationScheme = importModel.ClassificationScheme;
            inventoryDraft.AbbreviationList = importModel.AbbreviationList;
            inventoryDraft.Notes = importModel.Notes;

            _context.InventoryDrafts.Update(inventoryDraft);
            await _context.SaveAsync("Inventory draft updated with import data");
            _logger.LogInformation($"Updated data for inventory {inventoryDraft.SystemIdentifier} draftId:{inventoryDraft.Id}");
        }

        private async Task<Guid> CreateArchivalEntity(InventoryDraft inventoryDraft, ArchivalEntityImportModel aeModel)
        {
            string approximateDateStr = CommonHelper.GetApproximateDateString(
                        aeModel.StartDateDay, aeModel.StartDateMonth, aeModel.StartDateYear,
                        aeModel.EndDateDay, aeModel.EndDateMonth, aeModel.EndDateYear);

            ArchivalEntityDraftModel aeDraftModel = new ArchivalEntityDraftModel()
            {
                IsCurrent = true,
                HasExternalSource = false,
                ArchiveId = inventoryDraft.ArchiveId,
                FundDraftId = inventoryDraft.FundDraftId,
                FundSystemIdentifier = inventoryDraft.FundSystemIdentifier,
                InventoryDraftId = inventoryDraft.Id,
                InventorySystemIdentifier = inventoryDraft.SystemIdentifier,
                NumberNumeric = aeModel.NumberNumeric,
                NumberArray = aeModel.NumberArray,
                Number = aeModel.Number,
                Title = aeModel.Title,
                DescriptionLevelCode = ((int)Shared.ArchivalEntityDescriptionLevel.ArchivalEntity).ToString(),
                StatusCode = Shared.Status.New,
                AvailabilityStatusCode = (int)Shared.AvailabilityStatus.Enrollment,
                StartDateYear = aeModel.StartDateYear,
                StartDateMonth = aeModel.StartDateMonth,
                StartDateDay = aeModel.StartDateDay,
                EndDateYear = aeModel.EndDateYear,
                EndDateMonth = aeModel.EndDateMonth,
                EndDateDay = aeModel.EndDateDay,
                ApproximateChronologicalScope = approximateDateStr,
                Author = aeModel.Author,
                Location = aeModel.Location,
                Description = aeModel.Description,
                DocumentsAccessDescription = aeModel.DocumentsAccessDescription,
                Notes = aeModel.Notes,
                IsImported = true,
                LanguageCodes = aeModel.LanguageCodes,
                DescriptionAuthor = aeModel.DescriptionAuthor,

                Cypher = aeModel.Cypher,
                TextDocsCount = aeModel.TextDocsCount,
                GraphicalDocsCount = aeModel.GraphicalDocsCount,
                OtherMetrics = aeModel.OtherMetrics,
                Scaling = aeModel.Scaling,
                Features = aeModel.Features,
                Phase = aeModel.Phase,
                Part = aeModel.Part,
                Stage = aeModel.Stage,
                OtherLanguage = aeModel.OtherLanguage,
                ClassificationSchemeIndex = aeModel.ClassificationSchemeIndex,
            };


            var archivalEntitySysId = await _utilityService.CreateAEDraftInternalAsync(aeDraftModel);
            _logger.LogInformation($"Created draft for archival entity {archivalEntitySysId}");
            return archivalEntitySysId;
        }

        private async Task<Guid> CreateDocument(InventoryDraft inventoryDraft, DocumentImportModel docModel, int archivalEntityDraftId, Guid? archivalEntitySystemIdentifier)
        {
            string docApproximateDateStr = CommonHelper.GetApproximateDateString(
                               docModel.StartDateDay, docModel.StartDateMonth, docModel.StartDateYear,
                               docModel.EndDateDay, docModel.EndDateMonth, docModel.EndDateYear);

            DocumentDraftModel docDraftModel = new DocumentDraftModel()
            {
                IsCurrent = true,
                HasExternalSource = false,
                ArchiveId = inventoryDraft.ArchiveId,
                FundDraftId = inventoryDraft.FundDraftId,
                FundSystemIdentifier = inventoryDraft.FundSystemIdentifier,
                InventoryDraftId = inventoryDraft.Id,
                InventorySystemIdentifier = inventoryDraft.SystemIdentifier,
                ArchivalEntityDraftId = archivalEntityDraftId,
                ArchivalEntitySystemIdentifier = archivalEntitySystemIdentifier,
                ExternalIdentifier = null,
                Number = docModel.DocumentNumber.ToString(),
                Title = docModel.Title,
                DescriptionLevelCode = ((int)Shared.DocumentDescriptionLevel.Document).ToString(),
                StatusCode = Shared.Status.New,
                AvailabilityStatusCode = (int)Shared.AvailabilityStatus.Enrollment,
                StartDateYear = docModel.StartDateYear,
                StartDateMonth = docModel.StartDateMonth,
                StartDateDay = docModel.StartDateDay,
                EndDateYear = docModel.EndDateYear,
                EndDateMonth = docModel.EndDateMonth,
                EndDateDay = docModel.EndDateDay,
                ApproximateChronologicalScope = docApproximateDateStr,
                Author = docModel.Author,
                Location = docModel.Location,
                Description = docModel.Description,
                DocumentsAccessDescription = docModel.AccessConditions,
                Notes = docModel.Note,
                IsImported = true,
                LanguageCodes = docModel.LanguageCodes,
                DescriptionAuthor = docModel.DescriptionAuthor,

                Cypher = docModel.Cypher,
                TextDocsCount = docModel.TextDocsCount,
                GraphicalDocsCount = docModel.GraphicalDocsCount,
                OtherMetrics = docModel.OtherMetrics,
                Scaling = docModel.Scaling,
                Stage = docModel.Stage,
                Features = docModel.Features,
                Phase = docModel.Phase,
                Part = docModel.Part,
                OtherLanguage = docModel.OtherLanguage,
            };

            var documentSysId = await _utilityService.CreateDocDraftInternalAsync(docDraftModel);
            _logger.LogInformation($"Created draft for document {documentSysId}");
            return documentSysId;
        }
    }
}
