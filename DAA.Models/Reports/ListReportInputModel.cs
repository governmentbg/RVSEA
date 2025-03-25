using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Reports
{
    public class ListReportInputModel
	{
		[Required]
		public IList<string> ArchiveCodesInternal { get; set; } = new List<string>();
		[Required]
		public IList<string> ArchiveGid { get; set; } = new List<string>();
		[Required]
		public int ReportResultType { get; set; }
	}
}
