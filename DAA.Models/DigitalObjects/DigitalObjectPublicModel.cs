

using Microsoft.AspNetCore.Http;

namespace DAA.Models.DigitalObjects
{
    public class DigitalObjectPublicModel
    {
        public Guid? SystemIdentifier { get; set; }
        public Guid? DocumentSystemIdentifier { get; set; }
        public int? DocumentExternalIdentifier { get; set; }
        public bool DocumentHasExternalSource { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public int? TypeCode { get; set; }
        public string? Name { get; set; }
        public string? SourceName { get; set; }
        public string? FileType { get; set; }
        public string? ContentType { get; set; }
        public string? StatusCode { get; set; }
        public IFormFile? Content { get; set; }
        public int? PackageDocumentId { get; set; }
    }
}
