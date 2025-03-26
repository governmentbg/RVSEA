using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Authentication
{
    public class AccountConfirmationModel
    {
        [Required]
        public Guid UserId { get; set; }
        [Required]
        public string ConfirmationToken { get; set; }

    }
}
