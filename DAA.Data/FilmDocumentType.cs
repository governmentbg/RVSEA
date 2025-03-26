using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class FilmDocumentType
    {
        public FilmDocumentType()
        {
            FilmPackageDocuments = new HashSet<FilmPackageDocument>();
        }

        public int Id { get; set; }
        public string Code { get; set; } = null!;
        public string Text { get; set; } = null!;
        public string PackageType { get; set; } = null!;
        public bool IsRequired { get; set; }

        public virtual ICollection<FilmPackageDocument> FilmPackageDocuments { get; set; }
    }
}
