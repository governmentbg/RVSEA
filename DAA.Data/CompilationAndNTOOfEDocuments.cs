using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class CompilationAndNTOOfEDocumentsReport
	{
				/*Archive nvarchar(256) NULL,
				FundNumber nvarchar(256) NULL,
				Title nvarchar(MAX) NULL,
				MethodOfAcquisitions nvarchar(256) NULL,
				Type nvarchar(256) NULL,
				ChronologicalScope nvarchar(256) NULL,
				DateOfFiling nvarchar(256) NULL,
				Status nvarchar(256) NULL,
				LevelOfDescription nvarchar(256) NULL,
				InvetoryCount int NULL,
				AeCount int NULL,
				DocumentCount int NULL,
				FailFormats nvarchar(256) NULL,
				Mb nvarchar(256) NULL,
				Duration nvarchar(256) NULL,
				Note nvarchar(MAX) NULL*/

		public string? Archive { get; set; }
		public string? FundNumber { get; set; }
		public string? Title { get; set; }
		public string? MethodOfAcquisitions { get; set; }
		public string? Type { get; set; }
		public string? ChronologicalScope { get; set; }
		public DateTime? DateOfFiling { get; set; }
		public string? Status { get; set; }
		public string? LevelOfDescription { get; set; }
		public int? InventoryCount { get; set; }
		public int? AeCount { get; set; }
		public int? DocumentCount { get; set; }
		public string? FileFormats { get; set; }
		public long? Bytes { get; set; }
		public int? Duration { get; set; }
		public string? Note { get; set; }
		public Guid? SystemIdentifier { get; set; }
		public string? ExternalIdentifier { get; set; }
		public bool HasExternalSource { get; set; }
		public string? NumberArray { get; set;}

    }
}
