namespace DAA.Extensions.DynamicLinq
{
    public class DataSourceRequestModel
    {
        public int Page { get; set; }

        public int ItemsPerPage { get; set; }

        public string? SearchString { get; set; }

        public string? SortBy { get; set; }

        public bool SortDesc { get; set; }
        public string? SortByType { get; set; }

        public Filter? Filter { get; set; }
    }
}
