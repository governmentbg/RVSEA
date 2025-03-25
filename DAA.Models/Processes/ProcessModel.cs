using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Processes
{
    public class ProcessModel
    {
        public int? Id { get; set; }
        public int? ProcessTypeId { get; set; }
        public int? ActiveProcessStepId { get; set; }
        public int? ActiveProcessStepTypeId { get; set; }
        public int? ArchiveId { get; set; }
        public int? FundId { get; set; }
        public int? InventoryId { get; set; }
        public int? ArchivalEntityId { get; set; }
        public int? DocumentId { get; set; }
        public Guid? FundSystemIdentifier { get; set; }
        public Guid? InventorySystemIdentifier { get; set; }
        public Guid? ArchivalEntitySystemIdentifier { get; set; }
        public Guid? FilmSystemIdentifier { get; set; }
        public Guid? DocumentSystemIdentifier { get; set; }
        public bool Completed { get; set; }
    }
}
