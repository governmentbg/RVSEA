using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Reports
{
    public class ActiveProcessesReportInputModel
	{
		[Required]
		public IList<string>? Archives { get; set; }
		[Required]
		public int ReportResultType { get; set; }
		public string? ProcessStartedFrom { get; set; }
		public string? ProcessStartedTo { get; set; }
		public IList<string>? ProcessGids { get; set; }
		public IList<string>? ProcessTypesInternal { get; set; }
		public string? FundNumber { get; set; }
		public IList<string>? UserGids { get; set; }
		public IList<string>? UserIdsInternal { get; set; }
	}
}