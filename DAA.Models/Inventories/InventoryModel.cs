using DAA.Models.Inventories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Inventories
{
    public class InventoryModel
    {
        public int? Id { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int ArchiveId { get; set; }
        public int? FundDraftId { get; set; }
        public Guid? FundSystemIdentifier { get; set; }
        public int? FundExternalIdentifier { get; set; }
        public bool FundHasExternalSource { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public string? NumberArray { get; set; }
        public int? NumberNumeric { get; set; }
        public string? Number { get; set; }
        //public string? Title { get; set; }
        public string DescriptionLevelCode { get; set; } = null!;
        public int? AvailabilityStatusCode { get; set; }
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
        public int? ArchivalEntityCount { get; set; }
        public int? DocumentCount { get; set; }
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
        public int? ApplicationId { get; set; }
        public int? PackageAId { get; set; }
        public int? PackageBId { get; set; }
        public int? PackageCId { get; set; }
        public string? OtherLanguage { get; set; }

        //public IEnumerable<string>? AcquisitionMethodCodes { get; set; }
        public IEnumerable<string>? FileTypeCodes { get; set; }
        public IEnumerable<string>? OriginalityCodes { get; set; }
        public IEnumerable<string>? CreationMethodCodes { get; set; }
        public IEnumerable<string>? LanguageCodes { get; set; }

        public void Assign(InventoryModel obj, bool newObject = false)
        {
            if (!newObject)
            { 
                Id = obj.Id;
                SystemIdentifier = obj.SystemIdentifier;
            }
            ArchiveId = obj.ArchiveId;
            FundDraftId = obj.FundDraftId;
            FundSystemIdentifier = obj.FundSystemIdentifier;
            FundExternalIdentifier = obj.FundExternalIdentifier;
            FundHasExternalSource = obj.FundHasExternalSource;
            ExternalIdentifier = obj.ExternalIdentifier;
            HasExternalSource = obj.HasExternalSource;
            NumberArray = obj.NumberArray;
            NumberNumeric = obj.NumberNumeric;
            Number = obj.Number;
            DescriptionLevelCode = obj.DescriptionLevelCode;
            AvailabilityStatusCode = obj.AvailabilityStatusCode;
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
            ArchivalEntityCount = obj.ArchivalEntityCount;
            DocumentCount = obj.DocumentCount;
            BoxCount = obj.BoxCount;
            RollCount = obj.RollCount;
            AudioDocumentArchivalEntityCount = obj.AudioDocumentArchivalEntityCount;
            PhotoDocumentArchivalEntityCount = obj.PhotoDocumentArchivalEntityCount;
            VideoDocumentArchivalEntityCount = obj.VideoDocumentArchivalEntityCount;
            DigitalDocumentArchivalEntityCount = obj.DigitalDocumentArchivalEntityCount;
            FundCreatorTitleHistory = obj.FundCreatorTitleHistory;
            FundCreatorBiographicalHistory = obj.FundCreatorBiographicalHistory;
            History = obj.History;
            DocumentsProvider = obj.DocumentsProvider;
            DocumentsDescription = obj.DocumentsDescription;
            DocumentsAccessDescription = obj.DocumentsAccessDescription;
            ClassificationScheme = obj.ClassificationScheme;
            AbbreviationList = obj.AbbreviationList;
            MicrofilmedArchivalEntityCount = obj.MicrofilmedArchivalEntityCount;
            DigitizedArchivalEntityCount = obj.DigitizedArchivalEntityCount;
            NegativeFrameCount = obj.NegativeFrameCount;
            PositiveFrameCount = obj.PositiveFrameCount;
            Notes = obj.Notes;
            ApplicationId = obj.ApplicationId;
            PackageAId = obj.PackageAId;
            PackageBId = obj.PackageBId;
            PackageCId = obj.PackageCId;

            FileTypeCodes = obj.FileTypeCodes;
            OriginalityCodes = obj.OriginalityCodes;
            CreationMethodCodes = obj.CreationMethodCodes;
            LanguageCodes = obj.LanguageCodes;
        }
    }
}
