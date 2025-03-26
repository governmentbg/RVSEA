using Microsoft.EntityFrameworkCore;

namespace DAA.Data
{
    [Keyless]
    public class AccountAndDescriptionOfFilmDocumentsBook
    {
        public string? ReceivedOn { get; set; }
        // Title { get; set; }
        public string? CreationAuthor { get; set; }
        // оригинал/копие { get; set; }
        public string? ImmediateSourceOfAcquisition { get; set; }
        public string? CountryOfOrigin { get; set; }
        // DocumentsCharacteristics { get; set; }
        // съпроводителна текстова документация { get; set; }
        // документ, въз основа на който е приет { get; set; }
        public string? FundNumberAndInventoryAndArchiveEntiry { get; set; }
        // наличие на застрахователно копие/вид носител { get; set; }
        public string? Note { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}