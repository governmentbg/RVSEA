using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.DigitalObjects
{
    public class DigitalObjectReviewModel
    {
        public int? Id { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public Guid DigitalObjectSystemIdentifier { get; set; }
        public Guid DocumentSystemIdentifier { get; set; }
        public Guid ArchivalEntitySystemIdentifier { get; set; }
        public Guid UserSystemIdentifier { get; set; }
        public string? UserDisplayName { get; set; }
        public string? UserType { get; set; }
        public DateTime? Date { get; set; }
    }
}
