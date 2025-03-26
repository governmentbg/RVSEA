using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Reports
{
    public class ReportInputBaseModel
	{
		[Required]
		public IList<string>? StatusesInternal { get; set; }
		[Required]
		public IList<string>? StatusGids { get; set; }
		public IList<string>? Statuses { get; set; }
		[Required]
		public IList<string>? ArchiveCodesInternal { get; set; }
		[Required]
		public IList<string>? ArchiveGids { get; set; }
		[Required]
		public IList<string>? Archives { get; set; }
	}
}
