using DAA.Extensions.DynamicLinq;
using DocFlow.Models.File;

namespace DocFlow.Services.Interfaces
{
    public interface IExportService
    {
        FileDownloadModel ExportGridData(GridExportModel model, string fileName);
        Task<string> ExportGridDataToWord(GridExportModel model);
        Task<List<object>?> GetGridDataForExport(
            string? businessObjectType, DataSourceRequestModel options, object? BusinessObjectParams, object? exportOptions);
    }
}