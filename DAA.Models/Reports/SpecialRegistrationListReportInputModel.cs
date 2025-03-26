using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Reports
{
    public class SpecialRegistrationListReportInputModel
	{
		[Required]
		public IList<string>? ArchiveGids { get; set; }
		public string? FundNumber { get; set; }
		public string? InventoryNumber { get; set; }
		public string? ArchiveEntityNumber { get; set; }
		public bool? IsInRisk { get; set; }
		[Required]
		public IList<string>? DescriptionLevel { get; set; }
	}
}
