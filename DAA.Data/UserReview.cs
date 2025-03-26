using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class UserReview
    {
        public int Id { get; set; }
        public Guid SystemIdentifier { get; set; }
        public Guid UserId { get; set; }
        public DateTime Date { get; set; }
        public Guid? FundSystemIdentifier { get; set; }
        public int? FundExternalIdentifier { get; set; }
        public Guid? InventorySystemIdentifier { get; set; }
        public int? InventoryExternalIdentifier { get; set; }
        public Guid? ArchivalEntitySystemIdentifier { get; set; }
        public int? ArchivalEntityExternalIdentifier { get; set; }
        public Guid? DocumentSystemIdentifier { get; set; }
        public int? DocumentExternalIdentifier { get; set; }

        public virtual AspNetUser User { get; set; } = null!;
    }
}
