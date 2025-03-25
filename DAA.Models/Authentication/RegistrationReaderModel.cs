using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Authentication
{
    public class RegistrationReaderModel
    {
        [Required]
        public string Username { get; set; } = string.Empty;
        [EmailAddress]
        public string? Email { get; set; } = string.Empty;
        [Required]
        [EmailAddress]
        public string? EmailConfirmation { get; set; } = string.Empty;
        [Required]
        public string Password { get; set; } = string.Empty;
        [Required]
        public string PasswordConfirmation { get; set; } = string.Empty;
        [Required]
        public string ProfileType { get; set; } = string.Empty;
        public string? ProfileEntityType { get; set; }



        public string FirstName { get; set; } = string.Empty;
        public string? Surname { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string? Organization { get; set; } = string.Empty;
        public string? Department { get; set; } = string.Empty;
        public string? JobTitle { get; set; } = string.Empty;
        public string? Address { get; set; } = string.Empty;
        public string? LibraryCardNumber { get; set; } = string.Empty;
    }
}
