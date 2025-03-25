namespace DAA.Extensions.DynamicLinq
{
    public class DataSourceResponseModel<T>
    {
        public long TotalCount { get; set; }

        public IEnumerable<T>? Items { get; set; }
        public List<object>? Errors { get; set; }
        public bool? IsExternalSourceSnapshot { get; set; }

        public string? TotalCountInWords { get; set; }
    }
}
