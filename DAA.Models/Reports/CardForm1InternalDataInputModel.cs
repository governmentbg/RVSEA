using System.ComponentModel.DataAnnotations;

namespace DAA.Models.Reports
{
    public class CardForm1InternalDataInputModel
	{
		[Required]
		public string FundSystemIdentifier { get; set; } = string.Empty;
	}
}
