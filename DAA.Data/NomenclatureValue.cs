using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class NomenclatureValue
    {
        public int Id { get; set; }
        public int EntityId { get; set; }
        public string EntityType { get; set; } = null!;
        public int NomenclatureId { get; set; }
        public string NomenclatureCode { get; set; } = null!;
        public int ValueId { get; set; }
        public string ValueCode { get; set; } = null!;
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public bool EntityIsDraft { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
    }
}
