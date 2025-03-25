using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Data.RemoteDBEntities
{
    [Keyless]
    public class FundDisplayModel
    {
        public int? Id { get; set; }
        public int? ArchiveCode { get; set; }
        public string? ArchiveName { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public string? NumberArray { get; set; }
        public int? NumberNumeric { get; set; }
        public string? Number { get; set; }
        public string? Title { get; set; } = null!;
        public string? DescriptionLevelCode { get; set; }
        public string? DescriptionLevelText { get; set; }
        public string? TypeText { get; set; }
        public string? StatusCode { get; set; }
        public string? StatusText { get; set; }
        public string? AcquisitionMethodText { get; set; }
        public string? IndustryTypeText { get; set; }
        //public string? FileTypeText { get; set; }
        public string? LanguageText { get; set; }
        public bool? HasNoChronologicalScope { get; set; }
        public int? StartDateYear { get; set; }
        public int? StartDateMonth { get; set; }
        public int? StartDateDay { get; set; }
        public int? EndDateYear { get; set; }
        public int? EndDateMonth { get; set; }
        public int? EndDateDay { get; set; }
        public string? ApproxmateChronologicalScope { get; set; }
        //public long? Bytes { get; set; }
        public double? LinearMeters { get; set; }
        public string? OtherMetrics { get; set; }
        public int? InventoryCount { get; set; }
        public int? ArchivalEntityCount { get; set; }
        //public long? DocumentCount { get; set; }
        public string? FundCreatorTitleHistory { get; set; }
        public string? FundCreatorActivityHistory { get; set; }
        public string? FundCreatorBiographicalHistory { get; set; }
        public string? DocumentsProvider { get; set; }
        public string? DocumentsDescription { get; set; }
        //public string? ValuableDocumentsInventoryCount { get; set; }
        //public string? InvaluableDocumentsInventoryCount { get; set; }
        public string? DocumentsAccessDescription { get; set; }
        public string? History { get; set; }
        public string? RelatedFunds { get; set; }
        public string? Notes { get; set; }
        //public long? EnrolledBytes { get; set; }
        public int? EnrolledInventoryCount { get; set; }
        //public long? DeductedBytes { get; set; }
        public int? DeductedInventoryCount { get; set; }
        public DateTime? CreatedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public string? CreatedByDisplayName { get; set; }
        public string? UpdatedByDisplayName { get; set; }
    }
}
