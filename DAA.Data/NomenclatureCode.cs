using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class NomenclatureCode
    {
        public string Code { get; set; } = null!;
        public string Text { get; set; } = null!;
        public string? Description { get; set; }
        public int? SortOrder { get; set; }
    }
}
