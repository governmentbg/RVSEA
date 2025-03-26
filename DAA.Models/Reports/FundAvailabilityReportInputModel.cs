using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Reports
{
    public class FundAvailabilityReportInputModel : ReportInputBaseModel
	{
		public int? ReportResultType { get; set; }
		[Required]
		public IList<string>? PeriodGids { get; set; } // това е наименованието на FundArraysExternal в ИСДА; Масив, FundArray
		[Required]
		public IList<string>? FundArraysInternal { get; set; }
		[Required]
		public IList<string>? FundTypeGids { get; set; }
		[Required]
		public IList<string>? FundTypesInternal { get; set; }
		[Required]
		public IList<string>? MethodOfAcquisitionGids { get; set; }
		[Required]
		public IList<string>? MethodsOfAcquisitionInternal { get; set; }
		[Required]
		public IList<string>? ProcessGids { get; set; }
		[Required]
		public IList<string>? ProcessTypesInternal { get; set; }
		public IList<string>? FileFormats { get; set; }
		public DateTime? RegisteredFrom { get; set; }
		public DateTime? RegisteredTo { get; set; }
		public string? TextDate { get; set; }
		public string? DateFrom { get; set; }
		public string? DateTo { get; set; }
	}
}
