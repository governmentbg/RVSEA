using DAA.Models.File;
using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Films
{
    public class FilmPackageDocumentCreateModel
    {
        [Required]
        public Guid EntitySystemIdentifier { get; set; }
        [Required]
        public string EntityType { get; set; }
        [Required]
        public int PackageId { get; set; }
        [Required]
        public int DocumentTypeId { get; set; }
        public string? Description { get; set; }
        
        public IFormFile File { get; set; }
        public bool SkipValidation { get; set; }
    }
}
