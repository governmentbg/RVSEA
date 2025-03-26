using DAA.Models.Funds;

namespace DAA.Extensions.Models
{
    public static class FundExtensions
    {
        public static IQueryable<FundDisplayModel> FilterBySearchText(this IQueryable<FundDisplayModel> query, string searchText)
        {
            return query
                .Where(predicate =>
                    !String.IsNullOrWhiteSpace(searchText)
                    && (predicate.Title.Contains(searchText)
                     || (predicate.ArchiveName != null && predicate.ArchiveName.Contains(searchText))
                     || (predicate.NumberArray != null && predicate.NumberArray.Contains(searchText))
                     || (predicate.Number != null && predicate.Number.Contains(searchText))
                     || (predicate.DescriptionLevelText != null && predicate.DescriptionLevelText.Contains(searchText))
                     || (predicate.StatusText != null && predicate.StatusText.Contains(searchText))
                     || (predicate.TypeText != null && predicate.TypeText.Contains(searchText))));
        }
    }
}
