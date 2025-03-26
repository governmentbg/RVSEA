using Microsoft.AspNetCore.Http;

namespace DAA.Models.DigitalObjects
{
    public class DigitalObjectModel
    {
        public int? Id { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ParentId { get; set; }
        public Guid? ParentSystemIdentifier { get; set; }
        public int? ArchiveId { get; set; }
        public int? FundDraftId { get; set; }
        public Guid? FundSystemIdentifier { get; set; }
        public int? FundExternalIdentifier { get; set; }
        public bool FundHasExternalSource { get; set; }
        public int? InventoryDraftId { get; set; }
        public Guid? InventorySystemIdentifier { get; set; }
        public int? InventoryExternalIdentifier { get; set; }
        public bool InventoryHasExternalSource { get; set; }
        public int? ArchivalEntityDraftId { get; set; }
        public Guid? ArchivalEntitySystemIdentifier { get; set; }
        public int? ArchivalEntityExternalIdentifier { get; set; }
        public bool ArchivalEntityHasExternalSource { get; set; }
        public int? DocumentDraftId { get; set; }
        public Guid? DocumentSystemIdentifier { get; set; }
        public int? DocumentExternalIdentifier { get; set; }
        public bool DocumentHasExternalSource { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public int? TypeCode { get; set; }
        public string? Name { get; set; }
        public string? SourceName { get; set; }
        public string? UncPath { get; set; }
        public string? FileType { get; set; }
        public long FileSize { get; set; } = 0;
        public string? ContentType { get; set; }
        public string? StatusCode { get; set; }
        public IFormFile? Content { get; set; }
        public string? WatermarkName { get; set; }
        public string? WatermarkUncPath { get; set; }
        public string? HashCode { get; set; }
        public int? Duration { get; set; }
        public int? PackageDocumentId { get; set; }
        public bool IsImported { get; set; }
        public bool IsDigitized { get; set; }
        public bool SkipValidation { get; set; }
        


        public void Assign(DigitalObjectModel obj, bool newObject = false)
        {
            if (!newObject)
            {
                Id = obj.Id;
                SystemIdentifier = obj.SystemIdentifier;
            }
            ParentId = obj.ParentId;
            ParentSystemIdentifier = obj.ParentSystemIdentifier;
            ArchiveId = obj.ArchiveId;
            FundDraftId = obj.FundDraftId;
            FundSystemIdentifier = obj.FundSystemIdentifier;
            FundExternalIdentifier = obj.FundExternalIdentifier;
            FundHasExternalSource = obj.FundHasExternalSource;
            InventoryDraftId = obj.InventoryDraftId;
            InventorySystemIdentifier = obj.InventorySystemIdentifier;
            InventoryExternalIdentifier = obj.InventoryExternalIdentifier;
            InventoryHasExternalSource = obj.InventoryHasExternalSource;
            ArchivalEntityDraftId = obj.ArchivalEntityDraftId;
            ArchivalEntitySystemIdentifier = obj.ArchivalEntitySystemIdentifier;
            ArchivalEntityExternalIdentifier = obj.ArchivalEntityExternalIdentifier;
            ArchivalEntityHasExternalSource = obj.ArchivalEntityHasExternalSource;
            DocumentDraftId = obj.DocumentDraftId;
            DocumentSystemIdentifier = obj.DocumentSystemIdentifier;
            DocumentExternalIdentifier = obj.DocumentExternalIdentifier;
            DocumentHasExternalSource = obj.DocumentHasExternalSource;
            ExternalIdentifier = obj.ExternalIdentifier;
            HasExternalSource = obj.HasExternalSource;
            TypeCode = obj.TypeCode;
            Name = obj.Name;
            SourceName = obj.SourceName;
            UncPath = obj.UncPath;
            FileType = obj.FileType;
            FileSize = obj.FileSize;
            ContentType = obj.ContentType;
            StatusCode = obj.StatusCode;
            IsDigitized = obj.IsDigitized;
            Content = obj.Content;
            WatermarkName = obj.WatermarkName;
            WatermarkUncPath = obj.WatermarkUncPath;
            HashCode = obj.HashCode;
            PackageDocumentId = obj.PackageDocumentId;
            IsImported = obj.IsImported;
            IsDigitized = obj.IsDigitized;
            SkipValidation = obj.SkipValidation;
            Duration = obj.Duration;
        }
    }
}
