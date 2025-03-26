using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Packages
{
    public class ApplicationPackageModel
    {
        [Required]
        public int ApplicationId { get; set; }
        [Required]
        public IEnumerable<PackageDocumentBaseModel> PackageA { get; set; }
        [Required]
        public IEnumerable<PackageDocumentBaseModel> PackageB { get; set; }
    }

    public class PackageDocumentBaseModel
    {
        public int? Id { get; set; }
        public int? DocumentTypeId { get; set; }
        public string? Description { get; set; }
        public string? FileName { get; set; }
        public long? FileSize { get; set; }
        public Guid? DocumentSystemIdentifier { get; set; }
        public IFormFile File { get; set; }
        public bool _deleted { get; set; }
        public bool SkipValidation { get; set; }
        public bool? SignatureFile { get; set; }
        public bool IsInvaluable { get; set; }
        public int? TypeCode { get; set; }
        public Guid? ParentSystemIdentifier { get; set; }
        public int? ParentId { get; set; }
    }

    public class PackageDocumentCreateModel : PackageDocumentBaseModel
    {
        public int PackageId { get; set; }
        public IFormFile[]? Files { get; set; }
        public string? InventorySysIdentifier { get; set; }
    }

    public class ApplicationPackageDisplayModel
    {
        [Required]
        public int ApplicationId { get; set; }
        public Guid InventoryIdentifier { get; set; }
        [Required]
        public IEnumerable<PackageDocumentDisplayModel> PackageA { get; set; }
        [Required]
        public IEnumerable<PackageDocumentDisplayModel> PackageB { get; set; }
    }

    public class PackageDocumentDisplayModel : PackageDocumentBaseModel
    {
        public string? DocumentType { get; set; }
        public string FileId { get; set; }
        public string? FileTypeName { get; set; }
        public float? FileSizeInMB { get; set; }
        public int? RowNumber { get; set; }
        public string? CreatedByUserName { get; set; }
        public string? CreatedByDisplayName { get; set; }
        public DateTime? CreatedOn { get; set; }
        public bool? IsSigned { get; set; }
        public int? TypeCode { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public DateTime? UpdateOrCreateDate { get; set; }
        public string? ParentSourceName { get; set; }
    }
}
