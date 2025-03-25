using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class InventoryDraftsTestKalin
    {
        public int Id { get; set; }
        public Guid SystemIdentifier { get; set; }
        public int? ArchivalEntityCount { get; set; }
        public DateTime? CreatedOn { get; set; }
        public string? Number { get; set; }
        public int? StartDateYear { get; set; }
        public int? EndDateYear { get; set; }
        public double? LinearMeters { get; set; }
    }
}
