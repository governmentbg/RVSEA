using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using ArchivingClaimTypes = DAA.Shared.Security.ClaimTypes;
using SystemClaimTypes = System.Security.Claims.ClaimTypes;


namespace DAA.Shared.Security
{
    public static class ClaimsPrincipalExtensions
    {
        public static Guid GetUserId(this ClaimsPrincipal principal)
        {
            if (Guid.TryParse(principal.FindFirst(SystemClaimTypes.NameIdentifier)?.Value, out Guid userId))
            {
                return userId;
            }
            
            return default;
        }

        public static string? GetUserEmail(this ClaimsPrincipal principal) =>
            principal?.FindFirst(SystemClaimTypes.Email)?.Value;

        public static string? GetUserUsername(this ClaimsPrincipal principal) =>
            principal?.FindFirst(SystemClaimTypes.Name)?.Value;

        //public static int GetUserArchiveId(this ClaimsPrincipal principal)
        //{
        //    if (int.TryParse(principal.FindFirst(ArchivingClaimTypes.Archive)?.Value, out int archiveId))
        //    {
        //        return archiveId;
        //    }

        //    return default;
        //}

        public static bool GetUserIsAdmin(this ClaimsPrincipal principal)
        {
            if (bool.TryParse(principal.FindFirst(ArchivingClaimTypes.IsAdmin)?.Value, out bool isAdmin))
            {
                return isAdmin;
            }

            return default;
        }

        //public static bool GetUserIsAdmin(this ClaimsPrincipal principal, string adminType)
        //{
        //    if (principal?.FindFirst(DocFlowClaimTypes.IsAdmin) == null)
        //    {
        //        return default;
        //    }
        //    if (principal?.FindFirst(DocFlowClaimTypes.AdminType) == null)
        //    {
        //        return default;
        //    }

        //    if (bool.TryParse(principal.FindFirst(DocFlowClaimTypes.IsAdmin).Value, out bool isAdmin))
        //    {
        //        return isAdmin && (principal.FindFirst(DocFlowClaimTypes.AdminType).Value.Equals(adminType));
        //    }

        //    return default;
        //}
    }
}
