using System;
using System.Collections.Generic;
using System.Text;

namespace DAA.Models.Users
{
    public class UserRoleModel
    {
        public string UserId { get; set; }
        public IEnumerable<string> UserIds { get; set; }
        public string RoleId { get; set; }
        public IEnumerable<string> RoleIds { get; set; }
    }
}
