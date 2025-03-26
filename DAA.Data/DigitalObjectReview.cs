using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class DigitalObjectReview
    {
        public int Id { get; set; }
        public Guid SystemIdentifier { get; set; }
        public Guid DigitalObjectSystemIdentifier { get; set; }
        public Guid DocumentSystemIdentifier { get; set; }
        public Guid ArchivalEntitySystemIdentifier { get; set; }
        public Guid UserSystemIdentifier { get; set; }
        public DateTime Date { get; set; }

        public virtual AspNetUser UserSystemIdentifierNavigation { get; set; } = null!;
    }
}
