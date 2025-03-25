using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Data
{
    [Keyless]
    public class UserActionsJournalReport
    {
        public string? ArchiveName { get; set; }
        public int? ArchiveCode { get; set; }
        public string? DescriptionLevel { get; set; }
        public string? Kmf { get; set; }
        public string? Fund { get; set; }
        public int? Inventory { get; set; }
        public string? ArchivalEntity { get; set; }
        public int? DocumentServiceNumber { get; set; }
        public string? Employee { get; set; }
        public DateTime? Date { get; set; }
        public string? Process { get; set; }
        public string? Steps { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}
