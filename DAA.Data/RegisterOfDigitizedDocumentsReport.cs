using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class RegisterOfDigitizedDocumentsReport
    {
		public string? DocumentLink { get; set; }
		public string? ArchiveCode { get; set; }
		public string? ArchiveName { get; set; }
		public string? SystemId { get; set; }
		public string? LevelOfDescription { get; set; }
		public string? FundNumber { get; set; }
		public string? InventoryNumber { get; set; }
		public string? ArchiveEntityNumber { get; set; }
		public string? Title { get; set; }
		public string? DocCreationDate { get; set; }
		public string? Themes { get; set; }
		public string? DocStatus { get; set; }
		public string? CreationDateDO { get; set; }
		public int? RecordsCountDO { get; set; }
		public string? Duration { get; set; }
		public string? DigitalObjectRecreationDate { get; set; }
		public long? BytesDO { get; set; }
		public string? StatusDO { get; set; }
		public string? Operator { get; set; }
		public string? CorrectionReturnDate { get; set; }
		public string? FinalCorrectionDate { get; set; }
		public string? DigitalObjectAcceptanceDate { get; set; }
        public int? FundIntNumber { get; set; }
        public int? InventoryIntNumber { get; set; }
        public int? ArchivalEntityIntNumber { get; set; }
        public int? ArchiveSortOrder { get; set; }
        public int? MastersCount { get; set; }
        public int? AllDOCount { get; set; }

    }
}
