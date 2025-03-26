using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Reports
{
    public class WorkDoneOnDigitalObjectsReportInputModel
	{
		[Required]
		public IList<string> ArchiveCodes { get; set; } = new List<string>();
		[Required]
		public IList<string> FundArrays { get; set; } = new List<string>();
        [Required]
		public IList<string> UserIds { get; set; } = new List<string>();
        [Required]
		public IList<string> ProcessSteps { get; set; } = new List<string>();
        [Required]
		public IList<string> DigitalObjectStatuses { get; set; } = new List<string>();
        public DateTime? CreatedFrom { get; set; }
		public DateTime? CreatedTo { get; set; }
	}
}
