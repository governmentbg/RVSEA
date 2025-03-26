using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class FilmCardDocument
    {
        public int Id { get; set; }
        public int CardId { get; set; }
        public int PackageDocumentId { get; set; }
        public bool IsDraft { get; set; }

        public virtual FilmPackageDocument PackageDocument { get; set; } = null!;
    }
}
