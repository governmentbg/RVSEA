using System;
using System.Collections.Generic;
using System.Text;

namespace DAA.Models.Admin
{
    public class RoleDisplayModel : RoleBaseModel
    {
        public string Id { get; set; }
        public string ClientName { get; set; }
        public string UnitName { get; set; }
        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; }
        public string CreatedByName { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public string UpdatedBy { get; set; }
        public string UpdatedByName { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public string DeletedBy { get; set; }
        public string DeletedByName { get; set; }
    }
}
