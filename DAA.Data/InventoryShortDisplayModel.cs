using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Data
{
    [Keyless]
    public class InventoryShortDisplayModel
    {
        public int? Id { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public bool IsDraft { get; set; }
        public int? ArchiveId { get; set; }
        public int? ArchiveCode { get; set; }
        public string? ArchiveName { get; set; }
        public int? FundDraftId { get; set; }
        public Guid? FundSystemIdentifier { get; set; }
        public int? FundExternalIdentifier { get; set; }
        public bool FundHasExternalSource { get; set; }
        public string? FundNumber { get; set; }
        public string? NumberArray { get; set; }
        public string? Number { get; set; }
    }
}
