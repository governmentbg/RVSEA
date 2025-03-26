using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace DAA.Models.Users
{
    public class UserEditModel : UserBaseModel
    {
        [Required]
        public string FirstName { get; set; } = string.Empty;
        public string? Surname { get; set; }
        [Required]
        public string LastName { get; set; } = string.Empty;
        public string? Organization { get; set; }
        public string? Department { get; set; }
        public string? JobTitle { get; set; }
    }
}
