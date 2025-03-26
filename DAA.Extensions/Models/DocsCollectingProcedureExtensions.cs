using DAA.Models.DocsCollectionProcedure;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Extensions.Models
{
    public static class DocsCollectingProcedureExtensions
    {
        public static IQueryable<DocsCollectingGridModel> FilterBySearchText(this IQueryable<DocsCollectingGridModel> query, string searchText)
        {
            return query
                .Where(predicate =>
                    !String.IsNullOrWhiteSpace(searchText)
                    && (predicate.ProcessTypeTitle.Contains(searchText)
                     || (predicate.ArchiveName != null && predicate.ArchiveName.Contains(searchText))
                     || (predicate.CreatedByDisplayName != null && predicate.CreatedByDisplayName.Contains(searchText))
                     || (predicate.FundNumber != null && predicate.FundNumber.Contains(searchText))
                     || (predicate.InventoryNumber != null && predicate.InventoryNumber.Contains(searchText))));
        }
    }
}
