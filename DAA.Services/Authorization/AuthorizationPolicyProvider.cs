using DAA.Shared.Authorization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Services.Authorization
{
    public class AuthorizationPolicyProvider : IAuthorizationPolicyProvider
    {
        public DefaultAuthorizationPolicyProvider FallbackPolicyProvider { get; }

        public AuthorizationPolicyProvider(IOptions<AuthorizationOptions> options)
        {
            FallbackPolicyProvider = new DefaultAuthorizationPolicyProvider(options);
        }
        public Task<AuthorizationPolicy> GetDefaultPolicyAsync() => FallbackPolicyProvider.GetDefaultPolicyAsync();

        public Task<AuthorizationPolicy?> GetFallbackPolicyAsync() => FallbackPolicyProvider.GetFallbackPolicyAsync();

        public Task<AuthorizationPolicy?> GetPolicyAsync(string policyName)
        {
            bool isAdminPolicy = policyName.StartsWith(PolicyNameProvider.AdminPolicyPrefix, StringComparison.OrdinalIgnoreCase);
            if (isAdminPolicy)
            {
                var adminTypes = policyName.Substring(PolicyNameProvider.AdminPolicyPrefix.Length).Split("|", StringSplitOptions.RemoveEmptyEntries);
                var policy = new AuthorizationPolicyBuilder();

                policy.AddRequirements(new AdminAuthorizationRequirement(adminTypes));
                return Task.FromResult(policy.Build());
            }

            bool isRolePolicy = policyName.StartsWith(PolicyNameProvider.RolePolicyPrefix, StringComparison.OrdinalIgnoreCase);
            if (isRolePolicy)
            {
                var roles = policyName.Substring(PolicyNameProvider.RolePolicyPrefix.Length).Split("|", StringSplitOptions.RemoveEmptyEntries);
                var policy = new AuthorizationPolicyBuilder();

                policy.AddRequirements(new RolesAuthorizationRequirement(roles));
                return Task.FromResult(policy.Build());
            }

            return FallbackPolicyProvider.GetPolicyAsync(policyName);
        }
    }
}
