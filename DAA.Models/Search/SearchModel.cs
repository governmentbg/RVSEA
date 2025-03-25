
namespace DAA.Models.Search
{
    public class SearchModel 
    {
        public IEnumerable<string>? ArchiveId { get; set; }
        public IEnumerable<string>? DescriptionLevelCode { get; set; }
        public IEnumerable<string>? DescriptionLevelCodeExternal { get; set; }
        public IEnumerable<string>? CmfCountriesOfOriginCodes { get; set; }
        public IEnumerable<string>?  FundArrayCode { get; set; }
        public IEnumerable<string>? FundArrayCodeExternal { get; set; }
        public DateTime? DateFrom { get; set; }
        public DateTime? DateTo { get; set; }
        public string? FundNumber { get; set; }
        public string? InventoryNumber { get; set; }
        public string? ArchivalEntityNumber { get; set; }
        public string? CmfNumber { get; set; }
        public bool? AdvancedSearch {get; set;}
        public bool? SearchFileContent { get; set;}
        public bool? ForeignArchives {get; set;}
        public string? Name { get; set; }
        public string? SearchByDigitalCopies { get; set; }
        public string? KeyWords { get; set; }
        public int? Page { get; set; }
        public int? ItemsPerPage { get; set; }
        public string? SearchString { get; set; }
        public string? SortBy { get; set; }
        public bool? SortDesc { get; set; }
        public string? SortByType { get; set; }
    }
}