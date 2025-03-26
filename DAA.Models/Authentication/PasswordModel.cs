using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Authentication
{
    public class PasswordModel
    {
        [Required]
        public Guid UserId { get; set; }
        [Required]
        public string PasswordToken { get; set; } = string.Empty;
        [Required]
        public string Password { get; set; } = string.Empty;
        [Required]
        public string PasswordConfirmation { get; set; } = string.Empty;
        public string? CurrentPassword { get; set; }
    }
}
