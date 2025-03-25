using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Applications
{
    public class RejectModel
    {
        [Required]
        public int Id { get; set; }
        [Required]
        public string Reason { get; set; }
    }
}
