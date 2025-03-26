using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class FilmPackage
    {
        public FilmPackage()
        {
            FilmDraftPackageAs = new HashSet<FilmDraft>();
            FilmDraftPackageBs = new HashSet<FilmDraft>();
            FilmPackageAs = new HashSet<Film>();
            FilmPackageBs = new HashSet<Film>();
            FilmPackageDocuments = new HashSet<FilmPackageDocument>();
        }

        public int Id { get; set; }
        public string Type { get; set; } = null!;
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<FilmDraft> FilmDraftPackageAs { get; set; }
        public virtual ICollection<FilmDraft> FilmDraftPackageBs { get; set; }
        public virtual ICollection<Film> FilmPackageAs { get; set; }
        public virtual ICollection<Film> FilmPackageBs { get; set; }
        public virtual ICollection<FilmPackageDocument> FilmPackageDocuments { get; set; }
    }
}
