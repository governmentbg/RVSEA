using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class DocumentProcedure
    {
        public DocumentProcedure()
        {
            DockProcComments = new HashSet<DockProcComment>();
        }

        public int Id { get; set; }
        public bool Completed { get; set; }
        public int ProcedureStepId { get; set; }
        public int? DocumentId { get; set; }
        public int? ArchiveEntityId { get; set; }
        public int? ArchiveEntityExternalIdentifier { get; set; }
        public int? ProcedureTypeId { get; set; }

        public virtual Document? Document { get; set; }
        public virtual DocsCreatingProcedureStep ProcedureStep { get; set; } = null!;
        public virtual DocumentCreatingProceduresType? ProcedureType { get; set; }
        public virtual ICollection<DockProcComment> DockProcComments { get; set; }
    }
}
