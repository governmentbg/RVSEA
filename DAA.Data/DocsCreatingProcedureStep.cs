using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class DocsCreatingProcedureStep
    {
        public DocsCreatingProcedureStep()
        {
            DocumentProcedures = new HashSet<DocumentProcedure>();
        }

        public int Id { get; set; }
        public string Title { get; set; } = null!;
        public string? ResponsibleUserType { get; set; }

        public virtual ICollection<DocumentProcedure> DocumentProcedures { get; set; }
    }
}
