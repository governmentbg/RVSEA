namespace DAA.Models.Funds
{
    public class SearchedFundShortDisplayModel
    {
        public bool HasExternalSource { get; set; }
        public int? Id { get; set; }
        public int? ExternalIdentifier { get; set; }
        public string CommonId { get; set; } = string.Empty;
        public string? Name { get; set; }
    }
}
