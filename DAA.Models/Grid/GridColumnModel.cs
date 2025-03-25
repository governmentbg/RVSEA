using DAA.Shared.Attributes;

namespace DAA.Models.Grid
{
    public class GridColumnModel
    {
        public int Id { get; set; }
        public int Sort { get; set; }
        [ExportGridAttribute(false, false, true)]
        public string? Type { get; set; }
        [ExportGridAttribute(false, true, false)]
        public string? Prop { get; set; }
        public string? TextAlign { get; set; }
        public string? CellClass { get; set; }
        public string? TitleClass { get; set; }
        public bool Visible { get; set; }
        public bool Sortable { get; set; }
        public bool Filterable { get; set; }
    }
}
