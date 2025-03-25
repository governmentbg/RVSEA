namespace DAA.Models.Configuration
{
    public class OpenDataSettings
    {
        public const string Name = "OpenDataSettings";
        public string Url { get; set; } = "https://data.egov.bg/api/";
        public string ApiKey { get; set; } = "";
        public int OrgId { get; set; }
        public int DataCategory { get; set; }
        public List<OpenDataDatasetSettings> Datasets { get; set; } = new List<OpenDataDatasetSettings>();
    }

    public class OpenDataDatasetSettings
    {
        public int Id { get; set; }
        public string Uri { get; set; } = "";
        public string Name { get; set; } = "";
        public string Code { get; set; } = "";
        public string ResourceUri { get; set; } = "";
        public string ResourceName { get; set; } = "";
    }
}
