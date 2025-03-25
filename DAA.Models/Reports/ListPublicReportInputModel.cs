using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Reports
{
    public class ListPublicReportInputModel
    {
		[Required]
		public IList<string> Archives { get; set; } = new List<string>();
	}
}
