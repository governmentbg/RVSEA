using DAA.Extensions.Controller;
using DAA.Models.Commission;
using DAA.Services.Admin;
using DAA.Services.CommissionReports;
using DAA.Services.Files;
using DAA.Services.Process;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;

namespace DAA.Web.Intranet.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class CommissionReportsController : BaseApiController
    {
        private readonly IProcessService _processService;
        private readonly ICommissionReportService _reportService;
        private readonly IFileService _fileService;

        public CommissionReportsController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<BaseApiController> logger,
            IUserInfo userInfo,
            IProcessService processService,
            ICommissionReportService reportService,
            IFileService fileService)
            :base(localizer, logger, userInfo)
        {
            _processService = processService;
            _reportService = reportService;
            _fileService = fileService;
        }

        [HttpPost]
        public async Task<IActionResult>Create(CommissionReportModel model)
        {
            try
            {
                var reportResult = await _reportService.CreateAsync(model);
                if (!reportResult.Succeeded)
                {
                    var message = reportResult.RawErrors
                        ? _localizer.GetString("Error_ExecutingAction").ToString()
                        : reportResult.ToString(false);
                    _logger.LogError(reportResult.ToString());
                    return BadRequest(message);
                }

                return Success(reportResult.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating EPK report{model.Id}");
                return InternalServerError();
            }
        }

        [HttpPost("files/upload")]
        public async Task<IActionResult> UploadFiles([FromForm] IFormFileCollection files, [FromQuery]int reportId)
        {
            try
            {
                var uploadResult = await _reportService.UploadReportFilesAsync(files, reportId);
                if (!uploadResult.Succeeded)
                {
                    var message = uploadResult.RawErrors
                        ? _localizer.GetString("Error_ExecutingAction").ToString()
                        : uploadResult.ToString(false);
                    _logger.LogError(uploadResult.ToString());
                    return BadRequest(message);
                }
                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc.ToString());
                return InternalServerError();
            }
        }

        [HttpPut]
        public async Task<IActionResult> Update(CommissionReportModel model)
        {
            try
            {
                var reportResult = await _reportService.UpdateAsync(model);
                if (!reportResult.Succeeded)
                {
                    var message = reportResult.RawErrors
                        ? _localizer.GetString("Error_ExecutingAction").ToString()
                        : reportResult.ToString(false);
                    _logger.LogError(reportResult.ToString());
                    return BadRequest(message);
                }

                return Success(reportResult.Data);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error creating EPK report{model.Id}");
                return InternalServerError();
            }
        }
        
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            try
            {
                return Success(await _reportService.GetByIdAsync(id));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting EPK report {id}");
                return InternalServerError();
            }
        }
        
        [HttpGet("process/{processId}")]
        public async Task<IActionResult> GetByProcessId(int processId)
        {
            try
            {
                return Success(await _reportService.GetByProcessIdAsync(processId));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting EPK report for process {processId}");
                return InternalServerError();
            }
        }

        [HttpGet("files/download/{id}")]
        public async Task<IActionResult> Download(int id, [FromQuery]int reportId, [FromQuery]int processId, bool? isInline)
        {
            try
            {
                var process = await _processService.GetProcessAsync(processId);
                if (process == null)
                {
                    _logger.LogError($"Process {processId} does not exists");
                    return BadRequest(_localizer.GetString("Error_ExecutingAction").ToString());
                }

                var reportFile = await _reportService.GetReportFileAsync(id, reportId);
                if (reportFile == null)
                {
                    _logger.LogError($"Report file {id} for report {reportId} does not exists");
                    return BadRequest(_localizer.GetString("Error_FileNotFound").ToString());
                }
                
                var file =
                    await _fileService.GetFileAsync(
                        reportFile.UncPath!,
                        process.Completed ? Shared.FileStreamLocation.Adjunct : Shared.FileStreamLocation.Buffer);
                if (file == null || file.Content == null)
                {
                    _logger.LogError($"File for report file {id} does not exists or file content is null");
                    return BadRequest(_localizer.GetString("Error_FileNotFound").ToString());
                }

                Response.Headers.Add("Content-Disposition", $"{(isInline == true ? "inline" : "attachment")}; filename={reportFile.SourceName}");
                string? extension = Path.GetExtension(reportFile.SourceName);
                string contentType =
                    extension == ".png" ? "image/png" :
                    extension == ".tif" || extension == ".tiff" ? "image/tiff" :
                    reportFile.ContentType!;
                return new FileContentResult(file.Content, contentType);
            }
            catch (Exception exc)
            {
                _logger.LogError(exc.ToString());
                return InternalServerError();
            }
        }

        [HttpGet("files")]
        public IActionResult GetFilesByReportId([FromQuery]int reportId)
        {
            try
            {
                return Success(_reportService.GetReportFilesAsync(reportId));
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting report files for report {reportId}");
                return InternalServerError();
            }
        }

        [HttpDelete("files/{id}")]
        public async Task<IActionResult> DeleteFile(int id, [FromQuery]int reportId)
        {
            try
            {
                var deleteResult = await _reportService.DeleteReportFileAsync(id, reportId);
                if (!deleteResult.Succeeded)
                {
                    var message = deleteResult.RawErrors
                        ? _localizer.GetString("Error_ExecutingAction").ToString()
                        : deleteResult.ToString(false);
                    _logger.LogError(deleteResult.ToString());
                    return BadRequest(message);
                }

                return Success();
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting EPK report {id}");
                return InternalServerError();
            }
        }


        [HttpGet("list/{archiveId}")]
        public IActionResult ListReports(int archiveId)
        {
            try
            {
                return Success(_reportService.GetReports(archiveId));

            }
            catch (Exception exc)
            {
                _logger.LogError(exc, $"Error getting report for archive {archiveId}");
                return InternalServerError();
            }
        }

    }
}
