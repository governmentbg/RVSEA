using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.ArchiveEntities
{
    public class ArchivalEntityShortDisplayModel
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
        public int? FundDraftId { get; set; }
        public Guid? FundSystemIdentifier { get; set; }
        public int? FundExternalIdentifier { get; set; }
        public bool FundHasExternalSource { get; set; }
        public string? FundNumber { get; set; }
        public int? InventoryDraftId { get; set; }
        public Guid? InventorySystemIdentifier { get; set; }
        public int? InventoryExternalIdentifier { get; set; }
        public bool InventoryHasExternalSource { get; set; }
        public string? InventoryNumber { get; set; }
        public string? Number { get; set; }
        public string? Title { get; set; }
        public string? ApproximateChronologicalScope { get; set; }
        public string DescriptionLevelCode { get; set; } = null!;
        public string? DescriptionLevelText { get; set; }
        public string StatusCode { get; set; } = null!;
        public string? StatusText { get; set; }
        public int? AvailabilityStatusCode { get; set; }
        public string? AvailabilityStatusText { get; set; }
    }
}
