using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Data.RemoteDBEntities
{
    [Keyless]
    public class InventoryDisplayModel
    {
        public int? Id { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ArchiveCode { get; set; }
        public string? ArchiveName { get; set; }
        public bool? FundHasExternalSource { get; set; }
        public int? FundExternalIdentifier { get; set; }
        public string? FundNumber { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool? HasExternalSource { get; set; }
        public string? NumberArray { get; set; }
        public int? NumberNumeric { get; set; }
        public string? Number { get; set; }
        public string? DescriptionLevelCode { get; set; }
        public string? DescriptionLevelText { get; set; }
        public string? StatusCode { get; set; }
        public string? StatusText { get; set; }
        public int? AvailabilityStatusCode { get; set; }
        public string? AvailabilityStatusText { get; set; }
        public string? AcquisitionMethodText { get; set; }
        public string? CreationMethodText { get; set; }
        public string? OriginalityText { get; set; }
        public string? LanguageText { get; set; }
        public bool HasNoChronologicalScope { get; set; }
        public int? StartDateYear { get; set; }
        public int? StartDateMonth { get; set; }
        public int? StartDateDay { get; set; }
        public int? EndDateYear { get; set; }
        public int? EndDateMonth { get; set; }
        public int? EndDateDay { get; set; }
        public string? ApproxmateChronologicalScope { get; set; }
        public double? LinearMeters { get; set; }
        public string? OtherMetrics { get; set; }
        public int? ArchivalEntityCount { get; set; }
        public int? BoxCount { get; set; }
        public int? RollCount { get; set; }
        public int? AudioDocumentArchivalEntityCount { get; set; }
        public int? PhotoDocumentArchivalEntityCount { get; set; }
        public int? VideoDocumentArchivalEntityCount { get; set; }
        public int? DigitalDocumentArchivalEntityCount { get; set; }
        public string? FundCreatorTitleHistory { get; set; }
        public string? FundCreatorBiographicalHistory { get; set; }
        public string? History { get; set; }
        public string? DocumentsProvider { get; set; }
        public string? DocumentsDescription { get; set; }
        public string? DocumentsAccessDescription { get; set; }
        public string? ClassificationScheme { get; set; }
        public string? AbbreviationList { get; set; }
        public int? MicrofilmedArchivalEntityCount { get; set; }
        public int? DigitizedArchivalEntityCount { get; set; }
        public int? NegativeFrameCount { get; set; }
        public int? PositiveFrameCount { get; set; }
        public string? Notes { get; set; }
        public DateTime? CreatedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public string? CreatedByDisplayName { get; set; }
        public string? UpdatedByDisplayName { get; set; }
        public double? EnrolledLinearMeters { get; set; }
        public double? DeductedLinearMeters { get; set; }
        public int? EnrolledAECount { get; set; }
        public int? DeductedAECount { get; set; }
        public long? EnrolledBytes { get; set; }
        public long? DeductedBytes { get; set; }

    }
}
