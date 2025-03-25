using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Reports
{
    public class ReportInputBaseModelInternalOnly
	{
		[Required]
		public IList<string>? Statuses { get; set; }
		[Required]
		public IList<string>? Archives { get; set; }
	}
}
