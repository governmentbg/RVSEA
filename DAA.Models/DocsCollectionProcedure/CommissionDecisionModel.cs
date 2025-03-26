using System.ComponentModel.DataAnnotations;

namespace DAA.Models.DocsCollectionProcedure
{
    public class ProcessDecisionModel
    {
        [Required]
        public int ProcessId { get; set; }
        [Required]
        public bool Accepted { get; set; }
        public bool HasConditions { get; set; }
        public bool AssignForRedirect { get; set; }
        public int? RedirectToArchiveId { get; set; }
        public Guid? AssignToUserId { get; set; }
        public Guid? AssignToRoleId { get; set; }
    }
}
