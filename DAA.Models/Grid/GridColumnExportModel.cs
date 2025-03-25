using DAA.Shared.Attributes;

namespace DAA.Models.Grid
{
    public class GridColumnExportModel : GridColumnModel
    {
        [ExportGrid(true, false, false)]
        public string Title { get; set; }
    }
}
