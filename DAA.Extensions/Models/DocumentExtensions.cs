using DAA.Data;
using DAA.Models.Documents;
using DAA.Models.Documents.DocumentsProcedure;
using DAA.Models.Films;

namespace DAA.Extensions.Models
{
    public static class DocumentExtensions
    {
        public static IQueryable<DocumentDisplayModel> FilterBySearchText(this IQueryable<DocumentDisplayModel> query, string searchText)
        {
            return query
                .Where(predicate =>
                    !String.IsNullOrWhiteSpace(searchText)
                    && (predicate.Title!.Contains(searchText)
                      || (predicate.ArchiveName != null && predicate.ArchiveName.Contains(searchText))
                      || (predicate.FundNumber != null && predicate.FundNumber.Contains(searchText))
                      || (predicate.InventoryNumber != null && predicate.InventoryNumber.Contains(searchText))
                      || (predicate.ArchivalEntityNumber != null && predicate.ArchivalEntityNumber.Contains(searchText))
                      || (predicate.DescriptionLevelText != null && predicate.DescriptionLevelText.Contains(searchText))
                      || (predicate.StatusText != null && predicate.StatusText.Contains(searchText))
                      || (predicate.Number != null && predicate.Number.Contains(searchText))));
        }
        public static IQueryable<DocumentPublicDisplayModel> FilterBySearchText(this IQueryable<DocumentPublicDisplayModel> query, string searchText)
        {
            return query
                .Where(predicate =>
                    !string.IsNullOrWhiteSpace(searchText)
                    && (predicate.Title!.Contains(searchText)
                        || predicate.Number.Contains(searchText)));
        }

        public static IQueryable<DocumentOfListDisplayModel> FilterBySearchText(this IQueryable<DocumentOfListDisplayModel> query, string searchText)
        {
            return query
                .Where(predicate =>
                    !string.IsNullOrWhiteSpace(searchText)
                    && (predicate.Title.Contains(searchText)
                        || predicate.Number.Contains(searchText)));
        }
        public static IEnumerable<DocumentOfListDisplayModel> FilterByFilterString(this IEnumerable<DocumentOfListDisplayModel> query, string filterKeyWord)
        {
            return query
              .Where(predicate => predicate.Title.ToLower().Contains(filterKeyWord.ToLower())).ToList();

        }
        public static IEnumerable<DocumentOfListDisplayModel> FilterByNumber(this IEnumerable<DocumentOfListDisplayModel> query, int number)
        {
            return query
              .Where(predicate => predicate.Number!.ToString().Equals(number.ToString())).ToList();

        }
        public static IEnumerable<DocumentOfListDisplayModel> FilterByPageCount(this IEnumerable<DocumentOfListDisplayModel> query, int pageFrom, int pageTo)
        {
            return query
              .Where(predicate => predicate.StartSheetNumber >= pageFrom || predicate.StartSheetNumber >= pageFrom && predicate.EndSheetNumber <= pageTo).ToList();

        }

    }
}
