using Microsoft.AspNetCore.Authorization;

namespace DAA.Shared.Authorization
{
    public class RolesAttribute : AuthorizeAttribute
    {
        public string RolesList
        {
            get
            {
                return Policy?.Substring(PolicyNameProvider.RolePolicyPrefix.Length);
            }
            set
            {
                Policy = $"{PolicyNameProvider.RolePolicyPrefix}{value}";
            }
        }

        public RolesAttribute(params string[] roles)
        {
            RolesList = string.Join("|", roles);
        }
    }

}
