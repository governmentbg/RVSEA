using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class VFundsSearch1
    {
        public string? Idx { get; set; }
        public bool? IsDraft { get; set; }
        public string? Number { get; set; }
        public string Title { get; set; } = null!;
        public string? ApproxmateChronologicalScope { get; set; }
        public string? FundCreatorTitleHistory { get; set; }
        public string? FundCreatorActivityHistory { get; set; }
        public string? FundCreatorBiographicalHistory { get; set; }
        public string? DocumentsProvider { get; set; }
        public string? DocumentsDescription { get; set; }
        public string? DocumentsAccessDescription { get; set; }
        public string? History { get; set; }
        public string? RelatedFunds { get; set; }
        public string? Notes { get; set; }
    }
}
