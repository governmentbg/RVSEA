using DAA.Models.Nomenclatures;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Extensions.Models
{
    public static class NomenclatureExtensions
    {
        public static IQueryable<NomenclatureDisplayModel> FilterBySearchText(this IQueryable<NomenclatureDisplayModel> query, string searchText)
        {
            return query
                .Where(predicate =>
                    !String.IsNullOrWhiteSpace(searchText)
                    && (predicate.Text.Contains(searchText)
                        || predicate.Code.Contains(searchText)));
        }

        public static IQueryable<NomenclatureValueDisplayModel> FilterBySearchText(this IQueryable<NomenclatureValueDisplayModel> query, string searchText)
        {
            return query
                .Where(predicate =>
                    !String.IsNullOrWhiteSpace(searchText)
                    && (predicate.Text.Contains(searchText)
                        || predicate.Code.Contains(searchText)));
        }
    }
}
