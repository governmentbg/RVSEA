using System;
using System.Collections.Generic;
using System.Text;

namespace DAA.Models.Grid
{
    public class GridSettingsModel
    {
        public string DocumentTypeCode { get; set; }
        public bool ShowRowNumber { get; set; }
        public bool ShowSearch { get; set; }
        public IEnumerable<GridColumnModel> Columns { get; set; }
    }
}
