using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Funds
{
    public class FundModel
    {
        public int? Id { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ArchiveId { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public string? NumberArray { get; set; }
        public int? NumberNumeric { get; set; }
        public string? Number { get; set; }
        public string Title { get; set; } = null!;
        public string DescriptionLevelCode { get; set; } = null!;
        public string? TypeCode { get; set; } = null!;
        public string StatusCode { get; set; } = null!;
        public int? AcquisitionMethodId { get; set; }
        public bool HasNoChronologicalScope { get; set; }
        public int? StartDateYear { get; set; }
        public int? StartDateMonth { get; set; }
        public int? StartDateDay { get; set; }
        public int? EndDateYear { get; set; }
        public int? EndDateMonth { get; set; }
        public int? EndDateDay { get; set; }
        public string? ApproxmateChronologicalScope { get; set; }
        public long? Bytes { get; set; }
        public double? LinearMeters { get; set; }
        public string? OtherMetrics { get; set; }
        public int? InventoryCount { get; set; }
        public int? ArchivalEntityCount { get; set; }
        public int? DocumentCount { get; set; }
        public string? FundCreatorTitleHistory { get; set; }
        public string? FundCreatorActivityHistory { get; set; }
        public string? FundCreatorBiographicalHistory { get; set; }
        public string? DocumentsProvider { get; set; }
        public string? DocumentsDescription { get; set; }
        public string? ValuableDocumentsInventoryCount { get; set; }
        public string? InvaluableDocumentsInventoryCount { get; set; }
        public string? DocumentsAccessDescription { get; set; }
        public string? History { get; set; }
        public string? RelatedFunds { get; set; }
        public string? Notes { get; set; }
        public long? EnrolledBytes { get; set; }
        public long? EnrolledInventoryCount { get; set; }
        public long? DeductedBytes { get; set; }
        public long? DeductedInventoryCount { get; set; }
        public int? ApplicationId { get; set; }

        //public IEnumerable<string>? AcquisitionMethodCodes { get; set; }
        public IEnumerable<string>? IndustryTypeCodes { get; set; }
        public IEnumerable<string>? FileTypeCodes { get; set; }
        public IEnumerable<string>? LanguageCodes { get; set; }

        public void Assign (FundModel obj, bool newObject = false)
        {
            if (!newObject)
            {
                Id = obj.Id;
                SystemIdentifier = obj.SystemIdentifier;
            }
            ArchiveId = obj.ArchiveId;
            ExternalIdentifier = obj.ExternalIdentifier;
            HasExternalSource = obj.HasExternalSource;
            NumberArray = obj.NumberArray;
            NumberNumeric = obj.NumberNumeric;
            Number = obj.Number;
            Title = obj.Title;
            DescriptionLevelCode = obj.DescriptionLevelCode;
            TypeCode = obj.TypeCode;
            StatusCode = obj.StatusCode;
            AcquisitionMethodId = obj.AcquisitionMethodId;
            HasNoChronologicalScope = obj.HasNoChronologicalScope;
            StartDateYear = obj.StartDateYear;
            StartDateMonth = obj.StartDateMonth;
            StartDateDay = obj.StartDateDay;
            EndDateYear = obj.EndDateYear;
            EndDateMonth = obj.EndDateMonth;
            EndDateDay = obj.EndDateDay;
            ApproxmateChronologicalScope = obj.ApproxmateChronologicalScope;
            Bytes = obj.Bytes;
            LinearMeters = obj.LinearMeters;
            OtherMetrics = obj.OtherMetrics;
            InventoryCount = obj.InventoryCount;
            ArchivalEntityCount = obj.ArchivalEntityCount;
            DocumentCount = obj.DocumentCount;
            FundCreatorTitleHistory = obj.FundCreatorTitleHistory;
            FundCreatorActivityHistory = obj.FundCreatorActivityHistory;
            FundCreatorBiographicalHistory = obj.FundCreatorBiographicalHistory;
            DocumentsProvider = obj.DocumentsProvider;
            DocumentsDescription = obj.DocumentsDescription;
            ValuableDocumentsInventoryCount = obj.ValuableDocumentsInventoryCount;
            InvaluableDocumentsInventoryCount = obj.InvaluableDocumentsInventoryCount;
            DocumentsAccessDescription = obj.DocumentsAccessDescription;
            History = obj.History;
            RelatedFunds = obj.RelatedFunds;
            Notes = obj.Notes;
            EnrolledBytes = obj.EnrolledBytes;
            EnrolledInventoryCount = obj.EnrolledInventoryCount;
            DeductedBytes = obj.DeductedBytes;
            DeductedInventoryCount = obj.DeductedInventoryCount;
            ApplicationId = obj.ApplicationId;

            IndustryTypeCodes = obj.IndustryTypeCodes;
            FileTypeCodes = obj.FileTypeCodes;
            LanguageCodes = obj.LanguageCodes;
        }
    }
}
