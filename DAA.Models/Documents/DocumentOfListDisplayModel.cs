namespace DAA.Models.Documents
{
    public class DocumentOfListDisplayModel
    {
        public string? Number { get; set; } = string.Empty;
        public string? Title { get; set; }
        public int? Id { get; set; }
        public int? ExternalIdentifier { get; set; }
        public string CommonId { get; set; } = string.Empty;
        public bool Deleted { get; set; }
        public int? StartSheetNumber { get; set; }
        public int? EndSheetNumber { get; set; }
        //public string? Status { get; set; } засега го няма при нас
        public string? DescriptionLevel { get; set; }
        public string? ApproximateChronologicalScope { get; set; }
    }
}
