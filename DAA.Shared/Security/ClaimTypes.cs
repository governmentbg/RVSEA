using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Shared.Security
{
    public static class ClaimResourceType
    {
        public const string Global = "archiving";
    }
    public static class ClaimTypes
    {
        //public static readonly string Permission = $"https://schemas.sea.org/{ClaimResourceType.Global}/security/claims/permission";
        //public static readonly string Archive = $"https://schemas.sea.org/{ClaimResourceType.Global}/security/claims/archive";
        public static readonly string AuthenticationType = $"https://schemas.sea.org/{ClaimResourceType.Global}/security/claims/authtype";
        public static readonly string UserType = $"https://schemas.sea.org/{ClaimResourceType.Global}/security/claims/usrtype";
        public static readonly string ProfileType = $"https://schemas.sea.org/{ClaimResourceType.Global}/security/claims/pfltype";
        public static readonly string AdminType = $"https://schemas.sea.org/{ClaimResourceType.Global}/security/claims/admtype";
        public static readonly string IsAdmin = $"https://schemas.sea.org/{ClaimResourceType.Global}/security/claims/isadmin";
    }
}
