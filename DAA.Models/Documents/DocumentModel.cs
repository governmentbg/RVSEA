namespace DAA.Models.Documents
{
    public class DocumentModel
    {
        public int? Id { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ArchiveId { get; set; }
        public int? FundDraftId { get; set; }
        public Guid? FundSystemIdentifier { get; set; }
        public int? FundExternalIdentifier { get; set; }
        public bool FundHasExternalSource { get; set; }
        public int? InventoryDraftId { get; set; }
        public Guid? InventorySystemIdentifier { get; set; }
        public int? InventoryExternalIdentifier { get; set; }
        public bool InventoryHasExternalSource { get; set; }
        public int? InventoryAvailabilityStatusCode { get; set; }
        public int? ArchivalEntityDraftId { get; set; }
        public Guid? ArchivalEntitySystemIdentifier { get; set; }
        public int? ArchivalEntityExternalIdentifier { get; set; }
        public bool ArchivalEntityHasExternalSource { get; set; }
        public int? ArchivalEntityAvailabilityStatusCode { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool? HasExternalSource { get; set; }
        public string? Number { get; set; }
        public string? Title { get; set; }
        public string DescriptionLevelCode { get; set; } = null!;
        public string StatusCode { get; set; } = null!;
        public int? AvailabilityStatusCode { get; set; }
        public string? FileFormatCode { get; set; }
        public bool HasNoChronologicalScope { get; set; }
        public int? StartDateYear { get; set; }
        public int? StartDateMonth { get; set; }
        public int? StartDateDay { get; set; }
        public int? EndDateYear { get; set; }
        public int? EndDateMonth { get; set; }
        public int? EndDateDay { get; set; }
        public string? ApproximateChronologicalScope { get; set; }
        public string? Author { get; set; }
        public string? Location { get; set; }
        public long? Bytes { get; set; }
        public int? SheetCount { get; set; }
        public int? StartSheetNumber { get; set; }
        public int? EndSheetNumber { get; set; }
        public string? DigitalDevice { get; set; }
        public string? OtherMetrics { get; set; }
        public string? SizeCm { get; set; }
        public string? Scaling { get; set; }
        public int? Duration { get; set; }
        public string? Description { get; set; }
        public string? DocumentsAccessDescription { get; set; }
        public string? Features { get; set; }
        public int? MicrofilmedCopyCount { get; set; }
        public int? DigitizedCopyCount { get; set; }
        public int? PaperCopyCount { get; set; }
        public int? NegativeFrameCount { get; set; }
        public int? PositiveFrameCount { get; set; }
        public string? OtherCopyCount { get; set; }
        public string? Transcription { get; set; }
        public string? Notes { get; set; }
        public bool IsImported { get; set; }
        public string? DescriptionAuthor { get; set; }
        public string? Cypher { get; set; }
        public int? TextDocsCount { get; set; }
        public int? GraphicalDocsCount { get; set; }
        public string? Phase { get; set; }
        public string? Part { get; set; }
        public string? Stage { get; set; }
        public string? OtherLanguage { get; set; }
        public string? ClassificationSchemeIndex { get; set; }

        public IEnumerable<string>? CreationMethodCodes { get; set; }
        public IEnumerable<string>? OriginalityCodes { get; set; }
        public IEnumerable<string>? FileTypeCodes { get; set; }
        public IEnumerable<string>? LanguageCodes { get; set; }

        public void Assign(DocumentModel obj, bool newObject = false)
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
            InventoryDraftId = obj.InventoryDraftId;
            InventorySystemIdentifier = obj.InventorySystemIdentifier;
            InventoryExternalIdentifier = obj.InventoryExternalIdentifier;
            InventoryHasExternalSource = obj.InventoryHasExternalSource;
            InventoryAvailabilityStatusCode = obj.InventoryAvailabilityStatusCode;
            ArchivalEntityDraftId = obj.ArchivalEntityDraftId;
            ArchivalEntitySystemIdentifier = obj.ArchivalEntitySystemIdentifier;
            ArchivalEntityExternalIdentifier = obj.ArchivalEntityExternalIdentifier;
            ArchivalEntityHasExternalSource = obj.ArchivalEntityHasExternalSource;
            ArchivalEntityAvailabilityStatusCode = obj.ArchivalEntityAvailabilityStatusCode;
            ExternalIdentifier = obj.ExternalIdentifier;
            HasExternalSource = obj.HasExternalSource;
            Number = obj.Number;
            Title = obj.Title;
            DescriptionLevelCode = obj.DescriptionLevelCode;
            StatusCode = obj.StatusCode;
            AvailabilityStatusCode = obj.AvailabilityStatusCode;
            FileFormatCode = obj.FileFormatCode;
            HasNoChronologicalScope = obj.HasNoChronologicalScope;
            StartDateYear = obj.StartDateYear;
            StartDateMonth = obj.StartDateMonth;
            StartDateDay = obj.StartDateDay;
            EndDateYear = obj.EndDateYear;
            EndDateMonth = obj.EndDateMonth;
            EndDateDay = obj.EndDateDay;
            ApproximateChronologicalScope = obj.ApproximateChronologicalScope;
            Author = obj.Author;
            Location = obj.Location;
            Bytes = obj.Bytes;
            SheetCount = obj.SheetCount;
            StartSheetNumber = obj.StartSheetNumber;
            EndSheetNumber = obj.EndSheetNumber;
            DigitalDevice = obj.DigitalDevice;
            OtherMetrics = obj.OtherMetrics;
            SizeCm = obj.SizeCm;
            Scaling = obj.Scaling;
            Duration = obj.Duration;
            Description = obj.Description;
            DocumentsAccessDescription = obj.DocumentsAccessDescription;
            Features = obj.Features;
            MicrofilmedCopyCount = obj.MicrofilmedCopyCount;
            DigitizedCopyCount = obj.DigitizedCopyCount;
            PaperCopyCount = obj.PaperCopyCount;
            NegativeFrameCount = obj.NegativeFrameCount;
            PositiveFrameCount = obj.PositiveFrameCount;
            OtherCopyCount = obj.OtherCopyCount;
            Transcription = obj.Transcription;
            Notes = obj.Notes;
            IsImported = obj.IsImported;
            DescriptionAuthor = obj.DescriptionAuthor;
            Cypher = obj.Cypher;
            TextDocsCount = obj.TextDocsCount;
            GraphicalDocsCount = obj.GraphicalDocsCount;
            Phase = obj.Phase;
            Part = obj.Part;
            Stage = obj.Stage;
            OtherLanguage = obj.OtherLanguage;

            CreationMethodCodes = obj.CreationMethodCodes;
            OriginalityCodes = obj.OriginalityCodes;
            FileTypeCodes = obj.FileTypeCodes;
            LanguageCodes = obj.LanguageCodes;
        }
    }
}
