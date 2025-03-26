namespace DAA.Models.Inventories
{
    public class SearchedInventoryRequestModel
    {
        public string SearchText { get; set; } = string.Empty;
        public bool HasFundExternalSource { get; set; }
        public int? FundInternalIdentifier { get; set; }
        public int? FundExternalIdentifier { get; set; }
    }
}
