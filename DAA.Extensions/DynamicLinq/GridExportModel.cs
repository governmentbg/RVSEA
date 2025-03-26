using DAA.Models.Grid;

namespace DAA.Extensions.DynamicLinq
{
    public class GridExportModel
    {
        public List<GridColumnExportModel>? Columns { get; set; }
        public List<object>? Data { get; set; }
        public string? BusinessObjectType { get; set; }
        public DataSourceRequestModel? Options { get; set; }
        public object? ExportOptions { get; set; }
        public object? BusinessObjectParams { get; set; }
        public string? FileType { get; set; }
    }
}
