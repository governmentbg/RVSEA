using Microsoft.AspNetCore.Authorization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Shared.Authorization
{
    public class AdminAttribute : AuthorizeAttribute
    {
        /// <summary>
        /// Gets or sets a comma delimited list of admin types that are allowed to access the resource.
        /// </summary>
        public string? AdminTypes 
        {
            get
            {
                return Policy?.Substring(PolicyNameProvider.AdminPolicyPrefix.Length);
            }
            set
            {
                Policy = $"{PolicyNameProvider.AdminPolicyPrefix}{value}";
            }
        }

        public AdminAttribute(params string[] adminTypes) => AdminTypes = string.Join("|", adminTypes);
    }
}
