using DAA.Extensions.Controller;
using DAA.Extensions.DynamicLinq;
using DAA.Shared;
using DAA.Shared.Localization;
using DocFlow.Models.File;
using DocFlow.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using System.Diagnostics.CodeAnalysis;


namespace DAA.Web.Public.Controllers
{
    [ApiExplorerSettings(IgnoreApi = true)]
    [Route("api/[controller]")]
    [ApiController]
    public class GridController : BaseApiController
    {
        private readonly IExportService _exportService;

        public GridController(
            IStringLocalizer<SharedResources> localizer,
            ILogger<BaseApiController> logger,
            IExportService exportService)
            : base(localizer, logger)
        {
            _exportService = exportService;
        }

        [HttpPost("exportCurrentPage")]
        public IActionResult ExportCurrentPage(GridExportModel model)
        {
            try
            {
                FileDownloadModel file = _exportService.ExportGridData(model, "Grid");
                return Ok(file);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"ERROR exporting grid");
                return InternalServerError();
            }
        }

        [HttpPost("exportAll")]
        public async Task<IActionResult> ExportAll(GridExportModel model)
        {
            try
            {
                var data = await _exportService.GetGridDataForExport(model.BusinessObjectType, model.Options!, model.BusinessObjectParams, model.ExportOptions);

                model.Data = data;

                if (model.FileType == ExportFileType.Word)
                {
                    var html = _exportService.ExportGridDataToWord(model);

                    return Ok(html);
                }

                FileDownloadModel file = _exportService.ExportGridData(model, "Grid");
                return Ok(file);
            }
            catch (ArgumentException ex)
            {
                _logger.LogError(ex, $"ERROR exporting grid - wrong model data");
                return BadRequest($"ERROR exporting grid - wrong model data");
            } 
            catch (Exception ex)
            {
                _logger.LogError(ex, $"ERROR exporting grid");
                return InternalServerError();
            }
        }
    }
}
