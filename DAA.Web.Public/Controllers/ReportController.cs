using DAA.Data;
using DAA.Extensions.Controller;
using DAA.Models.Reports;
using DAA.Services.Admin;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Public.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReportController : BaseApiController
    {
        private readonly IReportService _reportService;
        private new readonly ILogger<AccountController> _logger;

        public ReportController(
            IStringLocalizer<SharedResources> localizer,
            IReportService reportService,
            ILogger<AccountController> logger
        )         
            :base(localizer)
        {
            _reportService = reportService;
            _logger = logger;
        }

        [HttpPost("funds")]
        public async Task<IActionResult> GetFundsPublicReport(CancellationToken token, ReportGridRequestModel<FundPublicReportInputModel> model)
        {
            ReportGridResponseModel<FundPublicReport> report;
            try
            {
                report = await _reportService.GetFundsPublicReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_FundsPublicReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            return Success(report, report.Message);
        }

        [HttpPost("fundsData")]
        public async Task<IActionResult> GetFundsDataPublicReport(CancellationToken token, ReportGridRequestModel<FundDataPublicReportInputModel> model)
        {
            ReportGridResponseModel<FundDataPublicReport> report;
            try
            {
                report = await _reportService.GetFundsDataPublicReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_FundsDataPublicReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            return Success(report, report.Message);
        }

        [HttpPost("fundMemories")]
        public async Task<IActionResult> GetFundMemoriesPublicReport(CancellationToken token, ReportGridRequestModel<ListPublicReportInputModel> model)
        {
            ReportGridResponseModel<FundMemoryPublicReport> report;
            try
            {
                report = await _reportService.GetFundMemoriesPublicReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_FundMemoriesPublicReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            return Success(report, report.Message);
        }

        [HttpPost("registerOfDigitalObjects")]
        public async Task<IActionResult> GetRegisterOfDigitalObjectsPublicReport(CancellationToken token, ReportGridRequestModel<RegisterOfDigitalObjectsPublicReportInputModel> model)
        {
            ReportGridResponseModel<RegisterOfDigitalObjectsPublicReport> report;
            try
            {
                report = await _reportService.GetRegisterOfDigitalObjectsPublicReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_RegisterOfDigitalObjectsPublicReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            return Success(report, report.Message);
        }

        [HttpPost("registerOfDigitalObjectsSummary")]
        public async Task<IActionResult> GetRegisterOfDigitalObjectsPublicReportSummary(CancellationToken token, ReportGridRequestModel<RegisterOfDigitalObjectsPublicReportInputModel> model)
        {
            ReportGridResponseModel<RegisterOfDigitalObjectsPublicReport> report;
            try
            {
                report = await _reportService.GetRegisterOfDigitalObjectsPublicReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_RegisterOfDigitalObjectsPublicReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            return Success(report, report.Message);
        }

        [HttpPost("partialReceipts")]
        public async Task<IActionResult> GetPartialReceiptsPublicReport(CancellationToken token, ReportGridRequestModel<PartialReceiptsPublicReportInputModel> model)
        {
            ReportGridResponseModel<PartialReceiptsPublicReport> report;
            try
            {
                report = await _reportService.GetPartialReceiptsPublicReport(token, model);
            }
            catch (OperationCanceledException ex)
            {
                return Success();
            }
            catch (Exception e)
            {
                _logger.LogError(e, _localizer.GetString("Error_PartialReceiptsPublicReport"));
                return InternalServerError(_localizer.GetString("Error_ReportLoading"));
            }

            return Success(report, report.Message);
        }

        [HttpPost("fundsList")]
        public async Task<IActionResult> GetFundsListReport(CancellationToken token, ReportGridRequestModel<ListPublicReportInputModel> model)
        {
            ReportGridResponseModel<FundsListPublicReport> report;
            try
            {
                report = await _reportService.GetFundsListReport(token, model);
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
    }
}
