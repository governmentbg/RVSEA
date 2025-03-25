using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Data
{
    [Keyless]
    public class NumberOfDocumentsOrderedByEmployeeReport
    {
		public string? Employee { get; set; }
		public string? Archive { get; set; }
		public string? FundLevelOfDescription { get; set; }
		public string? Fund { get; set; }
		public string? Inventory { get; set; }
		public string? ArchiveEntity { get; set; }
		public string? Document { get; set; }
		public DateTime? AccessDate { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool? HasExternalSource { get; set; }
        public string? InventoryNumber { get; set; }
        public string? ArchivalEntityNumber { get; set; }
        public string? DocumentNumber { get; set; }
    }
}
