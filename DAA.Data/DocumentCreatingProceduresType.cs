using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class DocumentCreatingProceduresType
    {
        public DocumentCreatingProceduresType()
        {
            DocumentProcedures = new HashSet<DocumentProcedure>();
        }

        public int Id { get; set; }
        public string? Title { get; set; }

        public virtual ICollection<DocumentProcedure> DocumentProcedures { get; set; }
    }
}
