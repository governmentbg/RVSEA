using DAA.Models.FundReconstructions;

namespace DAA.Extensions.Models
{
    public static class FundReconstructionExtensions
    {
        public static IQueryable<FundReconstructionDisplayModel> FilterBySearchText(this IQueryable<FundReconstructionDisplayModel> query, string searchText)
        {
            return query
                .Where(predicate =>
                    !String.IsNullOrWhiteSpace(searchText)
                    && (predicate.FundNumber!.Contains(searchText)
                        || predicate.SourceInventoryNumber!.Contains(searchText)
                        || predicate.SourceArchivalEntityNumber!.Contains(searchText)
                        || predicate.SourceDocumentTitle!.Contains(searchText)
                        || predicate.TargetInventoryNumber!.Contains(searchText)
                        || predicate.TargetArchivalEntityNumber!.Contains(searchText)
                        || predicate.TargetDocumentTitle!.Contains(searchText)));
        }
    }
}
