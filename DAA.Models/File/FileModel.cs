namespace DAA.Models.File
{
    public class FileModel
    {
        public string Name { get; set; } = null!;
        public string SystemName { get; set; } = null!;
        public string Type { get; set; } = null!;
        public string ContentType { get; set; } = null!;
        public long Size { get; set; } = 0;
        public byte[]? Content { get; set; }
    }
}
