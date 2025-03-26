
using DAA.Models.ArchiveEntities;

namespace DAA.Extensions.Models
{
    public static class ArchivalEntityExtensions
    {
        public static IQueryable<ArchivalEntityDisplayModel> FilterBySearchText(this IQueryable<ArchivalEntityDisplayModel> query, string searchText)
        {
            return query
                .Where(predicate =>
                    !string.IsNullOrWhiteSpace(searchText)
                    && (predicate.Title!.Contains(searchText)
                     || (predicate.ArchiveName != null && predicate.ArchiveName.Contains(searchText))
                     || (predicate.FundNumber != null && predicate.FundNumber.Contains(searchText))
                     || (predicate.InventoryNumber != null && predicate.InventoryNumber.Contains(searchText))
                     || predicate.Number!.Contains(searchText))
                     || (predicate.DescriptionLevelText != null && predicate.DescriptionLevelText.Contains(searchText))
                     || (predicate.StatusText != null && predicate.StatusText.Contains(searchText)));
        }

        public static IQueryable<ArchivalEntityDisplayModel> FilterByNumber(this IQueryable<ArchivalEntityDisplayModel> query, string number)
        {
            return query
                .Where(predicate =>
                    !string.IsNullOrWhiteSpace(number)
                    && predicate.Number!.Equals(number));
        }
        public static IQueryable<ArchivalEntityPublicDisplayModel> FilterBySearchTextPublic(this IQueryable<ArchivalEntityPublicDisplayModel> query, string searchText)
        {
            return query
                .Where(predicate =>
                    !string.IsNullOrWhiteSpace(searchText)
                    && (predicate.Title!.Contains(searchText)
                        || predicate.Number!.Contains(searchText)));
        }

        public static IQueryable<ArchivalEntityPublicDisplayModel> FilterByNumberPublic(this IQueryable<ArchivalEntityPublicDisplayModel> query, string number)
        {
            return query
                .Where(predicate =>
                    !string.IsNullOrWhiteSpace(number)
                    && predicate.Number!.Equals(number));
        }

        //public static IQueryable<ArchiveEntityOfListDisplayModel> FilterBySearchText(this IQueryable<ArchiveEntityOfListDisplayModel> query, string searchText)
        //{
        //    return query
        //        .Where(predicate =>
        //            !string.IsNullOrWhiteSpace(searchText)
        //            && (predicate.Title.Contains(searchText)
        //                || predicate.Number.Contains(searchText)));
        //}

        //public static IEnumerable<ArchiveEntityOfListDisplayModel> FilterByFilterString(this IEnumerable<ArchiveEntityOfListDisplayModel> query, string filterKeyWord)
        //{
        //    return query
        //      .Where(predicate => predicate.Title.ToLower().Contains(filterKeyWord.ToLower())).ToList();

        //}
        //public static IEnumerable<ArchiveEntityOfListDisplayModel> FilterByNumber(this IEnumerable<ArchiveEntityOfListDisplayModel> query, int number)
        //{
        //    return query
        //      .Where(predicate => predicate.Number.ToString().Equals(number.ToString())).ToList();

        //}
    }
}
