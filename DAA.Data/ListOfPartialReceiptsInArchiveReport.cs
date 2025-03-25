using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class ListOfPartialReceiptsInArchiveReport
    {
        public string? CountryCode { get; set; }
        public string? Archive { get; set; }
        public string? FundNumber { get; set; }
        public string? FundTitle { get; set; }
        public string? CreationDate { get; set; }
        public string? ImmediateSourceOfAcquisition { get; set; }
        //public string? FundType { get; set; } отпада по забележка на Архивите
        public string? DocumentProperties { get; set; }
        public string? Note { get; set; }
        public string? FundStatus { get; set; }
        public string? MethodOfAcquisition { get; set; }
        public string? ChronologicalScope { get; set; }
        // махат се по забележка от ИСДА
        //public string? ChronologicalScopeStartDate { get; set; }
        //public string? ChronologicalScopeEndDate { get; set; }
        public int? InventoryCount { get; set; }
        public int? AeCount { get; set; }
        public double? LinearMeters { get; set; }
        public long? Size { get; set; }
        public string? Duration { get; set; }
        public int? EDocumentsCount { get; set; }
        public string? FileFormats { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}
