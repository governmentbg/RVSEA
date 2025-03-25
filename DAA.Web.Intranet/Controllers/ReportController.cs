using DAA.Data;
using DAA.Extensions.Controller;
using DAA.Extensions.Exceptions;
using DAA.Models.Reports;
using DAA.Services.Admin;
using DAA.Services.Inventories;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Intranet.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReportController : BaseApiController
    {
        private const string TimeoutMessage = "Timeout";
        private readonly IInventoryService _inventoryService;
        private readonly IReportService _reportService;


        public ReportController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<AccountController> logger,
            IInventoryService inventoryService,
            IUserInfo userInfo,
            IReportService reportService
        )
            : base(localizer, logger, userInfo)
        {
            _reportService = reportService;
            _inventoryService = inventoryService;
        }

        [HttpPost("funds")]
        public async Task<IActionResult> GetFundsReport(CancellationToken token, ReportGridRequestModel<FundPublicReportInputModel> model)
        {
            ReportGridResponseModel<FundInternalReport> report;
            try
            {
                report = await _reportService.GetFundsInternalReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_FundsPrivateReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("fundsAvailability")]
        public async Task<IActionResult> GetFundAvailabilityReport(CancellationToken token, ReportGridRequestModel<FundAvailabilityReportInputModel> model)
        {
            ReportGridResponseModel<FundAvailabilityReport> report;
            try
            {
                report = await _reportService.GetFundAvailabilityReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_FundAvailabilityReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("fundsList")]
        public async Task<IActionResult> GetFundsListReport(CancellationToken token, ReportGridRequestModel<ListReportInputModel> model)
        {
            ReportGridResponseModel<FundsListReport> report;
            try
            {
                report = await _reportService.GetFundsListInternalReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_FundsListReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("fundMemoriesListInternalReport")]
        public async Task<IActionResult> GetFundMemoriesListInternalReport(CancellationToken token, ReportGridRequestModel<FundMemoriesListInternalReportFiltersModel> model)
        {
            ReportGridResponseModel<FundMemoriesListInternalReport> report;
            try
            {
                report = await _reportService.GetFundMemoriesListInternalReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_FundMemoriesListInternalReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("fundMemoriesList")]
        public async Task<IActionResult> GetFundMemoriesListReport(CancellationToken token, ReportGridRequestModel<ListReportInputModel> model)
        {
            ReportGridResponseModel<FundMemoriesListReport> report;
            try
            {
                report = await _reportService.GetFundMemoriesListReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_FundMemoriesListReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("partialReceiptsList")]
        public async Task<IActionResult> GetPartialReceiptsListReport(CancellationToken token, ReportGridRequestModel<ListReportInputModel> model)
        {
            ReportGridResponseModel<PartialReceiptsListReport> report;
            try
            {
                report = await _reportService.GetPartialReceiptsListReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_PartialReceiptsListReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("receiptsList")]
        public async Task<IActionResult> GetReceiptsListReport(CancellationToken token, ReportGridRequestModel<ReceiptsListReportInputModel> model)
        {
            ReportGridResponseModel<ReceiptsListReport> report;
            try
            {
                report = await _reportService.GetReceiptsListReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_ReceiptsListReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("workListForPriorityRestoration")]
        public async Task<IActionResult> GetWorkListForPriorityRestorationReport(CancellationToken token, ReportGridRequestModel<ListReportInputModel> model)
        {
            ReportGridResponseModel<WorkListForPriorityRestorationReport> report;
            try
            {
                report = await _reportService.GetWorkListForPriorityRestorationReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_WorkListForPriorityRestorationReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("inventoryBook")]
        public async Task<IActionResult> GetInventoryBook(CancellationToken token, ReportGridRequestModel<ListReportInputModel> model)
        {
            ReportGridResponseModel<InventoryBook> report;
            try
            {
                report = await _reportService.GetInventoryBook(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_InventoryBook"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("accountAndDescriptionOfFilmDocumentsBook")]
        public async Task<IActionResult> GetAccountAndDescriptionOfFilmDocumentsBook(CancellationToken token, ReportGridRequestModel<ListReportInputModel> model)
        {
            ReportGridResponseModel<AccountAndDescriptionOfFilmDocumentsBook> report;
            try
            {
                report = await _reportService.GetAccountAndDescriptionOfFilmDocumentsBook(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_AccountAndDescriptionOfFilmDocumentsBook"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("insuranceFundOfCopiesOfForeignArchives")]
        public async Task<IActionResult> GetInsuranceFundOfCopiesOfForeignArchives(CancellationToken token, ReportGridRequestModel<ListReportInputModel> model)
        {
            ReportGridResponseModel<InsuranceFundOfCopiesOfForeignArchives> report;
            try
            {
                report = await _reportService.GetInsuranceFundOfCopiesOfForeignArchives(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_InsuranceFundOfCopiesOfForeignArchives"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно ???

            return Success(report, message);
        }

        [HttpPost("inventoryBookOfCopiesFromForeignArchives")]
        public async Task<IActionResult> GetInventoryBookOfCopiesFromForeignArchives(CancellationToken token, ReportGridRequestModel<ListReportInputModel> model)
        {
            ReportGridResponseModel<InventoryBookOfCopiesFromForeignArchives> report;

            try
            {
                report = await _reportService.GetInventoryBookOfCopiesFromForeignArchives(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_InventoryBookOfCopiesFromForeignArchives"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("compilationAndNTOOfEDocuments")]
        public async Task<IActionResult> GetCompilationAndNTOOfEDocuments(CancellationToken token, ReportGridRequestModel<CompilationAndNTOOfEDocumentsInputModel> model)
        {
            ReportGridResponseModel<CompilationAndNTOOfEDocumentsReport> report;

            try
            {
                report = await _reportService.GetCompilationAndNTOOfEDocuments(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                e.GetType();
                _logger.LogError(e, _localizer.GetString("Error_CompilationAndNTOOfEDocuments"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("registerOfDigitizedDocumentsReportSummary")]
        public async Task<IActionResult> GetRegisterOfDigitizedDocumentsReportSummary(CancellationToken token, ReportGridRequestModel<RegisterOfDigitizedDocumentsReportInputModel> model)
        {
            RegisterOfDigitizedDocumentsSummaryAndCombined report;

            try
            {
                report = await _reportService.GetRegisterOfDigitizedDocumentsReportSummary(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_RegisterOfDigitizedDocumentsReportSummary"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            return Success(report);
        }

        [HttpPost("registerOfDigitizedDocumentsReport")]
        public async Task<IActionResult> GetRegisterOfDigitizedDocumentsReport(CancellationToken token, ReportGridRequestModel<RegisterOfDigitizedDocumentsReportInputModel> model)
        {
            ReportGridResponseModel<RegisterOfDigitizedDocumentsReport> report;

            try
            {
                report = await _reportService.GetRegisterOfDigitizedDocumentsReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_RegisterOfDigitizedDocumentsReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("countOfUsedCopiesOfDocumentsFromForeignArchivesReport")]
        public async Task<IActionResult> GetCountOfUsedCopiesOfDocumentsFromForeignArchivesReport(CancellationToken token, ReportGridRequestModel<CountOfUsedCopiesOfDocumentsFromForeignArchivesReportInputModel> model)
        {
            ReportGridResponseModel<CountOfUsedCopiesOfDocumentsFromForeignArchivesReport> report;
            try
            {
                report = await _reportService.GetCountOfUsedCopiesOfDocumentsFromForeignArchivesReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_CountOfUsedCopiesOfDocumentsFromForeignArchivesReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("qualityControlReport")]
        public async Task<IActionResult> GetQualityControlReport(CancellationToken token, ReportGridRequestModel<WorkDoneOnDigitalObjectsCombinedReportInputModel> model)
        {
            ReportGridWithSummaryGridResponseModel<QualityControlCombined, QualityControlReport> report;
            try
            {
                report = await _reportService.GetQualityControlReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_QualityControlReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }
            return Ok(report);
        }

        [HttpPost("digitalObjectsPreparationReport")]
        public async Task<IActionResult> GetDigitalObjectsPreparationReport(CancellationToken token, ReportGridRequestModel<WorkDoneOnDigitalObjectsCombinedReportInputModel> model)
        {
            ReportGridWithSummaryGridResponseModel<DigitalObjectsPreparationCombined, DigitalObjectsPreparationReport> report;
            try
            {
                report = await _reportService.GetDigitalObjectsPreparationReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_DigitalObjectsPreparationReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }
            return Ok(report);
        }

        [HttpPost("specialRegistrationListReport")]
        public async Task<IActionResult> GetSpecialRegistrationListReport(CancellationToken token, ReportGridRequestModel<SpecialRegistrationListReportInputModel> model)
        {
            ReportGridResponseModel<SpecialRegistrationListReport> report;
            try
            {
                report = await _reportService.GetSpecialRegistrationListReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_SpecialRegistrationListReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("numberOfArchiveEntitiesOrderedByReaderReport")]
        public async Task<IActionResult> GetNumberOfArchiveEntitiesOrderedByReaderReport(ReportGridRequestModel<NumberOfArchiveEntitiesOrderedByReaderInputModel> model)
        {
            ReportGridResponseModel<NumberOfArchiveEntitiesOrderedByReaderReport> report;
            try
            {
                report = await _reportService.GetNumberOfArchiveEntitiesOrderedByReaderReport(model);
                ;
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_NumberOfArchiveEntitiesOrderedByReaderReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }
            return Ok(report);
        }

        [HttpPost("numberOfArchiveEntitiesOrderedByEmployeeReport")]
        public async Task<IActionResult> GetNumberOfArchiveEntitiesOrderedByEmployeeReport(ReportGridRequestModel<NumberOfArchiveEntitiesOrderedByEmployeeInputModel> model)
        {
            ReportGridResponseModel<NumberOfArchiveEntitiesOrderedByEmployeeReport> report;
            try
            {
                report = await _reportService.GetNumberOfArchiveEntitiesOrderedByEmployeeReport(model);
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_NumberOfArchiveEntitiesOrderedByEmployeeReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("mostUsedRequestEntitiesReport")]
        public async Task<IActionResult> GetMostUsedRequestEntitiesReport(CancellationToken token, ReportGridRequestModel<MostUsedRequestEntitiesReportInputModel> model)
        {
            ReportGridResponseModel<MostUsedRequestEntitiesReport> report;
            try
            {
                report = await _reportService.GetMostUsedRequestEntitiesReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_GetMostUsedRequestEntitiesReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("numberOfDocumentsOrderedByReaderReport")]
        public async Task<IActionResult> GetNumberOfDocumentsOrderedByReaderReport(CancellationToken token, ReportGridRequestModel<NumberOfDocumentsOrderedByReaderReportInputModel> model)
        {
            ReportGridResponseModel<NumberOfDocumentsOrderedByReaderReport> report;
            try
            {
                report = await _reportService.GeNumberOfDocumentsOrderedByReaderReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_NumberOfDocumentsOrderedByReaderReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }
            return Ok(report);
        }
        [HttpPost("numberOfDocumentsOrderedByEmployeeReport")]
        public async Task<IActionResult> GetNumberOfDocumentsOrderedByEmployeeReport(CancellationToken token, ReportGridRequestModel<NumberOfDocumentsOrderedByEmployeeReportInputModel> model)
        {
            ReportGridResponseModel<NumberOfDocumentsOrderedByEmployeeReport> report;
            try
            {
                report = await _reportService.GeNumberOfDocumentsOrderedByEmployeeReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_NumberOfDocumentsOrderedByEmployeeReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }
            return Ok(report);
        }


        [HttpPost("activeProcesses")]
        public async Task<IActionResult> GetActiveProcessesReport(CancellationToken token, ReportGridRequestModel<ActiveProcessesReportInputModel> model)
        {
            ReportGridResponseModel<ActiveProcessesReport> report;
            try
            {
                report = await _reportService.GetActiveProcessesReport(token, model);
            }
            catch (DBRequestTimeoutException)
            {
                _logger.LogWarning("DB request timedout");

                return InternalServerError(TimeoutMessage);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_GetActiveProcessesReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("inventoryReport")]
        public async Task<IActionResult> GetInventoryReport(CancellationToken token, ReportGridRequestModel<InventoryReportInputModel> model)
        {
            ReportGridResponseModel<InventoryReport> report;
            try
            {
                report = await _reportService.GetInventoryReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_InventoryReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("digitalDocumentsUsage")]
        public async Task<IActionResult> GetDigitalDocumentsUsageReport(CancellationToken token, ReportGridRequestModel<DigitalDocumentsUsageReportInputModel> model)
        {
            ReportGridResponseModel<DigitalDocumentsUsageReport> report;
            try
            {
                report = await _reportService.GetDigitalDocumentsUsageReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_DigitalDocumentsUsageReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }
            return Ok(report);
        }

        [HttpPost("listOfRoughDocumentsReport")]
        public async Task<IActionResult> GetListOfRoughDocumentsReport(CancellationToken token, ReportGridRequestModel<ListOfRoughDocumentsReportInputModel> model)
        {
            ReportGridResponseModel<ListOfRoughDocumentsReport> report;
            try
            {
                report = await _reportService.GetListOfRoughDocumentsReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_ListOfRoughDocumentsReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }
            return Ok(report);
        }

        [HttpPost("listOfPartialReceiptsInArchiveReport")]
        public async Task<IActionResult> GetListOfPartialReceiptsInArchiveReport(CancellationToken token, ReportGridRequestModel<ListOfPartialReceiptsInArchiveReportInputModel> model)
        {
            ReportGridResponseModel<ListOfPartialReceiptsInArchiveReport> report;
            try
            {
                report = await _reportService.GetListOfPartialReceiptsInArchiveReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_ListOfPartialReceiptsInArchiveReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("userActionsJournalReport")]
        public async Task<IActionResult> GetUserActionsJournalReport(CancellationToken token, ReportGridRequestModel<UserActionsJournalReportInputModel> model)
        {
            ReportGridResponseModel<UserActionsJournalReport> report;
            try
            {
                report = await _reportService.GetUserActionsJournalReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_UserActionsJournalReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            var message = report.Message;
            report.Message = null; // вече е излишно

            return Success(report, message);
        }

        [HttpPost("cardForm1Data")]
        public async Task<IActionResult> GetCardForm1Data(ReportGridRequestModel<CardForm1DataInputModel> model)
        {
            ReportGridWithSummaryGridResponseModel<CardForm1SummaryExternalData, CardForm1Data> report;
            try
            {
                report = await _reportService.GetCardForm1Data(model);
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_CardForm1"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }
            return Ok(report);
        }

        [HttpPost("cardForm1AData")]
        public async Task<IActionResult> GetCardForm1AData(ReportGridRequestModel<CardForm1DataInputModel> model)
        {
            ReportGridWithSummaryGridResponseModel<CardForm1SummaryExternalData, CardForm1Data> report;
            if (model.Filters.HasExternalSource && model.Filters.ExternalIdentifier.HasValue)
            {
                var inventory = await _inventoryService.GetFromExternalSourceAsync(model.Filters.ExternalIdentifier.Value);

                try
                {

                    report = await _reportService.GetCardForm1AData(model, inventory.FundExternalIdentifier.Value);
                }
                catch (Exception e)
                {
                    _logger.LogError(e, _localizer.GetString("Error_CardForm1"));
                    return InternalServerError(_localizer.GetString("Error_ReportLoading"));
                }
                return Ok(report);
            }
            else 
            {
                try
                {
                    report = await _reportService.GetCardForm1AData(model, null);
                }
                catch (Exception e)
                {
                    _logger.LogError(e, _localizer.GetString("Error_CardForm1"));
                    return InternalServerError(_localizer.GetString("Error_ReportLoading"));
                }
                return Ok(report);
            }
        }

        [HttpPost("fundsData")]
        public async Task<IActionResult> GetFundsDataReport(CancellationToken token, ReportGridRequestModel<FundDataInternalReportInputModel> model)
        {
            ReportGridResponseModel<FundDataInternalReport> report;
            try
            {
                report = await _reportService.GetFundsDataInernalReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_FundsDataInternalReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            return Success(report, report.Message);
        }


        [HttpPost("workDoneOnDigitalObjects")]
        public async Task<IActionResult> GetWorkDoneOnDigitalObjectsReport(CancellationToken token, ReportGridRequestModel<WorkDoneOnDigitalObjectsReportInputModel> model)
        {
            ReportGridResponseModel<WorkDoneOnDigitalObjectsReport> report;
            try
            {
                report = await _reportService.GetWorkDoneOnDigitalObjectsReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_WorkDoneOnDigitalObjectsReport"));
                return InternalServerError();
            }

            return Success(report, report.Message);
        }
    }
}
