using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace DAA.Models.Admin
{
    public class RoleBaseModel
    {
        [Required]
        public string Name { get; set; }
        public IEnumerable<string> Permissions { get; set; }
        [Required]
        public int UnitId { get; set; }
        public int ClientId { get; set; }
    }
}
