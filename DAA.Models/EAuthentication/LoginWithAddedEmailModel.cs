using System.ComponentModel.DataAnnotations;

namespace DAA.Models.EAuthentication
{
    public class LoginWithAddedEmailModel
    {
        [Required]
        public string Email { get; set; } = string.Empty;
        [Required]
        public string CertPersonIdentifier { get; set; } = string.Empty;
        [Required]
        public string CertNames { get; set; } = string.Empty;
    }
}
