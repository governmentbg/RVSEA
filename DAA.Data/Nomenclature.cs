using System;
using System.Collections.Generic;

namespace DAA.Data
{
    public partial class Nomenclature
    {
        public Nomenclature()
        {
            FilmCardCountries = new HashSet<FilmCard>();
            FilmCardDraftCountries = new HashSet<FilmCardDraft>();
            FilmCardDraftFilmingExtents = new HashSet<FilmCardDraft>();
            FilmCardFilmingExtents = new HashSet<FilmCard>();
            FilmDrafts = new HashSet<FilmDraft>();
            Films = new HashSet<Film>();
            FundDrafts = new HashSet<FundDraft>();
            Funds = new HashSet<Fund>();
            Inventories = new HashSet<Inventory>();
            InventoryDrafts = new HashSet<InventoryDraft>();
            InverseParent = new HashSet<Nomenclature>();
        }

        public int Id { get; set; }
        public int? ParentId { get; set; }
        public DateTime? CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public bool Deleted { get; set; }
        public DateTime? DeletedOn { get; set; }
        public Guid? DeletedBy { get; set; }
        public string Code { get; set; } = null!;
        public string Text { get; set; } = null!;
        public string? Description { get; set; }
        public int? SortOrder { get; set; }
        public bool Inactive { get; set; }
        public bool Locked { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public DateTime? ExternalSourceUpdatedOn { get; set; }

        public virtual AspNetUser? CreatedByNavigation { get; set; }
        public virtual AspNetUser? DeletedByNavigation { get; set; }
        public virtual Nomenclature? Parent { get; set; }
        public virtual AspNetUser? UpdatedByNavigation { get; set; }
        public virtual ICollection<FilmCard> FilmCardCountries { get; set; }
        public virtual ICollection<FilmCardDraft> FilmCardDraftCountries { get; set; }
        public virtual ICollection<FilmCardDraft> FilmCardDraftFilmingExtents { get; set; }
        public virtual ICollection<FilmCard> FilmCardFilmingExtents { get; set; }
        public virtual ICollection<FilmDraft> FilmDrafts { get; set; }
        public virtual ICollection<Film> Films { get; set; }
        public virtual ICollection<FundDraft> FundDrafts { get; set; }
        public virtual ICollection<Fund> Funds { get; set; }
        public virtual ICollection<Inventory> Inventories { get; set; }
        public virtual ICollection<InventoryDraft> InventoryDrafts { get; set; }
        public virtual ICollection<Nomenclature> InverseParent { get; set; }
    }
}
