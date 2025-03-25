using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Users
{
    public class UserProfileModel
    {
        public int? Id { get; set; }
        [Required]
        public Guid UserId { get; set; }
        [Required]
        public string ProfileType { get; set; } = string.Empty;
        public string? EntityType { get; set; }
        [Required]
        public string FirstName { get; set; } = string.Empty;
        public string? Surname { get; set; }
        [Required]
        public string LastName { get; set; } = string.Empty;
        public string? Organization { get; set; }
        public string? Department { get; set; }
        public string? JobTitle { get; set; }
        public string? Address { get; set; }
        public string? LibraryCardNumber { get; set; }
        public DateTime? LibraryCardValidTo { get; set; }
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public string? Eik { get; set; }
        public string? DisplayName { get; set; }
        public string? UserName { get; set; }

        public string FullName 
        {
            get
            {
                return $"{FirstName} {Surname} {LastName}";
            }
        } 
    }
}
