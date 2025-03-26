using DAA.Models.Archives;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Extensions.Models
{
    public static class ArchiveExtensions
    {
        public static IQueryable<ArchiveDisplayModel> FilterBySearchText(this IQueryable<ArchiveDisplayModel> query, string searchText)
        {
            return query
                .Where(predicate =>
                    !String.IsNullOrWhiteSpace(searchText)
                    && predicate.Name.Contains(searchText));
        }
    }
}
