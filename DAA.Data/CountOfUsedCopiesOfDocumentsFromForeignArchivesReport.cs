using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class CountOfUsedCopiesOfDocumentsFromForeignArchivesReport
    {
		public string? KmfNumber { get; set; }
		public string? InventoryNumber { get; set; }
		public string? StatementDate { get; set; }
		public string? Employee { get; set; }
		public string? Reader { get; set; }
		public int? AeCount { get; set; }
		public int? ElectronicalDocumentsCount { get; set; }
		public long? ElectronicalDocumentsMB { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}
