using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Settings
{
    public class PackageATemplateModel
    {
        public int? Id { get; set; }
        public string Title { get; set; }
        public int ProcedureId { get; set; }
        public int FileId { get; set; }
        public string FileName { get; set; }
        public bool Required { get; set; }
        public int Sort { get; set; }
        public string Description { get; set; }
        public bool Static { get; set; }
    }

    public class PackageATemplateCreateModel
    {
        public string Title { get; set; }
        [Required]
        public int ProcedureId { get; set; }
        [Required]
        public bool Required { get; set; }
        [Required]
        public int Sort { get; set; }
        [Required]
        public IFormFile File { get; set; }
        public string? Description { get; set; }
        public bool? Static { get; set; }
    }

    public class PackageATemplateUpdateModel : PackageATemplateCreateModel
    {
        [Required]
        public int Id { get; set; }
        public new IFormFile? File { get; set; }
    }
}
