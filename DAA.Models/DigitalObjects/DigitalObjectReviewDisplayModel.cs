using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.DigitalObjects
{
    public class DigitalObjectReviewDisplayModel
    {
        public Guid SystemIdentifier { get; set; }
        public Guid? UserSystemIdentifier { get; set; }
        public string? DigitalObjectName { get; set; }
        public string? ArchivalEntityNumber { get; set; }
        public string? DocumentNumber { get; set; }
        public string? UserDisplayName { get; set; }
        public string? UserType { get; set; } = null!;
        public DateTime? Date { get; set; }
    }
}
