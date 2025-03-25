using CsvHelper;
using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Models.ArchiveEntities;
using DAA.Models.Archives;
using DAA.Models.DigitalObjects;
using DAA.Models.Films;
using DAA.Models.Reports;
using DAA.Services.Admin;
using DAA.Services.ArchivalEntities;
using DAA.Services.DigitalObjects;
using DAA.Services.Documents;
using DAA.Services.Films;
using DAA.Services.Funds;
using DAA.Services.Inventories;
using DAA.Shared;
using DAA.Shared.DynamicObjects;
using DAA.Shared.Excel;
using DAA.Shared.Localization;
using DocFlow.Models.File;
using DocFlow.Services.Interfaces;
using Microsoft.Extensions.Localization;
using OfficeOpenXml;
using System.Globalization;
using System.Text;
using System.Text.Json;
using PdfSharpCore.Pdf;
using TheArtOfDev.HtmlRenderer.PdfSharp;
using PdfDocument = PdfSharpCore.Pdf.PdfDocument;
using System.Data;
using System.Reflection;
using System.Xml.Serialization;
using System.Xml;
using PageSize = PdfSharpCore.PageSize;
using DAA.Services.Packages;

namespace DAA.Services
{
    public class ExportService : BaseService, IExportService
    {
        private readonly IArchiveService _archiveService;
        private readonly IReportService _reportService;
        private readonly IFilmService _filmService;
        private readonly IFilmCardService _filmCardService;
        private readonly IFundService _fundService;
        private readonly IInventoryService _inventoryService;
        private readonly IArchivalEntityService _archivalEntityService;
        private readonly IDocumentService _documentService;
        private readonly IDigitalObjectService _digitalObjectService;
        private readonly IPackagesService _packagesService;

        public ExportService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IArchiveService archiveService = null!,
            IReportService reportService = null!,
            IFilmService filmService = null!,
            IFilmCardService filmCardService = null!,
            IFundService fundService = null!,
            IInventoryService inventoryService = null!,
            IArchivalEntityService archivalEntityService = null!,
            IDocumentService documentService = null!,
            IPackagesService packagesService = null!,
        IDigitalObjectService digitalObjectService = null)
            : base(context, localizer)
        {
            _archiveService = archiveService;
            _reportService = reportService;
            _filmService = filmService;
            _filmCardService = filmCardService;
            _fundService = fundService;
            _inventoryService = inventoryService;
            _archivalEntityService = archivalEntityService;
            _documentService = documentService;
            _digitalObjectService = digitalObjectService;
            _packagesService= packagesService;
        }

        public FileDownloadModel ExportGridData(GridExportModel model, string fileName)
        {
            //ExportFileType fileType = ExportFileType.Unknown;
            //Enum.TryParse(model.FileType, out fileType);
            string fileType = model.FileType ?? ExportFileType.Unknown;

            byte[] exportedBytes = null!;
            string mimeType = "text/plain";
            string fullName = $"Grid-{DateTime.Now.ToString("yyyyMMddHHmmssfff")}.{model.FileType}";

            switch (fileType)
            {
                case ExportFileType.Xlsx:
                    mimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                    var excelStream = new MemoryStream();
                    using (var package = new ExcelPackage(excelStream))
                    {
                        var workSheet = package.Workbook.Worksheets.Add(fileName);
                        ExcelHelper.AddGridDataToSheet(workSheet, model.Columns, model.Data, _localizer);
                        package.Save();
                    }
                    excelStream.Position = 0;
                    exportedBytes = excelStream.ToArray();
                    break;
                case ExportFileType.Csv:
                    mimeType = "text/csv";
                    List<object> csvRecords = DynamicObjectHelper.GetGridDataForExport(model.Columns, model.Data, _localizer, true);

                    var csvStream = new MemoryStream();
                    if (csvRecords != null && csvRecords.Count > 0)
                    {
                        using var streamWriter = new StreamWriter(csvStream, Encoding.UTF8);
                        using var csvWriter = new CsvWriter(streamWriter, CultureInfo.InvariantCulture);
                        csvWriter.WriteRecords(csvRecords);
                        streamWriter.Flush();
                        csvStream.Position = 0;
                        exportedBytes = csvStream.ToArray();
                    }
                    break;
                case ExportFileType.PDF:
                    //case ExportFileType.Word:
                    mimeType = "application/pdf";

                    var document = new PdfDocument();

                    string html = ExportDatatableToHtml(model);

                    PdfGenerator.AddPdfPages(document, html, PageSize.A4);

                    using (MemoryStream ms = new())
                    {
                        document.PageMode = PdfPageMode.UseThumbs;
                        document.Save(ms);
                        exportedBytes = ms.ToArray();

                    }
                    break;
                case ExportFileType.XML:
                    mimeType = "application/xhtml+xml";
                    List<dynamic> xmlRecords = DynamicObjectHelper.GetGridDataForExport(model.Columns, model.Data, _localizer, true);

                    var xmlStream = new MemoryStream();
                    if (xmlRecords != null && xmlRecords.Count > 0)
                    {
                        SerializableDynamicData xmlData = new() { Data = xmlRecords };

                        XmlSerializer gridSerializer = new(typeof(SerializableDynamicData));

                        using (XmlWriter writer = XmlWriter.Create(xmlStream))
                        {
                            gridSerializer.Serialize(writer, xmlData);
                            xmlStream.Seek(0, SeekOrigin.Begin);
                            exportedBytes = xmlStream.ToArray();
                        }
                    }
                    break;
                default:
                    break;
            }

            FileDownloadModel file = new()
            {
                Mimetype = mimeType,
                Filename = fullName,
                Data = exportedBytes != null ? Convert.ToBase64String(exportedBytes) : ""
            };

            return file;
        }

        public async Task<List<object>?> GetGridDataForExport(
            string? businessObjectType,
            DataSourceRequestModel options,
            object? businessObjectParams,
            object? exportOptions)
        {
            if (string.IsNullOrWhiteSpace(businessObjectType))
            {
                return null;
            }

            List<object>? data = new();

            //Enum.TryParse(businessObjectType.ToLower(), out BusinessObjectType objectType);
            //switch (objectType)
            switch (businessObjectType)
            {
                case BusinessObjectType.Report:
                    if (businessObjectParams == null)
                    {
                        throw new ArgumentException("Report subject unknown");
                    }
                    var subType = businessObjectParams.ToString();

                    if (exportOptions == null)
                    {
                        throw new ArgumentException("Report export options missing");
                    }

                    data = await GetReportsData(exportOptions.ToString()!, subType!);
                    break;
                case BusinessObjectType.Archive:
                    DataSourceResponseModel<ArchiveDisplayModel> archives = _archiveService.GetAll(options);
                    data = archives.Items?.Cast<object>().ToList();
                    break;
                case BusinessObjectType.Fund:
                    DataSourceResponseModel<Models.Funds.FundDisplayModel> funds = _fundService.GetAll(options);
                    data = funds.Items?.Cast<object>().ToList();
                    break;
                case BusinessObjectType.Inventory:
                    DataSourceResponseModel<Models.Inventories.InventoryDisplayModel> inventories = _inventoryService.GetAll(options);
                    data = inventories.Items?.Cast<object>().ToList();
                    break;
                case BusinessObjectType.ArchivalEntity:
                    DataSourceResponseModel<ArchivalEntityDisplayModel> archivalEntities = _archivalEntityService.GetAll(options);
                    data = archivalEntities.Items?.Cast<object>().ToList();
                    break;
                case BusinessObjectType.Document:
                    DataSourceResponseModel<Models.Documents.DocumentDisplayModel> documents = _documentService.GetAll(options);
                    data = documents.Items?.Cast<object>().ToList();
                    break;
                case BusinessObjectType.Film:
                    DataSourceResponseModel<FilmShortModel> films = _filmService.GetAll(options);
                    data = films.Items?.Cast<object>().ToList();
                    break;
                case BusinessObjectType.FilmCard:
                    if (businessObjectParams != null)
                    {
                        Guid filmSysId = new Guid(businessObjectParams.ToString());
                        //int.TryParse(businessObjectParams.ToString(), out filmId);
                        DataSourceResponseModel<FilmCardShortModel> cards = _filmCardService.GetAll(options, filmSysId);
                        data = cards.Items?.Cast<object>().ToList();
                    }
                    break;
                case BusinessObjectReportType.PackageB:
                    if (businessObjectParams != null)
                    {
                        int rowNumber = 1;
                        int packageId = Int32.Parse(businessObjectParams.ToString());

                        var items = _packagesService.GetPackageDocumentsById(packageId).ToList();
                        //Заради изискването да има "Номер на ред"...
                        foreach (var item in items)
                        {
                            item.RowNumber = rowNumber;
                            rowNumber++;
                        }

                        data= items?.Cast<object>().ToList();
                    }
                    break;
                default:
                    break;
            }

            return data;
        }

        private async Task<List<object>?> GetReportsData(string exportOptions, string type)
        {
            CancellationToken token = new();

            switch (type)
            {
                case BusinessObjectReportType.FundPublic:
                    var fundPublicReportInputModel = JsonSerializer.Deserialize<FundPublicReportInputModel>(exportOptions);
                    var fundPublicReportGridRequestModel =
                        new ReportGridRequestModel<FundPublicReportInputModel>(fundPublicReportInputModel ??
                            throw new ArgumentException("fundPublicReportInputModel missing!"));

                    ReportGridResponseModel<FundPublicReport> fundPublicReport =
                        await _reportService.GetFundsPublicReport(token, fundPublicReportGridRequestModel);
                    return fundPublicReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.FundInternal:
                    var fundInternalReportInputModel = JsonSerializer.Deserialize<FundPublicReportInputModel>(exportOptions);
                    var fundinternalReportGridRequestModel =
                        new ReportGridRequestModel<FundPublicReportInputModel>(fundInternalReportInputModel ??
                            throw new ArgumentException("fundInternalReportInputModel missing!"));

                    ReportGridResponseModel<FundInternalReport> fundInernalReport =
                        await _reportService.GetFundsInternalReport(token, fundinternalReportGridRequestModel);
                    return fundInernalReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.FundAvailability:
                    var fundAvailabilityReportInputModel = JsonSerializer.Deserialize<FundAvailabilityReportInputModel>(exportOptions);
                    var fundAvailabilityReportGridRequestModel =
                        new ReportGridRequestModel<FundAvailabilityReportInputModel>(fundAvailabilityReportInputModel ??
                            throw new ArgumentException("fundAvailabilityReportInputModel missing!"));

                    ReportGridResponseModel<FundAvailabilityReport> fundAvailabilityReport =
                        await _reportService.GetFundAvailabilityReport(token, fundAvailabilityReportGridRequestModel);
                    return fundAvailabilityReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.FundsList:
                    var fundsListReportInputModel = JsonSerializer.Deserialize<ListPublicReportInputModel>(exportOptions);
                    var fundsListReportReportGridRequestModel =
                        new ReportGridRequestModel<ListPublicReportInputModel>(fundsListReportInputModel ??
                            throw new ArgumentException("fundsListReportInputModel missing!"));

                    ReportGridResponseModel<FundsListPublicReport> fundsListReport =
                        await _reportService.GetFundsListReport(token, fundsListReportReportGridRequestModel);
                    return fundsListReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.FundsListInternal:
                    var fundsListInternalReportInputModel = JsonSerializer.Deserialize<ListReportInputModel>(exportOptions);
                    var fundsListInternalReportGridRequestModel =
                        new ReportGridRequestModel<ListReportInputModel>(fundsListInternalReportInputModel ??
                            throw new ArgumentException("fundsListInternalReportInputModel missing!"));

                    ReportGridResponseModel<FundsListReport> fundsListInternalReport =
                        await _reportService.GetFundsListInternalReport(token, fundsListInternalReportGridRequestModel);
                    return fundsListInternalReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.FundDataPublic:
                    var fundDataPublicReportInputModel = JsonSerializer.Deserialize<FundDataPublicReportInputModel>(exportOptions);
                    var fundDataPublicReportReportGridRequestModel =
                        new ReportGridRequestModel<FundDataPublicReportInputModel>(fundDataPublicReportInputModel ??
                            throw new ArgumentException("fundDataPublicReportInputModel missing!"));

                    ReportGridResponseModel<FundDataPublicReport> fundDataPublicReport =
                        await _reportService.GetFundsDataPublicReport(token, fundDataPublicReportReportGridRequestModel);
                    return fundDataPublicReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.FundDataInternal:
                    var fundDataInternalReportInputModel = JsonSerializer.Deserialize<FundDataInternalReportInputModel>(exportOptions);
                    var fundDataInternalReportGridRequestModel =
                        new ReportGridRequestModel<FundDataInternalReportInputModel>(fundDataInternalReportInputModel ??
                            throw new ArgumentException("fundDataInternalReportInputModel missing!"));

                    ReportGridResponseModel<FundDataInternalReport> fundDataInternalReport =
                        await _reportService.GetFundsDataInernalReport(token, fundDataInternalReportGridRequestModel);
                    return fundDataInternalReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.FundMemory:
                    var fundMemoryReportInputModel = JsonSerializer.Deserialize<ListPublicReportInputModel>(exportOptions);
                    var fundMemoryPublicReportGridRequestModel =
                        new ReportGridRequestModel<ListPublicReportInputModel>(fundMemoryReportInputModel
                            ?? throw new ArgumentException("fundMemoryReportInputModel missing!"));

                    ReportGridResponseModel<FundMemoryPublicReport> fundMemoryReport =
                        await _reportService.GetFundMemoriesPublicReport(token, fundMemoryPublicReportGridRequestModel);
                    return fundMemoryReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.FundMemoriesList:
                    var fundMemoriesListReportInputModel = JsonSerializer.Deserialize<ListReportInputModel>(exportOptions);
                    var fundMemoriesListReportGridRequestModel =
                        new ReportGridRequestModel<ListReportInputModel>(fundMemoriesListReportInputModel
                            ?? throw new ArgumentException("fundMemoriesListReportInputModel missing!"));

                    ReportGridResponseModel<FundMemoriesListReport> fundMemoriesListReport =
                        await _reportService.GetFundMemoriesListReport(token, fundMemoriesListReportGridRequestModel);
                    return fundMemoriesListReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.FundMemoriesListInternalReport:
                    var fundMemoriesListInternalReportInputModel = JsonSerializer.Deserialize<FundMemoriesListInternalReportFiltersModel>(exportOptions);
                    var fundMemoriesListInternalReportGridRequestModel =
                        new ReportGridRequestModel<FundMemoriesListInternalReportFiltersModel>(fundMemoriesListInternalReportInputModel
                            ?? throw new ArgumentException("fundMemoriesListInternalReportInputModel missing!"));

                    ReportGridResponseModel<FundMemoriesListInternalReport> fundMemoriesListInternalReport =
                        await _reportService.GetFundMemoriesListInternalReport(token, fundMemoriesListInternalReportGridRequestModel);
                    return fundMemoriesListInternalReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.RegisterOfDigitalObjects:
                    var registerOfDigitalObjectsReportInputModel = JsonSerializer.Deserialize<RegisterOfDigitalObjectsPublicReportInputModel>(exportOptions);
                    var registerOfDigitalObjectsReportReportGridRequestModel =
                        new ReportGridRequestModel<RegisterOfDigitalObjectsPublicReportInputModel>(registerOfDigitalObjectsReportInputModel
                            ?? throw new ArgumentException("registerOfDigitalObjectsReportInputModel missing!"));

                    ReportGridResponseModel<RegisterOfDigitalObjectsPublicReport> registerOfDigitalObjectsReport =
                        await _reportService.GetRegisterOfDigitalObjectsPublicReport(token, registerOfDigitalObjectsReportReportGridRequestModel);
                    return registerOfDigitalObjectsReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.PartialReceipts:
                    var partialReceiptsReportInputModel = JsonSerializer.Deserialize<PartialReceiptsPublicReportInputModel>(exportOptions);
                    var partialReceiptsReportReportGridRequestModel = new ReportGridRequestModel<PartialReceiptsPublicReportInputModel>(partialReceiptsReportInputModel
                            ?? throw new ArgumentException("partialReceiptsReportInputModel missing!"));

                    ReportGridResponseModel<PartialReceiptsPublicReport> partialReceiptsReport =
                        await _reportService.GetPartialReceiptsPublicReport(token, partialReceiptsReportReportGridRequestModel);
                    return partialReceiptsReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.PartialReceiptsList:
                    var partialReceiptsListReportInputModel = JsonSerializer.Deserialize<ListReportInputModel>(exportOptions);
                    var partialReceiptsListReportReportGridRequestModel = new ReportGridRequestModel<ListReportInputModel>(partialReceiptsListReportInputModel
                            ?? throw new ArgumentException("partialReceiptsListReportInputModel missing!"));

                    ReportGridResponseModel<PartialReceiptsListReport> partialReceiptsListReport =
                        await _reportService.GetPartialReceiptsListReport(token, partialReceiptsListReportReportGridRequestModel);
                    return partialReceiptsListReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.ReceiptsList:
                    var receiptsListReportInputModel = JsonSerializer.Deserialize<ReceiptsListReportInputModel>(exportOptions);
                    var receiptsListReportReportGridRequestModel = new ReportGridRequestModel<ReceiptsListReportInputModel>(receiptsListReportInputModel
                            ?? throw new ArgumentException("receiptsListReportInputModel missing!"));

                    ReportGridResponseModel<ReceiptsListReport> receiptsListReport =
                        await _reportService.GetReceiptsListReport(token, receiptsListReportReportGridRequestModel);
                    return receiptsListReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.WorkListForPriorityRestoration:
                    var workListForPriorityRestorationReportInputModel = JsonSerializer.Deserialize<ListReportInputModel>(exportOptions);
                    var workListForPriorityRestorationReportGridRequestModel = new ReportGridRequestModel<ListReportInputModel>(workListForPriorityRestorationReportInputModel
                            ?? throw new ArgumentException("receiptsListReportInputModel missing!"));

                    ReportGridResponseModel<WorkListForPriorityRestorationReport> workListForPriorityRestorationReport =
                        await _reportService.GetWorkListForPriorityRestorationReport(token, workListForPriorityRestorationReportGridRequestModel);
                    return workListForPriorityRestorationReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.InventoryBook:
                    var inventoryBookInputModel = JsonSerializer.Deserialize<ListReportInputModel>(exportOptions);
                    var inventoryBookGridRequestModel = new ReportGridRequestModel<ListReportInputModel>(inventoryBookInputModel
                        ?? throw new ArgumentException("inventoryBookInputModel missing!"));

                    ReportGridResponseModel<InventoryBook> inventoryBook = await _reportService.GetInventoryBook(token, inventoryBookGridRequestModel);
                    return inventoryBook.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.AccountAndDescriptionOfFilmDocumentsBook:
                    var accountAndDescriptionOfFilmDocumentsBookInputModel = JsonSerializer.Deserialize<ListReportInputModel>(exportOptions);
                    var accountAndDescriptionOfFilmDocumentsBookGridRequestModel = new ReportGridRequestModel<ListReportInputModel>(accountAndDescriptionOfFilmDocumentsBookInputModel
                        ?? throw new ArgumentException("accountAndDescriptionOfFilmDocumentsBook missing!"));

                    ReportGridResponseModel<AccountAndDescriptionOfFilmDocumentsBook> accountAndDescriptionOfFilmDocumentsBook =
                        await _reportService.GetAccountAndDescriptionOfFilmDocumentsBook(token, accountAndDescriptionOfFilmDocumentsBookGridRequestModel);
                    return accountAndDescriptionOfFilmDocumentsBook.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.InventoryBookOfCopiesFromForeignArchives:
                    var inventoryBookOfCopiesFromForeignArchivesInputModel = JsonSerializer.Deserialize<ListReportInputModel>(exportOptions);
                    var inventoryBookOfCopiesFromForeignArchivesGridRequestModel = new ReportGridRequestModel<ListReportInputModel>(inventoryBookOfCopiesFromForeignArchivesInputModel
                        ?? throw new ArgumentException("inventoryBookOfCopiesFromForeignArchivesInputModel missing!"));

                    ReportGridResponseModel<InventoryBookOfCopiesFromForeignArchives> inventoryBookOfCopiesFromForeignArchives = await _reportService.GetInventoryBookOfCopiesFromForeignArchives(token, inventoryBookOfCopiesFromForeignArchivesGridRequestModel);
                    return inventoryBookOfCopiesFromForeignArchives.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.CompilationAndNTOOfEDocuments:
                    var compilationAndNTOOfEDocumentsInputModel = JsonSerializer.Deserialize<CompilationAndNTOOfEDocumentsInputModel>(exportOptions);
                    var compilationAndNTOOfEDocumentsGridRequestModel = new ReportGridRequestModel<CompilationAndNTOOfEDocumentsInputModel>(compilationAndNTOOfEDocumentsInputModel
                        ?? throw new ArgumentException("compilationAndNTOOfEDocumentsInputModel missing!"));

                    ReportGridResponseModel<CompilationAndNTOOfEDocumentsReport> compilationAndNTOOfEDocuments = await _reportService.GetCompilationAndNTOOfEDocuments(token, compilationAndNTOOfEDocumentsGridRequestModel);
                    return compilationAndNTOOfEDocuments.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.RegisterOfDigitizedDocumentsReport:
                    var registerOfDigitizedDocumentsReportInputModel = JsonSerializer.Deserialize<RegisterOfDigitizedDocumentsReportInputModel>(exportOptions);
                    var registerOfDigitizedDocumentsReportGridRequestModel = new ReportGridRequestModel<RegisterOfDigitizedDocumentsReportInputModel>(registerOfDigitizedDocumentsReportInputModel
                        ?? throw new ArgumentException("registerOfDigitizedDocumentsReportInputModel missing!"));

                    ReportGridResponseModel<RegisterOfDigitizedDocumentsReport> registerOfDigitizedDocumentsReport = await _reportService.GetRegisterOfDigitizedDocumentsReport(token, registerOfDigitizedDocumentsReportGridRequestModel);
                    return registerOfDigitizedDocumentsReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.CountOfUsedCopiesOfDocumentsFromForeignArchivesReport:
                    var countOfUsedCopiesOfDocumentsFromForeignArchivesReportInputModel = JsonSerializer.Deserialize<CountOfUsedCopiesOfDocumentsFromForeignArchivesReportInputModel>(exportOptions);
                    var countOfUsedCopiesOfDocumentsFromForeignArchivesRequestModel = new ReportGridRequestModel<CountOfUsedCopiesOfDocumentsFromForeignArchivesReportInputModel>(countOfUsedCopiesOfDocumentsFromForeignArchivesReportInputModel
                        ?? throw new ArgumentException("countOfUsedCopiesOfDocumentsFromForeignArchivesInputModel missing!"));

                    ReportGridResponseModel<CountOfUsedCopiesOfDocumentsFromForeignArchivesReport> countOfUsedCopiesOfDocumentsFromForeignArchivesReport = await _reportService.GetCountOfUsedCopiesOfDocumentsFromForeignArchivesReport(token, countOfUsedCopiesOfDocumentsFromForeignArchivesRequestModel);
                    return countOfUsedCopiesOfDocumentsFromForeignArchivesReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.QualityControlReport:
                    var qualityControlReportInputModel = JsonSerializer.Deserialize<WorkDoneOnDigitalObjectsCombinedReportInputModel>(exportOptions);
                    var qualityControlRequestModel = new ReportGridRequestModel<WorkDoneOnDigitalObjectsCombinedReportInputModel>(qualityControlReportInputModel
                        ?? throw new ArgumentException("qualityControlReportInputModel missing!"));

                    ReportGridWithSummaryGridResponseModel<QualityControlCombined, QualityControlReport> qualityControlReport = await _reportService.GetQualityControlReport(token, qualityControlRequestModel);
                    return qualityControlReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.DigitalObjectsPreparationReport:
                    var digitalobjectsPreparationReportInputModel = JsonSerializer.Deserialize<WorkDoneOnDigitalObjectsCombinedReportInputModel>(exportOptions);
                    var digitalobjectsPreparationRequestModel = new ReportGridRequestModel<WorkDoneOnDigitalObjectsCombinedReportInputModel>(digitalobjectsPreparationReportInputModel
                        ?? throw new ArgumentException("digitalobjectsPreparationReportInputModel missing!"));

                    ReportGridWithSummaryGridResponseModel<DigitalObjectsPreparationCombined, DigitalObjectsPreparationReport> digitalObjectsPreparationReport = await _reportService.GetDigitalObjectsPreparationReport(token, digitalobjectsPreparationRequestModel);
                    return digitalObjectsPreparationReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.SpecialRegistrationListReport:
                    var specialRegistrationListInputModel = JsonSerializer.Deserialize<SpecialRegistrationListReportInputModel>(exportOptions);
                    var specialRegistrationListRequestModel = new ReportGridRequestModel<SpecialRegistrationListReportInputModel>(specialRegistrationListInputModel
                        ?? throw new ArgumentException("specialRegistrationListReportInputModel missing!"));

                    ReportGridResponseModel<SpecialRegistrationListReport> specialRegistrationList = await _reportService.GetSpecialRegistrationListReport(token, specialRegistrationListRequestModel);
                    return specialRegistrationList.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.NumberOfArchiveEntitiesOrderedByReaderReport:
                    var numberOfArchiveEntitiesOrderedByReaderReportInputModel = JsonSerializer.Deserialize<NumberOfArchiveEntitiesOrderedByReaderInputModel>(exportOptions);
                    var numberOfArchiveEntitiesOrderedByReaderReportRequestModel = new ReportGridRequestModel<NumberOfArchiveEntitiesOrderedByReaderInputModel>(numberOfArchiveEntitiesOrderedByReaderReportInputModel
                        ?? throw new ArgumentException("numberOfArchiveEntitiesOrderedByReaderReportInputModel missing!"));


                    ReportGridResponseModel<NumberOfArchiveEntitiesOrderedByReaderReport> numberOfArchiveEntitiesOrderedByReaderReport = await _reportService.GetNumberOfArchiveEntitiesOrderedByReaderReport(numberOfArchiveEntitiesOrderedByReaderReportRequestModel);
                    return numberOfArchiveEntitiesOrderedByReaderReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.NumberOfArchiveEntitiesOrderedByEmployeeReport:
                    var numberOfArchiveEntitiesOrderedByEmployeeReportInputModel = JsonSerializer.Deserialize<NumberOfArchiveEntitiesOrderedByEmployeeInputModel>(exportOptions);
                    var numberOfArchiveEntitiesOrderedByEmployeeReportRequestModel = new ReportGridRequestModel<NumberOfArchiveEntitiesOrderedByEmployeeInputModel>(numberOfArchiveEntitiesOrderedByEmployeeReportInputModel
                        ?? throw new ArgumentException("numberOfArchiveEntitiesOrderedByEmployeeReportInputModel missing!"));


                    ReportGridResponseModel<NumberOfArchiveEntitiesOrderedByEmployeeReport> numberOfArchiveEntitiesOrderedByEmployeeReport = await _reportService.GetNumberOfArchiveEntitiesOrderedByEmployeeReport(numberOfArchiveEntitiesOrderedByEmployeeReportRequestModel);
                    return numberOfArchiveEntitiesOrderedByEmployeeReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.DigitalObjectReviewDisplayModel:
                    var digitalObjectReviewInputModel = JsonSerializer.Deserialize<DigitalObjectReviewSearchModel>(exportOptions);
                    var digitalObjectReviewRequestModel = new ReportGridRequestModel<DigitalObjectReviewSearchModel>(digitalObjectReviewInputModel
                        ?? throw new ArgumentException("digitalObjectReviewInputModel missing!"));


                    ReportGridResponseModel<DigitalObjectReviewDisplayModel> digitalObjectReview = _digitalObjectService.GetDigitalObjectReviewsAsync(digitalObjectReviewRequestModel);
                    return digitalObjectReview.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.MostUsedRequestEntitiesReport:
                    var mostUsedRequestEntitiesInputModel = JsonSerializer.Deserialize<MostUsedRequestEntitiesReportInputModel>(exportOptions);
                    var mostUsedRequestEntitiesRequestModel = new ReportGridRequestModel<MostUsedRequestEntitiesReportInputModel>(mostUsedRequestEntitiesInputModel
                        ?? throw new ArgumentException("mostUsedRequestEntitiesInputModel missing!"));

                    ReportGridResponseModel<MostUsedRequestEntitiesReport> mostUsedRequestEntities = await _reportService.GetMostUsedRequestEntitiesReport(token, mostUsedRequestEntitiesRequestModel);
                    return mostUsedRequestEntities.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.NumberOfDocumentsOrderedByReaderReport:
                    var numberOfDocumentsOrderedByReaderReportInputModel = JsonSerializer.Deserialize<NumberOfDocumentsOrderedByReaderReportInputModel>(exportOptions);
                    var numberOfDocumentsOrderedByReaderReportRequestModel = new ReportGridRequestModel<NumberOfDocumentsOrderedByReaderReportInputModel>(numberOfDocumentsOrderedByReaderReportInputModel
                        ?? throw new ArgumentException("numberOfDocumentsOrderedByReaderReportInputModel missing!"));

                    ReportGridWithSummaryGridResponseModel<NumberOfDocumentsOrderedByReaderReportCombined, NumberOfDocumentsOrderedByReaderReport> numberOfDocumentsOrderedByReaderReport = await _reportService.GeNumberOfDocumentsOrderedByReaderReport(token, numberOfDocumentsOrderedByReaderReportRequestModel);
                    return numberOfDocumentsOrderedByReaderReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.NumberOfDocumentsOrderedByEmployeeReport:
                    var numberOfDocumentsOrderedByEmployeeReportInputModel = JsonSerializer.Deserialize<NumberOfDocumentsOrderedByEmployeeReportInputModel>(exportOptions);
                    var numberOfDocumentsOrderedByEmployeeReportRequestModel = new ReportGridRequestModel<NumberOfDocumentsOrderedByEmployeeReportInputModel>(numberOfDocumentsOrderedByEmployeeReportInputModel
                        ?? throw new ArgumentException("numberOfDocumentsOrderedByEmployeeReportInputModel missing!"));

                    ReportGridWithSummaryGridResponseModel<NumberOfDocumentsOrderedByEmployeeReportCombined, NumberOfDocumentsOrderedByEmployeeReport> numberOfDocumentsOrderedByEmployeeReport = await _reportService.GeNumberOfDocumentsOrderedByEmployeeReport(token, numberOfDocumentsOrderedByEmployeeReportRequestModel);
                    return numberOfDocumentsOrderedByEmployeeReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.ActiveProcessesReport:
                    var аctiveProcessesReportInputModel = JsonSerializer.Deserialize<ActiveProcessesReportInputModel>(exportOptions);
                    var аctiveProcessesRequestModel = new ReportGridRequestModel<ActiveProcessesReportInputModel>(аctiveProcessesReportInputModel
                        ?? throw new ArgumentException("activeProcessesReportInputModel missing!"));

                    ReportGridResponseModel<ActiveProcessesReport> аctiveProcesses = await _reportService.GetActiveProcessesReport(token, аctiveProcessesRequestModel);
                    return аctiveProcesses.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.InventoryReport:
                    var inventoryReportInputModel = JsonSerializer.Deserialize<InventoryReportInputModel>(exportOptions);
                    var inventoryReportRequestModel = new ReportGridRequestModel<InventoryReportInputModel>(inventoryReportInputModel
                        ?? throw new ArgumentException("inventoryReportInputModel missing!"));

                    ReportGridWithSummaryGridResponseModel<InventoryReportCombined, InventoryReport> inventoryReport = await _reportService.GetInventoryReport(token, inventoryReportRequestModel);
                    return inventoryReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.ListOfRoughDocumentsReport:
                    var listOfRoughDocumentsReportInputModel = JsonSerializer.Deserialize<ListOfRoughDocumentsReportInputModel>(exportOptions);
                    var listOfRoughDocumentsReportRequestModel = new ReportGridRequestModel<ListOfRoughDocumentsReportInputModel>(listOfRoughDocumentsReportInputModel
                        ?? throw new ArgumentException("listOfRoughDocumentsReportInputModel missing!"));

                    ReportGridWithSummaryGridResponseModel<ListOfRoughDocumentsReportCombined, ListOfRoughDocumentsReport> listOfRoughDocumentsReport = await _reportService.GetListOfRoughDocumentsReport(token, listOfRoughDocumentsReportRequestModel);
                    return listOfRoughDocumentsReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.DigitalDocumentsUsageReport:
                    var digitalDocumentsUsageReportInputModel = JsonSerializer.Deserialize<DigitalDocumentsUsageReportInputModel>(exportOptions);
                    var digitalDocumentsUsageRequestModel = new ReportGridRequestModel<DigitalDocumentsUsageReportInputModel>(digitalDocumentsUsageReportInputModel
                        ?? throw new ArgumentException("digitalDocumentsUsageReport missing!"));

                    ReportGridWithSummaryGridResponseModel1<DigitalDocumentsUsageReportSummary, DigitalDocumentsUsageReport> digitalDocuments = await _reportService.GetDigitalDocumentsUsageReport(token, digitalDocumentsUsageRequestModel);
                    return digitalDocuments.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.ListOfPartialReceiptsInArchiveReport:
                    var listOfPartialReceiptsInArchiveReportInputModel = JsonSerializer.Deserialize<ListOfPartialReceiptsInArchiveReportInputModel>(exportOptions);
                    var listOfPartialReceiptsInArchiveReportRequestModel = new ReportGridRequestModel<ListOfPartialReceiptsInArchiveReportInputModel>(listOfPartialReceiptsInArchiveReportInputModel
                        ?? throw new ArgumentException("listOfPartialReceiptsInArchiveReportInputModel missing!"));

                    ReportGridWithSummaryGridResponseModel<ListOfPartialReceiptsInArchiveReportCombined, ListOfPartialReceiptsInArchiveReport> listOfPartialReceiptsInArchiveReport = await _reportService.GetListOfPartialReceiptsInArchiveReport(token, listOfPartialReceiptsInArchiveReportRequestModel);
                    return listOfPartialReceiptsInArchiveReport.Items!.Cast<object>().ToList();
                case BusinessObjectReportType.UserActionsJournalReport:
                    var userActionsJournalReportInputModel = JsonSerializer.Deserialize<UserActionsJournalReportInputModel>(exportOptions);
                    var userActionsJournalReportRequestModel = new ReportGridRequestModel<UserActionsJournalReportInputModel>(userActionsJournalReportInputModel
                        ?? throw new ArgumentException("userActionsJournalReportInputModel missing!"));

                    ReportGridResponseModel<UserActionsJournalReport> userActionsJournalReport = await _reportService.GetUserActionsJournalReport(token, userActionsJournalReportRequestModel);
                    return userActionsJournalReport.Items!.Cast<object>().ToList();

                case BusinessObjectReportType.WorkDoneOnDigitalObjectsReport:
                    var workDoneOnDigitalObjectsInputModel = JsonSerializer.Deserialize<WorkDoneOnDigitalObjectsReportInputModel>(exportOptions);
                    var workDoneOnDigitalObjectsRequestModel = new ReportGridRequestModel<WorkDoneOnDigitalObjectsReportInputModel>(workDoneOnDigitalObjectsInputModel
                        ?? throw new ArgumentException("workDoneOnDigitalObjectsInputModel missing!"));

                    ReportGridResponseModel<WorkDoneOnDigitalObjectsReport> workDoneOnDigitalObjects = await _reportService.GetWorkDoneOnDigitalObjectsReport(token, workDoneOnDigitalObjectsRequestModel);
                    return workDoneOnDigitalObjects.Items!.Cast<object>().ToList();
                default:
                    throw new ArgumentException("Report subject unknown");
            }
        }

        private string ExportDatatableToHtml(GridExportModel model)
        {
            string fontSize = String.Empty;
            //При необходимост може да се стилизира според броя на колонките
            switch (model.Columns!.Count)
            {
                case <= 8:
                    fontSize = "medium";
                    break;
                case <= 13:
                    fontSize = "0.700em";
                    break;
                case > 13:
                    fontSize = "smaller";
                    break;
                default:
                    break;
            }

            DataTable dt = new();

            //Започва създаването на html съдържанието с цел да се използват циклите за create-a !
            StringBuilder strHTMLBuilder = new();
            strHTMLBuilder.Append($"<table border='1px' cellpadding=\"0\" cellspacing='0' bgcolor='white' cellspacing=\"0\" style='font-size:{fontSize}; border-collapse: collapse; mso-padding-alt: 0cm 5.4pt 0cm 5.4pt'><tbody>");
            strHTMLBuilder.Append("<tr>");

            //Добавяне на имента на колонките
            foreach (var item in model.Columns!)
            {
                dt.Columns.Add(item.Title);
                strHTMLBuilder.Append("<td style='border: solid black 0.5pt; mso-border-top-alt: solid black 0.5pt;'>");
                strHTMLBuilder.Append(item.Title);
                strHTMLBuilder.Append("</td>");
            }

            strHTMLBuilder.Append("</tr>");

            for (int i = 0; i < model.Data!.Count; i++)
            {
                strHTMLBuilder.Append("<tr>");
                var dr = dt.Rows.Add();

                for (int j = 0; j < model.Columns.Count; j++)
                {
                    Type myType = model.Data[i].GetType();
                    strHTMLBuilder.Append($"<td style='font-size:{fontSize}; border: solid black 0.5pt'>");
                    IList<PropertyInfo> props = new List<PropertyInfo>(myType.GetProperties());

                    foreach (PropertyInfo prop in props)
                    {
                        object propValue = prop.GetValue(model.Data[i], null);
                        
                        if (prop.Name.ToLower() == model.Columns[j].Prop.ToLower())
                        {
                            dr[model.Columns[j].Title] = propValue;
                            strHTMLBuilder.Append(dr[model.Columns[j].Title].ToString());
                        }
                    }
                    strHTMLBuilder.Append("</td>");
                }
                strHTMLBuilder.Append("</tr>");
            }
            strHTMLBuilder.Append("</tbody></table>");
            return strHTMLBuilder.ToString();
        }

        public async  Task<string> ExportGridDataToWord(GridExportModel model)
        {
            return  ExportDatatableToHtml(model);
        }
    }
}

