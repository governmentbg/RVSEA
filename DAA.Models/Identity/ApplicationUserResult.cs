using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Identity
{
    public class ApplicationUserResult
    {
        public string? Token { get; set; }
        public DateTime? TokenExpiration { get; set; }
        public Guid? Id { get; set; }
        public string? Name { get; set; }
        public string? DisplayName { get; set; }
        public string? Email { get; set; }
        public bool IsAdmin { get; set; }
        public string? AdminType { get; set; }
        public string? ProfileType { get; set; }
    }
}
