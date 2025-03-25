using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Reports
{
    public class RegisterOfDigitalObjectsPublicReportInputModel
	{
        [Required]
        public IList<string>? Archives { get; set; }
        [Required]
        public IList<string> DigitalObjectStatuses { get; set; } = new List<string>();
        public DateTime? RegisteredFrom { get; set; }
		public DateTime? RegisteredTo { get; set; }
		public string? SystemId { get; set; }
	}
}
