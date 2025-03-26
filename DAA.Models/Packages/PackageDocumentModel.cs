

namespace DAA.Models.Packages
{
    public class PackageDocumentModel
    {
        public int Id { get; set; }
        public int PackageId { get; set; }
        public int DocumentTypeId { get; set; }
        public string FileId { get; set; }
        public string FilePath { get; set; }
        public string FileName { get; set; }
        public string FileType { get; set; }
        public string ContentType { get; set; }
        public long? FileSizeInBytes { get; set; }
        public string Description { get; set; }
    }
}
