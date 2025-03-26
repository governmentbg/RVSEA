using DAA.Shared.Authorization;
using DAA.Shared.Security;
using Microsoft.AspNetCore.Authorization;

namespace DAA.Services.Authorization
{
    public class AdminAuthorizationRequirement : IAdminAuthorizationRequirement
    {

        /// <summary>
        /// Gets the collection of allowed admin types.
        /// </summary>
        public IEnumerable<string> AllowedAdminTypes { get; }

        /// <summary>
        /// Creates a new instance of <see cref="AdminAuthorizationRequirement"/>.
        /// </summary>
        /// <param name="allowedAdminTypes">A collection of allowed admin types.</param>
        public AdminAuthorizationRequirement(IEnumerable<string> allowedAdminTypes)
        {
            //if (allowedAdminTypes == null)
            //{
            //    throw new ArgumentNullException(nameof(allowedAdminTypes));
            //}

            //if (!allowedAdminTypes.Any())
            //{
            //    throw new InvalidOperationException();
            //}
            if (allowedAdminTypes == null || !allowedAdminTypes.Any())
            {
                AllowedAdminTypes = new[] { AdminType.Admin };
            }
            else
            {
                AllowedAdminTypes = allowedAdminTypes;
            }
        }

        /// <inheritdoc />
        public override string ToString()
        {
            var adminTypes = $"User.IsInRole must be true for one of the following admin types: ({string.Join("|", AllowedAdminTypes)})";

            return $"{nameof(AdminAuthorizationRequirement)}:{adminTypes}";
        }
    }
}
