namespace DAA.Data.RemoteDBEntities
{
    public class DigitalObjectDisplayModel
    {
        public int? Id { get; set; }
        public Guid? SystemIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool? IsDraft { get; set; }
        public int? ArchiveCode { get; set; }
        public string? ArchiveName { get; set; }
        public bool? FundHasExternalSource { get; set; }
        public int? FundExternalIdentifier { get; set; }
        public string? FundNumber { get; set; }
        public bool? InventoryHasExternalSource { get; set; }
        public int? InventoryExternalIdentifier { get; set; }
        public string? InventoryNumber { get; set; }
        public bool? ArchivalEntityHasExternalSource { get; set; }
        public int? ArchivalEntityExternalIdentifier { get; set; }
        public string? ArchivalEntityNumber { get; set; }
        public int? DocumentExternalIdentifier { get; set; }
        public bool? DocumentHasExternalSource { get; set; }
        public string? DocumentNumber { get; set; }
        public int? ParentId { get; set; }
        public Guid? ParentSystemIdentifier { get; set; }
        public int? TypeCode { get; set; }
        public string? Name { get; set; }
        public string? SourceName { get; set; }
        public string? UncPath { get; set; }
        public string? FileType { get; set; }
        public bool? IsDigitized { get; set; }
        public bool? IsImported { get; set; }
    }
}
