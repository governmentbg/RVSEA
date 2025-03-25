using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Applications
{
    public class ApproveModel
    {
        [Required]
        public int Id { get; set; }
        public Guid? UserId { get; set; }
    }
}
