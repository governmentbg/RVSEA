using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class DockProcComment
    {
        public int Id { get; set; }
        public int ProcedureId { get; set; }
        public int CommentId { get; set; }
        public int? CommentType { get; set; }

        public virtual Comment Comment { get; set; } = null!;
        public virtual DocumentProcedure Procedure { get; set; } = null!;
    }
}
