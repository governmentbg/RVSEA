namespace DAA.Models.ArchiveEntities
{
    public class ArchiveEntityOfListDisplayModel
    {
        public string? Number { get; set; } = string.Empty;
        public string? Title { get; set; }
        public int? Id { get; set; }      
        public int? ExternalIdentifier { get; set; }
        public string CommonId { get; set; } = string.Empty;
        public bool Deleted { get; set; }
        public string? Status { get; set; }
        public string? DescriptionLevel { get; set; }
        public string? ApproximateChronologicalScope { get; set; }
    }
}
