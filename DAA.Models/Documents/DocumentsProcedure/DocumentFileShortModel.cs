
namespace DAA.Models.Documents.DocumentsProcedure
{
    public class DocumentFileShortModel
    {
        public int Id { get; set; }
        public int DocumentId { get; set; }
        public string FileId { get; set; }
        public string? FileType { get; set; }
        public bool? Approved { get; set; }
        public bool? IsMaster { get; set; }
        public string? FileName { get; set; }
    }
}
