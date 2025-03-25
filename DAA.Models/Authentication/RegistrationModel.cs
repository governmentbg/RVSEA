using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Authentication
{
    public class RegistrationModel
    {
        [Required]
        public string FirstName { get; set; } = string.Empty;
        public string? Surname { get; set; }
        [Required]
        public string LastName { get; set; } = string.Empty;
        public string? Organization { get; set; }
        public string? Department { get; set; }
        public string? JobTitle { get; set; }
        public string? Address { get; set; }
        public string? Phone { get; set; }
        public string? Eik { get; set; }
        public string? LibraryCardNumber { get; set; }
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;
        [Required]
        [EmailAddress]
        public string EmailConfirmation { get; set; } = string.Empty;
        [Required]
        public string Password { get; set; } = string.Empty;
        [Required]
        public string PasswordConfirmation { get; set; } = string.Empty;
        [Required]
        public string ProfileType { get; set; } = string.Empty;
        public string? ProfileEntityType { get; set; }
    }
}
