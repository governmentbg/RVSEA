using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Reports
{
    public class FundMemoriesListInternalReportFiltersModel : ReportInputBaseModel
	{
		[Required]
		public IList<string>? PeriodGids { get; set; } // това е наименованието на FundArraysExternal в ИСДА; Масив, FundArray
		[Required]
		public IList<string>? FundArraysInternal { get; set; }
		[Required]
		public IList<string>? MethodOfAcquisitionGids { get; set; }
		[Required]
		public IList<string>? MethodsOfAcquisitionInternal { get; set; }
		public DateTime? RegisteredFrom { get; set; }
		public DateTime? RegisteredTo { get; set; }
		public string? TextDate { get; set; }
		public string? DateFrom { get; set; }
		public string? DateTo { get; set; }
		[Required]
		public int ReportResultType { get; set; }
	}
}
