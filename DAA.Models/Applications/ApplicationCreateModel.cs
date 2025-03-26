using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Applications
{
    public class ApplicationCreateModel
    {
        [Required]
        public Guid ApplicantId { get; set; }
        [Required]
        public string? ApplicantFullName { get; set; }
        [Required]
        public string? ApplicantEmail { get; set; }
        public string? ApplicantPhone { get; set; }
        public string? Address { get; set; }
        public string? Organization { get; set; }
        public string? OrganizationRepresentative { get; set; }
        public string? OrganizationEIK { get; set; }
        [Required]
        public int ArchiveId { get; set; }
        [Required]
        public string? Type { get; set; }

        [Required]
        public string? DocumentsOwner { get; set; }

        [Required]
        public int? DocumentsSize { get; set; }

        [Required]
        public string? DocumentsPeriod { get; set; }

        [Required]
        public string? DocumentsOriginType { get; set; }
    }
}
