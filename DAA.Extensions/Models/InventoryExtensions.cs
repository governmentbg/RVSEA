using DAA.Models.Inventories;

namespace DAA.Extensions.Models
{
    public static class InventoryExtensions
    {
        public static IQueryable<InventoryDisplayModel> FilterBySearchText(this IQueryable<InventoryDisplayModel> query, string searchText)
        {
            return query
                .Where(predicate =>
                    !String.IsNullOrWhiteSpace(searchText)
                    && predicate.Number!.Contains(searchText)
                    || (predicate.FundNumber != null && predicate.FundNumber.Contains(searchText))
                    || (predicate.StatusText != null && predicate.StatusText.Contains(searchText))
                    || (predicate.ArchiveName != null && predicate.ArchiveName.Contains(searchText))
                    || (predicate.DescriptionLevelText != null && predicate.DescriptionLevelText.Contains(searchText)));
        }
    }
}
