using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Films
{
    public class FilmChangeStepModel
    {
        [Required]
        public int FilmId { get; set; }
        [Required]
        public Guid FilmSystemIdentifier { get; set; }
        [Required]
        public Shared.ProcessStepType StepType { get; set; }
        public string? Comment { get; set; }
        public string? AssignedToUserId { get; set; }
        public string? AssignedToRoleId { get; set; }
        public DateTime? EndDate { get; set; }
    }
}
