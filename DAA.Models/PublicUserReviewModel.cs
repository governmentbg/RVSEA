using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models
{
    public class PublicUserReviewModel
    {
        public int? Id { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public Guid UserId { get; set; }
        public string? UserDisplayName { get; set; } = null!;
        public string? UserProfileType { get; set; } = null!;
        public DateTime? Date { get; set; }
        public Guid? FundSystemIdentifier { get; set; }
        public Guid? InventorySystemIdentifier { get; set; }
        public Guid? ArchivalEntitySystemIdentifier { get; set; }
        public Guid? DocumentSystemIdentifier { get; set; }
    }
}
