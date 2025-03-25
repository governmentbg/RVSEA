namespace DAA.Models
{
    public class DropdownOption
    {
        public int? Id { get; set; }
        public string? Code { get; set; }
        public string Label { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? GroupName { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool? HasExternalSource { get; set; }
    }
}
