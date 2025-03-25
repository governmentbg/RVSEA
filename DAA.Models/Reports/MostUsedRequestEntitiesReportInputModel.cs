using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Reports
{
    public class MostUsedRequestEntitiesReportInputModel
	{
		public int? ReportResultType { get; set; }
		[Required]
		public IList<string> Archives { get; set; } = new List<string>();
		public string? FundNumber { get; set; }
		public string? InventoryNumber { get; set; }
		public string? ArchiveEntityNumber { get; set; }
		public string? DocumentNumber { get; set; }
		public IList<string>? DescriptionLevels { get; set; }
        public IList<string>? DescriptionLevelsExternal { get; set; }
    }
}
