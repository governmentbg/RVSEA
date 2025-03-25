using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Funds
{
    public class FundShortDisplayModel
    {
        public int? Id { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public string CalculatedIdentifier
        {
            get { return String.Concat(SystemIdentifier, "|", Id, "|", ExternalIdentifier); }
        }
        public bool IsDraft { get; set; }
        public int? ArchiveId { get; set; }
        public int? ArchiveCode { get; set; }
        public string? ArchiveName { get; set; }
        public string? NumberArray { get; set; }
        public string? Number { get; set; }
        public string? Title { get; set; }
        public string? LongTitle 
        { 
            get { return String.Concat(Number, " - ", Title); }
        }
    }
}
