using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Data
{
    [Keyless]
    public class ListOfRoughDocumentsReport
    {
        public string? CountryCode { get; set; }
        public string? Archive { get; set; }
        public string? FundNumber { get; set; }
        public string? FundTitle { get; set; }
        public DateTime? EntryDate { get; set; }
        public string? RoughInventoryNumber { get; set; }
        public string? AcquisitionMethod { get; set; }
        public string? Status { get; set; }
        public decimal? LinearMeters { get; set; }
        public long Bytes { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}
