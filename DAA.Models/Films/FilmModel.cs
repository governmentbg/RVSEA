using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Films
{
    public class FilmModel
    {
        public int Id { get; set; }
        public Guid SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        [Required]
        public int ArchiveId { get; set; }
        public int InventoryNumber { get; set; }
        public int? CountryId { get; set; }
        public int? FramesCount { get; set; }
        public int? MicrofilmNegativeRollsCount { get; set; }
        public int? MicrofilmNegativeFramesCount { get; set; }
        public int? MicrofilmPositiveRollsCount { get; set; }
        public int? MicrofilmPositiveFramesCount { get; set; }
        public string? PhotoCopy { get; set; }
        public string? DigitalCopy { get; set; }
        public string? Size { get; set; }
        public string? Other { get; set; }
        public int? AcceptedOnDay { get; set; }
        public int? AcceptedOnMonth { get; set; }
        public int? AcceptedOnYear { get; set; }
        public string? Source { get; set; }
        public string? Content { get; set; }
        public string? Notes { get; set; }

        public int? PackageAId { get; set; }
        public int? PackageBId { get; set; }

        public int? CurrentProcessId { get; set; }
        public int? CurrentProcessTypeId { get; set; }
        public int? CurrentStepId { get; set; }
        public int? CurrentStepTypeId { get; set; }
    }
}
