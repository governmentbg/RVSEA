using DAA.Models.Users;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Extensions.Models
{
    public static class UserExtensions
    {
        public static IQueryable<UserDisplayModel> FilterBySearchText(this IQueryable<UserDisplayModel> query, string searchText)
        {
            return query
                .Where(predicate => 
                    !String.IsNullOrWhiteSpace(searchText) 
                    && (
                        predicate.UserName.Contains(searchText)
                        || predicate.DisplayName.Contains(searchText)
                        || predicate.Email.Contains(searchText)
                        || predicate.CertificateThumbprint.Contains(searchText)
                        || predicate.CreatedByDisplayName.Contains(searchText)
                        || predicate.UpdatedByDisplayName.Contains(searchText)
                    ));
        }
    }
}
