
using DAA.Data;
using DAA.Shared;

namespace DAA.Extensions.Models
{
    public static class PublicSearchEngineExtensions
    {
        public static IQueryable<SearchResult> FilterByFilterKeyWord(this IQueryable<SearchResult> query, string keyWord)
        {
            return query
              .Where(predicate => !string.IsNullOrWhiteSpace(keyWord)
                //&& !string.IsNullOrEmpty(predicate.FundDescriptionLevelText) && predicate.FundDescriptionLevelText.ToLower().Contains(keyWord.ToLower())
                //&& !string.IsNullOrEmpty(predicate.InventoryDescriptionLevelText) && predicate.InventoryDescriptionLevelText.ToLower().Contains(keyWord.ToLower())
                //&& !string.IsNullOrEmpty(predicate.ArchivalEntityDescriptionLevelText) && predicate.ArchivalEntityDescriptionLevelText.ToLower().Contains(keyWord.ToLower())
                //|| !string.IsNullOrEmpty(predicate.ArchiveName) && predicate.ArchiveName.ToLower().Contains(keyWord.ToLower())
                //|| !string.IsNullOrEmpty(predicate.Title) && predicate.Title.ToLower().Contains(keyWord.ToLower())
                );
        }
        public static IQueryable<SearchResult> FilterByFilterTitle(this IQueryable<SearchResult> query, string searchWord)
        {
            return query
              .Where(predicate => !String.IsNullOrWhiteSpace(searchWord)
                //&& predicate.EntityType == BusinessObjectType.Fund && !string.IsNullOrEmpty(predicate.Title) && predicate.Title.ToLower().Contains(searchWord.ToLower())
                );
        }
        //to do
        //public static IQueryable<SearchEngineResult> FilterByFilterDate(this IQueryable<SearchEngineResult> query, DateOnly start , DateOnly end)
        //{

        //    return query
        //     .Where(q =>
        //              (start.Day <= q.RegisteredFrom.Value.Day && start.Month <= q.RegisteredFrom.Value.Month && start.Year <= q.RegisteredFrom.Value.Year)
        //           || (end.Day >= q.RegisteredFrom.Value.Day && end.Month <= q.RegisteredFrom.Value.Month && end.Year <= q.RegisteredFrom.Value.Year));
        //}
    }
}
