using DAA.Shared.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Shared.Identity
{
    public class UserInfo : IUserInfo
    {
        private readonly ClaimsPrincipal _principal;

        public ClaimsPrincipal CurrentUser => _principal;
        public Guid? CurrentUserId => _principal?.GetUserId();
        public string? CurrentUserEmail => _principal?.GetUserEmail();
        public string? CurrentUserUsername => _principal?.GetUserUsername();
        //public int? CurrentUserArchiveId => _principal?.GetUserArchiveId();
        public bool? CurrentUserIsAdmin => _principal?.GetUserIsAdmin();
                
        public UserInfo(ClaimsPrincipal principal)
        {
            _principal = principal;
        }
    }
}
