namespace DAA.Models.DigitalObjects
{
    public class DigitalObjectReviewSearchModel
    {
        public int Page { get; set; }

        public int ItemsPerPage { get; set; }

        public string? SearchString { get; set; }

        public string? SortBy { get; set; }

        public bool SortDesc { get; set; }
        public string? SortByType { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string? ArchivalEntitySystemIdentifier { get; set; }
    }
}
