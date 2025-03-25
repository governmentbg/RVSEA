using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Reports
{
    public class CompilationAndNTOOfEDocumentsInputModel : ReportInputBaseModel
    {
		public IList<string>? FundArraysInternal { get; set; }
		public IList<string>? FundTypesInternal { get; set; }
		public IList<string>? MethodsOfAcquisitionInternal { get; set; }
		public DateTime? RegisteredFrom { get; set; }
		public DateTime? RegisteredTo { get; set; }
		//
		public string? ProcessStartDate { get; set; }
		public string? ProcessEndDate { get; set; }
		//
		//public IList<string>? ArchiveGids { get; set; }
		//public IList<string>? ArchiveCodesInternal { get; set; }
		public string? DateFrom { get; set; }
		public string? DateTo { get; set; }
		//public IList<string>? StatusGids { get; set; }
		//public IList<string>? StatusesInternal { get; set; }
		public IList<string>? ProcessTypes { get; set; }
		public IList<string>? FileFormats { get; set; }
		public IList<string>? FundLevelOfdescriptionCodes { get; set; }
	}
}
