using DAA.Shared;
using DAA.Shared.Security;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace DAA.Models.Users
{
    public class UserBaseModel
    {
        public Guid Id { get; set; }
        public string AuthenticationType { get; set; } = String.Empty;
        public string UserType { get; set; } = null!;
        public string? UserProfileType { get; set; }
        public string UserName { get; set; } = String.Empty;
        public string DisplayName { get; set; } = String.Empty;
        [EmailAddress]
        public string Email { get; set; } = String.Empty;
        public IEnumerable<int> Archives { get; set; } = Enumerable.Empty<int>();
        public IEnumerable<Guid> Roles { get; set; } = Enumerable.Empty<Guid>();
    }
}
